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
  secrets_store: Flash.KvStore.Cachex,
  admin_username: "admin",
  admin_password_sha1: "d033e22ae348aeb5660fc2140aec35850c4da997", # "admin"
  ttl_options: [
    {"5 minutes", 300},
    {"30 minutes", 1800},
    {"1 hour", 3600},
    {"4 hours", 14400},
    {"12 hours", 43200},
    {"1 day", 86400},
    {"3 days", 259200},
    {"7 days", 604800}
  ],
  default_ttl: 3600

config :phoenix,
  json_library: Jason,
  filter_parameters: ["password", "secret"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :logger, compile_time_purge_matching: [[application: :remote_ip]]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :ex_aws,
  json_codec: Jason,
  region: {:system, "AWS_REGION"}

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
