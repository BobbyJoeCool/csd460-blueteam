-- =============================================================================
-- Team: Blue Team
-- Roster: Breutzmann, R. | White, S. | Fernandez, M. | Rodriguez, C.
-- CSD 460 - Moffat Bay Marina
-- File: MoffatBayMarinaDB_V1-10-0_update.sql
-- Purpose: Adds Contact.submittedAt, the date and time each Contact Us
--          message arrived (issue #326). Until now a message had no date
--          of its own, so staff couldn't see how long one had waited or
--          answer the oldest first.
--
--          The column defaults to CURRENT_TIMESTAMP, so the site's INSERT
--          doesn't change. Rows that already exist get the moment this
--          script runs, because there is no earlier time on record to give
--          them - except the ten seeded captains' messages, which are
--          matched by email and set to the same dates the consolidated
--          V1-10-0.sql seeds, each before its reply.
-- Version: 1.10.0
-- Date: 2026-10-06
-- =============================================================================
-- Run this script as a MySQL admin/root user against an existing 1.9.0
-- database (e.g. `mysql -u root -p < MoffatBayMarinaDB_V1-10-0_update.sql`).
-- =============================================================================

USE MoffatBayMarinaDB;

-- =============================================================================
-- Schema Changes
-- =============================================================================
ALTER TABLE Contact
    ADD COLUMN submittedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
        COMMENT 'Date and time the message was submitted.'
        AFTER message;

-- The seeded messages, so this database matches a fresh build. Only the
-- seed rows: a message sent while testing keeps the time set above.
UPDATE Contact c
JOIN (
    SELECT 'jack.sparrow@blackpearl.sea' AS email, TIMESTAMP('2026-06-13 18:42:00') AS sentAt
    UNION ALL SELECT 'thecaptain@majesticmetaphors.com', TIMESTAMP('2026-05-01 09:12:00')
    UNION ALL SELECT 'han.solo@corellianfreighter.com',  TIMESTAMP('2026-09-29 14:05:00')
    UNION ALL SELECT 'mal.reynolds@serenity.verse',      TIMESTAMP('2026-09-30 08:20:00')
    UNION ALL SELECT 'jl.picard@starfleet.ufp',          TIMESTAMP('2026-07-18 21:47:00')
    UNION ALL SELECT 'ahab@pequodwhaling.com',           TIMESTAMP('2026-10-02 06:30:00')
    UNION ALL SELECT 'captain.nemo@nautilus.sea',        TIMESTAMP('2026-04-10 23:59:00')
    UNION ALL SELECT 'james.hook@jollyroger.sea',        TIMESTAMP('2026-10-03 12:00:00')
    UNION ALL SELECT 'odysseus@ithacashipping.gr',       TIMESTAMP('2026-07-31 19:15:00')
    UNION ALL SELECT 'noah@thearkmarine.com',            TIMESTAMP('2026-10-04 07:00:00')
) seed ON seed.email = c.email
SET c.submittedAt = seed.sentAt
WHERE c.contactID <= 10;

-- =============================================================================
-- Record this version in DatabaseVersion
-- =============================================================================
INSERT INTO DatabaseVersion (version, appliedDate, description) VALUES
    ('1.10.0', CURDATE(), 'Contact: adds submittedAt (TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP) so staff can see how long each message has waited.');
