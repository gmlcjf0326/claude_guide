---
name: requirement-interview
description: Structured requirement-elicitation interview that must run before any non-trivial implementation. Use whenever the user requests a new feature, product, or change and the requirements are not already captured in docs/SPEC.md with ≥90% confidence — including vague requests ("make it better", "add auth"), first messages of a project, and any time the user seems unsure what they want. Produces or updates docs/SPEC.md. Invoked by /spec and by COMPASS State 1.
---

# Requirement Interview

The most expensive bug is building the wrong thing perfectly. This skill converts a fuzzy request into a signed-off SPEC through structured questioning — and, critically, through *proposing directions the user did not know to ask for*.
> 🇰🇷 가장 비싼 버그는 "엉뚱한 것을 완벽하게 만드는 것". 질문으로 안개를 걷고, 사용자가 몰랐던 더 나은 길까지 제시한다.

## The Confidence Gate

After every interview round, state a confidence score:

| Score | Meaning | Action |
|---|---|---|
| < 60% | Goal itself is unclear | Ask about goal & motivation only |
| 60–89% | Goal clear, edges fuzzy | Ask about scope, constraints, quality bar |
| ≥ 90% | Could write unambiguous acceptance criteria for every requirement | Write SPEC, request sign-off |

**90% means**: for each requirement you could write a testable acceptance criterion, and no remaining unknown could change the architecture. If an unknown could change the architecture, you are not at 90% — ask.
> 🇰🇷 90% = 모든 요구에 대해 검증 가능한 완료 기준을 쓸 수 있고, 남은 미지수가 아키텍처를 바꿀 수 없는 상태.

## Question Taxonomy — cover all seven over the rounds

| Dimension | Sample questions (adapt, don't recite) |
|---|---|
| Goal & motivation | What problem does this solve? What happens if we don't build it? How will you know it worked? |
| Users & context | Who uses this, how often, on what device/environment? Expert or first-timer? |
| Scope & non-goals | What is explicitly OUT for v1? What is the smallest version that is still useful? |
| Constraints | Stack fixed or open? Deadline? Budget ceiling (infra, API costs)? Must it run on-premise? |
| Data & integrations | What data exists today, in what shape? What external systems must this talk to? |
| Quality bar | Expected load? Acceptable latency? Security/compliance sensitivity? Offline needed? |
| Risks & unknowns | What are you most worried about? What has failed before? |

## Interview Mechanics

1. **Restate first.** Open with a one-paragraph restatement of the ask plus your picture of "success". Being corrected early is the cheapest correction there is.
2. **Batch 3–5 questions per round.** One-at-a-time exhausts people; ten-at-once overwhelms them.
3. **Offer choices, not blanks.** "Auth: (A) email+password, (B) OAuth social login, (C) magic links — which fits your users?" is faster and more accurate than "how should auth work?". Always leave room for "(D) something else".
4. **Declare defaults for the indifferent.** "If you have no preference, I'll assume A because <reason>" — this keeps momentum without hiding assumptions (Core Rule 1).
5. **Close every round** with: confidence score, what's still unknown, and whether another round is needed.

## When neither of you knows the answer

Some questions cannot be answered by asking harder: market sizing, whether a library actually supports X, quota and pricing ceilings, regulatory requirements, post-cutoff platform behavior. Guessing is forbidden (Rule 1) and stalling is useless — so **switch modes**: run the `research` skill (or `/research <topic>` for anything decision-shaping), persist the finding to `docs/research/`, then resume the round citing it.

**Hard rule:** confidence may not cross 90% while an *unresearched* unknown could still change the architecture. "The user didn't know either" is not a reason to proceed — it is the trigger to go find out.
> 🇰🇷 사용자도 나도 모르는 사실에 막히면 추측도 정체도 답이 아니다 — /research로 전환해 확인하고, 결과를 디스크에 남긴 뒤 라운드를 재개한다.

## Interviewing on top of documents (docs/inputs/)

When a SPEC draft already exists because `/setup` §0 distilled the user's own documents, the interview's job inverts — from **elicitation** to **verification**:

1. Read the document-derived MUSTs back, grouped by source file, and get an explicit confirm / deny / amend on each. Documents are *evidence*; only the user is sign-off.
2. Anything the user does not confirm stays visibly marked as unconfirmed — never promote it silently.
3. Interview only the genuine gaps and the conflicts §0e surfaced. Re-asking what the documents already answered burns the user's goodwill and teaches them the ingest was theater.
4. The SPEC stays `Signed off by user: ☐` until the user approves it in this conversation. `/blueprint` refuses to plan on an unsigned SPEC.
> 🇰🇷 문서에서 뽑은 요구사항은 '확인 대상'이지 '확정 사실'이 아니다. 문서는 증거, 서명은 사람.

## The Better-Direction Protocol (Core Rule 2)

The user may be asking for X when Y serves their goal better. When you detect this:

1. Confirm the underlying goal ("You want X — is that because of <inferred goal>?").
2. Present Y **as an option**, never a fait accompli: what Y is, why it may serve the goal better, what it costs relative to X, and your honest recommendation.
3. If the user still chooses X, build X well and record the exchange in `docs/DECISIONS.md`. Advising is your job; deciding is theirs.
> 🇰🇷 더 나은 방향은 '제안'한다. 강요하거나 몰래 바꾸지 않는다. 최종 결정권은 사용자에게.

Classic triggers: the request names a *solution* instead of a *problem* ("add a cron job" → the real need may be event-driven); the request fights the existing architecture; a managed service would replace weeks of custom code; the v1 scope hides a much smaller version that ships this week.

## Writing the SPEC

At ≥ 90% confidence, write `docs/SPEC.md` per `templates/SPEC.template.md`. Requirements use MUST / SHOULD / WON'T (this version). Every MUST gets a testable acceptance criterion. Non-goals are as explicit as goals — they are what keeps scope from creeping back in. Finish with a ≤ 10-line summary in chat and an explicit sign-off question.

## Anti-Patterns

- **Interrogation theater**: asking questions whose answers change nothing. Every question must be able to alter the SPEC.
- **Assumption smuggling**: proceeding on unstated guesses. State them or ask them.
- **Premature solutioning**: designing during the interview. Capture ideas as SPEC notes; design happens in `/blueprint`.
- **Confidence inflation**: claiming 90% to escape the interview. The number must survive the "could I write acceptance criteria right now?" test.
- **Document laundering**: treating a requirement as settled because a document in `docs/inputs/` said so. The user wrote or collected that document; they still have to confirm it survived contact with the plan.
