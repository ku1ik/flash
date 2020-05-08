# Flash

Keep the secrets out of emails and chat history!

## Deployment

### Insecure, for testing purposes only

You can run flash locally, in insecure "demo mode" like this:

    docker run -p 4000:4000 -e URL_SCHEME=http -e URL_PORT=4000 sickill/flash

Open [http://localhost:4000](http://localhost:4000) to access the app.

This is INSECURE (no HTTPS and no persistence), so do this only if you want
to play with it locally.

### Behind HTTPS-enabled proxy

Recommended, "production" setup would be to run it like this:

    docker run -p 4000:4000 -e URL_HOST=flash.example.com sickill/flash

The above assumes that there's a proxy/web server configured for
`flash.example.com` domain, which handles HTTPS and proxies all requests to
port 4000 of the container.

NOTE: This is minimal secure setup, however stored secrets are not persisted
and they will be lost upon container restart. See [Persistence](#persistence)
below for more robust setup.

### Automatic HTTPS with Caddy web server

You can get HTTPS up and running very easily with [Caddy web
server](https://caddyserver.com/). Caddy handles Let's Encrypt certificate
requesting/renewal automatically. Check out included [docker-compose
file](docker-compose.yml) for example setup.

## Configuration

Following env variables can be used to configure the service:

- `SECRET_KEY_BASE` - base secret token for encryption/signing, min. 64 chars long. Default: random key generated on boot
- `ENCRYPTION_KEY` - encryption key, 32 chars long. Default: first 32 chars of `SECRET_KEY_BASE` are used as encryption key
- `PORT` - HTTP listener port number. Default: 4000
- `REDIS_URL` - Redis server to use for secrets storage. Default: none
- `URL_SCHEME` - scheme for URL generation. Default: https
- `URL_HOST` - host for URL generation. Default: localhost
- `URL_PORT` - port for URL generation. Default: 443
- `DEFAULT_TTL` - default value for TTL input, in seconds. Default: 3600
- `ADMIN_USERNAME` - basic auth username for access to admin section. Default: admin
- `ADMIN_PASSWORD_SHA1` - SHA1 hex digest of the password for above user. Default: none

## Persistence

TODO: document

## Development

1. Install Erlang, Elixir and Node.js
2. `mix setup`
3. `mix test`
4. `iex -S mix phx.server`
5. Visit [`localhost:4000`](http://localhost:4000) from your browser

## Security

TODO: describe implemented security means and considerations
