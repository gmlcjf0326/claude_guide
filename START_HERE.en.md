# START HERE — the complete beginner's guide
> Follow this one document and COMPASS will feel natural within 30 minutes. No expert knowledge required.
> (Experienced users can jump straight to README.md. 한국어판: `START_HERE.md`)

## 1. What is this? (3-line summary)

Claude Code is smart, but it **resets its memory every session, half-guesses your requirements, and says "done" without verifying**. COMPASS is an operating system that blocks those failure modes — it scores its own understanding before coding (/spec), compares options on the record (/blueprint), refuses to call work done without verification (/inspect), and keeps all state on disk so **months-long projects survive across sessions**.

## 2. Honest pros and cons — know before you adopt

| Angle | You gain | You pay |
|---|---|---|
| Quality | Wrong deliverables, unverified "done", and security accidents are structurally blocked | A few extra minutes per task passing gates |
| Long-haul | Any new session resumes in under 2 minutes (1M+-token projects become feasible) | The /checkpoint habit (hooks help enforce it) |
| Tokens | Rules load only when their files are touched (unused stacks = 0) | ~1.5–2.5K tokens of always-on overhead per session (estimate) |
| Learning | Five commands are enough to start | The first week can feel slower — that's normal |
| Autonomy | The system proactively suggests the next move | Occasionally feels naggy (how to tune it: §8) |

**Honest conclusion**: overkill for a half-day throwaway script. But if you have even one "project I abandoned halfway", the first week's learning cost pays back in week two.

## 3. Prerequisites

- [ ] Claude Code v2.x installed (check with `claude --version`)
- [ ] macOS/Linux work as-is · **Windows requires WSL or Git Bash** (the hooks are bash)
- [ ] git available
- [ ] (Optional) A plan with Opus access — works fine without it, see §6

## 4. Install — 5 minutes (⚠️ mind trap #1)

```bash
# 1) After unzipping, from inside your project folder:
cp -r /path/to/COMPASS/. .        # ← the trailing ". ." matters!
```

> ⚠️ **The most common install accident**: `.claude` is a **hidden folder** — drag-copying in Finder/Explorer silently skips it, and then hooks, commands, and rules are all dead. The `cp -r source/. target` form (with the dot) copies hidden files too. On Windows CMD: `xcopy \path\COMPASS . /E /H /Y`

```bash
# 2) Verify — you must see both of these:
ls -a          # is .claude AND CLAUDE.md in the listing?

# 3) git init (skip if already a repo)
git init && git add -A && git commit -m "chore: install COMPASS"
```

Add to `.gitignore`: `.claude/settings.local.json` / `.claude/secrets.unlock` / `.env*` / `!.env.example`

## 5. First run — screens you'll see (don't panic)

Running `claude` for the first time may ask:

- **"Do you trust this project's settings (settings.json)?"** → Yes. (It's the COMPASS config you just installed.)
- **Hook execution approval** → Yes. (These are the safety mechanisms: auto-format, secret-file blocking, etc.)

On a healthy install, Claude's **first reply automatically contains a briefing** like:

```
This project isn't profiled yet — I suggest running /setup first.
```

If you see that, the install worked. If not, go to troubleshooting in §8.

## 6. The Opus model — turn it on if you have it, ignore it if you don't

The default distribution pins **no model**, so it runs unmodified on any plan (Pro included). If your plan has Opus, `/setup` asks once (step 3c) and turns on:

1. `templates/settings.local.json.example` → copied to `.claude/settings.local.json` (`opusplan`: Opus plans, Sonnet executes)
2. `.claude/agents/architect.md`: `model: inherit` → `model: opus`
3. (Optional) `model: opus` in the frontmatter of `.claude/commands/setup.md` · `spec.md` · `blueprint.md`

That list is also complete for manual enable/disable — audit with `grep -rn "model" .claude/`.

## 7. The 30-minute practice mission — learn by doing (strongly recommended)

Install into an empty practice folder, then follow along:

| Step | You type | Success looks like |
|---|---|---|
| 1 | `/setup` | 5–8 questions → answers fill `docs/PROJECT.md` |
| 2 | `/healthcheck` | A mostly-PASS checklist of hooks, commands, state files |
| 3 | `/spec a one-page about-me site with a visitor counter` | A few questions → "confidence 90%+" → SPEC summary → sign-off request |
| 4 | `approved. /blueprint` | Option comparison (or "only one sane path" declared) → PLAN·TODO created |
| 5 | `/next` | One task marked `[~]`, implemented, with verification output shown |
| 6 | `/checkpoint` | TODO tidied, commit, one line: "Next session: start with ~" |
| 7 | **Fully close the terminal**, run `claude` again | First reply summarizes progress + "continue with T-00X?" ← **this moment is why COMPASS exists** |

## 8. Common problems → fixes

| Symptom | Cause / fix |
|---|---|
| `/setup` isn't in the command list | `.claude` folder missing (§4 trap) — re-copy. Verify with `ls .claude/commands` (14 files) |
| Hooks do nothing (Windows) | You're in PowerShell/CMD — **run `claude` from WSL or Git Bash** |
| No session-start briefing | Run `/healthcheck` → checks hook registration. Also confirm `docs/` exists |
| Replies in the wrong language | Say it once, or `/remember All conversation in <your language>` — permanent afterwards |
| BLOAT warnings feel naggy | Set `COMPASS_BLOAT_SOFT`/`COMPASS_BLOAT_HARD` in `.claude/compass.conf`, or delete that hook block |
| "in-progress task" blocks exit | Working as intended (stop-gate). Resolve the TODO `[~]` to `[x]` or `[!]reason`, or checkpoint |
| Worried about missing `jq` | Works without it (grep fallbacks built in). Installing it just adds robustness |
| Refuses to write test keys into .env | Locked by default. One `/secrets on` opens it (run `/secrets off` after) |

## 9. Learning roadmap — do NOT read everything at once

- **Today**: this document + the practice mission. Done.
- **First week**: only `guides/14-daily-playbook.md` (22 real prompts — what to actually type).
- **When needed**: long project → guide 07 · Docker → 08 · app monetization → 13 · Korean public sector → 16. The rest is a reference shelf.
- **When unsure, just ask**: "what should I do now?" — routing is the system's job.

## 10. Upgrading and removing (⚠️ trap #2)

**Upgrading** — when a new version arrives, **never overwrite wholesale.** This is your data:

```
KEEP (never overwrite):   all of docs/ · .claude/rules/project-directives.md
REPLACE (with new):       CLAUDE.md · guides/ · templates/ · the rest of .claude/
```

```bash
# Safe upgrade (portable — works in Git Bash too, no rsync needed)
cp .claude/rules/project-directives.md /tmp/pd.bak
cp -r newversion/COMPASS/guides ./ && cp newversion/COMPASS/CLAUDE.md ./
cp -r newversion/COMPASS/templates ./
cp -r newversion/COMPASS/.claude/. .claude/
cp /tmp/pd.bak .claude/rules/project-directives.md
```

**Removing** — delete `CLAUDE.md`, `.claude/`, `guides/`, `templates/` and you're back to stock. Keep `docs/` — it's your project's record.

## 11. Command card (pin it next to your monitor)

```
/setup       once per project — charter+directives   /restore     deep restore from disk
/spec goal   interview on what to build (no code)    /map         build/refresh the code index
/blueprint   compare options → plan+TODO             /advise q    summon the architect
/next        run ONE next task + verify              /remember    persist a directive forever
/inspect     independent review must PASS            /improve     top-3 improvement proposals
/checkpoint  save-game (end of session, pre-compact) /research t  research → permanent notes
/healthcheck install self-diagnosis                  /secrets on  unlock .env for test keys        stuck? just ask: "what now?"
```

**No memorizing required** — speak naturally and the system invokes the right command itself ("let's do the next one", "save and wrap up" are enough). For recurring requests, try: `make a /morning command for my daily routine` — commands can be created conversationally (/healthcheck watches for built-in name collisions).

Happy building. Friction points aren't bugs — they're input for `/improve`. That's the system fitting itself to you.
