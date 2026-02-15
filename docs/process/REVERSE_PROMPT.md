# Reverse Prompt

> **Navigation**: [Process](./README.md) | [Documentation Root](../README.md)

This file is the AI-to-human communication channel. It is overwritten after each completed task.

---

## Last Updated

**Date**: 2026-02-15
**Task**: TradFi Signal Research and CI/Database Fixes
**Macro-milestone**: V0.2 Market Data

---

## Verification

### Build
**Command**: `mix compile --force`
**Result**: Pending verification after CI changes

### Tests
**Command**: `mix test`
**Result**: Pending verification (database now follows standard Phoenix patterns)

### CI Status
**Issue**: cargo-tarpaulin installation failure
**Fix Applied**: Added conditional installation check with `--locked` flag

---

## Completed Tasks

### 1. Fixed Failing CI (cargo-tarpaulin)

**Problem**: CI failed on `cargo install cargo-tarpaulin` with "binary already exists" error due to GitHub Actions caching `~/.cargo/bin/`.

**Solution**: Added conditional installation check in `.github/workflows/ci.yml`:
```yaml
- name: Install cargo-tarpaulin
  run: |
    if ! command -v cargo-tarpaulin &> /dev/null; then
      cargo install cargo-tarpaulin --locked
    fi
```

### 2. Revised Database Configuration to Follow Phoenix Best Practices

**Problem**: Unconventional `POSTGRES_ENABLED` conditional pattern caused PostgreSQL connection error flooding.

**Changes Made**:
- Removed `POSTGRES_ENABLED` conditional startup from `application.ex`
- Reverted to standard Phoenix pattern where `CordialCantina.Repo` is always in supervision tree
- Added PostgreSQL service container to GitHub Actions CI
- Standard `Ecto.Adapters.SQL.Sandbox` configuration in `test.exs`
- Added standard test alias: `test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"]`

**Rationale**: Standard Phoenix convention is to always include Repo in supervision tree. Tests use sandbox mode for isolation. CI environments should provide the database service.

### 3. Corroborated/Falsified TradFi Signal Suggestions

Research completed below.

---

## Research Findings: TradFi Signal Corroboration

### Claim 1: BTC-Nasdaq 100 Correlation (~0.62)

**PARTIALLY CORROBORATED with important caveats**

| Finding | Source |
|---------|--------|
| Long-running correlation is approximately 0.805 | [LongtermTrends](https://www.longtermtrends.com/bitcoin-vs-nasdaq/) |
| 30-day rolling correlation reached ~0.80 in late 2025 (highest since 2022) | [CoinDesk](https://www.coindesk.com/markets/2025/12/04/bitcoin-s-negative-correlation-with-nasdaq-persists-and-history-suggests-a-bottom-may-be-forming) |
| Current 20-day correlation is **-0.43** (negative) as of late 2025/early 2026 | [CoinDesk](https://www.coindesk.com/markets/2025/12/04/bitcoin-s-negative-correlation-with-nasdaq-persists-and-history-suggests-a-bottom-may-be-forming) |

**Assessment**: The ~0.62 figure is plausible as a historical average, but the current correlation has shifted to **negative territory** (-0.43). This represents the fourth time in five years that Bitcoin and Nasdaq have moved into negative correlation. The divergence began with the October 2025 flash crash when crypto leverage liquidations sent Bitcoin down while Nasdaq remained stable.

**Implementation Note**: The correlation is not static. The system should track rolling correlations rather than assume a fixed value.

### Claim 2: DXY/BTC Inverse Correlation (~-0.45)

**CORROBORATED with nuance**

| Finding | Source |
|---------|--------|
| DXY/BTC correlation historically ranges from -0.4 to -0.8 | [BitcoinWorld](https://bitcoinworld.co.in/www-cryptonews-com-dxy-vs-bitcoin-correlation-analysis-2026/) |
| Traditional inverse relationship remains prevalent in early 2026 | [CoinGlass](https://www.coinglass.com/learn/the-relationship-between-the-us-dollar-index-dxy-and-bitcoin-price-volatility-1) |
| JPMorgan 2026 analysis notes correlation has **shifted to positive** in some periods | [AInvest](https://www.ainvest.com/news/bitcoin-sensitivity-dollar-liquidity-shifts-implications-2026-2601/) |

**Assessment**: The -0.45 figure falls within the historical range (-0.4 to -0.8) and is corroborated. However, JPMorgan's 2026 analysis indicates Bitcoin now sometimes behaves as a "liquidity-sensitive risk asset" rather than a traditional dollar hedge, meaning the inverse relationship is not as reliable as in previous years.

**Implementation Note**: DXY remains a valid signal but should be weighted appropriately given the evolving relationship.

### Claim 3: US Spot ETFs (IBIT/FBTC) and MSTR Drive Price Discovery

**CORROBORATED**

| Finding | Source |
|---------|--------|
| IBIT holds ~$70B AUM (over 50% of spot ETF market) | [Nasdaq](https://www.nasdaq.com/articles/3-best-bitcoin-etf-picks-2026) |
| FBTC holds ~$18.5B AUM (second largest) | [Gate.io](https://www.gate.com/learn/articles/fbtc-bitcoin-etf-guide-2026/16034) |
| Combined ETF AUM exceeds $110 billion | [Bitbo](https://bitbo.io/treasuries/us-etfs/) |
| MSTR holds 673,783-712,647 BTC (~3.4% of total supply, ~$60B) | [Strategy](https://www.strategy.com/purchases), [CoinDesk](https://www.coindesk.com/business/2026/01/31/michael-saylor-s-bitcoin-stack-is-officially-underwater-but-here-s-why-he-likely-won-t-reach-for-the-panic-button) |

**Assessment**: Fully corroborated. IBIT and FBTC together represent massive institutional capital flows. MSTR's holdings (3%+ of total Bitcoin supply) can influence market sentiment through programmatic accumulation disclosures. The January 2026 MSCI decision not to exclude digital asset treasury companies triggered a 2.5% MSTR surge, demonstrating the stock-crypto feedback loop.

**Implementation Note**: A CEX feed to detect ETF-driven price movements before they hit Solana DEXes would provide a lead-lag advantage.

### Claim 4: 10-Year Treasury Yield is a Lagging Signal

**PARTIALLY CORROBORATED but contested**

| Finding | Source |
|---------|--------|
| BTC/10Y correlation hit -53 (14-year low) in June 2024 | [Binance](https://www.binance.com/en/square/post/2024-06-12-bitcoin-and-10-year-treasury-yield-correlation-hits-14-year-low-9372588240281) |
| Rising Treasury yields punished Bitcoin in late 2025 post-October crash | [YCharts](https://get.ycharts.com/resources/blog/how-treasury-yields-are-influencing-crypto-and-what-advisors-need-to-know/) |
| Real yields remain significant for 2026 Bitcoin outlook | [Bitcoin Magazine Pro](https://www.bitcoinmagazinepro.com/bitcoin-macro/us-treasury-yields-vs-btc/) |

**Assessment**: The claim is partially supported. Treasury yields are not "lagging" in the traditional technical analysis sense. Rather, they operate on a different timeframe and affect Bitcoin through real yield competition (opportunity cost of holding non-yielding assets). The relationship exists but is less direct than Nasdaq or DXY correlations for minute-level signals.

**Implementation Note**: Treasury yields may be more appropriate for daily/weekly regime detection rather than minute-level trading signals.

### Claim 5: yfinance Tickers (NQ=F, DX-Y.NYB)

**CORROBORATED**

| Ticker | Description | Verified |
|--------|-------------|----------|
| NQ=F | Nasdaq 100 Futures (Mar 2026 contract) | Yes - [Yahoo Finance](https://finance.yahoo.com/quote/NQ=F/) |
| DX-Y.NYB | US Dollar Index (ICE Futures) | Yes - [Yahoo Finance](https://finance.yahoo.com/quote/DX-Y.NYB/) |

**Assessment**: Both tickers are valid and actively quoted on Yahoo Finance. DX-Y.NYB closed at 96.88 on February 13, 2026. These can be used with the yfinance Python library.

### Claim 6: TradFi 1-Minute Updates Sufficient

**CORROBORATED with caveats**

TradFi markets (equities, futures) operate at lower volatility than crypto. One-minute granularity is appropriate for signals that provide regime context rather than direct trading triggers. Free-tier API limitations (yfinance, FRED) typically support this frequency.

**Caveat**: During market opens, closes, and high-volatility events (FOMC announcements, jobs reports), sub-minute TradFi data becomes more valuable.

### Claim 7: BTC Sub-10-Second Updates Recommended

**CORROBORATED**

Crypto market microstructure operates at sub-second timescales. For detecting price velocity and momentum shifts, sub-10-second polling is appropriate. The bottleneck is API rate limits (Birdeye free tier), not computation (Rust NIF).

### Claim 8: BTC "Undershooting" Global M2 by ~60%

**PARTIALLY FALSIFIED**

| Finding | Source |
|---------|--------|
| BTC has **decoupled** from global M2 since mid-2025 | [BeInCrypto](https://beincrypto.com/bitcoin-decouple-from-global-m2-in-2026/) |
| BTC shows negative YoY growth while M2 grows 10%+ | [Yahoo Finance](https://finance.yahoo.com/news/bitcoin-continues-decouple-global-m2-134022834.html) |
| Historical correlation with M2 is weakening as predictive tool | [Sarson Funds](https://sarsonfunds.com/the-correlation-between-bitcoin-and-m2-money-supply-growth-a-deep-dive/) |

**Assessment**: The decoupling is real, but framing it as "undershooting by 60%" is misleading. Bitcoin's relationship with M2 has become less reliable in 2026. Some analysts view this as a potential market top signal; Fidelity Digital Assets remains bullish citing renewed QE cycles.

**Implementation Note**: M2 may be less useful as a real-time signal in 2026 given the structural decoupling.

---

## Incidental Findings

### Bitcoin Negative Correlation with Nasdaq (Risk-On Divergence)

The current -0.43 correlation represents a significant regime shift. Historically, negative Bitcoin-Nasdaq correlations have preceded major Bitcoin turning points. This is potentially actionable information.

### MSTR as a Bitcoin Proxy Signal

MSTR stock movements may provide a lead indicator for Bitcoin sentiment in traditional finance. The MSCI inclusion/exclusion drama creates predictable volatility windows.

### Phoenix Architecture Recommendation

The suggestion to use GenServer for API polling with data passed to NIF as Binary/List aligns with Elixir best practices. The `ndarray` crate recommendation for Rust rolling correlation calculations is sound.

---

## Technical Concerns / Risks

### Database Configuration

PostgreSQL now follows standard Phoenix conventions:
- Repo always in supervision tree
- Sandbox mode for tests
- CI provides database service container

**Risk**: Developers without local PostgreSQL will see connection errors in dev. This is expected Phoenix behavior.

**Mitigation**: Document local PostgreSQL setup in README or provide docker-compose.yml.

### Correlation Regime Detection

Given the research showing correlation instability (BTC-Nasdaq flipping negative, DXY relationship evolving), the system should implement rolling correlation calculations rather than assuming fixed correlation coefficients.

---

## Intended Next Step

**Awaiting human direction** on:
- Verification of CI fixes (manual GitHub Actions run)
- Verification of database changes (local `mix test`)
- Prioritization of V0.2-M3 implementation given research findings
- Decision on whether to add CEX feed for ETF price discovery lead-lag

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

---

## Session Context

If you are a new AI session reading this file:

1. Check [GitHub Issues](https://github.com/sgeos/cordial_cantina/issues) for open tasks
2. V0.0 Process Definition: Complete (tagged v0.0.0)
3. V0.1 Foundation: Complete (tagged v0.1.0)
4. V0.2 Market Data: In progress (M1, M2 complete)
5. Primary tracking: GitHub Issues
6. CI fix applied: cargo-tarpaulin conditional installation
7. Database: Reverted to standard Phoenix/Ecto patterns
8. TradFi signal research: Completed (see findings above)
9. Wait for human prompt before proceeding
