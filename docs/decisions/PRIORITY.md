# Priority Decisions

> **Navigation**: [Decisions](./README.md) | [Documentation Root](../README.md)

This document captures unresolved questions that must be disambiguated before Phase 1 (Foundation) can be implemented with confidence.

## Document Status

**Created**: 2026-02-01
**Purpose**: Pre-Phase 1 disambiguation checklist
**Related**: [Resolved](./RESOLVED.md), [Backlog](./BACKLOG.md)

## Phase 1 Deliverables Reference

From [PHASE_1_FOUNDATION.md](../roadmap/PHASE_1_FOUNDATION.md), Phase 1 must deliver:
1. Core Elixir application structure with OTP supervision
2. Rust NIF scaffolding for numerical computation
3. Basic Solana blockchain interaction (read-only)
4. Unit test framework and initial test coverage

---

## Blocking Questions

### P1. OTP Supervision Tree Design

**Status**: Draft complete, requires review

**Document**: See `docs/SUPERVISION_TREE.md` for full supervision tree design.

**Resolved**:
- Complete supervision tree hierarchy with 7 subsystem supervisors
- Restart strategies assigned to each supervisor
- Restart intensity thresholds defined (default, low, moderate)
- State recovery requirements identified per process
- Recovery sources identified (Mnesia, PostgreSQL, on-chain, configuration)

**Remaining questions** (from SUPERVISION_TREE.md):

*Critical (must resolve before Phase 1)*:
1. ~~Mnesia initialization: Task vs GenServer?~~ **RESOLVED**: GenServer strategy. See [R2 in Resolved](./RESOLVED.md#r2-mnesia-initialization-strategy).
2. Mnesia clustering: How is schema synchronized across nodes?
3. Position recovery: How is on-chain state queried and validated?
4. Transaction monitoring: How are pending transactions persisted and recovered?

*Important (should resolve before Phase 1)*:
5. Market data warm-up: How long before signals are reliable? Should trading pause?
6. Strategy safe mode: Should there be an observation-only mode after restart?
7. Restart alerting: Should restart intensity breaches trigger alerts?

**Blocking because**: Critical questions affect process implementation. Important questions affect operational safety.

---

### P2. Rust NIF Integration Strategy

**Status**: Requires architecture decision

**Questions**:
1. Which NIF binding library: Rustler vs erlang-nif-sys vs hand-rolled?
2. What is the NIF API boundary? Which functions cross the Elixir/Rust boundary?
3. How are panics and errors handled to avoid crashing the BEAM VM?
4. Should NIFs be synchronous (blocking schedulers) or use dirty schedulers?
5. What is the memory ownership model for data passed between Elixir and Rust?
6. How is the Rust library built and linked during Mix compilation?

**Blocking because**: NIF crashes bring down the entire BEAM VM. The integration pattern must be established before building upon it.

**Suggested resolution**:
- Select Rustler as the binding library (mature, well-documented, handles safety)
- Define explicit API contracts before implementation
- Use dirty CPU schedulers for computation exceeding 1ms
- Implement resource types for shared state

---

### P3. Solana RPC Integration

**Status**: Requires vendor and failover decisions

**Questions**:
1. Which RPC provider(s) will be used? (Helius, QuickNode, Triton, self-hosted)
2. What is the failover strategy when primary RPC is unavailable?
3. What rate limits apply and how are they managed?
4. Which RPC methods are required for read-only Phase 1 operations?
5. How are WebSocket subscriptions managed for real-time updates?
6. What is the retry policy for failed RPC calls?

**Blocking because**: All blockchain interaction depends on RPC access. Provider selection affects rate limits, latency, and cost.

**Suggested resolution**:
- Primary: Helius (Solana-focused, good rate limits)
- Fallback: QuickNode or self-hosted validator
- Implement circuit breaker pattern for RPC calls

---

### P4. Configuration and Secrets Management

**Status**: Requires architecture decision

**Questions**:
1. How are RPC endpoint URLs and API keys provided to the application?
2. Where are private keys stored during development vs production?
3. How are environment-specific configurations managed (dev, test, staging, prod)?
4. Should secrets be loaded at compile time or runtime?
5. What is the key rotation procedure?

**Blocking because**: Phase 1 requires RPC credentials. The pattern established now carries through to private key management in later phases.

**Suggested resolution**:
- Use `config/runtime.exs` for all secrets via environment variables
- Development: `.env` files (gitignored)
- Production: Platform secret management (Vault, AWS Secrets Manager, etc. TBD)
- Private keys never in source code or environment variables in production

---

### P5. Test Framework and Coverage Strategy

**Status**: Requires tooling decisions

**Questions**:
1. What is the minimum code coverage target for Phase 1?
2. Which coverage tool: excoveralls vs cover?
3. How are Rust NIFs tested? Rust-side tests, Elixir-side integration tests, or both?
4. How are Solana RPC calls mocked in tests?
5. What is the CI pipeline configuration?

**Blocking because**: Test infrastructure must be established before writing production code to ensure testability.

**Suggested resolution**:
- Use built-in `mix test --cover` with 80% line coverage target for critical paths
- Rust: Unit tests via `cargo test`, integration tests via ExUnit
- Mock RPC calls using Mox or Bypass
- CI: GitHub Actions with Elixir, Rust, and PostgreSQL services

---

### P6. Mnesia Schema Design

**Status**: Partially resolved, requires table definitions

**Resolved** (see TBD_RESOLVED.md R1):
- Storage type: `ram_copies` only (data is ephemeral, PostgreSQL provides durability)
- Fragmentation: Parameterized, configurable per table
- Sliding window: Parameterized, business logic specific
- Offload triggers: Business logic specific (time-based, threshold-based, or hybrid)

**Remaining questions**:
1. What tables are needed for Phase 1?
2. What are the table types (set, ordered_set, bag) for each table?
3. What are the key structures and indices for each table?
4. How are tables distributed in a clustered deployment?
5. What are the default parameter values for fragmentation and sliding windows?

**Blocking because**: Table definitions must be established before writing code that depends on them.

**Suggested resolution for Phase 1**:
- `market_ticks`: ordered_set, ram_copies, keyed by {pair, timestamp}
- `order_book_snapshots`: set, ram_copies, keyed by {pair, timestamp}
- Schema versioning via application config, not Ecto-style migrations
- Default sliding window: 1 hour (configurable)
- Default fragmentation: single fragment initially (configurable)

---

### P7. Logging and Observability Foundation

**Status**: Requires tooling selection

**Questions**:
1. What structured logging format: JSON, logfmt, or Elixir default?
2. What log aggregation system (if any) for development?
3. What telemetry events should be emitted from Phase 1 components?
4. How are logs correlated across distributed nodes?

**Blocking because**: Debugging distributed OTP applications without proper logging is impractical. The pattern must be established early.

**Suggested resolution**:
- Use Logger with JSON formatter for structured output
- Emit telemetry events for all RPC calls, NIF invocations, and supervision events
- Add correlation IDs to log metadata

---

## Action Items

Before beginning Phase 1 implementation:

1. [x] Draft OTP supervision tree diagram with restart strategies (see SUPERVISION_TREE.md)
2. [ ] Review and finalize supervision tree critical questions
3. [ ] Select Rust NIF binding library (recommend: Rustler)
4. [ ] Select primary and fallback Solana RPC providers
5. [ ] Define secrets management pattern for development
6. [ ] Define Mnesia table schemas for market data
7. [ ] Configure CI pipeline with Elixir, Rust, and test database
8. [ ] Establish logging and telemetry conventions

---

## Revision History

| Date | Author | Changes |
|------|--------|---------|
| 2026-02-01 | Claude | Initial draft |
| 2026-02-01 | Claude | Reorganized: moved resolved items to TBD_RESOLVED.md, deferred items to TBD_BACKLOG.md |
| 2026-02-01 | Claude | P1 updated: supervision tree drafted in SUPERVISION_TREE.md, remaining questions narrowed |
| 2026-02-01 | Claude | P6 updated: Mnesia configuration resolved, remaining questions narrowed to table definitions |
