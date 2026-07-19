---
paths:
  - "**/*.sql"
  - "**/migrations/**"
  - "**/db/**"
  - "**/prisma/**"
  - "**/drizzle/**"
---

# PostgreSQL Rules
> 🇰🇷 Postgres 스키마/쿼리/마이그레이션 작업 시 자동 적용. (Supabase도 Postgres — supabase/ 경로에서는 serverless.md의 RLS 체크리스트가 함께 적용된다.)
> Applies only when this project's database IS PostgreSQL (check docs/PROJECT.md or the driver in use). These paths also match Prisma/Drizzle/migrations on other engines — for MySQL/SQLite/SQL Server, skip the Postgres-specific mandates (`timestamptz`, `CREATE INDEX CONCURRENTLY`, `GENERATED ALWAYS AS IDENTITY`, pgbouncer/Supavisor) and follow that engine's semantics.

## Schema — types & constraints are the last line of defense
- `text` over `varchar(n)` unless a real business limit exists; `timestamptz` ALWAYS (`timestamp` without zone is a latent bug); `numeric` for money — never `float`; `bigint GENERATED ALWAYS AS IDENTITY` for PKs (UUIDv7 acceptable when IDs must be client-generated or unguessable).
- `NOT NULL` is the default posture — nullable needs a reason. Every relationship gets a real `FOREIGN KEY` with an explicit `ON DELETE` decision (CASCADE/RESTRICT/SET NULL — chosen, not defaulted). `CHECK` constraints for domain rules; `UNIQUE` wherever the business says "one per".
- Naming: `snake_case` everywhere; consistent plural table names; indexes as `ix_<table>_<cols>`.

## Migrations — forward-only, boring, safe
- Never edit an applied migration; fix forward. One concern per migration file. Timestamped filenames.
- Set `lock_timeout` (e.g., `2s`) and `statement_timeout` at the top of risky migrations — a blocked `ALTER TABLE` must fail fast, not freeze production.
- Big-table safety recipes: add column → nullable first, backfill in batches, then `SET NOT NULL`; new index → `CREATE INDEX CONCURRENTLY` (outside a transaction); never rewrite a hot table in one statement.

## Indexes & query health
- Index: every FK column, every column in frequent `WHERE`/`ORDER BY`/policy predicates. Partial indexes for status/soft-delete filters (`WHERE deleted_at IS NULL`).
- Justify with `EXPLAIN (ANALYZE, BUFFERS)` before and after — no cargo-cult indexes; each one taxes every write.
- Keyset pagination (`WHERE id > $1 ORDER BY id LIMIT n`) over `OFFSET` for anything that grows. No `SELECT *` in application code.
- Parameterized queries ONLY — string-built SQL is an injection and a plan-cache bug in one move.

## Transactions & connections
- Transactions short and local: no network calls (HTTP/LLM/email) inside a transaction, ever. Retry on serialization failure (SQLSTATE 40001) when using stricter isolation.
- Apps connect through a pooler (pgbouncer / Supavisor); serverless functions use the transaction-mode pooler port. Pool sizes stay modest — hundreds of direct connections is how Postgres tips over.

## Ops floor
- Backups are only real once restored: test `pg_dump`/PITR restores on a schedule. Watch `pg_stat_statements` for the top-10 slow queries; that list is your performance backlog.
