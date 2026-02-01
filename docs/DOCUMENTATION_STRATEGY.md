# DOCUMENTATION_STRATEGY.md

> **Navigation**: [Documentation Root](./README.md)

This document describes the documentation strategy for Cordial Cantina. It serves as a meta-prompt for AI agents and a guide for human reviewers.

---

## Purpose

This documentation system is a **High-Density Information Architecture** designed to:

1. Serve as a complete product and process specification
2. Enable efficient AI-agent navigation without context window overload
3. Support human review through logical organization
4. Function as an external memory module for AI agents

The documentation is structured as a **knowledge graph** encoded in the file system.

---

## Design Principles

### Atomic Files

Each file contains **one concept**. This keeps the Signal-to-Noise Ratio (SNR) high.

**Example**: Instead of a monolithic `MATH.md`, we have separate files:
- `INVARIANT.md` for the CPMM invariant
- `FEES.md` for fee calculations
- `PRICE_IMPACT.md` for slippage modeling

When an AI agent needs to verify the CPMM invariant, it loads only `INVARIANT.md` rather than ingesting irrelevant material.

### Hierarchical Organization

- **High-level files** provide orientation and context
- **Low-level files** provide precision and implementation detail
- **Table of Contents (ToC)** files (`README.md`) exist at each directory level

This solves the **Context Window vs. Precision trade-off**: agents can navigate to the precise information needed without loading the entire specification.

### Breadcrumb Navigation

Every file contains an upward navigation link to its parent ToC:

```markdown
> **Navigation**: [Parent Section](../README.md)
```

If an agent gets lost, it can always "go up" to find the next relevant file.

### Naming Convention

- **UPPER_SNAKE_CASE** for file names
- **Lowercase `.md`** extension
- **README.md** for table of contents files

Examples: `THREE_RANGE_MODEL.md`, `PERFORMANCE.md`, `GLOSSARY.md`

---

## Directory Structure

```
docs/
├── README.md                    # Master ToC - entry point
├── DOCUMENTATION_STRATEGY.md    # This file
│
├── overview/                    # Product overview
│   ├── README.md
│   ├── PRODUCT_IDENTITY.md
│   ├── EXECUTIVE_SUMMARY.md
│   └── HYPOTHESES.md
│
├── strategy/                    # Trading strategy
│   ├── README.md
│   ├── THREE_RANGE_MODEL.md
│   ├── POSITION_ESTABLISHMENT.md
│   ├── REBALANCING.md
│   └── LIQUIDITY_WITHDRAWAL.md
│
├── physical_model/              # Physical modeling
│   ├── README.md
│   ├── MANIFOLD_REPRESENTATION.md
│   ├── PHYSICAL_ANALOGS.md
│   └── TEMPORAL_CYCLES.md
│
├── integration/                 # External systems
│   ├── README.md
│   ├── SOLANA_RPC.md
│   ├── RAYDIUM_PROTOCOL.md
│   └── EXTERNAL_SIGNALS.md
│
├── architecture/                # Technical architecture
│   ├── README.md
│   ├── TECHNOLOGY_STACK.md
│   ├── SUPERVISION_TREE.md
│   ├── DATA_STORAGE.md
│   └── STATE_MANAGEMENT.md
│
├── requirements/                # Non-functional requirements
│   ├── README.md
│   ├── PERFORMANCE.md
│   ├── SECURITY.md
│   ├── RELIABILITY.md
│   ├── TESTING.md
│   └── ACCEPTANCE_CRITERIA.md
│
├── roadmap/                     # Development phases
│   ├── README.md
│   ├── PHASE_1_FOUNDATION.md
│   ├── PHASE_2_MARKET_DATA.md
│   ├── PHASE_3_PHYSICAL_MODEL.md
│   ├── PHASE_4_STRATEGY.md
│   ├── PHASE_5_INTEGRATION.md
│   └── PHASE_6_PRODUCTION.md
│
├── decisions/                   # Architectural decisions
│   ├── README.md
│   ├── RESOLVED.md
│   ├── PRIORITY.md
│   └── BACKLOG.md
│
├── process/                     # Development process
│   ├── README.md
│   ├── PROCESS_STRATEGY.md
│   ├── GIT_STRATEGY.md
│   ├── MILESTONE.md             # Current sprint (working document)
│   ├── PROMPT.md                # Human → AI (working document)
│   ├── REVERSE_PROMPT.md        # AI → Human (working document)
│   ├── PROMPT_BACKLOG.md        # Persistent concerns
│   ├── MILESTONE_TEMPLATE.md    # Template
│   └── PROMPT_TEMPLATE.md       # Template
│
└── reference/                   # Reference material
    ├── README.md
    ├── GLOSSARY.md
    ├── RISKS.md
    └── RESEARCH_QUESTIONS.md
```

---

## How to Read (For AI Agents)

This section is a **meta-prompt** for AI agents working with this documentation.

### Navigating the Knowledge Tree

1. **Start at `docs/README.md`** to understand available sections
2. **Read section `README.md` files** to understand what each section contains
3. **Load atomic files only when needed** for the specific task at hand
4. **Use upward navigation links** if you need to reorient

### Context Management Strategy

**Do**:
- Load the relevant section README first to understand available files
- Load only the specific atomic files needed for the current task
- Trust that related information exists in sibling files (check ToC if needed)

**Do not**:
- Load all documentation files at once
- Assume a single file contains all relevant information
- Ignore navigation links when exploring unfamiliar sections

### Finding Information

| If you need... | Start here |
|----------------|------------|
| Product overview | `overview/README.md` |
| Trading logic details | `strategy/README.md` |
| Physical modeling math | `physical_model/README.md` |
| Solana/Raydium integration | `integration/README.md` |
| OTP supervision design | `architecture/SUPERVISION_TREE.md` |
| Database design | `architecture/DATA_STORAGE.md` |
| Performance requirements | `requirements/PERFORMANCE.md` |
| Security requirements | `requirements/SECURITY.md` |
| Current development phase | `roadmap/README.md` |
| Unresolved decisions | `decisions/PRIORITY.md` |
| Resolved decisions | `decisions/RESOLVED.md` |
| **Current milestone/sprint** | `process/MILESTONE.md` |
| **Development process** | `process/PROCESS_STRATEGY.md` |
| Git workflow | `process/GIT_STRATEGY.md` |
| Unresolved concerns | `process/PROMPT_BACKLOG.md` |
| Terminology | `reference/GLOSSARY.md` |

### Verification Pattern

When implementing a feature:

1. Read the relevant **strategy** file for business logic
2. Read the relevant **requirements** file for constraints
3. Check **decisions/PRIORITY.md** for open questions
4. Check **decisions/RESOLVED.md** for settled decisions
5. Consult **reference/GLOSSARY.md** for terminology

### Updating Documentation

When documentation changes are needed:

1. Identify the correct atomic file for the change
2. If no appropriate file exists, create one following naming conventions
3. Update the parent `README.md` ToC if adding a new file
4. Add upward navigation link to new files
5. Keep changes focused on the single concept of that file

---

## How to Review (For Humans)

### Section-Based Review

Each section can be reviewed independently:

- Approve `strategy/` without re-reading `requirements/`
- Review `architecture/` changes without loading `physical_model/`
- Focus on `decisions/` when evaluating architectural choices

### Audit Trail

- `decisions/RESOLVED.md` documents completed decisions with rationale
- `decisions/PRIORITY.md` tracks blocking questions
- `decisions/BACKLOG.md` records deferred items

### Change Impact

When reviewing changes:

1. Check which section(s) are modified
2. Review the section `README.md` for context
3. Examine only the modified atomic files
4. Verify navigation links are maintained

---

## Maintenance Guidelines

### Adding New Concepts

1. Determine the appropriate section
2. Create a new atomic file with UPPER_SNAKE_CASE name
3. Add navigation link at the top
4. Update the section `README.md` ToC
5. Cross-reference from related files if appropriate

### Splitting Large Files

If a file grows beyond ~200-300 lines and covers multiple concepts:

1. Identify the distinct concepts
2. Create separate atomic files for each
3. Update the parent ToC
4. Add cross-references between related files

### Deprecating Content

1. Remove from parent ToC first
2. Add deprecation notice to file if keeping for history
3. Or delete file entirely if no longer relevant
4. Update any cross-references in other files

---

## Version History

| Date | Author | Changes |
|------|--------|---------|
| 2026-02-01 | Claude | Initial documentation strategy |
