# Solana RPC Integration

> **Navigation**: [Integration](./README.md) | [Documentation Root](../README.md)

This document specifies the Solana blockchain integration via RPC.

---

## Overview

All blockchain interaction occurs through Solana RPC endpoints. The system requires both read operations (state queries) and write operations (transaction submission).

---

## Required Operations

### Read Operations

| Operation | Purpose | Frequency |
|-----------|---------|-----------|
| `getAccountInfo` | Query position state | On-demand |
| `getBalance` | Check wallet balances | Periodic |
| `getLatestBlockhash` | Transaction construction | Per transaction |
| `getSignatureStatuses` | Transaction confirmation | Per transaction |
| `getSlot` | Chain synchronization | Periodic |

### Write Operations

| Operation | Purpose | Frequency |
|-----------|---------|-----------|
| `sendTransaction` | Submit signed transactions | As needed |

### Subscriptions (WebSocket)

| Subscription | Purpose |
|--------------|---------|
| `accountSubscribe` | Real-time position updates |
| `signatureSubscribe` | Transaction confirmation |
| `slotSubscribe` | Block progression |

---

## Provider Selection

**Unresolved**: Primary and fallback RPC providers not yet selected.

**Candidates**:

| Provider | Strengths | Considerations |
|----------|-----------|----------------|
| Helius | Solana-focused, good rate limits | Cost |
| QuickNode | Multi-chain, reliable | Solana-specific features |
| Triton | Performance-focused | Availability |
| Self-hosted | Full control | Operational overhead |

See [Priority TBDs](../decisions/PRIORITY.md) for decision status.

---

## Failover Strategy

The system must handle RPC endpoint unavailability:

1. **Primary endpoint** handles all requests
2. **Health checks** detect primary failure
3. **Failover** redirects to secondary endpoint
4. **Recovery** returns to primary when healthy

**Pattern**: Circuit breaker with exponential backoff

---

## Rate Limiting

RPC providers impose rate limits. The system must:

- Track request counts per endpoint
- Implement request queuing
- Prioritize critical operations (transaction submission)
- Gracefully degrade non-critical operations

---

## Error Handling

| Error Type | Response |
|------------|----------|
| Rate limited | Backoff, retry |
| Timeout | Retry with different endpoint |
| Invalid response | Log, retry |
| Endpoint unavailable | Failover |
| Transaction failed | Log, notify, do not retry blindly |

---

## Unresolved Questions

| Question | Status |
|----------|--------|
| Which RPC provider(s) to use | TBD |
| Failover strategy details | TBD |
| Rate limit management approach | TBD |
| WebSocket reconnection policy | TBD |

---

## Related Documents

- [Raydium Protocol](./RAYDIUM_PROTOCOL.md) - Transaction construction
- [Supervision Tree](../architecture/SUPERVISION_TREE.md) - RPC process design
- [Reliability Requirements](../requirements/RELIABILITY.md) - Uptime expectations
