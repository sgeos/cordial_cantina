# State Management

> **Navigation**: [Architecture](./README.md) | [Documentation Root](../README.md)

This document specifies the data flow between hot and cold storage.

---

## Overview

Data flows from ingestion through Mnesia to PostgreSQL:

```
External Sources → Mnesia (hot) → PostgreSQL (cold)
                       │
                       ▼
                Trading Decisions
```

---

## Hot Data (Mnesia)

### Contents

| Data Type | Purpose | Retention |
|-----------|---------|-----------|
| Real-time price data | Trading decisions | Sliding window |
| Order book snapshots | Market analysis | Sliding window |
| Computed manifold coordinates | Physical model | Sliding window |
| Pending transaction queue | Transaction management | Until confirmed |
| Active position parameters | Position tracking | Until position closed |

### Characteristics

- Sub-millisecond read access
- Ephemeral (data can be recreated or is transient)
- Sized for active trading window

---

## Cold Data (PostgreSQL)

### Contents

| Data Type | Purpose | Retention |
|-----------|---------|-----------|
| Historical price data | Backtesting, analytics | Long-term |
| Transaction history | Audit trail | Permanent |
| Position snapshots | Recovery, analysis | Long-term |
| Performance metrics | Strategy evaluation | Long-term |

### Characteristics

- Durable storage
- Queryable for historical analysis
- Indexed for time-range queries

---

## Data Flow

### Ingestion

```
External Signal → Validation → Mnesia Write → PubSub Notification
```

1. Signal received from external source
2. Validation checks applied
3. Written to appropriate Mnesia table
4. Notification broadcast to interested processes

### Offload

```
Mnesia (aged data) → Decision → PostgreSQL or Drop
```

1. Offload scheduler triggers based on configured policy
2. Aged data identified in Mnesia
3. Decision: offload to PostgreSQL (if historically useful) or drop
4. Execute offload/delete operation
5. Confirm completion

### Offload Triggers

Triggers are business logic and trading strategy specific:

| Trigger Type | Description |
|--------------|-------------|
| Time-based | Offload data older than configured threshold |
| Threshold-based | Offload when table exceeds configured size |
| Hybrid | Combination of time and threshold |

Concrete trigger parameters are configured per data type.

---

## Recovery

### On Process Restart

| Process | Recovery Source | Strategy |
|---------|-----------------|----------|
| Market data feeds | No recovery | Reconnect, resume ingestion |
| Signal aggregator | Mnesia | Recompute from recent data |
| Strategy engine | Mnesia + PositionManager | Resume from current state |
| Position manager | On-chain + PostgreSQL | Query blockchain state |
| Transaction monitor | PostgreSQL | Reload pending signatures |

### On System Restart

1. Mnesia tables recreated (empty, ram_copies)
2. Critical state loaded from PostgreSQL
3. On-chain state queried for position recovery
4. Data feeds reconnected
5. Trading resumes after warm-up period

---

## Unresolved Questions

| Question | Status |
|----------|--------|
| Specific Mnesia table definitions | TBD in Phase 1 |
| Default sliding window sizes | TBD |
| Offload trigger parameters | TBD |
| PostgreSQL schema design | TBD |

---

## Related Documents

- [Data Storage](./DATA_STORAGE.md) - Storage layer details
- [Supervision Tree](./SUPERVISION_TREE.md) - Process recovery
- [Reliability Requirements](../requirements/RELIABILITY.md) - Recovery requirements
