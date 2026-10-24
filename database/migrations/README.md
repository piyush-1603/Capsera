# Database Migrations

This directory contains the ordered SQL migration files for CAPSERA.

## Migration Sequence

Apply the migration scripts in sequential order against the `capsera_db` database:

1. `001_identity_and_skills.sql` — Users, profiles (trainee/trainer), skills, and user-skill associations.
2. `002_courses_and_learning.sql` — Courses, lessons, learning resources, enrollments, and lesson progress.
3. `003_assessments_and_feedback.sql` — Assessments, questions, attempts, answers, and course feedback.
4. `004_certificates_and_announcements.sql` — Certificates, announcements, and administrative audit logs.

## Running Migrations

Execute each migration against `capsera_db`:

```bash
mysql -u root -p capsera_db < database/migrations/001_identity_and_skills.sql
mysql -u root -p capsera_db < database/migrations/002_courses_and_learning.sql
mysql -u root -p capsera_db < database/migrations/003_assessments_and_feedback.sql
mysql -u root -p capsera_db < database/migrations/004_certificates_and_announcements.sql
```

## Guidelines

- All tables use `InnoDB` engine and `utf8mb4` character set with `utf8mb4_unicode_ci` collation.
- All migrations are idempotent (`CREATE TABLE IF NOT EXISTS`).
- Never modify a migration that has already been applied in a shared environment.
- Primary keys use `INT UNSIGNED AUTO_INCREMENT` (`BIGINT UNSIGNED` for `audit_logs`).
- Foreign keys strictly enforce relational integrity and composite validity rules.
