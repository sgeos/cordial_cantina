# TBD_RESOLVED.md

This document records design decisions that have been fully resolved. Each entry includes the decision, rationale, and any residual sub-questions that remain open but do not block implementation.

## Document Status

**Created**: 2026-02-01
**Purpose**: Archive of resolved architectural decisions
**Related**: TBD_PRIORITY.md (blocking), TBD_BACKLOG.md (deferred)

---

## R1. Database Architecture

**Resolved**: 2026-02-01
**Updated in**: SPECIFICATION.md v0.1.1-alpha

### Decision

Dual-database architecture:

| Layer | Technology | Purpose |
|-------|------------|---------|
| Hot data | Mnesia | In-memory time-series data for active trading decisions |
| Cold data | PostgreSQL via Ecto | Historical data storage, audit trails, analytics |

### Rationale

- Mnesia provides sub-millisecond access for latency-critical trading operations
- Mnesia integrates natively with OTP supervision and distribution
- Mnesia supports transparent failover in clustered deployments
- PostgreSQL provides durable storage with mature tooling for historical analysis
- Ecto provides schema migrations, query composition, and ecosystem compatibility
- Separation of concerns allows independent scaling and optimization

### Data Flow

1. Real-time market data ingested into Mnesia tables
2. Mnesia maintains sliding window of recent data for active trading
3. Data rotating out of Mnesia is either offloaded to PostgreSQL (if useful as historical metric) or dropped (if no immediate or future utility)
4. Historical data may also be sourced from third-party APIs or parsed from on-chain data
5. PostgreSQL serves historical queries, backtesting, and analytics workloads

### Mnesia Configuration

**Storage type**: `ram_copies` only

**Rationale**: Data in Mnesia is nominally ephemeral. The `ram_copies` mode is simpler than `disc_copies`, and PostgreSQL provides durable cold storage. This separation of concerns avoids the complexity of Mnesia disk persistence and schema migration.

**Fragmentation**: Parameterized. Fragmentation strategy is configurable and may require task-level optimization based on data volume and access patterns.

**Sliding window size**: Parameterized. Concrete window sizes are business logic specific and should be configurable per data type and trading strategy.

### Offload Strategy

**Trigger conditions**: Business logic and trading strategy specific. The offload mechanism supports multiple trigger strategies:
- Time-based (e.g., rotate data older than N minutes)
- Threshold-based (e.g., rotate when table exceeds N records)
- Hybrid approaches combining time and threshold

**Data disposition**: When data rotates out of Mnesia:
- Data with future historical utility is offloaded to PostgreSQL
- Data with no immediate or future utility is dropped

Concrete trigger parameters and data disposition rules are configured per data type.

### PostgreSQL Configuration

**Indexing**: Primary index on datetime for all time-series tables.

**Access pattern**: Data accessed via an abstract interface that could theoretically serve data across partitions. The interface design allows partitioning to be added as a future optimization without changing calling code.

**Partitioning**: Deferred. If partitioning is implemented in the future, date-based partitioning (daily, monthly, or annual) will likely make sense depending on data volume and observed bottlenecks.

**Rationale**: This approach prioritizes future-proofing and deferred complexity. Partitioning adds operational overhead and should only be implemented when data volume necessitates it.

### Residual Sub-Questions

The following remain open but do not block the architectural decision:

- Specific Mnesia table definitions (names, key structures, indices)
- Concrete default values for fragmentation and sliding window parameters
- PostgreSQL schema design for historical tables

These sub-questions are tracked in TBD_PRIORITY.md under "Mnesia Schema Design."

---

## Revision History

| Date | Author | Changes |
|------|--------|---------|
| 2026-02-01 | Claude | Initial draft with Database Architecture resolution |
| 2026-02-01 | Claude | Added Mnesia configuration (ram_copies, parameterized fragmentation/windows), offload strategy, PostgreSQL configuration (datetime index, deferred partitioning) |
