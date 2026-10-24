-- CAPSERA Database Initialization
-- File: database/001_initial_setup.sql
-- Description: Creates the capsera_db database if it does not exist and sets UTF-8 encoding.
--
-- Run this setup script first:
--   mysql -u root -p < database/001_initial_setup.sql
--
-- NOTE: Application tables are managed via ordered migrations under database/migrations/.
-- Do not add application table definitions here to prevent duplication.

CREATE DATABASE IF NOT EXISTS capsera_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE capsera_db;
