# Current Milestone

> **Navigation**: [Process](./README.md) | [Documentation Root](../README.md)

This file is the source of truth for the current development sprint.

---

## Milestone: V0.1-M3-P1 Test Coverage Setup

**Status**: Complete

**Started**: 2026-02-02

**Macro-milestone**: V0.1-M3 Test Coverage Setup

**GitHub Issue**: [#4](https://github.com/sgeos/cordial_cantina/issues/4)

---

## Success Criteria

- [x] Add excoveralls to mix.exs dependencies
- [x] Configure coveralls.json for coverage reporting
- [x] Add coverage check to CI pipeline
- [x] Set 80% coverage target for critical paths (configurable)
- [x] Add Bypass for HTTP mocking

---

## Task Breakdown

| ID | Task | Status | Verification |
|----|------|--------|--------------|
| V0.1-M3-P1-T1 | Add excoveralls dependency | Complete | mix.exs updated |
| V0.1-M3-P1-T2 | Add bypass dependency | Complete | mix.exs updated |
| V0.1-M3-P1-T3 | Configure excoveralls in project | Complete | test_coverage, preferred_cli_env |
| V0.1-M3-P1-T4 | Create coveralls.json | Complete | File created |
| V0.1-M3-P1-T5 | Update CI for coverage | Complete | ci.yml updated |
| V0.1-M3-P1-T6 | Create Bypass test helper | Complete | test/support/bypass_test_helper.ex |
| V0.1-M3-P1-T7 | Write Bypass integration tests | Complete | 4 tests passing |
| V0.1-M3-P1-T8 | Verify mix coveralls works | Complete | 61.8% coverage reported |
| V0.1-M3-P1-T9 | Run precommit checks | Complete | 18 tests pass |
| V0.1-M3-P1-T10 | Update MILESTONE.md | Complete | This file |
| V0.1-M3-P1-T11 | Write REVERSE_PROMPT.md | Complete | File updated |
| V0.1-M3-P1-T12 | Commit changes | Complete | See commit |

---

## Notes

Per R7 decision:
- excoveralls is the standard Elixir coverage tool
- 80% target for critical paths (configurable via coveralls.json)
- No hard coverage target enforced for V0.1
- Bypass provides flexible HTTP mocking for RPC calls

Coverage reporting is added to CI but does not fail the build. Coverage metrics are reported for visibility.

---

## History

| Date | Change |
|------|--------|
| 2026-02-02 | Milestone created and completed |
