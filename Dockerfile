## Builder image

ARG ALPINE_VERSION=3.11.3
ARG ERLANG_OTP_VERSION=22.2.8
ARG ELIXIR_VERSION=1.10.2

# https://github.com/hexpm/bob#docker-images
FROM hexpm/elixir:${ELIXIR_VERSION}-erlang-${ERLANG_OTP_VERSION}-alpine-${ALPINE_VERSION} as builder

ARG MIX_ENV=prod

WORKDIR /opt/app

RUN apk upgrade && \
  apk add \
    nodejs \
    npm \
    build-base && \
  mix local.rebar --force && \
  mix local.hex --force

COPY assets/package.json assets/
COPY assets/package-lock.json assets/
RUN cd assets && npm install

COPY mix.* ./
RUN mix do deps.get --only prod, deps.compile

COPY assets/ assets/
RUN cd assets && npm run deploy

COPY config/config.exs config/
COPY config/prod.exs config/

RUN mix phx.digest

COPY config ./config
COPY lib ./lib
COPY priv ./priv

RUN mix release

# Final image

FROM alpine:${ALPINE_VERSION}

RUN apk add --no-cache \
  ca-certificates \
  libcrypto1.1 \
  ncurses

WORKDIR /opt/app

COPY --from=builder /opt/app/_build/prod/rel/flash .

CMD exec /opt/app/bin/flash start
