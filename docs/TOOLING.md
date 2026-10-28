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

### Candidate Hologram version

Hologram 0.12.3 is the current candidate as of 2026-10-28.
Confirm its requirements and integration instructions against the
official documentation before pinning the dependency.

Official references:

- https://hologram.page/docs/installation
- https://hologram.page/docs/introduction
- https://hologram.hexdocs.pm/
- https://hex.pm/packages/hologram

### Outstanding verification

- [ ] Choose and pin the initial dependency versions.
- [ ] Verify dependency resolution in this repository.
- [ ] Compile the application with the Hologram compiler enabled.
- [ ] Verify endpoint and static-asset integration.
- [ ] Start the application locally and verify a Hologram page.
- [ ] Run automated tests.
- [ ] Record the actual results before accepting the architecture.
