# 12 — Design Systems: Professional UI Without a Designer
> 🇰🇷 디자이너 없이도 '만든 사람이 있는 것 같은' UI를 내는 법 — 토큰 아키텍처, 컴포넌트 시스템 선택(Meta Astryx 포함), 그리고 에이전트가 디자인을 지키게 만드는 장치.

The enforced rules live in `.claude/rules/design.md` (auto-loads on UI files). This guide is the reasoning and the setup.

## 1. Why a solo dev needs a design *system*, not design *talent*

Users can't articulate why an app feels trustworthy, but the ingredients are measurable: consistent spacing, a disciplined type scale, coherent color, complete interaction states. A design system turns those from per-screen judgment calls into defaults — which matters double with agents: **an agent constrained by tokens and one component library produces consistent UI by construction; an unconstrained agent reinvents slightly-different buttons forever.** The system is not decoration; it is the thing that makes 50 agent-built screens look like one product.
> 🇰🇷 시스템의 본질: 에이전트가 화면 50개를 만들어도 '한 제품'처럼 보이게 만드는 제약 장치.

## 2. Choosing the component system (COMPASS options format)

| Option | Profile | Regret scenario |
|---|---|---|
| **A — Astryx** (Meta, open-source) | 효과↑: 150+ accessible components, 7 themes, dark mode, templates, CLI; grew inside Meta for 8 years powering 13,000+ apps; explicitly **agent-ready** (API/docs/CLI designed for humans and AI together; the repo ships its own CLAUDE.md). Theming = CSS custom property overrides; styles authored in StyleX but consumers can override with Tailwind/CSS — no lock-in; `swizzle` ejects any component's source when you need to own it. | It's **beta** (v0.1.x, 2026): APIs may shift — pin versions, read changelogs before upgrading. React-only. |
| **B — shadcn/ui** | 효율·소유권형: components are copied *into* your repo — full ownership, Tailwind-native, huge community. | You now maintain that code; accessibility and upgrades are your job; quality varies with your discipline. |
| **C — Radix primitives + your own styling** | Maximum control, minimum opinion. | You are building a design system as a side quest; weeks disappear. |
| **D — Full framework (MUI etc.)** | Everything included. | The "MUI look" is hard to escape; heavy; fighting the theme layer becomes the job. |

**Recommendation:** for React apps where polish-per-hour matters (the typical COMPASS solo-dev profile), **A (Astryx)** — the agent-ready design is a direct fit for COMPASS workflows, and the no-lock-in escape hatches (className overrides, swizzle) cap the beta risk. Choose **B** when full source ownership is a hard requirement. Record the choice in `docs/DECISIONS.md` with the beta caveat as the revisit trigger.

### Astryx working agreement (for the agent)
1. Install `@astryxdesign/core` + one theme (`@astryxdesign/theme-neutral` to start) + `@astryxdesign/cli` (dev). Add the package.json script so the CLI is reliably invokable: `"astryx": "node node_modules/@astryxdesign/cli/bin/astryx.mjs"`.
2. **Before building any screen**: check what exists — `npm run astryx -- component --list`, then `component <Name>` for props/examples. Never guess an API that is one CLI call away.
3. Customization ladder, in order: theme tokens → `className` overrides → composition of exported building blocks → `swizzle` (eject) as the last resort. Each rung is cheaper to maintain than the next.
4. Wrap everything in `src/ui/` re-exports so the app imports from `@/ui`, never from the library directly — this keeps a future migration to option B a mechanical find-replace.

## 3. Token architecture — the three tiers

```css
/* 1. Primitives — raw values, no meaning. Never used directly in components. */
--blue-600: #2563eb;  --gray-50: #f9fafb;  --space-4: 16px;

/* 2. Semantic — meaning, mapped to primitives. THIS is what components consume. */
--color-primary: var(--blue-600);
--color-bg: var(--gray-50);
--color-text-muted: var(--gray-500);

/* 3. Component (only when needed) — exceptions made explicit. */
--button-radius: var(--radius-md);
```

Dark mode is a remap of tier 2 (`[data-theme="dark"] { --color-bg: var(--gray-900); … }`) — components never know which mode they're in. This is also exactly how Astryx theming works (a theme *is* a set of custom-property overrides), so the mental model transfers.

Scales worth adopting verbatim: spacing `4 8 12 16 24 32 48 64`; type `13 15 17 22 28` (+ two weights, 400/600); radii `4 8 12 999`. Boring numbers, applied everywhere, beat inspired numbers applied sometimes.

## 4. The anti-slop principles

AI-built UI has a recognizable failure smell: five grays, three blues, boxes inside boxes, every element the same visual weight, lorem ipsum. The antidotes are restraint rules, not talent:

1. **One accent color.** Everything else is neutral. If two things compete for attention, demote one.
2. **Hierarchy through size and weight, not decoration.** A screen should be scannable squinting: one obvious primary action per view.
3. **Whitespace is a feature.** When a layout feels off, remove elements before adding dividers.
4. **Real content from day one.** Layouts tuned to lorem ipsum break on real Korean/English strings, long emails, and empty lists — design with the ugly real data.
5. **The three orphan states** — empty, loading, error — are designed, not defaulted. This is in the DoD for a reason: they're where products feel abandoned or cared-for.
6. **Platform grammar on mobile**: navigation, back behavior, sheets, and typography follow Apple HIG on iOS and Material on Android. Cross-platform code, platform-true feel.

## 5. Wiring it into COMPASS

- The `design.md` rule auto-loads on UI files and enforces tokens/states/a11y as you build.
- Add your chosen system + token file locations to `docs/CODEBASE_MAP.md` ("Where to add X: new UI component → src/ui/, tokens → src/styles/tokens.css").
- During `/inspect`, the reviewer treats a hardcoded color, a missing focus state, or an unhandled empty state as a blocking issue — same class as a failing test.
- During `/spec` for any user-facing feature, the quality-bar question includes: which of the three orphan states matter here, and what do they say?

## 6. When design knowledge runs out (지식이 부족할 때)

Design gaps come in three kinds, each with its own fix:

**API-level** ("Astryx의 Modal props가 뭐지?") — never guess a beta library. The research skill's ladder applies: Astryx CLI docs → installed types in `node_modules` → repo docs via web. The installed package is the one source that exactly matches your lockfile version.

**Visual-level** ("만든 게 실제로 괜찮아 보이나?") — the agent can *see* its work: activate the Playwright MCP (`cp templates/.mcp.json.example .mcp.json`, trim to what you need), then the loop is: run the dev server → screenshot the page → compare against intent (tokens respected? hierarchy scannable? states present?) → fix → screenshot again. Screenshots turn "should look fine" into verified.

**Taste-level** ("원하는 감성이 나는가?") — taste does not transfer through words alone. The highest-bandwidth input is 2–3 reference screenshots from the user ("좋아하는 제품 화면을 캡처해서 주세요") pasted into the conversation during /spec — the agent extracts the concrete properties (density, radius, contrast, motion) and encodes them as tokens. Ask for references; don't guess at vibes.

## 7. Asset cookbook — 복붙해서 쓰는 무료 에셋 레시피

**Fonts (한국어 제품 기본값 = Pretendard Variable):**
```html
<link rel="stylesheet" as="style" crossorigin
  href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/variable/pretendardvariable-dynamic-subset.min.css" />
```
```css
:root { --font-sans: "Pretendard Variable", Pretendard, -apple-system, "Segoe UI",
        "Malgun Gothic", "Apple SD Gothic Neo", sans-serif; }
body { font-family: var(--font-sans); }
```
Latin-only products: Google Fonts Inter (`<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500&display=swap">`). Either way: pinned version, `display=swap`, stack defined once in tokens.

**Icons (React 기본값 = lucide-react):**
```bash
pnpm add lucide-react
```
```tsx
import { Search, Settings } from "lucide-react";
<Search size={20} strokeWidth={1.75} aria-hidden />
```
Rules of use: one library per project · size from tokens (16/20/24) · `aria-hidden` on decorative, `aria-label` on interactive · Astryx components already ship their own glyphs — don't double-icon them.

**Images:**
- Prototype placeholders: `https://picsum.photos/1200/630` (deterministic variant: `/seed/<name>/1200/630`).
- Production photos: pick from Unsplash/Pexels (both licenses permit commercial use without attribution, though crediting is courteous) → **download into `public/images/`**, compress (squoosh/`sharp`), serve locally. Hotlinking = someone else's uptime becomes your bug. `source.unsplash.com` is shut down — never emit those URLs.
- Illustrations: unDraw (undraw.co) — SVG downloads recolorable to your `--color-primary`; matches token-first theming perfectly.
- Ledger habit: every third-party asset → one line in `public/CREDITS.md` (source URL, license, date). Ten seconds now beats a takedown email later.

**How the agent should behave** (this is the part that fixes "밋밋한 결과물"): when building any user-facing screen, installing the icon set and loading the chosen font is part of the FIRST UI task, not a polish pass — a screen rendered in system font with emoji icons is not a draft, it's a design-rule violation the reviewer will block.
