# CAPSERA — Product Requirements Document (PRD)

**Document status:** Finalized MVP baseline  
**Version:** 1.0  
**Prepared:** 24 October 2026  
**Product:** CAPSERA — Digital Capacity Building and Learning Management Portal  
**Repository:** capsera  
**Problem statement:** Smart India Hackathon 2026, SIH26075  
**Primary context:** Ministry of Earth Sciences (MoES) / India Meteorological Department (IMD), Smart Education  
**Team:** Four members  
**Target delivery:** 2–4 weeks  
**Technology:** React + Vite, Node.js + Express, PostgreSQL (18.6+)

This PRD is the single source of truth for product scope, behaviour, naming, acceptance criteria, API conventions, and team boundaries. Implementation details may be refined only through an agreed change to this document or a linked technical decision record.

---

## 1. Executive Summary

CAPSERA is a responsive web portal for organizational capacity building. It centralizes professional profiles, training courses, learning resources, MCQ assessments, progress tracking, feedback, certificates, trainer competency mapping, and basic administrative oversight.

The product addresses a common organizational problem: training information, learning resources, participation, assessment results, and trainer expertise are often spread across separate tools or spreadsheets. CAPSERA connects those activities in one workflow and makes training participation and competency evidence easier to manage.

The MVP is deliberately competency-led rather than just a course catalogue. Users record skills and expertise; trainees discover suitable courses and trainers; training activity and assessment results are recorded; and the platform updates course progress and certificate eligibility.

The project is a student-built SIH solution, not an official government system. The MVP must not claim government approval, official certification authority, AI-powered matching, proctoring, or production-grade compliance certification unless those capabilities are separately implemented and validated.

## 2. Problem Statement and Context

The SIH26075 problem statement invites a centralized web-based platform for organizational training, competency development, and knowledge sharing. Its required capabilities include secure signup/login with Trainee, Trainer, and Admin roles; trainee profiles; course enrollment and learning resources; subject-wise MCQ assessments; feedback; trainer questionnaires and deadlines; trainer libraries; admin approval and role management; dashboards; homepage announcements; and competency-based trainer identification.

CAPSERA addresses these requirements through a role-based learning lifecycle:

1. Establish a trusted user identity and profile.
2. Define and discover courses, lessons, resources, skills, and trainer expertise.
3. Enroll trainees and record learning activity.
4. Assess learning with subject-wise MCQs and store results.
5. Track completion and issue a basic certificate when eligibility rules are met.
6. Give trainers and admins a consistent view of participation, outcomes, and competency matches.

## 3. Product Goals

### 3.1 Goals for the MVP

- Provide a single responsive web application for trainees, trainers, and admins.
- Enforce server-side authentication, approval status, and role-based permissions.
- Let trainers create and publish courses, lessons, and learning resources.
- Let active trainees enroll in published courses and access permitted content.
- Support deadline-aware MCQ assessments with server-side scoring and persisted attempts.
- Track lesson completion, course progress, and assessment results.
- Match trainers to subjects/skills using an explainable, deterministic rule.
- Provide basic admin oversight of users, courses, enrollments, assessments, certificates, and announcements.
- Deliver an end-to-end demo using a real PostgreSQL database, not only mock data or localStorage.
- Keep ownership and naming consistent across four parallel contributors.

### 3.2 Success Criteria

The MVP is considered successful when all of the following are demonstrated:

- A new trainee can register, remain pending, and log in only after approval.
- An admin can approve accounts and assign allowed roles without allowing public self-assignment of Admin.
- A trainer can create and publish a course containing lessons and resources.
- A trainee can discover that course, enroll once, access allowed lessons/resources, and mark lessons complete.
- A trainee can attempt an assessment; the backend computes the score and stores the attempt and answers.
- The trainer who owns the course and an admin can view authorized result summaries; other trainees cannot.
- Progress and certificate eligibility follow the documented rules consistently.
- Trainer matching returns relevant trainers and explains why each was recommended.
- Admin counts and homepage announcements reflect database records.
- Core journeys work on mobile and desktop, and critical permission tests pass.
- No numerical performance or impact claims should be made without measured evidence.

## 4. Users and Roles

### 4.1 Trainee

A learner who completes a professional profile, declares skills and interests, discovers courses and trainers, enrolls in courses, studies resources, attempts assessments, reviews results, tracks progress, submits feedback, and views eligible certificates.

### 4.2 Trainer

A subject-matter expert who maintains an expertise profile, maps skills to a standard skill catalogue, creates courses and lessons, uploads learning resources, creates MCQ assessments with deadlines and attempt rules, and monitors participation and results for their own courses.

### 4.3 Admin

A platform administrator who approves accounts, assigns or changes roles, manages user status, oversees courses, views platform-wide summary metrics, publishes homepage announcements, manages the skill catalogue, and handles certificate/admin oversight.

### 4.4 Public Visitor

A non-authenticated visitor can see the public landing page and published homepage announcements, and can open signup/login pages. Public visitors cannot access course materials, user profiles, results, dashboards, or private resources.

## 5. MVP Scope

### 5.1 Included

- Authentication and role-based access.
- Admin approval of new accounts and role management.
- Trainee and trainer professional profiles.
- Skills catalogue and trainee/trainer skill mapping.
- Course creation, editing, publishing, discovery, and enrollment.
- Lessons and learning resource library (recorded lectures, presentations, documents, links).
- MCQ assessment creation, deadlines, attempts, server-side scoring, and stored results.
- Lesson completion and course progress tracking.
- Course feedback.
- Explainable skill-based trainer matching.
- Basic admin dashboard and summary statistics.
- Homepage announcements and achievements.
- Basic completion certificates with unique identifiers.
- Responsive layout, error states, validation, access controls, and integration tests.
- Deployment of the web app and database if the team's environment and timeline permit.

### 5.2 Explicitly Deferred

- Email/SMS/push notification service and notification inbox.
- AI-generated questions, adaptive testing, or ML-based recommendations.
- Proctored exams, camera monitoring, anti-cheat surveillance, device fingerprinting, or fullscreen enforcement.
- Advanced analytics, predictive skill-gap models, organizational heatmaps, and CSV/PDF reporting exports.
- Complex learning paths, course prerequisites, cohorts, calendars, live video conferencing, chat, discussion forums, and peer review.
- External LMS integrations or government identity systems.
- Native mobile applications and guaranteed offline learning.
- Multi-tenant organizational hierarchy, department-level workflows, and enterprise SSO.
- Cryptographic/tamper-proof certificates or claims of official accreditation.
- Payment, monetization, or public marketplace functionality.

These may be future enhancements, but must not be silently pulled into the MVP.

## 6. Core Behaviour Decisions

These decisions are the agreed defaults for the first release.

### 6.1 Registration, Approval, and Login

- Signup supports requesting a Trainee or Trainer account.
- All newly registered accounts start with status `PENDING`.
- Public signup must never accept `ADMIN` as a requested role. The backend validates the requested role against the allowed signup choices.
- An Admin account is provisioned through a deliberate seed/deployment process; there is no public admin signup.
- An admin approves or rejects pending users. The admin can change a user's role where permitted and can suspend/reactivate an account.
- Pending, rejected, or suspended accounts cannot access protected application functions.
- Passwords are hashed using a modern password-hashing library; plaintext passwords are never stored or logged.
- Login errors do not reveal whether an email address exists.
- Logout invalidates/clears the session according to the chosen auth implementation.
- The MVP includes profile editing and a basic password recovery approach. If email delivery cannot be configured in the student environment, recovery is handled by an admin-controlled reset process and documented as a demo limitation.
- Every protected API enforces authentication and authorization on the server, not only in the frontend.

### 6.2 Course Lifecycle

- Trainers can create and edit their own courses in `DRAFT`.
- Trainers can publish their own courses after required fields are complete.
- Admins can review, unpublish, archive, or manage any course.
- Only `PUBLISHED` courses appear in the trainee course catalogue.
- A published course has a title, description/summary, subject, level, trainer, status, and optional thumbnail.
- Each course may contain ordered lessons and resources.
- Trainers may edit their own courses; users cannot modify another trainer's course unless they are Admin.
- Archiving is preferred over hard deletion after a course has enrollments, attempts, or certificates.

### 6.3 Enrollment

- Active trainees can enroll directly in published courses.
- Enrollment is unique per trainee and course. Duplicate enrollment is rejected or returns the existing enrollment consistently; the implementation must choose one behaviour and test it.
- Trainers and admins can view enrollment records for reporting, but cannot impersonate trainees.
- Trainees can view only their own enrollments and progress.
- A trainee may cancel an enrollment only if no business rule or completed record prevents it; completed learning history should be preserved.

### 6.4 Lessons and Resources

- Lessons are ordered within a course.
- Trainers upload or link recorded lectures, presentations, PDFs/documents, and other approved study resources.
- Store uploaded files in a suitable storage service; store metadata and access references in MySQL. Large media binaries should not be stored in relational rows.
- Validate file size, allowed type, and upload permission on the server.
- Resource access follows course visibility and enrollment rules. A raw storage URL must not accidentally expose restricted content.
- For the MVP, trainees explicitly mark a lesson complete. The server validates that the lesson belongs to a course in which the trainee is enrolled.
- A completion event is persisted and updates course progress.

### 6.5 Assessment Lifecycle

- A trainer creates an assessment within a course they own.
- An assessment includes title, instructions, question set, optional deadline, optional duration, maximum attempts, pass threshold, and status.
- Questions are four-option MCQs with one correct option, optional explanation, and points.
- Only published assessments are available to eligible trainees.
- A trainee must be enrolled in the associated course and have an active account.
- The default maximum is one attempt unless the trainer configures more. The backend enforces attempt limits.
- The deadline is optional; if set, the backend checks it at attempt creation and submission.
- The backend owns scoring. The client must not submit a trusted score, pass flag, or correctness value.
- Correct answers and answer-key metadata are not returned in the initial trainee assessment payload.
- After submission, the trainee sees their score, percentage, pass/fail status, and permitted review information.
- Each attempt and answer is stored with timestamps. Submission must be idempotent or reject a second submission consistently.
- Scoring and persistence occur in a database transaction to avoid partial results.
- Trainers can view attempts and aggregate results only for courses they own; Admins can view platform-wide results. Trainees can view only their own attempts.
- No proctoring or anti-cheat surveillance is included in the MVP.

### 6.6 Progress and Course Completion

- Lesson progress is recorded per enrollment and lesson.
- Course progress percentage is calculated from the number of completed lessons divided by the total number of lessons. If a course has no lessons, progress is 0%, not 100%.
- A course is complete when all lessons are complete and, if the course has a required published assessment, the trainee has passed it.
- If the course has no required assessment, completion is based on all lessons being completed.
- Assessment attempts and lesson progress remain separate evidence; an assessment pass alone does not imply course completion.
- Progress is derived from database records, not trusted from a client-provided percentage.

### 6.7 Certificates

- Basic certificates are issued when the completion rule above is met.
- Each certificate has a unique certificate code, trainee, course, issue date, and status.
- Duplicate certificates for the same trainee/course are prevented.
- A simple verification page may confirm whether a code exists and is valid, exposing only minimal public information.
- The MVP certificate is a platform-issued completion record, not a government-accredited or cryptographically tamper-proof credential.
- If time is tight, a basic certificate view and unique code are required; polished PDF design is secondary.

### 6.8 Competency Mapping and Trainer Recommendations

- Skills are selected from an Admin-managed canonical skill catalogue; free-text interests can coexist but are not treated as normalized skills.
- Trainees can record skill proficiency and interests. Trainers can record expertise, proficiency, and years of experience.
- The recommendation engine is deterministic and explainable; no AI/ML service is required.
- Given a selected skill or subject, return active, approved trainers with matching mapped skills.
- Recommended MVP ranking:
  1. Exact skill match.
  2. Higher declared proficiency.
  3. More relevant experience.
- The response should explain matching factors, such as "matches Python; advanced proficiency; 3 years' experience."
- If no match exists, show an explicit empty state and allow the trainee to browse all published courses.
- The matching result is a recommendation, not a guarantee of trainer quality or a validated competency assessment.
- Skill-gap analysis may be shown as a simple comparison only when a target proficiency is explicitly defined. Do not invent an organizational competency score.

### 6.9 Course Feedback

- Enrolled trainees can submit a 1–5 star course rating and optional comment.
- One current feedback record per trainee/course is allowed; the trainee may edit it.
- Trainers can view feedback for courses they own; Admins can view platform-wide feedback.
- Validate and limit comment length. Do not expose a trainee's private profile fields in feedback reports.

### 6.10 Homepage Announcements

- Admins can create, edit, publish, and archive announcements, achievements, and newly added learning content posts.
- Only published, non-expired announcements appear publicly on the homepage.
- Announcement fields include title, body, category, status, publication time, optional expiry, and creator.
- This is a homepage content feed, not a real-time notification system. Notification inboxes, email alerts, and push alerts are deferred.

### 6.11 Admin Dashboard

The MVP dashboard provides database-backed counts for:

- Users by role and approval status.
- Published/draft courses.
- Enrollments and completions.
- Assessments and attempts.
- Certificates issued.
- Participation and assessment outcome summaries.

Dashboard counts must come from the database, not hard-coded demo numbers. Advanced trend charts, exports, cohort analytics, and predictive analysis are future scope. A few simple charts are optional if core flows are stable.

## 7. Functional Requirements and Acceptance Criteria

Priority definitions: **P0** = must work for MVP; **P1** = included if core P0 flow is stable; **P2** = future scope.

| ID | Requirement | Priority | Acceptance Criteria |
|---|---|---|---|
| FR-01 | Account registration and login | P0 | Users can register with name, email, password, and requested Trainee/Trainer role. Email is unique; password policy and field validation are enforced server-side. New accounts are `PENDING`. Active approved users can log in and log out. A pending account cannot access a protected route even if the frontend is manipulated. |
| FR-02 | Approval and role management | P0 | Admin can list/filter pending users, approve/reject them, suspend/reactivate users, and assign permitted roles. Public users cannot create or promote an Admin account. An API call without Admin permission receives `403`; changes persist after refresh. |
| FR-03 | Profile management | P0 | Trainee profile supports qualifications, work experience, interests, skills, certificates, biography, and organization/headline fields. Trainer profile supports qualifications, work experience, subject expertise, skills, years of experience, biography, and organization/headline. Users can edit only their own profile; Admin access is governed by explicit permissions. |
| FR-04 | Skill catalogue and mapping | P0 | Admin manages skill names/categories. Trainees map skills and proficiency; trainers map expertise and proficiency. Duplicate skill mapping is prevented; recommendation query returns only approved active trainers. |
| FR-05 | Course management | P0 | Trainer creates, edits, publishes, and archives their own courses. Admin can manage all courses. Drafts are not visible in the trainee catalogue; ownership is validated by the backend. |
| FR-06 | Lessons and resources | P0 | Trainer manages ordered lessons and attaches supported resources. Trainee accesses resources only when entitled. Unauthorized users cannot retrieve restricted resource metadata or download URLs. |
| FR-07 | Enrollment | P0 | Trainee enrolls in a published course and sees it in "My Learning." Duplicate enrollment cannot create duplicate records; trainee cannot access another trainee's enrollment. |
| FR-08 | Assessment creation and attempt | P0 | Trainer creates questions and assessment settings; trainee attempts a published assessment. Server enforces enrollment, deadlines, attempt limits, and scoring. Tampering with client-side score/correctness fields does not affect the stored result. |
| FR-09 | Results and progress | P0 | Trainee sees own result and progress; course owner/Admin sees permitted reports. Lesson completion and assessment pass update course completion and certificate eligibility according to rules. |
| FR-10 | Feedback | P1 | Enrolled trainee submits or edits a course rating/comment. Rating outside 1–5 is rejected; duplicate records are handled through edit/upsert semantics. |
| FR-11 | Certificates | P1 | Eligible trainee receives a basic certificate record with unique code. Certificate cannot be issued before eligibility and duplicate issuance is prevented. |
| FR-12 | Announcements | P1 | Admin publishes homepage announcements and achievements. Drafts and expired items are not shown to public visitors. |
| FR-13 | Trainer matching | P0 | Trainee or Admin searches by skill/subject and sees explainable matches. Deterministic ordering is stable for equivalent data and empty results are handled. |
| FR-14 | Admin dashboard | P0 | Admin views current counts and simple summaries. Numbers agree with seeded/test database records and are not hard-coded. |
| FR-15 | Responsive and accessible UI | P0 | Primary flows work at mobile, tablet, and desktop widths. Forms have labels, validation feedback, keyboard access, visible focus, meaningful empty/error/loading states. No essential action requires hover-only interaction or a desktop-only layout. |

## 8. Non-Functional Requirements

### 8.1 Security

- Hash passwords using bcrypt or Argon2; never log passwords, tokens, secrets, or sensitive assessment answers.
- Use parameterized SQL queries and validate request bodies, path parameters, and query parameters.
- Enforce role and ownership checks in the backend on every protected operation.
- Use HTTPS in deployment and secure HttpOnly cookies or an equivalently secure, consistently implemented authentication design.
- If cookie-based authentication is used, configure CSRF protections for state-changing requests, strict CORS, SameSite cookie policy, and allowed origins.
- Apply login rate limiting, security headers, request size limits, and generic authentication errors before public deployment.
- Store secrets in environment variables; commit only `.env.example`.
- Validate uploads by size and allowed MIME/type; prevent executable uploads and path traversal.
- Do not expose correct MCQ answers before submission or another permitted review point.
- Record audit events for admin approval, role changes, suspension, and certificate issuance.
- Avoid collecting unnecessary personal data.

### 8.2 Privacy

- Trainees see their own profile, enrollments, attempts, and certificates.
- Trainers see learner records only where needed for courses they own.
- Admins have broader access for platform administration.
- Public certificate verification returns minimal data.
- Use synthetic/demo data in presentations; do not commit real personal information.

### 8.3 Reliability and Data Integrity

- PostgreSQL is the source of truth for user, course, enrollment, assessment, progress, feedback, and certificate records.
- Use foreign keys, unique constraints, and indexes for integrity.
- Use transactions for assessment submission/scoring and certificate issuance where multiple writes must succeed together.
- Use consistent UTC timestamps in persistence and ISO 8601 timestamps in API responses.
- Prefer archive/status fields to hard deletion when historical records depend on a record.

### 8.4 Performance and Scalability

- Paginate list endpoints that may grow.
- Index email, foreign keys, course status/subject, enrollment lookups, attempt history, and dashboard filters as justified by queries.
- Do not introduce Redis, message queues, microservices, or video transcoding for the MVP without a demonstrated need.
- Keep uploaded media in file/object storage rather than PostgreSQL.

### 8.5 Accessibility and Usability

- Responsive layouts for mobile, tablet, and desktop.
- Semantic headings, form labels, keyboard navigation, visible focus, readable contrast, and error messages associated with inputs.
- Do not rely on color alone to convey status.
- Use clear language for pending approvals, deadlines, attempt limits, scores, and completion rules.

## 9. Technical Architecture

### 9.1 Approved Stack

- **Frontend:** React + Vite, JavaScript.
- **Routing:** React Router.
- **HTTP client:** Axios or `fetch`; team must standardize on one client.
- **Backend:** Node.js + Express, JavaScript.
- **Database:** PostgreSQL 18.6+.
- **SQL access:** `pg` (node-postgres) with connection pooling and parameterized queries (see DR-002).
- **Validation:** Use one agreed schema validation library or shared validation helpers.
- **File storage:** A cloud/object storage provider for deployed uploads; local storage may be used only for development if documented.
- **Testing:** API integration tests plus frontend critical-flow tests; exact test libraries are a team decision recorded before implementation.
- **Deployment:** Static frontend hosting plus Node API hosting and managed PostgreSQL, depending on free-tier availability.

### 9.2 Architecture

```
Browser (React/Vite) → REST API (Node/Express) → PostgreSQL
```

The browser must not connect directly to PostgreSQL. The API is responsible for authentication, authorization, validation, business rules, database transactions, and response formatting.

### 9.3 Proposed Repository Layout

```text
capsera/
├── client/
│   └── src/
│       ├── app/
│       ├── components/
│       ├── features/
│       │   ├── auth/
│       │   ├── profiles/
│       │   ├── courses/
│       │   ├── assessments/
│       │   ├── competency/
│       │   └── admin/
│       ├── layouts/
│       ├── services/
│       ├── hooks/
│       └── styles/
├── server/
│   └── src/
│       ├── config/
│       ├── middleware/
│       ├── modules/
│       │   ├── auth/
│       │   ├── users/
│       │   ├── profiles/
│       │   ├── courses/
│       │   ├── enrollments/
│       │   ├── assessments/
│       │   ├── competency/
│       │   ├── feedback/
│       │   ├── certificates/
│       │   ├── announcements/
│       │   └── admin/
│       ├── shared/
│       └── app.js
├── database/
│   ├── migrations/
│   └── seeds/
├── docs/
│   ├── PRD.md
│   ├── API_CONTRACT.md
│   ├── DATA_MODEL.md
│   └── DECISIONS.md
├── .env.example
├── .gitignore
└── README.md
```

This is the canonical proposed layout. The team may simplify it, but all members must use one agreed structure.

## 10. Canonical Naming Registry

These names are mandatory unless the team approves a documented change.

### 10.1 Product and Environment

| Item | Value |
|---|---|
| Product name | `CAPSERA` |
| Git repository | `capsera` |
| Database name | `capsera_db` |
| Frontend directory | `client` |
| Backend directory | `server` |
| API prefix | `/api/v1` |

### 10.2 Language and Naming Rules

| Context | Convention | Examples |
|---|---|---|
| JavaScript variables/functions | `camelCase` | `traineeId`, `courseId`, `createAssessment` |
| React components/class names | `PascalCase` | `CourseCard`, `AssessmentResultPage` |
| SQL tables and columns | `snake_case`, plural table names | `users`, `course_id`, `created_at` |
| JSON request/response fields | `camelCase` | `courseId`, `createdAt` |
| Environment variables/constants | `UPPER_SNAKE_CASE` | `DB_HOST`, `JWT_SECRET` |
| Enum/status values | Uppercase strings | `PENDING`, `PUBLISHED` |

Do not create synonyms for an existing canonical field. For example, use `traineeId`, not `studentId`, `learnerId`, and `userTraineeId` interchangeably.

### 10.3 Canonical Roles and Statuses

**Roles:** `TRAINEE`, `TRAINER`, `ADMIN`

**User statuses:** `PENDING`, `ACTIVE`, `REJECTED`, `SUSPENDED`

**Course statuses:** `DRAFT`, `PUBLISHED`, `ARCHIVED`

**Assessment statuses:** `DRAFT`, `PUBLISHED`, `CLOSED`

**Enrollment statuses:** `ACTIVE`, `COMPLETED`, `CANCELLED`

**Attempt statuses:** `IN_PROGRESS`, `SUBMITTED`, `GRADED`, `EXPIRED`

**Resource types:** `VIDEO`, `PRESENTATION`, `DOCUMENT`, `LINK`, `OTHER`

Certificate statuses should be represented by `issued_at` and nullable `revoked_at`, or by one explicitly standardized status field. Do not mix both models without a decision record.

### 10.4 Canonical Domain Entities

| Entity | SQL Table |
|---|---|
| `User` | `users` |
| `TraineeProfile` | `trainee_profiles` |
| `TrainerProfile` | `trainer_profiles` |
| `Skill` | `skills` |
| `TraineeSkill` | `trainee_skills` |
| `TrainerSkill` | `trainer_skills` |
| `Course` | `courses` |
| `Lesson` | `lessons` |
| `LearningResource` | `learning_resources` |
| `Enrollment` | `enrollments` |
| `LessonProgress` | `lesson_progress` |
| `Assessment` | `assessments` |
| `Question` | `questions` |
| `AssessmentAttempt` | `assessment_attempts` |
| `AttemptAnswer` | `attempt_answers` |
| `Feedback` | `feedback` |
| `Certificate` | `certificates` |
| `Announcement` | `announcements` |

All members must use these names in documentation and API discussions.

## 11. Shared API Conventions

### 11.1 General Rules

- Base path: `/api/v1`.
- REST resources use plural nouns and consistent HTTP verbs.
- JSON is the default request/response format.
- API field names use `camelCase`.
- IDs are generated by the database and never trusted from public signup payloads for ownership or role.
- List endpoints use consistent pagination: `page` (default 1), `pageSize` (default 20, maximum 100).
- Dates are ISO 8601 strings in responses; all persisted timestamps are treated consistently as UTC.
- All non-public endpoints require active authentication and server-side role/ownership checks.

### 11.2 Response Envelopes

**Success:**
```json
{
  "success": true,
  "data": {}
}
```

**Error:**
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "A human-readable message"
  }
}
```

**Paginated list:**
```json
{
  "success": true,
  "data": {
    "items": [],
    "pagination": {
      "page": 1,
      "pageSize": 20,
      "totalItems": 0,
      "totalPages": 0
    }
  }
}
```

### 11.3 HTTP Status Conventions

| Status | Meaning |
|---|---|
| `200` | Successful read/update/action |
| `201` | Created |
| `204` | Successful deletion/archive (no body) |
| `400` | Validation error |
| `401` | Missing/invalid authentication |
| `403` | Authenticated but forbidden or account inactive |
| `404` | Resource not found |
| `409` | Duplicate/conflicting operation |
| `413` | Upload too large |
| `415` | Unsupported media type |
| `429` | Rate limited |
| `500` | Unexpected server error (no internal secrets exposed) |

### 11.4 Canonical Endpoint Map

**Auth and account administration:**

| Method | Endpoint | Notes |
|---|---|---|
| `POST` | `/api/v1/auth/signup` | |
| `POST` | `/api/v1/auth/login` | |
| `POST` | `/api/v1/auth/logout` | |
| `GET` | `/api/v1/auth/me` | |
| `GET` | `/api/v1/admin/users` | |
| `PATCH` | `/api/v1/admin/users/:userId/status` | |
| `PATCH` | `/api/v1/admin/users/:userId/role` | |

**Profiles and skills:**

| Method | Endpoint | Notes |
|---|---|---|
| `GET` | `/api/v1/profiles/me` | |
| `PUT` | `/api/v1/profiles/me/trainee` | |
| `PUT` | `/api/v1/profiles/me/trainer` | |
| `GET` | `/api/v1/skills` | |
| `POST` | `/api/v1/skills` | Admin |
| `PUT` | `/api/v1/profiles/me/skills` | |
| `PUT` | `/api/v1/profiles/me/trainer-skills` | |
| `GET` | `/api/v1/trainers/recommendations?skillId=:skillId` | |

**Courses and learning:**

| Method | Endpoint | Notes |
|---|---|---|
| `GET` | `/api/v1/courses` | |
| `POST` | `/api/v1/courses` | |
| `GET` | `/api/v1/courses/:courseId` | |
| `PATCH` | `/api/v1/courses/:courseId` | |
| `POST` | `/api/v1/courses/:courseId/publish` | |
| `POST` | `/api/v1/courses/:courseId/lessons` | |
| `PATCH` | `/api/v1/lessons/:lessonId` | |
| `POST` | `/api/v1/courses/:courseId/resources` | |
| `GET` | `/api/v1/courses/:courseId/resources` | |
| `POST` | `/api/v1/courses/:courseId/enrollments` | |
| `GET` | `/api/v1/enrollments/me` | |
| `PATCH` | `/api/v1/enrollments/:enrollmentId/progress` | |

**Assessments and feedback:**

| Method | Endpoint | Notes |
|---|---|---|
| `POST` | `/api/v1/courses/:courseId/assessments` | |
| `POST` | `/api/v1/assessments/:assessmentId/questions` | |
| `POST` | `/api/v1/assessments/:assessmentId/publish` | |
| `GET` | `/api/v1/assessments/:assessmentId` | |
| `POST` | `/api/v1/assessments/:assessmentId/attempts` | |
| `POST` | `/api/v1/attempts/:attemptId/submit` | |
| `GET` | `/api/v1/attempts/me` | |
| `GET` | `/api/v1/courses/:courseId/results` | |
| `POST` | `/api/v1/courses/:courseId/feedback` | |
| `GET` | `/api/v1/courses/:courseId/feedback` | |

**Certificates, announcements, and admin:**

| Method | Endpoint | Notes |
|---|---|---|
| `GET` | `/api/v1/certificates/me` | |
| `GET` | `/api/v1/certificates/verify/:certificateCode` | |
| `GET` | `/api/v1/announcements` | |
| `POST` | `/api/v1/announcements` | Admin |
| `PATCH` | `/api/v1/announcements/:announcementId` | Admin |
| `GET` | `/api/v1/admin/dashboard/summary` | |
| `GET` | `/api/v1/admin/dashboard/assessment-performance` | |

This endpoint map is the shared contract target. Exact request fields, response examples, ownership rules, and error cases must be documented in `API_CONTRACT.md` before each module is implemented. Do not add alternate endpoints for the same operation without agreement.

## 12. Conceptual Data Model

The exact schema will be documented in `DATA_MODEL.md` and implemented as versioned migrations. The PRD requires these relationships:

- `users` has one optional trainee profile or trainer profile, depending on role.
- `users` (trainer) has many `courses`.
- `courses` has many `lessons`, `learning_resources`, and `assessments`.
- `users` (trainee) and `courses` are many-to-many through `enrollments`.
- `enrollments` has lesson completion records through `lesson_progress`.
- `assessments` has many `questions` and many `assessment_attempts`.
- `assessment_attempts` has answer rows through `attempt_answers`.
- `users` and `skills` are many-to-many through `trainee_skills` and `trainer_skills`.
- `feedback` links one trainee to one course; one current feedback record per trainee/course.
- `certificates` link a trainee and course, with a unique verification code.
- `announcements` reference their Admin creator.

**Integrity requirements:**

- Unique user email.
- Unique `(trainee_id, course_id)` enrollment.
- Unique `(assessment_id, trainee_id, attempt_number)` attempt.
- Unique `(trainee_id, course_id)` feedback and certificate where the MVP allows one each.
- Unique skill names and certificate codes.
- Foreign keys and indexes on relationship/filter columns.
- Database transactions for assessment submission and certificate issuance.
- Soft archive/status fields for important records with historical dependencies.

## 13. Four-Member Work Allocation

The goal is balanced end-to-end ownership, not four disconnected codebases. Every member is responsible for their module's UI, API integration, database operations, validation, tests, and documentation.

### Member 1 — Identity, Profiles, and User Governance

- Signup/login/logout/current user.
- Authentication and authorization middleware.
- Trainee/trainer profiles.
- Admin approval, role/status management.
- Owns canonical `User`, `TraineeProfile`, `TrainerProfile` contracts.
- Shared responsibility for security review.

### Member 2 — Courses and Learning Resources

- Course CRUD, publish/archive.
- Lessons and resource library/upload metadata.
- Course discovery, enrollment, lesson progress API integration.
- Owns `Course`, `Lesson`, `LearningResource`, `Enrollment`, `LessonProgress` implementation.
- Shared responsibility for end-to-end learning-flow testing.

### Member 3 — Assessments, Results, Progress, and Feedback

- Assessment creation/settings and MCQ question management.
- Attempt lifecycle, scoring, result review, attempt history.
- Progress rule integration and feedback.
- Owns `Assessment`, `Question`, `AssessmentAttempt`, `AttemptAnswer`, `Feedback` implementation.
- Shared responsibility for transactional integrity and assessment security tests.

### Member 4 — Competency, Certificates, Announcements, and Dashboard

- Skill catalogue and trainee/trainer skill mapping.
- Explainable trainer recommendation logic.
- Basic certificate issuance/verification.
- Homepage announcements and admin summary metrics.
- Owns `Skill`, `TraineeSkill`, `TrainerSkill`, `Certificate`, `Announcement`, dashboard queries.
- Shared responsibility for system-level integration and demo readiness.

### Equal-Work Policy

- All four members implement frontend + backend + database work in their owned module.
- All four write tests and review at least one teammate's pull request per milestone.
- Member 4 is not solely responsible for all integration, documentation, or deployment; tasks are shared and tracked.
- Rebalance if estimated effort diverges materially. A module owner is responsible for its contract, not allowed to change shared conventions unilaterally.

## 14. Suggested Delivery Plan (2–4 Weeks)

This is a target schedule, not a guarantee. It assumes all four members work consistently and use AI-assisted coding while reviewing and testing generated changes.

### Week 1 — Align and Build the Vertical Slice

- Finalize this PRD and API/data contracts.
- Establish repository conventions, environment examples, migrations, seeds, linting, and test commands.
- Implement authentication, role guards, and user approval.
- Build a thin end-to-end path: trainer creates/publishes course → trainee enrolls → lesson completion persists.

### Week 2 — Assessments and Core Modules

- Implement assessment/question creation, attempt submission, server-side scoring, and results.
- Connect progress calculation and certificate eligibility.
- Implement skill mapping and basic trainer recommendations.
- Integrate feedback and initial admin metrics.

### Week 3 — Complete Admin and Polish (if available)

- Announcements and certificate verification.
- Complete profile and resource upload flows.
- Add empty/loading/error states, responsive refinements, and demo seed data.
- Run cross-role permission tests and end-to-end tests.

### Week 4 — Stabilize and Present (if available)

- Fix integration bugs, deploy, verify environment configuration and database migrations.
- Prepare user journeys, screenshots, demo script, architecture/data-flow diagrams, and limitations.
- Freeze feature scope; only critical bug fixes after freeze.

For a strict two-week deadline, defer polished PDF certificates, charts, password-reset email automation, and any optional visual enhancements before compromising authentication, scoring integrity, or the end-to-end learning flow.

## 15. Testing and Definition of Done

A feature is "done" only when:

- The UI works for its intended role.
- The API validates input and enforces authentication, role, and ownership.
- Database changes persist and obey constraints.
- Loading, empty, success, validation, and failure states are handled.
- Tests cover the main success path and at least one unauthorized/invalid path.
- API contract and PRD changes are documented.
- The change is merged through a reviewed pull request and does not break the main branch.

### Minimum End-to-End Test Scenarios

1. Pending user cannot log in or call protected APIs.
2. Admin can approve a trainee and a trainer.
3. Trainee cannot self-assign Admin or change another user's role.
4. Trainer A cannot edit Trainer B's course or view private results for it.
5. Trainee cannot enroll in a draft/archived course.
6. Duplicate enrollment is blocked.
7. Unenrolled trainee cannot access restricted resources or assessments.
8. Client cannot forge assessment score or pass status.
9. Expired assessment cannot be submitted.
10. Attempt limit is enforced, including concurrent submission attempts.
11. Course progress is computed from persisted lesson records.
12. Certificate cannot be issued before eligibility and cannot be duplicated.
13. Announcement drafts/expired items are hidden from the homepage.
14. Recommendation results exclude pending/suspended trainers.
15. Dashboard values match test database records.

## 16. Risks and Mitigations

| Risk | Mitigation |
|---|---|
| Four AI coding sessions produce inconsistent names or architecture | Treat this PRD and `API_CONTRACT.md` as mandatory shared context; centralize changes |
| Integration begins too late | Build a vertical slice in Week 1; merge small PRs frequently |
| Vibe-coded features look functional but use mock data | Require database-backed acceptance tests for every P0 feature |
| Assessment answers leak to browser | Use role-specific DTOs and server-side scoring; test response payloads |
| Uploaded content becomes publicly accessible | Use controlled storage, signed URLs or authorized downloads, and server-side permission checks |
| Scope expands beyond the deadline | Keep deferred features explicitly out of MVP and require a scope-change decision |
| Admin account cannot be created for testing | Document a secure seed/provisioning procedure; never add public admin signup |
| Demo data is mistaken for real metrics | Clearly label demo data and avoid unsupported impact claims |
| Cloud service/free-tier changes delay deployment | Keep local development reproducible and document an alternate demo plan |

## 17. Assumptions and Constraints

- The team has an initialized Git repository named `capsera`; this document does not assume its current files or branches.
- The product name is CAPSERA, regardless of the source SIH problem statement's name CAPACITY CONNECT.
- The selected database is PostgreSQL (18.6+); this is not a MERN application.
- The product is a student project inspired by SIH26075, not an official MoES/IMD production deployment.
- The team has four members and expects a 2–4 week delivery window.
- No external dataset is required for the MVP; demo courses, skills, users, and questions can be seeded with synthetic data.
- Cloud storage, email delivery, and public hosting depend on account availability and may require documented fallback behaviour.
- Advanced features are not implied by aspirational reference-repository descriptions.

## 18. Reference Research and Inspiration

The following public repositories were reviewed as inspiration. Their READMEs and documented feature descriptions were used to compare ideas; this is not a guarantee that every claimed feature works, nor an exhaustive code/security audit.

**Official problem statement mirror — SIH26075:**
- https://github.com/vedantchalke36/sih-2026-problem-statements/blob/main/ps_2026/SIH26075.md
- Used as the baseline for the required three roles, resources, assessments, feedback, admin capabilities, and competency mapping.

**ASTALAKSHMI-S / -capacity-connect:**
- https://github.com/ASTALAKSHMI-S/-capacity-connect
- Inspiration: trainee information architecture, course explorer, learning player, competency and skill-gap views, assessment history, feedback. Its README notes mock/localStorage auth and incomplete trainer/admin modules, so CAPSERA requires real API/database integration.

**MiljotSinghK / Capacity-Connect:**
- https://github.com/MiljotSinghK/Capacity-Connect
- Inspiration: closed-loop competency model linking skills, gaps, trainer/course matching, assessment, and credentials; also emphasizes authorization and assessment integrity.

**umesh1177 / sih_2026:**
- https://github.com/umesh1177/sih_2026
- Inspiration: institutional role model, trainer-subject mapping, assessment lifecycle, and basic result analytics.

**bhanu123-vs / CAPACITY-CONNECT:**
- https://github.com/bhanu123-vs/CAPACITY-CONNECT
- Inspiration: SIH context, approval flow, password hashing, server-side role checks, responsive experience, and a relational-stack direction.

**abhinav115032 / capacity-connect:**
- https://github.com/abhinav115032/capacity-connect
- Additional SIH-related reference located during discovery.

**anandpatel9044 / Capacity_Connect:**
- https://github.com/anandpatel9044/Capacity_Connect
- Located during research; the public repository page appeared empty at the time reviewed.

### Research Interpretation

- SIH problem statement requirements take precedence over reference repositories.
- Reference projects may provide useful UX and workflow ideas, but repository claims are not independently verified functionality.
- CAPSERA should prefer explainable, deterministic matching over speculative AI for its first release.
- Real authorization, server-side scoring, persistent progress, and one complete learning journey matter more than a large number of incomplete screens.
- Use original implementation and UI design; do not copy another team's code or assets without checking license and attribution requirements.

## 19. Change Control and Approval

This PRD is the finalized baseline for the MVP. Changes should be proposed through a short decision record containing:

1. Requirement/section being changed.
2. Reason and expected user value.
3. Scope/time impact.
4. Data/API compatibility impact.
5. Approval from all four members.

The shared API contract, naming registry, and database model must be updated alongside any approved change. Individual members or AI assistants must not independently introduce competing names, routes, role values, status values, or duplicate entities.

## 20. Final MVP Definition

CAPSERA MVP is complete when an approved user can participate in the full learning lifecycle—profile and skills, trainer/course discovery, enrollment, lessons/resources, assessment, persisted results, progress, and eligible certificate—and when trainers/admins can securely manage the corresponding content and view the appropriate reports. The system must use the agreed React/Vite, Express, and PostgreSQL stack, enforce server-side permissions, and be usable on mobile and desktop.

---

*End of PRD — Version 1.0*
