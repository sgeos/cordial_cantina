defmodule CordialCantina.Repo do
  @moduledoc """
  PostgreSQL repository for cold data storage.

  Per R1 decision: PostgreSQL provides durable cold storage for:
  - Historical data rotating out of Mnesia
  - Audit trails
  - Analytics and backtesting queries

  ## Configuration

  Database configuration is loaded from environment variables via `config/runtime.exs`:
  - `DATABASE_URL` - PostgreSQL connection string
  - `POOL_SIZE` - Connection pool size (default: 10)

  ## Usage

  Use Ecto queries for historical data access:

      CordialCantina.Repo.all(PriceFeed)
      CordialCantina.Repo.get(PriceFeed, id)

  For time-series queries, use the datetime index:

      from p in PriceFeed,
        where: p.timestamp > ^start_time and p.timestamp < ^end_time
  """

  use Ecto.Repo,
    otp_app: :cordial_cantina,
    adapter: Ecto.Adapters.Postgres
end
