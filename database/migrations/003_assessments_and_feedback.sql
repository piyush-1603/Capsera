-- CAPSERA Database Migration
-- Migration: 003_assessments_and_feedback.sql
-- Description: Assessments, questions, attempts, answers, and course feedback.
--
-- Target DB: MySQL 8.0.16+ (InnoDB, utf8mb4)
-- Rollback summary:
--   DROP TABLE IF EXISTS feedback;
--   DROP TABLE IF EXISTS attempt_answers;
--   DROP TABLE IF EXISTS assessment_attempts;
--   DROP TABLE IF EXISTS questions;
--   DROP TABLE IF EXISTS assessments;

USE capsera_db;

-- 12. Assessments Table (Quizzes and exams linked to courses)
CREATE TABLE IF NOT EXISTS assessments (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  course_id INT UNSIGNED NOT NULL,
  title VARCHAR(255) NOT NULL,
  instructions TEXT DEFAULT NULL,
  duration_minutes INT UNSIGNED DEFAULT NULL,
  max_attempts INT UNSIGNED DEFAULT 1,
  pass_threshold DECIMAL(5,2) DEFAULT 50.00,
  status ENUM('DRAFT', 'PUBLISHED', 'CLOSED') NOT NULL DEFAULT 'DRAFT',
  deadline TIMESTAMP NULL DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_assessments_id_course (id, course_id),
  KEY idx_assessments_course_id (course_id),
  KEY idx_assessments_status (status),
  CONSTRAINT chk_assessments_duration CHECK (duration_minutes IS NULL OR duration_minutes >= 1),
  CONSTRAINT chk_assessments_max_attempts CHECK (max_attempts IS NULL OR max_attempts >= 1),
  CONSTRAINT chk_assessments_pass_threshold CHECK (pass_threshold IS NULL OR (pass_threshold >= 0.00 AND pass_threshold <= 100.00)),
  CONSTRAINT fk_assessments_course FOREIGN KEY (course_id) REFERENCES courses (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 13. Questions Table (Multiple-choice questions with 4 choices A-D)
CREATE TABLE IF NOT EXISTS questions (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  assessment_id INT UNSIGNED NOT NULL,
  question_text TEXT NOT NULL,
  option_a VARCHAR(1000) NOT NULL,
  option_b VARCHAR(1000) NOT NULL,
  option_c VARCHAR(1000) NOT NULL,
  option_d VARCHAR(1000) NOT NULL,
  correct_option CHAR(1) NOT NULL,
  explanation TEXT DEFAULT NULL,
  points INT UNSIGNED NOT NULL DEFAULT 1,
  sort_order INT NOT NULL DEFAULT 1,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_questions_id_assessment (id, assessment_id),
  KEY idx_questions_assessment_order (assessment_id, sort_order),
  CONSTRAINT chk_questions_correct_option CHECK (correct_option IN ('A', 'B', 'C', 'D')),
  CONSTRAINT chk_questions_points CHECK (points >= 1),
  CONSTRAINT fk_questions_assessment FOREIGN KEY (assessment_id) REFERENCES assessments (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 14. Assessment Attempts Table (Lifecycle of a student attempt)
CREATE TABLE IF NOT EXISTS assessment_attempts (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  assessment_id INT UNSIGNED NOT NULL,
  trainee_id INT UNSIGNED NOT NULL,
  attempt_number INT UNSIGNED NOT NULL,
  status ENUM('IN_PROGRESS', 'SUBMITTED', 'GRADED', 'EXPIRED') NOT NULL DEFAULT 'IN_PROGRESS',
  score DECIMAL(6,2) DEFAULT NULL,
  total_points DECIMAL(6,2) DEFAULT NULL,
  percentage DECIMAL(5,2) DEFAULT NULL,
  passed BOOLEAN DEFAULT NULL,
  started_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  submitted_at TIMESTAMP NULL DEFAULT NULL,
  graded_at TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_attempts_assessment_trainee_number (assessment_id, trainee_id, attempt_number),
  UNIQUE KEY uq_attempts_id_assessment (id, assessment_id),
  KEY idx_attempts_trainee_id (trainee_id),
  KEY idx_attempts_assessment_id (assessment_id),
  KEY idx_attempts_status (status),
  CONSTRAINT chk_attempts_attempt_number CHECK (attempt_number >= 1),
  CONSTRAINT chk_attempts_percentage CHECK (percentage IS NULL OR (percentage >= 0.00 AND percentage <= 100.00)),
  CONSTRAINT fk_attempts_assessment FOREIGN KEY (assessment_id) REFERENCES assessments (id) ON DELETE CASCADE,
  CONSTRAINT fk_attempts_trainee FOREIGN KEY (trainee_id) REFERENCES users (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 15. Attempt Answers Table
-- Uses composite foreign keys (attempt_id, assessment_id) and (question_id, assessment_id)
-- to strictly guarantee at database level that the answered question belongs to the attempt's assessment.
CREATE TABLE IF NOT EXISTS attempt_answers (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  attempt_id INT UNSIGNED NOT NULL,
  assessment_id INT UNSIGNED NOT NULL,
  question_id INT UNSIGNED NOT NULL,
  selected_option CHAR(1) DEFAULT NULL,
  is_correct BOOLEAN DEFAULT NULL,
  points_awarded DECIMAL(6,2) DEFAULT 0.00,
  PRIMARY KEY (id),
  UNIQUE KEY uq_attempt_answers_attempt_question (attempt_id, question_id),
  KEY idx_attempt_answers_attempt_id (attempt_id),
  KEY idx_attempt_answers_question_id (question_id),
  KEY idx_attempt_answers_assessment_id (assessment_id),
  CONSTRAINT chk_attempt_answers_selected_option CHECK (selected_option IS NULL OR selected_option IN ('A', 'B', 'C', 'D')),
  CONSTRAINT fk_attempt_answers_attempt_assessment FOREIGN KEY (attempt_id, assessment_id) REFERENCES assessment_attempts (id, assessment_id) ON DELETE CASCADE,
  CONSTRAINT fk_attempt_answers_question_assessment FOREIGN KEY (question_id, assessment_id) REFERENCES questions (id, assessment_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 16. Feedback Table (1-5 star ratings and reviews for courses)
CREATE TABLE IF NOT EXISTS feedback (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  trainee_id INT UNSIGNED NOT NULL,
  course_id INT UNSIGNED NOT NULL,
  rating TINYINT UNSIGNED NOT NULL,
  comment TEXT DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_feedback_trainee_course (trainee_id, course_id),
  KEY idx_feedback_course_id (course_id),
  KEY idx_feedback_trainee_id (trainee_id),
  CONSTRAINT chk_feedback_rating CHECK (rating >= 1 AND rating <= 5),
  CONSTRAINT fk_feedback_trainee FOREIGN KEY (trainee_id) REFERENCES users (id) ON DELETE CASCADE,
  CONSTRAINT fk_feedback_course FOREIGN KEY (course_id) REFERENCES courses (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
