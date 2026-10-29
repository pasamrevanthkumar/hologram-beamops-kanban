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

The initial application dependency constraints are declared in `mix.exs`.
The exact resolved versions are recorded in `mix.lock`.

| Component | Declared requirement | Resolved version | Evidence/status |
|---|---|---|---|
| Erlang/OTP | Local runtime | 29 | Installed locally |
| Elixir | Local toolchain | 1.20.4 | Installed locally |
| Node.js | Local toolchain | 24.21.0 | Installed locally |
| Phoenix | `~> 1.8.15` | 1.8.16 | Resolved in `mix.lock` |
| Hologram | `~> 0.12.3` | 0.12.3 | Resolved in `mix.lock` |
| Ecto SQL | `~> 3.13` | 3.14.0 | Resolved in `mix.lock` |
| Postgrex | `>= 0.0.0` | 0.22.4 | Resolved in `mix.lock` |
| Bandit | `~> 1.5` | 1.14.0 | Resolved in `mix.lock` |

The resolved versions establish the current local dependency baseline.
They do not, by themselves, establish production readiness or complete
architecture acceptance.

Official references:

- https://hologram.page/docs/installation
- https://hologram.page/docs/introduction
- https://hologram.hexdocs.pm/
- https://hex.pm/packages/hologram
- https://hex.pm/packages/phoenix
- https://hex.pm/packages/ecto_sql
- https://hex.pm/packages/postgrex

### Verification status

- [x] Generate the Phoenix host application.
- [x] Resolve dependencies and record exact versions in `mix.lock`.
- [x] Compile with the Hologram compiler enabled.
- [x] Verify the Hologram endpoint integration and homepage.
- [x] Exercise the Increment and Reset interactions in the browser.
- [x] Run automated tests (5 passed).
- [x] Record initial integration results below.

These checks establish the initial framework integration only. They do not
complete the application architecture or the full Kanban implementation.

## Initial Hologram integration verification — 2026-10-28

The Phoenix host application has been generated and the initial Hologram integration has been verified locally.

### Resolved dependency versions

| Component | Locked version |
|---|---|
| Hologram | 0.12.3 |
| Phoenix | 1.8.16 |
| Phoenix LiveView | 1.2.13 |
| Ecto | 3.14.2 |
| Ecto SQL | 3.14.0 |
| Postgrex | 0.22.4 |
| Bandit | 1.14.0 |

These versions come from the application mix.lock file.

### Verified behavior

- The Hologram homepage renders at / when started with mix holo.
- The Increment button updates the counter.
- The Reset button resets the counter.
- mix format --check-formatted passes.
- mix compile --warnings-as-errors passes.
- mix test passes: 5 tests.
- git diff --check passes.
- The local development database was created successfully.

The current evidence establishes the initial framework integration only. The full Kanban domain, database-backed workflows, production release, containers, CI, and deployment remain incomplete.

AWS provisioning remains out of scope until explicitly authorized.
