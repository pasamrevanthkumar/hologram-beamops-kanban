
resource "github_repository" "project" {
  name        = "hologram-beamops-kanban"
  description = "A Hologram-based Kanban application taken through the full Engineering Elixir Applications lifecycle."

  visibility = "private"

  has_issues      = true
  has_discussions = false
  has_projects    = false
  has_wiki        = false

  allow_merge_commit = false
  allow_squash_merge = true
  allow_rebase_merge = false

  delete_branch_on_merge = true
  auto_init              = false
}

locals {
  milestones = {
    M0 = {
      title       = "M0 - Planning and toolchain"
      description = "Completed: scope, requirements, architecture, decisions, toolchain compatibility, official documentation inventory, and GitHub project setup."
      state       = "closed"
    }
    M1 = {
      title       = "M1 - Working Kanban application"
      description = "Completed: Hologram-based Kanban application with task operations, PostgreSQL persistence, migrations, automated tests, and application documentation."
      state       = "closed"
    }
    M2 = {
      title       = "M2 - CI and packaging"
      description = "Completed: continuous integration, formatting and test checks, OTP release, Docker packaging, runtime configuration, and startup verification."
      state       = "closed"
    }
    M3 = {
      title       = "M3 - Local operations"
      description = "Completed: Docker Compose, database readiness, migrations, health checks, persistence verification, and local Docker Swarm experiments."
      state       = "closed"
    }
    M4 = {
      title       = "M4 - AWS infrastructure and deployment"
      description = "Completed: temporary AWS infrastructure provisioned with Terraform, application deployment and verification, persistence testing, documentation, and infrastructure destruction."
      state       = "closed"
    }
    M5 = {
      title       = "M5 - Delivery and distributed operation"
      description = "Deferred: automated AWS continuous deployment, deployment rollback, multi-node Erlang distribution, service discovery, production cluster health, and scaling."
      state       = "open"
    }
    M6 = {
      title       = "M6 - Observability"
      description = "Deferred: centralized logging, metrics, PromEx instrumentation, Grafana dashboards, alerting, and production observability validation. Basic container health checks and Docker logs were used."
      state       = "open"
    }
    M7 = {
      title       = "M7 - Final validation and cleanup"
      description = "In progress: final documentation and GitHub synchronization, repository security and portfolio review, monitoring for delayed AWS billing updates, and lessons learned. AWS infrastructure and local BeamOps runtime cleanup are complete."
      state       = "open"
    }
  }
}

resource "github_repository_milestone" "project" {
  for_each = local.milestones

  owner       = "pasamrevanthkumar"
  repository  = github_repository.project.name
  title       = each.value.title
  description = each.value.description
  state       = each.value.state
}

locals {
  issue_labels = {
    planning = {
      name        = "Kind:Planning"
      color       = "0E8A16"
      description = "Requirements, architecture, decisions, and technical research."
    }
    application = {
      name        = "Kind:Application"
      color       = "1D76DB"
      description = "Application features, domain logic, and user-facing behavior."
    }
    testing = {
      name        = "Kind:Testing"
      color       = "FBCA04"
      description = "Automated tests, validation, and verification."
    }
    cicd = {
      name        = "Kind:CI/CD"
      color       = "5319E7"
      description = "Continuous integration, delivery automation, and releases."
    }
    infrastructure = {
      name        = "Kind:Infrastructure"
      color       = "D93F0B"
      description = "Runtime environments, containers, Terraform, and infrastructure."
    }
    security = {
      name        = "Kind:Security"
      color       = "B60205"
      description = "Access control, secret management, and security hardening."
    }
    observability = {
      name        = "Kind:Observability"
      color       = "006B75"
      description = "Logs, metrics, dashboards, alerts, and operational visibility."
    }
    documentation = {
      name        = "Kind:Documentation"
      color       = "0075CA"
      description = "Project documentation, operational guides, and lessons learned."
    }
  }
}

resource "github_issue_label" "project" {
  for_each = local.issue_labels

  repository  = github_repository.project.name
  name        = each.value.name
  color       = each.value.color
  description = each.value.description
}

locals {
  project_issues = {
    hologram_compatibility = {
      title     = "Verify Elixir, Phoenix, and Hologram compatibility"
      milestone = "M0"
      labels    = ["Kind:Planning"]

      body = <<-EOT
      ## Objective

      Verify the supported versions and integration points required for the Hologram-based Kanban application.

      ## Tasks

      - Identify the Hologram version to use.
      - Verify compatibility with the selected Elixir, Erlang/OTP, and Phoenix versions.
      - Verify the supported Phoenix host integration.
      - Identify the supported Hologram interaction and testing APIs.
      - Record authoritative documentation and compatibility evidence.

      ## Acceptance criteria

      - [x] Compatible versions and constraints are documented.
      - [x] Official documentation references are recorded.
      - [x] Unsupported or uncertain integrations are clearly identified.
      - [x] Findings are committed to the project documentation.

      ## Verification evidence

      - Compatibility and tooling findings are recorded in `docs/TOOLING.md`.
      - Architecture boundaries and Hologram/Phoenix integration are documented in `docs/ARCHITECTURE.md`.
      - Project dependencies and the implemented application provide integration evidence.
      EOT
    }

    documentation_inventory = {
      title     = "Document official technical references and tool versions"
      milestone = "M0"
      labels    = ["Kind:Documentation"]

      body = <<-EOT
      ## Objective

      Establish a reliable reference inventory for the complete application lifecycle.

      ## Tasks

      - Record official Elixir, Erlang/OTP, Phoenix, and Hologram documentation.
      - Record Ecto, PostgreSQL, ExUnit, Docker, and Terraform references.
      - Identify the documentation needed for later CI/CD, deployment, and observability stages.
      - Record the version or compatibility constraints relevant to this project.

      ## Acceptance criteria

      - [x] References are recorded in the repository.
      - [x] Tool versions and unresolved version choices are distinguished.
      - [x] Documentation needed for later milestones is discoverable.
      - [x] No compatibility claim is made without supporting evidence.

      ## Verification evidence

      - Official references and relevant tool versions are recorded in `docs/TOOLING.md`.
      - Architecture, decisions, milestones, and deployment documentation are maintained under `docs/`.
      - Deferred capabilities are explicitly distinguished from implemented functionality.
      EOT
    }

    architecture_review = {
      title     = "Finalize the initial application architecture"
      milestone = "M0"
      labels    = ["Kind:Planning"]

      body = <<-EOT
      ## Objective

      Review the proposed architecture before implementing application code.

      ## Tasks

      - Verify the Hologram UI and Phoenix host boundaries.
      - Define the responsibilities of the application/domain layer.
      - Evaluate Ecto and PostgreSQL compatibility.
      - Identify persistence, transaction, and ordering requirements.
      - Define appropriate testing boundaries.

      ## Acceptance criteria

      - [x] Architecture decisions are supported by documentation or experiments.
      - [x] Confirmed components and proposed components are distinguished.
      - [x] Open technical questions are recorded.
      - [x] docs/ARCHITECTURE.md reflects the reviewed architecture.

      ## Verification evidence

      - `docs/ARCHITECTURE.md` describes the implemented UI, host, domain, persistence, and database boundaries.
      - `docs/DECISIONS.md` records the relevant architecture decisions.
      - Implemented application behavior and automated tests provide supporting evidence.
      EOT
    }

    architecture_decisions = {
      title     = "Review and resolve initial architecture decisions"
      milestone = "M0"
      labels    = ["Kind:Planning"]

      body = <<-EOT
      ## Objective

      Review the proposed architecture decision records and document decisions that must be settled before implementation.

      ## Tasks

      - Review ADR-002: separation of domain rules from UI and persistence.
      - Review ADR-003: PostgreSQL and Ecto.
      - Review ADR-006: access control before public exposure.
      - Review ADR-007: production infrastructure and observability.
      - Record the context, options, rationale, consequences, and verification evidence for each decision.

      ## Acceptance criteria

      - [x] Decisions required for the initial local implementation are resolved.
      - [x] Unresolved future deployment decisions remain explicitly proposed or deferred.
      - [x] No cloud infrastructure is provisioned as part of this issue.
      - [x] docs/DECISIONS.md reflects the current decision statuses.

      ## Verification evidence

      - `docs/DECISIONS.md` records the accepted application and temporary deployment decisions.
      - Public exposure, multi-node operation, scaling, and full observability remain deferred.
      - Temporary AWS infrastructure was destroyed after deployment verification.
      EOT
    }

    local_workflow = {
      title     = "Document the local development and verification workflow"
      milestone = "M0"
      labels    = ["Kind:Documentation"]

      body = <<-EOT
      ## Objective

      Define how the application will be developed and verified locally before moving into delivery and deployment stages.

      ## Tasks

      - Document the intended local development prerequisites.
      - Identify the commands needed for formatting, compilation, and testing.
      - Document how compatibility experiments and their results will be recorded.
      - Define how GitHub issues and milestone progress will be reflected in local documentation.

      ## Acceptance criteria

      - [x] The workflow is documented in the repository.
      - [x] Required commands are verified where the application/tooling is available.
      - [x] Unverified commands are clearly marked rather than presented as tested.
      - [x] Local documentation remains the version-controlled project record.

      ## Verification evidence

      - Local development and verification procedures are documented in the repository.
      - Formatting, compilation, automated tests, and container workflows were exercised.
      - GitHub milestones and issues are used to track lifecycle progress.
      EOT
    }
  }
}

resource "github_issue" "project" {
  for_each = local.project_issues

  repository = github_repository.project.name
  title      = each.value.title
  body       = each.value.body
  labels     = each.value.labels

  milestone_number = github_repository_milestone.project[
    each.value.milestone
  ].number
}
