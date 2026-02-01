# Requirements

> **Navigation**: [Documentation Root](../README.md)

This section specifies non-functional requirements for Cordial Cantina.

---

## Contents

| Document | Description |
|----------|-------------|
| [Performance](./PERFORMANCE.md) | Latency, throughput, and resource constraints |
| [Security](./SECURITY.md) | Threat model, key management, access control |
| [Reliability](./RELIABILITY.md) | Uptime, fault tolerance, recovery |
| [Testing](./TESTING.md) | Test strategy and coverage requirements |
| [Acceptance Criteria](./ACCEPTANCE_CRITERIA.md) | Go/no-go criteria for production |

---

## Requirements Overview

| Category | Key Metric | Target |
|----------|------------|--------|
| Performance | Signal-to-decision latency | < 100ms p95 |
| Performance | Decision-to-execution latency | < 50ms p95 |
| Security | Private key exposure | Never |
| Reliability | System uptime | 99.9% |
| Testing | Critical path coverage | 80% |

---

## Related Sections

- [Architecture](../architecture/README.md) - How requirements are met
- [Roadmap](../roadmap/README.md) - When requirements are validated
- [Decisions](../decisions/README.md) - Requirement-related decisions
