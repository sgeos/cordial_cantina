# Process Strategy

> **Navigation**: [Process](./README.md) | [Documentation Root](../README.md)

This document describes the milestone-based, bi-directional development loop for human/AI-agent collaboration.

---

## Overview

Development follows **milestone sprints** rather than time-based sprints. Each milestone has clear success criteria and is complete when all criteria are met, regardless of elapsed time.

The process uses three working documents for bi-directional communication:

| Document | Direction | Purpose |
|----------|-----------|---------|
| [PROMPT.md](./PROMPT.md) | Human → AI | Complex instruction staging |
| [MILESTONE.md](./MILESTONE.md) | Shared | Current sprint source of truth |
| [REVERSE_PROMPT.md](./REVERSE_PROMPT.md) | AI → Human | Questions, concerns, next steps |

---

## Milestone Sprints

### Why Milestone-Based

Time-based sprints (e.g., 2-week sprints) create artificial pressure and often result in incomplete work or arbitrary scope cuts. Milestone sprints:

- Focus on **completion quality** over deadline adherence
- Allow natural task boundaries to define scope
- Support asynchronous human/AI collaboration
- Enable clear success/failure determination

### Milestone Structure

Each milestone in [MILESTONE.md](./MILESTONE.md) includes:

1. **Name**: Descriptive identifier for the milestone
2. **Status**: In-Progress, Testing, Blocked, or Complete
3. **Success Criteria**: Specific, verifiable conditions for completion
4. **Task Breakdown**: Granular tasks with completion status

---

## Bi-Directional Communication

### Forward Prompts (Human → AI)

**File**: [PROMPT.md](./PROMPT.md)

The human pilot uses this file to:
- Draft complex instructions before prompting
- Refine multi-step requests
- Preserve prompt history in git

**Usage**:
1. Human writes detailed instructions in PROMPT.md
2. Human prompts AI: "Please execute the instructions in PROMPT.md"
3. AI reads and executes instructions
4. **AI commits PROMPT.md** along with other changes

**Critical rule**: PROMPT.md must always be committed to preserve collaboration history. The git history of PROMPT.md provides a complete record of human-to-AI instructions across the project lifecycle. This history is valuable for:
- Understanding decision context in future sessions
- Auditing the collaboration process
- Reconstructing the rationale behind implementation choices

### Reverse Prompts (AI → Human)

**File**: [REVERSE_PROMPT.md](./REVERSE_PROMPT.md)

After completing prompted instructions, the AI **must** overwrite this file with:

| Section | Content |
|---------|---------|
| Questions for Human Pilot | Clarifications needed, ambiguities encountered |
| Technical Concerns/Risks | Issues discovered, potential problems |
| Suggestions for Improvement | Optimizations, alternative approaches |
| Next Step | What the AI intends to do next (or is blocked on) |

**Critical rule**: If the AI is blocked or uncertain, it must document the blocker in REVERSE_PROMPT.md and **stop** rather than proceeding with assumptions.

---

## Task Completion Protocol

When the AI completes a task:

1. **Update MILESTONE.md**: Mark the task as complete
2. **Update REVERSE_PROMPT.md**: Include:
   - Verification command used (e.g., `mix test`, `cargo build`)
   - Verification result (pass/fail)
   - Any concerns or follow-up items
3. **Commit changes**: Use conventional commit referencing the task
4. **Proceed or stop**: Continue to next task or stop if blocked

### Verification Requirement

For every task marked "Complete" in MILESTONE.md, the AI must provide in REVERSE_PROMPT.md:

```markdown
## Verification

**Task**: [Task name from MILESTONE.md]
**Command**: `mix test test/path/to/test.exs`
**Result**: PASS (or FAIL with details)
```

If verification fails, the task is **not** complete.

---

## Work Item Coding System

All work items use the **Vw-Mx-Py-Tz** coding system for traceability across milestones, prompts, and tasks.

### Format

`Vw-Mx-Py-Tz`

| Component | Meaning | Example |
|-----------|---------|---------|
| Vw | Version (Phase) | V0.0 = Phase 0, V0.1 = Phase 1 |
| Mx | Milestone within version | M0 = Process definition |
| Py | Prompt within milestone | P7 = 7th prompt |
| Tz | Task within prompt | T3 = 3rd task |

### Version Mapping

| Phase | Version |
|-------|---------|
| Phase 0 (Process Definition) | V0.0 |
| Phase 1 (Foundation) | V0.1 |
| Phase 2 (Market Data) | V0.2 |
| Phase 3 (Physical Model) | V0.3 |
| Phase 4 (Strategy) | V0.4 |
| Phase 5 (Integration) | V0.5 |
| Phase 6 (Production) | V0.6 |

### Examples

- `V0.0-M0-P8-T3` = Phase 0, Milestone 0, Prompt 8, Task 3
- `V0.1-M2-P1-T1` = Phase 1, Milestone 2, Prompt 1, Task 1
- `V0.3-M1-P5` = Phase 3, Milestone 1, Prompt 5 (no specific task)

### Usage

- **MILESTONE.md**: Tasks use full Vw-Mx-Py-Tz format
- **MILESTONE_HISTORY.md**: Archived prompts include full coding
- **Git commits**: Reference task codes in commit messages
- **GitHub Issues**: Issue titles include Vw-Mx-Py or Vw-Mx-Py-Tz codes

---

## Commit Convention

Commits during milestone work should reference the milestone and task:

```
<scope>: <description>

[Milestone: <milestone-name>]
[Task: <task-identifier>]

Co-Authored-By: Claude <noreply@anthropic.com>
```

Example:
```
feat: implement Mnesia table initialization

[Milestone: V0.1-M2 Database Schema]
[Task: V0.1-M2-P3-T1]

Co-Authored-By: Claude <noreply@anthropic.com>
```

---

## Workflow Example

```
┌─────────────────────────────────────────────────────────────────┐
│ 1. Human creates/updates MILESTONE.md with sprint scope         │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│ 2. Human drafts complex instructions in PROMPT.md (optional)    │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│ 3. Human prompts AI with task (directly or via PROMPT.md)       │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│ 4. AI executes task                                             │
│    - Implements changes                                         │
│    - Runs verification                                          │
│    - Updates MILESTONE.md task status                           │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│ 5. AI overwrites REVERSE_PROMPT.md                              │
│    - Documents verification command and result                  │
│    - Lists questions, concerns, suggestions                     │
│    - States intended next step                                  │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│ 6. AI commits changes with conventional commit                  │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│ 7. Human reviews REVERSE_PROMPT.md                              │
│    - Answers questions                                          │
│    - Addresses concerns                                         │
│    - Approves or redirects next step                            │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
                        (Repeat 3-7)
```

---

## Blocking Protocol

When the AI encounters a blocker:

1. **Do not proceed with assumptions**
2. **Document in REVERSE_PROMPT.md**:
   - What is blocked
   - Why it is blocked
   - What information or decision is needed
3. **Update MILESTONE.md status** to "Blocked" if milestone-level
4. **Commit current state**
5. **Stop and wait** for human response

---

## Session Continuity

These files maintain state across sessions:

- **MILESTONE.md**: Shows current sprint state for any new session
- **REVERSE_PROMPT.md**: Shows last AI communication for context
- **PROMPT.md**: Preserves complex prompts for re-execution if needed

A new AI session should read MILESTONE.md first to understand current state.

---

## Related Documents

- [Git Strategy](./GIT_STRATEGY.md) - Version control conventions
- [Roadmap](../roadmap/README.md) - Phase-level planning
- [Decisions](../decisions/README.md) - Decision tracking
