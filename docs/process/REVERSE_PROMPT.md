# Reverse Prompt

> **Navigation**: [Process](./README.md) | [Documentation Root](../README.md)

This file is the AI-to-human communication channel. It is overwritten after each completed task.

---

## Last Updated

**Date**: 2026-02-02
**Task**: V0.0-M0-P9 Phase 1 Blocker Decisions
**Milestone**: V0.0-M0 Process Definition

---

## Verification

### V0.0-M0-P9-T1: Add R3-R9 to RESOLVED.md
**Result**: PASS - 7 new resolution entries added (R3 through R9)

### V0.0-M0-P9-T2: Update PRIORITY.md with resolution references
**Result**: PASS - Resolution summary table added, all P1-P7 marked resolved

### V0.0-M0-P9-T3: Update Action Items checklist
**Result**: PASS - All 8 action items marked complete

### V0.0-M0-P9-T4: Write REVERSE_PROMPT.md
**Result**: This file

### V0.0-M0-P9-T5: Verify mix precommit
**Status**: Pending

### V0.0-M0-P9-T6: Commit all changes
**Status**: Pending

---

## Files Modified

- `docs/decisions/RESOLVED.md` - Added R3-R9 for all Phase 1 blocker decisions
- `docs/decisions/PRIORITY.md` - Rewrote with resolution summary; Phase 1 unblocked
- `docs/process/MILESTONE.md` - Created V0.0-M0-P9
- `docs/process/REVERSE_PROMPT.md` - This file

---

## Decisions Documented

| Resolution | Topic | Key Points |
|------------|-------|------------|
| R3 | OTP Supervision | Single-node default; 100% redundancy; third-party APIs for historical data; PostgreSQL for transaction persistence |
| R4 | NIF Integration | Rustler; iterative API; safe Rust trusted; dirty schedulers >1ms; zero-copy reads |
| R5 | Solana RPC | Public RPC for V0.1; Birdeye + Raydium APIs; provider selection deferred |
| R6 | Secrets | runtime.exs + env vars; .env files; .env.example; production deferred |
| R7 | Testing | excoveralls; 80% critical paths; cargo test + ExUnit; Bypass for mocks |
| R8 | Mnesia Schema | Iterative definition; minimal tables per feature |
| R9 | Logging | Logger default format; telemetry events; correlation IDs |

---

## Remaining Blockers

**Phase 1 is unblocked.** All critical decisions have been made.

The following questions remain open but do not block implementation:

| Question | Status | Phase |
|----------|--------|-------|
| Market data warm-up duration | Deferred | V0.2+ |
| Strategy safe mode after restart | Deferred | V0.5+ |
| Restart intensity alerting | Deferred | V0.5+ |
| Is direct Solana RPC needed? | Open | Answered in V0.1 |
| Specific Mnesia table definitions | Iterative | V0.1-V0.2 |
| Production secrets management | Deferred | V0.6 |

---

## Noteworthy Comments and Questions

### 1. Solana RPC vs Birdeye + Raydium

You asked whether Solana RPC is needed or if Birdeye + Raydium is sufficient.

**Analysis**: For V0.1 read-only development, Birdeye + Raydium APIs likely provide everything needed:
- Birdeye: Historical OHLCV data, token metadata
- Raydium API: CLMM pool state, position management

Direct Solana RPC will likely be needed for:
- Transaction submission (V0.5+)
- Real-time WebSocket subscriptions for immediate price updates
- On-chain state verification for position reconciliation

**Recommendation**: Start with Birdeye + Raydium. Add direct RPC when a concrete need emerges.

### 2. Iterative vs Upfront Design

Several decisions use an "iterative" approach (API boundary, Mnesia schema, parameter tuning). This is intentional:
- Upfront design without implementation experience leads to rework
- Iterative refinement matches agile methodology
- Documentation captures decisions as they are made

This approach requires discipline to document decisions as they emerge.

### 3. V0.0-M0 Completion Status

With all Phase 1 blockers resolved, the V0.0-M0 Process Definition macro-milestone is near completion. Remaining items:
- GitHub Issues migration (if desired)
- Any final process refinements

---

## Questions for Human Pilot

1. **GitHub Issues migration**: Still desired? Could be V0.0-M0-P10, or deferred to after V0.1 starts.

2. **V0.0-M0 closure**: Ready to close the Process Definition macro-milestone and begin V0.1 Foundation?

3. **Birdeye + Raydium**: Confirmed as the initial data strategy? Any concerns with this approach?

---

## Technical Concerns / Risks

### catch_unwind Usage

The NIF decision (R4) mentions `catch_unwind` as a fallback for panic handling. In practice:
- Safe Rust should not panic if written correctly
- Mathematical code (joltshark) should be expressible without panics
- `catch_unwind` adds overhead and should be avoided where possible

**Recommendation**: Structure NIF code to return `Result` types rather than relying on `catch_unwind`. Reserve `catch_unwind` for truly exceptional circumstances.

---

## Suggestions for Improvement

1. **Create .env.example**: Implement R6 by creating the example environment file before V0.1 starts.

2. **Add excoveralls**: Implement R7 by adding excoveralls to mix.exs dependencies.

3. **V0.1-M1 planning**: Consider drafting the first V0.1 milestone to maintain momentum.

---

## Intended Next Step

**Awaiting human direction** on:
- Verification and commit
- V0.0-M0 closure decision
- V0.1 initiation

---

## Session Context

If you are a new AI session reading this file:

1. Read [MILESTONE.md](./MILESTONE.md) - V0.0-M0-P9 in progress
2. Read [PRIORITY.md](../decisions/PRIORITY.md) - Phase 1 unblocked
3. Read [RESOLVED.md](../decisions/RESOLVED.md) - R1-R9 documented
4. Process definition macro-milestone: Near complete
5. Coding system: Vw-Mx-Py-Tz (see PROCESS_STRATEGY.md)
6. Wait for human prompt before proceeding
