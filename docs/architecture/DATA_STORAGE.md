# Data Storage

> **Navigation**: [Architecture](./README.md) | [Documentation Root](../README.md)

This document specifies the data storage architecture.

---

## Overview

The system uses a dual-database architecture:

| Layer | Technology | Purpose |
|-------|------------|---------|
| Hot data | Mnesia (`ram_copies`) | In-memory time-series for active trading |
| Cold data | PostgreSQL via Ecto | Historical storage, audit trails, analytics |

---

## Mnesia Configuration

### Storage Type

**Decision**: `ram_copies` only

**Rationale**:
- Data in Mnesia is nominally ephemeral
- Simpler than `disc_copies` (no disk I/O, no schema migration complexity)
- PostgreSQL provides durability for data that must persist

### Fragmentation

**Configuration**: Parameterized per table

**Rationale**: Fragmentation strategy depends on data volume and access patterns. Default to single fragment, scale as needed.

### Sliding Window

**Configuration**: Parameterized per data type

**Rationale**: Window sizes are business logic specific. Different data types may require different retention periods.

---

## PostgreSQL Configuration

### Indexing

**Primary index**: Datetime for all time-series tables

**Rationale**: Most queries filter by time range

### Access Pattern

**Design**: Abstract interface that could serve data across partitions

**Rationale**: Allows partitioning to be added later without changing calling code

### Partitioning

**Status**: Deferred optimization

**Future approach**: Date-based partitioning (daily, monthly, or annual) based on data volume and observed bottlenecks

**Rationale**: Partitioning adds operational overhead. Implement only when data volume necessitates.

---

## Tables

### Mnesia Tables (Hot)

| Table | Type | Key | Purpose |
|-------|------|-----|---------|
| `market_ticks` | ordered_set | {pair, timestamp} | Real-time price data |
| `order_book_snapshots` | set | {pair, timestamp} | Order book state |
| `computed_signals` | set | {pair, timestamp} | Derived trading signals |

### PostgreSQL Tables (Cold)

| Table | Purpose |
|-------|---------|
| `historical_ticks` | Offloaded price data |
| `historical_order_books` | Offloaded order book data |
| `transactions` | Transaction audit trail |
| `positions` | Position snapshots for recovery |
| `performance_metrics` | Strategy performance data |

---

## Schema Evolution

### Mnesia

Schema changes on running Mnesia clusters are complex. Strategy:

- Schema versioning via application configuration
- No Ecto-style migrations for Mnesia
- Careful planning for schema changes requiring downtime

### PostgreSQL

Standard Ecto migrations for schema evolution.

---

## Related Documents

- [State Management](./STATE_MANAGEMENT.md) - Data flow between layers
- [Resolved Decisions](../decisions/RESOLVED.md) - Database architecture decision
- [Supervision Tree](./SUPERVISION_TREE.md) - Data process design
