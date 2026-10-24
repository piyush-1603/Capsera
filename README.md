# CAPSERA

**Digital Capacity Building and Learning Management Portal**

CAPSERA is a responsive web portal for organizational capacity building, built as a student project for Smart India Hackathon 2026 (SIH26075). It centralizes professional profiles, training courses, learning resources, MCQ assessments, progress tracking, feedback, certificates, trainer competency mapping, and administrative oversight.

> **Status:** Repository initialized — shared foundation only. Feature implementation has not started.

---

## Technology Stack

| Layer | Technology |
|---|---|
| Frontend | React + Vite (JavaScript) |
| Routing | React Router |
| HTTP Client | Axios |
| Backend | Node.js + Express |
| Database | PostgreSQL 18.6+ |
| DB Driver | `pg` (node-postgres connection pooling) |
| Testing | Vitest + Supertest |
| Linting | ESLint (flat config) |

---

## Prerequisites

- **Node.js** ≥ 18 (v22 recommended — see `.nvmrc`)
- **npm** ≥ 9
- **PostgreSQL** 18.6+ (Postgres.app, local daemon, or cloud Postgres)

```bash
# If using nvm
nvm use
```

---

## Getting Started

### 1. Clone the repository

```bash
git clone <repository-url> capsera
cd capsera
```

### 2. Install dependencies

```bash
# Install all dependencies (root, client, server)
npm run install:all
```

Or install individually:

```bash
npm install --prefix client
npm install --prefix server
```

### 3. Configure environment variables

```bash
# Server
cp server/.env.example server/.env
# Edit server/.env with your PostgreSQL credentials

# Client
cp client/.env.example client/.env
# Default values work for local development
```

**Required server environment variables:**

| Variable | Description | Default |
|---|---|---|
| `PORT` | Server port | `5000` |
| `NODE_ENV` | Environment | `development` |
| `DB_HOST` | PostgreSQL host | `localhost` |
| `DB_PORT` | PostgreSQL port | `5432` |
| `DB_USER` | PostgreSQL user | `postgres` |
| `DB_PASSWORD` | PostgreSQL password | *(none / empty)* |
| `DB_NAME` | Database name | `capsera_db` |
| `DB_SSL` | Enable SSL (for cloud DBs) | `false` |
| `CORS_ORIGIN` | Allowed frontend origin | `http://localhost:5173` |

**Client environment variables:**

| Variable | Description | Default |
|---|---|---|
| `VITE_API_BASE_URL` | Backend API URL | `http://localhost:5000/api/v1` |

### 4. Create the database & apply migrations

```bash
# 1. Create database if it does not already exist
createdb capsera_db

# 2. Run transactional schema migrations
npm run db:migrate

# 3. (Optional) Check migration status
npm run db:status
```

> **Note:** The server starts even without an active database connection. Database-dependent features will fail clearly with an error message. The health endpoint reports live database connectivity status.

### 5. Start the application

```bash
# Start both frontend and backend
npm run dev

# Or start individually:
npm run dev:server   # Backend on http://localhost:5000
npm run dev:client   # Frontend on http://localhost:5173
```

### 6. Verify the health endpoint

```bash
curl http://localhost:5000/api/v1/health
```

Expected response:

```json
{
  "success": true,
  "data": {
    "status": "ok",
    "timestamp": "2026-10-24T10:00:00.000Z",
    "environment": "development",
    "database": {
      "connected": true
    }
  }
}
```

If PostgreSQL is not running, `database.connected` will be `false` with an error message.

---

## Available Commands

| Command | Description |
|---|---|
| `npm run dev` | Start frontend and backend concurrently |
| `npm run dev:client` | Start frontend dev server (Vite) |
| `npm run dev:server` | Start backend dev server (Node --watch) |
| `npm run build:client` | Build frontend for production |
| `npm run db:migrate` | Run pending PostgreSQL database migrations |
| `npm run db:status` | Check PostgreSQL database migration status |
| `npm test` | Run server tests (Vitest) |
| `npm run lint` | Lint both client and server |
| `npm run lint:fix` | Auto-fix lint issues |
| `npm run install:all` | Install all dependencies |

---

## Project Structure

```text
capsera/
├── client/                     # React + Vite frontend
│   ├── src/
│   │   ├── components/         # Shared UI components
│   │   ├── hooks/              # Custom React hooks
│   │   ├── layouts/            # Page layout wrappers
│   │   ├── pages/              # Route-level page components
│   │   ├── services/           # API client and utilities
│   │   ├── App.jsx             # Root component with routes
│   │   ├── main.jsx            # Entry point
│   │   └── index.css           # Global styles
│   ├── .env.example
│   └── package.json
├── server/                     # Node.js + Express backend
│   ├── src/
│   │   ├── config/             # Environment and database config
│   │   ├── middleware/         # Error handling, not-found
│   │   ├── routes/             # Route registration
│   │   ├── utils/              # Response helpers, AppError
│   │   ├── app.js              # Express application setup
│   │   └── server.js           # Server entry point
│   ├── tests/                  # API tests (Vitest + Supertest)
│   ├── .env.example
│   └── package.json
├── database/
│   ├── migrations/             # SQL migration files
│   └── seeds/                  # Demo/test seed data
├── docs/
│   ├── PRD.md                  # Product Requirements Document
│   ├── DATA_MODEL.md           # Database schema planning
│   ├── API_CONTRACT.md         # API endpoint contracts
│   └── DECISIONS.md            # Technical decisions log
├── .editorconfig
├── .gitignore
├── .nvmrc
├── package.json                # Root workspace scripts
└── README.md
```

---

## Team Conventions

### Naming

| Context | Convention | Examples |
|---|---|---|
| JavaScript variables/functions | `camelCase` | `traineeId`, `createAssessment` |
| React components | `PascalCase` | `CourseCard`, `AssessmentResultPage` |
| SQL tables/columns | `snake_case`, plural tables | `users`, `course_id` |
| JSON fields | `camelCase` | `courseId`, `createdAt` |
| Environment variables | `UPPER_SNAKE_CASE` | `DB_HOST`, `JWT_SECRET` |
| Enum/status values | Uppercase strings | `PENDING`, `PUBLISHED` |

### Canonical Values

- **Roles:** `TRAINEE`, `TRAINER`, `ADMIN`
- **User statuses:** `PENDING`, `ACTIVE`, `REJECTED`, `SUSPENDED`
- **Course statuses:** `DRAFT`, `PUBLISHED`, `ARCHIVED`
- **Assessment statuses:** `DRAFT`, `PUBLISHED`, `CLOSED`
- **Enrollment statuses:** `ACTIVE`, `COMPLETED`, `CANCELLED`
- **Attempt statuses:** `IN_PROGRESS`, `SUBMITTED`, `GRADED`, `EXPIRED`
- **Resource types:** `VIDEO`, `PRESENTATION`, `DOCUMENT`, `LINK`, `OTHER`

### API Conventions

- **Base path:** `/api/v1`
- **Success response:** `{ "success": true, "data": {} }`
- **Error response:** `{ "success": false, "error": { "code": "ERROR_CODE", "message": "..." } }`
- **Pagination:** `page` (default 1), `pageSize` (default 20, max 100)
- **Dates:** ISO 8601 strings, UTC timestamps in database

---

## Git Workflow

1. **`main`** contains the stable integrated application.
2. Each member works on a **feature branch** (e.g., `feature/auth`, `feature/assessments`).
3. Changes enter `main` through **reviewed pull requests**.
4. Shared contracts (API, database migrations, environment variables, common config) must be coordinated.
5. Avoid unnecessary changes to another member's module.

### Branch naming

```
feature/<module>-<description>   # e.g., feature/auth-login
fix/<module>-<description>       # e.g., fix/assessments-scoring
```

---

## Module Ownership

Each member owns an end-to-end module (frontend + backend + database + tests + docs).

| Member | Module | Key Entities |
|---|---|---|
| **Member 1** | Authentication, profiles, account approval, role management | `User`, `TraineeProfile`, `TrainerProfile` |
| **Member 2** | Courses, lessons, learning resources, enrollments, progress | `Course`, `Lesson`, `LearningResource`, `Enrollment`, `LessonProgress` |
| **Member 3** | Assessments, MCQ questions, attempts, scoring, results, feedback | `Assessment`, `Question`, `AssessmentAttempt`, `AttemptAnswer`, `Feedback` |
| **Member 4** | Skills, competency matching, certificates, announcements, dashboard | `Skill`, `TraineeSkill`, `TrainerSkill`, `Certificate`, `Announcement` |

### Where to add your module

**Backend routes** — Add your router to [`server/src/routes/index.js`](server/src/routes/index.js):

```javascript
import assessmentRoutes from '../modules/assessments/assessment.routes.js';
router.use('/assessments', assessmentRoutes);
```

**Backend module** — Create your module under `server/src/modules/<module>/`:

```text
server/src/modules/assessments/
├── assessment.routes.js
├── assessment.controller.js
├── assessment.service.js
└── assessment.validation.js
```

**Frontend pages** — Add routes to [`client/src/App.jsx`](client/src/App.jsx) and create page components in `client/src/pages/`.

**Database migrations** — Add numbered SQL files to `database/migrations/`.

**Tests** — Add test files to `server/tests/`.

---

## Documentation

| Document | Purpose |
|---|---|
| [`docs/PRD.md`](docs/PRD.md) | Product Requirements Document — source of truth |
| [`docs/DATA_MODEL.md`](docs/DATA_MODEL.md) | Database schema planning (finalize before feature work) |
| [`docs/API_CONTRACT.md`](docs/API_CONTRACT.md) | API endpoint contracts (finalize before feature work) |
| [`docs/DECISIONS.md`](docs/DECISIONS.md) | Technical decisions log |

---

## Current Limitations

This repository contains **only the shared foundation**. The following are not yet implemented:

- ❌ Authentication, login, or authorization
- ❌ User management or account approval
- ❌ Course, lesson, or resource management
- ❌ Assessment creation, scoring, or results
- ❌ Progress tracking, feedback, or certificates
- ❌ Trainer matching, announcements, or dashboards
- ❌ Application database tables (schema must be finalized first)
- ❌ Production deployment configuration

## Next Steps

### Before feature implementation (all members)

1. **Finalize `docs/DATA_MODEL.md`** — Agree on exact column types, ON DELETE behavior, and indexes.
2. **Finalize `docs/API_CONTRACT.md`** — Each module owner documents request/response examples for their endpoints.
3. **Resolve pending decisions in `docs/DECISIONS.md`:**
   - DR-009: Validation library
   - DR-011: Authentication mechanism (JWT vs sessions)
   - DR-012: File upload storage provider
   - DR-013: Certificate status model
4. **Create database migrations** for the agreed schema.
5. **Seed the initial Admin account** (Member 1).

### Member-specific first tasks

- **Member 1:** Implement auth middleware, signup/login, user approval API + pages.
- **Member 2:** Implement course CRUD, lesson management, enrollment API + pages.
- **Member 3:** Implement assessment/question creation, attempt lifecycle, scoring API + pages.
- **Member 4:** Implement skill catalogue, trainer matching, certificates, announcements API + pages.

---

*Built for Smart India Hackathon 2026 — SIH26075*
