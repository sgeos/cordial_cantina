# Reverse Prompt

> **Navigation**: [Process](./README.md) | [Documentation Root](../README.md)

This file is the AI-to-human communication channel. It is overwritten after each completed task.

---

## Last Updated

**Date**: 2026-02-02
**Task**: M6 Foundation Stubs complete
**Milestone**: M6 Foundation Stubs

---

## Verification

### M6-T1: Add header to MASTER_CLAUDE_MD_REFERENCE.md
**Result**: PASS - Navigation header and usage notes added

### M6-T2: Update docs/reference/README.md
**Result**: PASS - MASTER_CLAUDE_MD_REFERENCE.md listed in ToC

### M6-T3: Create joltshark README.md
**Result**: PASS - Minimal README created

### M6-T4: Fix CI workflow
**Command**: `grep rust-toolchain .github/workflows/ci.yml`
**Result**: PASS - Changed `dtolnay/rust-action` to `dtolnay/rust-toolchain`

### M6-T5: Create root .gitignore
**Result**: PASS - Created with erl_crash.dump exclusion

### M6-T6: Delete erl_crash.dump
**Result**: PASS - File removed

### M6-T7: Create nif Rust subproject
**Result**: PASS - `cordial_cantina/native/nif/` created with Cargo.toml

### M6-T8: Implement nop() NIF function
**Result**: PASS - Function compiles with rustler 0.37

### M6-T9: Integrate NIF with Phoenix
**Result**: PASS - `[info] NIF loaded successfully` on startup

### M6-T10: Stub LiveView
**Result**: PASS - `/dashboard` returns 200, shows NIF status

### M6-T11: Verify with mix precommit
**Command**: `cd cordial_cantina && mix precommit`
**Result**: PASS - 5 tests, 0 failures

### M6-T12: Update REVERSE_PROMPT.md
**Result**: This file

### M6-T13: Commit all changes
**Status**: PENDING

---

## Files Created/Modified

**Created**:
- `.gitignore` - Root gitignore with erl_crash.dump exclusion
- `joltshark/README.md` - Minimal joltshark documentation
- `cordial_cantina/native/nif/Cargo.toml` - NIF crate configuration
- `cordial_cantina/native/nif/src/lib.rs` - NIF implementation with nop()
- `cordial_cantina/lib/cordial_cantina/nif.ex` - Elixir NIF module
- `cordial_cantina/lib/cordial_cantina_web/live/dashboard_live.ex` - LiveView dashboard

**Modified**:
- `docs/reference/MASTER_CLAUDE_MD_REFERENCE.md` - Added header and usage notes
- `docs/reference/README.md` - Added MASTER_CLAUDE_MD_REFERENCE.md to ToC
- `.github/workflows/ci.yml` - Fixed Rust action name
- `cordial_cantina/mix.exs` - Added rustler dependency
- `cordial_cantina/lib/cordial_cantina/application.ex` - Call nop() on startup
- `cordial_cantina/lib/cordial_cantina_web/router.ex` - Added /dashboard route
- `README.md` - Updated joltshark link

**Deleted**:
- `erl_crash.dump`

---

## erl_crash.dump Analysis

**Cause**: The crash occurred during shell initialization when Elixir attempted to print its version to standard_io. The IO channel was terminated before the print completed. This is a transient issue from running scripts in subshell contexts, not an application bug.

**Slogan**: `Runtime terminating during boot ({terminated,[{io,put_chars,[standard_io,...`

**Resolution**:
1. Added `erl_crash.dump` to root `.gitignore`
2. The crash is not reproducible in normal application startup
3. No code changes required

---

## CI Status

The CI workflow has been fixed:
- **Before**: `dtolnay/rust-action@stable` (repository not found)
- **After**: `dtolnay/rust-toolchain@stable` (correct action)

The workflow should now pass on GitHub. The Rust job will run:
- `cargo fmt --check`
- `cargo clippy -- -D warnings`
- `cargo test`

**Note**: joltshark uses `edition = "2024"` which requires Rust 1.85+. The `dtolnay/rust-toolchain@stable` action should provide a sufficiently recent toolchain on GitHub runners.

---

## Questions for Human Pilot

1. **Process definition status**: The bi-directional prompting workflow is functional. Is the process definition macro-milestone complete, or are there additional elements needed?

2. **Next direction**: Options for next milestone:
   - Option A: Resolve Phase 1 blocking decisions (P1-P7 in `decisions/PRIORITY.md`)
   - Option B: Continue process refinement
   - Option C: Other direction

---

## Technical Concerns / Risks

**Rust edition 2024**: The joltshark crate uses `edition = "2024"`. This is the latest Rust edition and requires Rust 1.85+. Local development should be fine with a recent toolchain, but verify CI runners have compatible versions.

**NIF loading in tests**: The NIF is currently loaded in the Application startup. If tests need to run without the NIF, consider conditional loading.

---

## Suggestions for Improvement

1. **NIF test**: Add an Elixir test that explicitly calls `CordialCantina.Nif.nop()` to verify NIF loading in the test suite.

2. **LiveView real-time**: The dashboard is a static stub. Future phases should add Phoenix PubSub for real-time updates.

3. **CI NIF build**: Consider adding the NIF build to CI. Currently CI only runs `mix precommit` which builds the NIF, but explicit verification would be clearer.

---

## Intended Next Step

**Awaiting human direction** on next milestone.

All M6 Foundation Stubs tasks (M6-T1 through M6-T12) are complete. M6-T13 (commit) pending.

---

## Session Context

If you are a new AI session reading this file:

1. Read [MILESTONE.md](./MILESTONE.md) - M6 Foundation Stubs complete (pending commit)
2. Read [PROMPT_BACKLOG.md](./PROMPT_BACKLOG.md) - B3, B5, B6 open
3. Check [decisions/PRIORITY.md](../decisions/PRIORITY.md) - 7 blocking items for Phase 1
4. Macro-milestone: Process definition (status TBD)
5. Wait for human prompt before proceeding
