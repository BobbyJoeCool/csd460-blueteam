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
-- Version: 1.1.0
-- Date: 2026-08-27
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

CREATE TABLE IF NOT EXISTS dock (
    dockID INT AUTO_INCREMENT PRIMARY KEY,
    dockNumber VARCHAR(1) NOT NULL UNIQUE COMMENT 'Customer facing dock letter, e.g. A-C.',
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

CREATE TABLE Reservation (
    reservationId INT AUTO_INCREMENT PRIMARY KEY,
    confirmationNumber VARCHAR(30) NOT NULL UNIQUE,
    customerId INT NOT NULL,
    boatId INT NOT NULL,
    slipId INT NOT NULL,
    startDate DATE NOT NULL,
    monthlyRate DECIMAL(10,2) NOT NULL
);
CREATE TABLE TerminationNotice (
    terminationNoticeId INT AUTO_INCREMENT PRIMARY KEY,
    reservationId INT NOT NULL UNIQUE,
    noticeDate DATE NOT NULL,
    terminationDate DATE NULL,

    noticeStatus ENUM(
        'Submitted',
        'Pending',
        'Approved',
        'Withdrawn',
        'Completed'
    ) NOT NULL
);
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

-- Reservation -> Customer
SET @fk_exists = (
    SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS
    WHERE CONSTRAINT_SCHEMA = 'moffatBayMarinaDB' AND CONSTRAINT_NAME = 'fk_reservation_customer'
);

SET @ddl = IF(
    @fk_exists = 0,
    'ALTER TABLE Reservation ADD CONSTRAINT fk_reservation_customer FOREIGN KEY (customerId) REFERENCES customer(customerId)',
    'SELECT 1'
);
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;


-- Reservation -> Boat
SET @fk_exists = (
    SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS WHERE CONSTRAINT_SCHEMA = 'moffatBayMarinaDB' AND CONSTRAINT_NAME = 'fk_reservation_boat'
);

SET @ddl = IF(
    @fk_exists = 0,
    'ALTER TABLE Reservation ADD CONSTRAINT fk_reservation_boat FOREIGN KEY (boatId) REFERENCES boat(boatId)',
    'SELECT 1'
);
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;


-- Reservation -> Slip
SET @fk_exists = (
    SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS WHERE CONSTRAINT_SCHEMA = 'moffatBayMarinaDB' AND CONSTRAINT_NAME = 'fk_reservation_slip'
);

SET @ddl = IF(
    @fk_exists = 0,
    'ALTER TABLE Reservation ADD CONSTRAINT fk_reservation_slip FOREIGN KEY (slipId) REFERENCES slip(slipId)',
    'SELECT 1'
);

PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;


-- TerminationNotice -> Reservation
SET @fk_exists = (
    SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS WHERE CONSTRAINT_SCHEMA = 'moffatBayMarinaDB' AND CONSTRAINT_NAME = 'fk_terminationNotice_reservation'
);

SET @ddl = IF(
    @fk_exists = 0,
    'ALTER TABLE TerminationNotice ADD CONSTRAINT fk_terminationNotice_reservation FOREIGN KEY (reservationId) REFERENCES Reservation(reservationId)',
    'SELECT 1'
);

PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Pending: slip.slipSizeID -> SlipSize(slipSizeID), once White, S. creates
-- the SlipSize table (see ERD.md v1.1.0). Commented out for now since that
-- table doesn't exist yet - uncomment once it does. ERD.md v1.1.0 settles
-- SlipSize on a surrogate slipSizeID PK (sizeFt is UNIQUE but not the PK),
-- and slip's own column is now slipSizeID (FK), not the old slipSize enum
-- column - update this block if slip's column name changes when the table
-- is actually created.
-- SET @fk_exists = (
--     SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS
--     WHERE CONSTRAINT_SCHEMA = 'moffatBayMarinaDB' AND CONSTRAINT_NAME = 'fkSlipSlipSize'
-- );
-- SET @ddl = IF(@fk_exists = 0,
--     'ALTER TABLE slip ADD CONSTRAINT fkSlipSlipSize FOREIGN KEY (slipSizeID) REFERENCES SlipSize (slipSizeID)',
--     'SELECT 1');
-- PREPARE stmt FROM @ddl;
-- EXECUTE stmt;
-- DEALLOCATE PREPARE stmt;

-- TODO: add remaining FKs here using the same guarded pattern as more tables are created.