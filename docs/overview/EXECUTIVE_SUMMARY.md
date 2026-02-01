# Executive Summary

> **Navigation**: [Overview](./README.md) | [Documentation Root](../README.md)

---

This specification describes a concentrated liquidity market maker (CLMM) trading system that applies physical modeling concepts from Riemannian geometry and classical mechanics to predictive market dynamics. The system implements inventory-aware trading strategies across three non-overlapping adjacent price ranges on automated market maker (AMM) platforms. The implementation leverages Phoenix, Elixir, LiveView, and OTP for fault-tolerant orchestration with Rust-based Native Implemented Functions (NIFs) for performance-critical computation.

---

## Key Characteristics

| Aspect | Description |
|--------|-------------|
| **Domain** | Decentralized finance (DeFi) liquidity provision |
| **Blockchain** | Solana |
| **Protocol** | Raydium CLMM |
| **Modeling approach** | Riemannian manifold with physical analogs |
| **Architecture** | OTP supervision trees for fault tolerance |
| **Target availability** | 99.9% uptime |

---

## Related Documents

- [Hypotheses](./HYPOTHESES.md) - Core assumptions being tested
- [Three-Range Model](../strategy/THREE_RANGE_MODEL.md) - Trading strategy details
- [Technology Stack](../architecture/TECHNOLOGY_STACK.md) - Implementation details
