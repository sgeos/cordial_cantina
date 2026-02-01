# External Signals

> **Navigation**: [Integration](./README.md) | [Documentation Root](../README.md)

This document specifies external signal sources and ingestion requirements.

---

## Overview

The system ingests external market data to inform trading decisions. Signals include price data, order book snapshots, and correlated asset prices.

---

## Bitcoin Price Influence

**Assumption**: Bitcoin (BTC) price movements influence the broader cryptocurrency market including target trading pairs.

**Epistemic status**: Well-documented correlation for many assets, but magnitude and lag vary by pair.

### Verification Requirements

- Correlation analysis between BTC price and target pair prices
- Lead-lag analysis to determine temporal relationships
- Regime detection for when correlation is high or low

---

## Signal Types

### Real-Time Price Data

| Signal | Source | Latency Requirement |
|--------|--------|---------------------|
| Target pair price | On-chain (Raydium) | < 500ms |
| BTC price | CEX WebSocket | < 1000ms |
| ETH price (optional) | CEX WebSocket | < 1000ms |

### Order Book Data

| Signal | Source | Frequency |
|--------|--------|-----------|
| Target pair order book | On-chain or aggregator | TBD |
| BTC order book (optional) | CEX API | TBD |

### Derived Signals

| Signal | Computation |
|--------|-------------|
| Funding rate | From perpetual markets |
| Open interest | From derivatives exchanges |
| Volume | Aggregated from multiple sources |

---

## Signal Ingestion Requirements

**Throughput targets**:
- 1000 price updates per second
- 100 order book snapshots per second

**Latency targets**:
- BTC price updates: < 1000ms end-to-end
- Target pair price updates: < 500ms end-to-end

---

## Data Quality

### Validation

All incoming signals require validation:

| Check | Action on Failure |
|-------|-------------------|
| Timestamp freshness | Mark signal stale, use last known good |
| Value bounds | Reject outliers, log anomaly |
| Source consistency | Cross-reference multiple sources |
| Sequence gaps | Log and interpolate if acceptable |

### Staleness

Signals become stale after configured thresholds:

| Signal Type | Stale After |
|-------------|-------------|
| Price | 5 seconds |
| Order book | 30 seconds |
| Funding rate | 5 minutes |

**Action on stale signals**: Reduce confidence, potentially pause trading.

---

## Unresolved Questions

| Question | Status |
|----------|--------|
| Complete enumeration of required signals | TBD |
| Data source selection and redundancy | TBD |
| Data validation and sanity checking procedures | TBD |
| Handling of stale, missing, or conflicting data | TBD |

---

## Related Documents

- [Temporal Cycles](../physical_model/TEMPORAL_CYCLES.md) - Time-based signal modulation
- [Performance Requirements](../requirements/PERFORMANCE.md) - Latency budgets
- [Supervision Tree](../architecture/SUPERVISION_TREE.md) - Feed process design
