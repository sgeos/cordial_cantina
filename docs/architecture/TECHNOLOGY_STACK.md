# Technology Stack

> **Navigation**: [Architecture](./README.md) | [Documentation Root](../README.md)

This document specifies the technology stack for Cordial Cantina.

---

## Application Layer

### Elixir

**Version**: 1.15+

**Role**: Primary application language

**Rationale**:
- Functional programming paradigm suits financial calculations
- Pattern matching enables clean data transformation
- Immutability reduces concurrency bugs

### Phoenix Framework

**Version**: 1.8+

**Role**: Web framework for monitoring UI and API

**Components used**:
- Phoenix LiveView for real-time dashboards
- Phoenix PubSub for internal messaging
- Phoenix Telemetry for observability

### OTP (Open Telecom Platform)

**Role**: Fault tolerance and process management

**Components used**:
- Supervision trees for automatic recovery
- GenServer for stateful processes
- Application behavior for lifecycle management

---

## Computation Layer

### Rust

**Role**: Performance-critical numerical computation

**Integration**: Native Implemented Functions (NIFs)

**Crate**: `joltshark`

**Rationale**:
- Predictable performance without garbage collection pauses
- Strong type system for numerical correctness
- `no_std` compatibility for embedded deployment options

### NIF Binding

**Library**: TBD (Rustler recommended)

**Considerations**:
- Panic safety (NIFs crashing brings down BEAM VM)
- Dirty schedulers for long-running computation
- Memory ownership across language boundary

---

## Data Layer

### Mnesia

**Role**: In-memory hot data storage

**Configuration**: `ram_copies` only

**Rationale**:
- Native OTP integration
- Sub-millisecond access for trading decisions
- Built-in distribution for clustering

### PostgreSQL

**Role**: Persistent cold data storage

**Integration**: Ecto (Elixir database wrapper)

**Rationale**:
- Mature, reliable relational database
- Strong tooling for migrations and queries
- Ecosystem compatibility

---

## HTTP and Networking

### Bandit

**Role**: HTTP server

**Rationale**: Pure Elixir implementation, Phoenix 1.8 default

### Finch

**Role**: HTTP client connection pooling

**Integration**: Backend for Req library

### Req

**Role**: HTTP client for external API calls

**Rationale**: Modern, well-designed Elixir HTTP client

---

## Frontend

### Tailwind CSS

**Version**: 4.x

**Role**: Utility-first CSS framework

### esbuild

**Role**: JavaScript/TypeScript bundling

---

## Development Tools

| Tool | Purpose |
|------|---------|
| Mix | Build tool and task runner |
| ExUnit | Testing framework |
| Credo | Static analysis (optional) |
| Dialyzer | Type checking (optional) |
| Cargo | Rust build tool |

---

## Version Constraints

| Component | Minimum Version | Notes |
|-----------|-----------------|-------|
| Elixir | 1.15 | Required for Phoenix 1.8 |
| Erlang/OTP | 26 | Required for Elixir 1.15 |
| Rust | 2024 edition | Required for joltshark |
| PostgreSQL | 14 | Recommended for features |

---

## Related Documents

- [Supervision Tree](./SUPERVISION_TREE.md) - OTP process design
- [Data Storage](./DATA_STORAGE.md) - Database architecture
- [Performance Requirements](../requirements/PERFORMANCE.md) - Performance targets
