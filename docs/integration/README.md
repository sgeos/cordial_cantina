# Integration

> **Navigation**: [Documentation Root](../README.md)

This section specifies external system integration requirements.

---

## Contents

| Document | Description |
|----------|-------------|
| [Solana RPC](./SOLANA_RPC.md) | Blockchain interaction via RPC |
| [Raydium Protocol](./RAYDIUM_PROTOCOL.md) | AMM operations and position management |
| [External Signals](./EXTERNAL_SIGNALS.md) | Price feeds and market data sources |

---

## Integration Overview

The system integrates with external systems at three levels:

```
┌─────────────────────────────────────────────────────────┐
│                    Cordial Cantina                       │
└─────────────────────────────────────────────────────────┘
         │                    │                    │
         ▼                    ▼                    ▼
┌─────────────┐      ┌─────────────┐      ┌─────────────┐
│ Solana RPC  │      │   Raydium   │      │  External   │
│  (read/     │      │  Protocol   │      │   Signals   │
│   write)    │      │  (on-chain) │      │  (off-chain)│
└─────────────┘      └─────────────┘      └─────────────┘
         │                    │                    │
         ▼                    ▼                    ▼
┌─────────────────────────────────────────────────────────┐
│                   Solana Blockchain                      │
└─────────────────────────────────────────────────────────┘
```

---

## Integration Patterns

| System | Protocol | Direction | Latency Requirement |
|--------|----------|-----------|---------------------|
| Solana RPC | JSON-RPC, WebSocket | Bidirectional | < 500ms |
| Raydium | Solana transactions | Write | < 200ms to submission |
| Price feeds | WebSocket, REST | Read | < 1000ms |

---

## Related Sections

- [Architecture](../architecture/README.md) - How integrations fit into system design
- [Requirements](../requirements/README.md) - Performance and reliability requirements
- [Decisions](../decisions/README.md) - Integration-related decisions
