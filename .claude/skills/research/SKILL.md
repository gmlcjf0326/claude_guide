---
name: research
description: Knowledge-freshness protocol for working beyond training data. Use whenever code touches a beta or fast-moving library (anything v0.x — Astryx included), a package or API whose exact signature is not certain, version-specific behavior (Tauri 2, React 19), anything released after the knowledge cutoff (new SDKs, pricing, quotas, policies), or when the user names an unfamiliar tool or term. Also use before /blueprint decisions that depend on facts that would otherwise be guessed. Prevents API hallucination by verifying against live sources and persisting findings to disk.
---

# Research — Working Beyond Training Data

Training knowledge has a cutoff and, worse, a confidence problem: the model does not reliably know what it doesn't know. This protocol replaces guessing with verification — and makes every verification permanent.
> 🇰🇷 환각의 근원은 "모른다는 걸 모름". 이 스킬은 추측을 검증으로 바꾸고, 검증 결과를 디스크에 영구화한다.

## When verification is MANDATORY (not optional)

- Any **v0.x / beta / RC dependency** — Astryx included; it changes weekly and training memory of it is presumed stale.
- Any API call whose **exact signature you could not write with certainty** right now.
- **Version-specific** behavior: Tauri 2 vs 1, React 19 vs 18, Postgres 16 features, Expo SDK differences.
- Anything plausibly **post-cutoff**: new releases, pricing, quotas, store policies, model names.
- The user names a **tool or term you don't recognize** → never bluff; verify or ask.

## The source ladder — try in order, note which rung you used

1. **The installed package itself** — `node_modules/<pkg>/` type definitions (`.d.ts`), README, source. Ground truth for the exact locked version; works offline; cannot be stale. This outranks the web.
2. **The package's own docs command** — Astryx: `npm run astryx -- component --list`, then `component <Name>` for props and usage. Other CLIs: `--help`, `man`.
3. **Context7 MCP** (if connected) — live library docs on demand. Activate by copying `templates/.mcp.json.example` → `.mcp.json`.
4. **Official docs via WebFetch / WebSearch** — the project's own site or GitHub over blogs; confirm the doc's version matches the installed one before trusting it.
5. **Reputable secondary sources** — last resort; cross-check at least two.

## Persist or it didn't happen (Rule 4 applies to knowledge too)

- **Small finding** (a signature, a config key): cite inline — a one-line code comment or task note ("per installed types v0.1.3").
- **Reusable finding** (how X's auth flow works, a pattern chosen): `docs/research/<topic>.md` — via `/research` or by hand. Next session reads the file instead of re-searching. Research that lives only in context is research you will pay for twice.
- **Decision-shaping finding**: fold into the `docs/DECISIONS.md` entry as evidence, with source links and dates.

## Honesty rules

- When verification mattered, say which rung: "per installed types", "per official docs fetched today".
- Sources conflict or nothing authoritative exists → say exactly that, present the options, let the user choose. An honest unknown beats a confident guess, every time.
- The typecheck gate is the safety net for hallucinated APIs against installed types — but it cannot check runtime semantics or behavior claims. Verify those at the source, not at the compiler.
