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
      description = "Finalize scope, requirements, architecture, decisions, toolchain compatibility, documentation inventory, and GitHub project setup."
    }
    M1 = {
      title       = "M1 - Working Kanban application"
      description = "Build the Hologram-based Kanban application with task operations, persistence, migrations, tests, and updated documentation."
    }
    M2 = {
      title       = "M2 - CI and packaging"
      description = "Add continuous integration, formatting and test checks, an OTP release, Docker packaging, runtime configuration, and startup verification."
    }
    M3 = {
      title       = "M3 - Local operations"
      description = "Configure local operations, Docker Compose, database readiness, health checks, persistence, and an appropriate local Docker Swarm exercise."
    }
    M4 = {
      title       = "M4 - AWS infrastructure and deployment"
      description = "Evaluate costs and architecture, manage AWS infrastructure with Terraform, assess Packer where justified, deploy, verify, and document cleanup."
    }
    M5 = {
      title       = "M5 - Delivery and distributed operation"
      description = "Implement deployment and rollback workflows, secret management, multi-node operation, Erlang distribution, service discovery, health checks, and scaling evaluation."
    }
    M6 = {
      title       = "M6 - Observability"
      description = "Add structured logs, metrics, suitable custom metrics, Grafana dashboards, alerting, and operational validation."
    }
    M7 = {
      title       = "M7 - Final validation and cleanup"
      description = "Verify the complete lifecycle, review documentation and decisions, inventory resources, clean up billable infrastructure, and record lessons learned."
    }
  }
}

resource "github_repository_milestone" "project" {
  for_each = local.milestones

  owner       = "pasamrevanthkumar"
  repository  = github_repository.project.name
  title       = each.value.title
  description = each.value.description
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

      - [ ] Compatible versions and constraints are documented.
      - [ ] Official documentation references are recorded.
      - [ ] Unsupported or uncertain integrations are clearly identified.
      - [ ] Findings are committed to the project documentation.
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

      - [ ] References are recorded in the repository.
      - [ ] Tool versions and unresolved version choices are distinguished.
      - [ ] Documentation needed for later milestones is discoverable.
      - [ ] No compatibility claim is made without supporting evidence.
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

      - [ ] Architecture decisions are supported by documentation or experiments.
      - [ ] Confirmed components and proposed components are distinguished.
      - [ ] Open technical questions are recorded.
      - [ ] docs/ARCHITECTURE.md reflects the reviewed architecture.
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

      - [ ] Decisions required for the initial local implementation are resolved.
      - [ ] Unresolved future deployment decisions remain explicitly proposed.
      - [ ] No cloud infrastructure is provisioned as part of this issue.
      - [ ] docs/DECISIONS.md reflects the current decision statuses.
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

      - [ ] The workflow is documented in the repository.
      - [ ] Required commands are verified where the application/tooling is available.
      - [ ] Unverified commands are clearly marked rather than presented as tested.
      - [ ] Local documentation remains the version-controlled project record.
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
