# Database Seeds

This directory contains seed data for development and demo purposes.

## Guidelines

- Seed files populate the database with synthetic/demo data for testing.
- Never include real personal information in seed files.
- Clearly label all seed data as demo/test data.
- Seeds should be idempotent — running them multiple times should not create duplicates.
- The admin seed creates the initial Admin account (there is no public admin signup).

## Planned Seeds

- `001_admin_user.sql` — Creates the initial admin account (Member 1 will implement after auth is ready).
- `002_skills.sql` — Populates the skill catalogue (Member 4).
- `003_demo_data.sql` — Demo courses, users, and assessments for presentation.

## Running Seeds

```bash
mysql -u root -p capsera_db < database/seeds/001_admin_user.sql
```
