# Project Milestones and GitHub Mapping

## Purpose

This file is the local record of the project milestones. GitHub Issues
and Milestones track actionable work.

The milestones describe stages in the lifecycle of one Hologram-based
application, not separate application projects.

The lifecycle is adapted from *Engineering Elixir Applications*.
The book is a guide; its technologies and chapters are not mandatory
deliverables when an implementation is unnecessary, unsuitable, or
outside the agreed scope.

## Milestone M0 — Planning and toolchain

Status: **Complete — 2026-11-05**

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
- [x] Planning documents reviewed and committed
- [x] Key open decisions identified
- [x] Toolchain versions and compatibility evidence documented
- [x] Initial GitHub issues mapped to this plan

Verification evidence:
- Requirements, architecture, tooling, and decision records are
  maintained in the repository.
- The selected Elixir, Erlang/OTP, Phoenix, and Hologram versions
  are recorded.
- Hologram-specific integration decisions are documented.
- GitHub repository, milestones, labels, and initial issues were
  created and mapped to the project plan.
- Future infrastructure and observability decisions remain explicitly
  distinguishable from decisions required for the initial application.

GitHub milestone: M0 - Planning and toolchain

GitHub issues:
- #1 — [Document official technical references and tool versions](https://github.com/pasamrevanthkumar/hologram-beamops-kanban/issues/1)
- #2 — [Document the local development and verification workflow](https://github.com/pasamrevanthkumar/hologram-beamops-kanban/issues/2)
- #3 — [Verify Elixir, Phoenix, and Hologram compatibility](https://github.com/pasamrevanthkumar/hologram-beamops-kanban/issues/3)
- #4 — [Review and resolve initial architecture decisions](https://github.com/pasamrevanthkumar/hologram-beamops-kanban/issues/4)
- #5 — [Finalize the initial application architecture](https://github.com/pasamrevanthkumar/hologram-beamops-kanban/issues/5)

## Milestone M1 — Working Kanban application

Status: **Complete — 2026-11-05**

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
- [x] Agreed functional requirements implemented
- [x] Automated tests pass locally
- [x] Setup and data-model documentation is current

Verification evidence:
- Implemented Kanban boards, columns, and tasks.
- Implemented task creation, editing, movement, ordering, and deletion.
- Implemented PostgreSQL persistence and database migrations.
- Implemented dashboard summaries.
- Automated tests cover application and persistence behavior.
- The application was exercised locally and during the temporary
  AWS deployment.

GitHub milestone: M1 - Working Kanban application

GitHub issues: No dedicated issues are currently recorded under M1.

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

GitHub milestone: M2 - CI and packaging

GitHub issues: Refer to the corresponding GitHub milestone.

## Milestone M3 — Local operations

Status: **Complete — 2026-11-03**

Objective:

Build a reproducible local multi-service environment and understand
the orchestration approach used by the book.

Includes:
- Database and application service configuration
- Docker Compose
- Service startup order, health checks, and persistence
- Evaluation or local exercise of Docker Swarm where appropriate

Exit criteria:
- [x] Environment starts from documented instructions
- [x] Data persistence and recovery behavior are tested
- [x] Service configuration is version-controlled

Verification evidence:
- Inspected the Compose services: `db`, `migrate`, and `app`.
- Verified PostgreSQL health checks and migration completion
  before application startup.
- Confirmed PostgreSQL data is stored in the named
  `hologram_beamops_kanban_postgres_data` volume.
- Created a dedicated `m3_persistence_check` test table and verified
  its record survived a PostgreSQL container restart.
- Verified the running application reconnected to PostgreSQL after
  the database restart.
- Restarted the application container and verified HTTP 200 and
  successful application-level database queries afterward.
- Exercised a disposable Docker Swarm Nginx service:
  - Created two replicas and verified HTTP 200.
  - Scaled from two to four replicas.
  - Removed one task container and observed Swarm create a replacement.
  - Scaled back to two replicas.
  - Removed the disposable service and verified cleanup.
- Confirmed the Kanban Compose application and PostgreSQL volume
  remained separate from the Swarm experiment.

Limitations and follow-up:
- Swarm was evaluated on a single node (`hpomen`). This does not
  demonstrate multi-node high availability.
- PostgreSQL recovery testing covered container restart, not backup
  restoration or permanent volume-loss recovery.
- Extended database outages and application behavior during a
  prolonged outage were not tested.
- Docker Compose remains the orchestration choice for this local
  application. Swarm migration is not part of M3.

GitHub milestone: M3 - Local operations

GitHub issues: Refer to the corresponding GitHub milestone.

## Milestone M4 — AWS infrastructure and deployment

Status: **Complete — 2026-11-05**

Objective:

Define and validate the temporary AWS deployment with explicit
cost and security controls.

Includes:
- Terraform-managed AWS infrastructure
- AWS architecture and cost review
- Infrastructure provisioning and application deployment
- Application health and functional verification
- Resource inventory and cleanup procedure

Exit criteria:
- [x] Infrastructure changes are managed and reviewed using Terraform
- [x] AWS credit eligibility and service pricing are reviewed before deployment
- [x] Access controls, cost controls, and cleanup steps are documented
- [x] Deployment is verified
- [x] Project-created AWS resources are removed and deletion is verified

Verification evidence:
- Provisioned a temporary EC2 deployment in `ap-southeast-2`.
- Used Terraform to manage the EC2 instance, security group,
  and EC2 key pair.
- Restricted SSH access to the deployment operator's public IP.
- Deployed the application using Docker Compose with PostgreSQL,
  a one-off migration service, and the Hologram application.
- Pulled the application image from the private GitHub Container Registry.
- Verified the image digest used by the deployment.
- Verified database migrations and PostgreSQL health.
- Verified the application health endpoint returned HTTP 200.
- Confirmed browser-based application functionality.
- Restarted the Compose application stack without deleting its
  PostgreSQL volume and verified that existing data persisted.
- Destroyed the Terraform-managed infrastructure.
- Terraform reported that all three managed resources were destroyed.
- Verified the EC2 instance was terminated and the project-created
  EBS volume and security group no longer existed.
- Removed local AWS deployment Terraform state and temporary plan
  artifacts after successful teardown.
- Committed the deployment procedure and verification record in
  `docs/AWS_DEPLOYMENT.md`.

Deployment limitations:
- This was a temporary, single-instance deployment.
- Continuous deployment, multi-node deployment, autoscaling,
  production load balancing, and automated rollback were not implemented.
- The application environment is no longer running in AWS.

GitHub milestone: M4 - AWS infrastructure and deployment

GitHub issues: Refer to the corresponding GitHub milestone.

## Milestone M5 — Delivery and distributed operation

Status: **Deferred — not implemented in this iteration**

Objective:

Automate delivery and evaluate distributed operation, scaling, and
safe rollback.

Includes:
- Continuous deployment
- Secret management
- Multi-node deployment and Erlang distribution
- Service discovery and cluster health
- Load balancing, scaling, and rollback strategy

Status and limitations:
- The application image was published to GHCR and manually deployed
  to the temporary AWS environment.
- A dedicated temporary read-only package token was used for the
  EC2 image pull.
- An automated AWS continuous deployment workflow was not implemented.
- Multi-node deployment and Erlang distribution were not implemented.
- Production service discovery, load balancing, autoscaling, and
  automated rollback were not implemented.
- These capabilities remain future work and are not claimed as
  completed project features.

GitHub milestone: M5 - Delivery and distributed operation

GitHub issues: No dedicated implementation issues are currently
recorded under M5.

## Milestone M6 — Observability

Status: **Deferred — not implemented in this iteration**

Objective:

Make application and runtime behavior visible and actionable.

Includes:
- Logging architecture and centralized logs
- Runtime and application metrics
- A custom metric where appropriate
- Grafana dashboard and alert configuration
- Operational validation

Status and limitations:
- Container health checks and Docker logs were used during local
  and AWS deployment verification.
- Centralized logging was not implemented.
- PromEx application metrics and custom metrics were not implemented.
- Grafana dashboards and alerting were not implemented.
- A production monitoring and incident-response workflow was not
  established.

These capabilities remain future work and are not claimed as
completed project features.

GitHub milestone: M6 - Observability

GitHub issues: No dedicated implementation issues are currently
recorded under M6.

## Milestone M7 — Final validation and cleanup

Status: **In progress — 2026-11-05**

Objective:

Review the implemented delivery lifecycle and leave the project in a
reproducible, documented state.

Includes:
- End-to-end verification
- Documentation and architecture decision review
- Final cloud-resource inventory
- Removal of unnecessary billable resources
- Summary of lessons learned and Hologram-specific adaptations
- Final AWS billing review

Exit criteria:
- [ ] Final lifecycle documentation and operating instructions are committed
- [x] Project-created AWS resources are removed and deletion is verified
- [x] Remaining technical limitations and future work are documented
- [x] AWS billing is reviewed for accrued charges
- [ ] Final repository and project-management records are synchronized

Verification evidence:
- Application functionality and health were verified during deployment.
- PostgreSQL persistence was verified across a Compose restart.
- AWS Terraform destruction completed successfully.
- AWS-side checks confirmed deletion of the project-created resources.
- `docs/AWS_DEPLOYMENT.md` records the temporary deployment and teardown.
- README and lifecycle documentation are being updated to reflect
  the actual completed and deferred scope.
- AWS Billing showed an amount due of $0.00 at the time of review.
- Cost Explorer showed $0.00 net cost for the reviewed period
  through 2026-11-05. Current-period figures may be estimated,
  and billing data may be delayed.
- AWS credits showed $139.70 remaining from $140.00 issued,
  with $0.30 used. The credits page did not identify which
  service accounted for the $0.30 usage.

Remaining work:
- Allow for possible billing-data delays and check for any
  subsequently posted charges before final project closure.
- Reconcile GitHub issue and milestone statuses with the final
  documentation.
- Complete the final repository security and portfolio review.

GitHub milestone: M7 - Final validation and cleanup

GitHub issues: No dedicated finalization issue is currently recorded
under M7.

## Book lifecycle cross-reference

The milestone grouping adapts the book's chapter sequence. The
cross-reference below distinguishes implemented work from deferred
topics.

| Book chapter | Main subject | Local milestone | Coverage |
|---|---|---|---|
| 1 | BEAMOps principles and toolchain | M0 | Completed |
| 2 | Terraform-managed GitHub issues and milestones | M0 | Completed |
| 3 | Phoenix LiveView, OTP releases, and Docker | M1, M2 | Adapted to Hologram; completed |
| 4 | GitHub Actions CI | M2 | Completed |
| 5 | Ecto, Docker Compose, and Docker Swarm | M1, M3 | Completed within documented scope |
| 6 | AWS production environment, Terraform, and Packer | M4 | Temporary AWS deployment completed; Packer not used |
| 7 | Continuous deployment and secrets | M5 | Deferred |
| 8 | Multi-node Docker Swarm | M5 | Deferred |
| 9 | Distributed Erlang | M5 | Deferred |
| 10 | Autoscaling, load balancing, rollback, and cleanup | M5, M7 | Deployment cleanup completed; scaling and rollback deferred |
| 11 | Logs and metrics | M6 | Deferred |
| 12 | Custom PromEx metric, Grafana dashboard/alert, production image | M2, M6 | Production image completed; metrics and dashboard/alert deferred |

The book uses Phoenix LiveView. Its application code and
framework-specific steps must be adapted and verified for Hologram.
Lifecycle practices are preserved where practical, while changes in
implementation and deferred topics are documented with their rationale.

## GitHub synchronization log

Record updates using this format:

- Date:
- GitHub milestone/issue created or changed:
- Local document updated:
- Commit:
- Notes:
