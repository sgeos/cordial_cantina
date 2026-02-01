# Phase 6: Production

> **Navigation**: [Roadmap](./README.md) | [Documentation Root](../README.md)

---

## Objectives

Deploy to mainnet and validate strategy profitability with real capital.

---

## Deliverables

| Deliverable | Description |
|-------------|-------------|
| Mainnet deployment | Limited capital deployment |
| Performance validation | Against acceptance criteria |
| Operator documentation | Runbooks and procedures |
| Incident response | Documented procedures |

---

## Success Criteria

| Criterion | Validation |
|-----------|------------|
| 99.9% uptime over 30-day period | Monitoring |
| Strategy profitability validated | P&L metrics |
| Subscriber onboarding operational | End-to-end test |

**Note**: Strategy profitability is an unverified hypothesis.

---

## Dependencies

- Phase 5 complete (all integration functional)
- All acceptance criteria met (see [Acceptance Criteria](../requirements/ACCEPTANCE_CRITERIA.md))

---

## Deployment Stages

| Stage | Capital | Duration | Exit Criteria |
|-------|---------|----------|---------------|
| Limited | Minimal | 2+ weeks | Positive P&L, no critical issues |
| Scaled | Moderate | 4+ weeks | Consistent performance |
| Full | Target | Ongoing | Continuous monitoring |

---

## Operational Readiness

| Item | Status Required |
|------|-----------------|
| Monitoring dashboards | Operational |
| Alerting configured | Tested |
| On-call rotation | Established |
| Runbooks documented | Reviewed |
| Rollback procedures | Tested |

---

## Risk Mitigation

| Risk | Mitigation |
|------|------------|
| Strategy underperformance | Immediate capital reduction |
| System failure | Automatic position withdrawal |
| Security incident | Kill switch, key rotation |

---

## Related Documents

- [Acceptance Criteria](../requirements/ACCEPTANCE_CRITERIA.md) - Go/no-go checklist
- [Reliability Requirements](../requirements/RELIABILITY.md) - Uptime requirements
- [Risks](../reference/RISKS.md) - Risk register
