---
description: Clarify-first requirement interview — never write code here; output is docs/SPEC.md
argument-hint: [feature or problem description]
---

ultrathink. Load the `requirement-interview` skill and follow it exactly for this request: $ARGUMENTS
> 🇰🇷 코드 작성 절대 금지. 이 커맨드의 산출물은 오직 완성된 SPEC 문서다.

Non-negotiables for this command:
0. **Check `docs/inputs/` first — at any point in the project, not just at the start.** Read the ledger `docs/inputs/INGESTED.md`, then ingest only what is unlisted or revised, following `/setup` §0 verbatim (0a inventory → 0b format ladder → 0c large-doc triage → 0d distill with `[src: …]` provenance → 0e conflicts into `docs/DECISIONS.md` → 0f append to the ledger). Never re-read what the ledger already covers, and never silently skip a file you couldn't convert. Don't re-ask what those documents already answer.
0b. **If a SPEC draft already exists from ingested documents**, this interview's job is *verification, not elicitation*: read the document-derived MUSTs back and get an explicit confirm/deny on each. Documents are evidence; only the user is sign-off.
1. First, restate the ask in one paragraph AND describe what success would look like — then let the user correct you.
2. Interview in rounds: 3–5 focused questions per round, offering concrete A/B/C choices wherever possible (choosing is easier than composing). Cover, over the rounds: goal & motivation · users & context · scope and explicit non-goals · constraints (stack, time, budget, deployment) · data & integrations · quality bar (performance, security, UX) · risks and unknowns.
3. End every round with a **confidence score (0–100%)** and a one-line list of what is still unknown. Below 90%: ask another round. At or above 90%: proceed.
4. Apply the better-direction protocol (Core Rule 2): if a superior approach to the user's stated goal exists, present it now as an explicit option with honest trade-offs.
5. At ≥ 90% confidence: write `docs/SPEC.md` following `templates/SPEC.template.md`, then show a ≤ 10-line summary — marking which requirements came from ingested documents and which from this interview — and ask for sign-off. **On explicit approval, set `Signed off by user: ☑` with today's date and remove any `pending sign-off` marker** — `/blueprint` is gated on it. Suggest `/blueprint` as the next step.
