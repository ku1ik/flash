# Flash

Keep the secrets out of emails and chat history!

## Running

You can run the service in, let's call it, "demo mode" like this:

    docker run -p 4000:4000 -e URL_SCHEME=http -e URL_PORT=4000 sickill/flash

This is INSECURE (no HTTPS and no persistence), so do this only if you want to play with it locally.

Recommended, "production" setup would be to run it like this:

    docker run -p 4000:4000 -e URL_HOST=flash.example.com -e SECRET_KEY_BASE=<64-char-random-token> -e REDIS_URL=redis://<redis-address> sickill/flash

The above assumes the service is running behind a load balancer/proxy/front webserver which handles HTTPS.

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
- `ADMIN_PASSWORD` - password for above. Default: none

## Development

1. Install Erlang, Elixir and Node.js
2. `mix setup`
3. `mix test`
4. `iex -S mix phx.server`
5. Visit [`localhost:4000`](http://localhost:4000) from your browser

## Security

TODO: describe implemented security means and considerations
