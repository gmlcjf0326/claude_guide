---
description: Continuous-improvement retrospective — find the top 3 improvements and present them as options
---

ultrathink. This is State-7 thinking: make the system better, not just the feature.
> 🇰🇷 항상 더 나은 방향으로. 단, 실행은 사용자가 고른 뒤에만.

1. Gather signals: files over 300 lines (`explorer` subagent can list them) · duplication candidates · drift between `docs/SPEC.md` and reality · "Improve" lines accumulated in `docs/SESSION_LOG.md` · recurring mistakes this project keeps making.
2. Pick the **top 3** improvements by value ÷ effort. For each, apply `tradeoff-analysis` briefly: what it costs, what it buys, the risk of NOT doing it.
3. Meta-improvement check: if a mistake keeps recurring, propose promoting the fix up the enforcement ladder — observation → CLAUDE.md rule → hook (see guides/11-continuous-improvement.md).
4. Present the 3 as options. Implement ONLY what the user picks; park the rest in `docs/BACKLOG.md`.
