# Project Milestones and GitHub Mapping

## Purpose

This file is the local record of the project milestones. GitHub Issues
and Milestones will track actionable work. Record GitHub identifiers
and links here after the corresponding resources have been created.

The milestones describe stages in the lifecycle of one application,
not separate application projects.

## Milestone M0 — Planning and toolchain

Objective:
Approve requirements, define the initial architecture, establish
project management, and verify the development toolchain.

Includes:
- Requirements and acceptance criteria
- Architecture proposal and decision records
- Hologram/Phoenix/Elixir compatibility checks
- Official documentation inventory
- GitHub milestone and issue setup

Exit criteria:
- Planning documents reviewed and committed
- Key open decisions identified
- Toolchain versions and compatibility evidence documented
- Initial GitHub issues mapped to this plan

GitHub milestone: Pending
GitHub issues: Pending

## Milestone M1 — Working Kanban application

Objective:
Implement and test the core application.

Includes:
- Board and column display
- Task creation and editing
- Task movement and ordering
- Task completion
- Persistence and migrations
- Domain and persistence tests

Exit criteria:
- Agreed functional requirements pass
- Automated tests pass locally
- Setup and data-model documentation is current

GitHub milestone: Pending
GitHub issues: Pending

## Milestone M2 — CI and packaging

Status: **Complete — 2026-11-01**

Objective:
Make application validation and packaging reproducible.

Includes:
- Formatting, compilation, and tests in CI
- OTP release
- Docker image and runtime configuration
- Image build and startup verification
- Non-root production container execution
- Documented local and containerized workflows

Exit criteria:
- [x] CI validates proposed changes
- [x] Release and image can be reproduced using documented steps
- [x] Runtime configuration does not depend on development-only tooling
- [x] Production container runs under a dedicated non-root user
- [x] Production image starts successfully and serves HTTP requests

Verification evidence:
- Local formatting and compilation checks passed.
- Local test suite: 89 tests passed.
- Production Docker image built successfully.
- Runtime container verified as UID 999 (`app`).
- Runtime image started successfully and returned HTTP 200.
- GitHub Actions run `41320737209` passed both jobs:
  - Compile, format and test
  - Build production Docker image
- Commit `083ad94` — Harden production Docker runtime and document deployment.

GitHub milestone: M2 — CI and packaging
GitHub issues: Refer to the corresponding GitHub milestone.

## Milestone M3 — Local operations

Objective:
Build a reproducible local multi-service environment and understand
the orchestration approach used by the book.

Includes:
- Database and application service configuration
- Docker Compose
- Service startup order, health checks, and persistence
- Evaluation or local exercise of Docker Swarm where appropriate

Exit criteria:
- Environment starts from documented instructions
- Data persistence and recovery behavior are tested
- Service configuration is version-controlled

GitHub milestone: Pending
GitHub issues: Pending

## Milestone M4 — AWS infrastructure and deployment

Objective:
Define and validate the production infrastructure and deploy with
explicit cost and security controls.

Includes:
- Terraform and GitHub provider workflow
- AWS architecture and cost review
- Machine-image strategy, including Packer if justified
- Infrastructure provisioning and application deployment
- Resource inventory and cleanup procedure

Exit criteria:
- Infrastructure changes have been reviewed before application
- AWS credit eligibility and current service pricing are checked
- Access controls, cost controls, and cleanup steps are documented
- Deployment is verified and unnecessary resources are removed

GitHub milestone: Pending
GitHub issues: Pending

## Milestone M5 — Delivery and distributed operation

Objective:
Automate delivery and evaluate distributed operation, scaling, and
safe rollback.

Includes:
- Continuous deployment
- Secret management
- Multi-node deployment and Erlang distribution
- Service discovery and cluster health
- Load balancing, scaling, and rollback strategy

Exit criteria:
- Deployment and rollback procedures are tested
- Secrets are not committed to source control
- Distributed behavior and failure scenarios are documented
- Scaling decisions are supported by experiments and operational needs

GitHub milestone: M0 - Planning and toolchain

GitHub issues:
- #1 — [Document official technical references and tool versions](https://github.com/pasamrevanthkumar/hologram-beamops-kanban/issues/1)
- #2 — [Document the local development and verification workflow](https://github.com/pasamrevanthkumar/hologram-beamops-kanban/issues/2)
- #3 — [Verify Elixir, Phoenix, and Hologram compatibility](https://github.com/pasamrevanthkumar/hologram-beamops-kanban/issues/3)
- #4 — [Review and resolve initial architecture decisions](https://github.com/pasamrevanthkumar/hologram-beamops-kanban/issues/4)
- #5 — [Finalize the initial application architecture](https://github.com/pasamrevanthkumar/hologram-beamops-kanban/issues/5)

## Milestone M6 — Observability

Objective:
Make application and runtime behavior visible and actionable.

Includes:
- Logging architecture and centralized logs
- Runtime and application metrics
- A custom metric where appropriate
- Grafana dashboard and alert configuration
- Operational validation

Exit criteria:
- Logs and metrics support investigation of representative failures
- Dashboard values are verified
- Alert behavior is tested
- Monitoring configuration and response procedures are documented

GitHub milestone: Pending
GitHub issues: Pending

## Milestone M7 — Final validation and cleanup

Objective:
Review the complete delivery lifecycle and leave the project in a
reproducible, documented state.

Includes:
- End-to-end verification
- Documentation and architecture decision review
- Final cloud-resource inventory
- Removal of unnecessary billable resources
- Summary of lessons learned and Hologram-specific adaptations

Exit criteria:
- Lifecycle evidence and operating instructions are committed
- Remaining resources and costs are understood
- Unneeded resources are removed
- Remaining limitations and future work are documented

GitHub milestone: Pending
GitHub issues: Pending

## Book lifecycle cross-reference

The milestone grouping adapts the book's chapter sequence:

| Book chapter | Main subject | Local milestone |
|---|---|---|
| 1 | BEAMOps principles and toolchain | M0 |
| 2 | Terraform-managed GitHub issues and milestones | M0 |
| 3 | Phoenix LiveView, OTP releases, and Docker | M1, M2 |
| 4 | GitHub Actions CI | M2 |
| 5 | Ecto, Docker Compose, and Docker Swarm | M1, M3 |
| 6 | AWS production environment, Terraform, and Packer | M4 |
| 7 | Continuous deployment and secrets | M5 |
| 8 | Multi-node Docker Swarm | M5 |
| 9 | Distributed Erlang | M5 |
| 10 | Autoscaling, load balancing, rollback, and cleanup | M5, M7 |
| 11 | Logs and metrics | M6 |
| 12 | Custom PromEx metric, Grafana dashboard/alert, production image | M6, M7 |

The book uses Phoenix LiveView. Its application code and framework-specific
steps must be adapted and verified for Hologram. Lifecycle coverage
should be preserved where practical, while any change in implementation
is documented with its rationale.

## GitHub synchronization log

Record updates using this format:

- Date:
- GitHub milestone/issue created or changed:
- Local document updated:
- Commit:
- Notes:
