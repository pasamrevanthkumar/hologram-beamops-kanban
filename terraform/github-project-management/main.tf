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
