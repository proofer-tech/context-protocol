#!/usr/bin/env bash
# context-protocol site build: src/ -> dist/
set -euo pipefail
cd "$(dirname "$0")"
rm -rf dist && mkdir -p dist/fonts
cp src/index.html src/llms.txt src/robots.txt src/sitemap.xml src/icon.svg src/proofer-wordmark-dark-bg.png src/proofer-mark.png dist/
cp -r src/img dist/img
cp -r src/logos dist/logos
cat src/ds/tokens.css src/ds/bundle-core.css src/style.css > dist/style.css

# motion.js
npx esbuild src/motion.ts --bundle --minify --format=iife --target=es2019 --outfile=dist/motion.js --log-level=warning

# fonts: subset to the glyphs this page uses
python3 - <<'PY'
import re, html, subprocess, pathlib
src = pathlib.Path("src/index.html").read_text() + pathlib.Path("src/motion.ts").read_text() + pathlib.Path("src/og.html").read_text()
text = html.unescape(re.sub(r"<[^>]+>", " ", src))
chars = set(text) | set("0123456789.,-_/:;!?()[]<>#@&+=%'\"*`~^|\\ ")
chars |= set(chr(c) for c in range(0x20, 0x7f))
pathlib.Path("/tmp/cp-chars.txt").write_text("".join(sorted(chars)))
PY
for w in Rg Bd; do
  pyftsubset src/fonts-src/LINESeedKR-$w.woff2 --text-file=/tmp/cp-chars.txt --flavor=woff2 \
    --layout-features='*' --output-file=dist/fonts/lineseed-$(echo $w | tr A-Z a-z).woff2
done

# cache busting: Pages serves max-age=600, so a new index.html can meet an old css/js/font.
# append a content hash to each reference.
python3 - <<'PY'
import hashlib, pathlib, re
d = pathlib.Path("dist")
h = lambda p: hashlib.sha256((d / p).read_bytes()).hexdigest()[:10]
css = (d / "style.css").read_text()
for f in ("fonts/lineseed-rg.woff2", "fonts/lineseed-bd.woff2"):
    css = re.sub(re.escape(f) + r'(\?v=[0-9a-f]+)?', f + "?v=" + h(f), css)
(d / "style.css").write_text(css)
idx = (d / "index.html").read_text()
for f in ("style.css", "motion.js"):
    idx = idx.replace(f'"{f}"', f'"{f}?v={h(f)}"')
(d / "index.html").write_text(idx)
PY

# icons + og.png
cp src/og.html dist/og.html
python3 shots.py icons-og
rm dist/og.html
python3 - <<'PY'
import hashlib, pathlib
d = pathlib.Path("dist")
v = hashlib.sha256((d / "og.png").read_bytes()).hexdigest()[:10]
idx = (d / "index.html").read_text().replace('og.png"', f'og.png?v={v}"')
(d / "index.html").write_text(idx)
PY
ls -la dist dist/fonts
