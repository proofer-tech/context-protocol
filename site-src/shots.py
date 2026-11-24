import asyncio, sys, http.server, threading, functools, os
from playwright.async_api import async_playwright

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "dist")
PORT = 8765

def serve():
    h = functools.partial(http.server.SimpleHTTPRequestHandler, directory=ROOT)
    h.log_message = lambda *a: None
    s = http.server.ThreadingHTTPServer(("127.0.0.1", PORT), h)
    threading.Thread(target=s.serve_forever, daemon=True).start()
    return s

async def icons_og(b):
    pg = await b.new_page(viewport={"width": 1200, "height": 630})
    await pg.goto(f"http://127.0.0.1:{PORT}/og.html")
    await pg.evaluate("document.fonts.ready")
    await pg.wait_for_timeout(300)
    await pg.screenshot(path=f"{ROOT}/og.png")
    svg = open(f"{ROOT}/icon.svg").read()
    for size, name, pad in [(32, "icon-32.png", 0), (180, "apple-touch-icon.png", 0.12)]:
        p = await b.new_page(viewport={"width": size, "height": size})
        inner = int(size * (1 - 2 * pad))
        bg = "#231f20" if pad else "transparent"
        await p.set_content(f'<html><body style="margin:0;background:{bg};display:grid;place-items:center;width:{size}px;height:{size}px"><div style="width:{inner}px;height:{inner}px">{svg.replace("<svg ", f"<svg width=\"{inner}\" height=\"{inner}\" ")}</div></body></html>')
        await p.screenshot(path=f"{ROOT}/{name}", omit_background=not pad)

async def main(mode):
    serve()
    async with async_playwright() as p:
        b = await p.chromium.launch(executable_path="/usr/bin/google-chrome")
        if mode == "icons-og":
            await icons_og(b)
        await b.close()

if __name__ == "__main__":
    asyncio.run(main(sys.argv[1]))
