-- =============================================================================
-- Team: Blue Team
-- Roster: Breutzmann, R. | White, S. | Fernandez, M. | Rodriguez, C.
-- CSD 460 - Moffat Bay Marina
-- File: MoffatBayMarinaDB_V1-1-0_update.sql
-- Purpose: Adds the four Customer columns that application code already
--          expects but V1-0-0 never created:
--            - failedLoginAttempts / accountLocked, read and written by
--              CustomerDAO for the Login contract's lockout flow. Without
--              these, every call to CustomerDAO.findByEmail throws an
--              SQLException on an unknown column, so no login attempt
--              reaches the page at all.
--            - phoneCountryCode / streetAddress2, collected by the
--              Registration form per the Registration contract's
--              "Phone Number" and "The Address Field" sections.
--          Customer table owner: Fernandez, M.
--          Unlike MoffatBayMarinaDB_V1-0-0.sql, this does NOT drop or
--          recreate the database - it alters the existing
--          MoffatBayMarinaDB in place, so existing data survives.
-- Version: 1.1.0
-- Date: 2026-08-31
-- =============================================================================
-- Run this script as a MySQL admin/root user against an existing database
-- (e.g. `mysql -u root -p MoffatBayMarinaDB < MoffatBayMarinaDB_V1-1-0_update.sql`).
-- Safe to run on a database already seeded by V1-0-0; no seed data is touched.
-- =============================================================================

USE MoffatBayMarinaDB;

-- =============================================================================
-- Schema Changes
-- =============================================================================

ALTER TABLE Customer
    ADD COLUMN failedLoginAttempts INT NOT NULL DEFAULT 0
        COMMENT 'Consecutive failed login attempts since the last successful login. Reset to 0 on success, per BR/Login contract.',
    ADD COLUMN accountLocked BOOLEAN NOT NULL DEFAULT FALSE
        COMMENT 'TRUE once failedLoginAttempts reaches 3. A locked account is rejected before the password is even checked.',
    ADD COLUMN phoneCountryCode VARCHAR(3) NOT NULL DEFAULT '1'
        COMMENT 'Dialing country code, kept separate from the 10-digit phone column. Defaults to 1 (US/Canada).',
    ADD COLUMN streetAddress2 VARCHAR(100) NULL
        COMMENT 'Optional second address line - apartment, suite, PO box.';

-- Existing seeded customers get the defaults above: 0 failed attempts,
-- unlocked, country code 1, no second address line. That leaves every
-- V1-0-0 account able to log in exactly as before.

-- =============================================================================
-- Record this version in DatabaseVersion
-- =============================================================================

INSERT INTO DatabaseVersion (version, appliedDate, description) VALUES
    ('1.1.0', CURDATE(), 'Customer: adds failedLoginAttempts and accountLocked for the login lockout flow, plus phoneCountryCode and streetAddress2 for the registration form.');
