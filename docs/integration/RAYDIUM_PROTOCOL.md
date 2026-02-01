# Raydium Protocol Integration

> **Navigation**: [Integration](./README.md) | [Documentation Root](../README.md)

This document specifies the Raydium CLMM protocol integration.

---

## Overview

Raydium is a Solana-based automated market maker (AMM). The system interacts with Raydium's Concentrated Liquidity Market Maker (CLMM) pools for position management.

---

## Required Operations

### Position Management

| Operation | Purpose |
|-----------|---------|
| Create position | Establish new liquidity position with tick range |
| Add liquidity | Increase liquidity in existing position |
| Remove liquidity | Decrease liquidity in existing position |
| Close position | Remove all liquidity and close position |
| Collect fees | Harvest accumulated trading fees |

### State Queries

| Query | Purpose |
|-------|---------|
| Position info | Current liquidity, tick range, uncollected fees |
| Pool state | Current tick, liquidity distribution, fee rate |
| Token balances | Tokens held in position |

---

## Transaction Construction

Each operation requires constructing and signing a Solana transaction:

1. **Fetch current state** (blockhash, account data)
2. **Build instruction** using Raydium SDK or raw instruction encoding
3. **Estimate compute budget** for priority fee calculation
4. **Sign transaction** with wallet private key
5. **Submit transaction** via RPC
6. **Monitor confirmation** and handle failures

---

## Tick Mathematics

CLMM positions are defined by tick ranges. Key concepts:

| Concept | Description |
|---------|-------------|
| Tick | Discrete price point (price = 1.0001^tick) |
| Tick spacing | Minimum tick increment for pool |
| Lower tick | Bottom of position range |
| Upper tick | Top of position range |

**Conversion**:
- Price → Tick: `tick = floor(log(price) / log(1.0001))`
- Tick → Price: `price = 1.0001^tick`

---

## Slippage Considerations

Position operations may experience slippage:

| Operation | Slippage Source |
|-----------|-----------------|
| Add liquidity | Price movement during confirmation |
| Remove liquidity | Price movement during confirmation |
| Fee collection | None (fees are exact) |

**Mitigation**: Set appropriate slippage tolerance, simulate before submission.

---

## Security Considerations

| Concern | Mitigation |
|---------|------------|
| Private key exposure | Secure key management (see [Security](../requirements/SECURITY.md)) |
| Transaction malleability | Verify transaction after confirmation |
| Front-running | Priority fees, transaction simulation |
| Unauthorized transactions | Monitor for unexpected activity |

---

## Unresolved Questions

| Question | Status |
|----------|--------|
| Transaction confirmation strategy and retry logic | TBD |
| Priority fee calculation approach | TBD |
| Slippage tolerance parameters | TBD |
| Transaction simulation requirements | TBD |
| Concurrent transaction management | TBD |

---

## External Documentation

- Raydium CLMM documentation: https://docs.raydium.io/ (verify URL)
- Solana Program Library: https://spl.solana.com/

---

## Related Documents

- [Solana RPC](./SOLANA_RPC.md) - Transaction submission
- [Three-Range Model](../strategy/THREE_RANGE_MODEL.md) - Position strategy
- [Security Requirements](../requirements/SECURITY.md) - Key management
