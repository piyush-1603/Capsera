-- CAPSERA Database Migration
-- Migration: 001_identity_and_skills.sql
-- Description: Core identity, user profiles, and shared skills catalog.
--
-- Target DB: MySQL 8.0.16+ (InnoDB, utf8mb4)
-- Rollback summary:
--   DROP TABLE IF EXISTS trainer_skills;
--   DROP TABLE IF EXISTS trainee_skills;
--   DROP TABLE IF EXISTS skills;
--   DROP TABLE IF EXISTS trainer_profiles;
--   DROP TABLE IF EXISTS trainee_profiles;
--   DROP TABLE IF EXISTS users;

USE capsera_db;

-- 1. Base Users Table
CREATE TABLE IF NOT EXISTS users (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(255) NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  role ENUM('TRAINEE', 'TRAINER', 'ADMIN') NOT NULL,
  status ENUM('PENDING', 'ACTIVE', 'REJECTED', 'SUSPENDED') NOT NULL DEFAULT 'PENDING',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_users_email (email),
  KEY idx_users_role_status (role, status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. Trainee Profiles (1:1 extension of users with role TRAINEE)
CREATE TABLE IF NOT EXISTS trainee_profiles (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id INT UNSIGNED NOT NULL,
  headline VARCHAR(255) DEFAULT NULL,
  organization VARCHAR(255) DEFAULT NULL,
  biography TEXT DEFAULT NULL,
  qualifications TEXT DEFAULT NULL,
  work_experience TEXT DEFAULT NULL,
  interests TEXT DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_trainee_profiles_user_id (user_id),
  CONSTRAINT fk_trainee_profiles_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. Trainer Profiles (1:1 extension of users with role TRAINER)
CREATE TABLE IF NOT EXISTS trainer_profiles (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id INT UNSIGNED NOT NULL,
  headline VARCHAR(255) DEFAULT NULL,
  organization VARCHAR(255) DEFAULT NULL,
  biography TEXT DEFAULT NULL,
  qualifications TEXT DEFAULT NULL,
  work_experience TEXT DEFAULT NULL,
  subject_expertise TEXT DEFAULT NULL,
  years_of_experience INT UNSIGNED DEFAULT 0,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_trainer_profiles_user_id (user_id),
  CONSTRAINT fk_trainer_profiles_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 4. Shared Skills Catalog
CREATE TABLE IF NOT EXISTS skills (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL,
  category VARCHAR(100) DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_skills_name (name),
  KEY idx_skills_category (category)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 5. Trainee Skills (Many-to-Many: Trainees <-> Skills)
CREATE TABLE IF NOT EXISTS trainee_skills (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id INT UNSIGNED NOT NULL,
  skill_id INT UNSIGNED NOT NULL,
  proficiency ENUM('BEGINNER', 'INTERMEDIATE', 'ADVANCED', 'EXPERT') DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_trainee_skills_user_skill (user_id, skill_id),
  KEY idx_trainee_skills_skill_id (skill_id),
  CONSTRAINT fk_trainee_skills_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
  CONSTRAINT fk_trainee_skills_skill FOREIGN KEY (skill_id) REFERENCES skills (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 6. Trainer Skills (Many-to-Many: Trainers <-> Skills)
CREATE TABLE IF NOT EXISTS trainer_skills (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id INT UNSIGNED NOT NULL,
  skill_id INT UNSIGNED NOT NULL,
  proficiency ENUM('BEGINNER', 'INTERMEDIATE', 'ADVANCED', 'EXPERT') DEFAULT NULL,
  years_of_experience INT UNSIGNED DEFAULT 0,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_trainer_skills_user_skill (user_id, skill_id),
  KEY idx_trainer_skills_skill_id (skill_id),
  CONSTRAINT fk_trainer_skills_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
  CONSTRAINT fk_trainer_skills_skill FOREIGN KEY (skill_id) REFERENCES skills (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
