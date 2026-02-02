# Priority Decisions

> **Navigation**: [Decisions](./README.md) | [Documentation Root](../README.md)

This document captures unresolved questions that must be disambiguated before Phase 1 (Foundation) can be implemented with confidence.

## Document Status

**Created**: 2026-02-01
**Updated**: 2026-02-02
**Purpose**: Pre-Phase 1 disambiguation checklist
**Related**: [Resolved](./RESOLVED.md), [Backlog](./BACKLOG.md)

## Phase 1 Deliverables Reference

From [PHASE_1_FOUNDATION.md](../roadmap/PHASE_1_FOUNDATION.md), Phase 1 must deliver:
1. Core Elixir application structure with OTP supervision
2. Rust NIF scaffolding for numerical computation
3. Basic Solana blockchain interaction (read-only)
4. Unit test framework and initial test coverage

---

## Resolution Summary

All Phase 1 blocking questions have been resolved. See [RESOLVED.md](./RESOLVED.md) for full details.

| Priority | Topic | Status | Resolution |
|----------|-------|--------|------------|
| P1 | OTP Supervision | **Resolved** | [R2](./RESOLVED.md#r2-mnesia-initialization-strategy), [R3](./RESOLVED.md#r3-otp-supervision-operational-model) |
| P2 | Rust NIF Integration | **Resolved** | [R4](./RESOLVED.md#r4-rust-nif-integration-strategy) |
| P3 | Solana RPC | **Resolved** | [R5](./RESOLVED.md#r5-solana-rpc-strategy) |
| P4 | Secrets Management | **Resolved** | [R6](./RESOLVED.md#r6-secrets-management-strategy) |
| P5 | Testing Framework | **Resolved** | [R7](./RESOLVED.md#r7-testing-framework-strategy) |
| P6 | Mnesia Schema | **Resolved** | [R8](./RESOLVED.md#r8-mnesia-schema-strategy) |
| P7 | Logging | **Resolved** | [R9](./RESOLVED.md#r9-logging-and-observability-strategy) |

---

## Remaining Open Questions

The following questions remain open but do not block Phase 1:

### From P1: OTP Supervision

| Question | Status | Notes |
|----------|--------|-------|
| P1.5: Market data warm-up duration | Deferred | Determined during implementation |
| P1.6: Strategy safe mode after restart | Deferred | Operational concern for V0.5+ |
| P1.7: Restart intensity alerting | Deferred | Operational concern for V0.5+ |

### From P3: Solana RPC

| Question | Status | Notes |
|----------|--------|-------|
| Is direct RPC needed or is Birdeye+Raydium sufficient? | Open | Answered during V0.1 implementation |

### From P6: Mnesia Schema

| Question | Status | Notes |
|----------|--------|-------|
| Specific table definitions | Iterative | Emerge from implementation |
| Default parameter values | Iterative | Tuned during implementation |

---

## Action Items

Before beginning Phase 1 implementation:

1. [x] Draft OTP supervision tree diagram with restart strategies (see SUPERVISION_TREE.md)
2. [x] Review and finalize supervision tree critical questions (see R2, R3)
3. [x] Select Rust NIF binding library (Rustler - see R4)
4. [x] Select primary and fallback Solana RPC providers (public RPC for V0.1 - see R5)
5. [x] Define secrets management pattern for development (see R6)
6. [x] Define Mnesia table schemas for market data (iterative approach - see R8)
7. [x] Configure CI pipeline with Elixir, Rust, and test database (existing pipeline)
8. [x] Establish logging and telemetry conventions (see R9)

**Phase 1 is unblocked.**

---

## Revision History

| Date | Author | Changes |
|------|--------|---------|
| 2026-02-01 | Claude | Initial draft |
| 2026-02-01 | Claude | Reorganized: moved resolved items to TBD_RESOLVED.md, deferred items to TBD_BACKLOG.md |
| 2026-02-01 | Claude | P1 updated: supervision tree drafted in SUPERVISION_TREE.md, remaining questions narrowed |
| 2026-02-01 | Claude | P6 updated: Mnesia configuration resolved, remaining questions narrowed to table definitions |
| 2026-02-02 | Claude | All P1-P7 blockers resolved. Phase 1 unblocked. |
