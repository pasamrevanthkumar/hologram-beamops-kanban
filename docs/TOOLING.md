# Tool Inventory

Tools will be selected and version-pinned when their stage begins.
Read the official documentation before implementation.

| Area | Tool | Purpose |
|---|---|---|
| Language/runtime | Elixir and Erlang/OTP | Application and BEAM runtime |
| Web framework | Hologram | Web application UI and framework |
| Database | PostgreSQL and Ecto | Persistent application data |
| Version control | Git | Source history and collaboration |
| Repository hosting | GitHub | Issues, milestones, source, and CI |
| Testing | ExUnit | Automated tests |
| Packaging | Mix releases | Self-contained application releases |
| Containers | Docker | Reproducible application images |
| Local orchestration | Docker Compose | Multi-service development |
| Infrastructure as code | Terraform | Provision and manage infrastructure |
| Machine images | Packer | Automated machine-image creation, if applicable |
| Cloud | AWS | Production infrastructure |
| Continuous integration | GitHub Actions | Automated validation |
| Secret management | SOPS and Docker secrets | Protect and supply deployment secrets |
| Distributed runtime | Erlang distribution and libcluster | Cluster formation and discovery, as appropriate |
| Logging | Grafana Loki stack or suitable alternatives | Centralized logs |
| Metrics | PromEx and Prometheus-compatible tooling | Application and runtime metrics |
| Dashboards and alerts | Grafana | Operational visibility and alerting |

## Selection policy

The table is a preliminary inventory based on the book's lifecycle.
Verify compatibility with Hologram and the chosen deployment architecture
before adopting any Phoenix-specific tooling or configuration.

## Initial compatibility baseline — 2026-10-28

### Locally observed versions

| Tool | Version | Evidence |
|---|---|---|
| Erlang/OTP | 29 | `elixir -v` |
| Elixir | 1.20.4, compiled with OTP 27 | `elixir -v` |
| Node.js | 24.21.0 | `node --version` |
| npm | 11.19.0 | `npm --version` |

These versions were observed on the local development machine.
They are a starting baseline, not yet a project-specific tested toolchain.

### Hologram and Phoenix reference

The separate `~/dev-environment/hologram_host` project currently
locks Hologram 0.12.1, Phoenix 1.8.15, Ecto 3.14.2, and Postgrex
0.22.4.

Its endpoint includes `Hologram.Router` before the Phoenix router,
and its static paths include `"hologram"`. Its formatter imports
Hologram formatting rules, and `.gitignore` excludes
`/priv/static/hologram/`.

This project is a reference only. Its dependencies and configuration
have not been copied into this repository.

### Candidate dependency baseline

The following versions are candidates for the initial application,
not yet a verified dependency lockfile.

| Component | Candidate | Evidence/status |
|---|---|---|
| Erlang/OTP | 29 | Installed locally; meets documented minimum |
| Elixir | 1.20.4 | Installed locally; meets documented minimum |
| Node.js | 24.21.0 | Installed locally; meets documented minimum |
| Phoenix | 1.8.15 | Used by the existing Hologram reference project |
| Hologram | 0.12.3 | Current candidate release |
| Ecto / Ecto SQL | 3.14.x | Candidate persistence dependencies |
| Postgrex | 0.22.4 | Used by the reference project |

The initial Hologram dependency requirement will be evaluated as
`{:hologram, "~> 0.12.3"}`. Mix will resolve the exact version and
record it in `mix.lock` when the application is created and dependencies
are fetched. The Phoenix and database dependency requirements must also
be selected in the generated application's `mix.exs`.

Official references:

- https://hologram.page/docs/installation
- https://hologram.page/docs/introduction
- https://hologram.hexdocs.pm/
- https://hex.pm/packages/hologram
- https://hex.pm/packages/phoenix
- https://hex.pm/packages/ecto_sql
- https://hex.pm/packages/postgrex

### Outstanding verification

- [ ] Generate the Phoenix host application.
- [ ] Resolve the candidate dependency requirements.
- [ ] Compile with the Hologram compiler enabled.
- [ ] Verify endpoint and static-asset integration.
- [ ] Start the application locally and verify a Hologram page.
- [ ] Run automated tests.
- [ ] Record actual results before accepting the architecture.
