# Milestone Template

> **Navigation**: [Process](./README.md) | [Documentation Root](../README.md)

Copy this template to create a new milestone in MILESTONE.md.

---

```markdown
# Current Milestone

> **Navigation**: [Process](./README.md) | [Documentation Root](../README.md)

This file is the source of truth for the current development sprint.

---

## Milestone: [NAME]

**Status**: In-Progress | Testing | Blocked | Complete

**Started**: YYYY-MM-DD

---

## Success Criteria

- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3

---

## Task Breakdown

| ID | Task | Status | Verification |
|----|------|--------|--------------|
| MX-T1 | Task description | Pending | Verification command |
| MX-T2 | Task description | Pending | Verification command |
| MX-T3 | Task description | Pending | Verification command |

---

## Notes

[Context, dependencies, or special considerations]

---

## History

| Date | Change |
|------|--------|
| YYYY-MM-DD | Milestone created |
```

---

## Field Definitions

### Status Values

| Status | Meaning |
|--------|---------|
| In-Progress | Active work underway |
| Testing | Implementation complete, verification in progress |
| Blocked | Cannot proceed until blocker resolved |
| Complete | All success criteria met |

### Task Status Values

| Status | Meaning |
|--------|---------|
| Pending | Not yet started |
| In-Progress | Currently being worked on |
| Complete | Done and verified |
| Blocked | Cannot proceed |
| Skipped | Intentionally not done |

### ID Convention

- Format: `MX-TY` where X is milestone number, Y is task number
- Example: `M3-T2` is task 2 of milestone 3
- Keep IDs stable once assigned (do not renumber)

### Verification

Every task should have a verification command or method:
- Code tasks: Test command (e.g., `mix test path/to/test.exs`)
- File tasks: Existence check (e.g., `ls path/to/file`)
- Documentation: Manual review or link check

---

## Checklist for New Milestones

- [ ] Copy template to MILESTONE.md
- [ ] Set milestone name and start date
- [ ] Define clear, verifiable success criteria
- [ ] Break down into specific tasks with IDs
- [ ] Assign verification method to each task
- [ ] Archive previous milestone to history (optional)
