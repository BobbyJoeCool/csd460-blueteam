-- =============================================================================
-- Team: Blue Team
-- Roster: Breutzmann, R. | White, S. | Fernandez, M. | Rodriguez, C.
-- CSD 460 - Moffat Bay Marina
-- File: MoffatBayMarinaDB_V1-3-0_update.sql
-- Purpose: Drops Boat.regState. The Registration page no longer has a
--          separate Registration State/Province <select> - the owner
--          types the state/province prefix as part of Registration
--          Number itself (e.g. "WN1234AB"), and RegisterServlet's
--          REG_NUMBER_PATTERN / CA_REG_NUMBER_PATTERN now require that
--          prefix to be present. See the Registration contract's
--          "Boat Fields" section.
--          Also makes regNumber nullable, matching how the field has
--          been optional at the application layer since the HIN-first
--          rework (V1-2-0 predates that fix; a NOT NULL regNumber was
--          never actually reachable once Registration became optional).
--          Boat table owner: Fernandez, M.
--          Unlike MoffatBayMarinaDB_V1-0-0.sql, this does NOT drop or
--          recreate the database - it alters the existing
--          MoffatBayMarinaDB in place, so existing data survives.
-- Version: 1.3.0
-- Date: 2026-09-06
-- =============================================================================
-- Run this script as a MySQL admin/root user against an existing database
-- (e.g. `mysql -u root -p MoffatBayMarinaDB < MoffatBayMarinaDB_V1-3-0_update.sql`).
-- Safe to run on a database already at 1.2.0.
-- =============================================================================

USE MoffatBayMarinaDB;

-- =============================================================================
-- Preserve existing data
-- =============================================================================
-- Fold the state/province prefix into regNumber before the separate
-- column goes away, so existing/seeded boats keep a complete
-- registration number instead of silently losing the state part.

UPDATE Boat
SET regNumber = CONCAT(regState, regNumber)
WHERE regState IS NOT NULL AND regNumber IS NOT NULL;

-- =============================================================================
-- Schema Changes
-- =============================================================================

ALTER TABLE Boat
    DROP INDEX uqBoatRegistration,
    DROP COLUMN regState,
    MODIFY COLUMN regNumber VARCHAR(20) NULL
        COMMENT 'Registration number, including the state/province prefix the owner typed (e.g. WN1234AB, or C1234AB for a Canadian Pleasure Craft Licence).',
    ADD CONSTRAINT uqBoatRegistration UNIQUE (regNumber);

-- =============================================================================
-- Record this version in DatabaseVersion
-- =============================================================================

INSERT INTO DatabaseVersion (version, appliedDate, description) VALUES
    ('1.3.0', CURDATE(), 'Boat: drops regState; regNumber now stores the full registration number including the state/province prefix, and is nullable.');
