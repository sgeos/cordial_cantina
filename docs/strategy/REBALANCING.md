# Rebalancing

> **Navigation**: [Strategy](./README.md) | [Documentation Root](../README.md)

This document specifies the rebalancing logic for redistributing inventory across ranges.

---

## Overview

Rebalancing redistributes assets between ranges to maintain optimal position sizing. The specific rebalancing actions depend on which range is currently active (contains the current price).

---

## R_fee Active State

**Condition**: Current price is within R_fee bounds.

**Actions**:
- R_restock is topped off with stable coin from accumulated fees or R_exit
- R_exit is topped off with meme coin from accumulated fees or R_restock

**Purpose**: Prepare outer ranges for price movement in either direction while price generates fees in the central range.

---

## R_restock Active State

**Condition**: Current price is within R_restock bounds (below R_fee).

**Actions**:
- Meme coin acquired in R_restock is rebalanced between R_fee and R_exit
- Stable coin is concentrated in R_restock to continue accumulating meme coin

**Purpose**: Distribute acquired meme coin to ranges where it will generate fees (R_fee) or be sold at higher prices (R_exit).

---

## R_exit Active State

**Condition**: Current price is within R_exit bounds (above R_fee).

**Actions**:
- Stable coin acquired in R_exit is rebalanced between R_fee and R_restock
- Meme coin is concentrated in R_exit to continue exchanging for stable coin

**Purpose**: Distribute acquired stable coin to ranges where it will generate fees (R_fee) or buy meme coin at lower prices (R_restock).

---

## Unresolved Design Questions

The following questions are tracked in [Backlog](../decisions/BACKLOG.md):

| Question | Impact |
|----------|--------|
| Rebalancing trigger thresholds | When to initiate rebalancing |
| Proportional allocation rules | How much to allocate to each range |
| Gas cost optimization | Batching vs immediate rebalancing |
| Rebalancing frequency limits | Prevent excessive transaction costs |

---

## Transaction Flow

```
┌─────────────────────────────────────────────────────────┐
│                  Rebalancing Decision                    │
└─────────────────────────────────────────────────────────┘
                           │
                           ▼
              ┌────────────────────────┐
              │ Calculate target       │
              │ allocations per range  │
              └────────────────────────┘
                           │
                           ▼
              ┌────────────────────────┐
              │ Calculate required     │
              │ withdrawals/deposits   │
              └────────────────────────┘
                           │
                           ▼
              ┌────────────────────────┐
              │ Withdraw from source   │
              │ positions              │
              └────────────────────────┘
                           │
                           ▼
              ┌────────────────────────┐
              │ Deposit to target      │
              │ positions              │
              └────────────────────────┘
```

---

## Related Documents

- [Three-Range Model](./THREE_RANGE_MODEL.md) - Range definitions
- [Liquidity Withdrawal](./LIQUIDITY_WITHDRAWAL.md) - Emergency withdrawal
- [Raydium Protocol](../integration/RAYDIUM_PROTOCOL.md) - Transaction details
