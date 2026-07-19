---
paths:
  - "**/*.py"
---

# Python Rules
> 🇰🇷 Python 백엔드 작업 시 자동 적용.

## Toolchain
- Packaging & venv: **uv** (`uv add`, `uv sync`, `uv run`). Lockfile (`uv.lock`) committed.
- Lint + format: **ruff** (`ruff check`, `ruff format`) — the post-edit hook runs it automatically.
- Tests: **pytest**, files under `tests/` mirroring the package layout; fixtures over setup methods.

## Types & correctness
- Type hints on every public function signature; run pyright/mypy where configured.
- No mutable default arguments (`def f(items: list = [])` is a bug — use `None` + guard).
- `pathlib.Path` over string paths; context managers over manual open/close.
- Pydantic v2 models validate ALL external input (request bodies, env, files, LLM output) at the boundary; plain dataclasses for internal-only data.

## FastAPI shape (when used)
- One router per feature (`features/billing/router.py`), included from a thin `main.py`. No business logic in route functions — routes parse/validate → call service → shape response.
- Dependencies (`Depends`) for auth, db sessions, config — never module-level globals holding request state.
- Explicit response models; never return raw ORM/DB objects.

## Errors & logging
- Raise specific exceptions; translate to HTTP errors in ONE exception-handler layer, not per-route.
- Structured logging (key=value or JSON) to stdout; never `print` in library code; never log secrets or full PII payloads.
- Every `except:` names the exception type. Bare `except:` is forbidden.
