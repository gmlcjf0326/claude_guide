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

**This repo IS a marketplace** — `.claude-plugin/marketplace.json` + `plugin.json` ship at the root. The plugin is deliberately an *installer*, not the runtime: plugins cannot carry CLAUDE.md, `.claude/rules/`, permissions, or the statusline, and plugin commands are always namespaced (`/compass:spec`, not `/spec`) — so COMPASS runs project-level, and the plugin's single command `/compass:init` installs or safely upgrades that project layer (docs/ and project-directives.md always preserved; both install traps eliminated). Install flow:

```
/plugin marketplace add <owner>/<this-repo>
/plugin install compass@compass
/compass:init          ← inside your project; restart claude afterwards
```

Upgrades: `/plugin update compass` → `/compass:init` again. The copy-the-zip install (Mode A) remains fully supported and versions *with each project*.
> 🇰🇷 이 저장소 자체가 마켓플레이스다. 플러그인은 런타임이 아니라 '설치기' — /compass:init 한 번이면 zip 복사의 두 함정(숨김폴더 누락·업그레이드 덮어쓰기)이 사라진다.
