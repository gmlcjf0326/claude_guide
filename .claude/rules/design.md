---
paths:
  - "**/*.tsx"
  - "**/*.jsx"
  - "**/*.css"
  - "**/*.scss"
  - "**/tailwind.config.*"
  - "**/*.vue"
  - "**/*.svelte"
---

# UI & Design Rules
> 🇰🇷 UI 코드 작업 시 자동 적용. 심화: guides/12-design-system.md.

## Tokens before pixels
- Every color, spacing, radius, and font size comes from the token layer (CSS custom properties / Tailwind theme / theme package). A hardcoded hex or magic px in a component is a violation — add or use a token.
- Spacing on a 4px grid (4·8·12·16·24·32·48·64). One type scale: ~5 sizes + 2 weights, defined once.
- Colors are **semantic** (`--color-bg`, `--color-surface`, `--color-text-muted`, `--color-danger`) mapped to a palette. Dark mode = remapping semantic tokens, never per-component overrides.

## One component system, wrapped
- Pick ONE component system and route it through your own `src/ui/` wrapper layer; never mix two libraries. Default recommendation: **Astryx** (Meta's open-source, agent-ready system — 150+ accessible components, theming via CSS custom properties, no styling lock-in; beta, so pin versions) or **shadcn/ui** when you want full source ownership. Decision guidance: guides/12-design-system.md.
- With Astryx: **never write component code from training memory** — it is beta and changes weekly. Knowledge ladder (research skill): its CLI (`npm run astryx -- component --list` / `component <Name>`) → installed types in `node_modules/@astryxdesign/*` → repo docs via web. Customize via theme tokens first, `className` second, swizzle (eject) last.

## Non-negotiable states & accessibility
- Every interactive element ships all states: hover, focus-visible, active, disabled, loading. Focus rings are never removed without an equal-or-better replacement.
- Contrast ≥ 4.5:1 for body text (WCAG AA). Touch targets ≥ 44×44pt (Apple HIG) / 48dp (Material). Every input has a label; every meaningful image has alt text.
- **Empty, loading, and error states are part of every screen's Definition of Done** — a screen without them is unfinished, not minimal.

## Motion & feel
- Micro-interactions 150–250ms; ease-out on enter, ease-in on exit; respect `prefers-reduced-motion`.
- Platform conventions win on mobile: iOS follows Apple HIG patterns, Android follows Material — a great web layout transplanted verbatim feels wrong on both.

## Anti-slop
- One accent color, used sparingly. Real copy over lorem ipsum. Generous whitespace over boxes-in-boxes. If a screen looks like a generic template, the fix is usually: fewer elements, stronger hierarchy, real content.

## Assets — real icons, real fonts, real images (free, production-grade)
- **Icons**: never use emoji as UI icons, and never hand-draw ad-hoc inline SVG blobs. Install a real icon set and use it consistently: React → `lucide-react` (or `@tabler/icons-react`); non-React → Tabler webfont/SVG. One set per project; sizes from the token scale (16/20/24).
- **Fonts**: never ship default system font for a branded UI unless explicitly chosen. Korean or KR+EN products → **Pretendard Variable** (CDN link in guide 12); Latin-only → Inter or equivalent. Define the stack ONCE in tokens (`--font-sans`) with proper fallbacks; load via `<link>` or package, subset when possible.
- **Images**: prototypes → `https://picsum.photos/<w>/<h>` placeholders; production → curated free photos (Unsplash/Pexels licenses allow commercial use) **downloaded into `public/`**, never hotlinked (note: source.unsplash.com is discontinued — don't generate those URLs). Illustrations → unDraw (recolorable to brand). Every third-party asset gets a line in `public/CREDITS.md`.
- These are review-blocking for user-facing diffs: emoji-as-icon, unloaded/default fonts on branded UI, dead image hotlinks.

## Style files, not inline styles (효율 원칙 — review-blocking)
- **No static `style=` attributes on individual tags.** They can't be cached or reused, carry maximal specificity, kill theming, and bloat HTML. Honest exceptions (the ONLY three): JS-computed dynamic values (`translateX(${x}px)`), CSS-variable injection only (`style={{'--i': i}}` with real styling in the sheet), truly per-instance runtime values.
- File separation standard: `tokens.css → base.css → components.css → utilities.css` under `@layer reset, tokens, base, components, utilities, overrides` (layers end specificity wars — no `!important`). React: CSS Modules or Tailwind v4 `@theme`; either way tokens are the single source.
- No magic values (every color/size via token) · no `!important` · selector nesting ≤ 3.

## Korean public-sector (공공기관) work
- Hard gates (KWCAG 2.2 = WCAG AA): body text **4.5:1**, large text/UI **3:1**; never signal by color alone; focus ring always visible.
- **Magic-number rule**: token grade difference ≥50 ⇒ 4.5:1, ≥40 ⇒ 3:1 — pick pairs by arithmetic before any checker.
- Typography: Pretendard GOV Variable · body 17px · line-height 150% · letter-spacing 0 · `word-break: keep-all` · weights 400/700 only. Primary `#256EF4` on actions only.
- Start from `templates/design/` (tokens-krds.css · base · components · tailwind bridge · demo). Deep dive + per-client playbook: `guides/16-public-sector-design.md`.
