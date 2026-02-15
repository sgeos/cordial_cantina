# Reverse Prompt

> **Navigation**: [Process](./README.md) | [Documentation Root](../README.md)

This file is the AI-to-human communication channel. It is overwritten after each completed task.

---

## Last Updated

**Date**: 2026-02-15
**Task**: Knowledge Graph Update and Setup Instructions
**Macro-milestone**: V0.2 Market Data

---

## Verification

### Build
**Command**: `mix compile --force`
**Result**: Pending verification

### Tests
**Command**: `mix test`
**Result**: Pending verification (requires local PostgreSQL)

### Seeds
**Command**: `mix run priv/repo/seeds.exs`
**Result**: New file created, pending verification

---

## Completed Tasks

### 1. Updated Knowledge Graph with Blocker Decisions

Added two new resolved decisions:

**R11: TradFi Signal and Data Source Strategy**
- BTC price: Birdeye (current), CEX feed (future for lead-lag)
- TradFi Priority 1: Nasdaq 100 (NQ=F via yfinance)
- TradFi Priority 2: DXY (DX-Y.NYB via yfinance)
- TradFi Priority 3: S&P 500 (ES) as risk-sentiment filter
- Update frequencies: TradFi 1-min, BTC sub-10-sec
- Architecture: GenServer polling, ndarray for Rust correlations

**R12: PostgreSQL Development Setup**
- PostgreSQL required for local development
- Standard Phoenix/Ecto patterns adopted
- Setup instructions in README.md

**Updated Backlog Items**:
- B1 (Development Environment): Partially resolved
- B4 (Historical Data Sources): Partially resolved

### 2. Updated cordial_cantina/README.md

Added:
- Prerequisites section (Elixir, Erlang, Rust, PostgreSQL versions)
- Database setup instructions with ecto commands
- Seeds.exs execution command
- Database variables documentation

### 3. Created cordial_cantina/priv/repo/seeds.exs

Created idempotent seed script that populates:
- 10 SOL/USDC price feed records
- 10 BTC/USDC price feed records
- SOL/USDC order book snapshot
- BTC/USDC order book snapshot

---

## V0.2 Blocker Analysis

### Open GitHub Issues

| Issue | Title | Status | Blockers |
|-------|-------|--------|----------|
| #11 | V0.2-M3: Real-time Price Feed Ingestion | Open | None identified |
| #12 | V0.2-M4: Order Book Snapshots | Open | Depends on #11 |
| #13 | V0.2-M5: Signal Validation | Open | Depends on #11, #12 |
| #14 | V0.2-M6: Mnesia to PostgreSQL Offload | Open | Depends on #11, #12 |

### Critical Path

```
#11 (Price Feed) → #12 (Order Book) → #13 (Signal Validation)
                                    ↘ #14 (Mnesia Offload)
```

**Issue #11 (Real-time Price Feed Ingestion)** is the critical blocker. Once implemented, other issues can proceed in parallel or sequence.

### Decision Points with No Obvious Choice

#### 1. Birdeye WebSocket vs REST Polling

**Context**: V0.2-M3 requires real-time price data ingestion.

| Option | Pros | Cons |
|--------|------|------|
| WebSocket | Lower latency, server push | More complex connection management |
| REST Polling | Simpler implementation | Higher latency, rate limit concerns |

**Suggestion**: Start with REST polling at sub-10-second intervals. WebSocket can be added later if latency becomes an issue. The existing `CordialCantina.Integration.WebSocketClient` module provides scaffolding for future WebSocket use.

#### 2. Correlation Calculation Location

**Context**: Rolling correlations between BTC and TradFi signals are needed.

| Option | Pros | Cons |
|--------|------|------|
| Rust NIF (ndarray) | High performance, modify-in-place | More complex deployment |
| Elixir (Nx) | Simpler integration, BEAM ecosystem | May be slower for large windows |

**Suggestion**: Implement in Rust NIF using ndarray as recommended. The joltshark crate already exists and can be extended. Sub-1-second internal processing requires NIF performance.

#### 3. TradFi Data Source: yfinance vs IEX

**Context**: Need 1-minute TradFi data (NQ=F, DX-Y.NYB).

| Option | Pros | Cons |
|--------|------|------|
| yfinance | Free, well-documented | Python library (requires Erlang port or HTTP wrapper) |
| IEX Cloud | Native REST API | Paid service, additional dependency |
| Yahoo Finance direct | No Python dependency | Undocumented, may change |

**Suggestion**: Use Yahoo Finance via direct HTTP requests (same data as yfinance). The `Req` library is already a dependency. This avoids Python/port complexity while accessing the same data.

### Remaining Ambiguities

1. **Birdeye API rate limits**: What is the exact rate limit for the free tier? This determines polling frequency.

2. **BTC token pair on Birdeye**: Is `BTC/USDC` available on Solana DEXes via Birdeye, or should we use a wrapped BTC token (e.g., wBTC)?

3. **Correlation window sizes**: What time windows should be used for rolling correlations? (e.g., 5-min, 15-min, 1-hour)

---

## Incidental Findings

### Correlation Regime Shift (February 2026)

Research revealed significant correlation instability:
- BTC-Nasdaq correlation flipped from +0.80 to -0.43
- This is the fourth time in five years correlations have gone negative
- Historically, negative correlation periods have preceded major BTC turning points

**Implication**: The system should not assume fixed correlation coefficients. Rolling calculations are essential.

### MSTR as Sentiment Proxy

MicroStrategy (MSTR) holds 3.4% of total BTC supply. MSTR stock movements may provide a leading indicator for BTC sentiment in TradFi. The January 2026 MSCI decision created predictable volatility.

**Consideration**: MSTR could be added as a fourth TradFi signal (after S&P 500) in future phases.

### 10-Year Treasury Yield Assessment

Research indicates the 10-Year Treasury Yield operates on a different timeframe than Nasdaq/DXY correlations. It is more appropriate for daily/weekly regime detection rather than minute-level signals.

**Recommendation**: Defer 10-Year Treasury integration. Focus on Nasdaq and DXY for V0.3.

---

## Technical Concerns / Risks

### PostgreSQL Connection in Development

Developers without local PostgreSQL will see connection errors on startup. This is expected Phoenix behavior.

**Mitigation**: README now documents PostgreSQL as a prerequisite.

### Seeds Script Assumptions

The seeds script generates random sample data. This is appropriate for development but should not be run in production.

**Mitigation**: Seeds script includes warning comments.

---

## Intended Next Step

**Awaiting human direction** on:
1. Verification of changes (local `mix test` and `mix run priv/repo/seeds.exs`)
2. Decision on Birdeye polling vs WebSocket for V0.2-M3
3. Clarification on Birdeye API rate limits
4. Confirmation of BTC token pair availability on Birdeye/Solana
5. Decision on correlation window sizes

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
6. Knowledge graph: Updated with R11 (TradFi signals), R12 (PostgreSQL setup)
7. CI: Fixed (cargo-tarpaulin, PostgreSQL service)
8. Database: Standard Phoenix/Ecto patterns
9. Wait for human prompt before proceeding
