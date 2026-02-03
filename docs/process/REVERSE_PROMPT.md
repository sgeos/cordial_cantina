# Reverse Prompt

> **Navigation**: [Process](./README.md) | [Documentation Root](../README.md)

This file is the AI-to-human communication channel. It is overwritten after each completed task.

---

## Last Updated

**Date**: 2026-02-02
**Task**: V0.1-M4-P1 Birdeye API Integration
**Macro-milestone**: V0.1-M4 Birdeye API Integration

---

## Verification

### V0.1-M3 Closure
**Command**: `gh issue close 4 --reason completed`
**Result**: PASS - Issue #4 closed with completion message

### V0.1-M4-P1: Birdeye API Integration
**Command**: `mix precommit`
**Result**: PASS - 36 tests, 0 failures

### CI Fix Verification
**Command**: `rm -rf _build && mix compile --force && mix precommit`
**Result**: PASS - Clean build and all tests pass

---

## Implementation Summary

### Created Files

**`lib/cordial_cantina/integration/birdeye.ex`**
- `fetch_ohlcv/5` - Fetches OHLCV data from Birdeye API
- Supports all 15 interval types (1m to 1M)
- Accepts DateTime or Unix timestamps
- Returns structured OHLCV data maps

**`lib/cordial_cantina/integration/rate_limiter.ex`**
- GenServer for rate limiting API calls
- `acquire/1` - Blocks until rate limit allows
- `register_endpoint/2` - Adds endpoints for round-robin
- `next_endpoint/1` - Gets next endpoint in rotation

**`test/cordial_cantina/integration/birdeye_test.exs`**
- 10 tests covering success, errors, validation

**`test/cordial_cantina/integration/rate_limiter_test.exs`**
- 8 tests covering acquire, timeout, round-robin

### Modified Files

**`.github/workflows/ci.yml`**
- Changed `mix compile` to `mix compile --force`
- Ensures NIF is built fresh with restored cache

**`CHANGELOG.md`**
- Added V0.1-M4-P1 Birdeye integration
- Added CI fix note

---

## Birdeye API Details

| Aspect | Value |
|--------|-------|
| Base URL | `https://public-api.birdeye.so` |
| OHLCV Endpoint | `/defi/ohlcv` |
| Auth Header | `X-API-KEY` |
| Chain Header | `x-chain` (default: solana) |
| Rate Limit | ~60 req/min (free tier) |

### Supported Intervals
1m, 3m, 5m, 15m, 30m, 1H, 2H, 4H, 6H, 8H, 12H, 1D, 3D, 1W, 1M

### Error Handling
- 429 -> `{:error, :rate_limited}`
- 401 -> `{:error, :unauthorized}`
- 404 -> `{:error, :not_found}`
- 5xx -> `{:error, {:http_error, status, body}}`

---

## Rust Test Coverage Question

Regarding your question about Rust test coverage tools:

**Recommended Tools:**

1. **cargo-tarpaulin** - Most popular, works well for simple projects
   ```sh
   cargo install cargo-tarpaulin
   cargo tarpaulin --out Html
   ```

2. **grcov** - Mozilla's tool, more comprehensive
   ```sh
   cargo install grcov
   RUSTFLAGS="-C instrument-coverage" cargo build
   ```

3. **llvm-cov** - Uses LLVM's native coverage
   ```sh
   cargo +nightly llvm-cov --html
   ```

For the NIF and joltshark, cargo-tarpaulin is the simplest option. It can be added to CI similarly to how excoveralls is used for Elixir.

---

## GitHub Issue Status

### Issue #4 (V0.1-M3)
**Status**: Closed
**Reason**: Completed

### Issue #5 (V0.1-M4)
All tasks complete:
- [x] Research Birdeye API endpoints and authentication
- [x] Create CordialCantina.Integration.Birdeye module
- [x] Implement OHLCV data fetching
- [x] Add rate limiting and error handling
- [x] Write tests with Bypass mocks

The issue can be closed after commit is verified.

---

## Questions for Human Pilot

1. **Close Issue #5?** Should I close GitHub Issue #5 now that implementation is complete?

2. **Add Rust coverage?** Should I add cargo-tarpaulin to the Rust CI job for coverage reporting?

3. **V0.1 complete?** V0.1-M1 through M4 are all complete. Ready to tag V0.1 release?

---

## Technical Concerns / Risks

None. The implementation follows R5 and R7 decisions. Rate limiting is implemented conservatively to stay within free tier limits.

---

## Intended Next Step

**Awaiting human direction** on:
- Commit verification
- Issue #5 closure
- Rust coverage decision
- V0.1 release tagging

---

## Session Context

If you are a new AI session reading this file:

1. Check [GitHub Issues](https://github.com/sgeos/cordial_cantina/issues) for open tasks
2. V0.0-M0 Process Definition: Complete
3. V0.1-M1 Mnesia GenServer: Complete (Issue #2 closed)
4. V0.1-M2 Secrets Management: Complete (Issue #3 closed)
5. V0.1-M3 Test Coverage: Complete (Issue #4 closed)
6. V0.1-M4 Birdeye API: Complete (this prompt)
7. Primary tracking: GitHub Issues
8. V0.1 Foundation: All milestones complete
9. Wait for human prompt before proceeding
