# Prompt Staging Area

> **Navigation**: [Process](./README.md) | [Documentation Root](../README.md)

This file is a staging area for complex human-to-AI instructions. The human pilot drafts and refines prompts here before execution.

---

# Current Prompt

## Objective

Please draft the following files.
- `docs/process/MILESTONE_HISTORY.md`: for archiving completed milestones.
- **Documentation coverage check script**: to verify all markdown files are referenced in their parent README.md.

## Context

Reasonable reverse prompt suggestions.

## Constraints

Script should use `#!/bin/sh` and be POSIX compliant.
Ideally, rely on portable commands, but it is OK if commands or tool versions are OS-specific.
I am developing on an M1 Mac.

## Success Criteria

MILESTONE_HISTORY.md added, documentation coverage check script tested and working.
Documentation update to reflect new file and coverage check script usage.

## Notes

Consider which files should be listed in the top level docs/README.md.
