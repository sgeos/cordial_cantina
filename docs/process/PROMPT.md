# Prompt Staging Area

> **Navigation**: [Process](./README.md) | [Documentation Root](../README.md)

This file is a staging area for complex human-to-AI instructions. The human pilot drafts and refines prompts here before execution.

---

# Current Prompt

## Comments

CI is now passing.

## Objectives

### Update Knowledge Graph to Document Blocker Decisions

I consulted with external LLMs to get clarification on requirements.
My write up of their suggestions and accompanying notes can be found in
the following two subsections.
Your corroboration/falsification report is in your current reverse prompt.
Please update the knowledge graph to resolve blockers as best you can
based on the below suggestions, and your corroboration/falsification report
and any incidentally discovered relevant information.
Flag issues in your next revese prompt if anything is unclear or ambiguous.

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

### Update Knowledge Graph Based on Database Best Practices Research

If your database research uncovered anything that should be recorded in the knowledge graph,
then please record it.

### Update cordial_cantina/README.md Setup Instructions

I manually installed Postgresql for local development.
Please update `cordial_cantina/README.md` with the following setup instructions.

- Make sure Postgresql is installed, and run the following commands.

```sh
mix deps.get
mix ecto.create
mix ecto.migrate
mix run priv/repo/seeds.exs
```

#### Add cordial_cantina/priv/repo/seeds.exs

Add `cordial_cantina/priv/repo/seeds.exs` with relevant contents.

### Report on Any V0.2 Blockers

Report on any remaining V0.2 blockers in your next reverse prompt.
Include suggestions and call out decision points with no obvious choice.

## Context

Clearing blockers for V0.2.
Refining process.

## Constraints

(none)

## Success Criteria

- Knowledge graph updated to document blocker resolutions.
  - Remaining decision points and ambiguities flagged, if any.
- Knowledge graph updated based on database best practices research, if appropriate.
- `cordial_cantina/README.md` updated with setup instructions.
- `cordial_cantina/priv/repo/seeds.exs` added with relevant contents.
- Remaining V0.2 blockers with suggestions reported in next reverse prompt.

## Notes

(none)
