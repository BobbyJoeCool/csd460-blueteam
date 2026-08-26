-- =============================================================================
-- Team: Blue Team
-- Roster: Breutzmann, R. | White, S. | Fernandez, M. | Rodriguez, C.
-- CSD 460 - Moffat Bay Marina
-- File: 01_create_database.sql
-- Purpose: Create the marina database, an admin app user, and every
--          team member's tables. Safe to re-run - every statement is
--          "create if not exists" so it will not clobber existing data.
--          Tables are created without foreign keys; every FK is added
--          in the Foreign Keys section at the end, once all tables
--          exist, so table creation order and cross-table references
--          never conflict.
-- Comment citation: Inline comments in this file were drafted with the
--          assistance of Claude (Anthropic) and reviewed by the
--          database lead, Breutzmann, R.
-- Version: 0.5.0 (in progress - moves to 1.0.0 once every team member's
--          tables/seed data are in)
-- Date: 2026-08-25
-- =============================================================================
-- Run this script as a MySQL admin/root user (e.g. `mysql -u root -p < 01_create_database.sql`).
-- Each teammate runs this once against their own local MySQL instance.
-- =============================================================================
-- Shared Setup - Database & Admin User (Database Lead: Breutzmann, R.)
-- =============================================================================
CREATE DATABASE IF NOT EXISTS moffatBayMarinaDB;

-- Shared dev/test app user. Password is intentionally simple for local
-- dev use only, per the module requirement that every teammate stand up
-- an identical local environment (same DB name, user, and password).
CREATE USER IF NOT EXISTS 'captainAhab'@'localhost' IDENTIFIED BY 'Ahab1234!';

GRANT ALL PRIVILEGES ON moffatBayMarinaDB.* TO 'captainAhab'@'localhost' WITH GRANT OPTION;

FLUSH PRIVILEGES;

USE moffatBayMarinaDB;

-- =============================================================================
-- Section: Breutzmann, R. - Slip & Dock Tables
-- =============================================================================
-- See Module-3/ERD/slip.mmd for the source ERD.
CREATE TABLE IF NOT EXISTS dock (
    dockID INT AUTO_INCREMENT PRIMARY KEY,
    dockNumber VARCHAR(1) NOT NULL UNIQUE COMMENT 'Customer facing dock letter, e.g. A-F.',
    dockDescription VARCHAR(255) COMMENT 'A customer facing brief description of the dock.'
);

CREATE TABLE IF NOT EXISTS slip (
    slipID INT AUTO_INCREMENT PRIMARY KEY,
    slipNumber INT NOT NULL COMMENT 'Customer facing slip number.',
    slipDescription VARCHAR(255) COMMENT 'A customer facing brief description of the slip.',
    dockID INT NOT NULL,
    slipStatus ENUM ('available', 'occupied', 'maintenance') NOT NULL DEFAULT 'available' COMMENT 'Occupied status of the slip.',
    slipSize INT NOT NULL COMMENT 'Slip length in feet: 26, 40, or 50.',
    CONSTRAINT chkSlipSize CHECK (slipSize IN (26, 40, 50)),
    CONSTRAINT uqDockSlipNumber UNIQUE (dockID, slipNumber)
);

-- =============================================================================
-- Section: White, S. - Tables TBD
-- =============================================================================
-- TODO (White, S.): add this section's CREATE TABLE statements here.
-- =============================================================================
-- Section: Fernandez, M. - Tables TBD
-- =============================================================================
-- TODO (Fernandez, M.): add this section's CREATE TABLE statements here.
-- =============================================================================
-- Section: Rodriguez, C. - Tables TBD
-- =============================================================================
-- TODO (Rodriguez, C.): add this section's CREATE TABLE statements here.
-- =============================================================================
-- Foreign Keys (all team members)
-- =============================================================================
-- Every FK constraint lives here, added after all CREATE TABLE statements
-- above have run, so no table's FK can fail because a table it references
-- hasn't been created yet. Add your table's FK(s) below as ALTER TABLE
-- statements.
--
-- MySQL has no "ADD CONSTRAINT IF NOT EXISTS" for foreign keys, so a plain
-- ALTER TABLE here would error with "Duplicate foreign key constraint name"
-- on a second run. Each FK is instead added through a guarded block: check
-- information_schema for the constraint name, build the ALTER TABLE as text
-- only if it's missing (otherwise a no-op SELECT), then PREPARE/EXECUTE that
-- text, since MySQL can only run conditionally-built SQL via dynamic SQL
-- outside a stored procedure. Copy this pattern for each new FK below.

SET @fk_exists = (
    SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS
    WHERE CONSTRAINT_SCHEMA = 'moffatBayMarinaDB' AND CONSTRAINT_NAME = 'fkSlipDockID'
);
SET @ddl = IF(@fk_exists = 0,
    'ALTER TABLE slip ADD CONSTRAINT fkSlipDockID FOREIGN KEY (dockID) REFERENCES dock (dockID)',
    'SELECT 1');
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- TODO: add remaining FKs here using the same guarded pattern as more tables are created.