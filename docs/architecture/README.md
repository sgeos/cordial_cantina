# Architecture

> **Navigation**: [Documentation Root](../README.md)

This section specifies the technical architecture of Cordial Cantina.

---

## Contents

| Document | Description |
|----------|-------------|
| [Technology Stack](./TECHNOLOGY_STACK.md) | Languages, frameworks, and tools |
| [Supervision Tree](./SUPERVISION_TREE.md) | OTP process hierarchy and fault tolerance |
| [Data Storage](./DATA_STORAGE.md) | Mnesia and PostgreSQL architecture |
| [State Management](./STATE_MANAGEMENT.md) | Hot and cold data flow |

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                        Cordial Cantina                           │
├─────────────────────────────────────────────────────────────────┤
│  Phoenix/LiveView (Web UI)                                       │
├─────────────────────────────────────────────────────────────────┤
│  OTP Supervision Trees (Fault Tolerance)                         │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐   │
│  │ Market  │ │Strategy │ │Blockchain│ │  Data   │ │   RPC   │   │
│  │  Data   │ │ Engine  │ │  Ops    │ │ Offload │ │  Mgmt   │   │
│  └─────────┘ └─────────┘ └─────────┘ └─────────┘ └─────────┘   │
├─────────────────────────────────────────────────────────────────┤
│  Rust NIFs (joltshark) - Numerical Computation                   │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────────────┐    ┌─────────────────────┐             │
│  │   Mnesia (Hot)      │    │  PostgreSQL (Cold)  │             │
│  │   ram_copies        │───▶│  Historical data    │             │
│  └─────────────────────┘    └─────────────────────┘             │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
                    ┌─────────────────┐
                    │ Solana / Raydium│
                    └─────────────────┘
```

---

## Design Principles

| Principle | Implementation |
|-----------|----------------|
| Fault tolerance | OTP supervision trees with defined restart strategies |
| Performance | Rust NIFs for computation, Mnesia for hot data |
| Durability | PostgreSQL for historical data and audit trails |
| Observability | Telemetry events, structured logging |
| Modularity | Separated concerns via supervisor boundaries |

---

## Related Sections

- [Requirements](../requirements/README.md) - Performance and reliability constraints
- [Integration](../integration/README.md) - External system connections
- [Decisions](../decisions/README.md) - Architectural decision records
