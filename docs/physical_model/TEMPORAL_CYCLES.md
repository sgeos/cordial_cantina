# Temporal Cycles

> **Navigation**: [Physical Model](./README.md) | [Documentation Root](../README.md)

This document describes the temporal cycle modeling approach.

---

## Overview

The system assumes market behavior exhibits cyclical patterns at multiple timescales. These cycles modulate the physical model parameters and influence trading decisions.

---

## Daily Cycles

**Assumption**: Market behavior correlates with traditional finance (TradFi) regional activity.

### Trading Sessions

| Session | Approximate UTC | Expected Characteristics |
|---------|-----------------|-------------------------|
| Asia-Pacific (APAC) | 00:00 - 08:00 | Asian market influence |
| European Union (EU) | 08:00 - 16:00 | European market influence |
| United States (US) | 14:00 - 22:00 | US market influence, overlap with EU |
| Sydney gap | 22:00 - 00:00 | Reduced liquidity between US close and APAC open |

**Epistemic status**: Industry folklore with partial empirical support. Requires validation on specific trading pairs.

### Verification Requirements

- Statistical significance testing for cycle presence
- Correlation analysis between TradFi hours and crypto market behavior
- Regime detection for when cycles are present or absent

---

## Weekly Cycles

**Assumption**: Market behavior varies by day of week.

| Day | Expected Characteristics |
|-----|-------------------------|
| Monday | Information digest from weekend events |
| Tuesday - Thursday | Active trading period |
| Friday | Position elimination ahead of weekend |
| Weekend | Elevated volatility due to reduced liquidity |

**Epistemic status**: Industry folklore with partial empirical support. Requires validation on specific trading pairs.

### Verification Requirements

- Volume and volatility analysis by day of week
- Statistical significance testing
- Regime detection for when cycles are present or absent

---

## Longer-Term Cycles

The system acknowledges existence of longer temporal cycles without specific enumeration.

**Potential cycles**:
- Monthly (options expiration, salary payments)
- Quarterly (earnings seasons, fund rebalancing)
- Annual (tax events, seasonal patterns)
- Market-specific (halving cycles for Bitcoin)

---

## Cycle Integration

Cycles modulate the physical model:

1. **Parameter adjustment**: Physical model parameters vary by time-of-day and day-of-week
2. **Signal weighting**: Cycle phase affects confidence in predictions
3. **Range adjustment**: Optimal ranges may vary with expected volatility

---

## Unresolved Questions

| Question | Status |
|----------|--------|
| Which longer-term cycles to model explicitly | TBD |
| How to detect regime changes in cycle behavior | TBD |
| How to weight cycle signals against real-time price action | TBD |
| Can cycles be detected algorithmically vs. assumed a priori | Research question |

---

## Related Documents

- [Physical Analogs](./PHYSICAL_ANALOGS.md) - Quantities modulated by cycles
- [External Signals](../integration/EXTERNAL_SIGNALS.md) - Additional timing signals
- [Research Questions](../reference/RESEARCH_QUESTIONS.md) - Cycle detection research
