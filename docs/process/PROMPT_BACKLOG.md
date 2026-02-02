# Prompt Backlog

> **Navigation**: [Process](./README.md) | [Documentation Root](../README.md)

This file records AI-agent concerns, questions, and suggestions that need human attention. Items here persist across REVERSE_PROMPT.md overwrites.

---

## How to Use

**AI agents**: When overwriting REVERSE_PROMPT.md, copy important unresolved items here before they are lost.

**Human pilot**: Review this backlog periodically. Mark items as resolved or transfer to appropriate documents.

---

## Unresolved Items

### From Milestone: M5 Project Infrastructure (2026-02-01)

| ID | Type | Item | Status |
|----|------|------|--------|
| B5 | Suggestion | Consider integration with project management/issue tracking system (GitHub Issues, Linear, etc.) to track features and fixes above repo level | Open |
| B6 | Question | CLAUDE.md inclusion strategy - how to include user's master ~/.claude/CLAUDE.md for reference without AI-agent auto-loading | Open |

### From Milestone: Documentation Foundation (2026-02-01)

| ID | Type | Item | Status |
|----|------|------|--------|
| B3 | Suggestion | Consider adding CHANGELOG.md for milestone completion history | Open |

---

## Resolved Items

| ID | Type | Item | Resolution | Date |
|----|------|------|------------|------|
| B1 | Question | Should milestones use a prefix (M1, M2) or descriptive names only? | Use prefix with unambiguous logical code (e.g., M5) | 2026-02-01 |
| B2 | Question | What verification depth for code tasks? | Passing `mix precommit` | 2026-02-01 |
| B4 | Suggestion | Consider CI integration for automated task verification | Implemented in M5 via GitHub Actions | 2026-02-01 |

---

## Item Types

| Type | Description |
|------|-------------|
| Question | Needs human decision or clarification |
| Concern | Technical risk or issue requiring attention |
| Suggestion | Improvement idea for consideration |
| Blocker | Cannot proceed without resolution |

---

## Status Values

| Status | Meaning |
|--------|---------|
| Open | Needs attention |
| In-Progress | Being addressed |
| Resolved | Addressed (move to Resolved Items) |
| Deferred | Intentionally postponed |
| Rejected | Decided against |
