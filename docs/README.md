# Cordial Cantina Documentation

> **Project**: Cordial Cantina
> **Version**: 0.1.0-alpha
> **Status**: Specification draft under active development

This is the documentation root for Cordial Cantina, a concentrated liquidity market maker (CLMM) trading system for Solana blockchain.

---

## Quick Navigation

| Section | Description |
|---------|-------------|
| [Overview](./overview/README.md) | Product identity, summary, and hypotheses |
| [Strategy](./strategy/README.md) | Trading strategy specification |
| [Physical Model](./physical_model/README.md) | Riemannian manifold and physics modeling |
| [Integration](./integration/README.md) | External system integration (Solana, Raydium) |
| [Architecture](./architecture/README.md) | Technical architecture and design |
| [Requirements](./requirements/README.md) | Performance, security, and reliability |
| [Roadmap](./roadmap/README.md) | Development phases and milestones |
| [Decisions](./decisions/README.md) | Architectural decision tracking |
| [Process](./process/README.md) | Development process and conventions |
| [Reference](./reference/README.md) | Glossary, risks, and research questions |

---

## Meta Documentation

- [Documentation Strategy](./DOCUMENTATION_STRATEGY.md) - How this documentation is organized and how to use it

---

## Document Hierarchy

```
docs/
├── README.md                    ← You are here
├── DOCUMENTATION_STRATEGY.md
│
├── overview/                    Product overview
│   ├── PRODUCT_IDENTITY.md
│   ├── EXECUTIVE_SUMMARY.md
│   └── HYPOTHESES.md
│
├── strategy/                    Trading strategy
│   ├── THREE_RANGE_MODEL.md
│   ├── POSITION_ESTABLISHMENT.md
│   ├── REBALANCING.md
│   └── LIQUIDITY_WITHDRAWAL.md
│
├── physical_model/              Physical modeling
│   ├── MANIFOLD_REPRESENTATION.md
│   ├── PHYSICAL_ANALOGS.md
│   └── TEMPORAL_CYCLES.md
│
├── integration/                 External systems
│   ├── SOLANA_RPC.md
│   ├── RAYDIUM_PROTOCOL.md
│   └── EXTERNAL_SIGNALS.md
│
├── architecture/                Technical architecture
│   ├── TECHNOLOGY_STACK.md
│   ├── SUPERVISION_TREE.md
│   ├── DATA_STORAGE.md
│   └── STATE_MANAGEMENT.md
│
├── requirements/                Non-functional requirements
│   ├── PERFORMANCE.md
│   ├── SECURITY.md
│   ├── RELIABILITY.md
│   ├── TESTING.md
│   └── ACCEPTANCE_CRITERIA.md
│
├── roadmap/                     Development phases
│   ├── PHASE_1_FOUNDATION.md
│   ├── PHASE_2_MARKET_DATA.md
│   ├── PHASE_3_PHYSICAL_MODEL.md
│   ├── PHASE_4_STRATEGY.md
│   ├── PHASE_5_INTEGRATION.md
│   └── PHASE_6_PRODUCTION.md
│
├── decisions/                   Architectural decisions
│   ├── RESOLVED.md
│   ├── PRIORITY.md
│   └── BACKLOG.md
│
├── process/                     Development process
│   └── GIT_STRATEGY.md
│
└── reference/                   Reference material
    ├── GLOSSARY.md
    ├── RISKS.md
    └── RESEARCH_QUESTIONS.md
```

---

## For AI Agents

See [Documentation Strategy](./DOCUMENTATION_STRATEGY.md#how-to-read-for-ai-agents) for navigation patterns and context management guidance.

**Quick start**: Load only the section README relevant to your current task, then drill into atomic files as needed.

---

## For Human Reviewers

Each section can be reviewed independently. See [Documentation Strategy](./DOCUMENTATION_STRATEGY.md#how-to-review-for-humans) for review guidance.
