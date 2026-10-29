# Architecture Proposal

## 1. Status

Status: Initial scaffold integration verified; Kanban implementation and production architecture remain in progress.

This document describes the logical architecture and current implementation boundary. The basic Hologram scaffold and local PostgreSQL setup have been verified. The Kanban domain, schemas, migrations, and database-backed behavior remain to be implemented and tested. Production deployment and infrastructure have not been implemented.

## 2. Architectural goals

- Use Hologram for the web application UI.
- Keep business rules separate from UI code and persistence details.
- Persist application data reliably.
- Support automated tests and reproducible builds.
- Begin with a local development environment.
- Evolve the same application through the book's delivery lifecycle.
- Document differences between Hologram and the book's Phoenix LiveView
  implementation.

## 3. Proposed logical components

### Browser and Hologram UI

Responsibilities:
- Render the board, columns, and tasks.
- Collect user input.
- Present validation errors and operation results.
- Manage temporary UI state where appropriate.

Hologram pages, components, actions, and commands must follow the APIs
supported by the selected Hologram version. Do not assume that Phoenix
LiveView callbacks or templates can be copied directly.

### Phoenix host and Hologram runtime

Responsibilities:
- Run the web application using the integration supported by Hologram.
- Handle routing and framework-level request processing.
- Provide the runtime needed by the application.

Verify the exact host integration against the Hologram documentation
and the dependency versions selected for this project.

### Application/domain layer

Responsibilities:
- Apply rules for creating and editing tasks.
- Validate task movement and ordering.
- Apply completion rules.
- Coordinate persistence operations.
- Return explicit success and error results.

This layer should avoid depending on UI rendering details.

### Persistence layer

Selected technology: Ecto with PostgreSQL, as recorded in ADR-003. Kanban persistence behavior remains to be implemented and verified.

Responsibilities:
- Define schemas and changesets.
- Execute queries and transactions.
- Enforce appropriate data relationships and constraints.
- Manage version-controlled database migrations.

### Database

Selected technology: PostgreSQL, as recorded in ADR-003.

Initially run it locally. Later, containerize or orchestrate it as
required by the relevant delivery stage. Production database hosting
must be evaluated separately for reliability, security, and cost.

## 4. Initial data model proposal

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

The final schema must define foreign keys, ordering constraints, indexes,
and deletion behavior. The task ordering strategy and concurrency
behavior remain open decisions until implementation design.

## 5. State-changing request flow

1. The user performs an action in the Hologram UI.
2. The action invokes the supported server-side operation.
3. The application validates the input and applies domain rules.
4. The persistence layer executes the required database operation,
   using a transaction where appropriate.
5. The operation returns a success or error result.
6. The UI displays the resulting state or useful error feedback.

The exact Hologram action/command boundary must be confirmed against
the selected version's documentation.

## 6. Testing boundaries

- Domain tests: task validation, completion, movement, and ordering.
- Persistence tests: schemas, changesets, constraints, transactions,
  and migrations.
- UI/framework tests: use the testing facilities supported by Hologram
  and its host integration.
- Delivery tests: build, container startup, health checks, and deployment
  validation.

## 7. Deployment evolution

The deployment architecture will evolve in stages:

1. Local application and local database.
2. Reproducible development and automated CI.
3. OTP release and container image.
4. Local multi-service orchestration.
5. Infrastructure as code and a cost-reviewed AWS deployment.
6. Automated delivery and secrets management.
7. Distributed deployment and scaling evaluation.
8. Centralized logs, metrics, dashboards, and alerts.

The exact production topology and AWS services remain undecided until
the relevant stages. No cloud infrastructure is authorized by this
proposal.

## 8. Security boundaries

- Browser-provided data is untrusted.
- Server-side operations enforce validation and domain rules.
- Secrets must not be committed to Git.
- Public exposure requires an approved access-control design.
- Database access and production credentials must be restricted.
- Deployment and rollback procedures must not disclose secrets.

## 9. Open questions

- Which Hologram version and host integration should be pinned?
- Which supported testing approach best covers Hologram interactions?
- How should task ordering be represented and updated atomically?
- What access-control strategy is appropriate before public exposure?
- Which container orchestration and AWS services are justified by the
  book's goals, compatibility, operational complexity, and budget?
