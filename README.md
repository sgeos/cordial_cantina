# Cordial Cantina

[![CI](https://github.com/sgeos/cordial_cantina/actions/workflows/ci.yml/badge.svg)](https://github.com/sgeos/cordial_cantina/actions/workflows/ci.yml)

A concentrated liquidity market maker (CLMM) trading system for Solana blockchain.

**Status**: Specification draft under active development

## Documentation

See the [Documentation Knowledge Graph](./docs/README.md) for complete project documentation including:

- Product overview and strategy
- Technical architecture
- Requirements and roadmap
- Development process

## Project Structure

```
cordial_cantina/
├── cordial_cantina/     # Elixir/Phoenix application
├── joltshark/           # Rust numerical computation library
├── docs/                # Documentation knowledge graph
├── scripts/             # Development and build scripts
├── hooks/               # Shared git hooks
├── .github/             # CI workflows
└── CLAUDE.md            # AI agent instructions
```

### Subprojects

| Directory | Language | Description |
|-----------|----------|-------------|
| [cordial_cantina/](./cordial_cantina/README.md) | Elixir/Phoenix | Main application with OTP supervision tree |
| [joltshark/](./joltshark/README.md) | Rust | NIF library for numerical computation |

## Setup

### Prerequisites

- Elixir 1.15+ and Erlang/OTP 26+
- Rust (stable toolchain)
- PostgreSQL (for production)
- [GitHub CLI (`gh`)](https://cli.github.com/) - for issue management and CI interaction

### Installation

Clone the repository and run the setup script:

```sh
git clone <repository-url>
cd cordial_cantina
./scripts/setup.sh
```

The setup script will:
1. Install git hooks
2. Make scripts executable
3. Install Elixir dependencies

### Verify Installation

```sh
cd cordial_cantina
mix precommit
```

This runs compilation, formatting, and tests.

## Development

### Running the Application

```sh
cd cordial_cantina
mix phx.server
```

Or with interactive Elixir shell:

```sh
cd cordial_cantina
iex -S mix phx.server
```

### Scripts

| Script | Purpose |
|--------|---------|
| `scripts/setup.sh` | Initial environment setup |
| `scripts/check-doc-coverage.sh` | Verify documentation references |

### Git Hooks

Git hooks are installed automatically by `scripts/setup.sh`. To install manually:

```sh
ln -sf ../../hooks/pre-commit .git/hooks/pre-commit
```

## Contributing

See [Process Strategy](./docs/process/PROCESS_STRATEGY.md) for development workflow.

## License

TBD
