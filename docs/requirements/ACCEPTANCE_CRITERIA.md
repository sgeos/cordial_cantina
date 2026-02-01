# Acceptance Criteria

> **Navigation**: [Requirements](./README.md) | [Documentation Root](../README.md)

This document specifies acceptance criteria for production deployment.

---

## Overview

The system is considered ready for production deployment when **all** of the following criteria are met.

---

## Functional Requirements

| Criterion | Validation Method |
|-----------|-------------------|
| Three-range position management implemented | Unit tests, integration tests |
| Asymmetric position establishment verified | Testnet deployment |
| Rebalancing logic executes correctly | Multiple scenario tests |
| Liquidity withdrawal triggers function | Fault injection tests |
| Fee collection from subscribers operational | End-to-end test |

---

## Performance Requirements

| Criterion | Target | Validation Method |
|-----------|--------|-------------------|
| Signal-to-decision latency | < 100ms p95 | Load testing |
| Decision-to-execution latency | < 50ms p95 | Load testing |
| System uptime | 99.9% over 30-day testnet | Monitoring |

---

## Security Requirements

| Criterion | Validation Method |
|-----------|-------------------|
| Private keys never exposed in logs or network traffic | Code review, log audit |
| All transactions signed and validated before submission | Code review, tests |
| Access controls prevent unauthorized operations | Security testing |
| Security audit completed with no critical findings | External audit |

---

## Reliability Requirements

| Criterion | Validation Method |
|-----------|-------------------|
| OTP supervision recovers from simulated faults | Chaos engineering |
| State persistence and recovery tested | Failure scenario tests |
| Zero-downtime deployment procedures validated | Deployment drill |

---

## Validation Requirements

| Criterion | Target | Validation Method |
|-----------|--------|-------------------|
| Backtesting returns | Positive risk-adjusted | Multiple market regimes |
| Testnet profitability | Positive over significant period | Live testnet trading |
| Unit test coverage | 80% for critical paths | Coverage tool |
| Integration tests | Pass for all external interactions | CI pipeline |

---

## Go/No-Go Checklist

### Phase 5 → Phase 6 Transition

Before mainnet deployment with real capital:

- [ ] All functional requirements met
- [ ] All performance requirements met
- [ ] All security requirements met
- [ ] All reliability requirements met
- [ ] All validation requirements met
- [ ] Operator training completed
- [ ] Incident response procedures documented
- [ ] Rollback procedures tested
- [ ] Monitoring and alerting operational
- [ ] Legal review completed (if applicable)

---

## Unresolved Criteria

The following acceptance criteria require quantification:

| Criterion | Current Status |
|-----------|----------------|
| Backtesting Sharpe ratio minimum | TBD |
| Maximum acceptable drawdown | TBD |
| Testnet profitability duration | TBD |
| Capital scaling thresholds | TBD |

---

## Related Documents

- [Testing Requirements](./TESTING.md) - How criteria are validated
- [Roadmap](../roadmap/README.md) - When criteria apply
- [Risks](../reference/RISKS.md) - What criteria mitigate
