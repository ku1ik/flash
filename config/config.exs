# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :flash, FlashWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "lFWk6IgHHqLGq/13wHOjfMRp8hrtzO08B++bvAxDAIAhCBSoY2DtjVnXMElCs2Ym",
  render_errors: [view: FlashWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Flash.PubSub,
  live_view: [signing_salt: "Tyqw5Lq3"]

config :flash,
  encryption_key: "lFWk6IgHHqLGq/13wHOjfMRp8hrtzO08",
  secrets_store: Flash.Secrets.Store.Cachex,
  admin_username: "admin",
  admin_password: "admin",
  ttl_options: [
    {"5 minutes", "5m"},
    {"30 minutes", "30m"},
    {"1 hour", "1h"},
    {"4 hours", "4h"},
    {"12 hours", "12h"},
    {"1 day", "1d"},
    {"3 days", "3d"},
    {"7 days", "7d"}
  ],
  default_ttl: 3600

config :phoenix,
  json_library: Jason,
  filter_parameters: ["password", "text"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :logger, compile_time_purge_matching: [[application: :remote_ip]]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
