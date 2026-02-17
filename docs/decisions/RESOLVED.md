# Resolved Decisions

> **Navigation**: [Decisions](./README.md) | [Documentation Root](../README.md)

This document records design decisions that have been fully resolved. Each entry includes the decision, rationale, and any residual sub-questions that remain open but do not block implementation.

## Document Status

**Created**: 2026-02-01
**Purpose**: Archive of resolved architectural decisions
**Related**: [Priority](./PRIORITY.md), [Backlog](./BACKLOG.md)

---

## R1. Database Architecture

**Resolved**: 2026-02-01
**Updated in**: SPECIFICATION.md v0.1.1-alpha

### Decision

Dual-database architecture:

| Layer | Technology | Purpose |
|-------|------------|---------|
| Hot data | Mnesia | In-memory time-series data for active trading decisions |
| Cold data | PostgreSQL via Ecto | Historical data storage, audit trails, analytics |

### Rationale

- Mnesia provides sub-millisecond access for latency-critical trading operations
- Mnesia integrates natively with OTP supervision and distribution
- Mnesia supports transparent failover in clustered deployments
- PostgreSQL provides durable storage with mature tooling for historical analysis
- Ecto provides schema migrations, query composition, and ecosystem compatibility
- Separation of concerns allows independent scaling and optimization

### Data Flow

1. Real-time market data ingested into Mnesia tables
2. Mnesia maintains sliding window of recent data for active trading
3. Data rotating out of Mnesia is either offloaded to PostgreSQL (if useful as historical metric) or dropped (if no immediate or future utility)
4. Historical data may also be sourced from third-party APIs or parsed from on-chain data
5. PostgreSQL serves historical queries, backtesting, and analytics workloads

### Mnesia Configuration

**Storage type**: `ram_copies` only

**Rationale**: Data in Mnesia is nominally ephemeral. The `ram_copies` mode is simpler than `disc_copies`, and PostgreSQL provides durable cold storage. This separation of concerns avoids the complexity of Mnesia disk persistence and schema migration.

**Fragmentation**: Parameterized. Fragmentation strategy is configurable and may require task-level optimization based on data volume and access patterns.

**Sliding window size**: Parameterized. Concrete window sizes are business logic specific and should be configurable per data type and trading strategy.

### Offload Strategy

**Trigger conditions**: Business logic and trading strategy specific. The offload mechanism supports multiple trigger strategies:
- Time-based (e.g., rotate data older than N minutes)
- Threshold-based (e.g., rotate when table exceeds N records)
- Hybrid approaches combining time and threshold

**Data disposition**: When data rotates out of Mnesia:
- Data with future historical utility is offloaded to PostgreSQL
- Data with no immediate or future utility is dropped

Concrete trigger parameters and data disposition rules are configured per data type.

### PostgreSQL Configuration

**Indexing**: Primary index on datetime for all time-series tables.

**Access pattern**: Data accessed via an abstract interface that could theoretically serve data across partitions. The interface design allows partitioning to be added as a future optimization without changing calling code.

**Partitioning**: Deferred. If partitioning is implemented in the future, date-based partitioning (daily, monthly, or annual) will likely make sense depending on data volume and observed bottlenecks.

**Rationale**: This approach prioritizes future-proofing and deferred complexity. Partitioning adds operational overhead and should only be implemented when data volume necessitates it.

### Residual Sub-Questions

The following remain open but do not block the architectural decision:

- Specific Mnesia table definitions (names, key structures, indices)
- Concrete default values for fragmentation and sliding window parameters
- PostgreSQL schema design for historical tables

These sub-questions are tracked in PRIORITY.md under "Mnesia Schema Design."

---

## R2. Mnesia Initialization Strategy

**Resolved**: 2026-02-02
**Related**: P1 in PRIORITY.md, R1 above

### Decision

**Strategy**: GenServer

Mnesia initialization will use a dedicated GenServer rather than a Task.

### Rationale

- GenServer provides supervision integration with restart semantics
- GenServer can maintain state about schema status and initialization progress
- GenServer enables health check queries from other processes
- GenServer supports graceful handling of first boot vs subsequent boot scenarios
- A Task is fire-and-forget and lacks the stateful coordination needed for schema management

### Implementation Guidance

The Mnesia GenServer should:
1. Initialize schema on first boot, join existing schema on subsequent boots
2. Expose health check function for readiness probes
3. Block dependent processes via Registry or PubSub until schema is ready
4. Handle node joins and schema synchronization in clustered deployments

### Residual Sub-Questions

The following remain open but do not block the initialization strategy:
- Specific table definitions (tracked in PRIORITY.md P6)
- Clustering synchronization details (tracked in PRIORITY.md P1.2)

---

## R3. OTP Supervision Operational Model

**Resolved**: 2026-02-02
**Related**: P1 in PRIORITY.md

### Decision

**Clustering model**: Single-node operation with optional redundancy.

| Aspect | Decision |
|--------|----------|
| Node topology | Single node by default |
| Multi-node redundancy | 100% redundancy per node (each node is self-sufficient) |
| Net split behavior | Nodes operate independently with available information |

**Position recovery**: Third-party APIs for historical data.

| Source | Purpose |
|--------|---------|
| Birdeye | Historical market data |
| DEX Screener | Historical market data |
| Local chain analysis | Deferred (non-trivial, not immediate priority) |

**Transaction persistence**: PostgreSQL with API verification.

| Aspect | Decision |
|--------|----------|
| Persistence layer | PostgreSQL |
| Recovery procedure | Check both database and API response |
| Ground truth sync | Re-verify past decisions (markets change during downtime) |

### Rationale

- Single-node simplifies initial development and debugging
- 100% redundancy avoids complex distributed state coordination
- Third-party APIs provide expedient historical data access
- PostgreSQL persistence enables recovery across restarts
- Re-verification handles market drift during downtime

### Residual Sub-Questions

- Specific Birdeye/DEX Screener API integration details (V0.2 scope)
- Concrete recovery verification logic (implementation detail)

---

## R4. Rust NIF Integration Strategy

**Resolved**: 2026-02-02
**Related**: P2 in PRIORITY.md

### Decision

| Aspect | Decision |
|--------|----------|
| Binding library | Rustler |
| API boundary | Defined iteratively during development |
| Error handling | Return errors to BEAM; safe Rust trusted |
| Panic handling | `catch_unwind` reserved for truly exceptional circumstances only |
| Scheduling | Synchronous by default; dirty schedulers for calls >1ms |
| Memory model | BEAM owns passed-in memory (read-only, zero-copy); Rustler conventions for Rust-to-BEAM |
| Build integration | Already working via Mix/Rustler |

### Rationale

- Rustler is mature, well-documented, and handles NIF safety concerns
- Iterative API definition allows boundary to emerge from requirements
- Safe Rust with no panic conditions can be trusted
- Mathematical code is expected to be expressible in safe Rust
- Dirty schedulers prevent scheduler blocking for expensive computations
- Zero-copy reads minimize overhead for BEAM-owned data

### Implementation Guidance

- Prefer returning Result types from NIF functions
- Structure code to avoid panics entirely; safe Rust should return errors, not panic
- Reserve `catch_unwind` for truly exceptional circumstances only (e.g., FFI boundaries with untrusted C code)
- Profile NIF calls; move to dirty scheduler if >1ms observed
- Use Rustler resource types for shared state across calls

### Residual Sub-Questions

- Specific API function signatures (emerge during implementation)
- Profiling thresholds for dirty scheduler migration (runtime tuning)

---

## R5. Solana RPC Strategy

**Resolved**: 2026-02-02
**Related**: P3 in PRIORITY.md

### Decision

| Aspect | Decision |
|--------|----------|
| V0.1 provider | Public RPC endpoints |
| Provider selection | Deferred until requirements clearer |
| Historical data | Birdeye API |
| Range management | Raydium API |

### Open Question

Is direct Solana RPC needed for V0.1, or is Birdeye + Raydium API sufficient?

**Tentative answer**: Birdeye + Raydium may be sufficient for initial development. Direct RPC may be needed for:
- Real-time transaction submission (V0.5+)
- On-chain state verification
- WebSocket subscriptions for live updates

This question will be answered during V0.1 implementation.

### Rationale

- Public RPC sufficient for read-only development
- Third-party APIs (Birdeye, Raydium) provide higher-level abstractions
- Deferring provider selection avoids premature optimization
- Requirements will crystallize during implementation

---

## R6. Secrets Management Strategy

**Resolved**: 2026-02-02
**Related**: P4 in PRIORITY.md

### Decision

| Environment | Strategy |
|-------------|----------|
| Development | `config/runtime.exs` with environment variables |
| Local secrets | `.env` files (gitignored) |
| Documentation | `.env.example` with safe dummy values |
| Production | Deferred until V1.0 release |

### Rationale

- Environment variables are standard Elixir practice
- `.env` files provide convenient local development
- `.env.example` documents required variables without exposing secrets
- Production secrets management (Vault, AWS Secrets Manager) adds complexity best deferred

### Implementation Guidance

1. Create `.env.example` with all required variables
2. Add `.env` to `.gitignore`
3. Load via `config/runtime.exs` using `System.get_env/1`
4. Never commit actual secrets

### Residual Sub-Questions

- Production secrets platform selection (V0.6 scope)
- Key rotation procedures (V0.6 scope)

---

## R7. Testing Framework Strategy

**Resolved**: 2026-02-02
**Related**: P5 in PRIORITY.md

### Decision

| Aspect | Decision |
|--------|----------|
| Coverage tool | excoveralls |
| Coverage target | 80% for critical paths; no hard target for V0.1 |
| Rust testing | `cargo test` for unit tests |
| Elixir NIF testing | ExUnit integration tests (happy + error paths) |
| RPC mocking | Bypass |
| CI pipeline | GitHub Actions (existing, iterative improvements) |

### Rationale

- excoveralls is the standard Elixir coverage tool
- 80% target for critical paths ensures core logic is tested
- Dual testing (Rust + Elixir) catches issues at both levels
- Bypass provides flexible HTTP mocking for RPC calls
- Existing CI pipeline works; changes made as needed

### Implementation Guidance

- Add excoveralls to mix.exs dependencies
- Configure coveralls.json for coverage reporting
- Write Elixir integration tests for all NIF functions
- Use Bypass to mock external API calls in tests

---

## R8. Mnesia Schema Strategy

**Resolved**: 2026-02-02
**Related**: P6 in PRIORITY.md

### Decision

**Approach**: Iterative schema definition.

| Aspect | Decision |
|--------|----------|
| Schema evolution | Define minimal tables for first feature |
| Table definitions | Emerge from implementation requirements |
| Versioning | Application config (not Ecto-style migrations) |

### Rationale

- Upfront schema design without concrete requirements leads to rework
- Iterative definition allows schema to match actual data needs
- ram_copies mode (see R1) simplifies schema changes

### Implementation Guidance

When adding a Mnesia table:
1. Define table in Mnesia GenServer initialization
2. Document table structure in code comments
3. Add table to schema version config
4. Write tests for table operations

### Residual Sub-Questions

- Specific table definitions (emerge during V0.1-V0.2)
- Default parameter values (tuned during implementation)

---

## R9. Logging and Observability Strategy

**Resolved**: 2026-02-02
**Related**: P7 in PRIORITY.md

### Decision

| Aspect | Decision |
|--------|----------|
| Logging library | Elixir Logger (built-in) |
| Format | Default format initially; JSON when needed |
| Telemetry | Emit events for RPC calls, NIF invocations, supervision events |
| Correlation | Add correlation IDs to log metadata |

### Rationale

- Built-in Logger is sufficient for initial development
- JSON formatting adds complexity; defer until log aggregation is needed
- Telemetry events enable future observability integration
- Correlation IDs support distributed tracing when needed

### Implementation Guidance

- Use Logger with metadata for context
- Define telemetry events in a central module
- Add correlation_id to process dictionary or metadata
- Consider JSON formatter when deploying to log aggregation

---

## R10. Message Queue Selection

**Resolved**: 2026-02-14
**Related**: B3 in BACKLOG.md (now resolved)

### Decision

| Aspect | Decision |
|--------|----------|
| Message processing | Broadway with GenStage |
| External broker | Not required for V0.2 |
| Data ingestion | Broadway pipelines for high-throughput market data |

### Rationale

- Broadway provides a unified interface for data ingestion with built-in back-pressure
- GenStage handles producer-consumer patterns within the BEAM
- External message brokers (RabbitMQ, Kafka) add operational complexity not justified at current scale
- Broadway integrates natively with OTP supervision trees
- Broadway supports batching, rate limiting, and graceful shutdown
- Can migrate to external broker later if throughput or durability requirements change

### Implementation Guidance

1. Define Broadway pipelines for each data source (e.g., Birdeye WebSocket, price feeds)
2. Use GenStage producers for internal event generation
3. Implement acknowledger callbacks for reliable processing
4. Configure batching based on data source characteristics
5. Monitor pipeline throughput via Telemetry events

### Residual Sub-Questions

- Specific pipeline configurations (emerge during V0.2 implementation)
- Batching parameters (tuned based on observed throughput)
- Acknowledger strategy for WebSocket data (implementation detail)

---

## R11. TradFi Signal and Data Source Strategy

**Resolved**: 2026-02-15
**Related**: B4 in BACKLOG.md (Historical Data Sources)

### Decision

| Aspect | Decision |
|--------|----------|
| Primary BTC price source | Birdeye (Solana DEX prices) |
| Future BTC price source | CEX feed (Coinbase/Binance) for lead-lag detection |
| TradFi Signal Priority 1 | Nasdaq 100 (NQ=F via yfinance) |
| TradFi Signal Priority 2 | DXY US Dollar Index (DX-Y.NYB via yfinance) |
| TradFi Signal Priority 3 | S&P 500 (ES) as risk-sentiment filter |
| TradFi update frequency | 1-minute (sufficient for lower volatility) |
| BTC update frequency | Sub-10-second (Birdeye polling) |
| Internal processing | Sub-1-second capable |

### Correlation Context (February 2026)

Research findings on market correlations:

| Relationship | Historical | Current (Feb 2026) | Notes |
|--------------|------------|---------------------|-------|
| BTC-Nasdaq 100 | ~0.62 to 0.80 | **-0.43** (negative) | Regime shift since Oct 2025 crash |
| BTC-DXY | -0.4 to -0.8 | ~-0.45 | Traditionally inverse, but evolving |
| BTC-M2 | Historically correlated | **Decoupled** | Less reliable since mid-2025 |

**Critical insight**: Correlations are not static. The system must implement rolling correlation calculations rather than assume fixed coefficients.

### Price Discovery Dynamics

| Entity | AUM/Holdings | Influence |
|--------|--------------|-----------|
| IBIT (BlackRock) | ~$70B | Primary ETF, >50% of spot ETF market |
| FBTC (Fidelity) | ~$18.5B | Second largest spot ETF |
| MSTR (Strategy) | 673K-712K BTC (~$60B) | 3.4% of total supply, sentiment driver |

US Spot ETFs and MSTR significantly influence BTC price discovery. A CEX feed would detect these movements before they propagate to Solana DEX prices.

### Implementation Guidance

1. **Phase 1 (V0.2)**: Use Birdeye for BTC price data (existing integration)
2. **Phase 2 (V0.3+)**: Add yfinance integration for TradFi signals
   - `NQ=F` for Nasdaq 100 Futures
   - `DX-Y.NYB` for DXY
3. **Future**: Add CEX WebSocket feed for price discovery lead-lag

### Architecture Recommendations

| Component | Recommendation |
|-----------|----------------|
| API polling | GenServer with state management |
| NIF data passing | Binary or List format |
| Rolling correlations | Rust `ndarray` crate |
| Rate limiting | Caching layer for TradFi APIs |

### Rationale

- Birdeye is already integrated and sufficient for Solana execution
- yfinance provides free TradFi data at 1-minute granularity
- Sub-10-second BTC updates enable price velocity detection
- Rolling correlations handle regime shifts dynamically
- CEX feed deferred to avoid premature complexity

### Residual Sub-Questions

- Specific yfinance polling implementation (V0.3 scope)
- CEX WebSocket provider selection (deferred)
- Correlation window sizes (tuned during implementation)
- 10-Year Treasury Yield utility (less suitable for minute-level signals per research)

---

## R12. PostgreSQL Development Setup

**Resolved**: 2026-02-15
**Related**: B1 in BACKLOG.md (Development Environment Setup)

### Decision

| Aspect | Decision |
|--------|----------|
| Local development | PostgreSQL required |
| Test environment | PostgreSQL with Ecto.Adapters.SQL.Sandbox |
| CI environment | PostgreSQL service container |
| Configuration | Standard Phoenix/Ecto patterns |

### Rationale

- Standard Phoenix convention: Repo always in supervision tree
- Ecto sandbox provides test isolation without conditional startup logic
- CI PostgreSQL service container mirrors local development
- Avoids unconventional POSTGRES_ENABLED conditional patterns

### Implementation

Setup commands documented in `cordial_cantina/README.md`:
```sh
mix deps.get
mix ecto.create
mix ecto.migrate
mix run priv/repo/seeds.exs
```

### Residual Sub-Questions

- Production database configuration (V0.6 scope)
- Connection pooling parameters (tuned during deployment)

---

## R13. Birdeye WebSocket Data Ingestion

**Resolved**: 2026-02-16
**Related**: R11 (TradFi Signal Strategy), V0.2-M3 (Real-time Price Feed Ingestion)

### Decision

| Aspect | Decision |
|--------|----------|
| Data ingestion method | WebSocket (not REST polling) |
| Client implementation | `CordialCantina.Integration.WebSocketClient` (existing) |
| Connection management | GenServer with reconnection logic |

### Rationale

- WebSocket provides lower latency than REST polling
- Server-push model reduces unnecessary API calls
- Existing WebSocketClient module provides scaffolding
- Better suited for sub-10-second update requirements
- Aligns with Broadway pipeline architecture for data processing

### Implementation Guidance

1. Extend `WebSocketClient` to connect to Birdeye WebSocket endpoints
2. Implement message parsing for price feed and order book data
3. Broadcast parsed data via PubSub for downstream consumers
4. Handle reconnection with exponential backoff

### Residual Sub-Questions

- Specific Birdeye WebSocket endpoint URLs (verify in API docs)
- Message format for subscription requests
- Authentication method for WebSocket connections

---

## R14. Rust Rolling Correlation Calculations

**Resolved**: 2026-02-16
**Related**: R4 (Rust NIF Integration), R11 (TradFi Signal Strategy)

### Decision

| Aspect | Decision |
|--------|----------|
| Implementation location | Rust NIF (joltshark crate) |
| Numerical library | `ndarray` crate |
| Window configuration | Parametric (multiple window sizes) |
| Coefficient assumption | Dynamic rolling (not fixed) |

### Rationale

- Sub-1-second internal processing requires NIF performance
- joltshark crate already exists and can be extended
- `ndarray` provides efficient array operations with modify-in-place semantics
- Parametric windows enable holistic analysis across timeframes
- Rolling calculations essential due to correlation regime shifts (documented in R11)

### Implementation Guidance

1. Add `ndarray` dependency to joltshark Cargo.toml
2. Implement rolling correlation function accepting:
   - Two time series as input
   - Window size parameter
   - Optional weights for exponential moving average
3. Return correlation coefficient and statistical confidence
4. Support multiple concurrent window sizes (e.g., 5-min, 15-min, 1-hour)

### Example API

```rust
/// Calculate rolling Pearson correlation between two series
fn rolling_correlation(
    series_a: &[f64],
    series_b: &[f64],
    window_size: usize,
) -> Result<Vec<f64>, NifError>
```

### Residual Sub-Questions

- Specific window sizes to implement (tune during V0.3)
- Whether to include Spearman rank correlation
- Memory management for large time series

---

## R15. Yahoo Finance Direct HTTP for TradFi Data

**Resolved**: 2026-02-16
**Related**: R11 (TradFi Signal Strategy)

### Decision

| Aspect | Decision |
|--------|----------|
| Data source | Yahoo Finance (direct HTTP) |
| HTTP client | `Req` library (existing dependency) |
| Python dependency | None (avoid yfinance library) |
| Tickers | NQ=F (Nasdaq 100), DX-Y.NYB (DXY), ES=F (S&P 500), MSTR |

### Rationale

- Same underlying data as yfinance Python library
- `Req` is already a project dependency
- Avoids Python/Erlang port complexity
- No external language runtime required
- Direct HTTP provides full control over request/response handling

### Implementation Guidance

1. Use Yahoo Finance query endpoints (same as yfinance uses internally)
2. Implement GenServer for polling at 1-minute intervals
3. Cache responses to respect rate limits
4. Parse JSON responses into Elixir structs
5. Broadcast via PubSub for downstream correlation calculations

### Ticker Mapping

| Signal | Ticker | Description |
|--------|--------|-------------|
| Nasdaq 100 Futures | NQ=F | Primary BTC correlation signal |
| DXY | DX-Y.NYB | US Dollar Index (inverse correlation) |
| S&P 500 Futures | ES=F | Risk sentiment filter |
| MSTR | MSTR | BTC sentiment proxy |

### Residual Sub-Questions

- Yahoo Finance endpoint stability (undocumented API)
- Rate limiting behavior for direct HTTP requests
- Fallback data source if Yahoo Finance becomes unavailable

---

## R16. Birdeye API Configuration

**Resolved**: 2026-02-16
**Related**: R13 (Birdeye WebSocket), V0.2-M3

### Decision

| Aspect | Decision |
|--------|----------|
| Free tier rate limit | **1 RPS** (not 60 RPS) |
| Compute units (free) | 30,000 |
| BTC token (Solana) | Wrapped BTC (Portal): `3NZ9JMVBmGAqocybic2c7LQCJScmgsAZ6vQqTDzcqmJh` |
| Alternative BTC token | Wrapped Bitcoin (Sollet): `9n4nbM75f5Ui33ZbPYXn59EwSgE8CGsHtAeTH5YFeJ9E` |

### Rate Limit Tiers (Verified)

| Tier | Rate Limit | Price |
|------|-----------|-------|
| Standard (Free) | 1 rps | Free |
| Lite | 15 rps | $39/mo |
| Starter | 15 rps | $99/mo |
| Premium | 50 rps | $199/mo |
| Business | 100 rps | $499+/mo |

**Critical correction**: The free tier is 1 RPS, significantly more restrictive than initially assumed. This affects polling frequency design.

### Rationale

- Official Birdeye documentation confirms 1 RPS for Standard tier
- WebSocket preferred over REST to minimize API calls within rate limit
- Portal wBTC has higher liquidity on Solana DEXes
- Multiple wrapped BTC options provide redundancy

### Implementation Guidance

1. Prioritize WebSocket connections to stay within rate limits
2. Use REST API sparingly for initial data fetch or reconnection
3. Implement request queuing to avoid rate limit violations
4. Monitor compute unit consumption
5. Consider paid tier if 1 RPS insufficient for V0.2 requirements

### Residual Sub-Questions

- WebSocket connections counted against rate limit?
- Compute unit cost per WebSocket message vs REST call

---

## R17. MSTR as Sentiment Proxy Signal

**Resolved**: 2026-02-16
**Related**: R11 (TradFi Signal Strategy), R15 (Yahoo Finance)

### Decision

| Aspect | Decision |
|--------|----------|
| Signal role | Leading indicator for BTC sentiment in TradFi |
| Priority | Priority 4 (after Nasdaq, DXY, S&P 500) |
| Ticker | MSTR (via Yahoo Finance) |
| Update frequency | 1-minute (same as other TradFi signals) |

### Rationale

- MSTR holds 3.4% of total BTC supply (~673K-712K BTC)
- MSTR stock movements reflect institutional BTC sentiment
- MSCI inclusion/exclusion decisions create predictable volatility windows
- Stock-crypto feedback loop documented in January 2026 MSCI decision

### Implementation Guidance

1. Include MSTR in Yahoo Finance polling (alongside NQ=F, DX-Y.NYB, ES=F)
2. Track MSTR price relative to implied BTC NAV
3. Monitor premium/discount to NAV as sentiment indicator
4. Consider MSTR volatility as regime change signal

### Residual Sub-Questions

- Specific premium/discount thresholds for signal generation
- Integration with correlation calculations (correlate MSTR with BTC?)

---

## R18. 10-Year Treasury Yield as Macro Signal

**Resolved**: 2026-02-16
**Related**: R11 (TradFi Signal Strategy)

### Decision

| Aspect | Decision |
|--------|----------|
| Signal role | Macro-timing signal (not day trading) |
| Update frequency | Daily (not minute-level) |
| Ticker | ^TNX (via Yahoo Finance) |
| Usage | Regime detection, not precise timing |

### Rationale

- Research indicates 10-Year Treasury operates on different timeframe than Nasdaq/DXY
- BTC/10Y correlation hit -53 (14-year low) indicating structural relationship
- Real yields affect BTC through opportunity cost mechanism
- More appropriate for daily/weekly regime detection

### Implementation Guidance

1. Poll daily (not minute-level) to reduce API calls
2. Use for macro regime classification:
   - Rising yields → Risk-off environment → Bearish BTC bias
   - Falling yields → Risk-on environment → Bullish BTC bias
3. Combine with other signals for regime confirmation
4. Do not use for minute-level trading decisions

### Residual Sub-Questions

- Threshold values for regime classification
- Integration with daily strategy adjustments (V0.4+ scope)

---

## R19. Birdeye WebSocket Endpoint Configuration

**Resolved**: 2026-02-16
**Related**: R13 (Birdeye WebSocket Data Ingestion), R16 (Birdeye API Configuration)

### Decision

| Aspect | Decision |
|--------|----------|
| Endpoint URL | `wss://public-api.birdeye.so/socket/solana?x-api-key=<API_KEY>` |
| Authentication | API key via query parameter |
| Protocol | `echo-protocol` (required header) |
| Max tokens per connection | 100 |

### Subscription Message Format

**Simple Query (Single Token):**
```json
{
  "type": "SUBSCRIBE_PRICE",
  "data": {
    "queryType": "simple",
    "chartType": "1m",
    "address": "<TOKEN_ADDRESS>",
    "currency": "usd"
  }
}
```

**Complex Query (Multiple Tokens, Max 100):**
```json
{
  "type": "SUBSCRIBE_PRICE",
  "data": {
    "queryType": "complex",
    "query": "(address = ADDR1 AND chartType = 1m AND currency = usd) OR (...)"
  }
}
```

### Field Definitions

| Field | Required | Values |
|-------|----------|--------|
| `type` | Yes | `SUBSCRIBE_PRICE`, `SUBSCRIBE_TXS`, `SUBSCRIBE_WALLET_TXS`, `SUBSCRIBE_TOKEN_NEW_LISTING` |
| `queryType` | Yes | `simple` or `complex` |
| `address` | Yes | Token or pair contract address |
| `chartType` | Yes | `1m`, `3m`, `5m`, `15m`, `30m`, `1H`, `2H`, `4H`, `6H`, `8H`, `12H`, `1D`, `3D`, `1W`, `1M` |
| `currency` | Yes | `usd` (token price) or `pair` (market pair) |

### Response Format

Responses arrive as `PRICE_DATA` events:
```json
{
  "type": "PRICE_DATA",
  "data": {
    "o": 123.45,
    "h": 124.00,
    "l": 123.00,
    "c": 123.80,
    "v": 1000000,
    "unixTime": 1708099200,
    "address": "<TOKEN_ADDRESS>",
    "symbol": "SOL"
  }
}
```

### Connection Requirements

| Requirement | Value |
|-------------|-------|
| Origin header | `ws://public-api.birdeye.so` |
| Sec-WebSocket-Protocol | `echo-protocol` |
| Ping-pong | Required for connection stability |
| Reconnection | Implement exponential backoff |

### Token Addresses for Subscription

| Token | Address |
|-------|---------|
| SOL | `So11111111111111111111111111111111111111112` |
| Portal wBTC | `3NZ9JMVBmGAqocybic2c7LQCJScmgsAZ6vQqTDzcqmJh` |
| Sollet wBTC | `9n4nbM75f5Ui33ZbPYXn59EwSgE8CGsHtAeTH5YFeJ9E` |

### Access Requirements

WebSocket access requires Business Package or higher subscription for production use. Free tier may have limited WebSocket access.

### Implementation Reference

GitHub example: https://github.com/birdeye-so/tradingview-example-js-api/blob/main/websocket_example.js

### Residual Sub-Questions

- WebSocket availability on free tier (verify during implementation)
- Ping interval requirements
- Rate limit behavior for WebSocket vs REST

---

## Revision History

| Date | Author | Changes |
|------|--------|---------|
| 2026-02-01 | Claude | Initial draft with Database Architecture resolution |
| 2026-02-01 | Claude | Added Mnesia configuration (ram_copies, parameterized fragmentation/windows), offload strategy, PostgreSQL configuration (datetime index, deferred partitioning) |
| 2026-02-02 | Claude | Added R2: Mnesia initialization strategy (GenServer) |
| 2026-02-02 | Claude | Added R3-R9: Phase 1 blocker decisions (OTP, NIF, RPC, secrets, testing, Mnesia schema, logging) |
| 2026-02-14 | Claude | Added R10: Message queue selection (Broadway) |
| 2026-02-15 | Claude | Added R11: TradFi signal and data source strategy |
| 2026-02-15 | Claude | Added R12: PostgreSQL development setup |
| 2026-02-16 | Claude | Added R13: Birdeye WebSocket data ingestion |
| 2026-02-16 | Claude | Added R14: Rust rolling correlation calculations |
| 2026-02-16 | Claude | Added R15: Yahoo Finance direct HTTP for TradFi |
| 2026-02-16 | Claude | Added R16: Birdeye API configuration (rate limits, tokens) |
| 2026-02-16 | Claude | Added R17: MSTR as sentiment proxy signal |
| 2026-02-16 | Claude | Added R18: 10-Year Treasury Yield as macro signal |
| 2026-02-16 | Claude | Added R19: Birdeye WebSocket endpoint configuration |
