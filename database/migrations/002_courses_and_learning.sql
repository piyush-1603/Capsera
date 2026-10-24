-- CAPSERA Database Migration
-- Migration: 002_courses_and_learning.sql
-- Description: Courses, lessons, learning resources, enrollments, and lesson progress.
--
-- Target DB: MySQL 8.0.16+ (InnoDB, utf8mb4)
-- Rollback summary:
--   DROP TABLE IF EXISTS lesson_progress;
--   DROP TABLE IF EXISTS enrollments;
--   DROP TABLE IF EXISTS learning_resources;
--   DROP TABLE IF EXISTS lessons;
--   DROP TABLE IF EXISTS courses;

USE capsera_db;

-- 7. Courses Table
CREATE TABLE IF NOT EXISTS courses (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  trainer_id INT UNSIGNED NOT NULL,
  title VARCHAR(255) NOT NULL,
  summary VARCHAR(500) DEFAULT NULL,
  description TEXT DEFAULT NULL,
  subject VARCHAR(100) DEFAULT NULL,
  level ENUM('BEGINNER', 'INTERMEDIATE', 'ADVANCED') DEFAULT NULL,
  status ENUM('DRAFT', 'PUBLISHED', 'ARCHIVED') NOT NULL DEFAULT 'DRAFT',
  thumbnail_url VARCHAR(1000) DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_courses_trainer_id (trainer_id),
  KEY idx_courses_status (status),
  KEY idx_courses_subject (subject),
  CONSTRAINT fk_courses_trainer FOREIGN KEY (trainer_id) REFERENCES users (id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 8. Lessons Table (Ordered content units within a course)
CREATE TABLE IF NOT EXISTS lessons (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  course_id INT UNSIGNED NOT NULL,
  title VARCHAR(255) NOT NULL,
  content MEDIUMTEXT DEFAULT NULL,
  sort_order INT NOT NULL DEFAULT 1,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_lessons_id_course (id, course_id),
  KEY idx_lessons_course_id (course_id),
  KEY idx_lessons_course_order (course_id, sort_order),
  CONSTRAINT fk_lessons_course FOREIGN KEY (course_id) REFERENCES courses (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 9. Learning Resources Table (Files, links, media attached to course or lesson)
CREATE TABLE IF NOT EXISTS learning_resources (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  course_id INT UNSIGNED NOT NULL,
  lesson_id INT UNSIGNED DEFAULT NULL,
  title VARCHAR(255) NOT NULL,
  type ENUM('VIDEO', 'PRESENTATION', 'DOCUMENT', 'LINK', 'OTHER') NOT NULL,
  url VARCHAR(2000) NOT NULL,
  file_size BIGINT UNSIGNED DEFAULT NULL,
  mime_type VARCHAR(100) DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_learning_resources_course_id (course_id),
  KEY idx_learning_resources_lesson_id (lesson_id),
  CONSTRAINT fk_learning_resources_course FOREIGN KEY (course_id) REFERENCES courses (id) ON DELETE CASCADE,
  CONSTRAINT fk_learning_resources_lesson FOREIGN KEY (lesson_id) REFERENCES lessons (id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 10. Enrollments Table (Trainee course enrollment lifecycle)
CREATE TABLE IF NOT EXISTS enrollments (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  trainee_id INT UNSIGNED NOT NULL,
  course_id INT UNSIGNED NOT NULL,
  status ENUM('ACTIVE', 'COMPLETED', 'CANCELLED') NOT NULL DEFAULT 'ACTIVE',
  enrolled_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  completed_at TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_enrollments_trainee_course (trainee_id, course_id),
  UNIQUE KEY uq_enrollments_id_course (id, course_id),
  KEY idx_enrollments_trainee_id (trainee_id),
  KEY idx_enrollments_course_id (course_id),
  KEY idx_enrollments_status (status),
  CONSTRAINT fk_enrollments_trainee FOREIGN KEY (trainee_id) REFERENCES users (id) ON DELETE CASCADE,
  CONSTRAINT fk_enrollments_course FOREIGN KEY (course_id) REFERENCES courses (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 11. Lesson Progress Table
-- Uses composite foreign keys (enrollment_id, course_id) and (lesson_id, course_id)
-- to strictly guarantee at database level that the completed lesson belongs to the enrolled course.
CREATE TABLE IF NOT EXISTS lesson_progress (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  enrollment_id INT UNSIGNED NOT NULL,
  course_id INT UNSIGNED NOT NULL,
  lesson_id INT UNSIGNED NOT NULL,
  completed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_lesson_progress_enrollment_lesson (enrollment_id, lesson_id),
  KEY idx_lesson_progress_enrollment_id (enrollment_id),
  KEY idx_lesson_progress_lesson_id (lesson_id),
  KEY idx_lesson_progress_course_id (course_id),
  CONSTRAINT fk_lesson_progress_enrollment_course FOREIGN KEY (enrollment_id, course_id) REFERENCES enrollments (id, course_id) ON DELETE CASCADE,
  CONSTRAINT fk_lesson_progress_lesson_course FOREIGN KEY (lesson_id, course_id) REFERENCES lessons (id, course_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
