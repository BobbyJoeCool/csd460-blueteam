-- =============================================================================
-- Team: Blue Team
-- Roster: Breutzmann, R. | White, S. | Fernandez, M. | Rodriguez, C.
-- CSD 460 - Moffat Bay Marina
-- File: 02_seed_data.sql
-- Purpose: Populate each team member's tables with placeholder dev data.
--          Safe to re-run - INSERT IGNORE plus the unique constraints on
--          dock.dockNumber and slip(dockID, slipNumber) skip rows that
--          already exist.
-- Comment citation: Inline comments in this file were drafted with the
--          assistance of Claude (Anthropic) and reviewed by the
--          database lead, Breutzmann, R.
-- Version: 0.5.0 (in progress - moves to 1.0.0 once every team member's
--          tables/seed data are in)
-- Date: 2026-08-25
-- =============================================================================

USE moffatBayMarinaDB;

-- =============================================================================
-- Section: Breutzmann, R. - Dock & Slip Seed Data
-- =============================================================================
-- Dock layout: 6 docks (A-F), all sited along the marina's single
-- harbor-side shoreline (per client notes, not split across sides
-- of the island).
--
-- Slip size mix: no slip counts are specified anywhere in the project
-- docs (README, definitions.md, ERD). The 2:2:1 ratio (26 ft : 40 ft : 50 ft)
-- is a developer decision made by the team for placeholder dev data, not
-- looked up from any source - adjust if the client specifies real numbers.
--
-- Per dock (10 slips): 4 x 26 ft, 4 x 40 ft, 2 x 50 ft.
-- Total: 60 slips (24 x 26 ft, 24 x 40 ft, 12 x 50 ft).

-- ---------------------------------------------------------------------------
-- Docks
-- ---------------------------------------------------------------------------
INSERT IGNORE INTO dock (dockNumber, dockDescription) VALUES
    ('A', 'Dock A, pier 1 of 6 along the marina harbor shoreline.'),
    ('B', 'Dock B, pier 2 of 6 along the marina harbor shoreline.'),
    ('C', 'Dock C, pier 3 of 6 along the marina harbor shoreline.'),
    ('D', 'Dock D, pier 4 of 6 along the marina harbor shoreline.'),
    ('E', 'Dock E, pier 5 of 6 along the marina harbor shoreline.'),
    ('F', 'Dock F, pier 6 of 6 along the marina harbor shoreline.');

-- ---------------------------------------------------------------------------
-- Slips (10 per dock: 4 x 26ft, 4 x 40ft, 2 x 50ft)
-- ---------------------------------------------------------------------------
-- Dock A: 10 slips (4 x 26ft, 4 x 40ft, 2 x 50ft)
INSERT IGNORE INTO slip (slipNumber, slipDescription, dockID, slipStatus, slipSize)
SELECT v.slipNumber, v.slipDescription, d.dockID, 'available', v.slipSize
FROM dock d
JOIN (
    SELECT 1 AS slipNumber, '26 ft slip on Dock A.' AS slipDescription, 26 AS slipSize
    UNION ALL SELECT 2, '26 ft slip on Dock A.', 26
    UNION ALL SELECT 3, '26 ft slip on Dock A.', 26
    UNION ALL SELECT 4, '26 ft slip on Dock A.', 26
    UNION ALL SELECT 5, '40 ft slip on Dock A.', 40
    UNION ALL SELECT 6, '40 ft slip on Dock A.', 40
    UNION ALL SELECT 7, '40 ft slip on Dock A.', 40
    UNION ALL SELECT 8, '40 ft slip on Dock A.', 40
    UNION ALL SELECT 9, '50 ft slip on Dock A.', 50
    UNION ALL SELECT 10, '50 ft slip on Dock A.', 50
) v ON d.dockNumber = 'A';

-- Dock B: 10 slips (4 x 26ft, 4 x 40ft, 2 x 50ft)
INSERT IGNORE INTO slip (slipNumber, slipDescription, dockID, slipStatus, slipSize)
SELECT v.slipNumber, v.slipDescription, d.dockID, 'available', v.slipSize
FROM dock d
JOIN (
    SELECT 1 AS slipNumber, '26 ft slip on Dock B.' AS slipDescription, 26 AS slipSize
    UNION ALL SELECT 2, '26 ft slip on Dock B.', 26
    UNION ALL SELECT 3, '26 ft slip on Dock B.', 26
    UNION ALL SELECT 4, '26 ft slip on Dock B.', 26
    UNION ALL SELECT 5, '40 ft slip on Dock B.', 40
    UNION ALL SELECT 6, '40 ft slip on Dock B.', 40
    UNION ALL SELECT 7, '40 ft slip on Dock B.', 40
    UNION ALL SELECT 8, '40 ft slip on Dock B.', 40
    UNION ALL SELECT 9, '50 ft slip on Dock B.', 50
    UNION ALL SELECT 10, '50 ft slip on Dock B.', 50
) v ON d.dockNumber = 'B';

-- Dock C: 10 slips (4 x 26ft, 4 x 40ft, 2 x 50ft)
INSERT IGNORE INTO slip (slipNumber, slipDescription, dockID, slipStatus, slipSize)
SELECT v.slipNumber, v.slipDescription, d.dockID, 'available', v.slipSize
FROM dock d
JOIN (
    SELECT 1 AS slipNumber, '26 ft slip on Dock C.' AS slipDescription, 26 AS slipSize
    UNION ALL SELECT 2, '26 ft slip on Dock C.', 26
    UNION ALL SELECT 3, '26 ft slip on Dock C.', 26
    UNION ALL SELECT 4, '26 ft slip on Dock C.', 26
    UNION ALL SELECT 5, '40 ft slip on Dock C.', 40
    UNION ALL SELECT 6, '40 ft slip on Dock C.', 40
    UNION ALL SELECT 7, '40 ft slip on Dock C.', 40
    UNION ALL SELECT 8, '40 ft slip on Dock C.', 40
    UNION ALL SELECT 9, '50 ft slip on Dock C.', 50
    UNION ALL SELECT 10, '50 ft slip on Dock C.', 50
) v ON d.dockNumber = 'C';

-- Dock D: 10 slips (4 x 26ft, 4 x 40ft, 2 x 50ft)
INSERT IGNORE INTO slip (slipNumber, slipDescription, dockID, slipStatus, slipSize)
SELECT v.slipNumber, v.slipDescription, d.dockID, 'available', v.slipSize
FROM dock d
JOIN (
    SELECT 1 AS slipNumber, '26 ft slip on Dock D.' AS slipDescription, 26 AS slipSize
    UNION ALL SELECT 2, '26 ft slip on Dock D.', 26
    UNION ALL SELECT 3, '26 ft slip on Dock D.', 26
    UNION ALL SELECT 4, '26 ft slip on Dock D.', 26
    UNION ALL SELECT 5, '40 ft slip on Dock D.', 40
    UNION ALL SELECT 6, '40 ft slip on Dock D.', 40
    UNION ALL SELECT 7, '40 ft slip on Dock D.', 40
    UNION ALL SELECT 8, '40 ft slip on Dock D.', 40
    UNION ALL SELECT 9, '50 ft slip on Dock D.', 50
    UNION ALL SELECT 10, '50 ft slip on Dock D.', 50
) v ON d.dockNumber = 'D';

-- Dock E: 10 slips (4 x 26ft, 4 x 40ft, 2 x 50ft)
INSERT IGNORE INTO slip (slipNumber, slipDescription, dockID, slipStatus, slipSize)
SELECT v.slipNumber, v.slipDescription, d.dockID, 'available', v.slipSize
FROM dock d
JOIN (
    SELECT 1 AS slipNumber, '26 ft slip on Dock E.' AS slipDescription, 26 AS slipSize
    UNION ALL SELECT 2, '26 ft slip on Dock E.', 26
    UNION ALL SELECT 3, '26 ft slip on Dock E.', 26
    UNION ALL SELECT 4, '26 ft slip on Dock E.', 26
    UNION ALL SELECT 5, '40 ft slip on Dock E.', 40
    UNION ALL SELECT 6, '40 ft slip on Dock E.', 40
    UNION ALL SELECT 7, '40 ft slip on Dock E.', 40
    UNION ALL SELECT 8, '40 ft slip on Dock E.', 40
    UNION ALL SELECT 9, '50 ft slip on Dock E.', 50
    UNION ALL SELECT 10, '50 ft slip on Dock E.', 50
) v ON d.dockNumber = 'E';

-- Dock F: 10 slips (4 x 26ft, 4 x 40ft, 2 x 50ft)
INSERT IGNORE INTO slip (slipNumber, slipDescription, dockID, slipStatus, slipSize)
SELECT v.slipNumber, v.slipDescription, d.dockID, 'available', v.slipSize
FROM dock d
JOIN (
    SELECT 1 AS slipNumber, '26 ft slip on Dock F.' AS slipDescription, 26 AS slipSize
    UNION ALL SELECT 2, '26 ft slip on Dock F.', 26
    UNION ALL SELECT 3, '26 ft slip on Dock F.', 26
    UNION ALL SELECT 4, '26 ft slip on Dock F.', 26
    UNION ALL SELECT 5, '40 ft slip on Dock F.', 40
    UNION ALL SELECT 6, '40 ft slip on Dock F.', 40
    UNION ALL SELECT 7, '40 ft slip on Dock F.', 40
    UNION ALL SELECT 8, '40 ft slip on Dock F.', 40
    UNION ALL SELECT 9, '50 ft slip on Dock F.', 50
    UNION ALL SELECT 10, '50 ft slip on Dock F.', 50
) v ON d.dockNumber = 'F';

-- =============================================================================
-- Section: White, S. - Seed Data TBD
-- =============================================================================
-- TODO (White, S.): add this section's INSERT statements here.

-- =============================================================================
-- Section: Fernandez, M. - Seed Data TBD
-- =============================================================================
-- TODO (Fernandez, M.): add this section's INSERT statements here.

-- =============================================================================
-- Section: Rodriguez, C. - Seed Data TBD
-- =============================================================================
-- TODO (Rodriguez, C.): add this section's INSERT statements here.
