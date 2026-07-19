---
paths:
  - "supabase/**"
  - "**/supabase/**"
  - "functions/**"
  - "**/firestore.rules"
  - "**/storage.rules"
  - "**/database.rules.json"
  - "**/firebase.json"
  - "**/.firebaserc"
---

# Serverless Rules — Supabase & Firebase
> 🇰🇷 Supabase/Firebase 작업 시 자동 적용. 여기의 RLS 체크리스트는 생략 불가.
> Applies to Supabase/Firebase projects ONLY. The RLS litany is Supabase-specific — in other stacks, `.sql` files follow postgres.md (or your engine's semantics), and a folder merely named `functions/` does not make a project serverless.

## Supabase — the RLS litany (each line prevents a real production incident)
1. `ALTER TABLE ... ENABLE ROW LEVEL SECURITY` **in the same migration** as `CREATE TABLE` — a table without RLS is publicly writable through the anon key.
2. RLS enabled with **zero policies = all queries silently return empty** — always ship at least one policy with the enablement.
3. Every INSERT/UPDATE policy needs **`WITH CHECK`** — `USING` alone lets users write rows they couldn't read (ownership theft).
4. **Index every column referenced inside a policy** (`user_id`, `team_id`, ...) — unindexed policy predicates seq-scan and time out exactly when you get traction.
5. Scope policies with **`TO authenticated`** (or the precise role); avoid policies that also run for `anon` unintentionally.
6. **`service_role` key never leaves the server.** Client code uses `anon` + RLS, period.
7. Join-heavy policies → wrap in a `SECURITY DEFINER` helper function; prefer `team_id IN (SELECT ...)` over correlated joins.

## Supabase — workflow
- Schema changes ONLY via CLI migrations (`supabase migration new`, committed SQL). Dashboard edits create untracked drift — if it happened, `db pull` immediately.
- Business logic in Edge Functions or your backend, not in ever-growing SQL triggers.
- Serverless runtimes connect through the pooler port (Supavisor), not direct Postgres.

## Firebase
- Firestore rules are **deny-by-default**; every `allow` is explicit, tested with the emulator, and never `allow read, write: if true` "temporarily".
- Cloud Functions: small, stateless, **idempotent** (retries WILL redeliver events); check-and-set with a processed-marker for event handlers.
- No unbounded queries — paginate everything user-facing; a missing `limit()` is a cost and latency bug.
- Emulator suite for local dev and tests; never test against production projects.
