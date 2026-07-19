---
name: tradeoff-analysis
description: Structured option comparison for significant technical decisions. Use whenever a choice meaningfully shapes architecture, cost, or future flexibility — picking a database, auth strategy, library, deployment model, sync approach, refactor strategy — and always inside /blueprint and /improve. Produces a compared option set (typically efficient-vs-impactful-vs-balanced) with a recommendation, and records the outcome in docs/DECISIONS.md. Do NOT use for trivial choices like variable names or import order.
---

# Trade-off Analysis

One option is a decree. Two options is a choice. Compared options with honest costs is engineering.
> 🇰🇷 선택지 하나는 통보, 둘은 선택, 비용까지 정직하게 견준 것이 엔지니어링이다.

## Step 1 — Is this actually a significant decision?

Significant = expensive to reverse, OR shapes many future decisions, OR moves cost/performance/security materially. Everything else: just pick the conventional answer and move on. Fabricating fake alternatives for trivial choices is noise, not rigor.

## Step 2 — Generate real options

Generate along these axes until you have 2–4 genuinely different answers:

- **Build vs buy vs assemble** (custom code / managed service / library glue)
- **Now vs later** (solve fully now / smallest slice now + revisit trigger)
- **Simple vs flexible** (hardcode the one case / generalize)
- **Managed vs self-hosted** (Supabase vs own Postgres; Vercel vs VPS)

Default framing — the COMPASS quadrant (matches how the user thinks):

| Label | Profile |
|---|---|
| **A — Efficient** | 효율↑ 효과 중간 · low effort, decent outcome, ships fastest |
| **B — Impactful** | 효율↓ 효과↑ · high effort, strongest outcome, slowest |
| **C — Balanced** | the pragmatic middle, when a real one exists (never invent a fake C) |

## Step 3 — Score honestly

| Criterion | Question it answers |
|---|---|
| Impact | How much closer to the SPEC's goal does this get us? |
| Effort | Hours/days to working, verified state? |
| Risk | What can go wrong, how likely, how bad? |
| Reversibility | If wrong, what does switching cost? ← weight this heavily |
| Maintenance | What does this cost every month after it ships? |

Present as a compact table (H/M/L is fine — false numeric precision is worse than honest fuzz). For each option add one line: **"Regret scenario:"** — the future in which choosing it hurts most. If you cannot write a regret scenario, you have not thought hard enough about that option.

## Step 4 — Recommend, with teeth

Always end with a recommendation and the reasoning. Tie-breakers, in order:
1. **Reversible beats irreversible** at equal value — a good-enough door you can walk back through beats an optimal wall.
2. **Simple beats flexible** unless the SPEC explicitly demands the flexibility today.
3. **Boring beats novel** for infrastructure; save novelty for the product's actual differentiator.

For irreversible calls, get the `architect` subagent's verdict before presenting (Core Rule 8) and include it.

## Step 5 — Record

After the user picks, append to `docs/DECISIONS.md` (see template): ID, date, decision, options with one-line scores, why, and a **revisit-when trigger** ("revisit if >50GB data or multi-region needed"). A decision without a revisit trigger silently becomes dogma.
> 🇰🇷 기록 없는 결정은 다음 세션에서 다시 싸우게 되고, 재검토 조건 없는 결정은 교리가 된다.

## Worked example (compressed)

Decision: primary datastore for a solo-dev SaaS.
- **A Supabase (Efficient)** — Impact M, Effort L, Risk L-M, Rev M, Maint L. Regret: hitting RLS/pricing walls at scale.
- **B Self-hosted Postgres (Impactful)** — Impact H(control), Effort H, Risk M, Rev M, Maint H. Regret: solo dev spending weekends on ops instead of product.
- **C SQLite + Litestream (Balanced-small)** — Impact M(single-node), Effort L, Risk M, Rev H, Maint L. Regret: multi-writer needs arrive early.
**Recommendation: A** — auth+RLS+realtime included outweigh lock-in at this stage; high-quality migration path exists. *Revisit when: >50GB, multi-region, or Supabase pricing exceeds a dedicated DBA-hour/month.*
