-- =============================================================================
-- Team: Blue Team
-- Roster: Breutzmann, R. | White, S. | Fernandez, M. | Rodriguez, C.
-- CSD 460 - Moffat Bay Marina
-- File: MoffatBayMarinaDB_V1-2-0_update.sql
-- Purpose: Adds Customer.country, collected by the Registration form so
--          the page can show a badge above Boat Registration for a
--          customer outside the US/Canada, and so RegisterServlet can
--          decide whether a boat's Registration State/Number field means
--          a US state or a Canadian province. See the Registration
--          contract's "Country" and "Boat Fields" sections.
--          Customer table owner: Fernandez, M.
--          Unlike MoffatBayMarinaDB_V1-0-0.sql, this does NOT drop or
--          recreate the database - it alters the existing
--          MoffatBayMarinaDB in place, so existing data survives.
-- Version: 1.2.0
-- Date: 2026-09-04
-- =============================================================================
-- Run this script as a MySQL admin/root user against an existing database
-- (e.g. `mysql -u root -p MoffatBayMarinaDB < MoffatBayMarinaDB_V1-2-0_update.sql`).
-- Safe to run on a database already at 1.1.0; no seed data is touched.
-- =============================================================================

USE MoffatBayMarinaDB;

-- =============================================================================
-- Schema Changes
-- =============================================================================

ALTER TABLE Customer
    ADD COLUMN country VARCHAR(5) NOT NULL DEFAULT 'US'
        COMMENT 'One of US, CA, or OTHER - see the Registration contract''s "Country" section. VARCHAR(5), not CHAR(2), since OTHER is a literal stored value, not an ISO code.';

-- Existing seeded customers default to 'US', matching how every prior
-- account was actually registered before this column existed.

-- =============================================================================
-- Record this version in DatabaseVersion
-- =============================================================================

INSERT INTO DatabaseVersion (version, appliedDate, description) VALUES
    ('1.2.0', CURDATE(), 'Customer: adds country (US/CA/OTHER), driving the Registration page''s foreign-registration badge and the Boat Registration State/Province field.');
