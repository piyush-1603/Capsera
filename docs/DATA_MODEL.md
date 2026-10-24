# CAPSERA — Data Model Specification

> [!NOTE]
> **Finalized Schema Specification**
> This document defines the canonical MySQL 8.0.16+ InnoDB database schema for CAPSERA. The 19 planned tables are partitioned across four ordered migrations in `database/migrations/`.

---

## 1. Entity-Relationship Overview

The CAPSERA data model is organized around the following core relationships:

- A **User** has one platform role (`TRAINEE`, `TRAINER`, or `ADMIN`) and an optional 1:1 role-specific profile (`trainee_profiles` or `trainer_profiles`).
- **Skills** form a global catalog. Trainees and trainers associate with skills via `trainee_skills` and `trainer_skills`.
- A **Trainer** creates **Courses**. Each course contains ordered **Lessons** and optional **Learning Resources**.
- A **Trainee** enrolls in a course via **Enrollments**. Per-lesson completion is tracked through **Lesson Progress**, where composite foreign keys strictly enforce that the completed lesson belongs to the enrolled course.
- A course contains **Assessments** (MCQ quizzes/exams) composed of **Questions**. A trainee's attempt lifecycle is tracked in **Assessment Attempts**, and submitted choices are stored in **Attempt Answers**, with composite foreign keys enforcing that answers and questions share the exact same assessment.
- Trainees provide ratings and reviews via **Feedback** (one review per trainee per course).
- Upon course completion, a verifiable **Certificate** is issued with a unique code.
- System administrators publish platform **Announcements**.
- All critical administrative actions (approvals, suspensions, role modifications, certificate revocations) are immutably tracked in **Audit Logs** (with zero credentials stored).

```
users ──┬── trainee_profiles
        ├── trainer_profiles
        ├── trainee_skills ──── skills
        ├── trainer_skills ──── skills
        │
        ├── courses (as trainer) ──┬── lessons
        │                          ├── learning_resources
        │                          ├── assessments ──┬── questions
        │                          │                 └── assessment_attempts ── attempt_answers
        │                          ├── enrollments ──── lesson_progress
        │                          ├── feedback
        │                          └── certificates
        │
        ├── announcements (as admin)
        └── audit_logs (as actor)
```

---

## 2. Table Specifications (19 Tables)

### Migration 001: Identity, Profiles & Skills

#### 2.1 `users`
Base identity table for all platform actors.

| Column | Type | Nullable | Default | Description / Constraints |
|---|---|---|---|---|
| `id` | `INT UNSIGNED` | NO | AUTO_INCREMENT | Primary Key |
| `name` | `VARCHAR(100)` | NO | — | Display / legal name |
| `email` | `VARCHAR(255)` | NO | — | Unique login email (`uq_users_email`) |
| `password_hash` | `VARCHAR(255)` | NO | — | Bcrypt / Argon2 hashed password |
| `role` | `ENUM('TRAINEE', 'TRAINER', 'ADMIN')` | NO | — | Platform access role |
| `status` | `ENUM('PENDING', 'ACTIVE', 'REJECTED', 'SUSPENDED')` | NO | `'PENDING'` | Account approval state |
| `created_at` | `TIMESTAMP` | NO | `CURRENT_TIMESTAMP` | Account creation timestamp (UTC) |
| `updated_at` | `TIMESTAMP` | NO | `CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP` | Modification timestamp (UTC) |

**Indexes:**
- `PRIMARY KEY (id)`
- `UNIQUE KEY uq_users_email (email)`
- `KEY idx_users_role_status (role, status)`

---

#### 2.2 `trainee_profiles`
1:1 extension of `users` for trainees.

| Column | Type | Nullable | Default | Description / Constraints |
|---|---|---|---|---|
| `id` | `INT UNSIGNED` | NO | AUTO_INCREMENT | Primary Key |
| `user_id` | `INT UNSIGNED` | NO | — | FK → `users(id)` ON DELETE CASCADE, UNIQUE |
| `headline` | `VARCHAR(255)` | YES | NULL | Professional headline |
| `organization` | `VARCHAR(255)` | YES | NULL | Current employer / academic institution |
| `biography` | `TEXT` | YES | NULL | Biographical summary |
| `qualifications` | `TEXT` | YES | NULL | Academic degrees and certifications |
| `work_experience` | `TEXT` | YES | NULL | Summary of past professional roles |
| `interests` | `TEXT` | YES | NULL | Learning interests and target topics |
| `created_at` | `TIMESTAMP` | NO | `CURRENT_TIMESTAMP` | Creation timestamp (UTC) |
| `updated_at` | `TIMESTAMP` | NO | `CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP` | Modification timestamp (UTC) |

**Indexes:**
- `PRIMARY KEY (id)`
- `UNIQUE KEY uq_trainee_profiles_user_id (user_id)`
- `CONSTRAINT fk_trainee_profiles_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE`

---

#### 2.3 `trainer_profiles`
1:1 extension of `users` for trainers.

| Column | Type | Nullable | Default | Description / Constraints |
|---|---|---|---|---|
| `id` | `INT UNSIGNED` | NO | AUTO_INCREMENT | Primary Key |
| `user_id` | `INT UNSIGNED` | NO | — | FK → `users(id)` ON DELETE CASCADE, UNIQUE |
| `headline` | `VARCHAR(255)` | YES | NULL | Professional headline |
| `organization` | `VARCHAR(255)` | YES | NULL | Current organization |
| `biography` | `TEXT` | YES | NULL | Trainer bio |
| `qualifications` | `TEXT` | YES | NULL | Educational qualifications |
| `work_experience` | `TEXT` | YES | NULL | Industry experience |
| `subject_expertise` | `TEXT` | YES | NULL | Domain areas of teaching |
| `years_of_experience` | `INT UNSIGNED` | YES | 0 | Total professional experience |
| `created_at` | `TIMESTAMP` | NO | `CURRENT_TIMESTAMP` | Creation timestamp (UTC) |
| `updated_at` | `TIMESTAMP` | NO | `CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP` | Modification timestamp (UTC) |

**Indexes:**
- `PRIMARY KEY (id)`
- `UNIQUE KEY uq_trainer_profiles_user_id (user_id)`
- `CONSTRAINT fk_trainer_profiles_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE`

---

#### 2.4 `skills`
Centralized skill catalog for competency mapping.

| Column | Type | Nullable | Default | Description / Constraints |
|---|---|---|---|---|
| `id` | `INT UNSIGNED` | NO | AUTO_INCREMENT | Primary Key |
| `name` | `VARCHAR(100)` | NO | — | Unique skill name (`uq_skills_name`) |
| `category` | `VARCHAR(100)` | YES | NULL | Subject category (e.g., Programming, Cloud) |
| `created_at` | `TIMESTAMP` | NO | `CURRENT_TIMESTAMP` | Creation timestamp (UTC) |
| `updated_at` | `TIMESTAMP` | NO | `CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP` | Modification timestamp (UTC) |

**Indexes:**
- `PRIMARY KEY (id)`
- `UNIQUE KEY uq_skills_name (name)`
- `KEY idx_skills_category (category)`

---

#### 2.5 `trainee_skills`
M:N join table mapping trainees to competencies.

| Column | Type | Nullable | Default | Description / Constraints |
|---|---|---|---|---|
| `id` | `INT UNSIGNED` | NO | AUTO_INCREMENT | Primary Key |
| `user_id` | `INT UNSIGNED` | NO | — | FK → `users(id)` ON DELETE CASCADE |
| `skill_id` | `INT UNSIGNED` | NO | — | FK → `skills(id)` ON DELETE CASCADE |
| `proficiency` | `ENUM('BEGINNER', 'INTERMEDIATE', 'ADVANCED', 'EXPERT')` | YES | NULL | Self-rated proficiency |
| `created_at` | `TIMESTAMP` | NO | `CURRENT_TIMESTAMP` | Creation timestamp (UTC) |

**Indexes:**
- `PRIMARY KEY (id)`
- `UNIQUE KEY uq_trainee_skills_user_skill (user_id, skill_id)`
- `KEY idx_trainee_skills_skill_id (skill_id)`

---

#### 2.6 `trainer_skills`
M:N join table mapping trainers to competencies for matching.

| Column | Type | Nullable | Default | Description / Constraints |
|---|---|---|---|---|
| `id` | `INT UNSIGNED` | NO | AUTO_INCREMENT | Primary Key |
| `user_id` | `INT UNSIGNED` | NO | — | FK → `users(id)` ON DELETE CASCADE |
| `skill_id` | `INT UNSIGNED` | NO | — | FK → `skills(id)` ON DELETE CASCADE |
| `proficiency` | `ENUM('BEGINNER', 'INTERMEDIATE', 'ADVANCED', 'EXPERT')` | YES | NULL | Trainer proficiency level |
| `years_of_experience` | `INT UNSIGNED` | YES | 0 | Years practicing/teaching skill |
| `created_at` | `TIMESTAMP` | NO | `CURRENT_TIMESTAMP` | Creation timestamp (UTC) |

**Indexes:**
- `PRIMARY KEY (id)`
- `UNIQUE KEY uq_trainer_skills_user_skill (user_id, skill_id)`
- `KEY idx_trainer_skills_skill_id (skill_id)`

---

### Migration 002: Courses & Learning

#### 2.7 `courses`
Training curriculum authored by trainers.

| Column | Type | Nullable | Default | Description / Constraints |
|---|---|---|---|---|
| `id` | `INT UNSIGNED` | NO | AUTO_INCREMENT | Primary Key |
| `trainer_id` | `INT UNSIGNED` | NO | — | FK → `users(id)` ON DELETE RESTRICT |
| `title` | `VARCHAR(255)` | NO | — | Course title |
| `summary` | `VARCHAR(500)` | YES | NULL | Short summary / card overview |
| `description` | `TEXT` | YES | NULL | Full course syllabus and description |
| `subject` | `VARCHAR(100)` | YES | NULL | Primary topic area |
| `level` | `ENUM('BEGINNER', 'INTERMEDIATE', 'ADVANCED')` | YES | NULL | Difficulty level |
| `status` | `ENUM('DRAFT', 'PUBLISHED', 'ARCHIVED')` | NO | `'DRAFT'` | Course lifecycle status |
| `thumbnail_url` | `VARCHAR(1000)` | YES | NULL | Media thumbnail URL |
| `created_at` | `TIMESTAMP` | NO | `CURRENT_TIMESTAMP` | Creation timestamp (UTC) |
| `updated_at` | `TIMESTAMP` | NO | `CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP` | Modification timestamp (UTC) |

**Indexes:**
- `PRIMARY KEY (id)`
- `KEY idx_courses_trainer_id (trainer_id)`
- `KEY idx_courses_status (status)`
- `KEY idx_courses_subject (subject)`
- `CONSTRAINT fk_courses_trainer FOREIGN KEY (trainer_id) REFERENCES users(id) ON DELETE RESTRICT`

---

#### 2.8 `lessons`
Ordered teaching units within a course.

| Column | Type | Nullable | Default | Description / Constraints |
|---|---|---|---|---|
| `id` | `INT UNSIGNED` | NO | AUTO_INCREMENT | Primary Key |
| `course_id` | `INT UNSIGNED` | NO | — | FK → `courses(id)` ON DELETE CASCADE |
| `title` | `VARCHAR(255)` | NO | — | Lesson title |
| `content` | `MEDIUMTEXT` | YES | NULL | Lesson text, instructions, or markdown |
| `sort_order` | `INT` | NO | 1 | Sequential ordering in course syllabus |
| `created_at` | `TIMESTAMP` | NO | `CURRENT_TIMESTAMP` | Creation timestamp (UTC) |
| `updated_at` | `TIMESTAMP` | NO | `CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP` | Modification timestamp (UTC) |

**Indexes:**
- `PRIMARY KEY (id)`
- `UNIQUE KEY uq_lessons_id_course (id, course_id)` *(Required for composite FK in `lesson_progress`)*
- `KEY idx_lessons_course_id (course_id)`
- `KEY idx_lessons_course_order (course_id, sort_order)`
- `CONSTRAINT fk_lessons_course FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE`

---

#### 2.9 `learning_resources`
Multimedia attachments and references.

| Column | Type | Nullable | Default | Description / Constraints |
|---|---|---|---|---|
| `id` | `INT UNSIGNED` | NO | AUTO_INCREMENT | Primary Key |
| `course_id` | `INT UNSIGNED` | NO | — | FK → `courses(id)` ON DELETE CASCADE |
| `lesson_id` | `INT UNSIGNED` | YES | NULL | FK → `lessons(id)` ON DELETE SET NULL |
| `title` | `VARCHAR(255)` | NO | — | Resource title |
| `type` | `ENUM('VIDEO', 'PRESENTATION', 'DOCUMENT', 'LINK', 'OTHER')` | NO | — | Media categorization |
| `url` | `VARCHAR(2000)` | NO | — | Resource link or file storage path |
| `file_size` | `BIGINT UNSIGNED` | YES | NULL | Size in bytes |
| `mime_type` | `VARCHAR(100)` | YES | NULL | Content MIME type |
| `created_at` | `TIMESTAMP` | NO | `CURRENT_TIMESTAMP` | Upload timestamp (UTC) |

**Indexes:**
- `PRIMARY KEY (id)`
- `KEY idx_learning_resources_course_id (course_id)`
- `KEY idx_learning_resources_lesson_id (lesson_id)`
- `CONSTRAINT fk_learning_resources_course FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE`
- `CONSTRAINT fk_learning_resources_lesson FOREIGN KEY (lesson_id) REFERENCES lessons(id) ON DELETE SET NULL`

---

#### 2.10 `enrollments`
Course participation and status tracker.

| Column | Type | Nullable | Default | Description / Constraints |
|---|---|---|---|---|
| `id` | `INT UNSIGNED` | NO | AUTO_INCREMENT | Primary Key |
| `trainee_id` | `INT UNSIGNED` | NO | — | FK → `users(id)` ON DELETE CASCADE |
| `course_id` | `INT UNSIGNED` | NO | — | FK → `courses(id)` ON DELETE CASCADE |
| `status` | `ENUM('ACTIVE', 'COMPLETED', 'CANCELLED')` | NO | `'ACTIVE'` | Enrollment status |
| `enrolled_at` | `TIMESTAMP` | NO | `CURRENT_TIMESTAMP` | Enrollment timestamp (UTC) |
| `completed_at` | `TIMESTAMP` | YES | NULL | Course completion timestamp |

**Indexes:**
- `PRIMARY KEY (id)`
- `UNIQUE KEY uq_enrollments_trainee_course (trainee_id, course_id)`
- `UNIQUE KEY uq_enrollments_id_course (id, course_id)` *(Required for composite FK in `lesson_progress`)*
- `KEY idx_enrollments_trainee_id (trainee_id)`
- `KEY idx_enrollments_course_id (course_id)`
- `KEY idx_enrollments_status (status)`

---

#### 2.11 `lesson_progress`
Individual lesson completion tracking.

| Column | Type | Nullable | Default | Description / Constraints |
|---|---|---|---|---|
| `id` | `INT UNSIGNED` | NO | AUTO_INCREMENT | Primary Key |
| `enrollment_id` | `INT UNSIGNED` | NO | — | FK (composite) → `enrollments(id, course_id)` |
| `course_id` | `INT UNSIGNED` | NO | — | Denormalized course ID ensuring strict match |
| `lesson_id` | `INT UNSIGNED` | NO | — | FK (composite) → `lessons(id, course_id)` |
| `completed_at` | `TIMESTAMP` | NO | `CURRENT_TIMESTAMP` | Completion timestamp |

**Indexes & Constraints:**
- `PRIMARY KEY (id)`
- `UNIQUE KEY uq_lesson_progress_enrollment_lesson (enrollment_id, lesson_id)`
- `KEY idx_lesson_progress_enrollment_id (enrollment_id)`
- `KEY idx_lesson_progress_lesson_id (lesson_id)`
- `KEY idx_lesson_progress_course_id (course_id)`
- `CONSTRAINT fk_lesson_progress_enrollment_course FOREIGN KEY (enrollment_id, course_id) REFERENCES enrollments (id, course_id) ON DELETE CASCADE`
- `CONSTRAINT fk_lesson_progress_lesson_course FOREIGN KEY (lesson_id, course_id) REFERENCES lessons (id, course_id) ON DELETE CASCADE`

---

### Migration 003: Assessments & Feedback

#### 2.12 `assessments`
Quizzes and examinations linked to a course.

| Column | Type | Nullable | Default | Description / Constraints |
|---|---|---|---|---|
| `id` | `INT UNSIGNED` | NO | AUTO_INCREMENT | Primary Key |
| `course_id` | `INT UNSIGNED` | NO | — | FK → `courses(id)` ON DELETE CASCADE |
| `title` | `VARCHAR(255)` | NO | — | Assessment title |
| `instructions` | `TEXT` | YES | NULL | Student test instructions |
| `duration_minutes` | `INT UNSIGNED` | YES | NULL | Allowed time (CHECK `>= 1` if present) |
| `max_attempts` | `INT UNSIGNED` | YES | 1 | Attempt limit (CHECK `>= 1` if present) |
| `pass_threshold` | `DECIMAL(5,2)` | YES | 50.00 | Passing grade % (CHECK `0.00` to `100.00`) |
| `status` | `ENUM('DRAFT', 'PUBLISHED', 'CLOSED')` | NO | `'DRAFT'` | Assessment status |
| `deadline` | `TIMESTAMP` | YES | NULL | Submission cutoff time |
| `created_at` | `TIMESTAMP` | NO | `CURRENT_TIMESTAMP` | Creation timestamp |
| `updated_at` | `TIMESTAMP` | NO | `CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP` | Modification timestamp |

**Indexes & Constraints:**
- `PRIMARY KEY (id)`
- `UNIQUE KEY uq_assessments_id_course (id, course_id)`
- `KEY idx_assessments_course_id (course_id)`
- `KEY idx_assessments_status (status)`
- `CONSTRAINT chk_assessments_duration CHECK (duration_minutes IS NULL OR duration_minutes >= 1)`
- `CONSTRAINT chk_assessments_max_attempts CHECK (max_attempts IS NULL OR max_attempts >= 1)`
- `CONSTRAINT chk_assessments_pass_threshold CHECK (pass_threshold IS NULL OR (pass_threshold >= 0.00 AND pass_threshold <= 100.00))`
- `CONSTRAINT fk_assessments_course FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE`

---

#### 2.13 `questions`
Multiple-choice questions with 4 options.

| Column | Type | Nullable | Default | Description / Constraints |
|---|---|---|---|---|
| `id` | `INT UNSIGNED` | NO | AUTO_INCREMENT | Primary Key |
| `assessment_id` | `INT UNSIGNED` | NO | — | FK → `assessments(id)` ON DELETE CASCADE |
| `question_text` | `TEXT` | NO | — | Question text |
| `option_a` | `VARCHAR(1000)` | NO | — | Option A |
| `option_b` | `VARCHAR(1000)` | NO | — | Option B |
| `option_c` | `VARCHAR(1000)` | NO | — | Option C |
| `option_d` | `VARCHAR(1000)` | NO | — | Option D |
| `correct_option` | `CHAR(1)` | NO | — | Answer key (CHECK in `'A', 'B', 'C', 'D'`) |
| `explanation` | `TEXT` | YES | NULL | Post-submission solution explanation |
| `points` | `INT UNSIGNED` | NO | 1 | Question weight (CHECK `>= 1`) |
| `sort_order` | `INT` | NO | 1 | Display sequence |
| `created_at` | `TIMESTAMP` | NO | `CURRENT_TIMESTAMP` | Creation timestamp |

**Indexes & Constraints:**
- `PRIMARY KEY (id)`
- `UNIQUE KEY uq_questions_id_assessment (id, assessment_id)`
- `KEY idx_questions_assessment_order (assessment_id, sort_order)`
- `CONSTRAINT chk_questions_correct_option CHECK (correct_option IN ('A', 'B', 'C', 'D'))`
- `CONSTRAINT chk_questions_points CHECK (points >= 1)`
- `CONSTRAINT fk_questions_assessment FOREIGN KEY (assessment_id) REFERENCES assessments(id) ON DELETE CASCADE`

---

#### 2.14 `assessment_attempts`
Lifecycle of a trainee sitting for an assessment.

| Column | Type | Nullable | Default | Description / Constraints |
|---|---|---|---|---|
| `id` | `INT UNSIGNED` | NO | AUTO_INCREMENT | Primary Key |
| `assessment_id` | `INT UNSIGNED` | NO | — | FK → `assessments(id)` ON DELETE CASCADE |
| `trainee_id` | `INT UNSIGNED` | NO | — | FK → `users(id)` ON DELETE CASCADE |
| `attempt_number` | `INT UNSIGNED` | NO | — | Attempt sequence (CHECK `>= 1`) |
| `status` | `ENUM('IN_PROGRESS', 'SUBMITTED', 'GRADED', 'EXPIRED')` | NO | `'IN_PROGRESS'` | Attempt state |
| `score` | `DECIMAL(6,2)` | YES | NULL | Points obtained |
| `total_points` | `DECIMAL(6,2)` | YES | NULL | Maximum points possible |
| `percentage` | `DECIMAL(5,2)` | YES | NULL | Score % (CHECK `0.00` to `100.00`) |
| `passed` | `BOOLEAN` | YES | NULL | Pass flag based on assessment threshold |
| `started_at` | `TIMESTAMP` | NO | `CURRENT_TIMESTAMP` | Attempt commencement |
| `submitted_at` | `TIMESTAMP` | YES | NULL | Attempt submission |
| `graded_at` | `TIMESTAMP` | YES | NULL | Auto-grading completion |

**Indexes & Constraints:**
- `PRIMARY KEY (id)`
- `UNIQUE KEY uq_attempts_assessment_trainee_number (assessment_id, trainee_id, attempt_number)`
- `UNIQUE KEY uq_attempts_id_assessment (id, assessment_id)`
- `KEY idx_attempts_trainee_id (trainee_id)`
- `KEY idx_attempts_assessment_id (assessment_id)`
- `KEY idx_attempts_status (status)`
- `CONSTRAINT chk_attempts_attempt_number CHECK (attempt_number >= 1)`
- `CONSTRAINT chk_attempts_percentage CHECK (percentage IS NULL OR (percentage >= 0.00 AND percentage <= 100.00))`
- `CONSTRAINT fk_attempts_assessment FOREIGN KEY (assessment_id) REFERENCES assessments(id) ON DELETE CASCADE`
- `CONSTRAINT fk_attempts_trainee FOREIGN KEY (trainee_id) REFERENCES users(id) ON DELETE CASCADE`

---

#### 2.15 `attempt_answers`
Trainee response for each assessment question.

| Column | Type | Nullable | Default | Description / Constraints |
|---|---|---|---|---|
| `id` | `INT UNSIGNED` | NO | AUTO_INCREMENT | Primary Key |
| `attempt_id` | `INT UNSIGNED` | NO | — | FK (composite) → `assessment_attempts(id, assessment_id)` |
| `assessment_id` | `INT UNSIGNED` | NO | — | Denormalized assessment ID ensuring strict match |
| `question_id` | `INT UNSIGNED` | NO | — | FK (composite) → `questions(id, assessment_id)` |
| `selected_option` | `CHAR(1)` | YES | NULL | Selected option (CHECK in `'A', 'B', 'C', 'D'`) |
| `is_correct` | `BOOLEAN` | YES | NULL | Result flag |
| `points_awarded` | `DECIMAL(6,2)` | YES | 0.00 | Awarded points |

**Indexes & Constraints:**
- `PRIMARY KEY (id)`
- `UNIQUE KEY uq_attempt_answers_attempt_question (attempt_id, question_id)`
- `KEY idx_attempt_answers_attempt_id (attempt_id)`
- `KEY idx_attempt_answers_question_id (question_id)`
- `KEY idx_attempt_answers_assessment_id (assessment_id)`
- `CONSTRAINT chk_attempt_answers_selected_option CHECK (selected_option IS NULL OR selected_option IN ('A', 'B', 'C', 'D'))`
- `CONSTRAINT fk_attempt_answers_attempt_assessment FOREIGN KEY (attempt_id, assessment_id) REFERENCES assessment_attempts (id, assessment_id) ON DELETE CASCADE`
- `CONSTRAINT fk_attempt_answers_question_assessment FOREIGN KEY (question_id, assessment_id) REFERENCES questions (id, assessment_id) ON DELETE CASCADE`

---

#### 2.16 `feedback`
Course rating and qualitative review by enrolled trainees.

| Column | Type | Nullable | Default | Description / Constraints |
|---|---|---|---|---|
| `id` | `INT UNSIGNED` | NO | AUTO_INCREMENT | Primary Key |
| `trainee_id` | `INT UNSIGNED` | NO | — | FK → `users(id)` ON DELETE CASCADE |
| `course_id` | `INT UNSIGNED` | NO | — | FK → `courses(id)` ON DELETE CASCADE |
| `rating` | `TINYINT UNSIGNED` | NO | — | Star rating (CHECK `1` to `5`) |
| `comment` | `TEXT` | YES | NULL | Feedback comments |
| `created_at` | `TIMESTAMP` | NO | `CURRENT_TIMESTAMP` | Submission timestamp |
| `updated_at` | `TIMESTAMP` | NO | `CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP` | Modification timestamp |

**Indexes & Constraints:**
- `PRIMARY KEY (id)`
- `UNIQUE KEY uq_feedback_trainee_course (trainee_id, course_id)`
- `KEY idx_feedback_course_id (course_id)`
- `KEY idx_feedback_trainee_id (trainee_id)`
- `CONSTRAINT chk_feedback_rating CHECK (rating >= 1 AND rating <= 5)`
- `CONSTRAINT fk_feedback_trainee FOREIGN KEY (trainee_id) REFERENCES users(id) ON DELETE CASCADE`
- `CONSTRAINT fk_feedback_course FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE`

---

### Migration 004: Certificates, Announcements & Audit Logs

#### 2.17 `certificates`
Cryptographically verifiable course completion credentials.

| Column | Type | Nullable | Default | Description / Constraints |
|---|---|---|---|---|
| `id` | `INT UNSIGNED` | NO | AUTO_INCREMENT | Primary Key |
| `trainee_id` | `INT UNSIGNED` | NO | — | FK → `users(id)` ON DELETE CASCADE |
| `course_id` | `INT UNSIGNED` | NO | — | FK → `courses(id)` ON DELETE RESTRICT |
| `certificate_code` | `VARCHAR(64)` | NO | — | Unique verification code (`uq_certificates_code`) |
| `issued_at` | `TIMESTAMP` | NO | `CURRENT_TIMESTAMP` | Issuance timestamp (UTC) |
| `revoked_at` | `TIMESTAMP` | YES | NULL | Nullable revocation timestamp (NULL = valid) |

**Indexes & Constraints:**
- `PRIMARY KEY (id)`
- `UNIQUE KEY uq_certificates_code (certificate_code)`
- `UNIQUE KEY uq_certificates_trainee_course (trainee_id, course_id)`
- `KEY idx_certificates_trainee_id (trainee_id)`
- `KEY idx_certificates_course_id (course_id)`
- `KEY idx_certificates_issued_at (issued_at)`
- `CONSTRAINT fk_certificates_trainee FOREIGN KEY (trainee_id) REFERENCES users(id) ON DELETE CASCADE`
- `CONSTRAINT fk_certificates_course FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE RESTRICT`

---

#### 2.18 `announcements`
Platform-wide broadcast notices published by administrators.

| Column | Type | Nullable | Default | Description / Constraints |
|---|---|---|---|---|
| `id` | `INT UNSIGNED` | NO | AUTO_INCREMENT | Primary Key |
| `admin_id` | `INT UNSIGNED` | NO | — | FK → `users(id)` ON DELETE RESTRICT |
| `title` | `VARCHAR(255)` | NO | — | Announcement title |
| `body` | `TEXT` | NO | — | Announcement body text |
| `category` | `VARCHAR(50)` | YES | NULL | Classification tag (e.g. MAINTENANCE, EVENT) |
| `status` | `ENUM('DRAFT', 'PUBLISHED', 'ARCHIVED')` | NO | `'DRAFT'` | Publication status |
| `published_at` | `TIMESTAMP` | YES | NULL | Publication timestamp |
| `expires_at` | `TIMESTAMP` | YES | NULL | Auto-expiry cutoff timestamp |
| `created_at` | `TIMESTAMP` | NO | `CURRENT_TIMESTAMP` | Creation timestamp |
| `updated_at` | `TIMESTAMP` | NO | `CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP` | Modification timestamp |

**Indexes & Constraints:**
- `PRIMARY KEY (id)`
- `KEY idx_announcements_admin_id (admin_id)`
- `KEY idx_announcements_status_published (status, published_at)`
- `KEY idx_announcements_expires_at (expires_at)`
- `CONSTRAINT fk_announcements_admin FOREIGN KEY (admin_id) REFERENCES users(id) ON DELETE RESTRICT`

---

#### 2.19 `audit_logs`
Administrative action audit trail and compliance ledger.

| Column | Type | Nullable | Default | Description / Constraints |
|---|---|---|---|---|
| `id` | `BIGINT UNSIGNED` | NO | AUTO_INCREMENT | Primary Key |
| `actor_id` | `INT UNSIGNED` | YES | NULL | FK → `users(id)` ON DELETE SET NULL |
| `action` | `VARCHAR(100)` | NO | — | Performed action (e.g. `USER_APPROVAL`, `ROLE_CHANGE`) |
| `entity_type` | `VARCHAR(50)` | NO | — | Affected entity table (e.g. `users`, `certificates`) |
| `entity_id` | `VARCHAR(100)` | NO | — | Affected entity primary key / code |
| `metadata` | `JSON` | YES | NULL | Contextual attributes (zero credentials/secrets) |
| `ip_address` | `VARCHAR(45)` | YES | NULL | Client IP address (IPv4 / IPv6) |
| `created_at` | `TIMESTAMP` | NO | `CURRENT_TIMESTAMP` | Log record timestamp (UTC) |

**Indexes & Constraints:**
- `PRIMARY KEY (id)`
- `KEY idx_audit_logs_actor (actor_id, created_at)`
- `KEY idx_audit_logs_entity (entity_type, entity_id)`
- `KEY idx_audit_logs_action (action, created_at)`
- `KEY idx_audit_logs_created_at (created_at)`
- `CONSTRAINT fk_audit_logs_actor FOREIGN KEY (actor_id) REFERENCES users(id) ON DELETE SET NULL`

---

## 3. Structural Integrity & Cross-Table Guarantees

1. **Course-Enrolled Lesson Guarantee:**
   `lesson_progress` enforces `(enrollment_id, course_id) REFERENCES enrollments(id, course_id)` and `(lesson_id, course_id) REFERENCES lessons(id, course_id)`. A lesson cannot be completed unless it belongs to the enrolled course.
2. **Assessment-Question Attempt Guarantee:**
   `attempt_answers` enforces `(attempt_id, assessment_id) REFERENCES assessment_attempts(id, assessment_id)` and `(question_id, assessment_id) REFERENCES questions(id, assessment_id)`. An answer cannot record an option for a question that does not belong to the attempt's assessment.
3. **Rating Bounds:**
   `feedback.rating` is enforced between 1 and 5 via MySQL CHECK constraint `chk_feedback_rating`.
4. **Assessment Percentage Bounds:**
   `pass_threshold` and `percentage` are bounded between `0.00` and `100.00` via CHECK constraints.
5. **No Orphan Certificates or Courses:**
   `certificates.course_id` and `courses.trainer_id` use `ON DELETE RESTRICT` to ensure educational records remain stable and verifiable.
