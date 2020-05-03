# Flash

To start your Phoenix server:

  * Setup the project with `mix setup`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Configuration

Required env variables:

- `SECRET_KEY_BASE` - base secret token for encryption/signing, min. 64 chars long

Optional env variables:

- `ENCRYPTION_KEY` - encryption key, 32 chars long. Default: first 32 chars of `SECRET_KEY_BASE` are used as encryption key
- `PORT` - HTTP listener port number. Default: 4000
- `REDIS_URL` - Redis server to use for secrets storage. Default: none
- `URL_SCHEME` - scheme for URL generation. Default: https
- `URL_HOST` - host for URL generation. Default: localhost
- `URL_PORT` - port for URL generation. Default: 443
- `DEFAULT_TTL` - default value for TTL input, in seconds. Default: 3600
- `ADMIN_USERNAME` - basic auth username for access to admin section. Default: admin
- `ADMIN_PASSWORD` - password for above. Default: none

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
