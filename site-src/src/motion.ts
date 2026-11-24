import { gsap } from "gsap";
import { ScrollTrigger } from "gsap/ScrollTrigger";
import { SplitText } from "gsap/SplitText";
import { DrawSVGPlugin } from "gsap/DrawSVGPlugin";

gsap.registerPlugin(ScrollTrigger, SplitText, DrawSVGPlugin);

const $ = <T extends Element = HTMLElement>(s: string, r: ParentNode = document) => r.querySelector(s) as T | null;
const $$ = <T extends Element = HTMLElement>(s: string, r: ParentNode = document) => Array.from(r.querySelectorAll(s)) as T[];

/* nav: hairline once scrolled */
const nav = $(".nav");
const onScroll = () => nav && nav.classList.toggle("scrolled", window.scrollY > 8);
addEventListener("scroll", onScroll, { passive: true });
onScroll();

/* E e3: section counter + current link */
const secs = $$("[data-sec]");
const counter = $("[data-counter]");
const total = $("[data-total]");
if (total) total.textContent = String(secs.length).padStart(2, "0");
const links = $$<HTMLAnchorElement>(".links a");
const io = new IntersectionObserver(
  (entries) => {
    for (const e of entries) {
      if (!e.isIntersecting) continue;
      const i = secs.indexOf(e.target as HTMLElement);
      if (counter) counter.textContent = String(i + 1).padStart(2, "0");
      const id = (e.target as HTMLElement).id;
      links.forEach((a) => a.classList.toggle("on", !!id && a.getAttribute("href") === "#" + id));
    }
  },
  { rootMargin: "-45% 0px -54% 0px" }
);
secs.forEach((s) => io.observe(s));

/* copy buttons */
$$<HTMLButtonElement>(".copy").forEach((b) => {
  b.addEventListener("click", () => {
    const t = document.getElementById(b.dataset.copy || "")?.textContent || "";
    navigator.clipboard?.writeText(t).then(() => {
      const o = b.textContent;
      b.textContent = "복사됨";
      setTimeout(() => (b.textContent = o), 1400);
    }, () => {});
  });
});

/* latest release tag */
fetch("https://api.github.com/repos/proofer-tech/context-protocol/releases/latest")
  .then((r) => (r.ok ? r.json() : null))
  .then((j) => {
    const v = j && typeof j.tag_name === "string" ? j.tag_name.replace(/^v/, "") : null;
    const el = $("[data-ver]");
    if (v && el && /^[\w.\-]{1,20}$/.test(v)) el.textContent = v;
  })
  .catch(() => {});

/* hub state (shared by motion and no-motion paths) */
const NAMES = ["Claude Cowork", "Claude Code", "Codex", "Cursor", "Antigravity", "Grok Build"];
const spokes = $$<SVGPathElement>("[data-spoke]");
const pulses = $$<SVGPathElement>("[data-pulse]");
const chips = $$("[data-chip]");
const attached = $("[data-attached]");
let active = -1;
let pulseTween: gsap.core.Tween | null = null;
function attach(i: number, animate: boolean) {
  if (i === active) return;
  active = i;
  spokes.forEach((p, k) => p.classList.toggle("on", k === i));
  chips.forEach((c, k) => c.classList.toggle("on", k === i));
  if (attached) attached.textContent = NAMES[i];
  const lab = $("[data-attached-label]");
  if (lab) lab.textContent = "지금 붙은 머리";
  pulses.forEach((p) => gsap.set(p, { opacity: 0 }));
  pulseTween?.kill();
  const p = pulses[i];
  if (!p || !animate) return;
  gsap.set(p, { opacity: 1 });
  pulseTween = gsap.fromTo(p, { drawSVG: "0% 0%" }, {
    keyframes: [
      { drawSVG: "0% 22%", duration: 0.25, ease: "power2.in" },
      { drawSVG: "78% 100%", duration: 0.5, ease: "none" },
      { drawSVG: "100% 100%", duration: 0.25, ease: "power2.out" },
    ],
  });
}

const mm = gsap.matchMedia();

mm.add(
  {
    motion: "(prefers-reduced-motion: no-preference)",
    fine: "(hover: hover) and (min-width: 768px)",
  },
  (ctx) => {
    const { motion, fine } = ctx.conditions as { motion: boolean; fine: boolean };
    if (!motion) return;

    const fontsReady = Promise.race([
      (document as any).fonts?.ready ?? Promise.resolve(),
      new Promise((r) => setTimeout(r, 1200)),
    ]);

    /* A a1: hero lines rise out of a mask after fonts settle */
    const heroH = $(".hero-sec h1");
    const heroRest = $$(".hero-sec .eyebrow, .hero-side p, .hero-sec .cta-row, .facts > div");
    gsap.set([heroH, ...heroRest], { autoAlpha: 0 });
    fontsReady.then(() => {
      if (!heroH) return;
      const split = SplitText.create(heroH, { type: "lines", mask: "lines", linesClass: "split-line" });
      const tl = gsap.timeline();
      tl.set(heroH, { autoAlpha: 1 })
        .from(split.lines, { yPercent: 105, duration: 1, ease: "expo.out", stagger: 0.12 })
        .fromTo(heroRest, { autoAlpha: 0, y: 14 }, { autoAlpha: 1, y: 0, duration: 0.7, ease: "power3.out", stagger: 0.06 }, 0.25);
    });

    /* B b2: hairline draws, then heading lines rise */
    const ruled = $$(".docs, .rows");
    ruled.forEach((el) => {
      const cs = getComputedStyle(el);
      const draw = document.createElement("i");
      draw.setAttribute("aria-hidden", "true");
      Object.assign(draw.style, {
        position: "absolute", left: "0", right: "0", top: "-1px", height: cs.borderTopWidth,
        background: cs.borderTopColor, transformOrigin: "left", pointerEvents: "none",
      });
      if (cs.position === "static") el.style.position = "relative";
      el.style.borderTopColor = "transparent";
      el.prepend(draw);
      gsap.from(draw, { scaleX: 0, duration: 1.1, ease: "power4.inOut", scrollTrigger: { trigger: el, start: "top 88%" } });
    });

    fontsReady.then(() => {
      $$("[data-m='lines']").forEach((h) => {
        if (h.closest(".hero-sec")) return;
        const split = SplitText.create(h, { type: "lines", mask: "lines", linesClass: "split-line" });
        gsap.from(split.lines, {
          yPercent: 105, duration: 0.9, ease: "expo.out", stagger: 0.1,
          scrollTrigger: { trigger: h, start: "top 85%" },
        });
      });
      ScrollTrigger.refresh();
    });

    $$(".head2 .lede, .head2 .cmd, .center-head .lede, .heads-copy p, .compare, .tree-wrap, .lint, .cmd").forEach((el) => {
      gsap.from(el, { y: 16, opacity: 0, duration: 0.8, ease: "power3.out", scrollTrigger: { trigger: el, start: "top 90%" } });
    });

    [".finds li", ".steps li", ".cards .card", ".cells .card", ".rows li", ".docs li", ".lic > div", ".faq details"].forEach((sel) => {
      const items = $$(sel.startsWith(".") ? sel : "." + sel);
      if (!items.length) return;
      gsap.from(items, {
        y: 20, opacity: 0, duration: 0.7, ease: "power3.out", stagger: 0.07,
        scrollTrigger: { trigger: items[0].parentElement, start: "top 85%" },
      });
    });

    /* card glyphs draw on enter */
    $$(".glyph").forEach((g) => {
      const parts = $$<SVGGeometryElement>("path, circle", g);
      gsap.from(parts, {
        drawSVG: "0%", duration: 1.2, ease: "power2.inOut", stagger: 0.05,
        scrollTrigger: { trigger: g, start: "top 85%" },
      });
    });

    /* fact numbers count from 0 (values are the real counts) */
    $$("[data-count]").forEach((el) => {
      const to = Number(el.dataset.count);
      const o = { v: 0 };
      fontsReady.then(() =>
        gsap.to(o, {
          v: to, duration: 1.1, ease: "power2.out", delay: 0.5,
          onUpdate: () => (el.textContent = String(Math.round(o.v))),
        })
      );
    });

    /* signature: heads attach to one body.
       spokes draw in as the panel enters, then scroll swaps which head is attached */
    const hub = $("#heads");
    if (hub) {
      gsap.set(spokes, { drawSVG: "0%" });
      gsap.set(chips, { opacity: 0, scale: 0.92 });
      const ring = $(".hub .ring");
      const draw = gsap.timeline({ scrollTrigger: { trigger: ".hub", start: "top 80%", end: "top 30%", scrub: 0.6 } });
      draw.to(chips, { opacity: 1, scale: 1, duration: 0.3, stagger: 0.06, ease: "power2.out" }, 0)
        .to(spokes, { drawSVG: "100%", duration: 0.6, stagger: 0.07, ease: "none" }, 0.1);
      if (ring) gsap.to(ring, { rotation: 120, svgOrigin: "320 280", ease: "none", scrollTrigger: { trigger: hub, start: "top bottom", end: "bottom top", scrub: 1 } });

      let hovering = false;
      ScrollTrigger.create({
        trigger: hub, start: "top 30%", end: "bottom 50%",
        onUpdate: (st) => {
          if (hovering) return;
          attach(Math.min(5, Math.floor(st.progress * 6)), true);
        },
        onEnter: () => attach(active < 0 ? 0 : active, true),
      });
      if (fine) {
        chips.forEach((c, i) => {
          const enter = () => { hovering = true; attach(i, true); };
          const leave = () => { hovering = false; };
          c.addEventListener("pointerenter", enter);
          c.addEventListener("pointerleave", leave);
        });
      }
    }

    return () => {
      SplitText.getAll?.().forEach((s: any) => s.revert());
    };
  }
);
