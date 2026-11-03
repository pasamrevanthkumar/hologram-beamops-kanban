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

## Terraform GitHub project-management verification — 2026-10-31

Terraform is used to manage this project's GitHub repository planning
resources as code. The configuration is maintained in
`terraform/github-project-management/`.

### Tool versions

| Tool | Version |
|---|---|
| Terraform | 1.17.1 |
| GitHub Terraform provider | `integrations/github` 6.13.0 |

The provider version is constrained in `versions.tf` and recorded in
`.terraform.lock.hcl`.

### Managed resources

The Terraform state tracks 22 GitHub resources:

| Resource | Count |
|---|---:|
| GitHub repository | 1 |
| Repository milestones | 8 |
| Custom issue labels | 8 |
| Planning issues | 5 |
| **Total** | **22** |

### Verification results

- [x] Terraform configuration initialized with the GitHub provider.
- [x] Terraform state inspected; all 22 expected resources are tracked.
- [x] Refresh-only plan completed successfully.
- [x] Normal Terraform plan completed successfully.
- [x] Both plans reported no differences between the remote GitHub
      resources, saved state, and configuration.

No Terraform apply was necessary because the existing resources already
matched the declared configuration.

### State and security

Terraform state, state backups, saved plans, and provider working
directories remain local and are excluded from Git through `.gitignore`.
Terraform state can contain sensitive resource metadata and must not be
committed or published.

This exercise manages GitHub project-management resources only. It does
not provision AWS infrastructure. AWS provisioning remains out of scope
until explicitly authorized.

## GitHub Actions CI verification — 2026-11-01

### Workflow

Implemented `.github/workflows/ci.yml` to run automatically on:
- Pushes to `main`
- Pull requests targeting `main`

The workflow contains two jobs:

1. **Compile, format and test**
   - Runs on `ubuntu-latest`.
   - Uses Erlang/OTP 29.0 and Elixir 1.20.4.
   - Starts PostgreSQL 18 as a GitHub Actions service container.
   - Caches Mix dependencies and build artifacts.
   - Installs Hex and Rebar.
   - Fetches dependencies.
   - Checks formatting with `mix format --check-formatted`.
   - Compiles with `mix compile --warnings-as-errors`.
   - Runs the test suite with `mix test`.

2. **Build production Docker image**
   - Runs only after the test job succeeds.
   - Uses Docker Buildx and `docker/build-push-action`.
   - Builds the production image without publishing it.
   - Uses GitHub Actions cache (`type=gha`) for Docker build layers.

### Local verification

All checks passed before pushing the workflow:
- `actionlint .github/workflows/ci.yml`
- `direnv exec . mix format --check-formatted`
- `direnv exec . mix compile --warnings-as-errors`
- `direnv exec . mix test` — 89 tests passed.
- `docker buildx build --load --tag hologram-beamops-kanban:ci .` — successful production image build.

### Remote GitHub Actions verification

- Workflow commit: `804c7e9` — Add GitHub Actions CI workflow.
- GitHub Actions run ID: `41311250570`.
- Test job: passed in 1m 56s.
- Production Docker build job: passed in 7m 10s.
- Overall workflow result: success.

### Warnings observed

The successful run reported non-blocking warnings:
- GitHub Actions actions using Node.js 20 are being forced to run on Node.js 24.
- The `xref: [exclude: ...]` option in `mix.exs` is deprecated; the compiler recommends `elixirc_options: [no_warn_undefined: ...]`.
- GitHub's `ubuntu-latest` runner label is scheduled to migrate to Ubuntu 26.

These warnings did not prevent either job from succeeding. They remain maintenance items for a future update.

### Security and publishing

- Workflow permissions are restricted to `contents: read`.
- PostgreSQL credentials used by CI are disposable test-only values.
- The production Docker image is built but not pushed to a registry.
- No AWS resources were provisioned by this workflow.

## Production Docker runtime hardening — 2026-11-01

### Non-root execution

The production runtime image was hardened to use a dedicated system
user and group named `app`.

The release files are copied into the runtime image with ownership
assigned to `app:app`, and the Dockerfile switches to `USER app`
before starting the application.

Local verification:
- Runtime image: `hologram-beamops-kanban:ci`
- Container identity: UID 999, GID 999 (`app`)
- Working directory: `/app`
- Elixir, Mix, Erlang CLI tools, and development tooling are not
  exposed as runtime executables.
- Release startup succeeded.
- Application returned HTTP 200 through the temporary runtime test
  container connected to the existing Compose network.

### Runtime configuration and example environment

The committed `.env.docker.example` documents the environment
required for local Compose deployment.

The actual `.env.docker` file remains ignored by Git.

Secrets must be generated or supplied locally. They must not be
committed or embedded in the Docker image.

### Remote CI verification

- Commit: `083ad94` — Harden production Docker runtime and document deployment.
- GitHub Actions run ID: `41320737209`.
- Compile, format and test job: passed.
- Production Docker image build job: passed.
- Overall workflow result: success.

The run reported non-blocking Node.js 20 deprecation and Ubuntu
runner migration warnings. These remain maintenance items.

### Outcome

The production image is built from a multi-stage Dockerfile,
runs as a non-root user, and starts independently of development
tooling. The image build and application validation are both
covered by GitHub Actions.

The image is built in CI but is not published to a registry.
No AWS infrastructure was provisioned.

## Local operations verification — 2026-11-03

### Docker Compose

The local application environment uses three services:

| Service | Responsibility |
|---|---|
| `db` | PostgreSQL 18 |
| `migrate` | One-shot release migration task |
| `app` | Hologram/Phoenix OTP release |

Operational behavior verified:

- The application waits for PostgreSQL to become healthy.
- The migration service runs to completion before the application starts.
- PostgreSQL uses the named volume
  `hologram_beamops_kanban_postgres_data`.
- Restarting PostgreSQL temporarily interrupts existing database
  connections. The application subsequently reconnects successfully.
- Restarting the application does not remove PostgreSQL data.
- The application returned HTTP 200 after both restart experiments.

A dedicated `m3_persistence_check` table was used to verify that a
record survived a PostgreSQL container restart. This was a test
artifact, not part of the application's domain schema.

### Docker Swarm evaluation

Docker Engine 29.9.2 and Docker Compose v5.6.1 were observed locally.

A single-node Swarm was initialized on `hpomen` using the machine's
local IPv4 address. A disposable `nginx:alpine` service was used to
evaluate Swarm without migrating the Kanban application.

Experiments:

- Created a replicated service with two tasks.
- Published container port 80 on host port 8080.
- Verified HTTP 200.
- Scaled the service from two to four replicas.
- Force-removed one task container and observed Swarm replace it.
- Scaled the service back to two replicas.
- Removed the disposable service and verified that no Swarm
  services remained.

The experiments demonstrated desired-state reconciliation,
replica scaling, and task replacement.

### Orchestration decision

Docker Compose remains the local orchestration tool for this project.
It provides the required multi-container workflow for PostgreSQL,
migrations, and the application release.

Swarm was evaluated but not adopted for the application. The experiment
used one physical node, so it did not establish machine-level
high availability. A multi-node deployment would require additional
planning for networking, persistent storage, failure domains, and
operational security.

Compose-managed services and Swarm services are managed independently.
The disposable Swarm service was removed after the experiment.

### Operational boundaries

The M3 experiments did not include:

- PostgreSQL backup and restore validation.
- Recovery after permanent database-volume loss.
- Extended database outage testing.
- Multi-node Swarm operation.
- Production deployment or AWS infrastructure.

These remain possible future exercises rather than verified
capabilities.
