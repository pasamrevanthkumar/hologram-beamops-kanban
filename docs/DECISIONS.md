# Architecture Decision Records

This file indexes architectural decisions for Hologram BeamOps Kanban.
Each decision should record its context, options, rationale, consequences,
and verification evidence.

Use these statuses:
- Proposed: a candidate decision awaiting verification or approval.
- Accepted: selected for implementation.
- Superseded: replaced by a later decision.
- Rejected: considered and not selected.

## ADR-001: Use Hologram for the web UI

Status: Accepted

Context:
The project is intended to adapt the full delivery lifecycle in
Engineering Elixir Applications to a Hologram-based application.

Decision:
Use Hologram for the application UI. Treat the book's Phoenix LiveView
code as a reference for lifecycle and operations practices, not as code
that can automatically be copied into Hologram.

Consequences:
- Hologram-specific APIs and integration points must be verified.
- Differences from Phoenix LiveView must be documented.
- UI and interaction tests must use supported Hologram facilities.

## ADR-002: Separate domain rules from UI and persistence

Status: Accepted

Context:
The application must be testable and maintainable as it grows through
the delivery lifecycle.

Decision:
Keep task and board rules in application/domain modules rather than
embedding all business behavior in UI components or database callbacks.

Rationale:
Separating domain rules from the Hologram UI and persistence layer makes
the rules easier to test independently and reduces coupling as the
application gains features and operational complexity.

Consequences:
- Domain behavior should be testable without rendering UI components.
- Persistence concerns should not define the application business rules.
- The initial module boundaries must remain simple and be reviewed as
  implementation reveals concrete needs.

Verification:
The application implements separate domain, UI, and persistence
responsibilities. Domain and application behavior is covered by
automated tests, including database-backed behavior. The implemented module
boundaries reflect the separation intended by this decision.

## ADR-003: PostgreSQL and Ecto for persistence

Status: Accepted

Context:
The application needs durable data, migrations, constraints, and
database-backed tests.

Decision:
Use PostgreSQL as the relational database and Ecto with Ecto SQL for
data mapping, migrations, queries, and transaction management.

Rationale:
PostgreSQL provides durable relational storage and database constraints.
Ecto provides an Elixir-native persistence layer with explicit schemas,
queries, changesets, migrations, and transaction support.

Consequences:
- Local development and tests require a configured PostgreSQL database.
- Data integrity should be enforced through appropriate database
  constraints as well as application-level validation.
- Multi-step task moves and ordering changes must use transactions where
  needed to preserve consistency.

Verification:
The selected dependencies compile with the project's Hologram and
Phoenix baseline. PostgreSQL schemas, migrations, persistence operations,
and database-backed tests have been implemented and exercised.
Database readiness and migration execution were also verified in the
Docker Compose and temporary AWS deployment environments.
The automated test suite passed with 89 tests during the CI and
packaging milestone.

## ADR-004: Local-first development

Status: Accepted

Context:
The project should minimize cost and avoid premature cloud complexity.

Decision:
Develop and validate locally before provisioning AWS infrastructure.

Consequences:
- Cloud deployment is a later, separately reviewed stage.
- Cost, credit eligibility, security, and cleanup must be checked first.
- No AWS resources should be created as part of initial planning.

## ADR-005: Git and Markdown as the local project record

Status: Accepted

Context:
Project planning must remain reviewable and version-controlled while
also using GitHub Issues and Milestones.

Decision:
Keep requirements, architecture, decisions, tools, and milestone
records in Markdown under version control. Use GitHub for actionable
issues and milestone tracking.

Consequences:
- GitHub issue and milestone identifiers should be recorded locally.
- Important decisions and progress should not exist only in issue
  comments or uncommitted notes.

## ADR-006: Public access and application security

Status: Accepted

Context:
The application was deployed temporarily to AWS for verification.
Public application exposure would require an appropriate access-control
strategy and additional security review.

Decision:
Do not expose the application directly to the public internet in this
iteration. Restrict SSH access to the deployment operator's public IP
and bind the application to localhost on the EC2 instance. Access the
application through an SSH tunnel during deployment verification.

Keep deployment secrets outside source control and supply runtime
configuration through environment variables.

Rationale:
The purpose of the temporary deployment was to verify the application
and its operational packaging, not to launch a publicly accessible
production service. Restricting network access reduced exposure and
avoided introducing an authentication system outside the agreed scope.

Consequences:
- The temporary AWS deployment was accessible through an SSH tunnel.
- The application environment has since been destroyed.
- Public application access requires a separate access-control and
  security design before any future public deployment.
- Runtime secrets must not be committed to the repository.
- This decision does not establish that the application is ready for
  unrestricted public access.

Verification:
The EC2 security group restricted SSH ingress to the deployment
operator's public IP. The application was bound to localhost and
verified through an SSH tunnel. The deployment and its resources were
subsequently removed.

## ADR-007: Temporary AWS infrastructure and deferred observability

Status: Accepted

Context:
The project required a practical cloud deployment to validate the
Hologram application, OTP release, Docker image, PostgreSQL integration,
and deployment procedure. The project also had a limited AWS budget
and a requirement to avoid unnecessary ongoing infrastructure costs.

Decision:
Use a temporary, single-instance AWS deployment managed with Terraform.
Run the application and PostgreSQL using Docker Compose on EC2. Use
GitHub Container Registry to distribute the application image.

Destroy the project-created AWS infrastructure after deployment
verification.

Defer multi-node distributed operation, production scaling,
automated rollback, centralized logging, metrics, Grafana dashboards,
and alerting.

Rationale:
A small temporary deployment was sufficient to validate the
application's production packaging and deployment workflow without
introducing the cost and complexity of a larger production architecture.

Consequences:
- The temporary AWS topology is documented in
  `docs/AWS_DEPLOYMENT.md`.
- Terraform configuration for the AWS deployment is retained as
  reproducible project source.
- The project-created AWS resources were destroyed after verification.
- The application is not currently hosted in AWS.
- Distributed deployment and full observability remain future work.
- Any future deployment must repeat the cost, security, and cleanup
  review.

Verification:
The application was deployed to EC2 using Docker Compose, PostgreSQL,
and a GHCR-hosted image. Database migrations, health checks, browser
functionality, and persistence across a Compose restart were verified.
Terraform destroyed the three managed AWS resources, and subsequent
AWS checks confirmed their deletion.

Container health checks and Docker logs were used for operational
verification. Centralized observability, PromEx metrics, Grafana
dashboards, and alerting were not implemented.

## ADR template

### ADR-NNN: Short title

Status: Proposed | Accepted | Superseded | Rejected

Context:
What problem or constraint requires a decision?

Options considered:
- Option A
- Option B

Decision:
What are we choosing?

Rationale:
Why is this appropriate for this project?

Consequences:
What trade-offs, follow-up work, or constraints result?

Verification:
What documentation, tests, or experiments support this decision?
