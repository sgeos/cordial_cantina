# Roadmap

> **Navigation**: [Documentation Root](../README.md)

This section specifies the development roadmap for Cordial Cantina.

---

## Contents

| Document | Description |
|----------|-------------|
| [Phase 1: Foundation](./PHASE_1_FOUNDATION.md) | Core application structure |
| [Phase 2: Market Data](./PHASE_2_MARKET_DATA.md) | Signal ingestion |
| [Phase 3: Physical Model](./PHASE_3_PHYSICAL_MODEL.md) | Manifold implementation |
| [Phase 4: Strategy](./PHASE_4_STRATEGY.md) | Trading logic |
| [Phase 5: Integration](./PHASE_5_INTEGRATION.md) | Live blockchain integration |
| [Phase 6: Production](./PHASE_6_PRODUCTION.md) | Mainnet deployment |

---

## Phase Overview

```
Phase 1        Phase 2        Phase 3        Phase 4        Phase 5        Phase 6
Foundation  →  Market Data →  Physical   →   Strategy   →  Integration → Production
                              Model

OTP setup      Price feeds    Manifold       Position       Raydium        Mainnet
Rust NIFs      Order books    computation    management     integration    deployment
Solana RPC     Validation     Physics        Rebalancing    Transactions   Monitoring
Test infra     Persistence    analogs        Withdrawal     Fee collection Operations
```

---

## Current Status

**Current Phase**: Pre-Phase 1 (Specification)

**Blocking items**: See [Priority TBDs](../decisions/PRIORITY.md)

---

## Phase Dependencies

```
Phase 1 ─────┬───────────────────────────────────────────────────────────────►
             │
Phase 2 ─────┴───────┬───────────────────────────────────────────────────────►
                     │
Phase 3 ─────────────┴───────┬───────────────────────────────────────────────►
                             │
Phase 4 ─────────────────────┴───────┬───────────────────────────────────────►
                                     │
Phase 5 ─────────────────────────────┴───────┬───────────────────────────────►
                                             │
Phase 6 ─────────────────────────────────────┴───────────────────────────────►
```

Each phase builds on the previous. Phases cannot be skipped.

---

## Related Sections

- [Decisions](../decisions/README.md) - Phase-blocking decisions
- [Requirements](../requirements/README.md) - Phase validation criteria
- [Acceptance Criteria](../requirements/ACCEPTANCE_CRITERIA.md) - Production readiness
