-- CAPSERA Database Migration
-- Migration: 004_certificates_and_announcements.sql
-- Description: Course completion certificates, system announcements, and audit logging.
--
-- Target DB: MySQL 8.0.16+ (InnoDB, utf8mb4)
-- Rollback summary:
--   DROP TABLE IF EXISTS audit_logs;
--   DROP TABLE IF EXISTS announcements;
--   DROP TABLE IF EXISTS certificates;

USE capsera_db;

-- 17. Certificates Table (Course completion certificates)
CREATE TABLE IF NOT EXISTS certificates (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  trainee_id INT UNSIGNED NOT NULL,
  course_id INT UNSIGNED NOT NULL,
  certificate_code VARCHAR(64) NOT NULL,
  issued_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  revoked_at TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_certificates_code (certificate_code),
  UNIQUE KEY uq_certificates_trainee_course (trainee_id, course_id),
  KEY idx_certificates_trainee_id (trainee_id),
  KEY idx_certificates_course_id (course_id),
  KEY idx_certificates_issued_at (issued_at),
  CONSTRAINT fk_certificates_trainee FOREIGN KEY (trainee_id) REFERENCES users (id) ON DELETE CASCADE,
  CONSTRAINT fk_certificates_course FOREIGN KEY (course_id) REFERENCES courses (id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 18. Announcements Table (Platform announcements published by administrators)
CREATE TABLE IF NOT EXISTS announcements (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  admin_id INT UNSIGNED NOT NULL,
  title VARCHAR(255) NOT NULL,
  body TEXT NOT NULL,
  category VARCHAR(50) DEFAULT NULL,
  status ENUM('DRAFT', 'PUBLISHED', 'ARCHIVED') NOT NULL DEFAULT 'DRAFT',
  published_at TIMESTAMP NULL DEFAULT NULL,
  expires_at TIMESTAMP NULL DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_announcements_admin_id (admin_id),
  KEY idx_announcements_status_published (status, published_at),
  KEY idx_announcements_expires_at (expires_at),
  CONSTRAINT fk_announcements_admin FOREIGN KEY (admin_id) REFERENCES users (id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 19. Audit Logs Table (Administrative actions and compliance event trail)
-- Security note: Passwords, tokens, and other secrets must NEVER be persisted in metadata.
CREATE TABLE IF NOT EXISTS audit_logs (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  actor_id INT UNSIGNED DEFAULT NULL,
  action VARCHAR(100) NOT NULL,
  entity_type VARCHAR(50) NOT NULL,
  entity_id VARCHAR(100) NOT NULL,
  metadata JSON DEFAULT NULL,
  ip_address VARCHAR(45) DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_audit_logs_actor (actor_id, created_at),
  KEY idx_audit_logs_entity (entity_type, entity_id),
  KEY idx_audit_logs_action (action, created_at),
  KEY idx_audit_logs_created_at (created_at),
  CONSTRAINT fk_audit_logs_actor FOREIGN KEY (actor_id) REFERENCES users (id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
