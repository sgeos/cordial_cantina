# Process

> **Navigation**: [Documentation Root](../README.md)

This section specifies development process and conventions for human/AI-agent collaboration.

---

## Contents

| Document | Description |
|----------|-------------|
| [Process Strategy](./PROCESS_STRATEGY.md) | Milestone-based development loop |
| [Git Strategy](./GIT_STRATEGY.md) | Version control conventions |

---

## Working Documents

These files maintain state across sessions and enable bi-directional communication:

| Document | Direction | Purpose |
|----------|-----------|---------|
| [MILESTONE.md](./MILESTONE.md) | Shared | Current sprint source of truth |
| [PROMPT.md](./PROMPT.md) | Human → AI | Complex instruction staging |
| [REVERSE_PROMPT.md](./REVERSE_PROMPT.md) | AI → Human | Questions, concerns, next steps |

---

## Quick Start for New Sessions

1. Read [MILESTONE.md](./MILESTONE.md) to understand current sprint state
2. Read [REVERSE_PROMPT.md](./REVERSE_PROMPT.md) for last AI communication
3. Check [PROCESS_STRATEGY.md](./PROCESS_STRATEGY.md) for workflow expectations
4. Wait for human prompt before proceeding

---

## Process Overview

Development follows **milestone sprints** (not time-based):
- Each milestone has clear success criteria
- Tasks are tracked with completion status
- Verification commands are documented
- Bi-directional communication via REVERSE_PROMPT.md

See [Process Strategy](./PROCESS_STRATEGY.md) for complete documentation.

---

## Related Sections

- [Roadmap](../roadmap/README.md) - Phase-level planning
- [Decisions](../decisions/README.md) - Decision tracking
