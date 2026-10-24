# CAPSERA Database Guide

This directory contains the database initialization instructions, ordered PostgreSQL schema migrations, migration runner, and seed definitions for the **CAPSERA** platform.

---

## Development Database Target

- **Database Engine:** PostgreSQL 18.6+ (Postgres.app / local daemon / cloud PostgreSQL)
- **Node.js Driver:** `pg` (node-postgres with connection pooling via `pg.Pool`)
- **Collation & Encoding:** UTF-8 (`TIMESTAMPTZ` UTC storage)
- **Database Name:** `capsera_db`

---

## Prerequisites & Setup

### 1. Start PostgreSQL
Ensure your local PostgreSQL service is running (e.g. click "Start" on **Postgres.app** or start your system daemon).

### 2. Create Database
If `capsera_db` does not exist:
```bash
# macOS with Postgres.app:
createdb capsera_db

# Or via psql:
psql -U postgres -c "CREATE DATABASE capsera_db;"
```

### 3. Configure Local Credentials
Ensure `server/.env` contains your PostgreSQL connection details:
```env
DB_HOST=localhost
DB_PORT=5432
DB_USER=piyush       # or 'postgres'
DB_PASSWORD=         # blank for default Postgres.app
DB_NAME=capsera_db
DB_SSL=false
```

---

## Running Migrations

CAPSERA uses an automated, transactional migration runner (`database/migrate.js`) backed by the `schema_migrations` tracking table:

```bash
# Run all pending migrations
npm run db:migrate

# Check status of applied and pending migrations
npm run db:status
```

*From the `server/` subdirectory, you can also run `npm run db:migrate`.*

---

## Migration Table Reference

The 19 planned tables are partitioned into 4 transactional migrations:

| Migration | File | Tables Created | Key Integrity Rules |
|---|---|---|---|
| **001** | [`001_identity_and_skills.sql`](migrations/001_identity_and_skills.sql) | `users`, `trainee_profiles`, `trainer_profiles`, `skills`, `trainee_skills`, `trainer_skills` | Unique email, 1:1 user-to-profile, composite uniqueness on user-skills, automatic `updated_at` triggers |
| **002** | [`002_courses_and_learning.sql`](migrations/002_courses_and_learning.sql) | `courses`, `lessons`, `learning_resources`, `enrollments`, `lesson_progress` | Unique `(trainee_id, course_id)` enrollment, composite FK ensuring lesson progress belongs strictly to enrolled course |
| **003** | [`003_assessments_and_feedback.sql`](migrations/003_assessments_and_feedback.sql) | `assessments`, `questions`, `assessment_attempts`, `attempt_answers`, `feedback` | Check constraints on score/rating/options, composite FK ensuring attempt answers belong strictly to the attempt's assessment |
| **004** | [`004_certificates_and_announcements.sql`](migrations/004_certificates_and_announcements.sql) | `certificates`, `announcements`, `audit_logs` | Unique verification code, one certificate per trainee per course, JSONB audit metadata with GIN index (zero credentials logged) |

---

## Migration Safety & Idempotency

- Every migration runs within a PostgreSQL transaction (`BEGIN ... COMMIT`).
- Already applied migrations recorded in `schema_migrations` are safely skipped.
- If a migration encounters an error, the transaction rolls back cleanly without leaving partial tables.
