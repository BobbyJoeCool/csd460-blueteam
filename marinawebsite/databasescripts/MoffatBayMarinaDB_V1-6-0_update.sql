-- =============================================================================
-- Team: Blue Team
-- Roster: Breutzmann, R. | White, S. | Fernandez, M. | Rodriguez, C.
-- CSD 460 - Moffat Bay Marina
-- File: MoffatBayMarinaDB_V1-6-0_update.sql
-- Purpose: Adds Reservation.electricalHookup - whether this reservation
--          includes the optional electric hookup.
--
--          The Reservation page has asked this question since it was built
--          and there was nowhere to put the answer. Reservation.monthlyRate
--          stores the blended total the customer was quoted, so a booking
--          with electric and a booking without it are indistinguishable
--          once saved: 26 ft of boat plus electric and 27 ft of boat
--          without it both come to $283.50. The marina needs to know who
--          has a hookup - it is a physical thing plugged in at the slip,
--          not only a line on an invoice.
--
--          Boolean rather than a second money column. The amount lives in
--          Rate ('ELECTRIC_MONTHLY'), added in V1-5-0, and the total lives
--          in Reservation.monthlyRate; this column records only whether the
--          fee is part of that total. See the ERD's Design Decisions for
--          the tradeoff that comes with that.
--
--          Unlike MoffatBayMarinaDB_V1-4-0.sql, this does NOT drop or
--          recreate the database - it alters the existing
--          MoffatBayMarinaDB in place, so existing data survives.
-- Version: 1.6.0
-- Date: 2026-09-10
-- =============================================================================
-- Run this script as a MySQL admin/root user against an existing database
-- (e.g. `mysql -u root -p MoffatBayMarinaDB < MoffatBayMarinaDB_V1-6-0_update.sql`).
-- Expects a database already at 1.5.0. Run once - like the CREATE TABLE in
-- V1-5-0, the ALTER below fails rather than doing nothing if the column is
-- already there, which is the intended behaviour: it says so instead of
-- pretending it ran.
-- =============================================================================

USE MoffatBayMarinaDB;

-- =============================================================================
-- 1. Schema Changes - Reservation.electricalHookup
-- =============================================================================
-- NOT NULL with a default of FALSE: every existing row needs an answer, and
-- "no hookup" is the only answer that can be given honestly. There is no
-- way to work out which of the 60 seeded reservations had electric.
--
-- Placed next to monthlyRate rather than at the end of the table, so the
-- two columns that describe what the customer is paying for sit together.

ALTER TABLE Reservation
    ADD COLUMN electricalHookup BOOLEAN NOT NULL DEFAULT FALSE
        COMMENT 'TRUE if this reservation includes the optional electric hookup. The fee itself is Rate.ELECTRIC_MONTHLY and is already counted in monthlyRate.'
        AFTER monthlyRate;

-- To confirm it applied:
--   SHOW COLUMNS FROM Reservation LIKE 'electricalHookup';
--   SELECT electricalHookup, COUNT(*) FROM Reservation GROUP BY electricalHookup;
-- The second returns a single row - 0 (false), 60 - on a freshly updated
-- database, since every existing reservation takes the default.

-- =============================================================================
-- Record this version in DatabaseVersion
-- =============================================================================

INSERT INTO DatabaseVersion (version, appliedDate, description) VALUES
    ('1.6.0', CURDATE(), 'Adds Reservation.electricalHookup (BOOLEAN NOT NULL DEFAULT FALSE) - records whether a reservation includes the optional electric hookup.');
