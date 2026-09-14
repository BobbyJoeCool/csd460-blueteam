-- =============================================================================
-- Team: Blue Team
-- Roster: Breutzmann, R. | White, S. | Fernandez, M. | Rodriguez, C.
-- CSD 460 - Moffat Bay Marina
-- File: MoffatBayMarinaDB_V1-5-0_update.sql
-- Purpose: Two changes, both needed before the Reservation page can be built.
--
--          1. Adds the Rate table. Slip pricing is $10.50 per foot of BOAT
--             length per month, plus an optional flat $10.50 per month for
--             an electric hookup. Until now those figures existed nowhere
--             in the database at all - only as prose in the Reservation
--             contract - which would have left them hardcoded in
--             application code. Reservation.monthlyRate is calculated from
--             these values at booking time.
--             Rate table owner: Breutzmann, R. (Database Lead)
--
--          2. Repairs Boat.regNumber values doubled by V1-3-0. That script
--             ran CONCAT(regState, regNumber), but every seeded regNumber
--             already carried its state prefix ('WN1204JT'), so the concat
--             produced 'WAWN1204JT'. All 60 seeded boats match
--             RegisterServlet.REG_NUMBER_PATTERN before V1-3-0 and none of
--             them match it after. See Legacy/Week4/README.md.
--
--          Unlike MoffatBayMarinaDB_V1-4-0.sql, this does NOT drop or
--          recreate the database - it alters the existing
--          MoffatBayMarinaDB in place, so existing data survives.
-- Version: 1.5.0
-- Date: 2026-09-07
-- =============================================================================
-- Run this script as a MySQL admin/root user against an existing database
-- (e.g. `mysql -u root -p MoffatBayMarinaDB < MoffatBayMarinaDB_V1-5-0_update.sql`).
-- Safe to run on a database already at 1.4.0, however it was built:
--   - built from MoffatBayMarinaDB_V1-4-0.sql, the regNumber values are
--     already correct and section 2 below matches nothing and does nothing.
--   - built the old way (V1-0-0 plus the four updates), section 2 repairs
--     the doubled prefixes.
-- Either way the end state is the same.
-- =============================================================================

USE MoffatBayMarinaDB;

-- =============================================================================
-- 1. Schema Changes - Rate
-- =============================================================================
-- Deliberately a small standalone lookup, not a column on SlipSize: the
-- price follows the BOAT's length, so it does not vary by slip size and
-- has nothing to hang off that table.
--
-- Deliberately no effective-date range or rate history either. Every
-- Reservation already stores its own monthlyRate at the moment of booking,
-- so past reservations keep their old price with no help from this table.
-- Dated rates would solve a problem that is already solved.

CREATE TABLE Rate (
    rateID INT AUTO_INCREMENT PRIMARY KEY,
    rateCode VARCHAR(30) NOT NULL UNIQUE COMMENT 'Stable code the application looks a rate up by. Never change a code once it is in use - change the amount instead.',
    rateAmount DECIMAL(10,2) NOT NULL COMMENT 'Current amount in US dollars.',
    rateDescription VARCHAR(255) COMMENT 'What this rate is, in plain terms.',
    CONSTRAINT chkRateAmountPositive CHECK (rateAmount > 0)
);

-- Both figures already include the 5% increase applied this term; the
-- previous $10.00 rate never existed in this database, so there is nothing
-- to migrate and no transition period to handle.
INSERT INTO Rate (rateCode, rateAmount, rateDescription) VALUES
    ('SLIP_PER_FOOT_MONTHLY', 10.50, 'Monthly slip rent per foot of boat length.'),
    ('ELECTRIC_MONTHLY',      10.50, 'Optional monthly electric hookup, flat rate regardless of boat size.');

-- =============================================================================
-- 2. Data Repair - Boat.regNumber
-- =============================================================================
-- A correct registration number is two letters, then digits (WN1204JT).
-- A doubled one has four leading letters (WAWN1204JT). That difference is
-- what the guard below keys on, so any boat registered through the site
-- after V1-3-0 ran - which already has a correct single prefix - is left
-- alone. Rows with a NULL regNumber are skipped by REGEXP returning NULL.

UPDATE Boat
SET regNumber = SUBSTRING(regNumber, 3)
WHERE regNumber REGEXP '^[A-Za-z]{4}';

-- To see what this changed (or what it would have changed, run beforehand):
--   SELECT boatID, boatName, regNumber FROM Boat
--   WHERE regNumber REGEXP '^[A-Za-z]{4}';

-- =============================================================================
-- Record this version in DatabaseVersion
-- =============================================================================

INSERT INTO DatabaseVersion (version, appliedDate, description) VALUES
    ('1.5.0', CURDATE(), 'Adds the Rate table (per-foot slip rent and flat electric fee) and repairs Boat.regNumber values doubled by V1-3-0.');
