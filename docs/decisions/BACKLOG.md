# Backlog Decisions

> **Navigation**: [Decisions](./README.md) | [Documentation Root](../README.md)

This document records TBD items that do not require immediate resolution. Items are organized by the phase in which they become relevant.

## Document Status

**Created**: 2026-02-01
**Purpose**: Deferred decisions and non-blocking questions
**Related**: [Priority](./PRIORITY.md), [Resolved](./RESOLVED.md)

---

## Phase 1 Adjacent (Non-Blocking)

These items are relevant to Phase 1 but do not block implementation. They should be addressed during or shortly after Phase 1.

### ~~B1. Development Environment Setup~~

**Status**: PARTIALLY RESOLVED - See [R12 in RESOLVED.md](./RESOLVED.md#r12-postgresql-development-setup)

**Resolved**:
- PostgreSQL is required for development (standard Phoenix pattern)
- Setup instructions documented in `cordial_cantina/README.md`

**Remaining questions**:
1. What Elixir/OTP versions are supported? (Document in README)
2. What Rust toolchain version is required? (Document in README)

---

### B2. Code Organization Conventions

**Questions**:
1. How are domain modules organized under `lib/cordial_cantina/`?
2. What is the naming convention for GenServers, Supervisors, and Workers?
3. Where do Rust NIF wrapper modules live?

**Suggested resolution**: Establish conventions in AGENTS.md or a CONTRIBUTING.md

**Why non-blocking**: Conventions can emerge during implementation and be documented retroactively.

---

## Phase 2: Market Data

### ~~B3. Message Queue Selection~~

**Status**: RESOLVED - See [R10 in RESOLVED.md](./RESOLVED.md#r10-message-queue-selection)

**Decision**: Broadway with GenStage is sufficient for V0.2. No external message broker required.

---

### ~~B4. Historical Data Sources~~

**Status**: PARTIALLY RESOLVED - See [R11 in RESOLVED.md](./RESOLVED.md#r11-tradfi-signal-and-data-source-strategy)

**Resolved**:
- BTC price: Birdeye (current), CEX feed (future)
- TradFi signals: yfinance (NQ=F, DX-Y.NYB)
- Update frequencies: TradFi 1-min, BTC sub-10-sec

**Remaining questions**:
1. Cost and rate limit structure for yfinance free tier?
2. How is data quality validated?
3. Historical backfill strategy for backtesting?

**Why deferred**: Real-time data prioritized. Historical backfill needed for backtesting in Phase 3+.

---

## Phase 3: Physical Modeling

### B5. Numerical Library Selection

**Questions**:
1. Which Rust libraries for linear algebra and numerical computation?
2. What precision (f32 vs f64) is required?
3. How are numerical stability issues detected and handled?

**Why deferred**: Phase 1 establishes NIF scaffolding only. Detailed numerical work begins in Phase 3.

---

## Phase 4: Trading Strategy

### B6. Rebalancing Thresholds and Quantities

**Questions**:
1. What triggers a rebalancing operation?
2. What are the proportional allocation rules between ranges?
3. How is gas cost optimization factored into rebalancing decisions?

**Why deferred**: Strategy parameters require backtesting infrastructure from Phase 3.

---

### B7. Unidirectional Movement Detection

**Questions**:
1. What is the quantitative definition of unidirectional movement?
2. What detection algorithm and parameters are used?
3. What are the re-entry criteria after liquidity withdrawal?

**Why deferred**: Requires physical modeling from Phase 3 and strategy framework from Phase 4.

---

### B8. Range Optimization Algorithm

**Questions**:
1. What is the optimal width and spacing for the three liquidity ranges?
2. How do capital constraints and expected volatility affect range selection?
3. How frequently should ranges be recalibrated?

**Why deferred**: Requires backtesting and market data infrastructure.

---

## Phase 5: Live Integration

### B9. Subscription Pricing Model

**Questions**:
1. Flat rate, performance-based, or tiered pricing?
2. What is the fee collection frequency and mechanism?
3. How are insufficient subscriber balances handled?
4. What are the refund or credit policies?

**Why deferred**: Business model decisions can be made closer to launch.

---

### B10. HSM Integration

**Questions**:
1. Is hardware security module integration feasible?
2. Which HSM vendors are compatible with Solana signing?
3. What is the cost-benefit analysis?

**Why deferred**: Security hardening for production. Development can use software keys.

---

### B11. Multi-Signature Schemes

**Questions**:
1. Are multi-signature schemes required for high-value transactions?
2. What threshold (e.g., 2-of-3) is appropriate?
3. How does this affect transaction latency?

**Why deferred**: Security hardening for production deployment.

---

## Phase 6: Production Deployment

### B12. Legal Entity Structure

**Questions**:
1. What legal entity structure is appropriate for system operation?
2. What are the liability considerations?

**Why deferred**: Legal consultation required closer to production launch.

---

### B13. Jurisdiction Selection

**Questions**:
1. Which jurisdiction provides favorable regulatory environment?
2. What are the compliance requirements in selected jurisdiction?
3. What disclosures are required to subscribers?

**Why deferred**: Requires legal consultation and business planning.

---

### B14. Monitoring and Observability Stack

**Questions**:
1. What metrics aggregation and storage solution?
2. What dashboard and visualization tools?
3. What alerting and on-call procedures?

**Why deferred**: Production observability can be built incrementally. Development uses basic logging.

---

## Revision History

| Date | Author | Changes |
|------|--------|---------|
| 2026-02-01 | Claude | Initial draft consolidating deferred items from SPECIFICATION.md |
| 2026-02-15 | Claude | B1 partially resolved (PostgreSQL setup documented) |
| 2026-02-15 | Claude | B4 partially resolved (TradFi signal sources selected) |
