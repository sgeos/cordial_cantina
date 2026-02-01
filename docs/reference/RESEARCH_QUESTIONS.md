# Research Questions

> **Navigation**: [Reference](./README.md) | [Documentation Root](../README.md)

This document enumerates open research questions that must be addressed for complete system design.

---

## Physical Modeling

### RQ1: Manifold Topology

**Question**: What is the appropriate dimensionality and topology for the Riemannian manifold representation?

**Impact**: Determines computational complexity and model expressiveness.

**Related**: [Manifold Representation](../physical_model/MANIFOLD_REPRESENTATION.md)

---

### RQ2: Metric Tensor

**Question**: How should the metric tensor be computed from market data to ensure meaningful geometric properties?

**Impact**: Determines whether geometric operations have market-relevant meaning.

**Related**: [Manifold Representation](../physical_model/MANIFOLD_REPRESENTATION.md)

---

### RQ3: Geodesic Computation

**Question**: What numerical methods provide stable and efficient geodesic computation for trajectory prediction?

**Impact**: Affects prediction accuracy and latency.

**Related**: [Physical Analogs](../physical_model/PHYSICAL_ANALOGS.md)

---

## Market Behavior

### RQ4: Cycle Detection

**Question**: Can daily and weekly cycles be detected algorithmically rather than assumed a priori?

**Impact**: Enables adaptive strategy rather than fixed assumptions.

**Related**: [Temporal Cycles](../physical_model/TEMPORAL_CYCLES.md)

---

### RQ5: Regime Identification

**Question**: How should the system detect and adapt to different market regimes where strategy performance may vary?

**Impact**: Prevents strategy failure during regime changes.

**Related**: [Hypotheses](../overview/HYPOTHESES.md)

---

## Strategy Optimization

### RQ6: Range Optimization

**Question**: What is the optimal width and spacing for the three liquidity ranges given capital constraints and expected volatility?

**Impact**: Directly affects fee generation and impermanent loss.

**Related**: [Three-Range Model](../strategy/THREE_RANGE_MODEL.md)

---

### RQ7: Rebalancing Frequency

**Question**: What is the optimal trade-off between rebalancing frequency and transaction costs?

**Impact**: Affects net profitability.

**Related**: [Rebalancing](../strategy/REBALANCING.md)

---

### RQ8: Withdrawal Timing

**Question**: Can unidirectional movement be predicted with sufficient accuracy to justify liquidity withdrawal?

**Impact**: Determines effectiveness of withdrawal as risk mitigation.

**Related**: [Liquidity Withdrawal](../strategy/LIQUIDITY_WITHDRAWAL.md)

---

## Performance

### RQ9: Capital Efficiency

**Question**: What is the expected capital efficiency compared to passive holding or alternative strategies?

**Impact**: Determines strategy viability.

**Related**: [Hypotheses](../overview/HYPOTHESES.md)

---

## Scaling

### RQ10: Multi-Pair Scaling

**Question**: How does the system scale to managing positions across multiple trading pairs simultaneously?

**Impact**: Affects growth potential and diversification.

**Related**: [Architecture](../architecture/README.md)

---

## Research Priority

| Question | Phase | Priority |
|----------|-------|----------|
| RQ1, RQ2, RQ3 | Phase 3 | High |
| RQ6, RQ7 | Phase 4 | High |
| RQ4, RQ5 | Phase 3-4 | Medium |
| RQ8 | Phase 4 | Medium |
| RQ9 | Phase 4-5 | Medium |
| RQ10 | Phase 6+ | Low |
