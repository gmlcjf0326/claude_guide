# 10 — Extensibility: Skills, Commands, Hooks, MCP, Plugins
> 🇰🇷 COMPASS를 확장하는 5개의 문 — 각각 언제 열고, 어떻게 만드는가.

## Which extension point for which job

| You want to add… | Use | Because |
|---|---|---|
| Procedural knowledge Claude should apply when relevant | **Skill** | auto-triggers by description; costs ~60 tokens idle |
| A workflow you invoke by name | **Command** | explicit `/name`, supports `$ARGUMENTS`, can pin a model |
| Something that must happen every time, no judgment | **Hook** | deterministic; prompts are requests, hooks are law |
| An external system (DB, browser, GitHub, docs) | **MCP server** | tools, not text; least-privilege credentials |
| A always-true fact/convention | **CLAUDE.md or a rule** | but spend the instruction budget reluctantly |

## Adding a skill (5 minutes)

```
.claude/skills/<name>/SKILL.md
---
name: <lowercase-hyphens>
description: <what it does AND when to trigger — be pushy: list the concrete situations, verbs, and file types that should activate it>
---
# Body: the procedure. Imperative voice. <500 lines. Link big references as separate files in the folder.
```
The description is the trigger mechanism — write it like a matching rule, not a summary. Test: ask for the task without naming the skill; it should fire.

## Adding a command

`.claude/commands/<name>.md` with frontmatter `description`, optional `argument-hint`, optional `model`. Body = the prompt; `$ARGUMENTS` interpolates. Keep commands thin: point at a skill for the heavy procedure (see how `/spec` delegates to `requirement-interview`).

## Adding a hook — with the safety rails

1. Script into `.claude/hooks/`, reading JSON from stdin; `chmod +x`.
2. Wire it in `settings.json` under the event (`PreToolUse`/`PostToolUse`/`Stop`/`SessionStart`…), with a `matcher` and a modest `timeout`.
3. Non-negotiable rails: **exit 2 blocks, exit 1 does not** (the classic footgun) · Stop hooks must honor `stop_hook_active` or they loop · degrade gracefully (tool missing → `exit 0`) — a broken hook poisons every session · never block Edit/Write mid-task for style issues (warn in PostToolUse instead).
4. Verify with `/hooks`, and test by piping sample JSON: `echo '{"tool_input":{"file_path":".env"}}' | bash .claude/hooks/guard-secrets.sh; echo $?`

## Connecting MCP servers

Project-shared config lives in `.mcp.json` (an example ships as `templates/.mcp.json.example` — copy to project root and edit). Useful starters: **context7** (live library docs — kills stale-API hallucinations), **github** (issues/PRs), **playwright** (browser control for E2E), plus official servers for Supabase/Postgres when you want the agent querying schema directly. Security posture: least-privilege tokens (read-only where possible), secrets via env not committed JSON, and only servers you trust — an MCP server runs with your credentials.

## Packaging COMPASS as a plugin (optional)

For one-command installs across many repos: create `.claude-plugin/plugin.json` (`{"name":"compass","version":"1.0.0"}`), move `commands/`, `agents/`, `skills/`, `hooks/` to the plugin root per the plugin spec, add a `marketplace.json`, push to a git repo, then `/plugin marketplace add you/compass` + `/plugin install compass`. For a solo dev the copy-into-project install this zip uses is simpler and versions *with each project* — package as a plugin only when repo count makes copying annoying.
> 🇰🇷 저장소가 5개를 넘어 복사가 귀찮아질 때 플러그인화하라. 그 전엔 프로젝트 동봉이 더 단순하다.
