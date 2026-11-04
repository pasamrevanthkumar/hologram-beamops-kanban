# PostgreSQL Database Backup and Recovery

This document records the PostgreSQL database architecture, backup procedure, restoration procedure, and the backup-and-recovery exercise performed for the Hologram BeamOps Kanban application.

The purpose of this runbook is to provide a repeatable process for creating database backups and verifying that those backups can be restored successfully.

## 1. Current Database Architecture

The application uses PostgreSQL as its database.

The database runs as a Docker Compose service alongside the application.

| Item | Value |
|---|---|
| Application | Hologram BeamOps Kanban |
| Database | PostgreSQL |
| PostgreSQL version | 18.6 |
| Compose service | `db` |
| Database name | `hologram_beamops_kanban` |
| Database role | `kanban` |
| Docker volume | `hologram_beamops_kanban_postgres_data` |
| Container data directory | `/var/lib/postgresql` |
| Compose environment file | `.env.docker` |

The PostgreSQL database uses a Docker named volume for persistent storage.

The named volume allows database data to survive container recreation. However, a Docker volume alone is not a backup. If the volume is accidentally deleted, corrupted, or otherwise becomes unavailable, the database may be lost.

For this reason, independent database backups are maintained outside the Docker volume.

## 2. Backup Location and Security

Database backups are stored on the host machine in:

```text
~/db-backups/hologram_beamops_kanban/
```

The backup directory is separate from the application repository.

This separation helps prevent database backups from being accidentally committed to Git.

### Directory permissions

The backup directories should only be accessible by the current user.

Create the directory if it does not already exist:

```bash
mkdir -p ~/db-backups/hologram_beamops_kanban
```

Set restrictive permissions:

```bash
chmod 700 ~/db-backups
chmod 700 ~/db-backups/hologram_beamops_kanban
```

Backup files should have permissions of `600`:

```bash
chmod 600 ~/db-backups/hologram_beamops_kanban/*.dump
```

This ensures that only the file owner can read and write the backup files.

### Important security considerations

- Never commit database backups to Git.
- Never store database passwords or application secrets in backup documentation.
- Keep backup files outside the application repository.
- Restrict access to backup directories and files.
- For production, maintain backups independently of the application server and database host.
- Consider encrypted off-site or cloud backups for disaster recovery.

## 3. Create a Database Backup

PostgreSQL provides `pg_dump` for creating logical database backups.

We use the custom archive format (`-Fc`) because it supports selective restoration and inspection through `pg_restore`.

### Step 1: Define the backup filename

Create a timestamped backup filename:

```bash
BACKUP_FILE="$HOME/db-backups/hologram_beamops_kanban/kanban-$(date +%Y%m%d-%H%M%S).dump"
```

### Step 2: Create the backup

Run:

```bash
docker compose --env-file .env.docker exec -T db pg_dump -U kanban -d hologram_beamops_kanban -Fc > "$BACKUP_FILE"
```

This command:

- Executes `pg_dump` inside the running PostgreSQL container.
- Connects to the `hologram_beamops_kanban` database.
- Uses the `kanban` database role.
- Creates a custom-format PostgreSQL archive.
- Redirects the resulting archive to a file on the host machine.

### Step 3: Restrict backup permissions

```bash
chmod 600 "$BACKUP_FILE"
```

### Step 4: Verify the backup file

```bash
ls -lh "$BACKUP_FILE"
```

Verify the file type:

```bash
file "$BACKUP_FILE"
```

### Step 5: Generate a SHA-256 checksum

```bash
sha256sum "$BACKUP_FILE"
```

The checksum can later be used to verify that the backup file has not changed or become corrupted.

## 4. Inspect a Backup

PostgreSQL provides `pg_restore` to inspect and restore custom-format archives.

Before attempting restoration, inspect the archive contents.

Run:

```bash
docker compose --env-file .env.docker exec -T db pg_restore --list < "$BACKUP_FILE"
```

This displays the archive's table of contents.

The archive should contain the database objects and data required for restoration, including:

- Tables
- Table data
- Sequences
- Sequence values
- Default values
- Primary keys
- Indexes
- Foreign-key constraints

Inspecting the archive provides an initial check that the backup is readable and contains the expected database objects.

A successful archive listing does not, by itself, prove that the database can be restored successfully. A restoration exercise is required to verify that.

## 5. Restore into a Separate Test Database

A backup should be tested by restoring it into a separate database.

Never use the original application database as the target for a recovery test.

For this exercise, the temporary database is:

```text
kanban_restore_test
```

### Step 1: Create the temporary database

Run:

```bash
docker compose --env-file .env.docker exec db psql -U kanban -d postgres -c "CREATE DATABASE kanban_restore_test;"
```

### Step 2: Restore the backup

Run:

```bash
docker compose --env-file .env.docker exec -T db pg_restore -U kanban -d kanban_restore_test --clean --if-exists --no-owner --no-privileges < "$BACKUP_FILE"
```

Explanation:

- `-U kanban`: Connect using the `kanban` database role.
- `-d kanban_restore_test`: Restore into the temporary test database.
- `--clean`: Drop existing objects before recreating them.
- `--if-exists`: Avoid errors when objects do not already exist.
- `--no-owner`: Do not restore original object ownership.
- `--no-privileges`: Do not restore original access privileges.

The `--clean` option is appropriate for this disposable test database. Always verify the target database name before running a restoration command.

## 6. Verify the Restored Database

A successful `pg_restore` command is not enough. We must verify that the restored database contains the expected objects and data.

### Step 1: Verify the tables

Run:

```bash
docker compose --env-file .env.docker exec db psql -U kanban -d kanban_restore_test -c "\dt"
```

The restored database should contain these four tables:

- `boards`
- `columns`
- `schema_migrations`
- `tasks`

### Step 2: Verify row counts

Run:

```bash
docker compose --env-file .env.docker exec db psql -U kanban -d kanban_restore_test -c "SELECT 'boards' AS table_name, COUNT(*) FROM boards UNION ALL SELECT 'columns', COUNT(*) FROM columns UNION ALL SELECT 'tasks', COUNT(*) FROM tasks UNION ALL SELECT 'schema_migrations', COUNT(*) FROM schema_migrations;"
```

The expected results from our backup and recovery exercise were:

| Table | Restored rows |
|---|---:|
| boards | 2 |
| columns | 6 |
| tasks | 6 |
| schema_migrations | 1 |

The row counts matched the original database at the time of the backup.

### Step 3: Verify the database size

Run:

```bash
docker compose --env-file .env.docker exec db psql -U kanban -d kanban_restore_test -c "SELECT pg_size_pretty(pg_database_size('kanban_restore_test'));"
```

This provides an additional check that the restored database contains data.

## 7. Remove the Temporary Restore Database

After verifying the restoration, remove the temporary database.

Run:

```bash
docker compose --env-file .env.docker exec db psql -U kanban -d postgres -c "DROP DATABASE kanban_restore_test;"
```

Verify that it no longer exists:

```bash
docker compose --env-file .env.docker exec db psql -U kanban -d postgres -c "SELECT datname FROM pg_database WHERE datname = 'kanban_restore_test';"
```

The query should return no rows.

This cleanup ensures that the temporary restoration database does not remain unnecessarily on the development system.

The original application database remains untouched.

## 8. Verified Backup and Recovery Exercise

The following records document the backup and restoration exercise completed for this project.

### Backup details

| Item | Recorded value |
|---|---|
| Backup file | `kanban-20261104-105836.dump` |
| Backup format | PostgreSQL custom archive |
| PostgreSQL version | 18.6 |
| Approximate file size | 11 KB |
| Archive format version | 1.16-0 |
| Compression | gzip |
| Database | `hologram_beamops_kanban` |
| Backup directory | `~/db-backups/hologram_beamops_kanban/` |

### SHA-256 checksum

```text
feb5e6b78e7812086a51f11d44e561dce4b7925d0a1451889e3c8f48615c4ff2
```

### Archive inspection

The backup archive was inspected using `pg_restore --list`.

The archive listing succeeded and showed 34 TOC entries, including:

- Four tables
- Table data
- Sequences and sequence values
- Default values
- Primary keys
- Indexes
- Foreign-key constraints

### Restoration verification

The backup was restored into the separate temporary database:

```text
kanban_restore_test
```

The restoration completed successfully.

The restored database contained all four expected tables.

The verified row counts were:

| Table | Rows |
|---|---:|
| boards | 2 |
| columns | 6 |
| tasks | 6 |
| schema_migrations | 1 |

The temporary database was subsequently dropped and its absence was verified.

### Final status

The backup and recovery exercise was successfully repeated.

The original application database was not modified by the restoration test.

The application and PostgreSQL containers were both healthy after the exercise.

The backup file and its checksum remained available in the host backup directory.

This exercise demonstrated that the project can create a PostgreSQL logical backup, inspect its archive, restore it into a separate database, and verify the restored data.

## 9. Recovery Limitations and Production Requirements

The completed exercise verifies the logical backup and restoration process in the local Docker environment.

However, this is not yet a complete production disaster-recovery strategy.

Several additional requirements must be considered before deploying the application to AWS.

### 9.1 Independent backup storage

The current backup directory resides on the development machine.

If the machine or its storage device is lost, the backups stored on it may also be lost.

For production, backups should be stored independently of the database host.

An object-storage service such as Amazon S3 can provide durable off-host backup storage.

### 9.2 Automated backups

The current process is manual.

Production systems should use an automated backup schedule.

The schedule should be determined by:

- How much data the application can afford to lose.
- How quickly the application must recover.
- Database size and growth.
- Backup storage cost.
- Retention requirements.

### 9.3 Backup retention

Production backups should have a defined retention policy.

For example, a policy could retain:

- Daily backups for a defined number of days.
- Weekly backups for a defined number of weeks.
- Monthly backups for a defined number of months.

The actual retention periods should be chosen according to business and recovery requirements.

### 9.4 Recovery Point Objective (RPO)

RPO defines the maximum acceptable amount of data loss measured in time.

For example, an RPO of one hour means the recovery strategy should allow recovery to a point no more than one hour before the failure.

A periodic logical backup alone may not satisfy a strict RPO.

Continuous archiving or point-in-time recovery may be required.

### 9.5 Recovery Time Objective (RTO)

RTO defines the maximum acceptable time required to restore service after a failure.

The restoration process should be tested to determine how long recovery actually takes.

A backup is useful only if it can be restored within the required recovery window.

### 9.6 Encryption

Production backups should be encrypted at rest and protected while being transferred.

Encryption keys and credentials must be managed securely.

Database credentials, application secrets, and encryption keys should never be committed to the Git repository.

### 9.7 Monitoring and alerting

Production backup automation should report:

- Whether the backup completed successfully.
- Whether the backup failed.
- Backup file size.
- Backup age.
- Storage availability.
- Whether the backup can be inspected.
- Whether periodic restoration tests succeed.

A backup process that silently fails is not a reliable backup strategy.

### 9.8 Regular restoration tests

Production recovery procedures should be tested periodically.

A successful backup job does not guarantee a successful restoration.

Restoration tests should verify:

- Database objects.
- Table data.
- Row counts or application-level data integrity.
- Database migrations.
- Application connectivity.
- Application functionality after recovery.

### 9.9 AWS deployment considerations

During the AWS deployment milestone, we will evaluate an appropriate production database and backup architecture.

Potential AWS services and concepts to study include:

- Amazon RDS for managed PostgreSQL.
- Amazon S3 for independent backup storage.
- IAM policies for access control.
- AWS KMS for encryption-key management.
- CloudWatch for monitoring and alerting.
- Automated backup retention.
- Point-in-time recovery.
- Infrastructure as Code for reproducible infrastructure.

The final architecture will depend on cost, operational complexity, reliability requirements, and the AWS services selected for the project.

No AWS resources are created as part of this local backup and recovery exercise.

---

**Milestone outcome:** PostgreSQL backup creation, archive inspection, restoration into a separate test database, data verification, and temporary database cleanup have all been successfully exercised locally. This runbook records the process and provides a foundation for implementing a production-grade backup and recovery strategy during the AWS deployment phase.
