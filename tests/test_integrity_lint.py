"""integrity_lint.py 테스트. 픽스처 워크스페이스는 임시 폴더에 만든다.

저장소 안에 픽스처 md 를 두지 않는다. 이 저장소의 작업 트리가 곧 프로토콜 워크스페이스라서,
일부러 틀리게 만든 노트가 그 워크스페이스의 린트에 걸리기 때문이다.

실행: python3 -m unittest discover -s tests
"""
import datetime as dt
import importlib.util
import sys
import tempfile
import textwrap
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location("integrity_lint", ROOT / "_context-protocol/tools/integrity_lint.py")
lint_mod = importlib.util.module_from_spec(spec)
spec.loader.exec_module(lint_mod)

SCHEME = """---
type: schema
title: scheme
scheme_id: test
top_concept: "[[context-infrastructure]]"
---
"""

OK_FILES = {
    "_context-protocol/_schema/concept-scheme.md": SCHEME,
    "_context-protocol/_concepts/context-infrastructure.md": "---\ntype: concept\n---\n# top\n",
    "_project.md": textwrap.dedent("""\
        ---
        type: project-descriptor
        suitability:
          subjects: ["[[context-infrastructure]]", "[[notes]]"]
        ---
        """),
    "notes/notes.md": "---\ntype: concept\nbroader: \"[[context-infrastructure]]\"\n---\n# notes\n",
    "notes/a.md": "---\ntype: document\nupdated: 2026-01-01\n---\n# a\n",
    "notes/sub/sub.md": "---\ntype: concept\nbroader: \"[[notes]]\"\n---\n",
    "notes/b.md": textwrap.dedent("""\
        ---
        type: document
        subject:
          - "[[notes]]"
        grounded_on:
          - "[[source.pdf]]"
        supersedes: ["[[a]]"]
        updated: 2026-01-01
        ---
        """),
    "notes/source.pdf": "%PDF",
    "README.md": "---\ntype: readme\n---\n# readme\n",
    "_context-protocol/_deprecated_v5/old.md": "# 점검 제외\n",
}


def make_ws(files):
    d = Path(tempfile.mkdtemp())
    for rel, body in files.items():
        p = d / rel
        p.parent.mkdir(parents=True, exist_ok=True)
        p.write_text(body, encoding="utf-8")
    return d


def counts(r):
    return {k: len(v) for k, v in r["errors"].items()}, {k: len(v) for k, v in r["signals"].items()}


class LintTest(unittest.TestCase):
    def run_both(self, files, today=dt.date(2026, 6, 1)):
        """PyYAML 이 있을 때와 없을 때 결과가 같아야 한다."""
        ws = make_ws(files)
        a = lint_mod.lint(ws, today)
        saved = sys.modules.get("yaml")
        sys.modules["yaml"] = None
        try:
            b = lint_mod.lint(ws, today)
        finally:
            if saved is None:
                sys.modules.pop("yaml", None)
            else:
                sys.modules["yaml"] = saved
        self.assertEqual(a["errors"], b["errors"])
        self.assertEqual(a["signals"], b["signals"])
        return a

    def test_clean_workspace_passes(self):
        e, s = counts(self.run_both(OK_FILES))
        self.assertEqual(sum(e.values()), 0, e)

    def test_rule1_missing_broader(self):
        f = dict(OK_FILES)
        f["notes/sub/sub.md"] = "---\ntype: concept\n---\n"
        e, _ = counts(self.run_both(f))
        self.assertEqual(e["rule1_broader"], 1)

    def test_rule2_dangling(self):
        f = dict(OK_FILES)
        f["notes/a.md"] = "---\ntype: document\nsubject: [\"[[nowhere]]\"]\n---\n"
        e, _ = counts(self.run_both(f))
        self.assertEqual(e["rule2_dangling"], 1)

    def test_rule3_orphan(self):
        f = dict(OK_FILES)
        f["loose/x.md"] = "# 소속 없음\n"
        e, _ = counts(self.run_both(f))
        self.assertEqual(e["rule3_orphan"], 1)

    def test_rule4_cycle(self):
        f = dict(OK_FILES)
        f["notes/notes.md"] = "---\ntype: concept\nbroader: \"[[sub]]\"\n---\n"
        e, _ = counts(self.run_both(f))
        self.assertGreaterEqual(e["rule4_cycle"], 1)

    def test_rule6_project_subjects(self):
        f = dict(OK_FILES)
        f["_project.md"] = "---\ntype: project-descriptor\nsuitability:\n  subjects: [\"[[ghost]]\"]\n---\n"
        e, _ = counts(self.run_both(f))
        self.assertEqual(e["rule6_project_subjects"], 1)

    def test_validity_expired_signal(self):
        f = dict(OK_FILES)
        f["notes/rule.md"] = "---\ntype: document\nvalid_until: 2026-03-31\n---\n"
        f["notes/old.md"] = "---\ntype: document\nvalid_until: 2026-03-31\nstatus: superseded\n---\n"
        r = self.run_both(f, today=dt.date(2026, 6, 1))
        e, s = counts(r)
        self.assertEqual(sum(e.values()), 0)
        self.assertEqual(s["validity_expired"], 1)

    def test_decomposition_signal(self):
        f = dict(OK_FILES)
        body = "---\ntype: document\n---\n" + "".join(f"## h{i}\n" for i in range(7))
        f["notes/sub/long.md"] = body  # 하위 개념 폴더가 없는 sub/ 안
        _, s = counts(self.run_both(f))
        self.assertEqual(s["decomposition"], 1)

    def test_nfd_filenames(self):
        import unicodedata
        f = dict(OK_FILES)
        name = unicodedata.normalize("NFD", "창업")
        f[f"{name}/{name}.md"] = "---\ntype: concept\nbroader: \"[[context-infrastructure]]\"\n---\n"
        f["notes/c.md"] = "---\ntype: document\nsubject: [\"[[창업]]\"]\n---\n"
        e, _ = counts(self.run_both(f))
        self.assertEqual(sum(e.values()), 0, e)

    def test_trust_inversion_signal(self):
        f = dict(OK_FILES)
        f["notes/raw.md"] = "---\ntype: document\ntrust_tier: unverified\n---\n"
        f["notes/curated.md"] = "---\ntype: document\ntrust_tier: verified\ngrounded_on: [\"[[raw]]\", \"[[source.pdf]]\"]\n---\n"
        f["notes/fine.md"] = "---\ntype: document\ntrust_tier: unverified\ngrounded_on: [\"[[raw]]\"]\n---\n"
        f["notes/nokey.md"] = "---\ntype: document\ngrounded_on: [\"[[raw]]\"]\n---\n"
        f["notes/bad.md"] = "---\ntype: document\ntrust_tier: maybe\n---\n"
        e, s = counts(self.run_both(f))
        self.assertEqual(sum(e.values()), 0, e)
        self.assertEqual(s["trust_inversion"], 2)  # curated 역전 + bad 허용값 아님


if __name__ == "__main__":
    unittest.main()
