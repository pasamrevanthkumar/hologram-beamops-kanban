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

Status: Proposed

Context:
The application must be testable and maintainable as it grows through
the delivery lifecycle.

Proposal:
Keep task and board rules in application/domain modules rather than
embedding all business behavior in UI components or database callbacks.

Verification:
Confirm the module boundaries during the initial implementation design.

## ADR-003: PostgreSQL and Ecto for persistence

Status: Proposed

Context:
The application needs durable data, migrations, constraints, and
database-backed tests.

Proposal:
Evaluate PostgreSQL and Ecto for the initial persistence layer.

Verification:
Check compatibility with the selected Hologram and Phoenix dependency
versions, test database setup, and document local development commands.

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

Status: Proposed

Context:
A public deployment must not expose non-public data through an
unauthenticated application.

Proposal:
Select and validate an appropriate access-control strategy before
public production exposure. Keep secrets out of source control and
validate state-changing operations on the server.

Verification:
Document the chosen approach, threat considerations, secret handling,
and deployment restrictions before public exposure.

## ADR-007: Production infrastructure and observability

Status: Proposed

Context:
The book covers Terraform, AWS, Docker-based deployment, distributed
operation, scaling, logging, metrics, dashboards, and alerts.

Proposal:
Evaluate each technology at the stage where it is needed. Prefer
reproducible infrastructure and automated operational checks, while
avoiding unnecessary services and cost.

Verification:
Record the selected topology, cost checks, compatibility findings,
operational risks, and cleanup procedure before provisioning.

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
