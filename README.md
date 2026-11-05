# Hologram BeamOps Kanban

A Hologram-based Kanban application taken through a practical software delivery lifecycle, guided by "Engineering Elixir Applications".

The project applies a practical software delivery lifecycle to a Hologram-based application, covering testing, CI/CD, OTP releases, Docker, infrastructure as code, and a temporary AWS deployment. Distributed operation and observability are documented as deferred lifecycle topics.

## Project Principles

- Use Hologram for the web application UI.
- Learn the complete application lifecycle rather than isolated chapter exercises.
- Keep development local until cloud deployment is planned and cost-checked.
- Prefer reproducible environments and infrastructure as code.
- Automate testing, builds, deployments, and operational checks where appropriate.
- Document architectural decisions and Hologram-specific adaptations.
- Avoid introducing unnecessary infrastructure before the application needs it.

## Application Features

- Create and manage Kanban boards.
- Automatically create default columns when a board is created.
- Create tasks with titles and descriptions.
- Organize tasks across columns.
- Move and reorder tasks.
- Delete tasks while maintaining ordering consistency.
- View dashboard summaries.

## Technology Stack

| Area | Technology |
|---|---|
| Language | Elixir |
| Runtime | Erlang/OTP |
| Web application | Hologram |
| Web server | Bandit |
| Database | PostgreSQL |
| Database access | Ecto / Postgrex |
| Frontend assets | Tailwind CSS / esbuild |
| Testing | ExUnit |
| CI | GitHub Actions |
| Application packaging | OTP Releases |
| Containerization | Docker |
| Local orchestration | Docker Compose |
| Infrastructure as Code | Terraform |

## Prerequisites

For local development:

- Elixir 1.20.4
- Erlang/OTP 29
- PostgreSQL 18
- Node.js and npm
- Git
- direnv

For containerized deployment:

- Docker Engine
- Docker Buildx
- Docker Compose plugin

## Local Development

Enter the project directory:

```bash
cd ~/dev-environment/hologram_beamops_kanban
```

Allow direnv to load the project's environment:

```bash
direnv allow
```

Install dependencies and prepare the application:

```bash
direnv exec . mix setup
```

The `setup` alias performs:

- Dependency installation.
- Database setup and migrations.
- Frontend tool installation.
- Asset compilation.

Start the Hologram development server:

```bash
direnv exec . mix holo
```

## Testing and Code Quality

Run the test suite:

```bash
direnv exec . mix test
```

Check formatting:

```bash
direnv exec . mix format --check-formatted
```

Compile with warnings treated as errors:

```bash
direnv exec . mix compile --warnings-as-errors
```

Run the precommit checks:

```bash
direnv exec . mix precommit
```

The test alias creates and migrates the test database before executing tests.

## Production Docker Image

The Dockerfile uses a multi-stage build:

1. **Build stage:** Installs development and frontend build tools, dependencies, and assets.
2. **Release stage:** Compiles production dependencies and creates an OTP release.
3. **Runtime stage:** Uses a minimal Debian image containing the runtime libraries required by the release.

The runtime image does not require Elixir, Mix, Hex, or development tooling.

The production container runs under a dedicated non-root `app` user.

### Build the image

Build the production image:

```bash
docker buildx build --load \
  --tag hologram-beamops-kanban:ci .
```

Inspect its configuration:

```bash
docker image inspect hologram-beamops-kanban:ci \
  --format 'User={{.Config.User}} WorkingDir={{.Config.WorkingDir}}'
```

Verify the runtime identity:

```bash
docker run --rm \
  --entrypoint /bin/sh \
  hologram-beamops-kanban:ci \
  -c 'id'
```

### Production runtime configuration

The production release reads configuration from environment variables.

Important variables include:

| Variable | Purpose |
|---|---|
| `DATABASE_URL` | PostgreSQL connection URL |
| `SECRET_KEY_BASE` | Phoenix secret key base |
| `PHX_SERVER` | Enables the HTTP server |
| `PHX_HOST` | Production hostname |
| `PORT` | HTTP listening port; defaults to 4000 |
| `POOL_SIZE` | Database connection pool size |
| `DNS_CLUSTER_QUERY` | Optional DNS-based cluster discovery |
| `ECTO_IPV6` | Optional IPv6 database connection configuration |

Required production variables must be supplied at runtime. Do not bake production secrets into the Docker image.

## Local Multi-Service Deployment

Docker Compose defines three services:

| Service | Responsibility |
|---|---|
| `db` | PostgreSQL database |
| `migrate` | Runs database migrations |
| `app` | Runs the application release |

The startup sequence is controlled by health and completion conditions:

1. PostgreSQL starts.
2. PostgreSQL passes its health check.
3. The migration service executes the release migration function.
4. The application starts after successful migration completion.

PostgreSQL data is stored in the `postgres_data` named volume.

### Configure the environment

Create a local Docker environment file from the committed example:

```bash
cp .env.docker.example .env.docker
```
### Build the Compose application image

The current Compose configuration references the `hologram_beamops_kanban:local` image:

```bash
docker buildx build --load \
  --tag hologram_beamops_kanban:local .
```

### Start the services

```bash
docker compose --env-file .env.docker up -d
```

Check service status:

```bash
docker compose --env-file .env.docker ps
```

Inspect application logs:

```bash
docker compose --env-file .env.docker logs -f app
```

Open the application:

http://localhost:4000

### Stop the services

Stop the containers while preserving database data:

```bash
docker compose --env-file .env.docker down
```

To remove the database volume as well:

```bash
docker compose --env-file .env.docker down -v
```

**Warning:** Removing the volume permanently deletes the local PostgreSQL data.

## Local Operations and Recovery

The local multi-service deployment uses Docker Compose to manage the
application, PostgreSQL, and one-shot database migrations.

Useful operational commands:

```bash
# Start the application stack
docker compose --env-file .env.docker up -d

# Inspect service status, including the completed migration container
docker compose --env-file .env.docker ps -a

# Follow application logs
docker compose --env-file .env.docker logs -f app

# Restart the application
docker compose --env-file .env.docker restart app

# Stop containers while preserving database data
docker compose --env-file .env.docker down
```

## Continuous Integration

GitHub Actions runs automated validation on pushes to `main` and pull requests targeting `main`.

The workflow performs:

- Dependency installation.
- Formatting verification.
- Compilation with warnings treated as errors.
- Automated tests using PostgreSQL.
- Production Docker image build.

The Docker image is built in CI but is not automatically published to a container registry.

## Infrastructure and Deployment

Terraform is used to manage selected GitHub project-management resources.

AWS infrastructure provisioning and production deployment are planned for later milestones. No AWS resources are created by the current local deployment workflow.

## Lifecycle Roadmap

| Milestone | Objective |
|---|---|
| M0 | Project planning and toolchain |
| M1 | Working Kanban application |
| M2 | CI, OTP releases, and Docker packaging |
| M3 | Local operations and multi-service deployment |
| M4 | AWS infrastructure and deployment |
| M5 | Delivery automation and distributed operation |
| M6 | Observability, metrics, dashboards, and alerts |
| M7 | Final validation and cleanup |

## Documentation

Additional project documentation is maintained in the `docs/` directory.

- `docs/MILESTONES.md` — milestone objectives and exit criteria.
- `docs/TOOLING.md` — tools, references, and implementation notes.

## Project Status

**Status: Initial application lifecycle completed — 2026-11-05**

The Hologram-based Kanban application has been implemented, tested,
packaged, deployed to AWS, verified, and documented.

Completed work includes:

- Core Kanban functionality with PostgreSQL persistence.
- Automated tests and GitHub Actions continuous integration.
- OTP release and production Docker image.
- Local multi-service deployment using Docker Compose.
- Database readiness, migrations, health checks, and persistence verification.
- A single-node Docker Swarm orchestration exercise.
- Terraform-managed AWS infrastructure.
- Temporary AWS deployment using EC2, Docker Compose, PostgreSQL, and GHCR.
- Application health and browser-based functional verification.
- Infrastructure teardown and AWS resource deletion verification.
- Deployment and lifecycle documentation.

The AWS deployment was intentionally temporary. The application was
successfully verified, and the project-created AWS infrastructure was
subsequently destroyed to avoid unnecessary ongoing costs.

### Deferred work

The following book lifecycle topics were not implemented in this iteration:

- Automated continuous deployment to AWS.
- Multi-node distributed deployment and Erlang cluster operation.
- Production scaling, load balancing, and automated rollback.
- Centralized logging and metrics.
- PromEx metrics, Grafana dashboards, and alerting.

These topics remain possible future extensions. They are not claimed as
completed capabilities.

### Deployment status

The GitHub repository and published container images are retained as
project artifacts. The AWS application environment is no longer running.
