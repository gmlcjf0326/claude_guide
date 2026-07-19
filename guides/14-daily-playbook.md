# 14 — Daily Playbook: How to Actually Drive COMPASS
> 🇰🇷 실전 운전 가이드. "코딩할 때 뭘 쳐야 하지?"의 답 — 명령은 뼈대, 대화는 근육이다. 하루 20+ 프롬프트 중 명령은 2~3개뿐이고, 나머지는 짧은 자연어면 충분하다.

## 1. The one mental model

Commands are **joints**; conversation is **muscle**. A 20-prompt feature day breaks down as roughly: 3 commands (`/spec` `/next` `/checkpoint`) + 6 short answers to interview/blueprint questions + 8 natural reactions while building + 2 corrections or `/remember`. Only the first `/spec` message deserves careful writing (goal·context·constraints·unknowns). Everything else, shorter is better — "A", "승인", "진행", and a pasted error log are all first-class prompts, because the *system* carries the structure so your prompts don't have to.
> 🇰🇷 정성 들일 프롬프트는 /spec의 첫 문제 설명 하나. 나머지는 짧을수록 좋다.

## 2. The session rhythm

```
OPEN   just start typing — the hook already injected PROJECT/PROGRESS/TODO
       ("계속하자" or /restore for the deep restore)
LOOP   /next → Claude builds + shows proof → you react in plain language → repeat
MID    context ~60% → /checkpoint → /compact (focused)
CLOSE  /checkpoint  (the stop-gate hook won't let you leave [~] tasks dangling anyway)
```

## 3. Situation → what to type (the cheat sheet)

Korean prompt text below is example input — drive COMPASS in YOUR language; the system carries the structure either way.

| Situation · 상황 | You type · 입력 |
|---|---|
| New feature/product, half-day+ · 새 기능/제품 | `/spec goal·context·constraints·unknowns` (`/spec 목표·상황·제약·모르는 것`) |
| A few-hours middle-sized task · 몇 시간짜리 작업 | Just describe it + "put 2–3 acceptance bullets on the TODO and go" · "TODO에 완료기준 2~3개 적고 진행해" (medium path — no SPEC document) |
| The next planned task · 계획된 다음 작업 | `/next` (or just "do the next one" · "다음 거 하자") |
| A bug · 버그 | Paste the error/log verbatim — a repro test is demanded first · 에러/로그 그대로 붙여넣기 |
| Trivial fix · 사소한 수정 | Just say it ("fix the header typo" · "헤더 오타 고쳐줘") — states 4→6 only |
| Don't like the result · 결과 불만족 | Immediately, with the reason: "no — newest-first must be the default; users come to find TODAY's document" |
| Verify a claim Claude made · 주장 검증 | "show me the raw test output" / "how many lines is that file NOW?" |
| Hard design question · 설계 고민 | `/advise <question>` (summons the architect) |
| Good idea, not now · 지금은 아닌 아이디어 | "park it in BACKLOG" · "BACKLOG에 넣어둬" |
| A rule to keep forever · 영구 지침 | `/remember <directive>` |
| Codebase feels heavy · 코드가 답답함 | `/improve` |
| Something behaves oddly · 오동작 의심 | `/healthcheck` |
| Session end / before compact · 세션 끝 | `/checkpoint` |

## 4. Worked session A — feature day one (13 prompts, annotated)

Existing project (문서 검색 SaaS, /setup 완료 상태). Today's goal: CSV export.

| # | You type | What happens / why this works |
|---|---|---|
| 1 | `오늘은 검색 결과 CSV 내보내기 만들자. /spec 검색 결과를 CSV로 내보내기. 팀 고객들이 보고용으로 요청함. 결과가 수천 건일 수 있음.` | 목표+맥락 두 줄이면 충분 — 나머지는 인터뷰가 캔다 |
| 2 | `1-A, 2-B(최대 1만 행), 3은 잘 모르겠으니 추천해줘, 4-A, 5: 한글 깨지면 절대 안 됨` | 선택지형 질문엔 기호로 답하고, 모르는 건 모른다고 — 추천을 시키면 된다 |
| 3 | `전부 A로. 그리고 엑셀에서 바로 열리는 게 제일 중요해` | 2라운드 답 + 진짜 우선순위 한 줄 추가 (이 한 줄이 SPEC의 quality bar가 된다) |
| 4 | `승인. /blueprint` | 신뢰도 ≥90% 도달, SPEC 요약 확인 후 서명 — 한 단어면 된다 |
| 5 | `C로 가되 1만 행 제한 유지. 결정 기록해줘` | 옵션 A(동기)/B(백그라운드 잡)/C(제한부 동기) 중 선택 → DECISIONS에 남는다 |
| 6 | `/next` | T-101 시작 — [~] 마킹, 완료기준 재진술, 구현, 게이트 실행까지 자동 |
| 7 | `BOM 처리 확실해? 한글 들어간 테스트 케이스 출력 보여줘` | **증거 요구** — "될 겁니다"를 허용하지 않는 게 당신의 일 |
| 8 | `좋다. /next` | 다음 작업(T-102, 내보내기 버튼 UI) |
| 9 | `버튼은 결과 헤더 오른쪽 끝으로. 아이콘만 말고 라벨도` | 자연어 코스보정 — design.md 규칙이 상태(hover/disabled)를 챙긴다 |
| 10 | `/inspect` | code-reviewer 서브에이전트가 diff를 계획·DoD 대비 검사 |
| 11 | `수정 확인. empty state 문구는 "내보낼 결과가 없습니다"로` | 리뷰 FAIL(에러 상태 미처리) → 수정 → PASS 후 디테일 지시 |
| 12 | `/remember CSV류 내보내기는 항상 UTF-8 BOM 포함` | 오늘 배운 것을 영구화 — 다음 달의 나를 위한 3초 |
| 13 | `/checkpoint` | TODO 정직화 + PROGRESS + 커밋/푸시 + "내일: T-103부터" 라인 |

## 5. Worked session B — continuation day (9 prompts)

| # | You type | What happens |
|---|---|---|
| 1 | `계속하자` | 훅이 이미 주입한 상태 기반으로 요약 + T-103 제안 (아무 설명 필요 없음) |
| 2 | `ㄱㄱ` | 이것도 유효한 프롬프트다 — /next와 동일하게 동작 |
| 3 | `이거 떠: [스택트레이스 붙여넣기]` | 버그 프로토콜: 실패 재현 테스트 먼저 → 수정 → 통과 |
| 4 | `통과 로그 보여줘` | 증거 확인 습관 |
| 5 | `아까 export/service.ts 300줄 경고 떴지? 지금 쪼개` | 훅의 비대화 경고에 반응 — bloat-guard 분할 프로토콜 실행 |
| 6 | `/advise PDF 내보내기까지 확장할지 고민이야. 고객 2팀이 물어봤어` | Opus architect 소환 — 판정/리스크/대안 형식으로 회신 |
| 7 | `보류가 맞네. BACKLOG에 근거랑 같이 넣어둬` | 아이디어 주차 — 스코프 크리프 방지 |
| 8 | `/checkpoint 하고 /compact` | 컨텍스트 60% 부근 — 체크포인트 먼저, 압축은 그 다음 (순서가 생명) |
| 9 | *(계속 작업하거나)* `/checkpoint` | 마무리 |

**Count**: 22 prompts across two days. Commands: 10. Everything else: plain, short, human.

## 6. Where YOUR attention actually matters (the 3 leverage points)

The system automates diligence, not judgment. Spend your focus here and skim everywhere else:
1. **Plan approval (session A, #4–5)** — 2 minutes reading the options honestly beats 2 hours of rework. This is the highest-leverage read of your day.
2. **Proof inspection at critical paths** — money, auth, data deletion: read the actual diff and test output yourself, not the summary.
3. **Checkpoint honesty** — glance at TODO statuses before ending; a `[x]` you don't believe is a debt with interest.

## 7. Anti-patterns (each one observed in the wild)

| Anti-pattern | Why it hurts | Instead |
|---|---|---|
| Typing every prompt as a command · 모든 프롬프트를 명령어로 | Commands are joints, nothing more — you get rigid and slow · 경직되고 느려진다 | React in natural language during the loop · 루프 중엔 자연어로 |
| "Whatever you think" in the interview · 인터뷰에 "알아서 해줘" | Garbage input → a beautifully built wrong thing · 엉뚱한 것을 훌륭하게 만든다 | If unsure, "I don't know — recommend" IS a valid answer · "모르니 추천해줘" |
| Marathon without checkpoints · 체크포인트 없는 마라톤 | One compaction can vaporize an afternoon · compact 한 번에 오후 증발 | The 60% rule + per-task state updates (automatic) |
| "Next" without proof · 증거 없이 "다음" | Unverified optimism is the most expensive bug · 미검증 낙관이 최고가 버그 | Make "show me the output" a reflex · "출력 보여줘" 입버릇 |
| Tolerating a bad result for 3 turns · 불만족을 3턴 참기 | Later feedback = more code to unwind · 늦을수록 되돌릴 게 많다 | Correct immediately, with the reason · 즉시, 이유와 함께 |
| Leaving lessons only in chat · 배움을 대화에만 | Compaction erases them · compact가 지운다 | 3 seconds of `/remember` |

## 8. How your usage evolves

**Week 1**: follow the golden path literally; expect hook nags (bloat, stop-gate) — they're calibrating you as much as the agent. **Week 2–4**: your prompts get shorter; `/improve` after the first milestone tunes budgets and prunes rules that never fire. **Month 2+**: the system is invisible — you talk, it structures; the only ceremony left is the one that saves you: `/checkpoint`. If it ever feels heavy instead of invisible, that friction is `/improve` input, not a reason to abandon ship.
> 🇰🇷 성숙의 신호: 시스템이 보이지 않게 되는 것. 무겁게 느껴지면 그 마찰 자체가 /improve의 입력이다.
