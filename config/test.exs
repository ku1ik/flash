use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :flash, FlashWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

config :flash, redis_url: System.get_env("TEST_REDIS_URL", "redis://localhost:6379/1")
