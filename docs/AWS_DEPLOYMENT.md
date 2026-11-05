# AWS Deployment and Verification

## 1. Overview

Hologram BeamOps Kanban was deployed to Amazon Web Services (AWS) using Terraform and Docker Compose.

The deployment validates that the application can run in a cloud environment using a single EC2 instance, with PostgreSQL hosted locally in a Docker container.

The deployment was intended for temporary validation and was not designed as a permanent production infrastructure.

## 2. AWS Architecture

| Component | Configuration |
|---|---|
| Cloud provider | Amazon Web Services |
| Region | Asia Pacific (Sydney), `ap-southeast-2` |
| Availability Zone | `ap-southeast-2a` |
| Compute | Amazon EC2 |
| Instance type | `t3.small` |
| Operating system | Amazon Linux 2023 |
| Container runtime | Docker Engine |
| Container orchestration | Docker Compose |
| Application | Hologram BeamOps Kanban |
| Application image | GitHub Container Registry (GHCR) |
| Database | PostgreSQL 18.6 |
| Persistent storage | Docker named volume |
| Root storage | 20 GB encrypted gp3 EBS |
| Infrastructure management | Terraform |

The existing default VPC and subnet were reused. No additional VPC, NAT gateway, load balancer, or managed database service was created.

## 3. Network and Security Configuration

- SSH access was restricted to the developer's public IPv4 address using a `/32` CIDR rule.
- The application was bound to `127.0.0.1:4000` on the EC2 host.
- Browser access was provided through an SSH local port-forwarding tunnel.
- No application port was exposed directly to the public internet.
- EC2 Instance Metadata Service Version 2 (IMDSv2) was required.
- The root EBS volume was encrypted and configured for deletion when the instance terminates.
- The EC2 instance used standard CPU credit mode.

## 4. Container Deployment

The application image was retrieved from the private GitHub Container Registry package:

`ghcr.io/pasamrevanthkumar/hologram-beamops-kanban:latest`

The image was pulled using a GitHub Personal Access Token with `read:packages` permission.

After pulling, the image was locally tagged as:

`hologram-beamops-kanban:verified`

The existing Docker Compose configuration was reused without modifying the application deployment architecture.

The Compose services were:

- `db`: PostgreSQL database.
- `migrate`: One-time database migration.
- `app`: Hologram application.

The application depended on successful database health checks and migration completion.

## 5. Environment Configuration

Production environment variables were generated directly on the EC2 instance.

The `.env.docker` file contained the database credentials, `DATABASE_URL`, `SECRET_KEY_BASE`, Phoenix endpoint configuration, and connection pool settings.

The file was restricted to the EC2 user using filesystem permissions `600`.

Secrets and environment files were not committed to Git.

## 6. Deployment Verification

The following checks were completed successfully:

| Verification | Result |
|---|---|
| EC2 instance creation | Passed |
| SSH connectivity | Passed |
| Docker installation | Passed |
| Docker Compose installation | Passed |
| Private GHCR authentication | Passed |
| Application image retrieval | Passed |
| PostgreSQL startup and health check | Passed |
| Database migrations | Passed |
| Hologram application startup | Passed |
| Application health endpoint | HTTP 200 |
| Browser access through SSH tunnel | Passed |
| Kanban interface functionality | Passed |

The database migration successfully created the boards, columns, and tasks tables.

The application health endpoint was checked at:

`/hologram/ping`

The endpoint returned HTTP 200.

## 7. Database Persistence Verification

Database persistence was tested by removing and recreating the Docker Compose containers.

The following commands were executed:

```bash
docker compose -f ~/compose.yaml --env-file ~/.env.docker down

docker compose -f ~/compose.yaml --env-file ~/.env.docker up -d
```

The `-v` option was deliberately omitted from the `down` command to preserve the PostgreSQL named volume.

After the containers were recreated:

- PostgreSQL returned to a healthy state.
- Database migrations completed successfully.
- The Hologram application started successfully.
- Previously created Kanban boards and tasks remained available.

The persistence test passed.

## 8. Infrastructure Management

AWS infrastructure was provisioned using Terraform from:

`terraform/aws-deployment/`

The Terraform configuration managed:

- EC2 instance.
- EC2 key pair.
- EC2 security group.

The default VPC and subnet were referenced as existing resources rather than recreated.

Terraform state, state backups, and saved plans were excluded from version control.

## 9. Teardown

The AWS deployment was temporary. After completing the deployment and verification activities, the infrastructure was scheduled for destruction using Terraform.

The teardown removes the Terraform-managed EC2 instance, security group, and key pair. The root EBS volume is configured for deletion on instance termination.

The Docker named volume and application data on the EC2 host are also removed when the instance and its root storage are destroyed.

The GitHub repository, application source code, published GHCR image, Terraform configuration, and deployment documentation remain available independently of the AWS infrastructure.

## 10. Outcome

The project successfully demonstrated the deployment and operation of a Hologram-based Elixir application on AWS.

The deployment validated container image distribution, cloud compute provisioning, database initialization, application startup, browser access, and persistent database storage.

The temporary infrastructure approach allowed the complete cloud deployment lifecycle to be demonstrated without maintaining unnecessary AWS resources.
