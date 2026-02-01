# Physical Analogs

> **Navigation**: [Physical Model](./README.md) | [Documentation Root](../README.md)

This document defines the physical quantities used to describe market dynamics.

---

## Overview

Market dynamics are described using analogs from classical mechanics. These quantities provide intuitive vocabulary for market behavior and enable trajectory prediction using established physics.

---

## Defined Quantities

### Velocity

**Definition**: First time derivative of position on manifold.

**Market interpretation**: Rate of price change. Positive velocity indicates upward price movement.

**Use**: Trend detection, momentum signals.

---

### Acceleration

**Definition**: Second time derivative of position on manifold.

**Market interpretation**: Rate of change of price velocity. Positive acceleration indicates strengthening upward movement or weakening downward movement.

**Use**: Trend strength assessment, reversal detection.

---

### Jolt

**Definition**: Third time derivative of position on manifold.

**Market interpretation**: Rate of change of acceleration. Indicates how quickly momentum is building or dissipating.

**Use**: Early warning of regime change, volatility prediction.

---

### Kinetic Energy

**Definition**: Represents market momentum. Proportional to velocity squared.

**Formula**: KE = ½mv² (where m is an effective "mass" parameter)

**Market interpretation**: High kinetic energy indicates strong directional movement.

**Use**: Position sizing, withdrawal triggers.

---

### Potential Energy

**Definition**: Represents price position relative to equilibrium or resistance/support levels.

**Market interpretation**: Price far from equilibrium has high potential energy and may "fall back" toward equilibrium.

**Use**: Range boundary detection, mean reversion signals.

---

### Total Energy

**Definition**: Sum of kinetic and potential energy.

**Conservation**: In idealized markets, total energy is conserved during price evolution. Energy injection (news, large orders) changes total energy.

**Use**: Detecting external shocks, regime identification.

---

## Orbital Mechanics Analog

Price trajectories near support/resistance levels can be modeled as orbits around gravitational attractors.

**Support levels**: Gravitational wells that attract price
**Resistance levels**: Gravitational wells above current price

**Orbital types**:
- Bound orbit: Price oscillates around level
- Escape trajectory: Price breaks through level
- Capture: Price settles at new equilibrium

---

## Unresolved Implementation Questions

| Question | Impact |
|----------|--------|
| Discretization and sampling rates for derivative estimation | Noise vs. responsiveness tradeoff |
| Noise filtering and smoothing techniques | Signal quality |
| Numerical integration methods for trajectory prediction | Prediction accuracy |
| Error bounds and stability analysis | Reliability of predictions |

---

## Related Documents

- [Manifold Representation](./MANIFOLD_REPRESENTATION.md) - Underlying geometry
- [Temporal Cycles](./TEMPORAL_CYCLES.md) - Time-varying effects
- [Liquidity Withdrawal](../strategy/LIQUIDITY_WITHDRAWAL.md) - Using energy for decisions
