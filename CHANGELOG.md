# Changelog

All notable changes to Cordial Cantina are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- V0.1 Foundation milestone issues created in GitHub
- `CordialCantina.Mnesia.Server` GenServer for Mnesia initialization (V0.1-M1-P1)
- Secrets management with `.env.example` and `runtime.exs` configuration (V0.1-M2-P1)
- Environment variable documentation in README

### Fixed
- CI pipeline: Added `mix compile` step before `mix precommit` (NIF requires compilation)
- GitHub Issues #2-#5: Fixed broken links (relative to absolute URLs)

---

## [0.0.0] - 2026-02-02

### Added

#### Documentation
- Hierarchical knowledge graph documentation structure
- DOCUMENTATION_STRATEGY.md with AI agent navigation guidance
- Process strategy for milestone-based bi-directional development
- Vw-Mx-Py-Tz work item coding system

#### Infrastructure
- GitHub Actions CI pipeline (Elixir, Rust, documentation coverage)
- Pre-commit hooks for documentation coverage validation
- Setup script with dependency checking

#### Application Foundation
- Phoenix/Elixir application structure
- Rust NIF scaffolding via Rustler with joltshark integration
- LiveView dashboard stub with PubSub real-time updates
- Mnesia GenServer strategy documented

#### Project Management
- GitHub Issues integration for task tracking
- GitHub milestone for V0.1 Foundation
- Labels for version and task type categorization

### Resolved Decisions

| ID | Decision | Summary |
|----|----------|---------|
| R1 | Database Architecture | Dual-database: Mnesia (hot) + PostgreSQL (cold) |
| R2 | Mnesia Initialization | GenServer strategy |
| R3 | OTP Supervision Model | Single-node default, third-party APIs for historical data |
| R4 | NIF Integration | Rustler, safe Rust trusted, dirty schedulers >1ms |
| R5 | Solana RPC | Public RPC for V0.1, Birdeye + Raydium APIs |
| R6 | Secrets Management | runtime.exs + env vars, production deferred |
| R7 | Testing Framework | excoveralls, 80% critical paths, Bypass for mocks |
| R8 | Mnesia Schema | Iterative definition per feature |
| R9 | Logging | Logger default format, telemetry events |

### Development History

| Code | Milestone | Key Deliverable |
|------|-----------|-----------------|
| V0.0-M0-P1 | Documentation Foundation | Knowledge graph structure |
| V0.0-M0-P2 | Process Refinement | Templates and backlog |
| V0.0-M0-P3 | Process Tooling | Coverage check script |
| V0.0-M0-P4 | Pre-commit Hook | Automated doc validation |
| V0.0-M0-P5 | Project Infrastructure | CI, hooks, setup script |
| V0.0-M0-P6 | Foundation Stubs | NIF and LiveView |
| V0.0-M0-P7 | CI and LiveView | Clippy fixes, PubSub |
| V0.0-M0-P8 | Coding System | Vw-Mx-Py-Tz format |
| V0.0-M0-P9 | Phase 1 Blockers | R3-R9 decisions |
| V0.0-M0-P10 | GitHub Issues | Project management migration |
| V0.0-M0-P11 | Finalize Migration | CHANGELOG, cleanup |
| V0.0-M0-P12 | CI Fix | Compile step, link repair |

---

## Version History

- **0.0.0** - Process Definition (V0.0-M0) complete
- **0.1.0** - Foundation (V0.1) - planned

[Unreleased]: https://github.com/sgeos/cordial_cantina/compare/v0.0.0...HEAD
[0.0.0]: https://github.com/sgeos/cordial_cantina/releases/tag/v0.0.0
