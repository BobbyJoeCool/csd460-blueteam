-- =============================================================================
-- Team: Blue Team
-- Roster: Breutzmann, R. | White, S. | Fernandez, M. | Rodriguez, C.
-- CSD 460 - Moffat Bay Marina
-- File: MoffatBayMarinaDB_V1-8-0_update.sql
-- Purpose: Resets every seeded Employee and Customer password to one that
--          meets the site's password rules - at least 10 characters, one
--          uppercase letter, one lowercase letter, one number, and one
--          special character from ! $ % * #. These are the same rules
--          Utils.PASSWORD_PATTERN and formValidation.js's PASSWORD_RULES
--          enforce on Registration, Change Password and Forgot Password.
--
--          The seed passwords predate those rules ('AHAB1', 'Password1',
--          'Foster9!' ...) - 29 of the 59 seeded accounts failed them -
--          so a tester logging in with a seeded account was using a
--          password the site would never let a real customer choose.
--
--          Every new password follows one pattern, so nobody needs this
--          file open to log in:
--
--              Moffat + <LastName> + <two-digit seed position> + !
--
--          where the position is the account's place in its table's seed
--          INSERT (its original employeeID / customerID on a fresh build),
--          e.g. elena.marsh@example.com -> MoffatMarsh01!
--
--          Rows are matched by email rather than ID, so a database with
--          extra accounts registered through the site keeps those accounts'
--          passwords untouched. Hashes use SHA2(x, 256), matching
--          Utils.hashPassword() in Java.
--
--          Employees:
--   maria.alvarez@moffatbaymarina.com   MoffatAlvarez01!
--   tom.whitfield@moffatbaymarina.com   MoffatWhitfield02!
--   priya.nair@moffatbaymarina.com      MoffatNair03!
--   derek.simmons@moffatbaymarina.com   MoffatSimmons04!
--   lena.cho@moffatbaymarina.com        MoffatCho05!
--   carlos.reyes@moffatbaymarina.com    MoffatReyes06!
--   sophie.bennett@moffatbaymarina.com  MoffatBennett07!
--
--          Customers:
--   elena.marsh@example.com             MoffatMarsh01!
--   desmond.okafor@example.com          MoffatOkafor02!
--   yuki.tanaka@example.com             MoffatTanaka03!
--   rosa.delgado@example.com            MoffatDelgado04!
--   arthur.penhale@example.com          MoffatPenhale05!
--   nadia.brennan@example.com           MoffatBrennan06!
--   kenneth.pearson@example.com         MoffatPearson07!
--   william.dunmore@example.com         MoffatDunmore08!
--   robert.foster@example.com           MoffatFoster09!
--   joshua.foster@example.com           MoffatFoster10!
--   mark.okonkwo@example.com            MoffatOkonkwo11!
--   nancy.blackwood@example.com         MoffatBlackwood12!
--   jennifer.rourke@example.com         MoffatRourke13!
--   robert.bellweather@example.com      MoffatBellweather14!
--   jennifer.prescott@example.com       MoffatPrescott15!
--   melissa.sinclair@example.com        MoffatSinclair16!
--   joseph.castillo@example.com         MoffatCastillo17!
--   david.tremaine@example.com          MoffatTremaine18!
--   joshua.strand@example.com           MoffatStrand19!
--   sandra.rourke@example.com           MoffatRourke20!
--   stephanie.rivas@example.com         MoffatRivas21!
--   betty.blackwood@example.com         MoffatBlackwood22!
--   carol.corcoran@example.com          MoffatCorcoran23!
--   william.mercer@example.com          MoffatMercer24!
--   donna.winslow@example.com           MoffatWinslow25!
--   ashley.whitmore@example.com         MoffatWhitmore26!
--   kenneth.sutherland@example.com      MoffatSutherland27!
--   matthew.beaumont@example.com        MoffatBeaumont28!
--   amanda.bellweather@example.com      MoffatBellweather29!
--   linda.alonso@example.com            MoffatAlonso30!
--   george.bellweather@example.com      MoffatBellweather31!
--   michael.strand@example.com          MoffatStrand32!
--   lisa.castellan@example.com          MoffatCastellan33!
--   ashley.foster@example.com           MoffatFoster34!
--   patricia.mercer@example.com         MoffatMercer35!
--   george.corcoran@example.com         MoffatCorcoran36!
--   kevin.whitfield@example.com         MoffatWhitfield37!
--   kimberly.beaumont@example.com       MoffatBeaumont38!
--   betty.redmond@example.com           MoffatRedmond39!
--   mark.pearson@example.com            MoffatPearson40!
--   mary.okonkwo@example.com            MoffatOkonkwo41!
--   john.sharma@example.com             MoffatSharma42!
--   robert.kowalski@example.com         MoffatKowalski43!
--   kevin.corcoran@example.com          MoffatCorcoran44!
--   jessica.whitfield@example.com       MoffatWhitfield45!
--   michael.redmond@example.com         MoffatRedmond46!
--   sandra.bellweather@example.com      MoffatBellweather47!
--   george.kowalski@example.com         MoffatKowalski48!
--   richard.landry@example.com          MoffatLandry49!
--   sarah.marchetti@example.com         MoffatMarchetti50!
--   michael.barrett@example.com         MoffatBarrett51!
--   edward.mercer@example.com           MoffatMercer52!
--
-- Version: 1.8.0
-- Date: 2026-09-17
-- =============================================================================
-- Run this script as a MySQL admin/root user against an existing database
-- (e.g. `mysql -u root -p MoffatBayMarinaDB < MoffatBayMarinaDB_V1-8-0_update.sql`).
-- Data-only - no schema change, safe to re-run.
-- =============================================================================

USE MoffatBayMarinaDB;

-- =============================================================================
-- 1. Data Update - Employee.passwordHash
-- =============================================================================

UPDATE Employee SET passwordHash = SHA2('MoffatAlvarez01!', 256) WHERE email = 'maria.alvarez@moffatbaymarina.com';
UPDATE Employee SET passwordHash = SHA2('MoffatWhitfield02!', 256) WHERE email = 'tom.whitfield@moffatbaymarina.com';
UPDATE Employee SET passwordHash = SHA2('MoffatNair03!', 256) WHERE email = 'priya.nair@moffatbaymarina.com';
UPDATE Employee SET passwordHash = SHA2('MoffatSimmons04!', 256) WHERE email = 'derek.simmons@moffatbaymarina.com';
UPDATE Employee SET passwordHash = SHA2('MoffatCho05!', 256) WHERE email = 'lena.cho@moffatbaymarina.com';
UPDATE Employee SET passwordHash = SHA2('MoffatReyes06!', 256) WHERE email = 'carlos.reyes@moffatbaymarina.com';
UPDATE Employee SET passwordHash = SHA2('MoffatBennett07!', 256) WHERE email = 'sophie.bennett@moffatbaymarina.com';

-- =============================================================================
-- 2. Data Update - Customer.passwordHash
-- =============================================================================

UPDATE Customer SET passwordHash = SHA2('MoffatMarsh01!', 256) WHERE email = 'elena.marsh@example.com';
UPDATE Customer SET passwordHash = SHA2('MoffatOkafor02!', 256) WHERE email = 'desmond.okafor@example.com';
UPDATE Customer SET passwordHash = SHA2('MoffatTanaka03!', 256) WHERE email = 'yuki.tanaka@example.com';
UPDATE Customer SET passwordHash = SHA2('MoffatDelgado04!', 256) WHERE email = 'rosa.delgado@example.com';
UPDATE Customer SET passwordHash = SHA2('MoffatPenhale05!', 256) WHERE email = 'arthur.penhale@example.com';
UPDATE Customer SET passwordHash = SHA2('MoffatBrennan06!', 256) WHERE email = 'nadia.brennan@example.com';
UPDATE Customer SET passwordHash = SHA2('MoffatPearson07!', 256) WHERE email = 'kenneth.pearson@example.com';
UPDATE Customer SET passwordHash = SHA2('MoffatDunmore08!', 256) WHERE email = 'william.dunmore@example.com';
UPDATE Customer SET passwordHash = SHA2('MoffatFoster09!', 256) WHERE email = 'robert.foster@example.com';
UPDATE Customer SET passwordHash = SHA2('MoffatFoster10!', 256) WHERE email = 'joshua.foster@example.com';
UPDATE Customer SET passwordHash = SHA2('MoffatOkonkwo11!', 256) WHERE email = 'mark.okonkwo@example.com';
UPDATE Customer SET passwordHash = SHA2('MoffatBlackwood12!', 256) WHERE email = 'nancy.blackwood@example.com';
UPDATE Customer SET passwordHash = SHA2('MoffatRourke13!', 256) WHERE email = 'jennifer.rourke@example.com';
UPDATE Customer SET passwordHash = SHA2('MoffatBellweather14!', 256) WHERE email = 'robert.bellweather@example.com';
UPDATE Customer SET passwordHash = SHA2('MoffatPrescott15!', 256) WHERE email = 'jennifer.prescott@example.com';
UPDATE Customer SET passwordHash = SHA2('MoffatSinclair16!', 256) WHERE email = 'melissa.sinclair@example.com';
UPDATE Customer SET passwordHash = SHA2('MoffatCastillo17!', 256) WHERE email = 'joseph.castillo@example.com';
UPDATE Customer SET passwordHash = SHA2('MoffatTremaine18!', 256) WHERE email = 'david.tremaine@example.com';
UPDATE Customer SET passwordHash = SHA2('MoffatStrand19!', 256) WHERE email = 'joshua.strand@example.com';
UPDATE Customer SET passwordHash = SHA2('MoffatRourke20!', 256) WHERE email = 'sandra.rourke@example.com';
UPDATE Customer SET passwordHash = SHA2('MoffatRivas21!', 256) WHERE email = 'stephanie.rivas@example.com';
UPDATE Customer SET passwordHash = SHA2('MoffatBlackwood22!', 256) WHERE email = 'betty.blackwood@example.com';
UPDATE Customer SET passwordHash = SHA2('MoffatCorcoran23!', 256) WHERE email = 'carol.corcoran@example.com';
UPDATE Customer SET passwordHash = SHA2('MoffatMercer24!', 256) WHERE email = 'william.mercer@example.com';
UPDATE Customer SET passwordHash = SHA2('MoffatWinslow25!', 256) WHERE email = 'donna.winslow@example.com';
UPDATE Customer SET passwordHash = SHA2('MoffatWhitmore26!', 256) WHERE email = 'ashley.whitmore@example.com';
UPDATE Customer SET passwordHash = SHA2('MoffatSutherland27!', 256) WHERE email = 'kenneth.sutherland@example.com';
UPDATE Customer SET passwordHash = SHA2('MoffatBeaumont28!', 256) WHERE email = 'matthew.beaumont@example.com';
UPDATE Customer SET passwordHash = SHA2('MoffatBellweather29!', 256) WHERE email = 'amanda.bellweather@example.com';
UPDATE Customer SET passwordHash = SHA2('MoffatAlonso30!', 256) WHERE email = 'linda.alonso@example.com';
UPDATE Customer SET passwordHash = SHA2('MoffatBellweather31!', 256) WHERE email = 'george.bellweather@example.com';
UPDATE Customer SET passwordHash = SHA2('MoffatStrand32!', 256) WHERE email = 'michael.strand@example.com';
UPDATE Customer SET passwordHash = SHA2('MoffatCastellan33!', 256) WHERE email = 'lisa.castellan@example.com';
UPDATE Customer SET passwordHash = SHA2('MoffatFoster34!', 256) WHERE email = 'ashley.foster@example.com';
UPDATE Customer SET passwordHash = SHA2('MoffatMercer35!', 256) WHERE email = 'patricia.mercer@example.com';
UPDATE Customer SET passwordHash = SHA2('MoffatCorcoran36!', 256) WHERE email = 'george.corcoran@example.com';
UPDATE Customer SET passwordHash = SHA2('MoffatWhitfield37!', 256) WHERE email = 'kevin.whitfield@example.com';
UPDATE Customer SET passwordHash = SHA2('MoffatBeaumont38!', 256) WHERE email = 'kimberly.beaumont@example.com';
UPDATE Customer SET passwordHash = SHA2('MoffatRedmond39!', 256) WHERE email = 'betty.redmond@example.com';
UPDATE Customer SET passwordHash = SHA2('MoffatPearson40!', 256) WHERE email = 'mark.pearson@example.com';
UPDATE Customer SET passwordHash = SHA2('MoffatOkonkwo41!', 256) WHERE email = 'mary.okonkwo@example.com';
UPDATE Customer SET passwordHash = SHA2('MoffatSharma42!', 256) WHERE email = 'john.sharma@example.com';
UPDATE Customer SET passwordHash = SHA2('MoffatKowalski43!', 256) WHERE email = 'robert.kowalski@example.com';
UPDATE Customer SET passwordHash = SHA2('MoffatCorcoran44!', 256) WHERE email = 'kevin.corcoran@example.com';
UPDATE Customer SET passwordHash = SHA2('MoffatWhitfield45!', 256) WHERE email = 'jessica.whitfield@example.com';
UPDATE Customer SET passwordHash = SHA2('MoffatRedmond46!', 256) WHERE email = 'michael.redmond@example.com';
UPDATE Customer SET passwordHash = SHA2('MoffatBellweather47!', 256) WHERE email = 'sandra.bellweather@example.com';
UPDATE Customer SET passwordHash = SHA2('MoffatKowalski48!', 256) WHERE email = 'george.kowalski@example.com';
UPDATE Customer SET passwordHash = SHA2('MoffatLandry49!', 256) WHERE email = 'richard.landry@example.com';
UPDATE Customer SET passwordHash = SHA2('MoffatMarchetti50!', 256) WHERE email = 'sarah.marchetti@example.com';
UPDATE Customer SET passwordHash = SHA2('MoffatBarrett51!', 256) WHERE email = 'michael.barrett@example.com';
UPDATE Customer SET passwordHash = SHA2('MoffatMercer52!', 256) WHERE email = 'edward.mercer@example.com';

-- To confirm it applied (should match MoffatMarsh01!):
--   SELECT email, passwordHash = SHA2('MoffatMarsh01!', 256) AS matches
--   FROM Customer WHERE email = 'elena.marsh@example.com';

-- =============================================================================
-- Record this version in DatabaseVersion
-- =============================================================================

INSERT INTO DatabaseVersion (version, appliedDate, description) VALUES
    ('1.8.0', CURDATE(), 'Data-only: resets every seeded Employee and Customer password to Moffat<LastName><NN>! so each meets the site password rules (10+ chars, upper, lower, number, one of ! $ % * #).');
