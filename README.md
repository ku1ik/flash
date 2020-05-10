# Flash

_Keep the secrets out of emails and chat history!_

Flash is a tiny web service for sharing the secrets in a secure way.

While sending passwords, API tokens or other sensitive piece of information
over email or chat is known to be a bad practice from security point of view,
it keeps happening over and over due to its convenience.

This project aims to solve the problem of "how to transfer the secret from
person A to person B in both hassle-free and secure way".

The project was inspired by [Magic
Wormhole](https://magic-wormhole.readthedocs.io), and while they both have
similar end-goal, Flash solves the problem with different means (and thus
different trade-offs). See [Goals/non-goals](#goals-and-non-goals) section
for more about that.

## How it works

Flash solves the stated problem by temporarily storing the secrets under
single-use, time limited, private links, which _can_ be shared over email or
chat.

1. Open Flash in your web browser
2. Paste your secret
3. Copy resulting secret link
4. Share the link with a person you'd like to know your secret

Every secret link contains unguessable, random token, which uniquely points
to a secret. When the link is opened by the recipient it warns them about
ephemeral nature of the link, and after confirmation it displays the secret
content. At that point the secret is removed from the storage and can't be
retrieved from Flash ever again. It's burned after reading :)

Each secret is kept in the storage for limited amount of time (TTL), which is
selected when creating the secret link (several options from 5 minutes to 7
days). If the link is not used within selected TTL then the secret is
automatically removed from the storage and the link will not work anymore.

See [Security](#security) section for more in-depth information about
security model of this project.

## Goals and non-goals

### Goals:

- Keep it simple, small and focused on the essential problem,
- Make secret sharing asynchronous - both parties don't have to be online at
  the same time,
- Keep it friendly for non-developers.

The last two goals make it quite different from how [Magic
Wormhole](https://magic-wormhole.readthedocs.io) operates (an inspiration for
this project). Wormhole runs in terminal, and while this is natural for
developers, it's quite a barrier for non-developer types (e.g. other roles in
your organization). Flash is accessible by anyone with a web browser.
Wormhole is synchronous (P2P) - requires both parties to be online when
sharing happens, which allows it to not store the secrets at all. Flash is
async, which is more convenient for the user, but requires storing the
secrets (temporarily, encrypted). It's a conscious trade-off which was chosen
here.

### Non-goals:

Following features are not planned as they stand against the chosen security model:

- Multi-use links
- Non-expiring links
- E2E (end-to-end) encryption

## Security

Following sections describe implemented security means, trade-offs and
considerations taken when developing this project.

... not E2E

### Links

Secret links contain 21 character long token which is used to lookup the
secret in the storage. The token is random and has no relation to the secret
content, and so it cannot be used to retrieve the secret after the secret has
been read or expired.

In case of the link falling into the wrong hands the person who created it
can burn it immediately (there's button for that on the page with sharing
instructions of a given link). If the unintended recipient already read the
secret it obviously can't be undone. However, if one reacts quickly this
gives them a chance to prevent the leakage. The "burn" button gives feedback
whether the secret was burned or it doesn't exist anymore (either already read
or expired).

Given the token embedded in the secret link is the only thing needed to
retrieve the actual secret it's essential to use HTTPS to avoid MITM attacks.
Flash defaults to HTTPS protocol, and if you really want HTTP (highly
discouraged) you need to configure it explicitly.

### Storage

The actual secret content is encrypted with AES-GCM (using 256-bit key) and
saved in the configured storage backend (see [Persistence](#persistence) for
storage options).

Given that stored data is short-lived there isn't a real need for configuring
backups of the storage backend database.

In case of the database contents getting exposed to some 3rd party (you use
managed database service with automatic backups by service provider, or
someone obtained a copy of database contents via other means) the secrets are
safe as long as this 3rd party doesn't also have access to the configured
encryption key (see [Configuration](#configuration)).

To put the above another way: in order to get access to the secrets one needs
to have access to the encryption key and the storage database.

### Other

- rate limiting to prevent brute-force attacks to find tokens
- CSRF protection: SameSite cookie + CSRF token
- HSTS + no iframe headers

Flash doesn't implement E2E encryption, and given the domain it operates in
(secure transfer of sensitive data) it's recommended to be self-hosted. You
should _not_ to use any public instances of Flash, for purposes other than
testing.

## Persistence

TODO: document

## Deployment

It is recommended to self-host Flash (run your own instance), and the easiest
way to run it is to use Docker.

You can build Docker image for the latest version like this:

    git clone https://github.com/sickill/flash.git
    cd flash
    docker build -t sickill/flash .

There's also [automated Docker Hub
build](https://docs.docker.com/docker-hub/builds/) configured for this
project, which generates
[sickill/flash](https://hub.docker.com/r/sickill/flash) image.

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

### Configuration

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

## Development

This project is built with [Elixir language](https://elixir-lang.org/) and
[Phoenix web framework](https://www.phoenixframework.org/).

To start developing:

1. Install Erlang, Elixir and Node.js for your platform
2. Run `mix setup` to fetch and build dependencies
3. Run `mix test` to run the test suite
4. Run `iex -S mix phx.server` to start `iex` shell with embedded web server
5. Visit [`localhost:4000`](http://localhost:4000) from your browser to access the site

## License

Copyright 2020 Marcin Kulik

This project is licensed under the [Apache License, Version 2.0](LICENSE).

The authors of this project are not responsible for any data loss, leakage of
sensitive information or any other damages due to use of this software. USE
AT YOUR OWN RISK.
