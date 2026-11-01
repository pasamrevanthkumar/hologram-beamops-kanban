# --------------------------------------------------
# Build stage
# --------------------------------------------------
FROM elixir:1.20.4-otp-29 AS build

RUN apt-get update -y && apt-get install -y \
    build-essential \
    git \
    curl \
    nodejs \
    npm \
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

RUN mix deps.get --only prod
RUN mix compile
RUN mix release

# --------------------------------------------------
# Runtime stage
# --------------------------------------------------
FROM debian:trixie-slim AS runtime

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

USER app

EXPOSE 4000

CMD ["/app/bin/hologram_beamops_kanban", "start"]
