# 01 — Clarify First: Understanding Before Building
> 🇰🇷 요구를 90% 이상 이해하기 전에는 코드를 쓰지 않는다 — 그 규율의 이유와 실전 기법.

The operational protocol lives in the `requirement-interview` skill. This guide is the *why* and the field manual.

## Why the gate exists

An agent that starts coding on a fuzzy request doesn't fail loudly — it succeeds at the wrong thing. Rework then costs more than the interview ever would, and worse, it teaches the user to distrust delegation. The confidence gate converts "I think I know what they want" into an explicit, inspectable number that must clear 90% before any code exists.

## The XY problem — the most common trap

Users routinely ask for their *attempted solution* (X) instead of their *actual problem* (Y). "Add a cron job that clears the table nightly" may really mean "the table grows unbounded and queries slow down" — where the better answers might be TTL indexes, partitioning, or fixing the leak. The interview skill's first dimension (goal & motivation) exists precisely to surface Y. When you smell a solution-shaped request, ask: **"What outcome does that give you?"**
> 🇰🇷 사용자는 종종 '문제'가 아니라 '자기가 떠올린 해법'을 요청한다. 해법 냄새가 나면 반드시 그 뒤의 목표를 캐물어라.

## Worked examples

**Vague feature** — "Add auth to my SaaS."
Round 1 (goal/users): Who signs up — individuals or teams? Is enterprise SSO on the roadmap? Round 2 (scope/quality): email+password vs OAuth vs magic links (A/B/C)? Session length? Password reset in v1? Round 3 (constraints): Supabase already in the stack → propose Supabase Auth as option A (efficient) vs custom JWT (impactful/control) — and note that choosing A collapses three weeks of work into two days. Confidence: 92% → SPEC.

**Solution-shaped request** — "Make the dashboard faster with Redis."
Better-direction protocol fires: measure first. The real cause might be an N+1 query, a missing index, or over-fetching — each cheaper and more durable than a cache layer that adds invalidation bugs. Present Redis as one option *after* profiling, not as the premise.

**Underspecified greenfield** — "온프레미스로도 팔 수 있는 문서 검색 서비스 만들고 싶어."
This is a product, not a task. The interview runs longer (2–4 rounds), and the SPEC's *non-goals* matter more than its goals: no multi-tenant billing in v1, no mobile app, Korean-language documents only first. The smallest useful version question ("가장 작은 유용한 버전은?") is the single highest-value question for requests like this.

## Calibrating the confidence number

The number is honest only if it survives this test: *for every requirement, could I write the acceptance criterion right now, and is there no unknown left that could change the architecture?* Unknown UI copy → doesn't block 90%. Unknown tenancy model → absolutely blocks 90%, because it changes the schema, auth, and pricing. Distinguish unknowns by their blast radius.

## When to skip the interview

Trivial state (states 4–6): typos, one-line fixes, mechanical renames, config tweaks with obvious intent. The tell: you could describe the entire diff in one sentence and be certain the user would nod. Anything requiring that sentence to contain "probably" goes through `/spec`.
