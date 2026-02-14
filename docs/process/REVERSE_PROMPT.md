# Reverse Prompt

> **Navigation**: [Process](./README.md) | [Documentation Root](../README.md)

This file is the AI-to-human communication channel. It is overwritten after each completed task.

---

## Last Updated

**Date**: 2026-02-14
**Task**: V0.2 Preparation Sprint
**Macro-milestone**: V0.2 Market Data

---

## Verification

### Build
**Command**: `mix compile --force`
**Result**: PASS - 28 modules compiled

### Tests
**Command**: `mix test`
**Result**: PASS - 59 tests, 0 failures

### V0.2 Issues Created
- Issue #9: V0.2-M1 PostgreSQL/Ecto Setup (CLOSED)
- Issue #10: V0.2-M2 Mnesia Market Data Tables (CLOSED)
- Issue #11: V0.2-M3 Real-time Price Feed Ingestion
- Issue #12: V0.2-M4 Order Book Snapshots
- Issue #13: V0.2-M5 Signal Validation
- Issue #14: V0.2-M6 Mnesia to PostgreSQL Offload

---

## Completed Tasks

### 1. Renamed MILESTONE.md to TASKLOG.md
- File renamed via git mv
- Updated all knowledge graph references in:
  - PROCESS_STRATEGY.md
  - DOCUMENTATION_STRATEGY.md
  - process/README.md

### 2. Documented B2 Decision (Broadway)
- Updated BACKLOG.md to mark B3 (Message Queue Selection) as resolved
- Added R10 to RESOLVED.md documenting Broadway decision
- Broadway selected over external message brokers (RabbitMQ/Kafka)

### 3. Updated Knowledge Graph for Rust Project
- Updated TEMPORAL_CYCLES.md with joltshark cyclic signal functions
- Updated TECHNOLOGY_STACK.md with joltshark capabilities
- Documented: cycle_interpolate, event_pulse, in_modular_range, range_map_modular

### 4. Defined Mnesia Market Data Schema
- Created `CordialCantina.Mnesia.Schema` module
- Defined `:price_feed` table (OHLCV data)
- Defined `:order_book` table (order book snapshots)
- Updated Mnesia.Server to create tables on startup

### 5. Added PostgreSQL/Ecto
- Added ecto_sql and postgrex dependencies
- Created `CordialCantina.Repo` module
- Created `CordialCantina.MarketData.PriceFeed` schema
- Created `CordialCantina.MarketData.OrderBook` schema
- Created database migration
- Conditional startup via POSTGRES_ENABLED config

### 6. Added Broadway
- Added broadway dependency
- Created `CordialCantina.Pipeline.MarketDataPipeline`
- Pipeline processes market data with back-pressure and batching

### 7. Added mint WebSocket Client
- Added mint_web_socket dependency
- Created `CordialCantina.Integration.WebSocketClient`
- Supports connection management, reconnection, and PubSub broadcasting

### 8. Created V0.2 GitHub Issues
- Created issues #9-#14 for V0.2 milestones
- Closed #9 and #10 as completed

---

## B3 Partial Decision: Historical Data Sources

### User Requirements

From PROMPT.md:
- BTC price
- Upstream TradFi signals likely to influence the BTC price
- Keep data source dependencies streamlined and minimal

### Recommended Data Sources

#### BTC Price Data

| Source | Type | Notes |
|--------|------|-------|
| **Birdeye** | API | Already integrated for SOL/USDC. Can fetch BTC pairs. |
| **CoinGecko** | API | Free tier available. Widely used. Rate-limited. |
| **Binance** | API/WebSocket | High liquidity. Real-time via WebSocket. |

**Recommendation**: Use Birdeye for BTC price data since the integration already exists. Birdeye supports BTC trading pairs on Solana DEXes.

#### Upstream TradFi Signals

| Signal | Source | Rationale |
|--------|--------|-----------|
| **S&P 500 Futures (ES)** | Yahoo Finance API | Correlation with crypto risk appetite |
| **US Dollar Index (DXY)** | FRED API | Inverse correlation with BTC |
| **10-Year Treasury Yield** | FRED API | Risk-free rate benchmark |
| **VIX (Fear Index)** | Yahoo Finance API | Market volatility indicator |

**Minimal Dependency Approach**:

1. **Primary**: Birdeye (already integrated)
   - BTC/USDC price on Solana DEXes
   - SOL/USDC (current integration)

2. **Secondary**: FRED API (Federal Reserve Economic Data)
   - DXY (US Dollar Index)
   - 10-Year Treasury Yield
   - Free, reliable, rate-limited

3. **Optional**: Yahoo Finance (via yfinance library or direct)
   - S&P 500 Futures
   - VIX

### Implementation Suggestion

```
Phase 1 (V0.2): BTC price via Birdeye
Phase 2 (V0.3+): Add FRED API for macro signals
```

### Questions for Human Pilot

1. **BTC via Birdeye**: Is BTC price on Solana DEXes sufficient, or do you need centralized exchange (CEX) BTC/USD prices?

2. **TradFi Signal Priority**: Which TradFi signals are most important?
   - [ ] DXY (US Dollar Index)
   - [ ] 10-Year Treasury Yield
   - [ ] S&P 500 / Equity Index
   - [ ] VIX

3. **Update Frequency**: What frequency is needed for TradFi signals?
   - Real-time (every minute)
   - Hourly
   - Daily

---

## Technical Concerns / Risks

### PostgreSQL Conditional Startup

PostgreSQL is now optional via `POSTGRES_ENABLED` config. In test environment, PostgreSQL is disabled by default to allow tests to run without a database.

**Risk**: Developers may forget to enable PostgreSQL in development.

**Mitigation**: Clear documentation in .env.example.

### WebSocket Client Not Yet Connected

The WebSocket client is implemented but not connected to any real data source. Actual Birdeye WebSocket endpoints need to be confirmed.

---

## Intended Next Step

**Awaiting human direction** on:
- B3 data source selection
- BTC price source preference
- TradFi signal priorities
- V0.2-M3 implementation start

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
4. V0.2 Market Data: In progress (M1, M2 complete)
5. Primary tracking: GitHub Issues
6. B3 (Historical Data Sources): Partially resolved, awaiting human input
7. Wait for human prompt before proceeding
