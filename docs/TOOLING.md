# Tool Inventory

Tools will be selected and version-pinned when their stage begins.
Read the official documentation before implementation.

| Area | Tool | Purpose |
|---|---|---|
| Language/runtime | Elixir and Erlang/OTP | Application and BEAM runtime |
| Web framework | Hologram | Web application UI and framework |
| Database | PostgreSQL and Ecto | Persistent application data |
| Version control | Git | Source history and collaboration |
| Repository hosting | GitHub | Issues, milestones, source, and CI |
| Testing | ExUnit | Automated tests |
| Packaging | Mix releases | Self-contained application releases |
| Containers | Docker | Reproducible application images |
| Local orchestration | Docker Compose | Multi-service development |
| Infrastructure as code | Terraform | Provision and manage infrastructure |
| Machine images | Packer | Automated machine-image creation, if applicable |
| Cloud | AWS | Production infrastructure |
| Continuous integration | GitHub Actions | Automated validation |
| Secret management | SOPS and Docker secrets | Protect and supply deployment secrets |
| Distributed runtime | Erlang distribution and libcluster | Cluster formation and discovery, as appropriate |
| Logging | Grafana Loki stack or suitable alternatives | Centralized logs |
| Metrics | PromEx and Prometheus-compatible tooling | Application and runtime metrics |
| Dashboards and alerts | Grafana | Operational visibility and alerting |

## Selection policy

The table is a preliminary inventory based on the book's lifecycle.
Verify compatibility with Hologram and the chosen deployment architecture
before adopting any Phoenix-specific tooling or configuration.
