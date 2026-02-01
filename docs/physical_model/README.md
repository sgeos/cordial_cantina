# Physical Model

> **Navigation**: [Documentation Root](../README.md)

This section specifies the physical modeling approach used for market prediction.

---

## Contents

| Document | Description |
|----------|-------------|
| [Manifold Representation](./MANIFOLD_REPRESENTATION.md) | Riemannian geometry foundations |
| [Physical Analogs](./PHYSICAL_ANALOGS.md) | Energy, velocity, acceleration, jolt |
| [Temporal Cycles](./TEMPORAL_CYCLES.md) | Daily, weekly, and longer-term patterns |

---

## Approach Overview

The system models market state as a point on a **Riemannian manifold** where geometric properties encode market dynamics. Physical analogs from classical mechanics provide the vocabulary for describing and predicting market behavior.

**Core hypothesis**: Physical modeling provides predictive power beyond statistical approaches.

**Epistemic status**: Unverified. See [Hypotheses](../overview/HYPOTHESES.md).

---

## Conceptual Framework

```
Market State → Manifold Position → Physical Properties → Prediction
     │                │                   │                  │
     │                │                   │                  │
  Price data    Coordinates on      KE, PE, velocity,    Trading
  Order book    Riemannian          acceleration,        decision
  Volume        manifold            jolt
```

---

## Implementation

Physical modeling is implemented in the `joltshark` Rust crate as Native Implemented Functions (NIFs). This provides:

- Numerical precision for manifold computation
- Performance for real-time signal generation
- Separation of mathematical core from orchestration logic

See [Technology Stack](../architecture/TECHNOLOGY_STACK.md) for integration details.

---

## Related Sections

- [Strategy](../strategy/README.md) - How predictions drive trading decisions
- [Requirements](../requirements/README.md) - Latency and performance constraints
- [Research Questions](../reference/RESEARCH_QUESTIONS.md) - Open mathematical questions
