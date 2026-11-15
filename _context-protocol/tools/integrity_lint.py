#!/usr/bin/env python3
"""context-protocol 무결성 린트 (실행판)

`_context-protocol/_views/integrity-lint.md` 의 규칙을 에이전트와 Obsidian 없이 돌린다.
규칙의 정의는 `_context-protocol/_schema/concept-scheme.md` "무결성 규칙" 이 정본이고,
이 스크립트는 그 실행판이다. 둘이 어긋나면 스키마가 맞다.

사용법:
    python3 _context-protocol/tools/integrity_lint.py [워크스페이스 루트] [--json] [--signals-fail]

- 규칙 위반이 하나라도 있으면 종료 코드 1. 없으면 0.
- 검토 신호(분해 검토, 근거 drift, 효력 만료)는 기본적으로 종료 코드에 넣지 않는다.
  `--signals-fail` 을 주면 신호도 실패로 친다(CI 에서 엄격하게 볼 때).
- 표준 라이브러리만 쓴다. PyYAML 이 있으면 frontmatter 를 그것으로 읽는다.

CI 에서 쓰는 법은 저장소 `docs/조직-도입-가이드.md` 참고.
"""
from __future__ import annotations

import argparse
import datetime as dt
import json
import os
import re
import sys
import unicodedata
from pathlib import Path

EXCLUDE_DIRS = {"_deprecated_v3", "_deprecated_v5", ".git", ".obsidian", ".trash", "node_modules"}
SKIP_TYPES_ORPHAN = {"concept", "view", "schema", "readme", "proposal", "project-descriptor"}
SKIP_TYPES_DECOMP = {"view", "schema", "readme", "proposal", "project-descriptor"}
PROV_RE = re.compile(r"^##\s+(확정|제안|열린 질문|Confirmed|Proposed|Open questions)")
LINK_RE = re.compile(r"\[\[([^\]|#]+)(?:#[^\]|]*)?(?:\|[^\]]*)?\]\]")


def nfc(s: str) -> str:
    return unicodedata.normalize("NFC", s)


# ---------- frontmatter ----------

def _scalar(v: str):
    v = v.strip()
    if not v:
        return None
    if (v[0] == v[-1]) and v[0] in "\"'" and len(v) >= 2:
        return v[1:-1]
    if v.startswith("[") and v.endswith("]"):
        inner = v[1:-1].strip()
        if not inner:
            return []
        out, buf, q = [], "", None
        depth = 0
        for ch in inner:
            if q:
                buf += ch
                if ch == q:
                    q = None
            elif ch in "\"'":
                q = ch
                buf += ch
            elif ch == "[":
                depth += 1
                buf += ch
            elif ch == "]":
                depth -= 1
                buf += ch
            elif ch == "," and depth == 0:
                out.append(_scalar(buf))
                buf = ""
            else:
                buf += ch
        if buf.strip():
            out.append(_scalar(buf))
        return out
    if v in ("true", "false"):
        return v == "true"
    return v


def _mini_yaml_safe(text: str) -> dict:
    # 목록 항목이 중첩 매핑 자리로 들어간 경우를 바로잡는 2단계 파서
    root: dict = {}
    lines = [l for l in text.splitlines() if l.strip() and not l.lstrip().startswith("#")]
    i = 0

    def parse_block(base_indent: int, i: int):
        obj = None
        while i < len(lines):
            raw = lines[i]
            indent = len(raw) - len(raw.lstrip(" "))
            if indent < base_indent:
                break
            line = raw.strip()
            if line.startswith("- "):
                if obj is None:
                    obj = []
                if not isinstance(obj, list):
                    break
                obj.append(_scalar(line[2:]))
                i += 1
                continue
            m = re.match(r"^([^:]+):(.*)$", line)
            if not m:
                i += 1
                continue
            if obj is None:
                obj = {}
            if not isinstance(obj, dict):
                break
            k, v = m.group(1).strip(), m.group(2)
            i += 1
            if v.strip() == "":
                if i < len(lines):
                    nxt = lines[i]
                    nind = len(nxt) - len(nxt.lstrip(" "))
                    if nind > indent or (nind == indent and nxt.strip().startswith("- ")):
                        child, i = parse_block(nind, i)
                        obj[k] = child
                        continue
                obj[k] = None
            else:
                obj[k] = _scalar(v)
        return obj, i

    res, _ = parse_block(0, 0)
    return res if isinstance(res, dict) else root


def read_frontmatter(text: str) -> dict | None:
    if not text.startswith("---"):
        return None
    lines = text.split("\n")
    if lines[0].strip() != "---":
        return None
    for j in range(1, len(lines)):
        if lines[j].strip() in ("---", "..."):
            block = "\n".join(lines[1:j])
            try:
                import yaml  # type: ignore

                data = yaml.safe_load(block)
                return data if isinstance(data, dict) else {}
            except ImportError:
                return _mini_yaml_safe(block)
            except Exception:
                return {"__yaml_error__": True}
    return None


# ---------- 워크스페이스 모델 ----------

class Note:
    def __init__(self, root: Path, path: Path):
        self.path = path
        self.rel = nfc(path.relative_to(root).as_posix())
        self.folder = nfc(path.parent.relative_to(root).as_posix()) if path.parent != root else ""
        self.name = nfc(path.stem)
        self.text = path.read_text(encoding="utf-8", errors="replace")
        self.fm = read_frontmatter(self.text) or {}
        self.type = self.fm.get("type")
        self.mtime = path.stat().st_mtime


def as_list(v):
    if v is None:
        return []
    return v if isinstance(v, list) else [v]


def link_target(v) -> str | None:
    if v is None:
        return None
    if isinstance(v, list):
        # YAML 이 [[x]] 를 중첩 리스트로 읽은 경우
        flat = v
        while isinstance(flat, list) and len(flat) == 1:
            flat = flat[0]
        v = flat if isinstance(flat, str) else str(v)
    s = str(v).strip()
    m = LINK_RE.search(s)
    if m:
        return nfc(m.group(1).strip())
    return nfc(s) if s else None


def walk(root: Path):
    md, files = [], []
    for dirpath, dirnames, filenames in os.walk(root):
        dirnames[:] = [d for d in dirnames if d not in EXCLUDE_DIRS and not d.startswith(".")]
        for f in filenames:
            if f.startswith("."):
                continue
            p = Path(dirpath) / f
            files.append(p)
            if f.endswith(".md"):
                md.append(p)
    return md, files


class Resolver:
    """Obsidian 식 위키링크 해석: 경로가 맞으면 그 파일, 아니면 파일명(확장자 생략 가능)으로 찾는다."""

    def __init__(self, root: Path, files):
        self.by_rel = {}
        self.by_name: dict = {}
        for p in files:
            rel = nfc(p.relative_to(root).as_posix())
            self.by_rel[rel] = rel
            name = nfc(p.name)
            self.by_name.setdefault(name, []).append(rel)
            if name.endswith(".md"):
                self.by_name.setdefault(name[:-3], []).append(rel)

    def resolve(self, target: str) -> str | None:
        t = target.strip().lstrip("/")
        for cand in (t, t + ".md"):
            if cand in self.by_rel:
                return cand
        base = t.split("/")[-1]
        hits = self.by_name.get(base) or self.by_name.get(base + ".md")
        if hits:
            hits = sorted(hits, key=len)
            if "/" in t:
                for h in hits:
                    if h.endswith(t) or h.endswith(t + ".md"):
                        return h
            return hits[0]
        return None


def top_concept(root: Path, resolver: Resolver) -> str:
    scheme = root / "_context-protocol" / "_schema" / "concept-scheme.md"
    if scheme.exists():
        fm = read_frontmatter(scheme.read_text(encoding="utf-8")) or {}
        t = link_target(fm.get("top_concept"))
        if t:
            return t.split("/")[-1]
    return "context-infrastructure"


def to_date(v):
    if v is None:
        return None
    if isinstance(v, dt.datetime):
        return v.date()
    if isinstance(v, dt.date):
        return v
    try:
        return dt.date.fromisoformat(str(v).strip()[:10])
    except ValueError:
        return None


def lint(root: Path, today: dt.date | None = None) -> dict:
    today = today or dt.date.today()
    md_paths, all_files = walk(root)
    notes = [Note(root, p) for p in md_paths]
    by_rel = {n.rel: n for n in notes}
    res = Resolver(root, all_files)
    top = top_concept(root, res)

    errors: dict[str, list] = {
        "rule1_broader": [],
        "rule2_dangling": [],
        "rule3_orphan": [],
        "rule4_cycle": [],
        "rule5_top_concept": [],
        "rule6_project_subjects": [],
        "yaml_error": [],
    }
    signals: dict[str, list] = {"decomposition": [], "grounded_drift": [], "validity_expired": []}

    for n in notes:
        if n.fm.get("__yaml_error__"):
            errors["yaml_error"].append({"note": n.rel})

    concepts = [n for n in notes if n.type == "concept"]
    concept_folders = {n.folder for n in concepts if not n.folder.endswith("_concepts")}

    # 규칙 1: broader 정확히 1개 (top 제외)
    for n in concepts:
        b = as_list(n.fm.get("broader"))
        b = [x for x in b if link_target(x)]
        if n.name == top:
            continue
        if len(b) != 1:
            errors["rule1_broader"].append({"note": n.rel, "broader_count": len(b)})

    # 규칙 5: top concept 는 정확히 1개
    tops = [n.rel for n in concepts if n.name == top]
    if len(tops) != 1:
        errors["rule5_top_concept"].append({"top_concept": top, "found": tops})

    # 규칙 2: 댕글링
    for n in notes:
        if n.type not in ("concept", "document"):
            continue
        for key in ("broader", "subject", "canon_note", "related"):
            for l in as_list(n.fm.get(key)):
                t = link_target(l)
                if t and res.resolve(t) is None:
                    errors["rule2_dangling"].append({"note": n.rel, "key": key, "target": t})
        for key in ("grounded_on", "supersedes"):
            for l in as_list(n.fm.get(key)):
                t = link_target(l)
                if t and res.resolve(t) is None:
                    errors["rule2_dangling"].append({"note": n.rel, "key": key, "target": t})

    # 규칙 3: 소속 미결정 문서
    for n in notes:
        if n.type in SKIP_TYPES_ORPHAN:
            continue
        if n.fm.get("subject"):
            continue
        if n.folder in concept_folders:
            continue
        errors["rule3_orphan"].append({"note": n.rel, "folder": n.folder})

    # 규칙 4: broader 순환
    parent = {}
    for n in concepts:
        b = [link_target(x) for x in as_list(n.fm.get("broader"))]
        b = [x for x in b if x]
        parent[n.rel] = res.resolve(b[0]) if b else None
    for start in parent:
        cur, seen, steps = parent[start], {start}, 0
        while cur and steps < 100:
            if cur in seen:
                errors["rule4_cycle"].append({"note": start})
                break
            seen.add(cur)
            cur = parent.get(cur)
            steps += 1

    # 규칙 6: _project.md suitability.subjects
    for n in notes:
        if n.type != "project-descriptor":
            continue
        suit = n.fm.get("suitability") or {}
        subs = suit.get("subjects") if isinstance(suit, dict) else None
        for l in as_list(subs):
            t = link_target(l)
            hit = res.resolve(t) if t else None
            if not hit or by_rel.get(hit) is None or by_rel[hit].type != "concept":
                errors["rule6_project_subjects"].append({"note": n.rel, "target": t})

    # 검토 신호: 분해 검토
    def has_sub(f):
        return any(c != f and c.startswith(f + "/") for c in concept_folders)

    for n in notes:
        if n.rel.startswith("_context-protocol/") or n.rel.startswith("memory/") or "action-log" in n.folder.split("/"):
            continue
        if n.type in SKIP_TYPES_DECOMP or n.fm.get("canon_note") or n.fm.get("derived_from"):
            continue
        if n.folder not in concept_folders or has_sub(n.folder):
            continue
        lines = n.text.split("\n")
        h2 = sum(1 for l in lines if re.match(r"^##\s", l) and not PROV_RE.match(l))
        if len(lines) > 200 or h2 > 5:
            signals["decomposition"].append({"note": n.rel, "lines": len(lines), "h2": h2})

    # 검토 신호: 근거 drift
    for n in notes:
        if n.type != "document" or not n.fm.get("grounded_on"):
            continue
        base_d = max([d for d in (to_date(n.fm.get("updated")), to_date(n.fm.get("grounded_checked"))) if d], default=None)
        base_ts = (dt.datetime.combine(base_d, dt.time.max).timestamp() if base_d else n.mtime)
        for l in as_list(n.fm.get("grounded_on")):
            t = link_target(l)
            hit = res.resolve(t) if t else None
            if hit:
                m = (root / hit).stat().st_mtime
                if m > base_ts:
                    signals["grounded_drift"].append({
                        "note": n.rel, "source": hit,
                        "source_mtime": dt.datetime.fromtimestamp(m).date().isoformat(),
                    })

    # 검토 신호: 효력 만료 (프리셋이 쓰는 종료 필드와 범용 valid_until)
    end_keys = ("valid_until", "effectiveTo", "coversTo", "endDate")
    for n in notes:
        if n.type != "document":
            continue
        for k in end_keys:
            d = to_date(n.fm.get(k))
            if d and d < today:
                status = n.fm.get("status")
                if status in ("superseded", "retired", "expired", "closed"):
                    continue
                signals["validity_expired"].append({"note": n.rel, "key": k, "date": d.isoformat()})

    return {"root": str(root), "today": today.isoformat(), "notes": len(notes), "errors": errors, "signals": signals}


LABELS = {
    "rule1_broader": "규칙 1) broader 가 정확히 1개가 아닌 concept",
    "rule2_dangling": "규칙 2) 댕글링 링크",
    "rule3_orphan": "규칙 3) 소속 미결정 document",
    "rule4_cycle": "규칙 4) broader 순환",
    "rule5_top_concept": "규칙 5) top concept 가 정확히 1개가 아님",
    "rule6_project_subjects": "규칙 6) _project.md suitability.subjects 미해결",
    "yaml_error": "frontmatter 를 읽지 못한 노트",
    "decomposition": "검토 신호) 분해 검토",
    "grounded_drift": "검토 신호) 근거 drift",
    "validity_expired": "검토 신호) 효력 만료",
}


def main(argv=None) -> int:
    ap = argparse.ArgumentParser(description="context-protocol 무결성 린트")
    ap.add_argument("root", nargs="?", default=".", help="워크스페이스 루트 (기본: 현재 폴더)")
    ap.add_argument("--json", action="store_true", help="JSON 으로 출력")
    ap.add_argument("--signals-fail", action="store_true", help="검토 신호도 실패로 친다")
    ap.add_argument("--today", help="기준일 YYYY-MM-DD (테스트용)")
    a = ap.parse_args(argv)
    root = Path(a.root).resolve()
    if not (root / "_context-protocol").is_dir():
        print(f"{root} 에 _context-protocol/ 이 없다. 워크스페이스 루트를 지정한다.", file=sys.stderr)
        return 2
    today = dt.date.fromisoformat(a.today) if a.today else None
    r = lint(root, today)
    n_err = sum(len(v) for v in r["errors"].values())
    n_sig = sum(len(v) for v in r["signals"].values())
    if a.json:
        print(json.dumps(r, ensure_ascii=False, indent=2))
    else:
        print(f"무결성 린트: {root} (md {r['notes']}개, 기준일 {r['today']})")
        for group in ("errors", "signals"):
            for k, rows in r[group].items():
                if rows:
                    print(f"\n{LABELS[k]} ({len(rows)})")
                    for row in rows:
                        print("  - " + ", ".join(f"{kk}={vv}" for kk, vv in row.items()))
        print(f"\n규칙 위반 {n_err}건, 검토 신호 {n_sig}건. " + ("통과." if n_err == 0 else "실패."))
    if n_err or (a.signals_fail and n_sig):
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
