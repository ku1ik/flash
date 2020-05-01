import Config

env = &System.get_env/1
env! = &System.fetch_env!/1

secret_key_base = env!.("SECRET_KEY_BASE")

config :flash, FlashWeb.Endpoint,
  http: [
    port: String.to_integer(env.("PORT") || "4000"),
    transport_options: [socket_opts: [:inet6]]
  ],
  url: [
    host: env.("URL_HOST") || "localhost",
    port: String.to_integer(env.("URL_PORT") || "443")
  ],
  secret_key_base: secret_key_base

config :flash,
  encryption_key: String.slice(env.("ENCRYPTION_KEY") || secret_key_base, 0..31),
  admin_username: env.("ADMIN_USERNAME") || "admin",
  admin_password: env.("ADMIN_PASSWORD") || Base.encode64(:crypto.strong_rand_bytes(32))

if redis_url = env.("REDIS_URL") do
  config :flash, redis_url: redis_url
end
