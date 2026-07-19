# 07 — Long Horizon: Building Beyond the Context Window (100K–1M+ tokens)
> 🇰🇷 이 가이드가 COMPASS의 존재 이유다. 컨텍스트 창(약 한나절 분량)을 아득히 넘는 프로젝트에서 에이전트가 무너지지 않게 하는 완전한 운영 체계.

## 1. The physics of the problem

A context window holds on the order of one working afternoon: some rules, some file contents, some conversation. A real product is *millions* of tokens of decisions, code, dead ends, and lessons — spread across weeks. No prompt, however clever, changes this arithmetic. Three forces make long sessions decay even before the window fills:

1. **Attrition** — compaction summarizes lossily; every `/compact` quietly deletes details you may need.
2. **Pollution** — old file contents, resolved errors, and dead-end explorations crowd out the signal; attention degrades well before 100% usage.
3. **Drift** — with the original goal far behind in the scroll, each local decision optimizes for the last few messages, and the sum walks away from the spec.

The conclusion is structural, not motivational: **long-horizon capability cannot live in the context. It must live on disk, with the context acting as a small, refreshable working set.**
> 🇰🇷 결론은 구조적이다: 장기전 능력은 컨텍스트가 아니라 디스크에 있어야 하고, 컨텍스트는 작은 작업 캐시로만 쓴다.

## 2. The five pillars

**P1 — Durable state.** Eight files in `docs/` carry everything a stranger needs: SPEC (why/what) · PLAN (how) · TODO (exactly where we are) · PROGRESS (dashboard) · CODEBASE_MAP (where things live) · DECISIONS (why things are the way they are) · SESSION_LOG (history) · BACKLOG (deferred). Together they answer the five questions any resumed session asks: *What are we building? How? Where are we? Why is it like this? What's next?*

**P2 — Checkpoints.** A checkpoint (= `/checkpoint`) is a synchronization barrier: disk state made honest + git commit. The invariant it maintains: *at any moment, losing the entire context costs at most the work since the last checkpoint.* Checkpoint at: task completion, phase end, session end, and ALWAYS immediately before `/compact` or `/clear`.

**P3 — Fresh context per phase.** Counterintuitive but consistently true: `/checkpoint` → `/clear` → `/restore` at a phase boundary *outperforms* pushing on in a long polluted session. A fresh session reading crisp docs has better attention than a tired one dragging 150K tokens of history. Marathon sessions are a smell, not a badge.

**P4 — Retrieval over recall.** Don't try to "remember" the codebase — that's what the map and the `explorer` subagent are for. The explorer spends *its* context reading widely and returns a distilled paragraph; your working set stays small. Corollary: in notes and PROGRESS, reference paths (`see src/features/billing/webhook.ts`) instead of pasting contents.

**P5 — Verification as memory.** Context forgets; test suites don't. A constraint enforced by a test ("webhook must be idempotent") survives every compaction, every `/clear`, every model change. This is why the DoD's "new behavior ⇒ new test" line is a *long-horizon* rule, not just a quality rule: you are writing memory that future sessions cannot lose.

## 3. Session lifecycle — the concrete rituals

### Opening (2 minutes)
The SessionStart hook already injected PROGRESS's tail and open TODO items. For real work sessions, run `/restore`: it re-reads the docs set, cross-checks `git log`/`git status` against the notes (disagreement = investigate first), spot-checks map freshness, and proposes the next task. Do not start coding from memory of "where we were" — memory may predate a compaction.

### During
- **Update state as you go** (Rule 4): `[~]` when starting, `[x]`/`[!]` when ending a task, 2–3 PROGRESS lines per task. A crash at minute 55 should cost 5 minutes.
- **Offload wide reading** to `explorer`; consult `docs/CODEBASE_MAP.md` before any search.
- **Watch context usage.** At ~60%: finish the current small step → `/checkpoint` → `/compact` with a focus prompt (below). Waiting for auto-compact (~80%+) means the summary is written from an already-degraded state.
- **One task at a time** (`/next`). Parallel half-finished tasks are how `[~]` zombies breed.

### Closing (3 minutes)
`/checkpoint`, ending with the spoken resume line: "Next session: /restore, then <task>." That one sentence, written while everything is loaded, is worth ten minutes of cold-start archaeology tomorrow.

## 4. Compaction playbook

```
/compact Focus on: the current task and its acceptance criteria, decisions made
this session and their reasons, files touched and why, and the immediate next
steps. Discard: full file contents already committed, exploration dead-ends,
resolved error messages, and anything already recorded in docs/.
```

- **Checkpoint first, always.** Compaction is lossy; the checkpoint is the lossless backup that makes the loss harmless.
- After compaction, the SessionStart hook re-injects PROGRESS/TODO from disk. If the compacted summary and the disk disagree, **disk wins** — the summary is a paraphrase; the files are the record.
- Never make an important decision in the messages *right after* a compaction without first glancing at SPEC/DECISIONS — that's the highest-amnesia moment in the whole lifecycle.
> 🇰🇷 압축 직후가 기억상실 최고위험 구간이다. 그 시점의 중요 결정은 반드시 SPEC/DECISIONS를 다시 보고 내린다.

## 5. Drift control

Drift is the silent killer of long projects: code and spec diverging one reasonable-looking commit at a time. The countermeasure is a fixed ritual at **every phase boundary**:

1. Re-read `docs/SPEC.md`, top to bottom (it's short by design).
2. Three verdicts: **aligned** → proceed · **spec outdated** (reality legitimately moved) → update SPEC + one line in DECISIONS saying why · **code drifted** → stop; add a reconciliation task to TODO *before* any new feature work.
3. Log the ritual's one-line outcome in SESSION_LOG ("drift check: aligned").

The discipline point: never let "the spec is old anyway" become ambient truth. Either the spec is the contract, or you update the contract — silence is the only forbidden option.

## 6. Scaling behavior — what changes at each order of magnitude

| Scale | Sessions | What the system adds |
|---|---|---|
| ~10K tokens (fix, script) | 1 | States 4–6 only; `docs/` optional |
| ~100K (real feature) | 1–3 | Full state machine; SPEC/PLAN/TODO live; map is born; checkpoint per session |
| ~500K (subsystem) | many | Phase-per-session; drift ritual; DECISIONS accumulating; /improve at milestones |
| **~1M+ (product)** | dozens | Everything above **plus**: map audits on a cadence, SESSION_LOG as the project's institutional memory, test suite treated as load-bearing memory, periodic `/improve` promoting recurring fixes into rules/hooks (guide 11) |

The pleasant surprise of this architecture: nothing is *replaced* as you scale — the same eight files and five commands simply carry more weight. There is no "now migrate to the serious system" cliff.

## 7. Failure modes → recovery

| Symptom | Root cause | Recovery | Prevention |
|---|---|---|---|
| Agent re-explains project from scratch each session | resume ritual skipped | `/restore` | SessionStart hook (already installed) |
| Mid-task decisions vanish after compaction | compact without checkpoint | git log + SESSION_LOG archaeology; re-decide, record in DECISIONS | checkpoint-before-compact, always |
| `[~]` zombies accumulating | statuses updated "later" | audit TODO now; each zombie → `[x]`, `[ ]`, or `[!]`+reason | stop-gate hook blocks dirty exits |
| Map points at moved/dead paths | Rule 6 skipped | `/map` full pass | same-commit contract; spot-checks in /restore |
| Rebuilt something that already existed | search before map | delete the duplicate, extend the original | map's "Where to add X"; explorer-first |
| Spec and product quietly diverged | phase boundaries without the ritual | reconciliation task, top of TODO | drift ritual, every boundary |
| CLAUDE.md rule repeatedly ignored | instruction budget exhausted / rule too soft | promote to a hook (guide 11's ladder) | keep CLAUDE.md lean; hooks for must-haves |

## 8. The metric that matters

Run the **Resume Test** occasionally: open a completely fresh session and say only "continue". If the agent reaches the correct next action within ~2 minutes using only `docs/` and git — the system is healthy at any scale. If it flounders, the failing pillar is usually visible immediately (stale PROGRESS, dishonest TODO, rotten map), and fixing *that file* is the highest-value work you can do that day.
> 🇰🇷 건강 진단은 하나면 충분하다: 새 세션에 "계속해"라고만 했을 때 2분 안에 올바른 다음 행동이 나오는가.
