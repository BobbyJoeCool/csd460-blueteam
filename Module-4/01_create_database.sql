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
--          TEMPORARY EXCEPTION: while the schema is still changing shape
--          across team members, this file drops and recreates the database
--          on every run (see the DROP DATABASE line below) so nobody is
--          stuck with a stale table left over from an earlier version.
--          That line makes the whole script destructive to existing data -
--          remove it once the database is fully up and running.
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
-- TODO: remove this line once the database is fully up and running. Until
-- then, every run wipes the database clean so schema changes never leave
-- behind a table/column shaped the old way - this deletes all data on every
-- run, do not leave it in past active development.
DROP DATABASE IF EXISTS moffatBayMarinaDB;
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
    slipStatus ENUM ('operational', 'maintenance', 'unavailable') NOT NULL DEFAULT 'operational' COMMENT 'Occupied status of the slip.',
    slipSize INT NOT NULL COMMENT 'Slip length in feet: 26, 40, or 50.',
    CONSTRAINT chkSlipSize CHECK (slipSize IN (26, 40, 50)),
    CONSTRAINT uqDockSlipNumber UNIQUE (dockID, slipNumber)
);

-- Contact Us page submissions (see ERD.md v1.2.0). Deliberately has no FK to
-- customer/boat - a submitter may not be a registered customer yet, so
-- boatName/boatLength are free text the visitor typed in, not references.
CREATE TABLE IF NOT EXISTS contact (
    contactID INT AUTO_INCREMENT PRIMARY KEY,
    firstName VARCHAR(50) NOT NULL COMMENT 'Contact''s first name, required.',
    lastName VARCHAR(50) NOT NULL COMMENT 'Contact''s last name, required.',
    email VARCHAR(255) NOT NULL COMMENT 'Contact''s email address, required.',
    boatName VARCHAR(100) COMMENT 'Name of the contact''s boat, optional - free text, not a link to the boat table.',
    boatLength DECIMAL(6,2) COMMENT 'Length of the contact''s boat in feet, optional.',
    reasonForContact ENUM ('Reservation Question', 'Waitlist Question', 'Billing', 'Maintenance Issue', 'General Inquiry', 'Other') NOT NULL COMMENT 'Reason the contact form was submitted.',
    message TEXT NOT NULL COMMENT 'Full text of the message submitted.',
    responded BOOLEAN NOT NULL DEFAULT FALSE COMMENT 'Whether marina staff has responded to this submission.',
    respondedDate TIMESTAMP NULL COMMENT 'Date/time staff responded, null until responded.',
    respondedMessage TEXT COMMENT 'Staff''s response message, null until responded.',
    respondedEmployeeID INT NULL COMMENT 'References employee.employeeID - the employee who responded, null until responded.'
);

-- Staff accounts (see ERD.md). Employees log in and respond to Contact
-- submissions via contact.respondedEmployeeID.
CREATE TABLE IF NOT EXISTS employee (
    employeeID INT AUTO_INCREMENT PRIMARY KEY,
    firstName VARCHAR(50) NOT NULL COMMENT 'Employee first name.',
    lastName VARCHAR(50) NOT NULL COMMENT 'Employee last name.',
    email VARCHAR(255) NOT NULL UNIQUE COMMENT 'Login username and contact email.',
    passwordHash VARCHAR(255) NOT NULL COMMENT 'Hashed password, validated in Java before hashing.',
    phone VARCHAR(20) COMMENT 'Contact phone number.',
    role VARCHAR(50) COMMENT 'Employee job role/title.',
    hireDate DATE COMMENT 'Date employee was hired.'
);

-- =============================================================================
-- Section: White, S. - Tables SlipSize, WaitList, BoatOwnership
-- =============================================================================

CREATE TABLE IF NOT EXISTS SlipSize (
    slipSizeId INT AUTO_INCREMENT PRIMARY KEY,
    sizeFt INT NOT NULL UNIQUE COMMENT 'Slip size category in feet.'
);

CREATE TABLE IF NOT EXISTS WaitList (
    waitListId INT AUTO_INCREMENT PRIMARY KEY,
    customerId INT NOT NULL COMMENT 'Customer requesting a slip.',
    slipSizeId INT NOT NULL COMMENT 'Requested slip size category.',
    timeJoined TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Date and time customer joined the wait list.',
    timeClosed TIMESTAMP NULL COMMENT 'Date and time wait list entry was closed; null while active.',
    status ENUM('Waiting', 'Offered', 'Fulfilled', 'Cancelled') NOT NULL DEFAULT 'Waiting' COMMENT 'Current status of the wait list entry.');

CREATE TABLE IF NOT EXISTS BoatOwnership (
    ownershipId INT AUTO_INCREMENT PRIMARY KEY,
    boatId INT NOT NULL COMMENT 'References the physical boat.',
    customerId INT NOT NULL COMMENT 'References the customer who owns or owned the boat.',
startDate DATE NOT NULL COMMENT 'Date ownership began.',
    endDate DATE NULL COMMENT 'Date ownership ended; NULL for current ownership.',
    CONSTRAINT chkOwnershipDates CHECK (endDate IS NULL OR endDate >= startDate)
);

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

-- Contact -> Employee
-- Placed here (rather than after the Reservation FKs below) so it still
-- runs even while Reservation's FKs fail for lack of a customer/boat table -
-- contact and employee both already exist, so this one doesn't need to wait.
SET @fk_exists = (
    SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS
    WHERE CONSTRAINT_SCHEMA = 'moffatBayMarinaDB' AND CONSTRAINT_NAME = 'fkContactRespondedEmployeeID'
);
SET @ddl = IF(@fk_exists = 0,
    'ALTER TABLE contact ADD CONSTRAINT fkContactRespondedEmployeeID FOREIGN KEY (respondedEmployeeID) REFERENCES employee (employeeID)',
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