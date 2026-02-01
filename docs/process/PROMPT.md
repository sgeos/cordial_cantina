# Prompt Staging Area

> **Navigation**: [Process](./README.md) | [Documentation Root](../README.md)

This file is a staging area for complex human-to-AI instructions. The human pilot drafts and refines prompts here before execution.

---

## Current Prompt

*No prompt currently staged.*

---

## Usage

1. Draft your complex instructions in this file
2. Commit the file to preserve prompt history
3. Prompt the AI: "Please execute the instructions in PROMPT.md"
4. The AI will read and execute the instructions

---

## Prompt History

Prompt history is preserved in git. Use `git log -p docs/process/PROMPT.md` to view previous prompts.

---

## Template

When drafting a prompt, consider including:

```markdown
## Objective

[What should be accomplished]

## Context

[Background information the AI needs]

## Constraints

[Limitations, requirements, or boundaries]

## Success Criteria

[How to verify the task is complete]

## Notes

[Additional guidance or preferences]
```
