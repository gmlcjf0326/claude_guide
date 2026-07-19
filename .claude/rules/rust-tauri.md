---
paths:
  - "**/*.rs"
  - "src-tauri/**"
---

# Rust / Tauri Rules
> 🇰🇷 Rust 및 Tauri 데스크톱 작업 시 자동 적용.

## Tauri commands — the checklist that prevents the classic silent failure
1. `#[tauri::command]` functions stay THIN: parse args → call a service function → map the result. Logic lives in `features/<name>/service.rs`, not in the command.
2. **Every new command MUST be added to `tauri::generate_handler![...]`** in the builder. There is no compile-time check — an unregistered command fails only at runtime with a vague frontend error. Registering is part of the task, not a follow-up.
3. Commands return `Result<T, AppError>` where `AppError` implements `Serialize` (via `thiserror` + a manual/derived Serialize). Never `unwrap()`/`expect()` in command paths — convert to errors the frontend can render.
4. Long or blocking work: `async fn` + `tokio::task::spawn_blocking` for CPU/IO-heavy sections. A blocked command freezes the UI thread's IPC.

## State & events
- Shared state: `tauri::Builder::manage(...)` + `State<'_, Mutex<T>>` (or `RwLock`). Accessing unmanaged state panics at runtime — manage first, always.
- Backend → frontend push: emit events with typed, versioned payload structs; frontend treats payloads as untrusted input (validate).

## Security
- Tauri 2 capabilities/ACL: grant the MINIMUM permissions per window; never wildcard the fs/shell scopes.
- Any path from the frontend is hostile: canonicalize and verify it stays inside the allowed root before touching the filesystem.

## Code health
- `cargo clippy --all-targets -- -D warnings` and `cargo fmt` must pass — clippy warnings are errors here.
- Errors: `thiserror` for library/feature error enums; `anyhow` only at the outermost binary edge.
- Module per feature (`features/billing/mod.rs`); no `util.rs` landfill.
- Prefer borrowing; `clone()` needs a reason you could say out loud.
- Tests: unit tests in-module (`#[cfg(test)]`), integration tests in `tests/`. The IPC boundary (command in → JSON out) deserves integration tests most.
