# Reverse Prompt

> **Navigation**: [Process](./README.md) | [Documentation Root](../README.md)

This file is the AI-to-human communication channel. It is overwritten after each completed task.

---

## Last Updated

**Date**: 2026-02-16
**Task**: Document V0.2 Decisions in Knowledge Graph
**Macro-milestone**: V0.2 Market Data

---

## Verification

### Build
**Command**: `mix compile --force`
**Result**: Verified by human pilot (per PROMPT.md comments)

### Tests
**Command**: `mix test`
**Result**: PASS - 59 tests, 0 failures (per PROMPT.md comments)

### Server
**Command**: `iex -S mix phx.server`
**Result**: Starts and runs without errors (per PROMPT.md comments)

---

## Completed Tasks

### 1. Documented Decisions in Knowledge Graph

Added six new resolved decisions (R13-R18):

| Decision | Summary |
|----------|---------|
| **R13** | Birdeye WebSocket data ingestion (not REST polling) |
| **R14** | Rust rolling correlation calculations using ndarray |
| **R15** | Yahoo Finance direct HTTP for TradFi (no Python dependency) |
| **R16** | Birdeye API configuration (1 RPS free tier, wBTC token addresses) |
| **R17** | MSTR as sentiment proxy signal (Priority 4) |
| **R18** | 10-Year Treasury Yield as macro signal (daily, not minute-level) |

### 2. Verified Birdeye Rate Limits

**Critical Finding**: The free tier rate limit is **1 RPS**, not 60 RPS.

| Tier | Rate Limit | Price |
|------|-----------|-------|
| Standard (Free) | 1 rps | Free |
| Lite | 15 rps | $39/mo |
| Starter | 15 rps | $99/mo |
| Premium | 50 rps | $199/mo |

**Implication**: WebSocket is essential to stay within rate limits. REST polling at sub-10-second intervals would exceed the free tier.

### 3. Identified BTC Token Addresses on Solana

| Token | Address | Notes |
|-------|---------|-------|
| Wrapped BTC (Portal) | `3NZ9JMVBmGAqocybic2c7LQCJScmgsAZ6vQqTDzcqmJh` | Higher liquidity |
| Wrapped Bitcoin (Sollet) | `9n4nbM75f5Ui33ZbPYXn59EwSgE8CGsHtAeTH5YFeJ9E` | Alternative |

---

## V0.2 Blocker Analysis

### Open GitHub Issues

| Issue | Title | Status | Blockers |
|-------|-------|--------|----------|
| #11 | V0.2-M3: Real-time Price Feed Ingestion | Open | None (decisions resolved) |
| #12 | V0.2-M4: Order Book Snapshots | Open | Depends on #11 |
| #13 | V0.2-M5: Signal Validation | Open | Depends on #11, #12 |
| #14 | V0.2-M6: Mnesia to PostgreSQL Offload | Open | Depends on #11, #12 |

### Critical Path

```
#11 (Price Feed) → #12 (Order Book) → #13 (Signal Validation)
                                    ↘ #14 (Mnesia Offload)
```

**Issue #11 is unblocked.** All key decisions have been resolved:
- Data ingestion: WebSocket (R13)
- Rate limits: 1 RPS verified (R16)
- BTC token: Portal wBTC identified (R16)

### Remaining Decision Points

#### 1. Birdeye WebSocket Endpoint Configuration

**Context**: Need to confirm exact WebSocket endpoints and subscription format.

**Suggestion**: Review Birdeye API documentation for WebSocket specifics. The existing `WebSocketClient` module provides the connection framework.

**Risk**: WebSocket may require paid tier or different authentication than REST API.

#### 2. Paid Tier Consideration

**Context**: 1 RPS free tier may be insufficient even with WebSocket.

| Scenario | Recommendation |
|----------|----------------|
| WebSocket sufficient | Stay on free tier |
| WebSocket requires paid | Consider Lite tier ($39/mo, 15 rps) |
| High-frequency needed | Consider Starter tier ($99/mo) |

**Suggestion**: Implement with free tier first. Upgrade if rate limits become blocking.

#### 3. wBTC Token Selection

**Context**: Two wrapped BTC options available.

| Token | Address | Recommendation |
|-------|---------|----------------|
| Portal wBTC | `3NZ9...cmJh` | **Primary** (higher liquidity per research) |
| Sollet wBTC | `9n4n...eJ9E` | Fallback |

**Suggestion**: Use Portal wBTC as primary. Support both for redundancy.

---

## No Obvious Choice Decisions

All major V0.2 decisions have been resolved. No decision points remain without a clear recommendation.

---

## Technical Concerns / Risks

### 1. Birdeye 1 RPS Limitation

**Risk**: Free tier may be too restrictive for real-time data needs.

**Mitigation**:
- WebSocket reduces REST API calls
- Caching layer for repeated queries
- Upgrade path to paid tier documented

### 2. Yahoo Finance API Stability

**Risk**: Direct HTTP to Yahoo Finance uses undocumented endpoints.

**Mitigation**:
- Same endpoints used by yfinance library (battle-tested)
- Implement retry logic with exponential backoff
- Monitor for endpoint changes
- Document fallback data sources

### 3. Rolling Correlation Complexity

**Risk**: Multiple concurrent window sizes increase computational load.

**Mitigation**:
- Rust NIF provides necessary performance
- ndarray enables efficient in-place operations
- Start with 3 window sizes, tune based on profiling

---

## Implementation Readiness Summary

| Component | Decision | Ready |
|-----------|----------|-------|
| BTC Price Source | Birdeye WebSocket | Yes |
| BTC Token | Portal wBTC | Yes |
| TradFi Source | Yahoo Finance HTTP | Yes |
| TradFi Tickers | NQ=F, DX-Y.NYB, ES=F, MSTR | Yes |
| Correlation Engine | Rust NIF + ndarray | Yes |
| Rate Limits | 1 RPS (free tier) | Documented |

**V0.2-M3 (Real-time Price Feed Ingestion) is ready to implement.**

---

## Intended Next Step

**Awaiting human direction** on:
1. Proceed with V0.2-M3 implementation using documented decisions
2. Confirm Portal wBTC as primary BTC token
3. Decision on Birdeye tier (start free, upgrade if needed)

---

## GitHub Status

### Open Issues (V0.2)
| Issue | Title | Status |
|-------|-------|--------|
| #11 | V0.2-M3: Real-time Price Feed Ingestion | Open |
| #12 | V0.2-M4: Order Book Snapshots | Open |
| #13 | V0.2-M5: Signal Validation | Open |
| #14 | V0.2-M6: Mnesia to PostgreSQL Offload | Open |

### Closed Issues (V0.2)
| Issue | Title | Status |
|-------|-------|--------|
| #9 | V0.2-M1: PostgreSQL/Ecto Setup | Closed |
| #10 | V0.2-M2: Mnesia Market Data Tables | Closed |

### Milestones
| Milestone | Status |
|-----------|--------|
| V0.1 Foundation | Complete (tagged v0.1.0) |
| V0.2 Market Data | 2/6 issues closed |

---

## Session Context

If you are a new AI session reading this file:

1. Check [GitHub Issues](https://github.com/sgeos/cordial_cantina/issues) for open tasks
2. V0.0 Process Definition: Complete (tagged v0.0.0)
3. V0.1 Foundation: Complete (tagged v0.1.0)
4. V0.2 Market Data: In progress (M1, M2 complete; M3-M6 open)
5. Primary tracking: GitHub Issues
6. Knowledge graph: 18 resolved decisions (R1-R18)
7. CI: Passing
8. Tests: 59 tests, 0 failures
9. Key V0.2 decisions resolved: WebSocket, Rust correlations, Yahoo Finance, rate limits
10. Wait for human prompt before proceeding
