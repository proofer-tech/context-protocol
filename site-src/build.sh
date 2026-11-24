#!/usr/bin/env bash
# context-protocol site build: src/ -> dist/
set -euo pipefail
cd "$(dirname "$0")"
rm -rf dist && mkdir -p dist/fonts
cp src/index.html src/llms.txt src/icon.svg src/proofer-wordmark-dark-bg.png src/proofer-mark.png dist/
cp -r src/img dist/img
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

# icons + og.png
cp src/og.html dist/og.html
python3 shots.py icons-og
rm dist/og.html
ls -la dist dist/fonts
