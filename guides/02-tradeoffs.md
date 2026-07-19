# 02 — Trade-offs: Options Before Commitment
> 🇰🇷 중요한 결정마다 "효율형 vs 효과형 vs 균형형" 선택지를 견주고, 기록한다.

The operational method lives in the `tradeoff-analysis` skill. This guide adds depth and judgment.

## The quadrant, and why it's the default framing

Most engineering choices spread along two axes: **효율 (efficiency — how cheap/fast to build and run)** and **효과 (effect — how strong the outcome)**. Presenting options as *A-Efficient / B-Impactful / C-Balanced* forces the real question into the open: *how much outcome does this decision actually need?* A logging library needs an A. Your data model usually deserves a B. Pretending everything deserves B is how projects die of gold-plating; pretending everything tolerates A is how they die of rework.

```
효과(Effect) ↑
  │      B (impactful)
  │            C (balanced)
  │  A (efficient)
  └──────────────────→ 효율(Efficiency)
```

## Reversibility is the master criterion

Two-way doors (a library behind one wrapper, a UI layout, an internal naming scheme) — decide fast, pick A, move on; being wrong costs an afternoon. One-way doors (database engine, public API contract, auth model, multi-tenancy shape, on-prem vs cloud packaging) — slow down, consult the `architect` subagent, often pay for B. **The cost of a decision is not its build cost; it's its exit cost.**
> 🇰🇷 결정의 진짜 비용은 만드는 비용이 아니라 '되돌리는 비용'이다. 되돌리기 쉬우면 빠르게, 어려우면 무겁게.

## The regret scenario technique

For each option, write one sentence describing the future where choosing it hurts most ("Regret: we hit Supabase's connection limits during our launch spike"). This does two things: it makes risks concrete instead of vibes, and it produces the *revisit-when trigger* for `docs/DECISIONS.md` almost for free — the trigger is simply the regret scenario's early-warning signal.

## Honest option generation

- Never fabricate a strawman C just to have three options. Two real options beat three where one is decoration.
- If only ONE reasonable option exists (rare, but real — e.g., the platform mandates it), say exactly that: "This is effectively decided by <constraint>; here's the one viable path and what would have to change for alternatives to open up." That's still trade-off thinking.
- Options must differ in *kind*, not just parameter values. "Postgres with 2 replicas vs 3 replicas" is tuning, not options.

## Recording — why DECISIONS.md pays rent

Across a long project, the same decision resurfaces every few weeks ("why aren't we using tRPC again?"). Without a record, you re-litigate; with one, you read three lines and move on — or you hit the revisit trigger and *know* it's genuinely time to reopen. Each entry: ID, date, options with one-line scores, choice, why, revisit-when. The template is `templates/DECISIONS.template.md`.
