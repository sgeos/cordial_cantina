# Cordial Cantina

A concentrated liquidity market maker (CLMM) trading system for Solana.

## Prerequisites

- Elixir 1.15+
- Erlang/OTP 26+
- Rust (stable toolchain)
- PostgreSQL 16+

## Quick Start

### Database Setup

Ensure PostgreSQL is installed and running, then:

```sh
# Install dependencies
mix deps.get

# Create and migrate database
mix ecto.create
mix ecto.migrate

# Seed database with initial data (optional)
mix run priv/repo/seeds.exs
```

### Run the Application

```sh
# Run Phoenix app
mix phx.server

# Or run inside IEx (Interactive Elixir)
iex -S mix phx.server
```

The application will be available at [http://localhost:4000](http://localhost:4000).

## Environment Variables

Configuration is loaded from environment variables. Copy `.env.example` to `.env` and set values as needed.

```sh
cp .env.example .env
```

### Required Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `PORT` | Web server port | `4000` |

### Production Variables

These are required when running in production (`MIX_ENV=prod`).

| Variable | Description | Required |
|----------|-------------|----------|
| `SECRET_KEY_BASE` | Phoenix secret key (generate with `mix phx.gen.secret`) | Yes |
| `PHX_HOST` | Hostname for URL generation | Yes |
| `PHX_SERVER` | Set to `true` to start server | Yes (for releases) |

### API Keys

These will be required for market data integration.

| Variable | Description | Required |
|----------|-------------|----------|
| `BIRDEYE_API_KEY` | Birdeye API key for market data | V0.1-M4 |
| `RAYDIUM_API_KEY` | Raydium API key (if required) | V0.2+ |

### Database Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `DATABASE_URL` | PostgreSQL connection URL (production) | localhost config |

For local development, the database is configured in `config/dev.exs` with default credentials. For production, set `DATABASE_URL` to your PostgreSQL connection string.

## Development

### Running Tests

```sh
mix test
```

### Pre-commit Checks

```sh
mix precommit
```

This runs compilation with warnings-as-errors, formatting, and tests.

## Documentation

See the [docs](../docs/README.md) directory for project documentation.
