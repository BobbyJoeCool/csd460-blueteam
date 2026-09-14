-- =============================================================================
-- Team: Blue Team
-- Roster: Breutzmann, R. | White, S. | Fernandez, M. | Rodriguez, C.
-- CSD 460 - Moffat Bay Marina
-- File: MoffatBayMarinaDB_V1-7-0_update.sql
-- Purpose: Rewrites Dock.dockDescription for all three docks.
--
--          Gives each dock a plain compass name (A = Eastern, B = Central,
--          C = Western) and reassigns which landmark each is described as
--          closest to: Dock B now carries "closest to the Office &
--          Restaurant" (previously lumped in with Dock C's description),
--          and Dock C is described as closest to the Fueling Station only.
--          This matches marina_a.png - the Office & Restaurant marker sits
--          measurably closer to Dock B than Dock C, and the Fuel Dock
--          marker sits past Dock C's end, so splitting the two dock C used
--          to claim brings the text in line with the map instead of
--          contradicting it.
--
--          Each description is now three lines (name, compass label,
--          nearest landmark) separated by CHAR(10), rather than one
--          sentence, so the Reservation page's dock cards can render it as
--          a short stat list. reservation.css needs `white-space: pre-line`
--          on `.dock-card__desc` for the line breaks to actually show;
--
-- Version: 1.7.0
-- Date: 2026-09-11
-- =============================================================================
-- Run this script as a MySQL admin/root user against an existing database
-- (e.g. `mysql -u root -p MoffatBayMarinaDB < MoffatBayMarinaDB_V1-7-0_update.sql`).
-- Data-only - no schema change, safe to re-run.
-- =============================================================================

USE MoffatBayMarinaDB;

-- =============================================================================
-- 1. Data Update - Dock.dockDescription
-- =============================================================================

UPDATE Dock
SET dockDescription = CONCAT('Linear Dock A', CHAR(10), 'Eastern Dock', CHAR(10), 'Closest to the Ship Store')
WHERE dockNumber = 'A';

UPDATE Dock
SET dockDescription = CONCAT('Linear Dock B', CHAR(10), 'Central Dock', CHAR(10), 'Closest to the Office & Restaurant')
WHERE dockNumber = 'B';

UPDATE Dock
SET dockDescription = CONCAT('Linear Dock C', CHAR(10), 'Western Dock', CHAR(10), 'Closest to the Fueling Station')
WHERE dockNumber = 'C';

-- To confirm it applied:
--   SELECT dockNumber, dockDescription FROM Dock ORDER BY dockNumber;

-- =============================================================================
-- Record this version in DatabaseVersion
-- =============================================================================

INSERT INTO DatabaseVersion (version, appliedDate, description) VALUES
    ('1.7.0', CURDATE(), 'Rewrites Dock.dockDescription as a three-line name/compass-label/landmark stat block; Dock B now closest to Office & Restaurant, Dock C closest to Fueling Station only.');
