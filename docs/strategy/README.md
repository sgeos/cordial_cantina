# Trading Strategy

> **Navigation**: [Documentation Root](../README.md)

This section specifies the trading strategy for Cordial Cantina.

---

## Contents

| Document | Description |
|----------|-------------|
| [Three-Range Model](./THREE_RANGE_MODEL.md) | Core three-range liquidity model (R_fee, R_restock, R_exit) |
| [Position Establishment](./POSITION_ESTABLISHMENT.md) | Asymmetric position initialization logic |
| [Rebalancing](./REBALANCING.md) | Rebalancing triggers and logic |
| [Liquidity Withdrawal](./LIQUIDITY_WITHDRAWAL.md) | Withdrawal triggers and procedures |

---

## Strategy Overview

The system maintains **three non-overlapping adjacent liquidity positions** on a CLMM platform:

| Range | Purpose | Active when |
|-------|---------|-------------|
| **R_fee** | Fee generation through liquidity provision | Price within range |
| **R_restock** | Acquire meme coin at favorable prices | Price below R_fee |
| **R_exit** | Exchange meme coin for stable coin | Price above R_fee |

### Invariants

- Ranges are non-overlapping
- Ranges are adjacent with no gaps
- Total capital is distributed across at most three positions

---

## Related Sections

- [Physical Model](../physical_model/README.md) - Predictive modeling approach
- [Integration](../integration/README.md) - Raydium protocol interaction
- [Requirements](../requirements/README.md) - Performance and reliability constraints
