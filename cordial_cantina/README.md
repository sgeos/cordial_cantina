# Cordial Cantina

A concentrated liquidity market maker (CLMM) trading system for Solana.

## Quick Start

```sh
# Install dependencies
mix deps.get

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

### Future Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `DATABASE_URL` | PostgreSQL connection URL | V0.2+ |

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
