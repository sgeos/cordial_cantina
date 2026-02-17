# Prompt Staging Area

> **Navigation**: [Process](./README.md) | [Documentation Root](../README.md)

This file is a staging area for complex human-to-AI instructions. The human pilot drafts and refines prompts here before execution.

---

# Current Prompt

## Comments

CI is now passing.
Postgresql locally installed.

```sh
$ mix test
Running ExUnit with seed: 109638, max_cases: 20

...........................................................
Finished in 0.8 seconds (0.7s async, 0.1s sync)
59 tests, 0 failures
```

The server starts and runs without errors.

```sh
iex -S mix phx.server
```

## Objectives

### Document Decisions in the Knowledge Tree

Document the following decisions in the knowledge tree.

#### Decision: Birdeye WebSocket-Based Data Source

Use WebSockets to ingest data from Birdeye.

#### Decision: Rust-Based Rolling Calculation

Implement in Rust NIF using ndarray as recommended.
The joltshark crate already exists and can be extended.
Sub-1-second internal processing requires NIF performance.

#### Decision: TradFi Data Source

Use Yahoo Finance via direct HTTP requests.
This is that same data as yfinance.
The `Req` library is already a dependency.
This avoids Python/port complexity while accessing the same data.
There is no reason for the project to rely on Python.

#### Decision: Resolve Ambiguities

1. **Birdeye API rate limits**:
   I am fairly certain 60 RPS is the rate limit for the free tier.
   Please independently verify.

2. **BTC token pair on Birdeye**: 
   BTC/USD appears to be listed on Birdeye.
   The URL follows.
   https://birdeye.so/solana/token/EtBc6gkCvsB9c6f5wSbwG8wPjRqXMB5euptK6bqG1R4X

3. **Correlation window sizes**:
   Correlation window logic should be parametric.
   Multiple time windows should be utilized for a wholistic analysis.

#### Decision: Correlation Coefficients

The system should not assume fixed correlation coefficients.
Rolling calculations are essential.

#### Decision: MSTR as Sentiment Proxy

Track MSTR as a leading indicator for BTC sentiment in TradFi.

#### Decision: 10-Year Treasury Yield

Track 10-year treasury yield as a macro-timing signal,
and not an immediate signal for precise day trading timing.

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
- Remaining V0.2 blockers with suggestions reported in next reverse prompt.

## Notes

(none)
