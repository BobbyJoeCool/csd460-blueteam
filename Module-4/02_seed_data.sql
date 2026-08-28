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
-- Version: 1.1.0 (tracks ERD.md; White, S. and Rodriguez, C. sections still
--          in progress - see the TODOs below)
-- Date: 2026-08-27
-- =============================================================================

USE moffatBayMarinaDB;

-- =============================================================================
-- Section: Breutzmann, R. - Dock & Slip Seed Data
-- =============================================================================
-- Dock layout: 3 docks (A, B, C), each a linear dock along the marina
-- harbor shoreline. Sourced from the client's marina map
-- (DevNotes/marina_a.png, from the "Moffat Bay Project.epub" client
-- packet) - this is real client data, not a developer placeholder.
--
-- Slip size mix: per the map's legend, each dock is laid out in two
-- mirrored columns of 12 slips (1-12 and 13-24). Within each column,
-- slips 1-3 and 13-15 = 50 ft, slips 4-7 and 16-19 = 40 ft, and
-- slips 8-12 and 20-24 = 26 ft.
--
-- Per dock (24 slips): 6 x 50 ft, 8 x 40 ft, 10 x 26 ft.
-- Total: 72 slips (18 x 50 ft, 24 x 40 ft, 30 x 26 ft).

-- ---------------------------------------------------------------------------
-- Docks
-- ---------------------------------------------------------------------------
INSERT IGNORE INTO dock (dockNumber, dockDescription) VALUES
    ('A', 'Linear Dock A, closest to the Ship Store.'),
    ('B', 'Linear Dock B, between Dock A and Dock C.'),
    ('C', 'Linear Dock C, closest to the Office & Restaurant and Fuel Dock.');

-- ---------------------------------------------------------------------------
-- Slips (24 per dock: 6 x 50ft, 8 x 40ft, 10 x 26ft - see marina map)
-- ---------------------------------------------------------------------------
-- Dock A: 24 slips (6 x 50ft, 8 x 40ft, 10 x 26ft)
INSERT IGNORE INTO slip (slipNumber, slipDescription, dockID, slipStatus, slipSize)
SELECT v.slipNumber, v.slipDescription, d.dockID, 'available', v.slipSize
FROM dock d
JOIN (
    SELECT 1 AS slipNumber, '50 ft slip on Dock A.' AS slipDescription, 50 AS slipSize
    UNION ALL SELECT 2, '50 ft slip on Dock A.', 50
    UNION ALL SELECT 3, '50 ft slip on Dock A.', 50
    UNION ALL SELECT 4, '40 ft slip on Dock A.', 40
    UNION ALL SELECT 5, '40 ft slip on Dock A.', 40
    UNION ALL SELECT 6, '40 ft slip on Dock A.', 40
    UNION ALL SELECT 7, '40 ft slip on Dock A.', 40
    UNION ALL SELECT 8, '26 ft slip on Dock A.', 26
    UNION ALL SELECT 9, '26 ft slip on Dock A.', 26
    UNION ALL SELECT 10, '26 ft slip on Dock A.', 26
    UNION ALL SELECT 11, '26 ft slip on Dock A.', 26
    UNION ALL SELECT 12, '26 ft slip on Dock A.', 26
    UNION ALL SELECT 13, '50 ft slip on Dock A.', 50
    UNION ALL SELECT 14, '50 ft slip on Dock A.', 50
    UNION ALL SELECT 15, '50 ft slip on Dock A.', 50
    UNION ALL SELECT 16, '40 ft slip on Dock A.', 40
    UNION ALL SELECT 17, '40 ft slip on Dock A.', 40
    UNION ALL SELECT 18, '40 ft slip on Dock A.', 40
    UNION ALL SELECT 19, '40 ft slip on Dock A.', 40
    UNION ALL SELECT 20, '26 ft slip on Dock A.', 26
    UNION ALL SELECT 21, '26 ft slip on Dock A.', 26
    UNION ALL SELECT 22, '26 ft slip on Dock A.', 26
    UNION ALL SELECT 23, '26 ft slip on Dock A.', 26
    UNION ALL SELECT 24, '26 ft slip on Dock A.', 26
) v ON d.dockNumber = 'A';

-- Dock B: 24 slips (6 x 50ft, 8 x 40ft, 10 x 26ft)
INSERT IGNORE INTO slip (slipNumber, slipDescription, dockID, slipStatus, slipSize)
SELECT v.slipNumber, v.slipDescription, d.dockID, 'available', v.slipSize
FROM dock d
JOIN (
    SELECT 1 AS slipNumber, '50 ft slip on Dock B.' AS slipDescription, 50 AS slipSize
    UNION ALL SELECT 2, '50 ft slip on Dock B.', 50
    UNION ALL SELECT 3, '50 ft slip on Dock B.', 50
    UNION ALL SELECT 4, '40 ft slip on Dock B.', 40
    UNION ALL SELECT 5, '40 ft slip on Dock B.', 40
    UNION ALL SELECT 6, '40 ft slip on Dock B.', 40
    UNION ALL SELECT 7, '40 ft slip on Dock B.', 40
    UNION ALL SELECT 8, '26 ft slip on Dock B.', 26
    UNION ALL SELECT 9, '26 ft slip on Dock B.', 26
    UNION ALL SELECT 10, '26 ft slip on Dock B.', 26
    UNION ALL SELECT 11, '26 ft slip on Dock B.', 26
    UNION ALL SELECT 12, '26 ft slip on Dock B.', 26
    UNION ALL SELECT 13, '50 ft slip on Dock B.', 50
    UNION ALL SELECT 14, '50 ft slip on Dock B.', 50
    UNION ALL SELECT 15, '50 ft slip on Dock B.', 50
    UNION ALL SELECT 16, '40 ft slip on Dock B.', 40
    UNION ALL SELECT 17, '40 ft slip on Dock B.', 40
    UNION ALL SELECT 18, '40 ft slip on Dock B.', 40
    UNION ALL SELECT 19, '40 ft slip on Dock B.', 40
    UNION ALL SELECT 20, '26 ft slip on Dock B.', 26
    UNION ALL SELECT 21, '26 ft slip on Dock B.', 26
    UNION ALL SELECT 22, '26 ft slip on Dock B.', 26
    UNION ALL SELECT 23, '26 ft slip on Dock B.', 26
    UNION ALL SELECT 24, '26 ft slip on Dock B.', 26
) v ON d.dockNumber = 'B';

-- Dock C: 24 slips (6 x 50ft, 8 x 40ft, 10 x 26ft)
INSERT IGNORE INTO slip (slipNumber, slipDescription, dockID, slipStatus, slipSize)
SELECT v.slipNumber, v.slipDescription, d.dockID, 'available', v.slipSize
FROM dock d
JOIN (
    SELECT 1 AS slipNumber, '50 ft slip on Dock C.' AS slipDescription, 50 AS slipSize
    UNION ALL SELECT 2, '50 ft slip on Dock C.', 50
    UNION ALL SELECT 3, '50 ft slip on Dock C.', 50
    UNION ALL SELECT 4, '40 ft slip on Dock C.', 40
    UNION ALL SELECT 5, '40 ft slip on Dock C.', 40
    UNION ALL SELECT 6, '40 ft slip on Dock C.', 40
    UNION ALL SELECT 7, '40 ft slip on Dock C.', 40
    UNION ALL SELECT 8, '26 ft slip on Dock C.', 26
    UNION ALL SELECT 9, '26 ft slip on Dock C.', 26
    UNION ALL SELECT 10, '26 ft slip on Dock C.', 26
    UNION ALL SELECT 11, '26 ft slip on Dock C.', 26
    UNION ALL SELECT 12, '26 ft slip on Dock C.', 26
    UNION ALL SELECT 13, '50 ft slip on Dock C.', 50
    UNION ALL SELECT 14, '50 ft slip on Dock C.', 50
    UNION ALL SELECT 15, '50 ft slip on Dock C.', 50
    UNION ALL SELECT 16, '40 ft slip on Dock C.', 40
    UNION ALL SELECT 17, '40 ft slip on Dock C.', 40
    UNION ALL SELECT 18, '40 ft slip on Dock C.', 40
    UNION ALL SELECT 19, '40 ft slip on Dock C.', 40
    UNION ALL SELECT 20, '26 ft slip on Dock C.', 26
    UNION ALL SELECT 21, '26 ft slip on Dock C.', 26
    UNION ALL SELECT 22, '26 ft slip on Dock C.', 26
    UNION ALL SELECT 23, '26 ft slip on Dock C.', 26
    UNION ALL SELECT 24, '26 ft slip on Dock C.', 26
) v ON d.dockNumber = 'C';

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

INSERT INTO Reservation
    (reservationId, confirmationNumber, customerId, boatId, slipId, startDate, monthlyRate, reservationStatus)
VALUES
    (1, 'MB-00001', 1, 1, 8, '2026-06-01', 485.00),
    (2, 'MB-00002', 2, 2, 4, '2026-07-01', 585.00),
    (3, 'MB-00003', 3, 3, 1, '2026-05-15', 685.00);
    
INSERT INTO TerminationNotice
    (terminationNoticeId, reservationId, noticeDate, terminationDate, noticeStatus)
VALUES
    (1, 1, '2026-08-01', NULL, 'Submitted'),
    (2, 2, '2026-08-10', NULL, 'Pending'),
    (3, 3, '2026-08-15', '2026-09-14', 'Approved');