import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :ccg, Ccg.Repo,
  username: System.get_env("PGUSER"),
  password: System.get_env("PGPASSWORD"),
  database: System.get_env("PGDATABASE"),
  hostname: System.get_env("PGHOST"),
  show_sensitive_data_on_connection_error: true,
  pool_size: 10,
  pool: Ecto.Adapters.SQL.Sandbox

config :ccg,
  user_token_signing_salt: "user auth"
# We don't run a server during test. If one is required,
# you can enable the server option below.
config :ccg, CcgWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "0/vwav2Dq7RscjZeT7AAUKqbafMW2PcDlB3rc1VhfZ9Kkou6ogaO7Aeif0JxaB+R",
  server: false

# In test we don't send emails.
config :ccg, Ccg.Mailer, adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
