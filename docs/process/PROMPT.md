# Prompt Staging Area

> **Navigation**: [Process](./README.md) | [Documentation Root](../README.md)

This file is a staging area for complex human-to-AI instructions. The human pilot drafts and refines prompts here before execution.

---

# Current Prompt

## Comments

We will get the blockers out of the way before migrating to GitHub Issues.
V0.0-M0 is approaching completion. We will review status after migrating to GitHub Issues.

See below for detailed comments on blockers.

## Objectives

### Decisions

#### OTP Supervision

- P1.2: In principle, the product should be written to operate on a single node. If multiple nodes are spun up, there should be 100% redundancy in each node. If a net split occurs, nodes do the best they can with the information they have.
- P1.3: Third party APIs can be used to pull historical data (Birdeye, DEX Screener). This is probably the most expedient. Ideally, the chain can be maintained and analyzed locally, but this is non-trivial and not an immediate priority solution.
- P1.4: Pending transactions can be persisted to PostgreSQL. Recovery checks both the database, and the API response to sync the application with ground truth and past decisions. Past decisions should be reverfied, because recovery implies downtime and markets change.

#### NIF Integration

- P2.1: Use Rustler bindings.
- P2.2: Define API boundary functions iteratively during development.
- P2.3: NIFs are written in Rust. Return errors to BEAM. Statically analyzed safe Rust with no panic conditions is trusted. When possible, code should be written so that it can be trusted. Code that might panic needs to be called with `catch_unwind`. Presumably, safe Rust can always be structured to return error codes instead of hitting a panic. Presumably, mathematical code can be written in safe Rust. Presumably, panices and errors are not acutally a problem. Having said that, `catch_unwind` is the fallback. Concrete details will be discovered iteratively during development.
- P2.4: In principle, NIF calls should be efficient enough to be synchronous. Long running calls will require dirty scheduling. Concrete details will be discovered iteratively during development, and through profiling.
- P2.5: If BEAM passes memory in, then BEAM is the owner of that memory. NIF could should treat it as read only and attempt to use zero copy solutions when reading it. Memory passed from Rust back to BEAM should follow Rustler conventions. Please let me know if "Rustler conventions" is not specific enough to provide clarification.
- P2.6: We already have a working solution.

Recommendations are acceptable.
- Select Rustler as the binding library (mature, well-documented, handles safety)
- Define explicit API contracts before implementation
- Use dirty CPU schedulers for computation exceeding 1ms
- Implement resource types for shared state

#### Solana RPC

- P3: Use public RPC for read-only V0.1 development. Defer provider selection until a decision needs to be made, or requirements become clearer.

Note that the present plan is to pull historical data from Birdeye, and use the Raydium API for managing ranges. Is Solana RPC needed? Is a Birdeye/Raydium solution sufficient?

#### Secrets

- P4: Use `config/runtime.exs` with environment variables and gitignored `.env` for development. Include `.env.example` with required variables assigned to safe dummy values. Defer more complex secrets management solutions until just before the V1.0 release. Optionally, implement a more complex strategy when an obvious solution becomes apparent.

#### Testing Framework and Coverage

- P5.1: There are no concrete test coverage target for V0.1. Everything mathematical or mission critical should be tested and working. Use recommended `mix test --cover` with 80% line coverage target for critical paths.
- P5.2: Use `excoveralls` because this is an Elixir project.
- P5.3: Use `cargo test` to test NIF, and underlying joltshark crate. Also have Elixir side integration tests. Integration tests should cover both happy paths and error paths, if possible.
- P5.4: Use the Elixir ecosystem Bypass for mock RPC calls.
- P5.5: We have an existing CI pipeline. Changes will be made iteratively when sensible. Recommended "GitHub Actions with Elixir, Rust, and PostgreSQL services" is acceptable.

#### Mnesia Schema

- P6: Iterative approach: Define minimal tables needed for first feature. Schema evolves with requirements.

#### Logging

- P7: Simple path: Use Logger with default format. JSON structured logging can be added when observability requirements crystallize.

Recommendations are acceptable:
- Use Logger with JSON formatter for structured output
- Emit telemetry events for all RPC calls, NIF invocations, and supervision events
- Add correlation IDs to log metadata

## Context

Decisions need to be made.

## Constraints

(no instructions)

## Success Criteria

Decisions are documented.
Knowledge graph is updated.
Remaining blockers are documented.
Remaining blockers are reported in the reverse prompt.
Noteworthy comments, questions, and concerns are reported in the next reverse prompt.

## Notes

(no notes)
