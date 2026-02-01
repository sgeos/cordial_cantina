# Position Establishment

> **Navigation**: [Strategy](./README.md) | [Documentation Root](../README.md)

This document specifies the asymmetric position initialization logic.

---

## Overview

Position initialization depends on the current price relative to the intended R_fee range. The strategy establishes different initial positions based on anticipated price movement direction.

---

## Scenario A: Current Price Below R_fee

**Condition**: Current market price is below the lower bound of R_fee.

**Initial state**:

| Range | Created | Funded | Asset |
|-------|---------|--------|-------|
| R_restock | Yes | No | (empty) |
| R_fee | Yes | Yes | Stable coin |
| R_exit | Yes | Yes | Stable coin |

**Rationale**: When price is below the target range, the system anticipates upward price movement. Stable coin positions in R_fee and R_exit will convert to meme coin as price rises through these ranges.

**Expected behavior**:
1. Price rises into R_fee → stable coin converts to meme coin, fees earned
2. Price rises into R_exit → remaining meme coin converts to stable coin
3. Price falls back → meme coin acquired in R_fee available for fee generation

---

## Scenario B: Current Price Above R_fee

**Condition**: Current market price is above the upper bound of R_fee.

**Initial state**:

| Range | Created | Funded | Asset |
|-------|---------|--------|-------|
| R_restock | Yes | Yes | Meme coin |
| R_fee | Yes | Yes | Meme coin |
| R_exit | Yes | No | (empty) |

**Rationale**: When price is above the target range, the system anticipates downward price movement. Meme coin positions in R_fee and R_restock will convert to stable coin as price falls through these ranges.

**Expected behavior**:
1. Price falls into R_fee → meme coin converts to stable coin, fees earned
2. Price falls into R_restock → remaining stable coin converts to meme coin
3. Price rises back → stable coin acquired in R_fee available for fee generation

---

## Scenario C: Current Price Within R_fee

**Condition**: Current market price is within R_fee bounds.

**Initial state**:

| Range | Created | Funded | Asset |
|-------|---------|--------|-------|
| R_restock | Yes | Partial | Stable coin |
| R_fee | Yes | Yes | Mixed (per CLMM math) |
| R_exit | Yes | Partial | Meme coin |

**Rationale**: When price is already in the target range, balanced positions prepare for movement in either direction.

---

## Unverified Assumptions

| Assumption | Risk if invalid |
|------------|-----------------|
| Price will eventually enter R_fee range | Positions remain inactive |
| Slippage during position creation is acceptable | Higher than expected costs |
| Gas costs are justified by expected returns | Negative ROI |

---

## Implementation Notes

Position creation on Raydium requires:
1. Computing tick boundaries for each range
2. Calculating required token amounts
3. Submitting position creation transactions
4. Monitoring for confirmation

See [Raydium Protocol](../integration/RAYDIUM_PROTOCOL.md) for integration details.

---

## Related Documents

- [Three-Range Model](./THREE_RANGE_MODEL.md) - Range definitions
- [Rebalancing](./REBALANCING.md) - Post-establishment inventory management
