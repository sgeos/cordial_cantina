# Hypotheses Under Test

> **Navigation**: [Overview](./README.md) | [Documentation Root](../README.md)

This document enumerates the core hypotheses that the Cordial Cantina project seeks to validate.

---

## Product Hypothesis

**Claim**: A profitable predictive market model can be constructed by representing market dynamics on a Riemannian manifold with physical analogs including orbital mechanics, kinetic energy, potential energy, velocity, acceleration, and jolt.

**Epistemic status**: Unverified hypothesis requiring empirical validation through backtesting and live trading data.

**Verification requirements**:
- Quantitative profit and loss metrics over statistically significant time periods
- Comparison against baseline strategies without physical modeling
- Sharpe ratio, maximum drawdown, and risk-adjusted return measurements

**Related documents**:
- [Manifold Representation](../physical_model/MANIFOLD_REPRESENTATION.md)
- [Physical Analogs](../physical_model/PHYSICAL_ANALOGS.md)

---

## Engineering Hypothesis

**Claim**: The Phoenix, Elixir, LiveView, and OTP stack combined with Rust-based NIFs provides sufficient robustness for trading bots requiring continuous 24/7 operation with zero downtime.

**Epistemic status**: Partially verified through industry adoption but unverified for this specific application.

**Verification requirements**:
- Uptime metrics exceeding 99.9% over continuous operation periods
- Mean time to recovery (MTTR) under fault injection scenarios
- Latency profiles under peak load conditions

**Related documents**:
- [Technology Stack](../architecture/TECHNOLOGY_STACK.md)
- [Reliability Requirements](../requirements/RELIABILITY.md)
- [Supervision Tree](../architecture/SUPERVISION_TREE.md)

---

## Unverified Assumptions

The following assumptions underpin the strategy but have not been validated:

### Market Behavior Assumptions

| Assumption | Risk if invalid |
|------------|-----------------|
| Price will eventually enter the target R_fee range | Positions remain inactive, no fee generation |
| Slippage during position creation is acceptable | Higher than expected costs |
| Gas costs are justified by expected returns | Negative ROI |
| Unidirectional movement can be reliably detected | Adverse selection, impermanent loss |
| Transaction confirmation latency is acceptable | Missed opportunities |

### Technical Assumptions

| Assumption | Risk if invalid |
|------------|-----------------|
| Physical analogs provide predictive power beyond statistical models | Strategy underperformance |
| Computational cost of manifold operations is justified | Latency budget exceeded |
| Numerical stability is achievable for required precision | Incorrect trading decisions |
| Rust NIFs provide sufficient performance | Computational bottlenecks |
| BEAM VM can handle required message passing throughput | System overload |

### External Assumptions

| Assumption | Risk if invalid |
|------------|-----------------|
| Raydium smart contracts are secure and audited | Capital loss |
| Solana network provides Byzantine fault tolerance | Transaction failures |
| Hosting provider provides adequate physical security | System compromise |

---

## Hypothesis Validation Strategy

1. **Phase 3**: Backtest physical modeling against historical data
2. **Phase 4**: Compare strategy performance against baseline
3. **Phase 5**: Testnet deployment with real-time validation
4. **Phase 6**: Mainnet deployment with limited capital

See [Roadmap](../roadmap/README.md) for phase details.
