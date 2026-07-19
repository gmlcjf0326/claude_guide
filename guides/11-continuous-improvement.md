# 11 — Continuous Improvement: The System That Upgrades Itself
> 🇰🇷 "항상 더 나은 방향으로"를 기분이 아니라 절차로 만드는 법.

## The improvement loop

Signals accumulate passively, then get harvested deliberately:

1. **Collect (free)** — every `/checkpoint` writes one "Improve:" line into SESSION_LOG (a friction felt, a duplication noticed, a mistake made). Zero ceremony; just one honest line.
2. **Harvest (`/improve`, at milestones)** — scan the signals: bloat report (files >300), duplication candidates, spec drift, recurring mistakes, accumulated Improve lines. Rank by value ÷ effort. Present the **top 3 as options** with trade-offs — improvement work competes for time like feature work and deserves the same honesty.
3. **Execute what the user picks; BACKLOG the rest.** Unbounded refactoring sprees are how improvement gets banned; scoped, chosen improvements are how it compounds.

## The promotion ladder — teaching the system

When the *same mistake happens twice*, the fix isn't "try harder" — it's promotion to a stronger enforcement tier:

```
Tier 0  Observation        "huh, forgot to register the Tauri command again"   (SESSION_LOG)
Tier 1  Written rule       add a line to the relevant .claude/rules/*.md       (advisory)
Tier 2  Checklist gate     add to DoD checklist or a command's steps           (procedural)
Tier 3  Hook               deterministic check, every time                     (LAW)
```

Promotion test: *did it recur after the previous tier?* → promote. The guard-secrets hook, the bloat check, and the stop-gate all started life, conceptually, as Tier-0 observations somebody got burned by. Conversely, **demote and delete**: a rule that hasn't prevented anything in months is spending instruction budget for nothing — the budget is finite, and pruning is improvement too.
> 🇰🇷 같은 실수 2회 = 티어 승격. 반대로 몇 달간 아무것도 막지 못한 규칙은 삭제 — 가지치기도 개선이다.

## Improving COMPASS itself

The system is not sacred. Healthy adaptations: budgets tuned to your reality (a Rust codebase might warrant 400/600) · new stack rules as your stacks evolve · new skills for workflows you repeat (see guide 10) · commands renamed to whatever your fingers actually type. Keep the four invariants, though — lean CLAUDE.md, disk-is-truth, hooks-for-must-haves, curated map — those are the load-bearing walls; everything else is furniture.

## The quarterly question

Every milestone or so, ask the meta-question: **"What did this project's last three mistakes have in common, and which tier fixes that class?"** One honest answer to that question is worth more than any amount of generic best-practice reading — it's *your* system learning *your* failure modes.
