-- =============================================================================
-- Team: Blue Team
-- Roster: Breutzmann, R. | White, S. | Fernandez, M. | Rodriguez, C.
-- CSD 460 - Moffat Bay Marina
-- File: MoffatBayMarinaDB_V1-9-0_update.sql
-- Purpose: Data-only. Adds three unreserved boats so the My Fleet page
--          (Module 9) has the fleets its front-end tests need.
--
--          Why: every seeded boat (1-60) has an Active reservation, and no
--          seeded customer owns more than two boats. So on a fresh build:
--            - no customer has an unreserved boat, so the grey "Open to
--              Reserve" status badge, the Reserve a Slip link, and an
--              enabled Remove button can never be seen;
--            - no customer has four boats, so My Fleet's two-column layout
--              (4+ boats) can never be seen;
--            - no boat has blank optional fields other than Wandering
--              Albatross's HIN, so the dashed "blank value" badges are
--              barely exercised.
--          The only customer that covered any of this was Elena Marsh, and
--          only on databases where earlier tests had added boats to her -
--          and she is the shared demo account, so her fleet can change
--          under a tester at any time.
--
--          After this update:
--   desmond.okafor@example.com / MoffatOkafor02!  - 2 boats
--       Second Wind   reserved (MB-00002)
--       Harbor Light  NEW, unreserved, every field filled
--   arthur.penhale@example.com / MoffatPenhale05! - 4 boats
--       Little Bear          reserved (MB-00005)
--       Wandering Albatross  reserved (MB-00006), no HIN
--       Kestrel              NEW, unreserved, every field filled
--       Morning Tide         NEW, unreserved, only HIN and length set -
--                            regNumber, boatType, boatBeam and boatYear
--                            are left NULL on purpose
--
--          Customers are matched by email and new boats by HIN rather than
--          by ID, since a database that has been used for testing may have
--          extra boats and the new rows will not get IDs 61-63. HINs and
--          registration numbers follow Utils.HIN_PATTERN and the US
--          registration pattern, so the Edit modal accepts them unchanged.
--          The update runs in one transaction: a failure (e.g. a HIN
--          already in use) leaves the database exactly as it was.
-- Version: 1.9.0
-- Date: 2026-09-23
-- =============================================================================
-- Run this script as a MySQL admin/root user against an existing database
-- at version 1.8.0 (check with currentVersion.sql), e.g.
-- `mysql -u root -p moffatBayMarinaDB < MoffatBayMarinaDB_V1-9-0_update.sql`.
-- Run it once - a second run fails on the unique HINs and changes nothing.
-- =============================================================================

USE MoffatBayMarinaDB;

START TRANSACTION;

-- =============================================================================
-- Data Changes
-- =============================================================================
INSERT INTO Boat
    (HIN, boatName, regNumber, boatType, boatLength, boatBeam, boatYear)
VALUES
    ('OKF63G7H8J90', 'Harbor Light', 'WN2218OK', 'Sailboat',  30.0, 10.2, 2011),
    ('PNH61A2B3C45', 'Kestrel',      'WN5521KP', 'Powerboat', 26.0,  8.5, 2019),
    ('PNH62D4E5F67', 'Morning Tide', NULL,       NULL,        18.5, NULL, NULL);

INSERT INTO BoatOwnership (boatID, customerID, startDate, endDate)
SELECT b.boatID, c.customerID, v.startDate, NULL
FROM (
    SELECT 'OKF63G7H8J90' AS hin, 'desmond.okafor@example.com' AS email, '2026-08-27' AS startDate
    UNION ALL SELECT 'PNH61A2B3C45', 'arthur.penhale@example.com', '2026-08-20'
    UNION ALL SELECT 'PNH62D4E5F67', 'arthur.penhale@example.com', '2026-09-02'
) v
JOIN Boat b     ON b.HIN = v.hin
JOIN Customer c ON c.email = v.email;

-- =============================================================================
-- Record this version in DatabaseVersion
-- =============================================================================
INSERT INTO DatabaseVersion (version, appliedDate, description) VALUES
    ('1.9.0', CURDATE(), 'Data-only: adds three unreserved boats for My Fleet testing - Desmond Okafor now owns 2 boats (1 reserved), Arthur Penhale 4 (2 reserved, 1 with blank optional fields).');

COMMIT;
