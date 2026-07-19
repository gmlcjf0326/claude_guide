# COMPASS User Manual (v1.16.0 · the complete one-page summary)
> This one document covers how to use the entire system — the manual you keep open while working.
> Onboarding: `START_HERE.en.md` · deep rationale: `guides/00–16` · this file is all of the "how". 한국어판: `COMPASS-USAGE-GUIDE.md`

---

## 1. What it is (30 seconds)

COMPASS is an **agentic-coding operating system** that runs on top of Claude Code. It structurally blocks Claude Code's three weaknesses — ① guessing at requirements ② claiming "done" without verification ③ forgetting between sessions. One-line philosophy: **"Disk is truth, context is cache"** — all state lives in `docs/` files, and whatever a session, compaction, or crash erases is restored from disk.

---

## 2. Install (5 minutes) — only two traps

```bash
# From the project folder (the trailing ". ." copies hidden folders — that's the key!)
cp -r /path/to/COMPASS/. .
ls -a                      # success = .claude AND CLAUDE.md are visible
git init && git add -A && git commit -m "chore: install COMPASS"
```

- ⚠️ **Trap 1**: `.claude` is hidden — drag-copy skips it and half the system silently dies. Use the command above.
- ⚠️ **Trap 2 (upgrades)**: never overwrite wholesale. **Keep**: all of `docs/` + `.claude/rules/project-directives.md` (your data). **Replace**: everything else.
- `.gitignore`: `.claude/settings.local.json` / `.claude/secrets.unlock` / `.env*` / `!.env.example`
- Plugin-install alternative: `/plugin marketplace add <owner>/<repo>` → `/plugin install compass@compass` → `/compass:init` in your project (both traps auto-avoided — README Mode C).
- Opus is opt-in: the default ships model-neutral and runs on any plan. If you have Opus, `/setup` (3c) asks and enables `settings.local.json` (opusplan) + the model pins on `architect.md`·`setup.md`·`spec.md`·`blueprint.md`.

---

## 3. Day-0 startup order

```
run claude → /effort max → /setup → /healthcheck → /spec first-goal
```

- `/setup` (once per project): a 5–8-question interview writes the **project charter** (docs/PROJECT.md) — stage, business model, quality bias, non-negotiables. Permanent directives you answer here land in project-directives.md and load forever. Have prior research? Drop it in `docs/inputs/` first — it reads everything and skips questions your documents already answer.
- `/healthcheck`: self-diagnoses hooks, all 14 commands, state files, and gates. Whenever anything feels off, start here.

---

## 4. The golden path — the skeleton of all work

```
/spec goal  →  /blueprint  →  /next (repeat)  →  /inspect  →  /checkpoint
 understand 90%+   compare options   one task at a time   independent review   save+commit
```

Internal state machine: RESUME → UNDERSTAND (≥90% confidence gate) → OPTIONS → PLAN → BUILD → VERIFY → CHECKPOINT. Not skipping gates is the entire discipline.

**Scaling down** — trivial fixes (typo, one-liner): just say it (states 4→6 only). A few hours of work: skip the SPEC document, "put 2–3 acceptance bullets on the TODO and go". Experiments: `[spike]` tag, throw the code away, keep the learning in DECISIONS.

---

## 5. Complete 14-command reference

| Command | When | What it does |
|---|---|---|
| `/setup` | once per project · after a pivot | Charter + permanent directives + tailoring. Ingests inputs/ |
| `/spec goal` | new work ≥ half a day | Interview (3–5 questions/round, A/B/C choices) → 90% confidence → SPEC. **No code** |
| `/blueprint` | deciding how | Per decision: efficient/impactful/balanced compared → PLAN+TODO. Architect consulted on irreversibles |
| `/next` | the next planned piece | ONE task: mark `[~]` → build → gates → `[x]` → state updated. Your most-used command |
| `/inspect` | right before "it's done" | Fresh-eyes reviewer judges the diff vs plan & DoD: PASS/FAIL. FAIL is non-negotiable |
| `/checkpoint` | session end · **always before compact/clear** | Honest TODO + PROGRESS + commit + push + "next: ~" |
| `/restore` | resuming · after time away | Deep restore from disk + git cross-check + map freshness |
| `/map` | when code is hard to find | Builds/refreshes the decision-level index (CODEBASE_MAP) |
| `/advise q` | design crossroads | Architect: verdict / risks / missed alternatives |
| `/remember x` | a rule worth keeping forever | Classifies it and writes it to the right permanent home |
| `/improve` | milestones · frustration | Top-3 improvements as options. Recurring mistakes promoted to rules/hooks |
| `/research t` | freshness or evidence needed | Source-ladder research → saved to `docs/research/` forever |
| `/secrets on\|off` | handling test keys | Unlock/relock .env (§10) |
| `/healthcheck` | something feels wrong | Full install self-diagnosis + command-shadow detection |

> **No memorizing**: "do the next one" ≈ /next, "save and wrap up" ≈ /checkpoint — natural language triggers the right command. Stuck? Ask: "what should I do now?"

---

## 6. The daily rhythm (anatomy of ~20 prompts)

```
Open:   just start — the co-pilot injects state and proposes the next move
Loop:   /next → [Claude works + shows proof] → natural-language feedback ("good" / "button goes right" / paste the error)
Middle: ~60% context or a counter warning → /checkpoint → /compact
Close:  /checkpoint  (phase finished? → /clear for a fresh next session)
```

A typical 20-prompt day = 3 commands + 7 interview answers ("1-A, recommend on 2") + 8 natural reactions + 2 corrections. **The only prompt worth crafting is the first /spec message** — goal · context · constraints · honest unknowns. Your three attention leverage points: ① 2 minutes actually reading the options at plan approval ② personally checking diffs on money/auth/deletion paths ③ skimming TODO honesty at checkpoints.

---

## 7. What runs automatically (hands off)

**5 automatic mechanisms = 4 hooks + statusline (law — they run outside context; compaction can't erase them; `/hooks` shows the 4 hooks only)**
- guard-secrets: blocks secret-file access via file tools, Grep, AND shell commands (respects §10's unlock mode)
- post-edit: auto-format on save + bloat warnings (300/500 lines, configurable, growth-only for legacy files) + unprotected-work counter (checkpoint nudge every 25 edits)
- session-resume: injects charter·progress·open tasks every session + **exactly one suggested next move**
- stop-gate: blocks ending with abandoned `[~]` tasks (resolve or checkpoint to pass; a clean git tree always passes)
- statusline: always-on terminal footer — `🧭 · phase · open/wip · edits (· UNLOCKED)`

**Rule auto-load**: TS/Rust/Python/Java/Postgres/serverless/AI/Docker/design rules load only when matching files are touched (unused = 0 tokens). Only your permanent directives (project-directives.md) always load.

---

## 8. The persistence layers — what survives

| Layer | Where | How it survives |
|---|---|---|
| Absolute rules | hooks (settings.json) | context-independent — always execute |
| Constitution · conventions · **directives** | CLAUDE.md · rules/ | re-read from disk every session |
| Project identity | docs/PROJECT.md | auto-injected by the start hook |
| Work state | docs/ files (SPEC·PLAN·TODO·PROGRESS·MAP·DECISIONS·LOG·BACKLOG) | refreshed at checkpoints, auto-injected |
| Research knowledge | docs/research/ | searched once, reused forever |
| ❌ promises made in chat | context only | **compaction erases them → promote with /remember** |

---

## 9. Long-project protocol (100K–1M+ tokens)

- **The 60% rule**: at ~60% context, `/checkpoint` → `/compact` (waiting for auto-compact means the summary is written from an already-degraded state). When the compacted memory and the disk disagree, **disk wins**.
- **Phase-per-session**: end of a phase = `/checkpoint` → `/clear` — fresh context + good docs beat a tired long history.
- **Drift ritual**: re-read the SPEC at every phase boundary → say one of match / update-spec / fix-code out loud. Only silence is forbidden.
- **Health metric = the Resume Test**: type just "continue" in a new session — does the right next action appear within 2 minutes?

---

## 10. Security — locked by default + test unlock

Default: `.env` and key files are blocked (hook-enforced across file tools, Grep, and shell commands). **When you paste test keys in chat**:

```
/secrets on   → verifies/patches .gitignore, then unlocks (🔓 shown in the session banner + statusline)
              → writes keys into .env — values are NEVER echoed back (confirmed by NAME only)
              → runs the test that needed the key to prove it works
/secrets off  → relock (left on 7+ days → /healthcheck calls it out)
```
Invariant in every mode: no value echoing · no committing env files · `.pem`/certificates/private keys permanently blocked.

---

## 11. Design work — without the "AI look"

- **Assets are part of the first task**: icons from a real set (lucide-react; no emoji-as-icon), a chosen webfont (Korean products → Pretendard Variable; recipe in guide 12 §7), images proto=picsum / production=downloaded+CREDITS.md. Enforcement is stage-gated: blocking at production quality bar, advisory for prototypes.
- **No inline styles** (efficiency principle): no per-tag `style=` — four honest exceptions (JS-computed values / CSS-variable injection / per-instance runtime values / compile-to-inline email targets). Structure: `tokens→base→components→utilities` + `@layer`.
- **Token starters**: general projects → `templates/design/tokens-neutral.css` (brand-neutral, all pairs contrast-verified); Korean public sector → `templates/design/tokens-krds.css` (measured, with the ≥50-grade ⇒ 4.5:1 magic-number rule). Per-client playbook: guide 16.
- Communicating taste: give 2–3 screenshots of screens you love with /spec — far higher bandwidth than words. To reproduce a screenshot: pixel color sampling → render → compare loop (Playwright MCP visual verification: guide 12 §6).

---

## 12. Making the system yours

- `/remember one-line` — permanently store today's lesson (the system classifies it).
- Recurring request → **promote to a command**: "make a /morning command for my daily routine" (/healthcheck watches for built-in collisions).
- Same mistake twice → `/improve` proposes the **promotion ladder** (observation → rule → checklist → hook) — the system learns itself.
- Thresholds: bloat 300/500 via `COMPASS_BLOAT_SOFT/HARD` in `.claude/compass.conf` (the /setup legacy question writes it for you); counter 25/50/75 in `post-edit.sh`. Dislike a hook? Delete its block in settings.json (the documented rule remains).

---

## 13. Troubleshooting, ultra-compressed

| Symptom | Fix |
|---|---|
| Command missing from the list | `.claude` not copied (§2 trap 1) or a new built-in collision → `/healthcheck` |
| Hooks unresponsive (Windows) | Run from WSL / Git Bash |
| Wrong reply language | `/remember All conversation in <language>` — once, permanent |
| Won't let me exit | Working as intended (stop-gate) — resolve the TODO `[~]` |
| .env access denied | Working as intended (locked by default) — for tests, `/secrets on` |
| Feels like it forgot something | `/restore` — disk is truth |

---

## 14. File map (one screen)

```
CLAUDE.md               constitution: state machine·12 rules·routing (loads every session)
START_HERE(.en).md      beginner onboarding / README.md full reference
.claude/
  settings.json         permissions·hook·statusline wiring   hooks/ 5 automatic mechanisms
  commands/ 14           skills/ 7 (interview·tradeoffs·map·bloat·long-horizon·DoD·research)
  agents/  architect(advisor)·code-reviewer·explorer
  rules/   stack auto-load + project-directives.md (always on — your permanent rules)
docs/                   ★ YOUR STATE — preserve on upgrades!
  PROJECT SPEC PLAN TODO PROGRESS CODEBASE_MAP DECISIONS SESSION_LOG BACKLOG
  inputs/ (drop zone for prior research)  research/ (permanent findings)
guides/00–16            deep rationale (07 long-horizon · 08 docker · 13 monetization · 14 playbook · 16 KRDS)
templates/              doc templates · docker/ · ci/ · design/ (neutral + KRDS tokens)
```

---

## 15. Honest limits (use with eyes open)

① Commands fire 100%; skill auto-triggering is probabilistic — call the command when you need certainty. ② Hooks guard the standard tool paths — "prettiness" itself can't be enforced; communicate taste with references. ③ Interview quality = input quality — "I don't know, recommend something" is a valid answer. ④ The first week feels slow — it pays back in the second.

**Summary of the summary**: `/setup` once → start with `/spec` → run on `/next` → end with `/checkpoint`. For everything else, say it naturally — the system knows. 🧭
