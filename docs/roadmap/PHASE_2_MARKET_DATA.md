# Phase 2: Market Data

> **Navigation**: [Roadmap](./README.md) | [Documentation Root](../README.md)

---

## Objectives

Implement real-time market data ingestion and persistence.

---

## Deliverables

| Deliverable | Description |
|-------------|-------------|
| Price feed ingestion | Real-time price updates from multiple sources |
| Order book snapshots | Periodic order book state capture |
| Signal validation | Data quality checks and anomaly detection |
| Time-series persistence | Mnesia storage with PostgreSQL offload |

---

## Success Criteria

| Criterion | Validation |
|-----------|------------|
| Signal latency meets requirements | < 500ms for target pair, < 1000ms for BTC |
| Data quality validation detects anomalies | Anomaly injection tests |
| Historical data retrievable for analysis | Query tests |

---

## Dependencies

- Phase 1 complete (OTP structure, RPC integration)

---

## Key Components

| Component | Purpose |
|-----------|---------|
| `Market.PriceFeed` | Price data ingestion |
| `Market.OrderBookFeed` | Order book ingestion |
| `Market.SignalAggregator` | Signal combination and validation |
| `Data.OffloadScheduler` | Mnesia → PostgreSQL offload |

---

## Related Documents

- [External Signals](../integration/EXTERNAL_SIGNALS.md) - Signal requirements
- [State Management](../architecture/STATE_MANAGEMENT.md) - Data flow
- [Performance Requirements](../requirements/PERFORMANCE.md) - Latency targets
