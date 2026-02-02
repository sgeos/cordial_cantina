# Reverse Prompt

> **Navigation**: [Process](./README.md) | [Documentation Root](../README.md)

This file is the AI-to-human communication channel. It is overwritten after each completed task.

---

## Last Updated

**Date**: 2026-02-02
**Task**: M7 CI and LiveView complete
**Milestone**: M7 CI and LiveView

---

## Verification

### M7-T1: Fix joltshark clippy errors
**Command**: `cd joltshark && cargo clippy -- -D warnings`
**Result**: PASS - Fixed 3 clippy lints (needless_range_loop x2, collapsible_if)

### M7-T2: Add CI status badge to README
**Result**: PASS - Badge added to top of README.md

### M7-T3: Add Elixir NIF test
**Command**: `mix test test/cordial_cantina/nif_test.exs`
**Result**: PASS - Test verifies nop() returns :ok

### M7-T4: Add Rust NIF test
**Command**: `cd cordial_cantina/native/nif && cargo test`
**Result**: PASS - Test verifies joltshark is accessible

### M7-T5: Add NIF build to CI workflow
**Result**: PASS - Added Rust toolchain setup to Elixir job

### M7-T6: Add LiveView PubSub with datetime
**Result**: PASS - Dashboard shows real-time UTC time and tick count

### M7-T7: Remove Orbital Market Maker references
**Result**: PASS - Product name removed from 3 docs files, physics concepts retained

### M7-T8: Verify mix precommit
**Command**: `mix precommit`
**Result**: PASS - 6 tests, 0 failures

### M7-T9: Update REVERSE_PROMPT.md
**Result**: This file

### M7-T10: Commit all changes
**Status**: PENDING

---

## LiveView Dashboard

**URL**: http://localhost:4000/dashboard

The dashboard displays:
- **NIF Status**: Shows :ok when NIF is loaded (green text)
- **Phase**: 0 (Foundation)
- **Server Time (UTC)**: Real-time clock updated every second via PubSub
- **Tick Count**: Increments every second to verify live updates

To test:
```sh
cd cordial_cantina
mix phx.server
# Open http://localhost:4000/dashboard in browser
# Time and tick count should update every second
```

---

## Files Created/Modified

**Created**:
- `cordial_cantina/test/cordial_cantina/nif_test.exs` - Elixir NIF test

**Modified**:
- `joltshark/src/lib.rs` - Fixed 3 clippy lints
- `README.md` - Added CI status badge
- `.github/workflows/ci.yml` - Added Rust toolchain for NIF build
- `cordial_cantina/native/nif/src/lib.rs` - Added Rust test
- `cordial_cantina/lib/cordial_cantina_web/live/dashboard_live.ex` - Added PubSub real-time updates
- `docs/README.md` - Removed Orbital Market Maker working title
- `docs/overview/README.md` - Removed working title reference
- `docs/overview/PRODUCT_IDENTITY.md` - Updated name section

---

## GitHub Issues Integration

Regarding migration to GitHub Issues:

**Feasibility**: The `gh` CLI tool supports full GitHub Issues management:
```sh
# Create issue
gh issue create --title "Title" --body "Body"

# List issues
gh issue list

# View issue
gh issue view 123

# Close issue
gh issue close 123
```

**Recommendation**: GitHub Issues would integrate well with the existing workflow:
- Issues can reference commits and PRs
- Labels can map to milestone phases (P1, P2, etc.)
- Milestones in GitHub can track sprint progress
- The current file-based MILESTONE.md could transition to GitHub Milestones

**Migration approach**:
1. Create GitHub labels for task types and phases
2. Create GitHub milestones for macro-milestones
3. Move PROMPT_BACKLOG.md items to Issues
4. Optionally keep MILESTONE.md as a local reference

This could be done agentically via `gh` commands in future milestones.

---

## Questions for Human Pilot

1. **CI status**: The clippy fixes should allow CI to pass. Push to verify?

2. **GitHub Issues**: Would you like to migrate to GitHub Issues in a future milestone? The `gh` CLI enables agentic management.

3. **Process definition**: Is the process definition macro-milestone now complete with CI passing?

---

## Technical Concerns / Risks

**LiveView tick implementation**: The current implementation has each connected client scheduling its own ticks. For many clients, this could be optimized with a single GenServer broadcasting ticks. Acceptable for stub phase.

---

## Suggestions for Improvement

1. **Centralized tick server**: Move tick scheduling to a GenServer for efficiency with many clients.

2. **Dashboard expansion**: Add more system metrics (memory, process count, etc.) in future phases.

---

## Intended Next Step

**Awaiting human direction** on commit and next milestone.

All M7 tasks (M7-T1 through M7-T9) are complete. M7-T10 (commit) pending.

---

## Session Context

If you are a new AI session reading this file:

1. Read [MILESTONE.md](./MILESTONE.md) - M7 CI and LiveView complete (pending commit)
2. Read [PROMPT_BACKLOG.md](./PROMPT_BACKLOG.md) - B3, B5, B6 open
3. LiveView dashboard: http://localhost:4000/dashboard
4. Process definition macro-milestone: Near complete (pending CI verification)
5. Wait for human prompt before proceeding
