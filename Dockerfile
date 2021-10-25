FROM registry.xirion.net/library/zookeeper-builder AS builder
ENV MIX_ENV=prod

WORKDIR /build/zookeeper
RUN mix local.rebar --force && mix local.hex --force
COPY mix.exs mix.lock ./
COPY config config
RUN mix do deps.get, deps.compile

# Build
COPY . .
RUN mkdir -p /opt/release && \
    mix release && \
    mv _build/${MIX_ENV}/rel/zookeeper /opt/release


# Runner image
FROM alpine:3 AS runner
RUN apk add --no-cache openssl ncurses-libs
WORKDIR /app/
ENV HOME=/app
RUN chown nobody:nobody /app
USER nobody:nobody
COPY --chown=nobody:nobody --from=builder /opt/release/zookeeper .
CMD ["/app/bin/zookeeper", "start"]
