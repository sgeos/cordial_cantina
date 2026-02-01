# Three-Range Model

> **Navigation**: [Strategy](./README.md) | [Documentation Root](../README.md)

This document defines the three-range liquidity model that forms the core of the trading strategy.

---

## Range Definitions

### R_fee (General Fee Generation Range)

**Purpose**: Primary fee accumulation through liquidity provision.

**Characteristics**:
- Centered on high-confidence trading range
- Active when current price is within range bounds
- Primary objective is fee accumulation

**Behavior**: When price is within R_fee, the position earns trading fees from swaps that cross the provided liquidity.

---

### R_restock (Meme Coin Restock Range)

**Purpose**: Acquire meme coin at favorable (lower) prices.

**Characteristics**:
- Positioned below R_fee
- Active when price moves below R_fee lower bound
- Objective is to accumulate meme coin inventory

**Behavior**: When price enters R_restock, stable coin converts to meme coin as trades execute against the position.

---

### R_exit (Stable Coin Exit Range)

**Purpose**: Exchange meme coin for stable coin at favorable (higher) prices.

**Characteristics**:
- Positioned above R_fee
- Active when price moves above R_fee upper bound
- Objective is to realize gains by converting to stable coin

**Behavior**: When price enters R_exit, meme coin converts to stable coin as trades execute against the position.

---

## Range Invariants

The following invariants must always hold:

1. **Non-overlapping**: No price point belongs to more than one range
2. **Adjacent**: Ranges share boundaries with no gaps between them
3. **Ordered**: R_restock < R_fee < R_exit (by price)
4. **Capital distribution**: Total capital distributed across at most three positions

---

## Range Boundaries

```
Price
  ↑
  │  ┌─────────────────┐
  │  │    R_exit       │  ← High price: convert meme → stable
  │  ├─────────────────┤
  │  │    R_fee        │  ← Target range: earn fees
  │  ├─────────────────┤
  │  │   R_restock     │  ← Low price: convert stable → meme
  │  └─────────────────┘
  │
  └──────────────────────→ Time
```

---

## Unresolved Questions

The following questions are tracked in [Priority TBDs](../decisions/PRIORITY.md):

- Optimal range width selection
- Optimal range spacing
- Range adjustment frequency and triggers

See also [Research Questions](../reference/RESEARCH_QUESTIONS.md) for open research.

---

## Related Documents

- [Position Establishment](./POSITION_ESTABLISHMENT.md) - How positions are initialized
- [Rebalancing](./REBALANCING.md) - How inventory is redistributed
- [Raydium Protocol](../integration/RAYDIUM_PROTOCOL.md) - Implementation details
