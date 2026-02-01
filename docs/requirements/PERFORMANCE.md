# Performance Requirements

> **Navigation**: [Requirements](./README.md) | [Documentation Root](../README.md)

This document specifies performance requirements.

---

## Latency Budgets

### Signal-to-Decision Latency

Time from external signal update to trading decision.

| Percentile | Target | Maximum |
|------------|--------|---------|
| p95 | < 100ms | - |
| p99 | - | < 500ms |

### Decision-to-Execution Latency

Time from trading decision to transaction submission.

| Percentile | Target | Maximum |
|------------|--------|---------|
| p95 | < 50ms | - |
| p99 | - | < 200ms |

**Note**: Network and blockchain confirmation latency is outside system control.

---

## Throughput Requirements

### Transaction Throughput

| Condition | Transactions/second |
|-----------|---------------------|
| Normal operation | 10 |
| Maximum burst | 50 |

### Signal Ingestion Throughput

| Signal Type | Target Rate |
|-------------|-------------|
| Price updates | 1000/second |
| Order book snapshots | 100/second |

---

## Resource Constraints

### CPU

**Target**: < 70% utilization during normal operation

**Rationale**: Headroom for load spikes and background tasks

### Memory

**Target**: TBD based on deployment environment

**Considerations**:
- Mnesia table sizing for sliding windows
- Rust NIF memory allocation
- BEAM VM overhead

### Network

**Target**: TBD based on signal sources and blockchain interaction

---

## Unverified Assumptions

| Assumption | Risk if invalid |
|------------|-----------------|
| Rust NIFs provide sufficient performance for computational bottlenecks | Latency budget exceeded |
| BEAM VM can handle required message passing throughput | System overload |
| These latency budgets provide competitive advantage | Strategy underperformance |

---

## Related Documents

- [Technology Stack](../architecture/TECHNOLOGY_STACK.md) - Performance-enabling technologies
- [Supervision Tree](../architecture/SUPERVISION_TREE.md) - Process design for performance
- [External Signals](../integration/EXTERNAL_SIGNALS.md) - Signal ingestion requirements
