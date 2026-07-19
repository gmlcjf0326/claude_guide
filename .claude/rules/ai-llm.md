---
paths:
  - "**/ai/**"
  - "**/llm/**"
  - "**/prompts/**"
  - "**/*prompt*"
---

# AI / LLM Integration Rules
> 🇰🇷 LLM API 연동 코드 작업 시 자동 적용.

## One boundary module
- ALL model calls go through a single client wrapper (`features/ai/client.ts` or equivalent). It owns: timeouts, retries with exponential backoff + jitter (retry on 429/5xx/timeouts only), a model-fallback chain, and per-call token/cost/latency logging. No raw SDK calls scattered in features.

## Treat model output as untrusted input
- Schema-validate EVERY structured response (Zod / Pydantic) before it touches business logic; on validation failure, retry with the error appended, then fail explicitly. Never `JSON.parse` and hope.
- Free-text output that reaches HTML gets escaped/sanitized like user input.
- Tool-using agents: allowlist tools narrowly; treat retrieved/external content as potentially adversarial (prompt injection) — never let fetched text directly authorize actions.

## Prompts are code
- Prompts live in versioned files (`prompts/<name>.md` or constants module), never inline string soup — they get code review and diffs like everything else.
- Pin model IDs explicitly in config; a silent model upgrade is a silent behavior change.
- Keep a small golden test set (input → expected properties, not exact strings) and run it when a prompt or model changes.

## Cost & safety
- Log tokens per call; alarm on anomalies. Cache stable prompt prefixes / responses where the provider supports it.
- Never send secrets or raw PII in prompts; redact before logging prompt/response pairs.
- Every LLM feature has a defined degraded mode (timeout → fallback message/path), because the API WILL have a bad day.
