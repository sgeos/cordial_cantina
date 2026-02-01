# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Cordial Cantina is a concentrated liquidity market maker (CLMM) trading system for Solana blockchain. The system applies physical modeling concepts from Riemannian geometry and classical mechanics to manage three non-overlapping liquidity positions on Raydium AMM.

**Status**: 0.1.0-alpha specification draft under active development

**Core Hypothesis**: A profitable predictive market model can be constructed by representing market dynamics on a Riemannian manifold with physical analogs including orbital mechanics, kinetic energy, potential energy, velocity, acceleration, and jolt. This hypothesis is unverified.

## Repository Structure

```
cordial_cantina/           # Root directory
├── cordial_cantina/       # Phoenix/Elixir web application
│   ├── lib/
│   │   ├── cordial_cantina/         # Business logic and domain context
│   │   └── cordial_cantina_web/     # Phoenix web layer
│   ├── test/              # ExUnit test suite
│   ├── assets/            # Frontend (Tailwind CSS, TypeScript, esbuild)
│   └── config/            # Environment-specific configuration
├── joltshark/             # Rust library for numerical computation (future NIFs)
└── docs/
    └── SPECIFICATION.md   # Comprehensive product specification
```

## Common Commands

All commands run from the `cordial_cantina/` directory.

```bash
# Development setup
mix setup                      # Install deps, build assets

# Run server
iex -S mix phx.server          # Interactive REPL with Phoenix
mix phx.server                 # Non-interactive server

# Pre-commit validation (REQUIRED before committing)
mix precommit                  # Runs: compile --warnings-as-errors, deps.unlock --unused, format, test

# Testing
mix test                       # Run all tests
mix test test/path/file.exs    # Run specific test file
mix test --failed              # Re-run failed tests

# Code quality
mix compile --warnings-as-errors
mix format
mix deps.unlock --unused
```

## Technology Stack

- **Elixir 1.15+** with **Phoenix 1.8** and **LiveView 1.1**
- **OTP** supervision trees for fault tolerance
- **Rust** (joltshark crate) for performance-critical numerical computation
- **Tailwind CSS 4** with **esbuild** for frontend assets
- **Bandit** HTTP server

## Key Guidelines

Refer to `cordial_cantina/AGENTS.md` for detailed Phoenix and Elixir conventions. Critical rules include:

### Phoenix LiveView
- Always wrap LiveView templates with `<Layouts.app flash={@flash} ...>`
- Use `<.icon name="hero-x-mark">` for icons, never Heroicons modules
- Use `<.input>` and `<.form>` components from core_components.ex
- Use LiveView streams for collections to avoid memory issues
- Never use deprecated `phx-update="append"` or `phx-update="prepend"`
- Colocated JS hook names must start with `.` prefix

### Elixir
- Lists do not support index access syntax. Use `Enum.at/2` or pattern matching
- Never nest multiple modules in the same file
- Never use map access syntax on structs
- Use `to_form/2` for forms, never pass changesets directly to templates

### Testing
- Always use `start_supervised!/1` to start processes in tests
- Avoid `Process.sleep/1`. Use `Process.monitor/1` and assert on DOWN messages
- Use `_ = :sys.get_state/1` for synchronization instead of sleeping

### HTTP Requests
- Use the included `Req` library. Avoid HTTPoison, Tesla, and :httpc

### Frontend
- Tailwind CSS 4 uses `@import "tailwindcss"` syntax in app.css
- Never write inline `<script>` tags. Use colocated hooks with `:type={Phoenix.LiveView.ColocatedHook}`
- Never use `@apply` in CSS

## Architecture Notes

### OTP Supervision

See `docs/SUPERVISION_TREE.md` for the complete supervision tree design.

**Subsystem supervisors**:
- `CordialCantina.Mnesia.Supervisor` - Mnesia table initialization
- `CordialCantina.Data.Supervisor` - Data offload (Mnesia to PostgreSQL)
- `CordialCantina.RPC.Supervisor` - Solana RPC connection management
- `CordialCantina.Market.Supervisor` - Market data ingestion
- `CordialCantina.Strategy.Supervisor` - Trading strategy execution
- `CordialCantina.Blockchain.Supervisor` - Transaction building and monitoring

**Infrastructure** (Phoenix standard):
- CordialCantinaWeb.Telemetry, DNSCluster, Phoenix.PubSub, Finch, CordialCantinaWeb.Endpoint

### Rust NIFs (joltshark)
The `joltshark/` crate provides `no_std` compatible numerical computation. Uses `num-traits` for generic scalar operations. Designed for state vectors representing position, velocity, acceleration, and jolt.

### Three-Range Trading Strategy
The system manages three adjacent, non-overlapping liquidity ranges:
- **R_fee**: Primary fee generation range centered on expected trading price
- **R_restock**: Below R_fee, acquires meme coin at favorable prices
- **R_exit**: Above R_fee, exchanges meme coin for stable coin

## Data Storage Architecture

| Layer | Technology | Purpose |
|-------|------------|---------|
| Hot data | Mnesia (`ram_copies`) | In-memory time-series data for active trading decisions |
| Cold data | PostgreSQL via Ecto | Historical data storage, audit trails, analytics |

**Mnesia**: Uses `ram_copies` only. Data is nominally ephemeral. Fragmentation and sliding window sizes are parameterized and business logic specific.

**PostgreSQL**: Indexed by datetime. Accessed via abstract interface to allow future partitioning without code changes. Partitioning is a deferred optimization.

**Data flow**: Mnesia maintains a sliding window. Data rotating out is either offloaded to PostgreSQL (if historically useful) or dropped. Offload triggers are business logic specific (time-based, threshold-based, or hybrid).

## Unresolved Architectural Decisions

Per SPECIFICATION.md, the following remain TBD:
- Message queue for event streaming
- Monitoring and observability stack
- Secret management for private keys
- Gas estimation and fee management subsystem
