# SUPERVISION_TREE.md

This document describes the OTP supervision tree design for Cordial Cantina. It enumerates all known processes requiring supervision and documents open questions about restart strategies, intensity thresholds, and state recovery.

## Document Status

**Created**: 2026-02-01
**Purpose**: Phase 1 supervision tree design
**Related**: TBD_PRIORITY.md (P1), SPECIFICATION.md

---

## Supervision Tree Overview

```
CordialCantina.Supervisor (Application, :one_for_one)
├── CordialCantina.Repo (Ecto/PostgreSQL)
├── CordialCantina.Mnesia.Supervisor (:one_for_all)
│   └── (Mnesia tables initialized at startup)
├── CordialCantina.Data.Supervisor (:rest_for_one)
│   ├── CordialCantina.Data.OffloadScheduler
│   └── CordialCantina.Data.OffloadWorker (pool)
├── CordialCantina.RPC.Supervisor (:one_for_one)
│   ├── CordialCantina.RPC.ConnectionManager
│   └── CordialCantina.RPC.RateLimiter
├── CordialCantina.Market.Supervisor (:rest_for_one)
│   ├── CordialCantina.Market.PriceFeed
│   ├── CordialCantina.Market.OrderBookFeed
│   └── CordialCantina.Market.SignalAggregator
├── CordialCantina.Strategy.Supervisor (:one_for_one)
│   ├── CordialCantina.Strategy.Engine
│   └── CordialCantina.Strategy.PositionManager
├── CordialCantina.Blockchain.Supervisor (:one_for_one)
│   ├── CordialCantina.Blockchain.TransactionBuilder
│   └── CordialCantina.Blockchain.TransactionMonitor
├── CordialCantinaWeb.Telemetry
├── {DNSCluster, ...}
├── {Phoenix.PubSub, ...}
├── {Finch, ...}
└── CordialCantinaWeb.Endpoint
```

---

## Process Definitions

### Infrastructure Processes (Phoenix/OTP Standard)

These processes are provided by Phoenix and OTP. Their supervision is well-understood.

#### CordialCantinaWeb.Telemetry

**Purpose**: Telemetry event handlers and metric aggregation.

| Question | Answer |
|----------|--------|
| Dependencies indicating restart strategy? | None. Stateless observer. |
| Obvious restart intensity? | Default (3 restarts in 5 seconds). Telemetry loss is acceptable during recovery. |
| State recovery required? | No. Restarts with empty state. Metric continuity not critical. |
| Recovery strategy? | N/A |
| Mnesia or PostgreSQL? | N/A |

**Restart strategy**: `:permanent`
**Status**: Resolved

---

#### DNSCluster

**Purpose**: DNS-based cluster discovery for distributed deployment.

| Question | Answer |
|----------|--------|
| Dependencies indicating restart strategy? | None. Independent discovery mechanism. |
| Obvious restart intensity? | Default. Cluster membership is eventually consistent. |
| State recovery required? | No. Re-queries DNS on restart. |
| Recovery strategy? | N/A |
| Mnesia or PostgreSQL? | N/A |

**Restart strategy**: `:permanent`
**Status**: Resolved

---

#### Phoenix.PubSub

**Purpose**: In-process and distributed pub/sub for LiveView and internal messaging.

| Question | Answer |
|----------|--------|
| Dependencies indicating restart strategy? | None. Central message broker. |
| Obvious restart intensity? | Default. Subscribers re-subscribe after reconnection. |
| State recovery required? | No. Subscriptions are transient. |
| Recovery strategy? | N/A |
| Mnesia or PostgreSQL? | N/A |

**Restart strategy**: `:permanent`
**Status**: Resolved

---

#### Finch (HTTP Client)

**Purpose**: HTTP connection pooling for outbound requests (Req library backend).

| Question | Answer |
|----------|--------|
| Dependencies indicating restart strategy? | None. Connection pools are stateless. |
| Obvious restart intensity? | Default. Connections are re-established on demand. |
| State recovery required? | No. Pools rebuild automatically. |
| Recovery strategy? | N/A |
| Mnesia or PostgreSQL? | N/A |

**Restart strategy**: `:permanent`
**Status**: Resolved

---

#### CordialCantinaWeb.Endpoint

**Purpose**: Phoenix HTTP endpoint serving web requests and WebSocket connections.

| Question | Answer |
|----------|--------|
| Dependencies indicating restart strategy? | Depends on PubSub for LiveView. Should start after PubSub. |
| Obvious restart intensity? | Default. HTTP is stateless per request. |
| State recovery required? | No. LiveView clients reconnect automatically. |
| Recovery strategy? | N/A |
| Mnesia or PostgreSQL? | N/A |

**Restart strategy**: `:permanent`
**Status**: Resolved

---

### Database Processes

#### CordialCantina.Repo

**Purpose**: Ecto repository for PostgreSQL access.

| Question | Answer |
|----------|--------|
| Dependencies indicating restart strategy? | None. Independent database connection pool. |
| Obvious restart intensity? | Default. Connection pool rebuilds on restart. |
| State recovery required? | No. Connections are stateless. |
| Recovery strategy? | N/A |
| Mnesia or PostgreSQL? | N/A (this IS the PostgreSQL interface) |

**Restart strategy**: `:permanent`
**Status**: Resolved

**Note**: Repo must be added to application.ex. Currently missing.

---

#### CordialCantina.Mnesia.Supervisor

**Purpose**: Supervises Mnesia initialization and ensures tables are created.

| Question | Answer |
|----------|--------|
| Dependencies indicating restart strategy? | Tables must exist before consumers start. Use `:one_for_all` to restart all children if initialization fails. |
| Obvious restart intensity? | Low (1-2 restarts in 30 seconds). Mnesia initialization failure is serious. |
| State recovery required? | No. Tables are created empty (ram_copies). |
| Recovery strategy? | N/A |
| Mnesia or PostgreSQL? | N/A |

**Restart strategy**: `:one_for_all` for children
**Status**: Open questions

**Open questions**:
1. Should Mnesia be initialized via a Task that completes, or a GenServer that stays alive?
2. How is Mnesia schema creation handled on first boot vs subsequent boots?
3. How is Mnesia cluster membership coordinated with DNSCluster?

---

### Data Management Processes

#### CordialCantina.Data.Supervisor

**Purpose**: Supervises data lifecycle processes (offload from Mnesia to PostgreSQL).

| Question | Answer |
|----------|--------|
| Dependencies indicating restart strategy? | OffloadWorker depends on OffloadScheduler for tasks. Use `:rest_for_one`. |
| Obvious restart intensity? | Default. Data offload can tolerate brief interruptions. |
| State recovery required? | Partial. See child processes. |
| Recovery strategy? | See child processes. |
| Mnesia or PostgreSQL? | See child processes. |

**Restart strategy**: `:rest_for_one`
**Status**: Open questions

---

#### CordialCantina.Data.OffloadScheduler

**Purpose**: Schedules data offload operations based on configured triggers (time-based, threshold-based).

| Question | Answer |
|----------|--------|
| Dependencies indicating restart strategy? | None. Reads configuration and schedules work. |
| Obvious restart intensity? | Default. Scheduler state is reconstructible. |
| State recovery required? | Partial. Pending schedule can be reconstructed from configuration and current time. |
| Recovery strategy? | On restart, recalculate next offload times based on current time and configured intervals. |
| Mnesia or PostgreSQL? | Neither. Configuration-driven. |

**Restart strategy**: `:permanent`
**Status**: Resolved

---

#### CordialCantina.Data.OffloadWorker

**Purpose**: Executes data offload from Mnesia to PostgreSQL.

| Question | Answer |
|----------|--------|
| Dependencies indicating restart strategy? | Depends on Repo and Mnesia being available. |
| Obvious restart intensity? | Default. Individual offload failures are retriable. |
| State recovery required? | No. Each offload is idempotent (keyed by timestamp). |
| Recovery strategy? | Scheduler re-dispatches work. In-flight offloads may be retried. |
| Mnesia or PostgreSQL? | Both. Reads from Mnesia, writes to PostgreSQL. |

**Restart strategy**: `:transient` (only restart on abnormal exit)
**Status**: Open questions

**Open questions**:
1. Should this be a pool of workers (via Poolboy or similar)?
2. How are partial offloads handled (some records written, some not)?
3. Is idempotency guaranteed by primary key constraints in PostgreSQL?

---

### RPC Processes (Solana Blockchain)

#### CordialCantina.RPC.Supervisor

**Purpose**: Supervises Solana RPC connection management.

| Question | Answer |
|----------|--------|
| Dependencies indicating restart strategy? | Children are independent. Use `:one_for_one`. |
| Obvious restart intensity? | Default. RPC issues are expected and recoverable. |
| State recovery required? | See child processes. |
| Recovery strategy? | See child processes. |
| Mnesia or PostgreSQL? | See child processes. |

**Restart strategy**: `:one_for_one`
**Status**: Resolved

---

#### CordialCantina.RPC.ConnectionManager

**Purpose**: Manages RPC endpoint selection, failover, and health checking.

| Question | Answer |
|----------|--------|
| Dependencies indicating restart strategy? | None. Reads endpoint configuration. |
| Obvious restart intensity? | Default. Connection state is reconstructible. |
| State recovery required? | Partial. Current endpoint selection and health status. |
| Recovery strategy? | On restart, assume all endpoints healthy and re-probe. Conservative approach. |
| Mnesia or PostgreSQL? | Neither. Ephemeral state, reconstructible from probing. |

**Restart strategy**: `:permanent`
**Status**: Resolved

---

#### CordialCantina.RPC.RateLimiter

**Purpose**: Enforces rate limits for RPC requests per endpoint.

| Question | Answer |
|----------|--------|
| Dependencies indicating restart strategy? | None. Independent rate tracking. |
| Obvious restart intensity? | Default. Rate limit state is ephemeral. |
| State recovery required? | No. On restart, assume full rate limit budget available. Conservative approach allows immediate requests. |
| Recovery strategy? | N/A |
| Mnesia or PostgreSQL? | Neither. Ephemeral counters, no persistence needed. |

**Restart strategy**: `:permanent`
**Status**: Resolved

---

### Market Data Processes

#### CordialCantina.Market.Supervisor

**Purpose**: Supervises market data ingestion processes.

| Question | Answer |
|----------|--------|
| Dependencies indicating restart strategy? | SignalAggregator depends on feeds. Use `:rest_for_one`. |
| Obvious restart intensity? | Moderate (5 restarts in 60 seconds). Market data interruption should trigger alerts. |
| State recovery required? | See child processes. |
| Recovery strategy? | See child processes. |
| Mnesia or PostgreSQL? | See child processes. |

**Restart strategy**: `:rest_for_one`
**Status**: Open questions

**Open questions**:
1. Should restart intensity trigger an alert or circuit breaker?
2. How long can the system operate without fresh market data before halting trading?

---

#### CordialCantina.Market.PriceFeed

**Purpose**: Ingests real-time price data from external sources.

| Question | Answer |
|----------|--------|
| Dependencies indicating restart strategy? | Depends on RPC.ConnectionManager for Solana data, or external WebSocket for CEX data. |
| Obvious restart intensity? | Default. Brief reconnection delays are acceptable. |
| State recovery required? | No. Price history is in Mnesia. Feed restarts and continues from current time. |
| Recovery strategy? | Reconnect to data source, resume ingestion. Gap in data is acceptable. |
| Mnesia or PostgreSQL? | Writes to Mnesia (market_ticks table). |

**Restart strategy**: `:permanent`
**Status**: Open questions

**Open questions**:
1. What external data sources are used? (WebSocket, REST polling, Solana RPC)
2. How is reconnection backoff handled?
3. Should there be multiple PriceFeed instances for redundancy?

---

#### CordialCantina.Market.OrderBookFeed

**Purpose**: Ingests order book snapshots from external sources.

| Question | Answer |
|----------|--------|
| Dependencies indicating restart strategy? | Similar to PriceFeed. |
| Obvious restart intensity? | Default. |
| State recovery required? | No. Order book is point-in-time snapshot. |
| Recovery strategy? | Reconnect and fetch fresh snapshot. |
| Mnesia or PostgreSQL? | Writes to Mnesia (order_book_snapshots table). |

**Restart strategy**: `:permanent`
**Status**: Open questions

**Open questions**:
1. Same as PriceFeed.
2. What is the snapshot frequency?

---

#### CordialCantina.Market.SignalAggregator

**Purpose**: Combines price and order book data into trading signals.

| Question | Answer |
|----------|--------|
| Dependencies indicating restart strategy? | Depends on PriceFeed and OrderBookFeed. Must restart if feeds restart. |
| Obvious restart intensity? | Default. |
| State recovery required? | Partial. Computed signals and intermediate state. |
| Recovery strategy? | Recompute from recent Mnesia data. Sliding window means recent history is available. |
| Mnesia or PostgreSQL? | Reads from Mnesia. May write computed signals to Mnesia. |

**Restart strategy**: `:permanent`
**Status**: Open questions

**Open questions**:
1. How much state must be reconstructed vs recomputed?
2. What is the warm-up period before signals are reliable after restart?
3. Should trading be paused during warm-up?

---

### Strategy Processes

#### CordialCantina.Strategy.Supervisor

**Purpose**: Supervises trading strategy processes.

| Question | Answer |
|----------|--------|
| Dependencies indicating restart strategy? | Engine and PositionManager are loosely coupled. Use `:one_for_one`. |
| Obvious restart intensity? | Low (2 restarts in 60 seconds). Strategy failures are serious. |
| State recovery required? | See child processes. |
| Recovery strategy? | See child processes. |
| Mnesia or PostgreSQL? | See child processes. |

**Restart strategy**: `:one_for_one`
**Status**: Open questions

**Open questions**:
1. Should strategy failures trigger a trading halt?
2. What is the manual intervention procedure for repeated failures?

---

#### CordialCantina.Strategy.Engine

**Purpose**: Executes trading strategy logic, makes buy/sell decisions.

| Question | Answer |
|----------|--------|
| Dependencies indicating restart strategy? | Depends on SignalAggregator for input, PositionManager for state. |
| Obvious restart intensity? | Low. Strategy engine failures should trigger investigation. |
| State recovery required? | Partial. Current decision state and pending actions. |
| Recovery strategy? | Read current position from PositionManager, read recent signals from Mnesia, resume. |
| Mnesia or PostgreSQL? | Reads signals from Mnesia. Delegates position state to PositionManager. |

**Restart strategy**: `:permanent`
**Status**: Open questions

**Open questions**:
1. How are in-flight decisions handled on restart?
2. Should there be a "safe mode" after restart that only observes?
3. How long is the warm-up period before active trading resumes?

---

#### CordialCantina.Strategy.PositionManager

**Purpose**: Tracks current liquidity positions and their parameters.

| Question | Answer |
|----------|--------|
| Dependencies indicating restart strategy? | None for internal state. Depends on Blockchain processes for on-chain state. |
| Obvious restart intensity? | Low. Position state is critical. |
| State recovery required? | **Yes**. Current positions must be recovered. |
| Recovery strategy? | Query on-chain state via RPC to reconstruct position inventory. |
| Mnesia or PostgreSQL? | **PostgreSQL** for position snapshots. On-chain as source of truth. |

**Restart strategy**: `:permanent`
**Status**: Open questions

**Open questions**:
1. How is position state synchronized with on-chain state?
2. How are discrepancies between local and on-chain state handled?
3. Should position snapshots be persisted to PostgreSQL as audit trail?
4. How frequently should local state be validated against chain?

---

### Blockchain Processes

#### CordialCantina.Blockchain.Supervisor

**Purpose**: Supervises blockchain interaction processes.

| Question | Answer |
|----------|--------|
| Dependencies indicating restart strategy? | Children are loosely coupled. Use `:one_for_one`. |
| Obvious restart intensity? | Default. Blockchain issues are recoverable. |
| State recovery required? | See child processes. |
| Recovery strategy? | See child processes. |
| Mnesia or PostgreSQL? | See child processes. |

**Restart strategy**: `:one_for_one`
**Status**: Resolved

---

#### CordialCantina.Blockchain.TransactionBuilder

**Purpose**: Constructs and signs Solana transactions.

| Question | Answer |
|----------|--------|
| Dependencies indicating restart strategy? | Depends on RPC for blockhash, PositionManager for parameters. |
| Obvious restart intensity? | Default. Stateless transaction construction. |
| State recovery required? | No. Each transaction is built fresh. |
| Recovery strategy? | N/A |
| Mnesia or PostgreSQL? | Neither. Stateless. |

**Restart strategy**: `:permanent`
**Status**: Resolved

**Note**: Private key access is required. Security architecture TBD.

---

#### CordialCantina.Blockchain.TransactionMonitor

**Purpose**: Monitors submitted transactions for confirmation or failure.

| Question | Answer |
|----------|--------|
| Dependencies indicating restart strategy? | Depends on RPC for status queries. |
| Obvious restart intensity? | Default. |
| State recovery required? | **Yes**. Pending transaction signatures must be recovered. |
| Recovery strategy? | Persist pending signatures to PostgreSQL. On restart, reload and resume monitoring. |
| Mnesia or PostgreSQL? | **PostgreSQL** for pending transaction log. |

**Restart strategy**: `:permanent`
**Status**: Open questions

**Open questions**:
1. How long should pending transactions be monitored before considered failed?
2. What is the retry policy for unconfirmed transactions?
3. How are duplicate submissions prevented?

---

## Supervisor Hierarchy Summary

| Supervisor | Strategy | Restart Intensity | Rationale |
|------------|----------|-------------------|-----------|
| CordialCantina.Supervisor | :one_for_one | Default (3/5s) | Top-level subsystems are independent |
| CordialCantina.Mnesia.Supervisor | :one_for_all | Low (1-2/30s) | Mnesia failure is critical |
| CordialCantina.Data.Supervisor | :rest_for_one | Default | Workers depend on scheduler |
| CordialCantina.RPC.Supervisor | :one_for_one | Default | RPC components are independent |
| CordialCantina.Market.Supervisor | :rest_for_one | Moderate (5/60s) | Aggregator depends on feeds |
| CordialCantina.Strategy.Supervisor | :one_for_one | Low (2/60s) | Strategy failures are serious |
| CordialCantina.Blockchain.Supervisor | :one_for_one | Default | Blockchain components are independent |

---

## State Recovery Summary

| Process | Recovery Required | Recovery Source | Notes |
|---------|-------------------|-----------------|-------|
| PositionManager | Yes | On-chain + PostgreSQL | Critical trading state |
| TransactionMonitor | Yes | PostgreSQL | Pending transaction signatures |
| SignalAggregator | Partial | Mnesia | Recompute from recent data |
| Strategy.Engine | Partial | Mnesia + PositionManager | Resume from current state |
| OffloadScheduler | Partial | Configuration | Recalculate schedule |
| All others | No | N/A | Stateless or ephemeral |

---

## Open Questions Summary

### Critical (Must resolve before Phase 1)

1. **Mnesia initialization**: Task vs GenServer? First boot vs subsequent boot handling?
2. **Mnesia clustering**: How is schema synchronized across nodes?
3. **Position recovery**: How is on-chain state queried and validated?
4. **Transaction monitoring**: How are pending transactions persisted and recovered?

### Important (Should resolve before Phase 1)

5. **Market data warm-up**: How long before signals are reliable? Should trading pause?
6. **Strategy safe mode**: Should there be an observation-only mode after restart?
7. **Restart alerting**: Should restart intensity breaches trigger alerts?

### Deferred (Can resolve during implementation)

8. **Offload worker pooling**: Single worker vs pool?
9. **Feed redundancy**: Single feed vs multiple for failover?
10. **Validation frequency**: How often to validate local vs on-chain state?

---

## Revision History

| Date | Author | Changes |
|------|--------|---------|
| 2026-02-01 | Claude | Initial draft |
