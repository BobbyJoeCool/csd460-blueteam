-- =============================================================================
-- Team: Blue Team
-- Roster: Breutzmann, R. | White, S. | Fernandez, M. | Rodriguez, C.
-- CSD 460 - Moffat Bay Marina
-- File: currentVersion.sql
-- Purpose: Returns only the most recently applied row from DatabaseVersion -
--          i.e. the version currently running on this database instance.
--          Read-only; safe to run at any time, makes no changes.
-- =============================================================================

USE MoffatBayMarinaDB;

SELECT *
FROM DatabaseVersion
ORDER BY databaseVersionID DESC
LIMIT 1;
