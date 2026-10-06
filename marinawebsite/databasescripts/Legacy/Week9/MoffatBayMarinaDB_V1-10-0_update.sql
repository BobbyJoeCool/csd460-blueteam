-- =============================================================================
-- Team: Blue Team
-- Roster: Breutzmann, R. | White, S. | Fernandez, M. | Rodriguez, C.
-- CSD 460 - Moffat Bay Marina
-- File: MoffatBayMarinaDB_V1-10-0_update.sql
-- Purpose: Two changes.
--
--          1. Adds Contact.submittedAt, the date and time each Contact Us
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
--
--          2. Moves the three seeded termination notices (MB-00001 to
--          MB-00003) to last days that haven't passed (issue #324). Slip
--          availability now follows notice dates, and the old seed dates
--          had all passed, which would have freed a slip of every size -
--          including the 40 ft slip the wait list demo needs full. They are
--          reset to the consolidated file's values whatever state testing
--          left them in (withdrawn, resubmitted), matched by confirmation
--          number.
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

-- The seeded notices, one per slip size, each ending in the future.
UPDATE TerminationNotice tn
JOIN Reservation r ON r.reservationID = tn.reservationID
JOIN (
    SELECT 'MB-00001' AS confirmationNumber, DATE('2026-10-01') AS noticeDate,
           DATE('2026-11-15') AS lastDay, 'Submitted' AS noticeStatus
    UNION ALL SELECT 'MB-00002', DATE('2026-09-28'), DATE('2026-11-30'), 'Pending'
    UNION ALL SELECT 'MB-00003', DATE('2026-10-01'), DATE('2026-12-31'), 'Approved'
) seed ON seed.confirmationNumber = r.confirmationNumber
SET tn.noticeDate = seed.noticeDate,
    tn.terminationDate = seed.lastDay,
    tn.noticeStatus = seed.noticeStatus;

-- =============================================================================
-- Record this version in DatabaseVersion
-- =============================================================================
INSERT INTO DatabaseVersion (version, appliedDate, description) VALUES
    ('1.10.0', CURDATE(), 'Contact: adds submittedAt (TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP) so staff can see how long each message has waited. Moves the three seeded termination notices to future last days, now that slip availability follows them.');
