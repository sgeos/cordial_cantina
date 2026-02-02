# Reverse Prompt

> **Navigation**: [Process](./README.md) | [Documentation Root](../README.md)

This file is the AI-to-human communication channel. It is overwritten after each completed task.

---

## Last Updated

**Date**: 2026-02-02
**Task**: V0.0-M0-P10 GitHub Issues Migration
**Milestone**: V0.0-M0 Process Definition

---

## Verification

### V0.0-M0-P10-T1: Update R4 catch_unwind language
**Result**: PASS - "truly exceptional circumstances" documented

### V0.0-M0-P10-T2: Update README.md with gh requirement
**Result**: PASS - gh CLI added to prerequisites

### V0.0-M0-P10-T3: Update setup.sh checks
**Result**: PASS - git/gh checks added, CLAUDE.md reference message added

### V0.0-M0-P10-T4: Create GitHub labels
**Result**: PASS - V0.0, V0.1, type:task, type:decision, type:suggestion created

### V0.0-M0-P10-T5: Create V0.1 milestone
**Result**: PASS - "V0.1 Foundation" milestone created

### V0.0-M0-P10-T6: Create V0.0 Historical Summary issue
**Result**: PASS - Issue #1 created and closed

### V0.0-M0-P10-T7: Create V0.1 milestone issues
**Result**: PASS - Issues #2-#5 created (M1-M4)

### V0.0-M0-P10-T8: Update PROCESS_STRATEGY.md for GitHub Issues
**Result**: PASS - GitHub Issues Integration section added

### V0.0-M0-P10-T9: Write REVERSE_PROMPT.md
**Result**: This file

### V0.0-M0-P10-T10: Verify and commit
**Command**: `git commit`
**Result**: PASS - Commit `e9c2e5c`

---

## GitHub Issues Created

| Issue | Title | Labels | Status |
|-------|-------|--------|--------|
| #1 | V0.0-M0: Process Definition - Historical Summary | V0.0 | Closed |
| #2 | V0.1-M1: Mnesia GenServer Implementation | V0.1, type:task | Open |
| #3 | V0.1-M2: Secrets Management Setup | V0.1, type:task | Open |
| #4 | V0.1-M3: Test Coverage Setup | V0.1, type:task | Open |
| #5 | V0.1-M4: Birdeye API Integration | V0.1, type:task | Open |
| #6 | B3: Add CHANGELOG.md | type:suggestion | Open |
| #7 | B6: CLAUDE.md inclusion strategy | type:suggestion | Open |

---

## Comments on Questions from PROMPT.md

### 1. GitHub Projects Integration

**Assessment**: GitHub Projects could add value but is not immediately necessary.

**Pros**:
- Kanban board view for visual task tracking
- Automation (auto-move issues on close)
- Sprint planning views

**Cons**:
- Adds complexity beyond basic Issues
- Requires additional setup and maintenance
- Agentic workflow via `gh` can manage issues directly

**Recommendation**: Defer GitHub Projects until V0.2+. GitHub Issues with milestones and labels are sufficient for V0.1.

### 2. Linear or Notion Advantages for Agentic Workflow

**Linear**:
- Excellent keyboard-driven UI (not relevant for agentic)
- Cycles and roadmaps are useful for team coordination
- CLI (`linear`) exists but is less mature than `gh`
- Would require additional authentication setup

**Notion**:
- Rich document integration
- API exists but is document-centric, not issue-centric
- Overhead for simple task tracking
- Better suited for documentation than issue tracking

**Recommendation**: GitHub Issues is the better choice for agentic workflow:
- `gh` CLI is mature and well-documented
- Native integration with git, commits, and PRs
- No additional service dependencies
- Sufficient for single-developer or small team

### 3. DEX Screener Free API

**Assessment**: DEX Screener does offer API access.

**Free Tier**:
- Rate-limited public endpoints exist
- No authentication required for basic data
- Endpoints: `/latest/dex/tokens/{address}`, `/latest/dex/pairs/{chainId}/{pairAddress}`

**Limitations**:
- Less comprehensive than Birdeye for historical data
- Solana support is available but Birdeye is more Solana-focused

**Recommendation**: Birdeye as primary, DEX Screener as potential fallback or supplement. Worth evaluating during V0.1-M4 implementation.

### 4. BTC Price and TradFi Metrics APIs

**BTC Price**:
| API | Free Tier | Notes |
|-----|-----------|-------|
| CoinGecko | Yes (30 calls/min) | Simple, reliable |
| CoinMarketCap | Yes (limited) | Requires API key |
| Binance | Yes | Real-time, WebSocket available |
| Kraken | Yes | Good for spot prices |

**Recommendation**: CoinGecko for simplicity, Binance for real-time needs.

**TradFi Metrics (Oil, Futures)**:
| API | Free Tier | Notes |
|-----|-----------|-------|
| Alpha Vantage | Yes (5 calls/min) | Stocks, forex, commodities |
| Yahoo Finance | Unofficial | yfinance Python library, no official API |
| Quandl (Nasdaq Data Link) | Limited free | Good for commodities |
| FRED (Federal Reserve) | Yes | Economic indicators, not real-time |

**Recommendation**: Alpha Vantage for initial TradFi integration. Rate limits are restrictive but sufficient for correlation analysis.

**Note**: TradFi correlation is likely V0.3+ scope. Defer concrete integration until needed.

---

## Files Modified

- `docs/decisions/RESOLVED.md` - R4 catch_unwind language updated
- `README.md` - gh CLI added to prerequisites
- `scripts/setup.sh` - git/gh checks added, CLAUDE.md message added
- `docs/process/PROCESS_STRATEGY.md` - GitHub Issues Integration section added
- `docs/process/PROMPT_BACKLOG.md` - Items migrated to GitHub Issues
- `docs/process/MILESTONE.md` - V0.0-M0-P10 created

---

## V0.0-M0 Completion Status

**Process Definition macro-milestone is complete.**

All objectives achieved:
- Documentation knowledge graph established
- Bi-directional communication process defined
- Vw-Mx-Py-Tz coding system implemented
- CI pipeline operational
- NIF foundation working
- All Phase 1 blockers resolved
- GitHub Issues integration complete

**Ready to begin V0.1 Foundation.**

---

## Questions for Human Pilot

1. **V0.0-M0 closure**: Ready to formally close the Process Definition macro-milestone?

2. **V0.1 priority**: Which V0.1 milestone should be tackled first?
   - M1: Mnesia GenServer (foundational)
   - M2: Secrets Management (quick win)
   - M3: Test Coverage (enables quality)
   - M4: Birdeye API (external integration)

3. **GitHub Projects**: Defer to V0.2+ as recommended?

---

## Technical Concerns / Risks

None identified for this prompt.

---

## Suggestions for Improvement

1. **Add milestone due dates**: Consider adding due dates to GitHub milestone for planning.

2. **Issue templates**: Create `.github/ISSUE_TEMPLATE/` for consistent issue format.

3. **PR template**: Create `.github/PULL_REQUEST_TEMPLATE.md` for consistent PRs.

---

## Intended Next Step

**Awaiting human direction** on:
- Verification and commit
- V0.0-M0 formal closure
- V0.1-M1 priority selection

---

## Session Context

If you are a new AI session reading this file:

1. Read [MILESTONE.md](./MILESTONE.md) - V0.0-M0-P10 complete
2. Check [GitHub Issues](https://github.com/sgeos/cordial_cantina/issues) - Primary tracking
3. V0.0-M0 Process Definition: Complete
4. V0.1 Foundation: Ready to begin
5. Coding system: Vw-Mx-Py-Tz (see PROCESS_STRATEGY.md)
6. Wait for human prompt before proceeding
