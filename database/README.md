# CAPSERA Database Guide

This directory contains the database initialization script, schema migrations, and seed data definitions for the **CAPSERA** platform.

---

## Prerequisites

- **MySQL Server:** Version 8.0.16 or higher (InnoDB engine, UTF-8 `utf8mb4_unicode_ci` collation).
- **Client Tool:** `mysql` CLI client or GUI client (e.g., MySQL Workbench, DBeaver).

---

## Setup & Migration Workflow

To set up the database locally, execute the setup script followed by the migrations in exact numeric order:

### Step 1: Create Database

Run [`001_initial_setup.sql`](001_initial_setup.sql) to create `capsera_db` if it does not already exist:

```bash
mysql -u root -p < database/001_initial_setup.sql
```

### Step 2: Apply Schema Migrations in Order

Apply each numbered migration file in [`database/migrations/`](migrations/):

```bash
# 1. Identity, User Profiles & Skills (users, trainee_profiles, trainer_profiles, skills, trainee_skills, trainer_skills)
mysql -u root -p capsera_db < database/migrations/001_identity_and_skills.sql

# 2. Courses, Lessons, Resources, Enrollments & Progress (courses, lessons, learning_resources, enrollments, lesson_progress)
mysql -u root -p capsera_db < database/migrations/002_courses_and_learning.sql

# 3. Assessments, Questions, Attempts, Answers & Feedback (assessments, questions, assessment_attempts, attempt_answers, feedback)
mysql -u root -p capsera_db < database/migrations/003_assessments_and_feedback.sql

# 4. Certificates, Announcements & Audit Logs (certificates, announcements, audit_logs)
mysql -u root -p capsera_db < database/migrations/004_certificates_and_announcements.sql
```

Or apply all migrations in a single command on Linux/macOS:

```bash
for file in database/migrations/*.sql; do
  echo "Applying $file..."
  mysql -u root -p capsera_db < "$file"
done
```

---

## Migration Table Reference

| Migration | File | Tables Created | Key Integrity Rules |
|---|---|---|---|
| **001** | [`001_identity_and_skills.sql`](migrations/001_identity_and_skills.sql) | `users`, `trainee_profiles`, `trainer_profiles`, `skills`, `trainee_skills`, `trainer_skills` | Unique email, unique skill names, 1:1 user-to-profile, composite uniqueness on user-skills |
| **002** | [`002_courses_and_learning.sql`](migrations/002_courses_and_learning.sql) | `courses`, `lessons`, `learning_resources`, `enrollments`, `lesson_progress` | Unique `(trainee_id, course_id)` enrollment, composite FK ensuring lesson progress belongs strictly to enrolled course |
| **003** | [`003_assessments_and_feedback.sql`](migrations/003_assessments_and_feedback.sql) | `assessments`, `questions`, `assessment_attempts`, `attempt_answers`, `feedback` | Check constraints on score/rating/options, composite FK ensuring attempt answers belong strictly to the attempt's assessment |
| **004** | [`004_certificates_and_announcements.sql`](migrations/004_certificates_and_announcements.sql) | `certificates`, `announcements`, `audit_logs` | Unique verification code, one certificate per trainee per course, JSON audit metadata (zero credentials logged) |

---

## Rollback Guidelines

Each migration file includes a rollback summary comment. In development, rollbacks drop child tables prior to parent tables:

- **004 Rollback:** `audit_logs` → `announcements` → `certificates`
- **003 Rollback:** `feedback` → `attempt_answers` → `assessment_attempts` → `questions` → `assessments`
- **002 Rollback:** `lesson_progress` → `enrollments` → `learning_resources` → `lessons` → `courses`
- **001 Rollback:** `trainer_skills` → `trainee_skills` → `skills` → `trainer_profiles` → `trainee_profiles` → `users`
