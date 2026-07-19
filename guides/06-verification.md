# 06 — Verification: Nothing Is Done Until Proven
> 🇰🇷 검증 게이트와 증거 기반 완료 보고 — "될 겁니다"를 금지하는 장치들.

The checklist lives in the `definition-of-done` skill. This guide covers strategy.

## Give the agent a way to verify itself

The single highest-leverage practice in agentic coding: a fast command that answers PASS/FAIL. An agent with `pnpm test` in reach converges; an agent without it guesses confidently. Every project should expose, early:

| Stack | Gates (run all before "done") |
|---|---|
| TS/Node | `pnpm lint` · `tsc --noEmit` (or `pnpm typecheck`) · `pnpm test` |
| Rust | `cargo clippy --all-targets -- -D warnings` · `cargo test` |
| Python | `ruff check .` · `pytest -q` |
| Supabase | migrations apply on shadow DB · RLS policy tests |

If the repo lacks a gate, *creating it is an early task*, not a someday wish — it repays itself within the same session.

## Test-first, when it earns its keep

TDD shines with agents on: bug fixes (failing test first is the proof you understood the bug), pure logic (parsers, pricing, ranking), and boundary contracts (API shapes, Tauri IPC). It's ceremony on: exploratory UI and throwaway spikes — say so and skip honestly. The asymmetric rule that always holds: **every bug fix ships with the regression test that would have caught it.**

## The independent reviewer

Self-review has a blind spot: the author's context contains the *intent*, so the eyes autocomplete what the code should say. The `code-reviewer` subagent starts with zero attachment — fresh context, reading only the diff, the plan, and the DoD — which is precisely why `/inspect` routes through it instead of asking the main agent "are you sure?". Treat its FAIL as non-negotiable: fix, or prove the finding false.
> 🇰🇷 작성자는 '의도'가 눈을 가린다. 그래서 리뷰는 맥락 없는 새 에이전트가 한다.

## Proof-of-work reporting

Completion reports contain evidence, not adjectives: the exact gate commands run and their final output lines pasted. Two red-flag phrases that must never appear: "tests should pass" (run them) and "I've verified" without output (show it). This norm costs ten seconds and eliminates the most expensive failure class in agent work: confident unverified claims.
