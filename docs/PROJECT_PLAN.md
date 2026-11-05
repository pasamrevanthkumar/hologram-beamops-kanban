
# Project Plan

## Project definition

One Hologram-based Kanban application, developed and taken through a
practical software delivery lifecycle guided by
*Engineering Elixir Applications*.

The lifecycle is deliberately adapted to the project's requirements,
Hologram framework, available time, and AWS cost constraints. The book
is a guide, not a requirement to reproduce every technology or chapter.

## Scope

### Implemented and verified

- Kanban boards, columns, and tasks
- Task creation, editing, movement, ordering, and completion
- PostgreSQL persistence and migrations
- Automated tests and GitHub Actions CI
- OTP release and production Docker image
- Local multi-service environment using Docker Compose
- Database readiness, health checks, persistence, and restart recovery
- Single-node Docker Swarm exercise
- AWS infrastructure managed with Terraform
- Temporary AWS deployment and application verification
- Infrastructure teardown and resource deletion verification
- Lifecycle and deployment documentation

### Deferred

- Automated continuous deployment to AWS
- Multi-node distributed deployment and Erlang clustering
- Production scaling, load balancing, and automated rollback
- Centralized logging and metrics
- PromEx metrics, Grafana dashboards, and alerting

## Delivery stages

- [x] Stage 1: Requirements, architecture, and project management
- [x] Stage 2: Verify the development toolchain and study Hologram integration
- [x] Stage 3: Implement and test the application
- [x] Stage 4: Build an OTP release and Docker image
- [x] Stage 5: Establish a reproducible local multi-service environment
- [x] Stage 6: Define and validate AWS infrastructure as code
- [x] Stage 7: Deploy to AWS with cost controls and verify the application
- [ ] Stage 8: Implement continuous deployment and secrets management — deferred
- [ ] Stage 9: Implement multi-node distributed deployment — deferred
- [ ] Stage 10: Evaluate production scaling, load balancing, and automated rollback — deferred
- [ ] Stage 11: Implement centralized logging and metrics — deferred
- [ ] Stage 12: Build dashboards, configure alerts, and validate monitoring — deferred
- [ ] Stage 13: Complete final documentation, repository synchronization, and lifecycle closure — in progress

## Constraints

- Local-first development
- AWS credits and expiry must be checked before provisioning
- Verify service eligibility, pricing, and credit terms before deployment
- Do not leave billable cloud resources running unnecessarily
- Record Hologram-specific differences from the book's Phoenix LiveView implementation
- Keep deferred capabilities distinct from implemented and verified capabilities

## Definition of done

The implemented scope has been tested, packaged, deployed temporarily,
verified, documented, and cleaned up.

Project-created AWS infrastructure has been destroyed and its deletion
verified. Final lifecycle closure requires reviewing AWS billing for
any accrued charges and recording the outcome.

Deferred lifecycle topics must remain documented as future work rather
than being represented as completed capabilities.
