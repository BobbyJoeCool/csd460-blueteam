-- =============================================================================
-- Team: Blue Team
-- Roster: Breutzmann, R. | White, S. | Fernandez, M. | Rodriguez, C.
-- CSD 460 - Moffat Bay Marina
-- File: updateTemplate.sql
-- Purpose: TEMPLATE for a future schema update script. Copy this file,
--          rename it to match the version it applies (e.g.
--          MoffatBayMarinaDB_V1-1-0_update.sql), fill in the blanks below,
--          and add this update's actual ALTER TABLE / CREATE TABLE / etc.
--          statements in the "Schema Changes" section.
--          Unlike MoffatBayMarinaDB_V1-0-0.sql, this does NOT drop or
--          recreate the database - it applies changes to an EXISTING
--          moffatBayMarinaDB in place, so existing data survives.
-- Version: <fill in - the version this update brings the database to>
-- Date: <fill in>
-- =============================================================================
-- Run this script as a MySQL admin/root user against an existing database
-- (e.g. `mysql -u root -p moffatBayMarinaDB < <renamed copy of this file>`).
-- =============================================================================

USE MoffatBayMarinaDB;

-- =============================================================================
-- Schema Changes
-- =============================================================================
-- TODO: add this update's ALTER TABLE / CREATE TABLE / etc. statements here.

-- =============================================================================
-- Record this version in DatabaseVersion
-- =============================================================================
-- TODO: fill in version and description before running - appliedDate is
-- left as CURDATE() so it always reflects the date this update actually runs.
INSERT INTO DatabaseVersion (version, appliedDate, description) VALUES
    ('', CURDATE(), '');
