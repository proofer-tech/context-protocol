#!/usr/bin/env bash
# context-protocol 배포 패키지 빌드
#
# 사용법: scripts/build.sh [빌드번호]
#   빌드번호를 주지 않으면 context-protocol-<버전>.zip
#   빌드번호 N 을 주면   context-protocol-<버전>-bN.zip
#
# 결과물은 dist/ 아래에 생긴다. dist/ 는 git 에 올리지 않는다.
# 배포는 GitHub Release 로만 한다 (docs/릴리스.md).
#
# 클라우드 동기화 폴더나 Cowork 마운트 위에서 돌리지 않는다. 스테이징을 지우지 못한다.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

BUILD_NO="${1:-}"
CP="_context-protocol"
SETUP="$CP/installers/CONTEXT_SETUP.md"
MIGRATE="$CP/installers/CONTEXT_MIGRATE.md"
GUIDE="$CP/CONTEXT_GUIDE.md"
PKG_README="package/README.md"

fail() { echo "빌드 중단: $*" >&2; exit 1; }

# 1. 버전은 MIGRATE 의 LATEST_VERSION 이다. 임의로 정하지 않는다.
VERSION="$(sed -n 's/^- LATEST_VERSION: \*\*\([0-9.]*\)\*\*.*/\1/p' "$MIGRATE" | head -1)"
[ -n "$VERSION" ] || fail "$MIGRATE 에서 LATEST_VERSION 을 찾지 못했다"

NAME="context-protocol-$VERSION"
[ -n "$BUILD_NO" ] && NAME="$NAME-b$BUILD_NO"
echo "버전 $VERSION, 패키지 $NAME"

# 2. 스탬프 대조. 설치기 두 개와 가이드의 Guide version 이 LATEST_VERSION 과 같아야 한다.
for f in "$SETUP" "$MIGRATE" "$GUIDE"; do
  stamp="$(grep -m1 -o 'Guide version: [0-9.]*' "$f" | awk '{print $3}')"
  [ "$stamp" = "$VERSION" ] || fail "$f 의 Guide version($stamp) 이 $VERSION 과 다르다"
done

# 3. 패키지 README 의 버전 표기
grep -q "^- 버전: $VERSION\$" "$PKG_README" || fail "$PKG_README 의 '- 버전:' 줄이 $VERSION 이 아니다"
grep -m1 "^# " "$PKG_README" | grep -q "context-protocol $VERSION " || fail "$PKG_README 제목의 버전이 $VERSION 이 아니다"

# 4. 설치기 블록과 정본 대조
python3 - "$ROOT" <<'PY'
import re, sys, pathlib
root = pathlib.Path(sys.argv[1])
cp = root / "_context-protocol"
pairs = {
    "guide_content": "CONTEXT_GUIDE.md",
    "ontology_readme": "_ontology.md",
    "ontology_schema_md": "_schema/concept-scheme.md",
    "ontology_index_view": "_views/index-moc.md",
    "ontology_lint_view": "_views/integrity-lint.md",
    "ontology_base": "_concepts.base",
}
def strip_fm(t):
    if t.startswith("---\n"):
        i = t.find("\n---\n", 4)
        if i > 0:
            return t[i + 5:]
    return t
bad = 0
for inst in ("CONTEXT_SETUP.md", "CONTEXT_MIGRATE.md"):
    s = (cp / "installers" / inst).read_text(encoding="utf-8")
    for tag, rel in pairs.items():
        m = re.search(r"^<%s>\n(.*?)^</%s>" % (tag, tag), s, re.S | re.M)
        if not m:
            print(f"  {inst} <{tag}> 블록 없음"); bad += 1; continue
        b = m.group(1).strip()
        c = (cp / rel).read_text(encoding="utf-8")
        if not (strip_fm(c).strip() in b or c.strip() in b):
            print(f"  {inst} <{tag}> 가 {rel} 와 다르다"); bad += 1
if bad:
    sys.exit("블록 대조 실패")
print("블록 대조 일치")
PY

# 5. 스테이징
OUT="$ROOT/dist"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
STAGE="$WORK/stage/$NAME"
mkdir -p "$STAGE/tools" "$OUT"
cp "$PKG_README" "$STAGE/README.md"
cp "$SETUP" "$MIGRATE" "$STAGE/"
cp "$CP"/tools/*.py "$STAGE/tools/"
cp LICENSE "$STAGE/LICENSE"
cp -R LICENSES "$STAGE/LICENSES"
cp -R presets "$STAGE/presets"
find "$STAGE" \( -name .DS_Store -o -name '._*' \) -delete

# 6. MANIFEST. 손으로 적지 않고 계산한다.
python3 - "$STAGE" "$VERSION" "${BUILD_NO:--}" <<'PY'
import hashlib, sys, pathlib, datetime
stage, version, build = pathlib.Path(sys.argv[1]), sys.argv[2], sys.argv[3]
files = sorted(p for p in stage.rglob("*") if p.is_file())
rows = []
for p in files:
    data = p.read_bytes()
    rows.append((p.relative_to(stage).as_posix(), len(data), hashlib.sha256(data).hexdigest()[:16]))
today = datetime.date.today().isoformat()
lines = [
    "---", "type: document", f"title: context-protocol {version} package manifest", "---", "",
    "# MANIFEST", "",
    f"- 버전: {version}", f"- 빌드: {'b' + build if build != '-' else '-'}",
    f"- 빌드 날짜: {today}", f"- 파일 수: {len(rows) + 1}", "",
    "| 파일 | 바이트 | sha256 (앞 16) |", "|---|---|---|",
]
lines += [f"| `{r}` | {n} | {h} |" for r, n, h in rows]
(stage / "MANIFEST.md").write_text("\n".join(lines) + "\n", encoding="utf-8")
PY

# 7. 압축 (-X 로 확장 속성 제외)
ZIP="$OUT/$NAME.zip"
rm -f "$ZIP"
(cd "$WORK/stage" && zip -qr -X "$ZIP" "$NAME")

# 8. 검증. 다른 곳에 풀어서 스테이징과 diff -r
mkdir -p "$WORK/verify"
(cd "$WORK/verify" && unzip -q "$ZIP")
diff -r "$STAGE" "$WORK/verify/$NAME" || fail "압축 해제 결과가 스테이징과 다르다"

COUNT="$(find "$STAGE" -type f | wc -l | tr -d ' ')"
BYTES="$(wc -c < "$ZIP" | tr -d ' ')"
SHA="$(sha256sum "$ZIP" 2>/dev/null | awk '{print $1}' || shasum -a 256 "$ZIP" | awk '{print $1}')"
echo "완료: $ZIP"
echo "파일 $COUNT 개, $BYTES 바이트, sha256 $SHA"
