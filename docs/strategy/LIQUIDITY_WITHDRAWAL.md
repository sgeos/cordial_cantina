# Liquidity Withdrawal

> **Navigation**: [Strategy](./README.md) | [Documentation Root](../README.md)

This document specifies the conditions and procedures for withdrawing all liquidity from the market.

---

## Overview

Liquidity withdrawal is a defensive action taken when market conditions indicate continued liquidity provision would result in significant losses. The system removes all positions from the AMM and holds assets until re-entry conditions are met.

---

## Withdrawal Trigger

**Primary trigger**: Detection of unidirectional price movement.

**Rationale**: Unidirectional movement causes adverse selection. Liquidity providers are systematically picked off by informed traders, resulting in impermanent loss that exceeds fee generation.

---

## Withdrawal Procedure

1. **Detection**: Signal aggregator identifies unidirectional movement pattern
2. **Decision**: Strategy engine confirms withdrawal is appropriate
3. **Execution**: All three positions are closed in sequence
4. **Monitoring**: Assets held in wallet, system monitors for re-entry conditions

### Transaction Sequence

```
1. Close R_restock position → receive assets
2. Close R_fee position → receive assets
3. Close R_exit position → receive assets
4. Verify all positions closed
5. Enter observation mode
```

---

## Re-Entry Conditions

The system re-establishes positions when:

1. Unidirectional movement has ceased
2. Market volatility has normalized
3. Sufficient time has elapsed since withdrawal

**Specific criteria**: TBD (see [Backlog](../decisions/BACKLOG.md))

---

## Emergency Withdrawal

In addition to algorithmic withdrawal, the system supports manual emergency withdrawal:

| Trigger | Action |
|---------|--------|
| Operator command | Immediate withdrawal of all positions |
| System health critical | Automatic withdrawal and halt |
| Network congestion extreme | Withdrawal with elevated priority fees |

---

## Unresolved Design Questions

| Question | Status |
|----------|--------|
| Quantitative definition of unidirectional movement | TBD |
| Detection algorithm and parameters | TBD |
| Re-entry criteria specification | TBD |
| Emergency withdrawal under network congestion | TBD |

---

## Unverified Assumptions

| Assumption | Risk if invalid |
|------------|-----------------|
| Unidirectional movement can be reliably detected before significant adverse selection | Losses before withdrawal |
| Transaction confirmation latency is acceptable for withdrawal execution | Delayed withdrawal |
| Gas costs for withdrawal and re-entry are justified | Excessive transaction costs |

---

## Related Documents

- [Three-Range Model](./THREE_RANGE_MODEL.md) - Range definitions
- [Physical Analogs](../physical_model/PHYSICAL_ANALOGS.md) - Movement detection signals
- [Raydium Protocol](../integration/RAYDIUM_PROTOCOL.md) - Position closure details
