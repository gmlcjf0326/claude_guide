---
description: Clarify-first requirement interview — never write code here; output is docs/SPEC.md
argument-hint: [feature or problem description]
---

ultrathink. Load the `requirement-interview` skill and follow it exactly for this request: $ARGUMENTS
> 🇰🇷 코드 작성 절대 금지. 이 커맨드의 산출물은 오직 완성된 SPEC 문서다.

Non-negotiables for this command:
0. **Check `docs/inputs/` first** — if reference material relevant to this request sits there (or the user just added some), read and incorporate it before interviewing. Distill reusable findings into `docs/research/`. Don't re-ask what those documents already answer.
1. First, restate the ask in one paragraph AND describe what success would look like — then let the user correct you.
2. Interview in rounds: 3–5 focused questions per round, offering concrete A/B/C choices wherever possible (choosing is easier than composing). Cover, over the rounds: goal & motivation · users & context · scope and explicit non-goals · constraints (stack, time, budget, deployment) · data & integrations · quality bar (performance, security, UX) · risks and unknowns.
3. End every round with a **confidence score (0–100%)** and a one-line list of what is still unknown. Below 90%: ask another round. At or above 90%: proceed.
4. Apply the better-direction protocol (Core Rule 2): if a superior approach to the user's stated goal exists, present it now as an explicit option with honest trade-offs.
5. At ≥ 90% confidence: write `docs/SPEC.md` following `templates/SPEC.template.md`, then show a ≤ 10-line summary and ask for sign-off. Suggest `/blueprint` as the next step.
