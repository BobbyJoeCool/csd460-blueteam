-- =============================================================================
-- Team: Blue Team
-- Roster: Breutzmann, R. | White, S. | Fernandez, M. | Rodriguez, C.
-- CSD 460 - Moffat Bay Marina
-- File: MoffatBayMarinaDB_V1-4-0_update.sql
-- Purpose: Adds Reservation.reservationStatus. The ERD has always included
--          this column, but V1-0-0 never created it. Adding it now so the
--          Reservation page (Module 6) can track whether a reservation is
--          Active, Cancelled, Completed, etc.
--          Reservation table owner: Rodriguez, C.
--          Unlike MoffatBayMarinaDB_V1-0-0.sql, this does NOT drop or
--          recreate the database - it alters the existing
--          MoffatBayMarinaDB in place, so existing data survives.
-- Version: 1.4.0
-- Date: 2026-09-06
-- =============================================================================
-- Run this script as a MySQL admin/root user against an existing database
-- (e.g. `mysql -u root -p MoffatBayMarinaDB < MoffatBayMarinaDB_V1-4-0_update.sql`).
-- Safe to run on a database already at 1.3.0.
-- =============================================================================

USE MoffatBayMarinaDB;

-- =============================================================================
-- Schema Changes
-- =============================================================================

ALTER TABLE Reservation
    ADD COLUMN reservationStatus VARCHAR(20) NOT NULL DEFAULT 'Active'
        COMMENT 'Current status of the reservation (e.g. Active, Cancelled, Completed).';

-- Existing seeded reservations default to 'Active', which is correct for
-- the current seed data - all 60 reservations represent current leases.

-- =============================================================================
-- Record this version in DatabaseVersion
-- =============================================================================

INSERT INTO DatabaseVersion (version, appliedDate, description) VALUES
    ('1.4.0', CURDATE(), 'Reservation: adds reservationStatus (designed in the ERD but missing from V1-0-0 creation script).');
