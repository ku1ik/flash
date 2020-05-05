# Flash

Keep the secrets out of emails and chat history!

## Running

    docker run -p 80:4000 sickill/flash

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

## Development

1. Install Erlang, Elixir and Node.js
2. `mix setup`
3. `mix test`
4. `iex -S mix phx.server`
5. Visit [`localhost:4000`](http://localhost:4000) from your browser

## Security

TODO: describe implemented security means and considerations
