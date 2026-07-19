# 05 — The Codebase Index (CODEBASE_MAP.md)
> 🇰🇷 파일이 수백 개로 늘어도 5초 안에 위치를 찾게 해주는 색인 — 그리고 그 색인이 썩지 않게 하는 계약.

Operational rules live in the `codebase-map` skill. This guide shows what good looks like.

## Why decision-level, with evidence

A 2026 study of repository context files (138 real issues, multiple agents — figures as circulated; verify before citing) found that LLM-generated structural overviews *lowered* success rates in most settings while adding 20%+ inference cost — while concise, human-curated context helped. The direction, not the exact numbers, is the load-bearing claim. The mechanism is intuitive: an auto-dumped file tree is stale within days, and stale directions are worse than no directions. So the map records what a tree cannot: **purpose, boundaries, invariants, and where new things go** — the facts that survive renames.

## An annotated example (solo-dev SaaS)

```markdown
# Codebase Map — Acme Docs SaaS

## Overview
Next.js app + Supabase (Postgres/RLS/auth) + a worker for ingest.
Documents flow: upload → ingest worker (parse/chunk/embed) → pgvector → search API → UI.
Billing is Stripe subscriptions, webhook-driven.

## Areas
| Area | Path | Purpose | Entry points | Invariants / notes |
|---|---|---|---|---|
| Auth | src/features/auth | session, roles, org membership | index.ts | ALL authz decisions here; UI never checks roles directly |
| Ingest | worker/src/ingest | parse→chunk→embed pipeline | pipeline.ts | idempotent per doc hash; safe to re-run |
| Search | src/features/search | query API + ranking | api.ts | only module allowed to query pgvector |
| Billing | src/features/billing | Stripe subs + webhooks | webhook.ts | webhook is sole writer of subscription state |
| DB | supabase/migrations | schema + RLS | (SQL) | every table: RLS enabled + policy in same migration |

## Invariants & Boundaries
- Client code uses the anon key ONLY; service_role never leaves the server.
- Feature folders import each other only via index.ts surfaces.

## Where to add X
| Adding… | Goes in |
|---|---|
| a new API route | src/features/<area>/api.ts (new area → new folder) |
| a new background job | worker/src/jobs/<name>.ts + register in worker/src/index.ts |
| a new table | supabase/migrations (CREATE TABLE + RLS + policy + indexes, one file) |

Last verified: 2026-07-08 against a1b2c3d
```

Notice what's absent: no per-file listing, no line counts, no code explanations. Every row answers "where do I go?" or "what must stay true?".

## The freshness economy

The map stays alive through two cheap habits, not heroic rewrites: (1) **the same-commit contract** (Rule 6) — structure change and map change travel together, so drift can't accumulate; (2) **spot-checks** — `/restore` and `/map` verify 3 random entries against reality; 2+ stale triggers a full pass. The footer's `Last verified` date makes staleness visible instead of ambient.
> 🇰🇷 지도는 대청소가 아니라 두 가지 잔습관으로 산다: 구조 변경과 같은 커밋에 갱신, 그리고 무작위 3개 항목 표본검사.
