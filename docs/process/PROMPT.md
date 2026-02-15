# Prompt Staging Area

> **Navigation**: [Process](./README.md) | [Documentation Root](../README.md)

This file is a staging area for complex human-to-AI instructions. The human pilot drafts and refines prompts here before execution.

---

# Current Prompt

## Comments

Consulted external LLMs to get clarification on requirements.
The suggestions need to be corroborated or falsified.

## Objectives

### Corroborate of Falsify Suggested Answers to Reverse Prompt

I consulted with external LLMs to get clarification on requirements.
My write up of their suggestions and accompanying notes can be found in
the following two subsections.
Please do your own research to corroborate or falsify these suggestions.
Report your findings in the next reverse prompt.
Also, report any other incidental potentially interesting findings that are
potentionally relevant to this project.

#### Suggested Answers to Reverse Prompt

1. **BTC price on Solana DEXes is sufficient for execution, but incomplete for prediction.**
   Using Birdeye for BTC price on Solana is perfect for internal logic,
   so start here for now.
   My understanding is that 2026 price discovery is heavily driven by
   **US Spot ETFs (IBIT/FBTC)** and **MSTR**.
   Therefor, a CEX "Front-Run" feed (e.g., Coinbase or Binance)
   to detect lead-lag effects before they hit Solana liquidity pools
   should be added in the future,
   and you should prepare for this now.

2. **TradFi Signal Priority**:
   1. **Priority 1: Nasdaq 100 (NQ/QQQ)**.
      I have heard that as of early 2026,
      BTC's correlation with the Nasdaq is at its highest point in 24 months (~$0.62$). 
   2. **Priority 2: DXY (US Dollar Index)**.
      My understanding is that
      while the DXY/BTC inverse correlation has structurally moderated to around $-0.45$,
      it remains the primary indicator for global liquidity drain. 
   3. **Priority 3: S&P 500 (ES)**.
      This can be used as a broader risk-sentiment filter. 
   4. **Note:** *I understand that that in 2026, the 10-Year Yield has become a lagging signal.
      It is therefore not suitable for minute-level crunching.*

3. **Hybrid Frequency is Mandatory.**
   - **TradFi:** 1-minute updates (via `yfinance` or `IEX`)
     are sufficient because these markets are less volatile.
   - **BTC Price:** Sub-10-second updates are recommended.
     Since a Rust NIF is in play, the bottleneck is not computation. It is network I/O.
     Poll Birdeye as slightly slower than the free tier allows to
     feed the Rust-driven state-machine with high-resolution "price velocity."
   - **Internal Machinery:** Internal machinery should be design for sub-1-second updates.
     When the service supports multiple users, the strategy will be to calculate once,
     and distribute the results to everyone.

#### Justification and Notes

* **The 2026 Context:**
  Recent data shows BTC "undershooting" global money supply by nearly 60%,
  behaving more like an AI-growth stock than a currency.
  The Rust algorithms should treat **Nasdaq volatility** as a primary input for BTC price direction.
* **Update Frequency**:
  A caching layer will be essential to avoid hitting API rate limits,
  particularly for TradFi data sources that may have stricter restrictions on free-tier usage.
* **Phoenix/Rust Architecture:**
  In a high-concurrency Elixir app,
  consider using a **GenServer** to manage the API polling
  and pass the raw data as a **Binary** or **List** to the NIF.
  Since efficient modify-in-place algorithms can be used in the NIF,
  consider using Rust's `ndarray` for lightning-fast rolling correlation calculations.
* **Minimalist Implementation:**
    * **BTC:** Birdeye (Current integration).
    * **Macro:** `yfinance` (Ticker: `NQ=F` for Nasdaq Futures, `DX-Y.NYB` for DXY).

### Attempt to Resolve Failing CI

CI is failing on the `install cargo-tarpaulin` step. See:
https://github.com/sgeos/cordial_cantina/actions/runs/22025355378/job/63641034742

### Research and Revise to Adopt Database Best Practices

When running `iex -S mix phx.server`,
the server starts and Liveview functionality works without issue,
but the following error message floods the console.

```
[error] Postgrex.Protocol (#PID<0.354.0> ("db_conn_1")) failed to connect: ** (DBConnection.ConnectionError) tcp connect (localhost:5432): connection refused - :econnrefused
```

Combined with your comments on adding "conditional startup via POSTGRES_ENABLED config,"
I suspect your setup is unconventional and not following best practices.
I have never been flooded by the mentioned error message when generating a Phoenix project
that does not exclude `Ecto`,
and I have never needed a lever to conditionally disable the database.

The problem may be as simple as not have a database setup.
In any case, please research this problem, best practices, and try to implement a solution.
Also, report any other incidental potentially interesting findings that are
potentionally relevant to this project.

## Context

Clearing blockers for V0.2.
Refining process.

## Constraints

(none)

## Success Criteria

- Suggested decisions for blocker resolution are corroborated or falsified,
  and this is reported in the next reverse prompt.
- Incidentally discovered relevant information is also reported in the next reverse prompt.
  - Blocker related.
  - Phoenix/Elixir/Database related.
- Theoretical CI fix implemented. I will manually verify.
- Database best practices researched, and database-related console error flooding resolved.
- Best practices adopted so a conditional database enabling lever is not needed for testing.

## Notes

(none)
