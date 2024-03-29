import Config

env = &System.get_env/1

secret_key_base =
  env.("SECRET_KEY_BASE") ||
    binary_part(Base.encode64(:crypto.strong_rand_bytes(64)), 0, 64)

config :flash, FlashWeb.Endpoint,
  http: [
    port: String.to_integer(env.("PORT") || "4000"),
    transport_options: [socket_opts: [:inet6]]
  ],
  url: [
    scheme: env.("URL_SCHEME") || "https",
    host: env.("URL_HOST") || "localhost",
    port: String.to_integer(env.("URL_PORT") || "443")
  ],
  secret_key_base: secret_key_base

config :flash,
  encryption_key: String.slice(env.("ENCRYPTION_KEY") || secret_key_base, 0..31),
  admin_username: env.("ADMIN_USERNAME") || "admin",
  admin_password_sha1: String.downcase(env.("ADMIN_PASSWORD_SHA1") || "")

if ttl = env.("DEFAULT_TTL") do
  config :flash, default_ttl: String.to_integer(ttl)
end

if redis_url = env.("REDIS_URL") do
  config :flash, secrets_store: Flash.KvStore.Redis
  config :flash, Flash.KvStore.Redis, url: redis_url
end

if s3_bucket = env.("S3_BUCKET") do
  config :flash, secrets_store: Flash.KvStore.S3

  config :flash, Flash.KvStore.S3,
    bucket: s3_bucket,
    prefix: env.("S3_PREFIX"),
    host: env.("S3_HOST")
end
