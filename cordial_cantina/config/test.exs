import Config

# Configure PostgreSQL for test
# Uses a separate database to allow parallel test runs
# Set POSTGRES_ENABLED=true to enable database tests
config :cordial_cantina,
  postgres_enabled: System.get_env("POSTGRES_ENABLED") == "true"

config :cordial_cantina, CordialCantina.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "cordial_cantina_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :cordial_cantina, CordialCantinaWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "Lf3WLLdyoSQQCcnrzsQdjZn8uazMKo4oKUwV0hezaK9dy7W/0692AE5+dhhA9KrO",
  server: false

# In test we don't send emails
config :cordial_cantina, CordialCantina.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true

# Sort query params output of verified routes for robust url comparisons
config :phoenix,
  sort_verified_routes_query_params: true
