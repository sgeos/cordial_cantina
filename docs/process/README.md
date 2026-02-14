# Process

> **Navigation**: [Documentation Root](../README.md)

This section specifies development process and conventions for human/AI-agent collaboration.

---

## Contents

| Document | Description |
|----------|-------------|
| [Process Strategy](./PROCESS_STRATEGY.md) | Development workflow and GitHub Issues integration |
| [Git Strategy](./GIT_STRATEGY.md) | Version control conventions |

---

## Project Management

**Primary**: [GitHub Issues](https://github.com/sgeos/cordial_cantina/issues)

Tasks and milestones are tracked via GitHub Issues. See [Process Strategy](./PROCESS_STRATEGY.md#github-issues-integration) for workflow details.

---

## Session Working Documents

These files maintain state across AI sessions and enable bi-directional communication:

| Document | Direction | Purpose |
|----------|-----------|---------|
| [TASKLOG.md](./TASKLOG.md) | Shared | Current sprint source of truth |
| [PROMPT.md](./PROMPT.md) | Human → AI | Complex instruction staging |
| [REVERSE_PROMPT.md](./REVERSE_PROMPT.md) | AI → Human | Questions, concerns, next steps |

---

## Quick Start for New Sessions

1. Check [GitHub Issues](https://github.com/sgeos/cordial_cantina/issues) for open tasks
2. Read [TASKLOG.md](./TASKLOG.md) to understand current sprint state
3. Read [REVERSE_PROMPT.md](./REVERSE_PROMPT.md) for last AI communication
4. Check [PROCESS_STRATEGY.md](./PROCESS_STRATEGY.md) for workflow expectations
5. Wait for human prompt before proceeding

---

## Process Overview

Development follows **milestone sprints** (not time-based):
- Tasks tracked via GitHub Issues with labels and milestones
- Session state maintained in TASKLOG.md
- Bi-directional communication via PROMPT.md and REVERSE_PROMPT.md
- Releases documented in [CHANGELOG.md](../../CHANGELOG.md)

See [Process Strategy](./PROCESS_STRATEGY.md) for complete documentation.

---

## Related Sections

- [Roadmap](../roadmap/README.md) - Phase-level planning
- [Decisions](../decisions/README.md) - Decision tracking
- [CHANGELOG](../../CHANGELOG.md) - Release history
