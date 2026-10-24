# CAPSERA — API Contract

> [!IMPORTANT]
> **This is a planning document.** It captures the intended API surface derived from the Product Requirements Document (PRD §11). All endpoints described here are **proposed** and must be reviewed and finalized by each module owner before implementation begins. Request/response body schemas for individual feature endpoints will be defined by the respective module owner.

---

## 1. Response Envelope Formats

All API responses follow a consistent envelope structure.

### 1.1 Success Response

```json
{
  "success": true,
  "data": { ... }
}
```

### 1.2 Error Response

```json
{
  "success": false,
  "error": {
    "message": "Human-readable error description",
    "code": "ERROR_CODE"
  }
}
```

### 1.3 Paginated Response

```json
{
  "success": true,
  "data": [ ... ],
  "pagination": {
    "page": 1,
    "pageSize": 20,
    "totalItems": 142,
    "totalPages": 8
  }
}
```

---

## 2. HTTP Status Conventions

| Status Code | Meaning                    | When to Use                                                    |
|-------------|----------------------------|----------------------------------------------------------------|
| `200`       | OK                         | Successful GET, PUT/PATCH, or action endpoint                  |
| `201`       | Created                    | Successful POST that creates a new resource                    |
| `204`       | No Content                 | Successful DELETE with no response body                        |
| `400`       | Bad Request                | Validation errors, malformed input                             |
| `401`       | Unauthorized               | Missing or invalid authentication token                        |
| `403`       | Forbidden                  | Authenticated user lacks the required role or ownership        |
| `404`       | Not Found                  | Resource does not exist                                        |
| `409`       | Conflict                   | Duplicate resource (e.g., email already registered, already enrolled) |
| `422`       | Unprocessable Entity       | Semantically invalid request (e.g., publishing a course with no lessons) |
| `500`       | Internal Server Error      | Unexpected server failure                                      |

---

## 3. Common Conventions

| Convention       | Value                                                                 |
|------------------|-----------------------------------------------------------------------|
| **Base Path**    | `/api` (all endpoints below are relative to this prefix)              |
| **Auth Mechanism** | JWT Bearer token in `Authorization` header                          |
| **Date Format**  | ISO 8601 (`2025-01-15T09:30:00.000Z`)                               |
| **Pagination — page** | Query param `page`, default `1`                                 |
| **Pagination — pageSize** | Query param `pageSize`, default `20`, max `100`             |

---

## 4. Endpoint Map by Module Ownership

### 4.1 Member 1 — Auth & User Management

#### Authentication

| Method | Path                            | Auth | Roles         | Description                        |
|--------|---------------------------------|------|---------------|------------------------------------|
| POST   | `/auth/signup`                  | No   | —             | Register a new user account        |
| POST   | `/auth/login`                   | No   | —             | Authenticate and receive JWT       |
| POST   | `/auth/logout`                  | Yes  | Any           | Invalidate current session/token   |
| GET    | `/auth/me`                      | Yes  | Any           | Get the authenticated user's info  |

#### Admin — User Administration

| Method | Path                            | Auth | Roles   | Description                              |
|--------|---------------------------------|------|---------|------------------------------------------|
| GET    | `/admin/users`                  | Yes  | ADMIN   | List all users (paginated, filterable)   |
| PATCH  | `/admin/users/:userId/status`   | Yes  | ADMIN   | Update a user's account status           |
| PATCH  | `/admin/users/:userId/role`     | Yes  | ADMIN   | Update a user's role                     |

#### Profiles

| Method | Path                            | Auth | Roles           | Description                              |
|--------|---------------------------------|------|-----------------|------------------------------------------|
| GET    | `/profiles/me`                  | Yes  | Any             | Get own profile                          |
| PUT    | `/profiles/me/trainee`          | Yes  | TRAINEE         | Create or update own trainee profile     |
| PUT    | `/profiles/me/trainer`          | Yes  | TRAINER         | Create or update own trainer profile     |

---

### 4.2 Member 2 — Courses & Learning

#### Courses

| Method | Path                                    | Auth | Roles           | Description                                |
|--------|-----------------------------------------|------|-----------------|--------------------------------------------|
| POST   | `/courses`                              | Yes  | TRAINER         | Create a new course                        |
| GET    | `/courses`                              | Yes  | Any             | List courses (paginated, filterable)       |
| GET    | `/courses/:courseId`                     | Yes  | Any             | Get course details                         |
| PUT    | `/courses/:courseId`                     | Yes  | TRAINER (owner) | Update course details                      |
| DELETE | `/courses/:courseId`                     | Yes  | TRAINER (owner) | Delete a course                            |
| PATCH  | `/courses/:courseId/publish`             | Yes  | TRAINER (owner) | Publish or archive a course                |

#### Lessons

| Method | Path                                    | Auth | Roles           | Description                                |
|--------|-----------------------------------------|------|-----------------|--------------------------------------------|
| POST   | `/courses/:courseId/lessons`             | Yes  | TRAINER (owner) | Add a lesson to a course                   |
| GET    | `/courses/:courseId/lessons`             | Yes  | Any             | List lessons for a course (ordered)        |
| GET    | `/lessons/:lessonId`                    | Yes  | Any             | Get a single lesson                        |
| PUT    | `/lessons/:lessonId`                    | Yes  | TRAINER (owner) | Update a lesson                            |
| DELETE | `/lessons/:lessonId`                    | Yes  | TRAINER (owner) | Delete a lesson                            |

#### Learning Resources

| Method | Path                                    | Auth | Roles           | Description                                |
|--------|-----------------------------------------|------|-----------------|--------------------------------------------|
| POST   | `/courses/:courseId/resources`           | Yes  | TRAINER (owner) | Add a learning resource                    |
| GET    | `/courses/:courseId/resources`           | Yes  | Any             | List resources for a course                |
| DELETE | `/courses/:courseId/resources/:resourceId` | Yes | TRAINER (owner) | Delete a resource                         |

#### Enrollments & Progress

| Method | Path                                    | Auth | Roles           | Description                                |
|--------|-----------------------------------------|------|-----------------|--------------------------------------------|
| POST   | `/courses/:courseId/enrollments`         | Yes  | TRAINEE         | Enroll in a course                         |
| GET    | `/courses/:courseId/enrollments`         | Yes  | TRAINER (owner) | List enrollments for a course              |
| GET    | `/enrollments/me`                       | Yes  | TRAINEE         | List own enrollments                       |
| POST   | `/enrollments/:enrollmentId/progress`   | Yes  | TRAINEE (owner) | Mark a lesson as completed                 |
| GET    | `/enrollments/:enrollmentId/progress`   | Yes  | TRAINEE (owner) | Get lesson progress for an enrollment      |

---

### 4.3 Member 3 — Assessments & Feedback

#### Assessments

| Method | Path                                        | Auth | Roles           | Description                                |
|--------|---------------------------------------------|------|-----------------|--------------------------------------------|
| POST   | `/courses/:courseId/assessments`             | Yes  | TRAINER (owner) | Create an assessment for a course          |
| GET    | `/courses/:courseId/assessments`             | Yes  | Any             | List assessments for a course              |
| GET    | `/assessments/:assessmentId`                | Yes  | Any             | Get assessment details                     |
| PUT    | `/assessments/:assessmentId`                | Yes  | TRAINER (owner) | Update an assessment                       |
| DELETE | `/assessments/:assessmentId`                | Yes  | TRAINER (owner) | Delete an assessment                       |
| PATCH  | `/assessments/:assessmentId/publish`        | Yes  | TRAINER (owner) | Publish or close an assessment             |

#### Questions

| Method | Path                                        | Auth | Roles           | Description                                |
|--------|---------------------------------------------|------|-----------------|--------------------------------------------|
| POST   | `/assessments/:assessmentId/questions`      | Yes  | TRAINER (owner) | Add a question to an assessment            |
| GET    | `/assessments/:assessmentId/questions`      | Yes  | Varies          | List questions for an assessment           |
| PUT    | `/assessments/:assessmentId/questions/:questionId` | Yes | TRAINER (owner) | Update a question                    |
| DELETE | `/assessments/:assessmentId/questions/:questionId` | Yes | TRAINER (owner) | Delete a question                    |

#### Attempts

| Method | Path                                        | Auth | Roles           | Description                                |
|--------|---------------------------------------------|------|-----------------|--------------------------------------------|
| POST   | `/assessments/:assessmentId/attempts`       | Yes  | TRAINEE         | Start a new attempt                        |
| POST   | `/attempts/:attemptId/submit`               | Yes  | TRAINEE (owner) | Submit an attempt for grading              |
| GET    | `/attempts/me`                              | Yes  | TRAINEE         | List own attempts across assessments       |

#### Results & Feedback

| Method | Path                                        | Auth | Roles           | Description                                |
|--------|---------------------------------------------|------|-----------------|--------------------------------------------|
| GET    | `/courses/:courseId/results`                | Yes  | TRAINER (owner) | Get aggregated assessment results          |
| POST   | `/courses/:courseId/feedback`               | Yes  | TRAINEE         | Submit feedback for a course               |
| GET    | `/courses/:courseId/feedback`               | Yes  | Any             | List feedback for a course (paginated)     |
| PUT    | `/courses/:courseId/feedback`               | Yes  | TRAINEE (owner) | Update own feedback                        |
| DELETE | `/courses/:courseId/feedback`               | Yes  | TRAINEE (owner) | Delete own feedback                        |

---

### 4.4 Member 4 — Competency & Admin Features

#### Skills Catalog

| Method | Path                                        | Auth | Roles   | Description                                |
|--------|---------------------------------------------|------|---------|--------------------------------------------|
| GET    | `/skills`                                   | Yes  | Any     | List all skills (paginated, filterable)    |
| POST   | `/skills`                                   | Yes  | ADMIN   | Create a new skill                         |
| PUT    | `/skills/:skillId`                          | Yes  | ADMIN   | Update a skill                             |
| DELETE | `/skills/:skillId`                          | Yes  | ADMIN   | Delete a skill                             |

#### User Skills

| Method | Path                                        | Auth | Roles   | Description                                |
|--------|---------------------------------------------|------|---------|--------------------------------------------|
| GET    | `/profiles/me/skills`                       | Yes  | TRAINEE | List own skills                            |
| POST   | `/profiles/me/skills`                       | Yes  | TRAINEE | Add a skill to own profile                 |
| DELETE | `/profiles/me/skills/:skillId`              | Yes  | TRAINEE | Remove a skill from own profile            |
| GET    | `/profiles/me/trainer-skills`               | Yes  | TRAINER | List own trainer skills                    |
| POST   | `/profiles/me/trainer-skills`               | Yes  | TRAINER | Add a skill to own trainer profile         |
| DELETE | `/profiles/me/trainer-skills/:skillId`      | Yes  | TRAINER | Remove a skill from own trainer profile    |

#### Trainer Recommendations

| Method | Path                                        | Auth | Roles   | Description                                |
|--------|---------------------------------------------|------|---------|--------------------------------------------|
| GET    | `/trainers/recommendations`                | Yes  | TRAINEE | Get recommended trainers based on skills   |

#### Certificates

| Method | Path                                        | Auth | Roles   | Description                                |
|--------|---------------------------------------------|------|---------|--------------------------------------------|
| GET    | `/certificates/me`                          | Yes  | TRAINEE | List own certificates                      |
| GET    | `/certificates/verify/:certificateCode`     | No   | —       | Publicly verify a certificate by code      |

#### Announcements

| Method | Path                                        | Auth | Roles   | Description                                |
|--------|---------------------------------------------|------|---------|--------------------------------------------|
| POST   | `/announcements`                            | Yes  | ADMIN   | Create an announcement                     |
| GET    | `/announcements`                            | Yes  | Any     | List announcements (paginated)             |
| GET    | `/announcements/:announcementId`            | Yes  | Any     | Get a single announcement                  |
| PUT    | `/announcements/:announcementId`            | Yes  | ADMIN   | Update an announcement                     |
| DELETE | `/announcements/:announcementId`            | Yes  | ADMIN   | Delete an announcement                     |

#### Admin Dashboard

| Method | Path                                        | Auth | Roles   | Description                                |
|--------|---------------------------------------------|------|---------|--------------------------------------------|
| GET    | `/admin/dashboard/summary`                  | Yes  | ADMIN   | Platform summary statistics                |
| GET    | `/admin/dashboard/assessment-performance`   | Yes  | ADMIN   | Aggregated assessment performance metrics  |

---

## 5. Contracts to Define Before Implementation

> [!NOTE]
> The endpoint map above establishes the URL structure and role boundaries. Before any module owner begins coding, the following must be documented for **every endpoint they own**:

| Item                        | What to Document                                                      |
|-----------------------------|-----------------------------------------------------------------------|
| **Request body schema**     | Required and optional fields, types, and validation rules             |
| **Response body example**   | Exact JSON shape returned inside the `data` envelope                  |
| **Validation rules**        | Field lengths, formats, allowed values, and business rules            |
| **Error codes**             | Module-specific error codes returned in `error.code`                  |
| **Ownership checks**        | Which endpoints verify that the authenticated user owns the resource  |
| **Query parameters**        | Available filters, sort options, and search fields for list endpoints |
| **State transitions**       | Valid status transitions (e.g., DRAFT → PUBLISHED → ARCHIVED)        |

Each module owner should add their detailed contracts as a separate document or section before writing any route handlers.
