#!/usr/bin/env python3
"""hwp2md: HWP(5.x) / HWPX 문서를 AI 가 읽을 수 있게 두 가지로 바꾼다.

  <원본이름>.md         글자. 표준 라이브러리만으로 뽑는다. 칸을 합친 표는 HTML 표로 남긴다.
  <원본이름>.pages.pdf  쪽 그림. rhwp(pip 패키지 rhwp-python)로 그린다. 없으면 깐다.
                        설치나 그리기가 실패하면 이 파일만 건너뛰고 글자 변환은 그대로 한다.

    python3 hwp2md.py <파일 또는 폴더> [...]            # 원본 옆에 두 파일을 쓴다
    python3 hwp2md.py --no-pages <파일 또는 폴더>       # 글자만
    python3 hwp2md.py --no-install <파일 또는 폴더>     # rhwp 가 없으면 깔지 않고 글자만
    python3 hwp2md.py --stdout <파일>                  # 글자를 화면으로만 출력
    python3 hwp2md.py --out-dir <폴더> <파일 또는 폴더>  # 결과를 다른 폴더에 쓴다

끝 상태 코드: 0 전부 성공, 1 글자도 그림도 못 얻은 파일이 하나 이상 있음.
실패와 생략은 표준 오류로 이유를 한 줄씩 알린다. 원본은 읽기만 하고 고치지 않는다.
"""
import io
import os
import re
import struct
import sys
import unicodedata
import zipfile
import zlib
import xml.etree.ElementTree as ET
from datetime import date

__version__ = "1.1"


class HwpError(Exception):
    """사람에게 그대로 보여 줄 수 있는 실패 이유."""


# ---------------------------------------------------------------------------
# Compound File Binary (OLE2) 최소 리더. HWP 5.x 는 이 컨테이너에 들어 있다.
# ---------------------------------------------------------------------------

_CFB_MAGIC = bytes.fromhex("D0CF11E0A1B11AE1")
_FREESECT, _ENDOFCHAIN = 0xFFFFFFFF, 0xFFFFFFFE


class _Cfb:
    def __init__(self, data):
        if data[:8] != _CFB_MAGIC:
            raise HwpError("HWP 5.x 형식이 아니다(OLE 서명 없음)")
        self.data = data
        self.ssz = 1 << struct.unpack_from("<H", data, 30)[0]
        self.mssz = 1 << struct.unpack_from("<H", data, 32)[0]
        (n_fat, dir_start, _, self.cutoff, minifat_start, n_minifat,
         difat_start, n_difat) = struct.unpack_from("<IIIIIIII", data, 44)
        difat = list(struct.unpack_from("<109I", data, 76))
        s = difat_start
        for _ in range(n_difat):
            if s in (_FREESECT, _ENDOFCHAIN):
                break
            vals = struct.unpack_from("<%dI" % (self.ssz // 4), self._sector(s))
            difat.extend(vals[:-1])
            s = vals[-1]
        fat_secs = [x for x in difat if x not in (_FREESECT, _ENDOFCHAIN)][:n_fat]
        fat = bytearray()
        for fs in fat_secs:
            fat += self._sector(fs)
        self.fat = struct.unpack("<%dI" % (len(fat) // 4), bytes(fat))
        # 디렉터리
        dir_data = self._chain(dir_start)
        self.entries = []
        for off in range(0, len(dir_data) - 127, 128):
            e = dir_data[off:off + 128]
            nlen = struct.unpack_from("<H", e, 64)[0]
            name = e[:max(nlen - 2, 0)].decode("utf-16-le", "replace")
            etype = e[66]
            left, right, child = struct.unpack_from("<III", e, 68)
            start = struct.unpack_from("<I", e, 116)[0]
            size = struct.unpack_from("<Q", e, 120)[0]
            if self.ssz == 512:
                size &= 0xFFFFFFFF
            self.entries.append(dict(name=name, type=etype, left=left, right=right,
                                     child=child, start=start, size=size))
        root = self.entries[0]
        self.ministream = self._chain(root["start"])[:root["size"]] if root["size"] else b""
        mf = self._chain(minifat_start) if n_minifat else b""
        self.minifat = struct.unpack("<%dI" % (len(mf) // 4), mf) if mf else ()

    def _sector(self, i):
        off = (i + 1) * self.ssz
        return self.data[off:off + self.ssz]

    def _chain(self, start):
        out, s, seen = bytearray(), start, set()
        while s not in (_FREESECT, _ENDOFCHAIN) and s < len(self.fat):
            if s in seen:
                raise HwpError("파일이 깨졌다(섹터 순환)")
            seen.add(s)
            out += self._sector(s)
            s = self.fat[s]
        return bytes(out)

    def _minichain(self, start, size):
        out, s, seen = bytearray(), start, set()
        while s not in (_FREESECT, _ENDOFCHAIN) and s < len(self.minifat):
            if s in seen:
                raise HwpError("파일이 깨졌다(미니 섹터 순환)")
            seen.add(s)
            off = s * self.mssz
            out += self.ministream[off:off + self.mssz]
            s = self.minifat[s]
        return bytes(out[:size])

    def _children(self, idx):
        """디렉터리 트리(레드블랙)에서 idx 의 자식 항목을 모두 모은다."""
        out, stack = [], [self.entries[idx]["child"]]
        while stack:
            i = stack.pop()
            if i == _FREESECT or i >= len(self.entries):
                continue
            e = self.entries[i]
            out.append(i)
            stack.extend([e["left"], e["right"]])
        return out

    def _find(self, path):
        idx = 0
        for part in path.split("/"):
            for c in self._children(idx):
                if self.entries[c]["name"] == part:
                    idx = c
                    break
            else:
                return None
        return idx

    def exists(self, path):
        return self._find(path) is not None

    def listdir(self, path):
        idx = self._find(path)
        if idx is None:
            return []
        return [self.entries[c]["name"] for c in self._children(idx)]

    def read(self, path):
        idx = self._find(path)
        if idx is None:
            raise HwpError("스트림이 없다: " + path)
        e = self.entries[idx]
        if e["size"] < self.cutoff:
            return self._minichain(e["start"], e["size"])
        return self._chain(e["start"])[:e["size"]]


# ---------------------------------------------------------------------------
# HWP 5.x 본문
# ---------------------------------------------------------------------------

_TAG_PARA_HEADER = 66
_TAG_PARA_TEXT = 67
_TAG_CTRL_HEADER = 71
_TAG_LIST_HEADER = 72
_TAG_TABLE = 77

# 컨트롤 문자: 한 글자짜리와 8 글자(16바이트)짜리
_CHAR_CTRL = {0, 10, 13, 24, 25, 26, 27, 28, 29, 30, 31}


def _records(buf):
    pos, n = 0, len(buf)
    while pos + 4 <= n:
        h = struct.unpack_from("<I", buf, pos)[0]
        pos += 4
        tag, level, size = h & 0x3FF, (h >> 10) & 0x3FF, (h >> 20) & 0xFFF
        if size == 0xFFF:
            size = struct.unpack_from("<I", buf, pos)[0]
            pos += 4
        yield tag, level, buf[pos:pos + size]
        pos += size


def _para_text(data):
    out, i, n = [], 0, len(data) // 2
    while i < n:
        c = struct.unpack_from("<H", data, i * 2)[0]
        if c >= 32:
            out.append(chr(c))
            i += 1
        elif c in _CHAR_CTRL:
            if c == 10:
                out.append("\n")
            elif c in (24, 30, 31):
                out.append(" " if c != 24 else "-")
            i += 1
        else:
            if c == 9:
                out.append("\t")
            i += 8
    return "".join(out).rstrip("\r")


def _clean(s):
    s = s.replace(" ", " ")
    s = re.sub(r"[ \t]+", " ", s)
    return s.strip()


def _cell_md(lines):
    txt = "<br>".join(x for x in (_clean(l) for l in lines) if x)
    return txt.replace("|", "\\|")


def _cell_html(lines):
    esc = lambda s: s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
    nested = lambda s: s.startswith(("<table>", "<tr>", "</table>"))  # 셀 안의 병합 표
    return "<br>".join(x if nested(x) else esc(x) for x in (_clean(l) for l in lines) if x)


def _render_html(cells):
    """병합 셀이 있는 표. 병합을 풀면 어떤 칸이 어느 묶음에 속하는지 사라지므로
    rowspan/colspan 을 살린 HTML 표로 낸다. 병합으로 가려진 칸은 원본에도 셀이 없다."""
    by_row = {}
    for (r, c), (lines, cs, rs) in cells.items():
        by_row.setdefault(r, []).append((c, lines, cs, rs))
    out = ["<table>"]
    for r in sorted(by_row):
        tds = []
        for c, lines, cs, rs in sorted(by_row[r], key=lambda x: x[0]):
            attr = (' rowspan="%d"' % rs if rs > 1 else "") + (' colspan="%d"' % cs if cs > 1 else "")
            tds.append("<td%s>%s</td>" % (attr, _cell_html(lines)))
        out.append("<tr>" + "".join(tds) + "</tr>")
    out.append("</table>")
    return out


def _render_table(rows, cols, cells):
    """cells: {(row, col): (문단 줄 목록, colspan, rowspan)}"""
    if not cells or not any(_cell_md(v[0]) for v in cells.values()):
        return []
    merged = any(cs > 1 or rs > 1 for _, cs, rs in cells.values())
    if merged and cols > 1:
        return _render_html(cells)
    grid = [["" for _ in range(cols)] for _ in range(rows)]
    for (r, c), (lines, _, _) in cells.items():
        if r < rows and c < cols:
            grid[r][c] = _cell_md(lines)
    # 비어 있는 열과 행은 버린다
    keep_c = [j for j in range(cols) if any(grid[i][j] for i in range(rows))] or list(range(cols))
    body = [[grid[i][j] for j in keep_c] for i in range(rows) if any(grid[i][j] for j in keep_c)]
    if not body:
        return []
    if len(keep_c) == 1:
        return [row[0] for row in body]
    lines = ["| " + " | ".join(body[0]) + " |", "|" + "---|" * len(keep_c)]
    lines += ["| " + " | ".join(r) + " |" for r in body[1:]]
    return lines


def _section_to_lines(buf):
    """레코드 트리를 따라가며 문단은 줄로, 표는 마크다운 표로 낸다.

    표 구조: CTRL_HEADER('tbl ', 레벨 L) 아래에 TABLE(L+1) 과 셀마다 LIST_HEADER(L+1) 가
    오고, 셀의 문단(PARA_HEADER)은 LIST_HEADER 와 같은 레벨 L+1 에 형제로 이어진다.
    """
    recs = list(_records(buf))

    def walk(i, done, sink):
        while i < len(recs) and not done(i):
            tag, level, data = recs[i]
            if tag == _TAG_PARA_TEXT:
                t = _para_text(data)
                if t.strip():
                    sink.append(t)
                i += 1
            elif tag == _TAG_CTRL_HEADER and data[:4][::-1] == b"tbl ":
                i = table(i, level, sink)
            else:
                i += 1
        return i

    def table(i, ctrl_level, sink):
        i += 1
        rows = cols = 0
        cells = {}
        caption = []
        seen_table = False
        lvl = ctrl_level + 1
        stop = lambda k: recs[k][1] < lvl or (recs[k][1] == lvl and recs[k][0] in (_TAG_LIST_HEADER, _TAG_TABLE))
        while i < len(recs) and recs[i][1] > ctrl_level:
            t2, l2, d2 = recs[i]
            if t2 == _TAG_TABLE and len(d2) >= 8:
                rows, cols = struct.unpack_from("<HH", d2, 4)
                seen_table = True
                i += 1
            elif t2 == _TAG_LIST_HEADER and l2 == lvl and not seen_table:
                # TABLE 레코드보다 먼저 나오는 LIST_HEADER 는 표 캡션이다
                i = walk(i + 1, stop, caption)
            elif t2 == _TAG_LIST_HEADER and l2 == lvl and len(d2) >= 12:
                # 셀 속성: 열 주소(8), 행 주소(10), 열 병합 수(12), 행 병합 수(14)
                col, row = struct.unpack_from("<HH", d2, 8)
                cs, rs = struct.unpack_from("<HH", d2, 12) if len(d2) >= 16 else (1, 1)
                cell_lines = []
                i = walk(i + 1, stop, cell_lines)
                prev = cells.get((row, col))
                if prev:
                    cell_lines = prev[0] + cell_lines
                cells[(row, col)] = (cell_lines, max(cs, 1), max(rs, 1))
            else:
                i += 1
        sink.extend(caption)
        sink.extend(_render_table(rows, cols, cells))
        sink.append("")
        return i

    out = []
    walk(0, lambda k: False, out)
    return out


def _hwp5_lines(data):
    cfb = _Cfb(data)
    if not cfb.exists("FileHeader"):
        raise HwpError("HWP 5.x 형식이 아니다(FileHeader 없음)")
    hdr = cfb.read("FileHeader")
    if not hdr.startswith(b"HWP Document File"):
        raise HwpError("HWP 5.x 형식이 아니다(서명 불일치)")
    flags = struct.unpack_from("<I", hdr, 36)[0]
    compressed, password, distribution = flags & 1, flags & 2, flags & 4
    if password:
        raise HwpError("암호가 걸린 문서다. 한글에서 암호를 풀고 다시 저장하거나 PDF 로 저장해 달라")
    if distribution or not cfb.exists("BodyText"):
        raise HwpError("배포용 문서라 본문이 암호화돼 있다. 한글에서 PDF 로 저장해 달라")
    secs = sorted((n for n in cfb.listdir("BodyText") if n.startswith("Section")),
                  key=lambda s: int(re.sub(r"\D", "", s) or 0))
    lines = []
    for s in secs:
        raw = cfb.read("BodyText/" + s)
        if compressed:
            try:
                raw = zlib.decompress(raw, -15)
            except zlib.error as ex:
                raise HwpError("본문 압축을 풀지 못했다(%s)" % ex)
        lines.extend(_section_to_lines(raw))
        lines.append("")
    return lines


# ---------------------------------------------------------------------------
# HWPX (OWPML, zip + xml)
# ---------------------------------------------------------------------------

def _local(tag):
    return tag.rsplit("}", 1)[-1]


def _hwpx_block(el, sink):
    for ch in el:
        name = _local(ch.tag)
        if name == "p":
            tables = [t for t in ch.iter() if _local(t.tag) == "tbl"]
            text = "".join(
                (t.text or "") + "".join((g.tail or "") for g in t)
                for r in ch if _local(r.tag) == "run"
                for t in r if _local(t.tag) == "t"
            )
            if text.strip():
                sink.append(text)
            # 문단 안에 든 표(직계 run 아래)만 처리한다. 더 깊은 표는 셀 처리에서 다룬다
            for r in ch:
                if _local(r.tag) != "run":
                    continue
                for t in r:
                    if _local(t.tag) == "tbl":
                        sink.extend(_hwpx_table(t))
                        sink.append("")
                    elif _local(t.tag) in ("rect", "ellipse", "container", "pic", "drawText", "ctrl"):
                        _hwpx_block(t, sink)
        elif name in ("subList", "drawText", "container", "rect",
                      "header", "footer", "footNote", "endNote"):
            _hwpx_block(ch, sink)


def _hwpx_table(tbl):
    rows = int(tbl.get("rowCnt", "0") or 0)
    cols = int(tbl.get("colCnt", "0") or 0)
    cells = {}
    caption = []
    for tr in tbl:
        if _local(tr.tag) == "caption":
            _hwpx_block(tr, caption)
        if _local(tr.tag) != "tr":
            continue
        for tc in tr:
            if _local(tc.tag) != "tc":
                continue
            addr = next((x for x in tc if _local(x.tag) == "cellAddr"), None)
            r = int(addr.get("rowAddr", 0)) if addr is not None else 0
            c = int(addr.get("colAddr", 0)) if addr is not None else 0
            span = next((x for x in tc if _local(x.tag) == "cellSpan"), None)
            cs = int(span.get("colSpan", 1)) if span is not None else 1
            rs = int(span.get("rowSpan", 1)) if span is not None else 1
            lines = []
            for sub in tc:
                if _local(sub.tag) == "subList":
                    _hwpx_block(sub, lines)
            cells[(r, c)] = (lines, max(cs, 1), max(rs, 1))
            rows, cols = max(rows, r + 1), max(cols, c + 1)
    return caption + _render_table(rows, cols, cells)


def _hwpx_lines(data):
    try:
        z = zipfile.ZipFile(io.BytesIO(data))
    except zipfile.BadZipFile:
        raise HwpError("HWPX 형식이 아니다(zip 이 아님)")
    names = z.namelist()
    if any(n.startswith("META-INF/") and "encryption" in n.lower() for n in names):
        raise HwpError("암호화된 HWPX 문서다. 한글에서 PDF 로 저장해 달라")
    secs = sorted((n for n in names if re.match(r"Contents/section\d+\.xml$", n)),
                  key=lambda s: int(re.sub(r"\D", "", s)))
    if not secs:
        raise HwpError("HWPX 본문(Contents/section*.xml)이 없다")
    lines = []
    for s in secs:
        root = ET.fromstring(z.read(s))
        _hwpx_block(root, lines)
        lines.append("")
    return lines


# ---------------------------------------------------------------------------
# 공통
# ---------------------------------------------------------------------------

def convert_bytes(data, name=""):
    low = name.lower()
    if data[:8] == _CFB_MAGIC or low.endswith(".hwp"):
        lines = _hwp5_lines(data)
    elif data[:2] == b"PK" or low.endswith(".hwpx"):
        lines = _hwpx_lines(data)
    else:
        raise HwpError("hwp 나 hwpx 가 아니다")
    text = "\n".join(_clean_keep_tabs(l) for l in lines)
    text = re.sub(r"\n{3,}", "\n\n", text).strip() + "\n"
    if len(re.sub(r"\s", "", text)) < 20:
        raise HwpError("본문 글자를 거의 찾지 못했다. 그림으로만 된 문서일 수 있다. PDF 로 저장해 달라")
    return text


def _clean_keep_tabs(l):
    if l.startswith("|"):
        return l
    return re.sub(r"[  ]+", " ", l).rstrip()


def read_bytes(path):
    # 클라우드 마운트에서는 경로로 여러 번 열면 잠김이 날 수 있어 한 번에 읽는다
    for attempt in range(2):
        try:
            with open(path, "rb") as f:
                return f.read()
        except OSError:
            if attempt:
                raise


def _front(src_name, kind):
    return ("---\n"
            "type: document\n"
            "derived_from: \"%s\"\n"
            "format: %s\n"
            "converted: %s\n"
            "converter: hwp2md %s\n"
            "---\n\n"
            "# " + src_name + " 변환본\n\n"
            "> 이 파일은 `%s` 의 글자를 뽑은 변환본이다. 칸을 합친 표는 HTML 표(rowspan, colspan)로 "
            "남겼다. 그림, 도형 배치, 서식은 빠지므로 쪽 모양이 필요하면 옆의 `%s.pages.pdf` 를 본다"
            "(없으면 원본을 한글에서 PDF 로 저장해 달라고 한다). 원본을 고치면 다시 변환한다.\n\n") % (
        src_name, kind, date.today().isoformat(), __version__, src_name, src_name)


# ---------------------------------------------------------------------------
# 페이지 그림 (선택). rhwp(https://github.com/edwardkim/rhwp, MIT) 로 쪽마다 그려
# <원본이름>.pages.pdf 한 파일로 묶는다. 글자는 위 변환기가, 배치는 이 그림이 맡는다.
# rhwp 가 없으면 pip 로 깐다. 어느 단계든 실패하면 글자 변환만 하고 넘어간다.
# ---------------------------------------------------------------------------

_MAX_PAGES = 80
_RENDER_CODE = r'''
import io, os, sys, rhwp
src, dst, scale, cap = sys.argv[1], sys.argv[2], float(sys.argv[3]), int(sys.argv[4])
d = rhwp.parse(src)
n = min(d.page_count, cap)
pngs = [d.render_png(i, scale=scale) for i in range(n)]
try:
    from PIL import Image
    ims = [Image.open(io.BytesIO(b)).convert("RGB") for b in pngs]
    ims[0].save(dst + ".pdf", save_all=True, append_images=ims[1:], resolution=72.0 * scale, quality=80)
    print("pdf %d %d" % (n, d.page_count))
except ImportError:
    os.makedirs(dst, exist_ok=True)
    for i, b in enumerate(pngs):
        with open(os.path.join(dst, "p%03d.png" % (i + 1)), "wb") as f:
            f.write(b)
    print("png %d %d" % (n, d.page_count))
'''
_rhwp_state = {}


def _render_env():
    env = dict(os.environ)
    if sys.platform.startswith("linux"):
        # rhwp-python 0.8.x 리눅스 휠에 든 freetype 이 낡아 FT_Palette_* 심볼이 없다.
        # 시스템 freetype(2.10 이상)을 먼저 올려 두면 그대로 돈다.
        for p in ("/lib/aarch64-linux-gnu/libfreetype.so.6", "/usr/lib/aarch64-linux-gnu/libfreetype.so.6",
                  "/lib/x86_64-linux-gnu/libfreetype.so.6", "/usr/lib/x86_64-linux-gnu/libfreetype.so.6",
                  "/usr/lib64/libfreetype.so.6", "/usr/lib/libfreetype.so.6"):
            if os.path.exists(p):
                env["LD_PRELOAD"] = (p + " " + env.get("LD_PRELOAD", "")).strip()
                break
    return env


def _run(cmd, timeout):
    import subprocess
    return subprocess.run(cmd, capture_output=True, text=True, timeout=timeout, env=_render_env())


def _pythons():
    import shutil
    seen = []
    for c in (sys.executable, "python3", "python3.13", "python3.12", "python3.11", "python3.10"):
        p = c if os.path.isabs(c) else shutil.which(c)
        if p and p not in seen:
            seen.append(p)
    return seen


def _find_rhwp(install):
    """rhwp 를 import 할 수 있는 파이썬 경로를 돌려준다. 없으면 (None, 이유)."""
    if "py" in _rhwp_state:
        return _rhwp_state["py"], _rhwp_state["why"]
    why = "rhwp 를 찾지 못했다"
    cands = []
    for py in _pythons():
        try:
            r = _run([py, "-c", "import sys; print(sys.version_info >= (3, 10)); import rhwp"], 60)
        except Exception as ex:
            continue
        if r.returncode == 0:
            _rhwp_state.update(py=py, why="")
            return py, ""
        if r.stdout.strip().startswith("True"):
            cands.append(py)
            if "No module named" not in r.stderr:
                why = "rhwp 를 불러오지 못했다: " + (r.stderr.strip().splitlines() or ["?"])[-1]
    if not cands:
        why = "파이썬 3.10 이상이 없어 rhwp 를 쓸 수 없다"
    elif install:
        py = cands[0]
        for extra in ([], ["--break-system-packages"]):
            try:
                r = _run([py, "-m", "pip", "install", "--user", "-q", "--disable-pip-version-check",
                          "rhwp-python"] + extra, 240)
            except Exception as ex:
                why = "rhwp 설치 실패: %s" % ex
                break
            if r.returncode == 0:
                chk = _run([py, "-c", "import rhwp"], 60)
                if chk.returncode == 0:
                    _rhwp_state.update(py=py, why="")
                    return py, ""
                why = "rhwp 를 깔았지만 불러오지 못했다: " + (chk.stderr.strip().splitlines() or ["?"])[-1]
                break
            why = "rhwp 설치 실패(네트워크 차단일 수 있다): " + (r.stderr.strip().splitlines() or ["?"])[-1]
            if "externally-managed" not in r.stderr:
                break
    _rhwp_state.update(py=None, why=why)
    return None, why


def render_pages(src, dst_base, install=True, scale=1.5):
    """쪽 그림을 dst_base + '.pdf' (PIL 이 없으면 dst_base/ 아래 PNG) 로 쓴다.
    돌려주는 값: (성공 여부, 사람에게 보일 한 줄)."""
    py, why = _find_rhwp(install)
    if not py:
        return False, why
    try:
        r = _run([py, "-c", _RENDER_CODE, src, dst_base, str(scale), str(_MAX_PAGES)], 600)
    except Exception as ex:
        return False, "쪽 그림 실패: %s" % ex
    if r.returncode != 0:
        return False, "쪽 그림 실패: " + (r.stderr.strip().splitlines() or ["?"])[-1]
    kind, n, total = r.stdout.split()[:3]
    out = dst_base + ".pdf" if kind == "pdf" else dst_base + "/"
    note = "" if n == total else " (앞 %s쪽만, 전체 %s쪽)" % (n, total)
    return True, "%s\t%s쪽%s" % (out, n, note)


def _targets(paths):
    for p in paths:
        if os.path.isdir(p):
            for root, dirs, files in os.walk(p):
                dirs[:] = [d for d in dirs if not d.startswith((".", "_"))]
                for f in sorted(files):
                    if unicodedata.normalize("NFC", f).lower().endswith((".hwp", ".hwpx")):
                        yield os.path.join(root, f)
        else:
            yield p


def main(argv):
    to_stdout, out_dir, paths = False, None, []
    pages, install = True, True
    it = iter(argv)
    for a in it:
        if a == "--stdout":
            to_stdout = True
        elif a == "--no-pages":
            pages = False
        elif a == "--no-install":
            install = False
        elif a == "--out-dir":
            out_dir = next(it)
        elif a in ("-h", "--help"):
            print(__doc__)
            return 0
        else:
            paths.append(a)
    if not paths:
        print(__doc__)
        return 2
    ok = fail = 0
    for src in _targets(paths):
        name = os.path.basename(src)
        dst_dir = out_dir or os.path.dirname(src)
        text_ok = False
        try:
            text = convert_bytes(read_bytes(src), name)
            text_ok = True
        except (HwpError, struct.error, ET.ParseError, IndexError, ValueError, OSError) as ex:
            print("실패\t%s\t%s" % (src, ex), file=sys.stderr)
        if text_ok:
            kind = "hwpx" if name.lower().endswith(".hwpx") else "hwp"
            body = _front(name, kind) + text
            if to_stdout:
                sys.stdout.write(body)
            else:
                dst = os.path.join(dst_dir, name + ".md")
                with open(dst, "w", encoding="utf-8") as f:
                    f.write(body)
                print("변환\t%s\t%s\t%d자" % (src, dst, len(text)))
        pages_ok = False
        if pages and not to_stdout:
            pages_ok, msg = render_pages(src, os.path.join(dst_dir, name + ".pages"), install)
            print(("쪽그림\t%s\t%s" if pages_ok else "쪽그림생략\t%s\t%s") % (src, msg),
                  file=sys.stdout if pages_ok else sys.stderr)
        if text_ok or pages_ok:
            ok += 1
        else:
            fail += 1
    print("완료\t성공 %d\t실패 %d" % (ok, fail), file=sys.stderr)
    return 1 if fail else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
