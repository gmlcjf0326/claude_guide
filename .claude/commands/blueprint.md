---
description: Turn the SPEC into compared options, an approved plan, and a phased TODO checklist
argument-hint: [scope, or leave empty for the whole SPEC]
model: opus
---

ultrathink. Read `docs/SPEC.md` first. If it does not exist or is stale, stop and tell the user to run `/spec`.
> 🇰🇷 SPEC 없이 계획 없음. 계획 없이 코드 없음.

Scope: $ARGUMENTS

1. Identify every **significant decision** in this scope (architecture, data model, key libraries, integration approach). Small implementation details are not decisions — do not inflate the list.
2. For each significant decision, load the `tradeoff-analysis` skill and present **≥ 2 real options** — typically: (A) efficient-but-modest, (B) costly-but-high-impact, (C) balanced — scored on impact / effort / risk / reversibility / maintenance, with your recommendation and the regret scenario for each.
3. For irreversible or cross-cutting decisions, consult the `architect` subagent **before** presenting options, and include its verdict.
4. After the user chooses, append each decision to `docs/DECISIONS.md` (format in `templates/DECISIONS.template.md`).
5. Write `docs/PLAN.md` (phases, each with a goal and acceptance criteria) and `docs/TODO.md` (checklist items, each ≤ half a day of work). Use the matching templates.
6. Finish by proposing the first task and suggesting `/next`.
