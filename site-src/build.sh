#!/usr/bin/env bash
# context-protocol site build: src/ -> dist/
set -euo pipefail
cd "$(dirname "$0")"
rm -rf dist && mkdir -p dist/fonts
cp src/index.html src/style.css src/llms.txt src/icon.svg dist/

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
pyftsubset node_modules/wanted-sans/fonts/webfonts/variable/complete/woff2/WantedSansVariable.woff2 \
  --text-file=/tmp/cp-chars.txt --flavor=woff2 --layout-features='*' --output-file=dist/fonts/wanted.woff2
pyftsubset node_modules/d2coding/src/d2coding.ttf \
  --text-file=/tmp/cp-chars.txt --flavor=woff2 --layout-features='*' --output-file=dist/fonts/d2coding.woff2

# icons + og.png
cp src/og.html dist/og.html
python3 shots.py icons-og
rm dist/og.html
ls -la dist dist/fonts
