# Reliability Requirements

> **Navigation**: [Requirements](./README.md) | [Documentation Root](../README.md)

This document specifies reliability and fault tolerance requirements.

---

## Availability Target

**Target**: 99.9% uptime over rolling 30-day periods

**Calculation**: 99.9% = maximum 43.2 minutes downtime per month

---

## Fault Tolerance

### OTP Supervision

All processes are supervised with defined restart strategies:

| Strategy | Use Case |
|----------|----------|
| `:one_for_one` | Independent processes |
| `:one_for_all` | Tightly coupled processes |
| `:rest_for_one` | Dependent process chains |

See [Supervision Tree](../architecture/SUPERVISION_TREE.md) for details.

### Restart Intensity

Supervisors have maximum restart intensity to prevent infinite restart loops:

| Severity | Restarts | Window |
|----------|----------|--------|
| Default | 3 | 5 seconds |
| Low | 1-2 | 30 seconds |
| Moderate | 5 | 60 seconds |

---

## Recovery

### Process Recovery

| Process Type | Recovery Time Target |
|--------------|---------------------|
| Stateless | < 1 second |
| Stateful (Mnesia) | < 5 seconds |
| Stateful (PostgreSQL) | < 30 seconds |
| External connection | < 60 seconds |

### System Recovery

| Scenario | Recovery Time Target |
|----------|---------------------|
| Single process crash | < 5 seconds |
| Subsystem failure | < 30 seconds |
| Full system restart | < 5 minutes |

---

## Zero-Downtime Operations

### Hot Code Upgrades

OTP releases enable hot code upgrades:

- Code changes without stopping the system
- State migration between versions
- Rollback capability

### Rolling Deployment

For multi-instance deployments:

- One instance upgraded at a time
- Traffic drained before upgrade
- Health checks before traffic restoration

---

## Maintenance Strategy

| Operation | Downtime |
|-----------|----------|
| Code deployment | None (hot upgrade) |
| Database migration | None (online migration) |
| Configuration change | None (runtime reload) |
| Hardware maintenance | Rolling (multi-instance) |

---

## Unresolved Questions

| Question | Status |
|----------|--------|
| Deployment automation and orchestration | TBD |
| Rollback procedures for failed upgrades | TBD |
| Testing strategy for upgrade procedures | TBD |

---

## Related Documents

- [Supervision Tree](../architecture/SUPERVISION_TREE.md) - Fault tolerance design
- [State Management](../architecture/STATE_MANAGEMENT.md) - Recovery sources
- [Testing Requirements](./TESTING.md) - Fault injection testing
