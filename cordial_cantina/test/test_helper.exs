ExUnit.start()

# Only set up Ecto sandbox if PostgreSQL is enabled
if Application.get_env(:cordial_cantina, :postgres_enabled, false) do
  Ecto.Adapters.SQL.Sandbox.mode(CordialCantina.Repo, :manual)
end
