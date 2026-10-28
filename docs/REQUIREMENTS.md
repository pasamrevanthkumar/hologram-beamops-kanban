# Product Requirements

## 1. Purpose

Build one Hologram-based Kanban application and take it through the
complete software delivery lifecycle described in *Engineering Elixir
Applications*.

This is one continuous application project. Lifecycle stages are not
separate application projects.

## 2. Initial users and scope

The first version is a single-user learning application intended to
demonstrate product development, packaging, deployment, and operations.

Authentication and multi-user collaboration are not assumed to be
implemented in the first version. Before any public deployment, an
appropriate access-control strategy must be selected and validated.

## 3. Functional requirements

### REQ-001: View a board

The user can open the Kanban board and see its columns and tasks.

Acceptance criteria:
- The board displays its columns in a defined order.
- Each column displays its tasks in a defined order.
- An empty board or column has a useful empty state.

### REQ-002: Create a task

The user can create a task in a selected column.

Acceptance criteria:
- A non-empty title is required.
- A description is optional.
- Invalid input receives understandable feedback.
- A successfully created task appears in the correct column.

### REQ-003: Edit a task

The user can update an existing task's title and description.

Acceptance criteria:
- Valid changes are saved.
- Invalid changes are rejected.
- A task's identity and column assignment remain unchanged unless
  explicitly changed by the relevant operation.

### REQ-004: Move and order tasks

The user can move a task between columns and change its position.

Acceptance criteria:
- The task appears in its destination column.
- The source and destination ordering remain valid.
- Moving a task does not create duplicate positions within a column.
- A failed operation does not leave a partially updated task.

### REQ-005: Complete a task

The user can mark a task as complete.

Acceptance criteria:
- Completion state is visible in the UI.
- The state is persisted.
- The chosen representation of completion is documented and tested.

### REQ-006: Persist application data

Boards, columns, and tasks are stored durably.

Acceptance criteria:
- Data survives an application restart.
- Database migrations are version-controlled.
- Invalid relationships are rejected.
- Data changes use appropriate transaction boundaries.

### REQ-007: Validate server-side operations

All state-changing operations validate their inputs and enforce domain
rules on the server.

Acceptance criteria:
- Client-side validation is treated as a usability aid, not a security
  boundary.
- Invalid requests cannot persist invalid domain state.
- Errors are handled without exposing secrets or internal details.

## 4. Quality requirements

### REQ-008: Automated verification

Use ExUnit for automated tests, with database-backed tests where
appropriate.

Acceptance criteria:
- Core domain rules have tests.
- Persistence behavior and important failure cases have tests.
- Formatting, compilation, and tests can be run using documented
  commands.
- CI runs the agreed validation checks.

### REQ-009: Reproducible packaging

Build an OTP release and package it in a container.

Acceptance criteria:
- Build and runtime instructions are documented.
- Configuration is supplied appropriately for each environment.
- The image can start the application without relying on development
  tooling being installed in the runtime container.

### REQ-010: Delivery and operations

Take the same application through local orchestration, CI/CD,
infrastructure as code, deployment, distributed operation, and
observability.

Acceptance criteria:
- Deployment and rollback procedures are documented and tested.
- Health checks and operational failure scenarios are validated.
- Logs and metrics help investigate representative failures.
- Dashboards and alerts are tested rather than merely configured.
- Cloud resources are reviewed and unnecessary resources removed.

## 5. Explicit initial exclusions

Unless later requirements justify them, the initial product does not
include:
- Multiple organizations or tenants
- Real-time collaborative editing
- Advanced role and permission management
- Attachments, comments, and notifications
- A mobile-native client

These exclusions do not prevent later expansion if it supports the
learning objectives and remains manageable.

## 6. Security and privacy

- Do not commit credentials, tokens, private keys, or production secrets.
- Do not expose an unauthenticated application containing non-public
  data to the public internet.
- Select and test an appropriate access-control approach before public
  production exposure.
- Validate all state-changing operations on the server.
- Document secret handling and cloud cleanup procedures.

## 7. Definition of done

A requirement is complete when its acceptance criteria are met, relevant
automated checks pass, documentation is updated, and the corresponding
GitHub issue is linked to the work.

The overall project is complete when the application has been developed,
tested, packaged, deployed, operated, monitored, documented, and
reviewed for cloud-resource cleanup.
