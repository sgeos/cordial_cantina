# Reverse Prompt

> **Navigation**: [Process](./README.md) | [Documentation Root](../README.md)

This file is the AI-to-human communication channel. It is overwritten after each completed task.

---

## Last Updated

**Date**: 2026-02-01
**Task**: M4 Pre-commit Hook complete
**Milestone**: Pre-commit Hook

---

## Verification

### M4-T1: Create pre-commit hook
**Command**: `ls -la .git/hooks/pre-commit`
**Result**: PASS - Hook created at `.git/hooks/pre-commit`

### M4-T2: Test pre-commit hook
**Command**: `git commit` (with staged files)
**Result**: PASS - Hook runs coverage check before commit

### M4-T3: Verify process codification
**Command**: Manual review of PROCESS_STRATEGY.md
**Result**: PASS - Workflow documented in "Task Completion Protocol" (lines 79-104) and "Workflow Example" (lines 132-180). The parse-execute-overwrite-commit sequence is codified.

### M4-T4: Update REVERSE_PROMPT.md
**Result**: This file

### M4-T5: Commit all changes
**Status**: PENDING

---

## Files Created/Modified

**Created**:
- `.git/hooks/pre-commit` - Pre-commit hook running documentation coverage check

**Modified**:
- `docs/process/MILESTONE.md` - M4 milestone
- `docs/process/MILESTONE_HISTORY.md` - Archived M3
- `docs/process/REVERSE_PROMPT.md` - This file

---

## Pre-commit Hook Usage

The hook runs automatically on every `git commit`. To bypass (not recommended):

```sh
git commit --no-verify
```

The hook:
1. Locates `scripts/check-doc-coverage.sh`
2. Runs coverage check on `docs/`
3. Blocks commit if any markdown file is unreferenced
4. Allows commit if all files are referenced

---

## Questions for Human Pilot

1. **Hook location**: The hook is in `.git/hooks/` which is not tracked by git. Should I create a `hooks/` directory in the repo with the hook source and add setup instructions?

2. **Next milestone**: Ready for next milestone. Options:
   - Option A: Resolve Phase 1 blocking decisions (P1-P7 in `decisions/PRIORITY.md`)
   - Option B: Begin Phase 1 implementation
   - Option C: Other direction

---

## Technical Concerns / Risks

**Hook portability**: Git hooks in `.git/hooks/` are local and not shared via clone. Contributors would need to manually install the hook or use a setup script. Consider:
- Adding `hooks/pre-commit` to repo with install instructions
- Using a git hook manager like `husky` or `lefthook` (adds dependencies)

---

## Suggestions for Improvement

1. **Shared hooks**: Move hook source to `hooks/pre-commit` in repo and add install script or Makefile target.

2. **CI integration**: Also run coverage check in CI to catch issues from contributors who skip local hooks.

---

## Intended Next Step

**Awaiting human direction** on next milestone.

All Pre-commit Hook tasks (M4-T1 through M4-T4) are complete. M4-T5 (commit) in progress.

---

## Session Context

If you are a new AI session reading this file:

1. Read [MILESTONE.md](./MILESTONE.md) - Milestone "Pre-commit Hook" (M4) complete
2. Read [PROMPT_BACKLOG.md](./PROMPT_BACKLOG.md) - Unresolved items from previous work
3. Check [decisions/PRIORITY.md](../decisions/PRIORITY.md) - 7 blocking items for Phase 1
4. Wait for human prompt before proceeding
