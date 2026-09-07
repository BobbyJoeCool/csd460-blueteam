-- =============================================================================
-- Team: Blue Team
-- Roster: Breutzmann, R. | White, S. | Fernandez, M. | Rodriguez, C.
-- CSD 460 - Moffat Bay Marina
-- File: MoffatBayMarinaDB_V1-0-0.sql
-- Purpose: This file creates and seeds the full database for the Marina.
--          It combines the work of the development team, and organizes the
--          database creation script in a way that allows all Foreign Keys to be
--          created as a part of the table they are in.
-- Comment citation: Inline comments in this file were drafted with the
--          assistance of Claude (Anthropic) and reviewed by the
--          database lead, Breutzmann, R.
-- Data Citation: Some fake data within the scripts was added by Claude (Anthropic)
--          to fill out the database.  Claude did not write any specific INSERT or CREATE
--          scripts, but mearly filled in the data of a pre-existing script.
-- Version: 1.0.0
-- Date: 2026-08-28
-- =============================================================================
-- Run this script as a MySQL admin/root user (e.g. `mysql -u root -p < marinaDatabasev1-0-0.sql`).
-- Each teammate runs this once against their own local MySQL instance.
-- This script is destructive: it drops the database if it already exists,
-- so every run starts from a clean, empty schema.
-- =============================================================================

-- *********************************************************
-- *   NOTICE TO DEVELOPER RUNNING THIS SCRIPT!!!!!        *
-- *   This script DELETES THE DATABASE and starts fresh!  *
-- *   ALL DATA INSIDE WILL BE LOST AND CANNOT BE UNDONE!  *
-- *   This script is for inital database creation ONLY.   *
-- *   For updating live database, use an update script.   *
-- *********************************************************

-- =============================================================================
-- Shared Setup - Database & Admin User (Database Lead: Breutzmann, R.)
-- =============================================================================
DROP DATABASE IF EXISTS MoffatBayMarinaDB;
CREATE DATABASE MoffatBayMarinaDB;

-- Shared dev/test app user. Password is intentionally simple for local
-- dev use only, per the module requirement that every teammate stand up
-- an identical local environment (same DB name, user, and password).
CREATE USER IF NOT EXISTS 'captainAhab'@'localhost' IDENTIFIED BY 'Ahab1234!';

GRANT ALL PRIVILEGES ON MoffatBayMarinaDB.* TO 'captainAhab'@'localhost' WITH GRANT OPTION;

FLUSH PRIVILEGES;

USE MoffatBayMarinaDB;

-- =============================================================================
-- Table 0: DatabaseVersion | Owner: Breutzmann, R. (Database Lead) |
-- Inward FKs (none)
-- Outward FKs (none)
-- =============================================================================
CREATE TABLE DatabaseVersion (
    databaseVersionID INT AUTO_INCREMENT PRIMARY KEY,
    version VARCHAR(20) NOT NULL COMMENT 'Semantic version of this script, matches the Version: header at the top of this file.',
    appliedDate DATE NOT NULL COMMENT 'Date this version was applied to the database.',
    description VARCHAR(255) COMMENT 'Brief note on what this version changed.'
);

INSERT INTO DatabaseVersion (version, appliedDate, description) VALUES
    ('1.0.0', CURDATE(), 'Initial consolidated single-file release: Dock, Employee, Customer, Boat, SlipSize, WaitList, BoatOwnership, Slip, Contact, Reservation, TerminationNotice.');

-- =============================================================================
-- Table 1: Dock | Owner: Breutzmann, R. |
-- Inward FKs Dock.dockID <- Slip.dockID
-- Outward FKs (none)
-- =============================================================================
CREATE TABLE Dock (
    dockID INT AUTO_INCREMENT PRIMARY KEY,
    dockNumber VARCHAR(1) NOT NULL UNIQUE COMMENT 'Customer facing dock letter, e.g. A-C.',
    dockDescription VARCHAR(255) COMMENT 'A customer facing brief description of the dock.'
);

INSERT INTO Dock (dockNumber, dockDescription) VALUES
    ('A', 'Linear Dock A, closest to the Ship Store.'),
    ('B', 'Linear Dock B, between Dock A and Dock C.'),
    ('C', 'Linear Dock C, closest to the Office & Restaurant and Fuel Dock.');

-- =============================================================================
-- Table 2: Employee | Owner: Breutzmann, R. |
-- Inward FKs Employee.employeeID <- Contact.respondedEmployeeID
-- Outward FKs (none)
-- =============================================================================
CREATE TABLE Employee (
    employeeID INT AUTO_INCREMENT PRIMARY KEY,
    firstName VARCHAR(50) NOT NULL COMMENT 'Employee first name.',
    lastName VARCHAR(50) NOT NULL COMMENT 'Employee last name.',
    email VARCHAR(255) NOT NULL UNIQUE COMMENT 'Login username and contact email.',
    passwordHash VARCHAR(255) NOT NULL COMMENT 'Hashed password, validated in Java before hashing.',
    phone VARCHAR(20) COMMENT 'Contact phone number.',
    jobTitle VARCHAR(50) COMMENT 'Employee job title.',
    hireDate DATE COMMENT 'Date employee was hired.'
);

INSERT INTO Employee (firstName, lastName, email, passwordHash, phone, jobTitle, hireDate) VALUES
    ('Maria', 'Alvarez', 'maria.alvarez@moffatbaymarina.com', SHA2('AHAB1', 256), '360-555-0101', 'Marina Manager', '2019-03-01'),
    ('Tom', 'Whitfield', 'tom.whitfield@moffatbaymarina.com', SHA2('AHAB2', 256), '360-555-0102', 'Dockmaster', '2020-06-15'),
    ('Priya', 'Nair', 'priya.nair@moffatbaymarina.com', SHA2('AHAB3', 256), '360-555-0103', 'Customer Service Rep', '2022-01-10'),
    ('Derek', 'Simmons', 'derek.simmons@moffatbaymarina.com', SHA2('AHAB4', 256), '360-555-0104', 'Maintenance Technician', '2021-09-01'),
    ('Lena', 'Cho', 'lena.cho@moffatbaymarina.com', SHA2('AHAB5', 256), '360-555-0105', 'Billing Clerk', '2023-04-20'),
    ('Carlos', 'Reyes', 'carlos.reyes@moffatbaymarina.com', SHA2('AHAB6', 256), '360-555-0106', 'Fueling Station Manager', '2020-11-02'),
    ('Sophie', 'Bennett', 'sophie.bennett@moffatbaymarina.com', SHA2('AHAB7', 256), '360-555-0107', 'Shop Manager', '2022-07-18');

-- =============================================================================
-- Table 3: Customer | Owner: Fernandez, M. |
-- Inward FKs Customer.customerID <- Reservation.customerID, Customer.customerID <- WaitList.customerID, Customer.customerID <- BoatOwnership.customerID
-- Outward FKs (none)
-- =============================================================================
CREATE TABLE Customer (
    customerID INT AUTO_INCREMENT PRIMARY KEY,
    firstName VARCHAR(50) NOT NULL COMMENT 'Customer first name.',
    lastName VARCHAR(50) NOT NULL COMMENT 'Customer last name.',
    email VARCHAR(100) NOT NULL UNIQUE COMMENT 'Login username and contact email.',
    passwordHash VARCHAR(255) NOT NULL COMMENT 'Hashed password, validated in Java before hashing.',
    phone VARCHAR(20) COMMENT 'Contact phone number.',
    streetAddress VARCHAR(100) COMMENT 'Mailing street address.',
    city VARCHAR(50) COMMENT 'Mailing city.',
    state CHAR(2) COMMENT 'Two letter state code.',
    zipCode VARCHAR(10) COMMENT 'Zip code, varchar to keep leading zeros and allow +4.',
    dateJoined DATE NOT NULL COMMENT 'Date the account was created.'
);

-- Customers 7-52 (46 rows) were generated by Claude (Anthropic) to fill
-- out the marina for the occupancy targets used in the Boat/slip/
-- Reservation seed data below; the schema (this CREATE TABLE) was written
-- by the team. Reviewed by the database lead, Breutzmann, R.
INSERT INTO Customer
    (firstName, lastName, email, passwordHash, phone, streetAddress, city, state, zipCode, dateJoined)
VALUES
    ('Elena', 'Marsh', 'elena.marsh@example.com', SHA2('Password1', 256), '360-555-0201', '412 Harborview Dr', 'Moffat Bay', 'WA', '98110', '2025-03-14'),
    ('Desmond', 'Okafor', 'desmond.okafor@example.com', SHA2('Sailor22', 256), '360-555-0202', '87 Tidewater Ln', 'Port Grayson', 'WA', '98221', '2025-06-02'),
    ('Yuki', 'Tanaka', 'yuki.tanaka@example.com', SHA2('Harbor33', 256), '360-555-0203', '1550 Anchorage Way', 'Moffat Bay', 'WA', '98110', '2025-09-19'),
    ('Rosa', 'Delgado', 'rosa.delgado@example.com', SHA2('Anchor44', 256), '360-555-0204', '23 Gull Point Rd', 'Sable Cove', 'OR', '97103', '2026-01-08'),
    ('Arthur', 'Penhale', 'arthur.penhale@example.com', SHA2('Voyage55', 256), '360-555-0205', '9 Old Pier St', 'Moffat Bay', 'WA', '98110', '2026-02-27'),
    ('Nadia', 'Brennan', 'nadia.brennan@example.com', SHA2('Compass66', 256), '360-555-0206', '744 Saltgrass Ave', 'Port Grayson', 'WA', '98221', '2026-05-30'),
    ('Kenneth', 'Pearson', 'kenneth.pearson@example.com', SHA2('Pearson7!', 256), '360-555-0300', '30 Driftwood Ave', 'Moffat Bay', 'WA', '98110', '2025-08-31'),
    ('William', 'Dunmore', 'william.dunmore@example.com', SHA2('Dunmore8!', 256), '360-555-0301', '109 Cape Ln', 'Port Grayson', 'WA', '98221', '2026-03-23'),
    ('Robert', 'Foster', 'robert.foster@example.com', SHA2('Foster9!', 256), '360-555-0302', '100 Beacon Ave', 'Sable Cove', 'OR', '97103', '2026-06-16'),
    ('Joshua', 'Foster', 'joshua.foster@example.com', SHA2('Foster10!', 256), '360-555-0303', '579 Beacon Pl', 'Moffat Bay', 'WA', '98110', '2025-08-28'),
    ('Mark', 'Okonkwo', 'mark.okonkwo@example.com', SHA2('Okonkwo11!', 256), '360-555-0304', '289 Harbor Rd', 'Port Grayson', 'WA', '98221', '2026-03-23'),
    ('Nancy', 'Blackwood', 'nancy.blackwood@example.com', SHA2('Blackwood12!', 256), '360-555-0305', '164 Beacon Ct', 'Sable Cove', 'OR', '97103', '2025-04-29'),
    ('Jennifer', 'Rourke', 'jennifer.rourke@example.com', SHA2('Rourke13!', 256), '360-555-0306', '104 Marina Ct', 'Moffat Bay', 'WA', '98110', '2025-10-12'),
    ('Robert', 'Bellweather', 'robert.bellweather@example.com', SHA2('Bellweather14!', 256), '360-555-0307', '475 Cape Ln', 'Port Grayson', 'WA', '98221', '2026-02-06'),
    ('Jennifer', 'Prescott', 'jennifer.prescott@example.com', SHA2('Prescott15!', 256), '360-555-0308', '305 Bay Ct', 'Sable Cove', 'OR', '97103', '2025-07-30'),
    ('Melissa', 'Sinclair', 'melissa.sinclair@example.com', SHA2('Sinclair16!', 256), '360-555-0309', '51 Shoal Dr', 'Moffat Bay', 'WA', '98110', '2025-04-06'),
    ('Joseph', 'Castillo', 'joseph.castillo@example.com', SHA2('Castillo17!', 256), '360-555-0310', '394 Driftwood St', 'Port Grayson', 'WA', '98221', '2026-01-23'),
    ('David', 'Tremaine', 'david.tremaine@example.com', SHA2('Tremaine18!', 256), '360-555-0311', '368 Beacon Dr', 'Sable Cove', 'OR', '97103', '2025-03-29'),
    ('Joshua', 'Strand', 'joshua.strand@example.com', SHA2('Strand19!', 256), '360-555-0312', '180 Cape Ave', 'Moffat Bay', 'WA', '98110', '2025-07-01'),
    ('Sandra', 'Rourke', 'sandra.rourke@example.com', SHA2('Rourke20!', 256), '360-555-0313', '281 Cape Ave', 'Port Grayson', 'WA', '98221', '2025-12-13'),
    ('Stephanie', 'Rivas', 'stephanie.rivas@example.com', SHA2('Rivas21!', 256), '360-555-0314', '62 Shoal Way', 'Sable Cove', 'OR', '97103', '2025-12-04'),
    ('Betty', 'Blackwood', 'betty.blackwood@example.com', SHA2('Blackwood22!', 256), '360-555-0315', '72 Beacon Ct', 'Moffat Bay', 'WA', '98110', '2025-08-20'),
    ('Carol', 'Corcoran', 'carol.corcoran@example.com', SHA2('Corcoran23!', 256), '360-555-0316', '410 Current Rd', 'Port Grayson', 'WA', '98221', '2025-10-13'),
    ('William', 'Mercer', 'william.mercer@example.com', SHA2('Mercer24!', 256), '360-555-0317', '767 Cape Dr', 'Sable Cove', 'OR', '97103', '2026-03-29'),
    ('Donna', 'Winslow', 'donna.winslow@example.com', SHA2('Winslow25!', 256), '360-555-0318', '375 Shoal Rd', 'Moffat Bay', 'WA', '98110', '2026-06-20'),
    ('Ashley', 'Whitmore', 'ashley.whitmore@example.com', SHA2('Whitmore26!', 256), '360-555-0319', '778 Tide Ln', 'Port Grayson', 'WA', '98221', '2025-06-20'),
    ('Kenneth', 'Sutherland', 'kenneth.sutherland@example.com', SHA2('Sutherland27!', 256), '360-555-0320', '816 Wharf Ln', 'Sable Cove', 'OR', '97103', '2026-02-13'),
    ('Matthew', 'Beaumont', 'matthew.beaumont@example.com', SHA2('Beaumont28!', 256), '360-555-0321', '484 Breaker Dr', 'Moffat Bay', 'WA', '98110', '2025-01-26'),
    ('Amanda', 'Bellweather', 'amanda.bellweather@example.com', SHA2('Bellweather29!', 256), '360-555-0322', '122 Cape Dr', 'Port Grayson', 'WA', '98221', '2025-12-29'),
    ('Linda', 'Alonso', 'linda.alonso@example.com', SHA2('Alonso30!', 256), '360-555-0323', '450 Compass St', 'Sable Cove', 'OR', '97103', '2025-01-18'),
    ('George', 'Bellweather', 'george.bellweather@example.com', SHA2('Bellweather31!', 256), '360-555-0324', '274 Breaker Rd', 'Moffat Bay', 'WA', '98110', '2026-06-18'),
    ('Michael', 'Strand', 'michael.strand@example.com', SHA2('Strand32!', 256), '360-555-0325', '310 Breaker Ave', 'Port Grayson', 'WA', '98221', '2025-06-20'),
    ('Lisa', 'Castellan', 'lisa.castellan@example.com', SHA2('Castellan33!', 256), '360-555-0326', '170 Cape Way', 'Sable Cove', 'OR', '97103', '2025-12-12'),
    ('Ashley', 'Foster', 'ashley.foster@example.com', SHA2('Foster34!', 256), '360-555-0327', '119 Marina Dr', 'Moffat Bay', 'WA', '98110', '2025-09-17'),
    ('Patricia', 'Mercer', 'patricia.mercer@example.com', SHA2('Mercer35!', 256), '360-555-0328', '904 Fathom Ln', 'Port Grayson', 'WA', '98221', '2025-04-12'),
    ('George', 'Corcoran', 'george.corcoran@example.com', SHA2('Corcoran36!', 256), '360-555-0329', '840 Anchor Rd', 'Sable Cove', 'OR', '97103', '2025-05-26'),
    ('Kevin', 'Whitfield', 'kevin.whitfield@example.com', SHA2('Whitfield37!', 256), '360-555-0330', '974 Cape Rd', 'Moffat Bay', 'WA', '98110', '2025-10-13'),
    ('Kimberly', 'Beaumont', 'kimberly.beaumont@example.com', SHA2('Beaumont38!', 256), '360-555-0331', '438 Beacon Ave', 'Port Grayson', 'WA', '98221', '2025-11-30'),
    ('Betty', 'Redmond', 'betty.redmond@example.com', SHA2('Redmond39!', 256), '360-555-0332', '670 Marina St', 'Sable Cove', 'OR', '97103', '2026-06-28'),
    ('Mark', 'Pearson', 'mark.pearson@example.com', SHA2('Pearson40!', 256), '360-555-0333', '258 Shoal Ln', 'Moffat Bay', 'WA', '98110', '2025-12-27'),
    ('Mary', 'Okonkwo', 'mary.okonkwo@example.com', SHA2('Okonkwo41!', 256), '360-555-0334', '572 Shoal Ave', 'Port Grayson', 'WA', '98221', '2025-01-22'),
    ('John', 'Sharma', 'john.sharma@example.com', SHA2('Sharma42!', 256), '360-555-0335', '651 Tide Ave', 'Sable Cove', 'OR', '97103', '2025-03-25'),
    ('Robert', 'Kowalski', 'robert.kowalski@example.com', SHA2('Kowalski43!', 256), '360-555-0336', '77 Breaker Ave', 'Moffat Bay', 'WA', '98110', '2025-10-27'),
    ('Kevin', 'Corcoran', 'kevin.corcoran@example.com', SHA2('Corcoran44!', 256), '360-555-0337', '224 Cape Rd', 'Port Grayson', 'WA', '98221', '2026-05-14'),
    ('Jessica', 'Whitfield', 'jessica.whitfield@example.com', SHA2('Whitfield45!', 256), '360-555-0338', '831 Wharf Ave', 'Sable Cove', 'OR', '97103', '2025-04-21'),
    ('Michael', 'Redmond', 'michael.redmond@example.com', SHA2('Redmond46!', 256), '360-555-0339', '446 Marina Pl', 'Moffat Bay', 'WA', '98110', '2026-03-11'),
    ('Sandra', 'Bellweather', 'sandra.bellweather@example.com', SHA2('Bellweather47!', 256), '360-555-0340', '60 Gull Way', 'Port Grayson', 'WA', '98221', '2026-03-03'),
    ('George', 'Kowalski', 'george.kowalski@example.com', SHA2('Kowalski48!', 256), '360-555-0341', '824 Gull Ave', 'Sable Cove', 'OR', '97103', '2025-07-30'),
    ('Richard', 'Landry', 'richard.landry@example.com', SHA2('Landry49!', 256), '360-555-0342', '464 Pier Pl', 'Moffat Bay', 'WA', '98110', '2025-07-21'),
    ('Sarah', 'Marchetti', 'sarah.marchetti@example.com', SHA2('Marchetti50!', 256), '360-555-0343', '260 Anchor St', 'Port Grayson', 'WA', '98221', '2026-08-01'),
    ('Michael', 'Barrett', 'michael.barrett@example.com', SHA2('Barrett51!', 256), '360-555-0344', '672 Cape Way', 'Sable Cove', 'OR', '97103', '2025-04-20'),
    ('Edward', 'Mercer', 'edward.mercer@example.com', SHA2('Mercer52!', 256), '360-555-0345', '175 Wharf St', 'Moffat Bay', 'WA', '98110', '2026-05-22');

-- =============================================================================
-- Table 4: Boat | Owner: Fernandez, M. |
-- Inward FKs Boat.boatID <- Reservation.boatID, Boat.boatID <- BoatOwnership.boatID
-- Outward FKs (none)
-- =============================================================================
CREATE TABLE Boat (
    boatID INT AUTO_INCREMENT PRIMARY KEY,
    HIN VARCHAR(12) NULL UNIQUE COMMENT 'Hull Identification Number, immutable ID of the physical vessel. Null allowed for qualifying pre-1972 boats.',
    boatName VARCHAR(50) NOT NULL COMMENT 'Name of the vessel, may change with ownership.',
    regState CHAR(2) NOT NULL COMMENT 'State the boat is registered in.',
    regNumber VARCHAR(20) NOT NULL COMMENT 'State registration number.',
    boatType VARCHAR(30) COMMENT 'Sailboat, powerboat, catamaran, etc.',
    boatLength DECIMAL(4,1) NOT NULL COMMENT 'Length in feet, used to check slip fit.',
    boatBeam DECIMAL(4,1) COMMENT 'Width in feet, used to check slip fit.',
    boatYear INT COMMENT 'Model year. INT rather than MySQL YEAR for portability and JDBC mapping.',
    CONSTRAINT uqBoatRegistration UNIQUE (regState, regNumber)
);

-- Boats 7-60 (54 rows) were generated by Claude (Anthropic) to fill out
-- the marina for the occupancy targets used in the slip/Reservation seed
-- data below - each is sized shorter than the slip it's later reserved
-- into. The schema (this CREATE TABLE) was written by the team. Reviewed
-- by the database lead, Breutzmann, R.
INSERT INTO Boat
    (HIN, boatName, regState, regNumber, boatType, boatLength, boatBeam, boatYear)
VALUES
    ('MFT412A3B404', 'Salt Whisper',       'WA', 'WN1204JT', 'Sailboat',  24.5,  8.2, 2014),
    ('BNT52C7D8188', 'Second Wind',        'WA', 'WN3391RK', 'Powerboat', 38.0, 13.5, 2019),
    ('CRS63E9F2224', 'Meridian',           'WA', 'WN0087PL', 'Catamaran', 47.5, 22.0, 2021),
    ('HLM74G1H6360', 'Gullwing',           'OR', 'OR5540BM', 'Sailboat',  31.0, 10.4, 2008),
    ('SBK85J3K0504', 'Little Bear',        'WA', 'WN7712DF', 'Powerboat', 22.0,  8.0, 2016),
    (NULL,           'Wandering Albatross','WA', 'WN0431XG', 'Sailboat',  36.0, 11.0, 1968),
    ('QLCA5GEP8SJY', 'Fair Winds', 'WA', 'WA2127HM', 'Catamaran', 32.6, 8.6, 1995),
    ('XTKGJSHGKTUP', 'Following Sea', 'WA', 'WA6617GX', 'Pontoon', 24.3, 6.3, 2001),
    ('CWPTCAXJSL43', 'Tranquility Base', 'WA', 'WA1158DC', 'Pontoon', 40.5, 9.9, 1994),
    ('PEBVZCYPRGY2', 'Sea Glass', 'WA', 'WA3532HF', 'Powerboat', 28.4, 8.2, 2011),
    ('XZHTLG0C6QN5', 'Barnacle Bill', 'OR', 'OR6000HH', 'Sailboat', 30.1, 7.3, 1997),
    ('MWS1XBHSMSCG', 'Tidewater Spirit', 'WA', 'WA8119MZ', 'Catamaran', 37.7, 9.3, 2012),
    ('JBY3A9NZ3EXW', 'Silver Wake', 'WA', 'WA3041ZK', 'Center Console', 39.3, 12.5, 2004),
    ('TEG20MV1AVUP', 'Nauti Buoy', 'WA', 'WA6279QQ', 'Trawler', 39.1, 11.2, 1998),
    ('XCK8XFRVQNKB', 'Windward Bound', 'WA', 'WA5011RV', 'Sailboat', 21.5, 5.3, 2014),
    ('RNHKAG3QM95D', 'Kingfisher', 'OR', 'OR2988QE', 'Trawler', 24.6, 6.7, 2018),
    ('TQF64SRT97RT', 'Sea Fever', 'OR', 'OR2269YK', 'Powerboat', 48.6, 11.9, 2002),
    ('EHNKPE22X52D', 'Ebb and Flow', 'WA', 'WA7883NU', 'Pontoon', 20.4, 5.6, 1986),
    ('AMK02Q7QT37B', 'Reel Time', 'OR', 'OR6507XX', 'Trawler', 24.6, 6.7, 1995),
    ('NUUBF3J5MDS0', 'Stormy Petrel', 'WA', 'WA4467QL', 'Catamaran', 21.5, 6.8, 2009),
    ('CRADYQECBRNB', 'Salty Dog', 'WA', 'WA4908ER', 'Pontoon', 36.6, 9.2, 1992),
    ('MFVHLVGBV01N', 'Restless Fathom', 'WA', 'WA4978DY', 'Catamaran', 25.1, 7.1, 2023),
    ('MTPZE8XA27G3', 'Wind Dancer', 'WA', 'WA6934WQ', 'Pontoon', 24.0, 6.5, 1994),
    ('VTR53TWRFT4R', 'Vagabond', 'WA', 'WA8613UV', 'Pontoon', 35.1, 9.7, 2009),
    ('RGMSXTTA9NFR', 'Deep Water Dream', 'WA', 'WA7658RT', 'Powerboat', 28.3, 7.0, 2015),
    ('CKH1RVZ69Y3X', 'Neptunes Grace', 'WA', 'WA8434JK', 'Catamaran', 36.2, 10.2, 1999),
    ('GGZ6T9UGNUQZ', 'Anchors Away', 'WA', 'WA5952AY', 'Center Console', 36.3, 10.7, 1993),
    ('YEW7GAU664XM', 'Tidal Grace', 'WA', 'WA5136RD', 'Sailboat', 18.3, 6.0, 2010),
    ('EEUVFRH2Q904', 'High Tide', 'WA', 'WA8253KU', 'Trawler', 33.3, 8.9, 2004),
    ('GWGSFLRMELA2', 'Coral Wanderer', 'WA', 'WA5771BH', 'Catamaran', 35.1, 9.4, 2003),
    ('WUXN3HQKTKED', 'Rip Current', 'WA', 'WA6039VZ', 'Center Console', 33.2, 10.1, 2003),
    ('JST74FC3WSBF', 'Gale Force', 'OR', 'OR1339XJ', 'Center Console', 34.2, 8.9, 1987),
    ('JFU37F6Y2XWG', 'Aegean Mist', 'OR', 'OR3634LP', 'Pontoon', 36.7, 10.3, 2016),
    ('QCLSWH18A52D', 'Second Chance', 'WA', 'WA9494MV', 'Trawler', 23.0, 6.6, 2013),
    ('KQY7HBRLVA2F', 'Cutlass', 'WA', 'WA2858QD', 'Pontoon', 18.4, 5.5, 1994),
    ('PRRR5K0N8JET', 'Windswept', 'WA', 'WA7798LS', 'Catamaran', 38.7, 11.6, 1985),
    ('EQT6YX05WNR0', 'Weekend Warrior', 'OR', 'OR1715LZ', 'Trawler', 23.4, 5.8, 2009),
    ('RBE8XG4G95AK', 'Northbound', 'WA', 'WA3529CR', 'Catamaran', 39.4, 10.0, 2006),
    ('LWY7CERUQF3G', 'Horizon Chaser', 'OR', 'OR2646QF', 'Pontoon', 22.9, 5.7, 2004),
    ('MMPKR92MLMF0', 'Drift Away', 'WA', 'WA4945RU', 'Powerboat', 28.5, 7.2, 1999),
    ('QKXLE4YV3S5V', 'Northern Star', 'WA', 'WA4886NU', 'Catamaran', 22.8, 6.4, 2021),
    ('JAUD7UQYQNSJ', 'Gulfstream', 'OR', 'OR1645KQ', 'Sailboat', 25.4, 7.6, 2022),
    ('LZPMNJZ98TLS', 'Blue Yonder', 'WA', 'WA8894KZ', 'Catamaran', 23.5, 7.6, 1992),
    ('XZX1ZF1ASH5Z', 'Landfall', 'WA', 'WA5295UN', 'Pontoon', 25.2, 8.0, 2008),
    ('VHWE5V2HJCCV', 'Pacific Drift', 'WA', 'WA2902DH', 'Center Console', 23.1, 6.5, 1993),
    ('UZZK2G72TCZP', 'Blue Lagoon', 'OR', 'OR4868MD', 'Pontoon', 39.9, 10.5, 2008),
    ('NJGH5FPBDXRJ', 'Full Circle', 'WA', 'WA4362CT', 'Powerboat', 47.8, 12.7, 2022),
    ('VAJKJSMHBJAY', 'Bowsprit', 'WA', 'WA6304AF', 'Catamaran', 37.4, 11.4, 1988),
    ('RQM8G48QC9V5', 'Moonshadow', 'WA', 'WA1510BR', 'Trawler', 23.6, 6.5, 2012),
    ('CLVKEJTW09U5', 'Riptide', 'WA', 'WA8048DY', 'Sailboat', 33.6, 8.2, 2020),
    ('PLQ12GW3WSZK', 'Loose Change', 'WA', 'WA8770CC', 'Sailboat', 38.0, 10.8, 1990),
    ('TBUXH2Y3DUVY', 'Ospreys Nest', 'WA', 'WA9313GE', 'Pontoon', 29.1, 7.5, 2015),
    ('DJUQ3BTBMTVX', 'Blue Horizon', 'WA', 'WA3972EU', 'Pontoon', 37.7, 11.0, 2010),
    ('CZSP025XLZVW', 'Coastal Drift', 'WA', 'WA1861EF', 'Center Console', 19.1, 5.1, 1988),
    ('VQPTP8HY3HU7', 'Sandpiper', 'OR', 'OR6053BH', 'Trawler', 36.8, 9.7, 2023),
    ('EJKWHA73MJ0Q', 'Meridian Star', 'WA', 'WA6802CN', 'Pontoon', 28.1, 8.4, 1987),
    ('UPU12UH1BWL5', 'Free Spirit', 'WA', 'WA2443PD', 'Powerboat', 32.3, 7.9, 2012),
    ('ZLHXLE8H98NY', 'Sunset Runner', 'WA', 'WA4232FV', 'Powerboat', 39.0, 12.6, 1989),
    ('UUQWWK4E64VT', 'Windrunner', 'OR', 'OR8565QB', 'Sailboat', 38.9, 10.4, 2008),
    ('VVS05C4NW68K', 'Compass Rose', 'WA', 'WA2381SW', 'Powerboat', 31.3, 8.3, 1987);

-- =============================================================================
-- Table 5: Slip Size (SlipSize) | Owner: White, S. |
-- Inward FKs SlipSize.slipSizeID <- Slip.slipSizeID, SlipSize.slipSizeID <- WaitList.slipSizeID
-- Outward FKs (none)
-- =============================================================================
CREATE TABLE SlipSize (
    slipSizeID INT AUTO_INCREMENT PRIMARY KEY,
    sizeFt INT NOT NULL UNIQUE COMMENT 'Slip size category in feet.'
);

-- Seeded with the marina's 3 defined slip sizes
INSERT INTO SlipSize (sizeFt) VALUES
    (26),
    (40),
    (50);

-- =============================================================================
-- Table 6: Wait List (WaitList) | Owner: White, S. |
-- Inward FKs (none)
-- Outward FKs WaitList.customerID FK -> Customer.customerID,
--             WaitList.slipSizeID FK -> SlipSize.slipSizeID
-- =============================================================================
CREATE TABLE WaitList (
    waitListID INT AUTO_INCREMENT PRIMARY KEY,
    customerID INT NOT NULL COMMENT 'Customer requesting a slip.',
    slipSizeID INT NOT NULL COMMENT 'Requested slip size category.',
    timeJoined TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Date and time customer joined the wait list.',
    timeClosed TIMESTAMP NULL COMMENT 'Date and time wait list entry was closed; null while active.',
    status ENUM('Waiting', 'Offered', 'Fulfilled', 'Cancelled') NOT NULL DEFAULT 'Waiting' COMMENT 'Current status of the wait list entry.',
    CONSTRAINT fkWaitListCustomerID FOREIGN KEY (customerID) REFERENCES Customer (customerID),
    CONSTRAINT fkWaitListSlipSizeID FOREIGN KEY (slipSizeID) REFERENCES SlipSize (slipSizeID)
);

INSERT INTO WaitList (customerID, slipSizeID, timeJoined, timeClosed, status) VALUES
    (2, (SELECT slipSizeID FROM SlipSize WHERE sizeFt = 40), '2026-01-15 09:00:00', '2026-07-01 09:00:00', 'Fulfilled'),
    (4, (SELECT slipSizeID FROM SlipSize WHERE sizeFt = 40), '2026-06-20 11:30:00', NULL, 'Waiting'),
    (5, (SELECT slipSizeID FROM SlipSize WHERE sizeFt = 40), '2026-07-05 14:15:00', NULL, 'Waiting'),
    (6, (SELECT slipSizeID FROM SlipSize WHERE sizeFt = 40), '2026-07-18 08:45:00', NULL, 'Waiting');

-- =============================================================================
-- Table 7: Boat Ownership (BoatOwnership) | Owner: White, S. |
-- Inward FKs (none)
-- Outward FKs BoatOwnership.boatID FK -> Boat.boatID,
--             BoatOwnership.customerID FK -> Customer.customerID
-- =============================================================================
CREATE TABLE BoatOwnership (
    ownershipID INT AUTO_INCREMENT PRIMARY KEY,
    boatID INT NOT NULL COMMENT 'References the physical boat.',
    customerID INT NOT NULL COMMENT 'References the customer who owns or owned the boat.',
    startDate DATE NOT NULL COMMENT 'Date ownership began.',
    endDate DATE NULL COMMENT 'Date ownership ended; NULL for current ownership.',
    CONSTRAINT chkOwnershipDates CHECK (endDate IS NULL OR endDate >= startDate),
    CONSTRAINT fkBoatOwnershipBoatID FOREIGN KEY (boatID) REFERENCES Boat (boatID),
    CONSTRAINT fkBoatOwnershipCustomerID FOREIGN KEY (customerID) REFERENCES Customer (customerID)
);
-- Rows for boats 1-6 are Sara White's (Module-4/02_seed_data.sql, commit
-- b5ec80d). Everything from boat 7 on (the 3 additional sales and the
-- current-owner row for every other boat, through boat 60) was added by
-- Claude (Anthropic) to cover the rest of the marina.
INSERT INTO BoatOwnership (boatID, customerID, startDate, endDate) VALUES
    (1, 1, '2023-04-15', NULL),
    (2, 2, '2024-02-10', NULL),
    (3, 3, '2024-08-22', NULL),
    -- Gullwing was sold by customer 4 to customer 6
    (4, 4, '2022-06-01', '2026-06-15'),
    (4, 6, '2026-06-15', NULL),
    -- Customer 5 currently owns two boats
    (5, 5, '2023-09-12', NULL),
    (6, 5, '2021-05-20', NULL),
    -- Fair Winds was sold by customer 1 to customer 6
    (7, 1, '2025-04-01', '2026-05-03'),
    (7, 6, '2026-05-03', NULL),
    -- Customer 7 currently owns two boats
    (8, 7, '2026-06-05', NULL),
    (9, 7, '2026-06-26', NULL),
    -- Customer 8 currently owns two boats
    (10, 8, '2026-04-18', NULL),
    (11, 8, '2026-07-23', NULL),
    -- Customer 9 currently owns two boats
    (12, 9, '2026-08-13', NULL),
    (13, 9, '2026-08-17', NULL),
    -- Customer 10 currently owns two boats
    (14, 10, '2026-06-05', NULL),
    (15, 10, '2026-04-17', NULL),
    -- Customer 11 currently owns two boats
    (16, 11, '2026-07-02', NULL),
    (17, 11, '2026-07-06', NULL),
    -- Customer 12 currently owns two boats
    (18, 12, '2026-07-31', NULL),
    (19, 12, '2026-07-23', NULL),
    -- Stormy Petrel was sold by customer 7 to customer 13
    (20, 7, '2025-09-15', '2026-03-23'),
    (20, 13, '2026-03-23', NULL),
    -- Customer 13 also owns boat 21 - two boats total
    (21, 13, '2026-08-16', NULL),
    (22, 14, '2026-03-28', NULL),
    (23, 15, '2026-03-29', NULL),
    (24, 16, '2025-10-15', NULL),
    (25, 17, '2026-07-27', NULL),
    (26, 18, '2025-06-18', NULL),
    (27, 19, '2025-12-08', NULL),
    (28, 20, '2026-05-07', NULL),
    (29, 21, '2026-05-18', NULL),
    (30, 22, '2026-04-29', NULL),
    (31, 23, '2026-06-14', NULL),
    (32, 24, '2026-07-24', NULL),
    (33, 25, '2026-07-28', NULL),
    (34, 26, '2026-08-03', NULL),
    -- Cutlass was sold by customer 10 to customer 27
    (35, 10, '2025-09-01', '2026-07-10'),
    (35, 27, '2026-07-10', NULL),
    (36, 28, '2025-12-01', NULL),
    (37, 29, '2026-04-26', NULL),
    (38, 30, '2026-03-21', NULL),
    (39, 31, '2026-07-09', NULL),
    (40, 32, '2026-03-03', NULL),
    (41, 33, '2026-03-17', NULL),
    (42, 34, '2026-04-11', NULL),
    (43, 35, '2025-12-27', NULL),
    (44, 36, '2025-08-09', NULL),
    (45, 37, '2026-05-19', NULL),
    (46, 38, '2026-05-08', NULL),
    (47, 39, '2026-07-31', NULL),
    (48, 40, '2026-02-17', NULL),
    (49, 41, '2025-06-01', NULL),
    (50, 42, '2026-04-18', NULL),
    (51, 43, '2026-06-25', NULL),
    (52, 44, '2026-07-01', NULL),
    (53, 45, '2025-06-15', NULL),
    (54, 46, '2026-04-20', NULL),
    (55, 47, '2026-04-06', NULL),
    (56, 48, '2026-03-30', NULL),
    (57, 49, '2026-06-07', NULL),
    (58, 50, '2026-08-16', NULL),
    (59, 51, '2026-07-09', NULL),
    (60, 52, '2026-07-12', NULL);

-- =============================================================================
-- Table 8: Slip | Owner: Breutzmann, R. |
-- Inward FKs Slip.slipID <- Reservation.slipID
-- Outward FKs Slip.dockID FK -> Dock.dockID, Slip.slipSizeID FK -> SlipSize.slipSizeID
-- =============================================================================
CREATE TABLE Slip (
    slipID INT AUTO_INCREMENT PRIMARY KEY,
    slipNumber INT NOT NULL COMMENT 'Customer facing slip number.',
    slipDescription VARCHAR(255) COMMENT 'A customer facing brief description of the slip.',
    dockID INT NOT NULL,
    slipStatus ENUM ('operational', 'maintenance', 'unavailable') NOT NULL DEFAULT 'operational' COMMENT 'Occupied status of the slip.',
    slipSizeID INT NOT NULL COMMENT 'References the slip size category, see SlipSize.sizeFt.',
    CONSTRAINT uqDockSlipNumber UNIQUE (dockID, slipNumber),
    CONSTRAINT fkSlipDockID FOREIGN KEY (dockID) REFERENCES Dock (dockID),
    CONSTRAINT fkSlipSlipSizeID FOREIGN KEY (slipSizeID) REFERENCES SlipSize (slipSizeID)
);

-- Dock A: 24 slips (6 x 50ft, 8 x 40ft, 10 x 26ft)
INSERT INTO Slip (slipNumber, slipDescription, dockID, slipStatus, slipSizeID)
SELECT v.slipNumber, v.slipDescription, d.dockID, 'operational', sz.slipSizeID
FROM Dock d
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
) v ON d.dockNumber = 'A'
JOIN SlipSize sz ON sz.sizeFt = v.slipSize;

-- Dock B: 24 slips (6 x 50ft, 8 x 40ft, 10 x 26ft)
INSERT INTO Slip (slipNumber, slipDescription, dockID, slipStatus, slipSizeID)
SELECT v.slipNumber, v.slipDescription, d.dockID, 'operational', sz.slipSizeID
FROM Dock d
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
) v ON d.dockNumber = 'B'
JOIN SlipSize sz ON sz.sizeFt = v.slipSize;

-- Dock C: 24 slips (6 x 50ft, 8 x 40ft, 10 x 26ft)
INSERT INTO Slip (slipNumber, slipDescription, dockID, slipStatus, slipSizeID)
SELECT v.slipNumber, v.slipDescription, d.dockID, 'operational', sz.slipSizeID
FROM Dock d
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
) v ON d.dockNumber = 'C'
JOIN SlipSize sz ON sz.sizeFt = v.slipSize;

-- ---------------------------------------------------------------------------
-- Slip status: pull a handful out of 'operational' for realism
-- ---------------------------------------------------------------------------
UPDATE Slip s JOIN Dock d ON s.dockID = d.dockID
SET s.slipStatus = 'maintenance' WHERE d.dockNumber = 'B' AND s.slipNumber = 8;
UPDATE Slip s JOIN Dock d ON s.dockID = d.dockID
SET s.slipStatus = 'unavailable' WHERE d.dockNumber = 'C' AND s.slipNumber = 8;
UPDATE Slip s JOIN Dock d ON s.dockID = d.dockID
SET s.slipStatus = 'maintenance' WHERE d.dockNumber = 'B' AND s.slipNumber = 16;
UPDATE Slip s JOIN Dock d ON s.dockID = d.dockID
SET s.slipStatus = 'unavailable' WHERE d.dockNumber = 'B' AND s.slipNumber = 13;

-- =============================================================================
-- Table 9: Contact | Owner: Breutzmann, R. |
-- Inward FKs (none)
-- Outward FKs Contact.respondedEmployeeID FK -> Employee.employeeID
-- =============================================================================
CREATE TABLE Contact (
    contactID INT AUTO_INCREMENT PRIMARY KEY,
    firstName VARCHAR(50) NOT NULL COMMENT 'Contact''s first name, required.',
    lastName VARCHAR(50) NOT NULL COMMENT 'Contact''s last name, required.',
    email VARCHAR(255) NOT NULL COMMENT 'Contact''s email address, required.',
    boatName VARCHAR(100) COMMENT 'Name of the contact''s boat, optional - free text, not a link to the boat table.',
    boatLength DECIMAL(6,2) COMMENT 'Length of the contact''s boat in feet, optional.',
    reasonForContact ENUM ('Reservation Question', 'Waitlist Question', 'Billing', 'Maintenance Issue', 'General Inquiry', 'Other') NOT NULL COMMENT 'Reason the contact form was submitted.',
    message TEXT NOT NULL COMMENT 'Full text of the message submitted.',
    responded BOOLEAN NOT NULL DEFAULT FALSE COMMENT 'Whether marina staff has responded to this submission.',
    respondedDate TIMESTAMP NULL COMMENT 'Date/time staff responded, null until responded.',
    respondedMessage TEXT COMMENT 'Staff''s response message, null until responded.',
    respondedEmployeeID INT NULL COMMENT 'References employee.employeeID - the employee who responded, null until responded.',
    CONSTRAINT fkContactRespondedEmployeeID FOREIGN KEY (respondedEmployeeID) REFERENCES Employee (employeeID)
);

-- Placeholder dev data: 10 fictional ship captains submit the marina's Contact Us form, each in character.
INSERT INTO Contact (firstName, lastName, email, boatName, boatLength, reasonForContact, message, responded, respondedDate, respondedMessage)
VALUES
    ('Jack', 'Sparrow', 'jack.sparrow@blackpearl.sea', 'Black Pearl', 145.00, 'General Inquiry',
        'Savvy? Before I so much as consider a slip, I require a straight answer: how abundant is the rum supply at your marina? And I do mean rum, not "spiced rum-adjacent beverage" - I know the difference, mate, even when the room is spinning. A pirate has priorities.',
        TRUE, '2026-06-14 10:15:00',
        'Mr. Sparrow - the Ship Store keeps a modest selection of spiced rum for sale, though we do not provide complimentary rum with slip rentals. We look forward to your visit (and kindly ask that the Black Pearl not depart under cover of a "borrowed" longboat).'),
    ('The', 'Captain', 'thecaptain@majesticmetaphors.com', NULL, NULL, 'Reservation Question',
        'A ship, you see, is never just a ship - it is a vessel for who we are becoming. I do not yet possess a physical craft, but a Captain must always secure his harbor before he secures his heart. Reserve me your finest slip, on indefinite hold, so that when my vessel arrives - and it will arrive - I am ready to meet it as a Captain should: standing on the dock, unafraid.',
        TRUE, '2026-05-02 16:40:00',
        'Thank you for your submission. As we have no boat on file to assign a slip to, we are unable to hold a reservation at this time - please reach back out once you have a vessel and its dimensions, and we would be glad to assist.'),
    ('Han', 'Solo', 'han.solo@corellianfreighter.com', 'Millennium Falcon', 114.00, 'Maintenance Issue',
        'Look, she may not look like much, but she is the fastest hunk of junk in this galaxy, and right now her hyperdrive is acting up again. I need a mechanic who will not ask questions about the "modifications" under the deck plating, and I need it done fast - I have got people who are not exactly patient looking for me.',
        FALSE, NULL, NULL),
    ('Malcolm', 'Reynolds', 'mal.reynolds@serenity.verse', 'Serenity', 265.00, 'Billing',
        'I run a crew, not a charity, so before Serenity so much as clips a line to one of your slips I want to know exactly what this is gonna cost me, and whether you will take payment in platinum. I would also take it kindly if your paperwork did not find its way into any Alliance hands - a captain likes to keep his business his own.',
        FALSE, NULL, NULL),
    ('Jean-Luc', 'Picard', 'jl.picard@starfleet.ufp', 'USS Enterprise (NCC-1701-D)', 2108.00, 'General Inquiry',
        'I am given to understand that your largest slip accommodates a vessel of some fifty feet. The Enterprise measures rather more than that - upward of two thousand, in point of fact - so before we make first contact with your marina in truth, I should like to know whether some manner of exception, or at minimum a very long dock, might be arranged.',
        TRUE, '2026-07-20 09:05:00',
        'Captain Picard - we are flattered by the inquiry, but must respectfully report that no slip in this marina, nor any marina we are aware of, could accommodate a vessel of that scale. We would, however, be delighted to have the Enterprise anchor offshore while the crew enjoys the Ship Store by shuttle.'),
    ('Ahab', 'of the Pequod', 'ahab@pequodwhaling.com', 'Pequod', 104.00, 'Waitlist Question',
        'I am told your slips are all spoken for and that I must be content to wait. Wait I will not - not for a berth, and certainly not for the white whale I have hunted these many years across every ocean there is. Tell me plainly where I stand on your list, and do not test the patience of a man who has already given a leg to this pursuit.',
        FALSE, NULL, NULL),
    ('Nemo', 'N/A', 'captain.nemo@nautilus.sea', 'Nautilus', 229.66, 'Other',
        'I have no nation, no name that matters, and no interest in the questions your paperwork tends to ask. I require a berth for the Nautilus, discretion regarding her comings and goings, and no undue curiosity about what lies beneath her waterline. I trust this is not an unreasonable arrangement for a man who owes nothing to the surface world.',
        TRUE, '2026-04-11 22:30:00',
        'Captain Nemo - we can offer a quiet, end-of-dock slip and can keep your registration details confidential per our standard privacy policy. We would ask, however, that the Nautilus surface for a standard hull inspection, same as any vessel.'),
    ('James', 'Hook', 'james.hook@jollyroger.sea', 'Jolly Roger', 100.00, 'Other',
        'A most pressing concern, and one I do not raise lightly: is there, to your knowledge, a large crocodile in these waters? One with, shall we say, a rather punctual disposition and an old score to settle with my left hand? I require an honest answer before the Jolly Roger comes anywhere near your docks - a codfish such as myself cannot be too careful.',
        FALSE, NULL, NULL),
    ('Odysseus', 'of Ithaca', 'odysseus@ithacashipping.gr', 'The Ithacan Galley', 100.00, 'Reservation Question',
        'I have been rather a long time at sea - longer, I confess, than I intended, and not for lack of trying to get home. I require a single night''s berth for my ship and crew, safe from any singing women on nearby rocks and any establishment offering suspiciously excellent hospitality. One night only; my wife is waiting.',
        TRUE, '2026-08-01 11:00:00',
        'Mr. of Ithaca - a one-night slip is reserved as requested. We can confirm there are no sirens native to this marina, though we cannot speak for the karaoke night at the dockside restaurant on Fridays. Safe travels home.'),
    ('Noah', 'of the Ark', 'noah@thearkmarine.com', 'The Ark', 450.00, 'Other',
        'I am inquiring on behalf of a somewhat larger party than usual - two of every kind, to be precise, so I will need more than the standard amount of deck space and, frankly, a very serious answer on whether your slips can hold a vessel three hundred cubits long. Also, does your marina have a policy on livestock?',
        FALSE, NULL, NULL);

-- =============================================================================
-- Table 10: Reservation | Owner: Rodriguez, C. |
-- Inward FKs Reservation.reservationID <- TerminationNotice.reservationID
-- Outward FKs Reservation.customerID FK -> Customer.customerID, Reservation.boatID FK -> Boat.boatID, Reservation.slipID FK -> Slip.slipID
-- =============================================================================
CREATE TABLE Reservation (
    reservationID INT AUTO_INCREMENT PRIMARY KEY,
    confirmationNumber VARCHAR(30) NOT NULL UNIQUE,
    customerID INT NOT NULL,
    boatID INT NOT NULL,
    slipID INT NOT NULL,
    startDate DATE NOT NULL,
    monthlyRate DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_reservation_customer FOREIGN KEY (customerID) REFERENCES Customer (customerID),
    CONSTRAINT fk_reservation_boat FOREIGN KEY (boatID) REFERENCES Boat (boatID),
    CONSTRAINT fk_reservation_slip FOREIGN KEY (slipID) REFERENCES Slip (slipID)
);


-- Reservations 4-60 (57 rows) were generated by Claude (Anthropic) to fill
-- out the marina to the following occupancy targets, taken from real
-- product requirements for this project: 26 ft slips ~80% full and spread
-- evenly across the 3 docks, 40 ft slips 100% full, and only 2 of the 18
-- 50 ft slips left open for reservation (one on Dock A, one on Dock C).
-- Reservations 4-6 reuse the previously-unreserved boats 4, 5, and 6;
-- reservation 7 finally gives customer 6 (previously boatless/wait-listed)
-- a slip. The schema (this CREATE TABLE) was written by the team.
-- Reviewed by the database lead, Breutzmann, R.
--
-- Reservation 4 (boat 4) is under customer 6, not customer 4: BoatOwnership
-- has boat 4 (Gullwing) sold by customer 4 to customer 6 on 2026-06-15, so
-- this reservation was reassigned to the new owner with a startDate on the
-- sale date - resolves the customerID mismatch previously flagged in the
-- BoatOwnership seed comment below.
INSERT INTO Reservation
    (reservationID, confirmationNumber, customerID, boatID, slipID, startDate, monthlyRate)
SELECT v.reservationID, v.confirmationNumber, v.customerID, v.boatID, s.slipID, v.startDate, v.monthlyRate
FROM (
    SELECT 1 AS reservationID, 'MB-00001' AS confirmationNumber, 1 AS customerID, 1 AS boatID, 'A' AS dockLetter, 8 AS slipNumber, '2026-06-01' AS startDate, 485.00 AS monthlyRate
    UNION ALL SELECT 2, 'MB-00002', 2, 2, 'A', 4, '2026-07-01', 585.00
    UNION ALL SELECT 3, 'MB-00003', 3, 3, 'A', 1, '2026-05-15', 685.00
    UNION ALL SELECT 4, 'MB-00004', 6, 4, 'A', 5, '2026-06-15', 585.00
    UNION ALL SELECT 5, 'MB-00005', 5, 5, 'A', 9, '2026-05-01', 485.00
    UNION ALL SELECT 6, 'MB-00006', 5, 6, 'A', 2, '2026-05-07', 685.00
    UNION ALL SELECT 7, 'MB-00007', 6, 7, 'B', 17, '2026-05-03', 585.00
    UNION ALL SELECT 8, 'MB-00008', 7, 8, 'C', 12, '2026-06-05', 485.00
    UNION ALL SELECT 9, 'MB-00009', 7, 9, 'C', 1, '2026-06-26', 685.00
    UNION ALL SELECT 10, 'MB-00010', 8, 10, 'C', 16, '2026-04-18', 585.00
    UNION ALL SELECT 11, 'MB-00011', 8, 11, 'A', 18, '2026-07-23', 585.00
    UNION ALL SELECT 12, 'MB-00012', 9, 12, 'B', 2, '2026-08-13', 685.00
    UNION ALL SELECT 13, 'MB-00013', 9, 13, 'B', 6, '2026-08-17', 585.00
    UNION ALL SELECT 14, 'MB-00014', 10, 14, 'B', 14, '2026-06-05', 685.00
    UNION ALL SELECT 15, 'MB-00015', 10, 15, 'C', 9, '2026-04-17', 485.00
    UNION ALL SELECT 16, 'MB-00016', 11, 16, 'C', 10, '2026-07-02', 485.00
    UNION ALL SELECT 17, 'MB-00017', 11, 17, 'C', 13, '2026-07-06', 685.00
    UNION ALL SELECT 18, 'MB-00018', 12, 18, 'A', 20, '2026-07-31', 485.00
    UNION ALL SELECT 19, 'MB-00019', 12, 19, 'B', 21, '2026-07-23', 485.00
    UNION ALL SELECT 20, 'MB-00020', 13, 20, 'B', 9, '2026-03-23', 485.00
    UNION ALL SELECT 21, 'MB-00021', 13, 21, 'A', 7, '2026-08-16', 585.00
    UNION ALL SELECT 22, 'MB-00022', 14, 22, 'B', 10, '2026-03-28', 485.00
    UNION ALL SELECT 23, 'MB-00023', 15, 23, 'A', 22, '2026-03-29', 485.00
    UNION ALL SELECT 24, 'MB-00024', 16, 24, 'B', 15, '2025-10-15', 685.00
    UNION ALL SELECT 25, 'MB-00025', 17, 25, 'C', 19, '2026-07-27', 585.00
    UNION ALL SELECT 26, 'MB-00026', 18, 26, 'B', 4, '2025-06-18', 585.00
    UNION ALL SELECT 27, 'MB-00027', 19, 27, 'B', 7, '2025-12-08', 585.00
    UNION ALL SELECT 28, 'MB-00028', 20, 28, 'C', 21, '2026-05-07', 485.00
    UNION ALL SELECT 29, 'MB-00029', 21, 29, 'A', 14, '2026-05-18', 685.00
    UNION ALL SELECT 30, 'MB-00030', 22, 30, 'C', 4, '2026-04-29', 585.00
    UNION ALL SELECT 31, 'MB-00031', 23, 31, 'A', 13, '2026-06-14', 685.00
    UNION ALL SELECT 32, 'MB-00032', 24, 32, 'B', 3, '2026-07-24', 685.00
    UNION ALL SELECT 33, 'MB-00033', 25, 33, 'C', 6, '2026-07-28', 585.00
    UNION ALL SELECT 34, 'MB-00034', 26, 34, 'B', 12, '2026-08-03', 485.00
    UNION ALL SELECT 35, 'MB-00035', 27, 35, 'B', 22, '2026-07-10', 485.00
    UNION ALL SELECT 36, 'MB-00036', 28, 36, 'A', 16, '2025-12-01', 585.00
    UNION ALL SELECT 37, 'MB-00037', 29, 37, 'A', 21, '2026-04-26', 485.00
    UNION ALL SELECT 38, 'MB-00038', 30, 38, 'C', 18, '2026-03-21', 585.00
    UNION ALL SELECT 39, 'MB-00039', 31, 39, 'B', 11, '2026-07-09', 485.00
    UNION ALL SELECT 40, 'MB-00040', 32, 40, 'B', 5, '2026-03-03', 585.00
    UNION ALL SELECT 41, 'MB-00041', 33, 41, 'A', 12, '2026-03-17', 485.00
    UNION ALL SELECT 42, 'MB-00042', 34, 42, 'A', 10, '2026-04-11', 485.00
    UNION ALL SELECT 43, 'MB-00043', 35, 43, 'C', 20, '2025-12-27', 485.00
    UNION ALL SELECT 44, 'MB-00044', 36, 44, 'C', 22, '2025-08-09', 485.00
    UNION ALL SELECT 45, 'MB-00045', 37, 45, 'B', 20, '2026-05-19', 485.00
    UNION ALL SELECT 46, 'MB-00046', 38, 46, 'C', 14, '2026-05-08', 685.00
    UNION ALL SELECT 47, 'MB-00047', 39, 47, 'C', 2, '2026-07-31', 685.00
    UNION ALL SELECT 48, 'MB-00048', 40, 48, 'C', 17, '2026-02-17', 585.00
    UNION ALL SELECT 49, 'MB-00049', 41, 49, 'A', 11, '2025-06-01', 485.00
    UNION ALL SELECT 50, 'MB-00050', 42, 50, 'C', 5, '2026-04-18', 585.00
    UNION ALL SELECT 51, 'MB-00051', 43, 51, 'A', 19, '2026-06-25', 585.00
    UNION ALL SELECT 52, 'MB-00052', 44, 52, 'C', 7, '2026-07-01', 585.00
    UNION ALL SELECT 53, 'MB-00053', 45, 53, 'A', 17, '2025-06-15', 585.00
    UNION ALL SELECT 54, 'MB-00054', 46, 54, 'C', 11, '2026-04-20', 485.00
    UNION ALL SELECT 55, 'MB-00055', 47, 55, 'A', 3, '2026-04-06', 685.00
    UNION ALL SELECT 56, 'MB-00056', 48, 56, 'B', 18, '2026-03-30', 585.00
    UNION ALL SELECT 57, 'MB-00057', 49, 57, 'C', 3, '2026-06-07', 685.00
    UNION ALL SELECT 58, 'MB-00058', 50, 58, 'B', 1, '2026-08-16', 685.00
    UNION ALL SELECT 59, 'MB-00059', 51, 59, 'B', 19, '2026-07-09', 585.00
    UNION ALL SELECT 60, 'MB-00060', 52, 60, 'A', 6, '2026-07-12', 585.00
) v
JOIN Dock d ON d.dockNumber = v.dockLetter
JOIN Slip s ON s.dockID = d.dockID AND s.slipNumber = v.slipNumber;


-- =============================================================================
-- Table 11: Termination Notice (TerminationNotice) | Owner: Rodriguez, C. |
-- Inward FKs (none)
-- Outward FKs TerminationNotice.reservationID FK -> Reservation.reservationID
-- =============================================================================
CREATE TABLE TerminationNotice (
    terminationNoticeID INT AUTO_INCREMENT PRIMARY KEY,
    reservationID INT NOT NULL UNIQUE,
    noticeDate DATE NOT NULL,
    terminationDate DATE NULL,
    noticeStatus ENUM(
        'Submitted',
        'Pending',
        'Approved',
        'Withdrawn',
        'Completed'
    ) NOT NULL,
    CONSTRAINT fk_terminationNotice_reservation FOREIGN KEY (reservationID) REFERENCES Reservation (reservationID)
);

INSERT INTO TerminationNotice
    (terminationNoticeID, reservationID, noticeDate, terminationDate, noticeStatus)
VALUES
    (1, 1, '2026-08-01', NULL, 'Submitted'),
    (2, 2, '2026-08-10', NULL, 'Pending'),
    (3, 3, '2026-08-15', '2026-09-14', 'Approved');

