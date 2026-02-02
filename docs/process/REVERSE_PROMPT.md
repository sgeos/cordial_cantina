# Reverse Prompt

> **Navigation**: [Process](./README.md) | [Documentation Root](../README.md)

This file is the AI-to-human communication channel. It is overwritten after each completed task.

---

## Last Updated

**Date**: 2026-02-01
**Task**: M5 Project Infrastructure complete
**Milestone**: M5 Project Infrastructure

---

## Verification

### M5-T1: Create hooks/ directory with shared pre-commit
**Command**: `ls -la hooks/`
**Result**: PASS - `hooks/pre-commit` created with documentation coverage check

### M5-T2: Create setup script
**Command**: `./scripts/setup.sh`
**Result**: PASS - Script installs hooks, checks dependencies, fetches Elixir deps

### M5-T3: Create CI workflow
**Command**: `ls -la .github/workflows/ci.yml`
**Result**: PASS - GitHub Actions workflow with documentation, Elixir, and Rust jobs

### M5-T4: Create top-level README.md
**Command**: `head -30 README.md`
**Result**: PASS - Documents structure, setup, subprojects with POSIX-compliant instructions

### M5-T5: Update PROMPT_BACKLOG.md
**Result**: PASS - Resolved B1 (milestone naming), B2 (verification depth), B4 (CI). Added B5 (project management), B6 (CLAUDE.md strategy)

### M5-T6: Test CI workflow locally
**Command**: `cd cordial_cantina && mix precommit`
**Result**: PASS - 5 tests, 0 failures

### M5-T7: Update REVERSE_PROMPT.md
**Result**: This file

### M5-T8: Commit all changes
**Status**: PENDING

---

## Files Created/Modified

**Created**:
- `README.md` - Top-level project README
- `hooks/pre-commit` - Shared git hook (tracked in repo)
- `scripts/setup.sh` - Environment setup script
- `.github/workflows/ci.yml` - GitHub Actions CI workflow

**Modified**:
- `docs/process/MILESTONE.md` - M5 milestone
- `docs/process/MILESTONE_HISTORY.md` - Archived M4
- `docs/process/PROMPT_BACKLOG.md` - Resolved B1, B2, B4; added B5, B6

---

## Questions for Human Pilot

### 1. CLAUDE.md Inclusion Strategy (B6)

You want to include your master `~/.claude/CLAUDE.md` in the repo for reference without AI-agent auto-loading. Options:

**Option A: Reference directory** (Recommended)
Create `reference/claude/` directory with the file:
```
reference/
└── claude/
    └── USER_CLAUDE_MD_EXAMPLE.md
```
The naming avoids auto-detection. Add note in README explaining it is for human reference.

**Option B: Docs section**
Add to `docs/reference/` as `CLAUDE_MD_REFERENCE.md` with a header noting it is not for AI consumption.

**Option C: Dotfile approach**
Store as `.claude-md-reference` (hidden file, not auto-detected).

I recommend **Option A** as it clearly separates reference material and the explicit naming prevents confusion.

### 2. Project Management Integration (B5)

Agreed that file-based tracking has limitations. Options to consider:
- **GitHub Issues**: Native integration, links to commits/PRs
- **GitHub Projects**: Kanban boards built on Issues
- **Linear**: Better UX, good GitHub integration
- **Notion**: Flexible but less code-integrated

For now, milestones in `MILESTONE.md` work for process definition. When real development starts, GitHub Issues would integrate naturally with the existing GitHub Actions CI.

### 3. Process Definition Macro-Milestone

Noted that we are in the "process definition" macro-milestone. The bi-directional loop appears functional:
- PROMPT.md for instructions
- REVERSE_PROMPT.md for feedback
- MILESTONE.md for tracking
- Pre-commit hooks for quality gates
- CI for verification

Is the process definition complete, or are there additional workflow elements needed?

---

## Technical Concerns / Risks

**CI not tested on GitHub**: The workflow file is created but not yet run on GitHub. First push to GitHub with this workflow will reveal any issues with action versions or configuration.

**Rust edition 2024**: `joltshark/Cargo.toml` specifies `edition = "2024"` which requires Rust 1.85+. CI uses `dtolnay/rust-action@stable` which should work, but verify the runner has a recent enough toolchain.

---

## Suggestions for Improvement

1. **joltshark README**: The Rust subproject lacks a README.md. Consider adding one for completeness.

2. **Makefile**: Consider adding a top-level Makefile with common targets (`make setup`, `make test`, `make precommit`) as an alternative to scripts.

3. **CI badge**: After first successful CI run, add status badge to README.md.

---

## Intended Next Step

**Awaiting human direction** on:
1. CLAUDE.md inclusion strategy decision
2. Confirmation that process definition is complete
3. Next milestone direction (requirements clarification vs implementation)

---

## Session Context

If you are a new AI session reading this file:

1. Read [MILESTONE.md](./MILESTONE.md) - M5 Project Infrastructure complete (pending commit)
2. Read [PROMPT_BACKLOG.md](./PROMPT_BACKLOG.md) - B3, B5, B6 open
3. Check [decisions/PRIORITY.md](../decisions/PRIORITY.md) - 7 blocking items for Phase 1
4. Macro-milestone: Process definition (near completion)
5. Wait for human prompt before proceeding
