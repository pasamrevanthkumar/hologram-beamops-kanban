# Application Architecture

## 1. Status

Status: **Implemented application architecture; temporary AWS deployment
verified and subsequently dismantled — 2026-11-05**

This document describes the logical architecture and implemented
boundaries of Hologram BeamOps Kanban.

The application uses Hologram for its web UI, a Phoenix host runtime,
an Elixir application/domain layer, Ecto for persistence, and PostgreSQL
for durable storage.

The application has been implemented and tested. Its OTP release and
production Docker image have been built and verified. A temporary
AWS deployment was also verified and subsequently destroyed.

The architecture is intentionally a single-application deployment.
Multi-node distributed operation, production scaling, automated
continuous deployment, and full observability remain deferred.

## 2. Architectural goals

- Use Hologram for the web application UI.
- Keep business rules separate from UI code and persistence details.
- Persist application data reliably.
- Support automated tests and reproducible builds.
- Provide a reproducible local development environment.
- Take the same application through a practical delivery lifecycle.
- Document differences between Hologram and the book's Phoenix LiveView
  implementation.
- Avoid unnecessary infrastructure and ongoing cloud costs.

## 3. Implemented logical components

### Browser and Hologram UI

Responsibilities:
- Render boards, columns, and tasks.
- Collect user input.
- Present operation results and validation feedback.
- Manage UI interactions using supported Hologram facilities.

Hologram pages, components, actions, and commands follow the APIs
supported by the selected Hologram version. Phoenix LiveView callbacks
and templates are not assumed to be directly interchangeable.

### Phoenix host and Hologram runtime

Responsibilities:
- Run the web application using the Hologram host integration.
- Handle routing and framework-level request processing.
- Provide the runtime required by the application.

The selected Hologram and Phoenix integration is recorded in the
project dependencies and tooling documentation.

### Application/domain layer

Responsibilities:
- Apply rules for creating and editing tasks.
- Validate task movement and ordering.
- Apply completion rules.
- Coordinate persistence operations.
- Return operation results.

Business behavior is separated from UI rendering and persistence
implementation details and is covered by automated tests.

### Persistence layer

Selected technology: Ecto with PostgreSQL, as recorded in ADR-003.

Responsibilities:
- Define database schemas and changesets.
- Execute queries and transactions.
- Enforce data relationships and constraints.
- Manage version-controlled database migrations.
- Persist Kanban application data.

The persistence implementation and database-backed behavior have
been implemented and tested.

### Database

Selected technology: PostgreSQL.

PostgreSQL runs locally and as a containerized service. During the
temporary AWS deployment, PostgreSQL ran alongside the application
using Docker Compose.

The local Compose environment uses a named volume for database
persistence.

## 4. Application data model

The application persists:

### Board
- ID
- Name
- Inserted and updated timestamps

### Column
- ID
- Board ID
- Name
- Position
- Inserted and updated timestamps

### Task
- ID
- Column ID
- Title
- Optional description
- Position
- Completion state or equivalent documented representation
- Inserted and updated timestamps

The implemented schemas and migrations define the persistence
structure and relevant data relationships. Database operations
implement the application's ordering and consistency requirements.

## 5. State-changing request flow

1. The user performs an action in the Hologram UI.
2. The action invokes the supported server-side operation.
3. The application validates input and applies domain rules.
4. The persistence layer executes the required database operation,
   using transactions where appropriate.
5. The operation returns a success or error result.
6. The UI presents the resulting state or useful feedback.

## 6. Testing boundaries

- Domain tests: task validation, completion, movement, and ordering.
- Persistence tests: schemas, changesets, constraints, and
  database-backed behavior.
- UI/framework tests: use the testing facilities supported by Hologram
  and its host integration.
- Delivery tests: compilation, formatting, application tests, image
  builds, container startup, health checks, and deployment validation.

The test suite passed with 89 tests during the CI and packaging
milestone.

## 7. Deployment architecture

### Local development

The application can run with its local development environment and
PostgreSQL database.

### Local multi-service deployment

Docker Compose manages:
- PostgreSQL (`db`)
- One-off database migrations (`migrate`)
- Hologram application (`app`)

Database readiness and migration completion are checked before
application startup.

### Temporary AWS deployment

A temporary single-instance deployment was provisioned in
`ap-southeast-2` using Terraform.

The EC2 instance ran:
- The Hologram application container
- PostgreSQL
- A one-off migration service
- Docker Compose

The application image was pulled from GitHub Container Registry.

The application was bound to localhost on the EC2 instance and
verified through an SSH tunnel. SSH ingress was restricted to the
deployment operator's public IP.

The deployment was verified, and the Terraform-managed resources
were subsequently destroyed. The AWS deployment procedure and
verification evidence are recorded in `docs/AWS_DEPLOYMENT.md`.

### Deferred deployment capabilities

The following capabilities were not implemented:
- Automated continuous deployment to AWS
- Multi-node deployment and Erlang distribution
- Production service discovery and cluster health
- Production load balancing and autoscaling
- Automated rollback
- Centralized logs and metrics
- PromEx metrics, Grafana dashboards, and alerting

## 8. Security boundaries

- Browser-provided data is untrusted.
- Server-side operations enforce validation and domain rules.
- Secrets must not be committed to Git.
- The temporary AWS deployment restricted SSH access to the
  deployment operator's public IP.
- The application was bound to localhost and accessed through
  an SSH tunnel during verification.
- Public exposure requires a separate access-control and security
  review.
- Database access and production credentials must be restricted.

The temporary deployment is no longer running.

## 9. Future architecture questions

The following topics require separate design and verification before
a future implementation:

- What access-control strategy is appropriate before public exposure?
- Is multi-node Erlang distribution justified by the application's
  availability and scaling requirements?
- Which orchestration and AWS services are justified by operational
  complexity and budget?
- Which centralized logging and metrics architecture is appropriate?
- What deployment and rollback automation is required for a future
  continuously delivered environment?
