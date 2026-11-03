# --------------------------------------------------
# Build stage
# --------------------------------------------------
FROM elixir:1.20.4-otp-29@sha256:c904ce753c35768c76a3be6f16428a83f8237ca0c402355b49bac99d74da2beb AS build

RUN apt-get update -y && apt-get install -y \
    build-essential \
    git \
    curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
    
WORKDIR /app

ENV MIX_ENV=dev

# Install Hex and Rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Install dependencies
COPY mix.exs mix.lock ./
RUN mix deps.get

# Copy application source
COPY . .

# Install frontend build tools
RUN mix assets.setup

# Compile application to generate Phoenix colocated assets
RUN mix compile

# Generate production frontend assets
RUN mix assets.deploy
# --------------------------------------------------
# Production release stage
# --------------------------------------------------
FROM build AS release
ENV MIX_ENV=prod
ENV NPM_CONFIG_OMIT=dev

RUN apt-get update -y && apt-get install -y \
    nodejs \
    npm \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN mix deps.get --only prod
RUN mix compile
RUN mix release

# --------------------------------------------------
# Health-check utility stage
# --------------------------------------------------
FROM busybox:1.37.0@sha256:a7dbc319b1438115a207e11930dc4bb3e643dcb3ec0bdd694bb36cd8fad289ec AS healthcheck

# --------------------------------------------------
# Runtime stage
# --------------------------------------------------
FROM debian:trixie-slim@sha256:f6b08b09a05725f9431502d3b5714f5c4576e82c1a84fa1debe0c24a7e0c3ec4 AS runtime

RUN apt-get update -y && apt-get install -y \
    libstdc++6 \
    openssl \
    libncurses6 \
    locales \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create a dedicated non-root application user
RUN groupadd --system app && \
    useradd --system \
      --gid app \
      --home-dir /app \
      --no-create-home \
      app

WORKDIR /app

ENV LANG=C.UTF-8
ENV HOME=/app
ENV MIX_ENV=prod
ENV PHX_SERVER=true

COPY --from=release --chown=app:app \
    /app/_build/prod/rel/hologram_beamops_kanban ./

COPY --from=healthcheck --chmod=0755 /bin/busybox /usr/local/bin/busybox

USER app

EXPOSE 4000

HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
  CMD ["/usr/local/bin/busybox", "wget", "--spider", "-q", "-T", "5", "-Y", "off", "http://127.0.0.1:4000/hologram/ping"]

CMD ["/app/bin/hologram_beamops_kanban", "start"]
