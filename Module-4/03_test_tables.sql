-- =============================================================================
-- Team: Blue Team
-- Roster: Breutzmann, R. | White, S. | Fernandez, M. | Rodriguez, C.
-- CSD 460 - Moffat Bay Marina
-- File: 03_test_tables.sql
-- Purpose: Assignment 4.1 verification - run 01_create_database.sql and
--          02_seed_data.sql first, then run this file and screenshot the
--          result grid for each SELECT (one screenshot per table showing
--          its contents, not its structure). Every table below already
--          holds well over the assignment's minimum of three rows.
-- Comment citation: Inline comments in this file were drafted with the
--          assistance of Claude (Anthropic) and reviewed by the
--          database lead, Breutzmann, R.
-- Version: 1.1.0 (tracks ERD.md; White, S. and Rodriguez, C. sections still
--          in progress - see the TODOs below)
-- Date: 2026-08-27
-- =============================================================================

USE moffatBayMarinaDB;

-- =============================================================================
-- Section: Breutzmann, R. - Dock & Slip Tables
-- =============================================================================
-- dock: 3 rows seeded (docks A-C).
SELECT * FROM dock;

-- slip: 72 rows seeded (24 per dock).
SELECT * FROM slip;

-- contact: 10 rows seeded (fictional ship captains testing the Contact Us form).
SELECT * FROM contact;

-- employee: 5 rows seeded (staff accounts).
SELECT * FROM employee;

-- =============================================================================
-- Section: White, S. - Tables TBD
-- =============================================================================
-- TODO (White, S.): add SELECT * FROM <table>; for each of your tables here.

-- =============================================================================
-- Section: Fernandez, M. - Tables TBD
-- =============================================================================
-- TODO (Fernandez, M.): add SELECT * FROM <table>; for each of your tables here.

-- =============================================================================
-- Section: Rodriguez, C. - Tables TBD
-- =============================================================================
-- TODO (Rodriguez, C.): add SELECT * FROM <table>; for each of your tables here.
SELECT * FROM Reservation;

SELECT * FROM TerminationNotice;