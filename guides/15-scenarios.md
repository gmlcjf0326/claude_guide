# 15 — Scenarios by Scale: One System, Three Gears
> 🇰🇷 같은 제품이 프로토타입 → MVP → 대규모로 성장하는 3막 실전 시나리오. 핵심 주장: 규모가 커져도 시스템은 교체되지 않는다 — 다이얼만 돌아간다.

The product: **PulseBoard** — a public feedback-board service (users post/vote on feature requests). Act 1 validates the idea with a Firebase serverless prototype; Act 2 builds the paid MVP; Act 3 operates at 1M+-token scale. All three acts use the same golden path (/setup once, then the five-command loop) and the same nine state files.

## 0. The scale dial

| | Act 1 · Prototype (1–2 days) | Act 2 · MVP (3–6 weeks) | Act 3 · Product (months, 1M+ tokens) |
|---|---|---|---|
| Goal | validate demand | prove paid value | grow & operate |
| `/spec` depth | 1 round (no architecture-changing unknowns) | 2–3 rounds; the 90% gate genuinely blocks | per-feature SPECs, quarterly re-alignment |
| State files in real use | PROJECT · TODO · PROGRESS | all nine; MAP is born; DECISIONS accumulate | all nine + map audits + drift ritual + `/improve` cadence |
| Sessions | 1–2 total | one per phase | one per phase + strict `/clear` discipline |
| Verification | smoke checks + rules tests | full gates + `/inspect` every task | + regression suite as long-term memory, CI |
| Skipped (out loud) | full test pyramid, i18n, analytics → BACKLOG | premium features, admin comforts | nothing silently — everything becomes a decision |
| **Never skipped** | security rules deny-by-default · secrets hook · honest TODO | same | same |

---

## Act 1 — 소규모: Firebase serverless landing + waitlist (weekend)

Fresh folder → COMPASS merged → `git init`. The transcript (12 prompts, condensed):

| # | You type | What happens / the point |
|---|---|---|
| 1 | `/setup` | 5 questions. Answers: stage **validating** · bias **ship-speed > polish** · non-negotiable: "Firestore rules deny-by-default, 프로토여도". → PROJECT.md written, the directive lands in `project-directives.md` (permanent) |
| 2 | `/spec 아이디어 검증용 랜딩페이지 + 이메일 웨이트리스트. Firebase 호스팅+Firestore. 이번 주말 안에.` | Goal·context·constraint in two lines — the interview digs the rest |
| 3 | `1-A(Vite+React), 2-이메일+한줄용도, 3-없음(나중), 4-없음, 5-Astryx neutral 그대로` | One round → **confidence 92%**. Why one round is honest here: no remaining unknown could change the architecture — the gate is met, not lowered |
| 4 | `승인. /blueprint` | Rare honest case: "at this scale there is exactly one reasonable path" — stated explicitly instead of inventing fake options (tradeoff-analysis anti-fabrication rule). PLAN: P1 static landing deployed · P2 waitlist write + rules. TODO: 6 items ≤1h each. Alerts/analytics/i18n → **BACKLOG, out loud** |
| 5 | `/next` | T-001 scaffold. Astryx knowledge ladder in action: `npm run astryx -- component Hero` before writing a line (research skill — beta lib, never from memory) |
| 6 | `/next` ×2 | T-002 copy+tokens (design.md enforces: no hardcoded hex) · T-003 deploy — proof: `curl -s -o /dev/null -w "%{http_code}" https://…` → `200` |
| 7 | `/next` | T-004 the rules moment — serverless.md auto-loaded: `allow create: if` email-shape valid && no extra fields; `read, update, delete: false`. **Emulator rules test runs even in a prototype** — a world-writable Firestore is the worst accident a prototype can have |
| 8 | `/next` | T-005 form wiring. Post-edit hook formats silently; no bloat warnings (files tiny) |
| 9 | `/inspect` | Reviewer **FAIL**: form lacks the three orphan states (success / already-registered / error). Fixed, re-review **PASS** — even prototypes ship states, per design rule |
| 10 | `/remember 사용자 입력 폼은 성공·중복·실패 3상태를 항상 갖춘다` | Today's lesson → permanent (survives every future compact) |
| 11 | `배포 URL 확인했어. /checkpoint` | TODO honest (2 items → BACKLOG), PROGRESS snapshot, SESSION_LOG entry (Improve: "에뮬레이터 셋업 스크립트화"), commit + push |
| 12 | *(2 weeks later: 214 signups)* | Act 2 begins |

**What the system bought at this scale**: not ceremony — *explicit omission* (4 BACKLOG items instead of vague guilt), one security invariant that never bent, and a save-file that made Act 2 start from knowledge instead of archaeology.

---

## Act 2 — 중규모: the paid MVP (Firebase, 3–6 weeks)

| # | Beat | The point |
|---|---|---|
| 1 | `/setup` (re-run = review mode) | stage validating→**MVP**, bias re-balanced, new directive: "모든 Cloud Function은 멱등(idempotent)" — pivots re-profile, they don't re-install |
| 2 | `/spec 피드백 보드 SaaS. 웨이트리스트 214명 대상 유료 출시…` — round 1 | Tenancy question surfaces: 개인 계정 vs 워크스페이스? **Confidence stalls at 78%** — this unknown changes schema, rules, and pricing. The gate actually blocks; two more rounds follow |
| 3 | Round 2: user asks for anonymous voting | **Better-direction protocol fires**: anonymous = spam/abuse surface → presented as option (A anonymous+rate-limit, B account-required, C email-verified anonymous) with honest trade-offs. User picks B. Advising, not overriding |
| 4 | `/blueprint` | Real options this time. **D-0001 data model**: A root collections + `workspaceId` field (query-flexible) vs B workspace subcollections (rules simple, isolation natural) → B recommended; regret: cross-workspace search gets harder; *revisit-when: global search ships*. **D-0002 payments**: A Stripe Checkout links (efficient) vs B full portal+webhooks (impactful) → A now, *revisit at 10 paying teams* |
| 5 | Phases = vertical slices | P1 auth+workspace walking skeleton (signup→create board→one post, end to end) · P2 posts/votes/comments · P3 Slack notify Function · P4 Stripe + **hard paywall** (guide 13 data: 5× conversion, retention identical) |
| 6 | `/next` loop, P2 | Bloat hook fires: `posts/service.ts` 312 lines (soft) → split by seam into `posts/`, `votes/`, `comments/` — map updated same commit (Rule 6) |
| 7 | `/inspect`, P2 | Reviewer **FAIL (blocking)**: vote-count update rule lets a client write arbitrary counts (the WITH-CHECK class of bug, Firestore edition). Fix: counts move server-side into a Function; rules test added as regression. **This is the incident the process exists for** |
| 8 | P3 idempotency | Slack notify Function: event-doc marker (`processed/{eventId}`) checked before send — retries WILL redeliver (serverless.md), and the directive from beat 1 is now muscle |
| 9 | Phase boundary | `/checkpoint` → `/clear` → next session opens with the co-pilot briefing re-injected from disk. Fresh context + crisp docs > 120K of tired history |
| 10 | 25-edit counter fires once mid-P4 | "Unprotected work accumulating" → checkpoint mid-phase. The nudge that prevents the 55-minute loss |
| 11 | `/map` after P2 | The map is born at ~40 files — decision-level: 5 areas, 2 invariants ("counts only written by Functions", "client uses rules-guarded paths only") |
| 12 | Week 6 | First paying team. **Resume Test run**: fresh session, "계속해" → correct next action in 90 seconds. System certified healthy |

**What changed at this scale**: decisions became assets (D-0001 gets cited three times in later work), phases became shippable slices, and `/inspect` paid its rent twice with real incidents.

---

## Act 3 — 대규모: months in, the 1M+-token regime

Weekly-log excerpts — by now the system is invisible; only the rituals show:

| Week | Event | The point |
|---|---|---|
| W1 | Daily shape: open → co-pilot briefing → `/next`… → evening `/checkpoint` → `/clear` | Phase-per-session is the default gear, not an aspiration |
| W2 | **Drift ritual catches divergence**: SPEC says free tier = 1 board; code allows 3 (a "temporary" P4 relaxation that stuck) | Protocol: stop → reconciliation task to TODO top → SPEC updated *with* a DECISIONS line. Never let "the spec is old anyway" become ambient truth |
| W3 | `/improve` harvest: SESSION_LOG shows "Function 멱등 마커 누락" recurred twice | **Promotion ladder in action**: already a written rule (tier 1) → promoted to tier 2: code-reviewer instructions now explicitly verify idempotency markers on every Function diff. The system just taught itself |
| W4 | Firebase bill spikes — **D-0001's revisit trigger fires** (read-heavy voting at scale) | `/advise` with a structured brief → architect (Opus): **VERDICT approve-with-changes** — add caching/aggregation for hot collections; full migration *rejected* (risk × current stage). Logged as D-0014 |
| W6 | Mobile begins | Per guide 13: Expo, monorepo `packages/shared` (Zod schemas shared with web), platform-true UI. New work = new feature-level `/spec`, same machine |
| W8 | Map audit: 3-entry spot check → 2 stale → full `/map` pass | Map rot found by ritual, not by a lost afternoon |
| W9 | Near-miss: auto-compact hits mid-task | SessionStart hook re-injects PROGRESS/TODO from disk; the compacted summary disagreed on one task status — **disk wins**, zombie avoided. This is checkpoint-before-compact earning its keep |
| W12 | Inventory check | Still: 9 docs files, 14 commands, 5 hook scripts. Nothing was replaced since Act 1 — the same files simply carry more weight (guide 07's scaling table, lived) |

**What defines this scale**: ritual compliance *is* survival — drift checks at boundaries, audits on cadence, `/improve` as a habit, and the test suite as the only memory that never compacts.

---

## Closing observations across all three acts

1. **The golden path never changed** — `/setup → /spec → /blueprint → /next → /inspect → /checkpoint` at every scale; only round counts, phase counts, and ritual frequency moved.
2. **Skipping was always audible** — BACKLOG and DECISIONS hold every omission; silence was the only forbidden move.
3. **The invariants never bent**: deny-by-default security, untouchable secrets, honest task states — identical in a weekend prototype and a months-old product.
4. **Each scale's hero differs**: Act 1 — explicit omission; Act 2 — recorded decisions + independent review; Act 3 — rituals + self-improving enforcement. Same system, three gears.
> 🇰🇷 결론: 규모 전환에 "이제 진짜 시스템으로 갈아타기" 절벽이 없다. 주말 프로토의 파일들이 그대로 수개월짜리 제품의 파일이 된다 — 무게만 실릴 뿐.
