# Prompt Staging Area

> **Navigation**: [Process](./README.md) | [Documentation Root](../README.md)

This file is a staging area for complex human-to-AI instructions. The human pilot drafts and refines prompts here before execution.

---

# Current Prompt

## Comments

GitHub CI has been verified as passing.

Rust project has been updated to include functions to provide signals indicating
market operating cycles to manifold and AI-model layers.

Answers to questions:
1. I think I pushed the v0.0.0 and v0.1.0 tags to remote.
2. Please create GitHub issues for the suggested V0.2 milestones.
3. Please setup and integrate Ecto/PostgreSQL.

## Objectives

### Decision : B2 - Message Queue Selection

Broadway is sufficient at this time.
Please update the knowledge graph.

### Partial Decision : B3 - Historical Data Sources

Please suggest concrete datasources in your next reverse prompt.
My understanding is that BTC is a proxy signal for the health of everything Crypto.
I want the following signals, and I want to keep data source dependencies streamlined and minimal:

- BTC price
- Upstream TradFi signals likely to influence the BTC price

Please update the knowledge graph if sensible.

### Accept Recommendations

1. Define Mnesia market data schema.
   Create specific tables for price feeds and order books per R8 iterative approach.
2. Add PostgreSQL/Ecto for time-series persistence and offload from Mnesia.
3. Adopt Broadway for high-throughput data ingestion.
4. Add mint WebSocket client to support Birdeye real-time data.
5. Will need to see real signal data before we can figure out what is anomalous.

### Rename MILESTONE.md to TASKLOG.md

`MILESTONE.md`'s function appears to have drifted,
but it makes sense to retain the file.
Rename `MILESTONE.md` to `TASKLOG.md` and update the knowledge graph.

### Address Updated Rust Project

If the knowledge graph or anything else needs to be updated to
reflect the changes in the Rust project, please do this.

### Create V0.2 Milestone GitHub Issues

Create GitHub issues for the suggested V0.2 milestones.

## Context

Clearing blockers for V0.2.
Refining process.

## Constraints

(none)

## Success Criteria

- B2 decision documented.
- B3 decision documented if sensible.
- Initial Mnesia market data schema defined.
- PostgreSQL/Ecto added and integrated. Schema mirrors Mnesia.
- Broadway added and integrated.
- mint WebSocket added and integrated.
- `MILESTONE.md` renamed to `TASKLOG.md` and knowledge graph updated.
- Knowledge graph and other relevant files updated to reflect Rust project additions.
- GitHub V0.2 milestone issues created.

## Notes

(none)
