-- =============================================================================
-- Team: Blue Team
-- Roster: Breutzmann, R. | White, S. | Fernandez, M. | Rodriguez, C.
-- CSD 460 - Moffat Bay Marina
-- File: 02_seed_data.sql
-- Purpose: Populate each team member's tables with placeholder dev data.
--          Safe to re-run - INSERT IGNORE plus the unique constraints on
--          dock.dockNumber and slip(dockID, slipNumber) skip rows that
--          already exist. contact has no natural unique key (a real visitor
--          could submit more than once), so its block is instead guarded by
--          "only seed if the table is currently empty".
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

-- ---------------------------------------------------------------------------
-- Contact - Contact Us submissions
-- ---------------------------------------------------------------------------
-- Placeholder dev data: 10 fictional ship captains submit the marina's
-- Contact Us form, each in character. No natural unique key on this table,
-- so this block is guarded by "only seed if the table is currently empty"
-- instead of INSERT IGNORE, to keep it safe to re-run without piling up
-- duplicate rows.
INSERT INTO contact (firstName, lastName, email, boatName, boatLength, reasonForContact, message, responded, respondedDate, respondedMessage)
SELECT * FROM (
    SELECT 'Jack' AS firstName, 'Sparrow' AS lastName, 'jack.sparrow@blackpearl.sea' AS email, 'Black Pearl' AS boatName, 145.00 AS boatLength, 'General Inquiry' AS reasonForContact,
        'Savvy? Before I so much as consider a slip, I require a straight answer: how abundant is the rum supply at your marina? And I do mean rum, not "spiced rum-adjacent beverage" - I know the difference, mate, even when the room is spinning. A pirate has priorities.' AS message,
        TRUE AS responded, '2026-06-14 10:15:00' AS respondedDate,
        'Mr. Sparrow - the Ship Store keeps a modest selection of spiced rum for sale, though we do not provide complimentary rum with slip rentals. We look forward to your visit (and kindly ask that the Black Pearl not depart under cover of a "borrowed" longboat).' AS respondedMessage
    UNION ALL
    SELECT 'The', 'Captain', 'thecaptain@majesticmetaphors.com', NULL, NULL, 'Reservation Question',
        'A ship, you see, is never just a ship - it is a vessel for who we are becoming. I do not yet possess a physical craft, but a Captain must always secure his harbor before he secures his heart. Reserve me your finest slip, on indefinite hold, so that when my vessel arrives - and it will arrive - I am ready to meet it as a Captain should: standing on the dock, unafraid.',
        TRUE, '2026-05-02 16:40:00',
        'Thank you for your submission. As we have no boat on file to assign a slip to, we are unable to hold a reservation at this time - please reach back out once you have a vessel and its dimensions, and we would be glad to assist.'
    UNION ALL
    SELECT 'Han', 'Solo', 'han.solo@corellianfreighter.com', 'Millennium Falcon', 114.00, 'Maintenance Issue',
        'Look, she may not look like much, but she is the fastest hunk of junk in this galaxy, and right now her hyperdrive is acting up again. I need a mechanic who will not ask questions about the "modifications" under the deck plating, and I need it done fast - I have got people who are not exactly patient looking for me.',
        FALSE, NULL, NULL
    UNION ALL
    SELECT 'Malcolm', 'Reynolds', 'mal.reynolds@serenity.verse', 'Serenity', 265.00, 'Billing',
        'I run a crew, not a charity, so before Serenity so much as clips a line to one of your slips I want to know exactly what this is gonna cost me, and whether you will take payment in platinum. I would also take it kindly if your paperwork did not find its way into any Alliance hands - a captain likes to keep his business his own.',
        FALSE, NULL, NULL
    UNION ALL
    SELECT 'Jean-Luc', 'Picard', 'jl.picard@starfleet.ufp', 'USS Enterprise (NCC-1701-D)', 2108.00, 'General Inquiry',
        'I am given to understand that your largest slip accommodates a vessel of some fifty feet. The Enterprise measures rather more than that - upward of two thousand, in point of fact - so before we make first contact with your marina in truth, I should like to know whether some manner of exception, or at minimum a very long dock, might be arranged.',
        TRUE, '2026-07-20 09:05:00',
        'Captain Picard - we are flattered by the inquiry, but must respectfully report that no slip in this marina, nor any marina we are aware of, could accommodate a vessel of that scale. We would, however, be delighted to have the Enterprise anchor offshore while the crew enjoys the Ship Store by shuttle.'
    UNION ALL
    SELECT 'Ahab', 'of the Pequod', 'ahab@pequodwhaling.com', 'Pequod', 104.00, 'Waitlist Question',
        'I am told your slips are all spoken for and that I must be content to wait. Wait I will not - not for a berth, and certainly not for the white whale I have hunted these many years across every ocean there is. Tell me plainly where I stand on your list, and do not test the patience of a man who has already given a leg to this pursuit.',
        FALSE, NULL, NULL
    UNION ALL
    SELECT 'Nemo', 'N/A', 'captain.nemo@nautilus.sea', 'Nautilus', 229.66, 'Other',
        'I have no nation, no name that matters, and no interest in the questions your paperwork tends to ask. I require a berth for the Nautilus, discretion regarding her comings and goings, and no undue curiosity about what lies beneath her waterline. I trust this is not an unreasonable arrangement for a man who owes nothing to the surface world.',
        TRUE, '2026-04-11 22:30:00',
        'Captain Nemo - we can offer a quiet, end-of-dock slip and can keep your registration details confidential per our standard privacy policy. We would ask, however, that the Nautilus surface for a standard hull inspection, same as any vessel.'
    UNION ALL
    SELECT 'James', 'Hook', 'james.hook@jollyroger.sea', 'Jolly Roger', 100.00, 'Other',
        'A most pressing concern, and one I do not raise lightly: is there, to your knowledge, a large crocodile in these waters? One with, shall we say, a rather punctual disposition and an old score to settle with my left hand? I require an honest answer before the Jolly Roger comes anywhere near your docks - a codfish such as myself cannot be too careful.',
        FALSE, NULL, NULL
    UNION ALL
    SELECT 'Odysseus', 'of Ithaca', 'odysseus@ithacashipping.gr', 'The Ithacan Galley', 100.00, 'Reservation Question',
        'I have been rather a long time at sea - longer, I confess, than I intended, and not for lack of trying to get home. I require a single night''s berth for my ship and crew, safe from any singing women on nearby rocks and any establishment offering suspiciously excellent hospitality. One night only; my wife is waiting.',
        TRUE, '2026-08-01 11:00:00',
        'Mr. of Ithaca - a one-night slip is reserved as requested. We can confirm there are no sirens native to this marina, though we cannot speak for the karaoke night at the dockside restaurant on Fridays. Safe travels home.'
    UNION ALL
    SELECT 'Noah', 'of the Ark', 'noah@thearkmarine.com', 'The Ark', 450.00, 'Other',
        'I am inquiring on behalf of a somewhat larger party than usual - two of every kind, to be precise, so I will need more than the standard amount of deck space and, frankly, a very serious answer on whether your slips can hold a vessel three hundred cubits long. Also, does your marina have a policy on livestock?',
        FALSE, NULL, NULL
) AS seedRows
WHERE NOT EXISTS (SELECT 1 FROM contact);

-- ---------------------------------------------------------------------------
-- Employee - staff accounts
-- ---------------------------------------------------------------------------
-- Placeholder dev data: 5 staff accounts. Passwords are the SHA1 hashes of
-- the plaintext 'AHAB1' through 'AHAB5' - a fast, unsalted hash used here
-- only as a local-dev placeholder, matching the 'captainAhab' theme of the
-- shared dev user above. Not suitable for production; swap for real
-- (salted, slow) password hashing once actual employee authentication is
-- implemented.
--
-- Hashed with SHA1() as literal values, not the SHA1() SQL function: this
-- MySQL build (9.6.0 Homebrew) errors on SHA1()/MD5() entirely
-- ("FUNCTION db.SHA1 does not exist" - confirmed with a bare
-- `SELECT SHA1('test')`, so it is not specific to this script), likely an
-- OpenSSL/FIPS restriction in how it was built. SHA2() still works, so this
-- appears to only affect the two legacy digests. Hashes below were
-- precomputed with `printf '%s' AHAB1 | shasum -a 1`.
INSERT IGNORE INTO employee (firstName, lastName, email, passwordHash, phone, role, hireDate) VALUES
    ('Maria', 'Alvarez', 'maria.alvarez@moffatbaymarina.com', '75b83b5f8301a44673ddacb0aab933cce6cd4d1a', '360-555-0101', 'Marina Manager', '2019-03-01'),
    ('Tom', 'Whitfield', 'tom.whitfield@moffatbaymarina.com', '8150dce58a4c75046f0f7b6c9bfa047aefd5825f', '360-555-0102', 'Dockmaster', '2020-06-15'),
    ('Priya', 'Nair', 'priya.nair@moffatbaymarina.com', '5581f9758ff000c517915a396941837f8a231974', '360-555-0103', 'Customer Service Rep', '2022-01-10'),
    ('Derek', 'Simmons', 'derek.simmons@moffatbaymarina.com', '63562e70d4a27bbbcda3a7627fdbaa0c06e2589c', '360-555-0104', 'Maintenance Technician', '2021-09-01'),
    ('Lena', 'Cho', 'lena.cho@moffatbaymarina.com', '93b0651d5db78917cb4d7f9d66b3c5dae1283c22', '360-555-0105', 'Billing Clerk', '2023-04-20');

-- =============================================================================
-- Section: White, S. - Seed Data TBD
-- =============================================================================
-- TODO (White, S.): add this section's INSERT statements here.

-- =============================================================================
-- Section: Fernandez, M. - Customer & Boat Seed Data
-- =============================================================================
-- NOTE (Fernandez, M.): this block must run BEFORE White, S. (BoatOwnership
-- has FKs into Boat) and BEFORE Rodriguez, C. (the Reservation seed hardcodes
-- customerId and boatId 1-3). If White, S.'s section above ends up with
-- inserts in it, these two sections need to swap places.
--
-- INSERT IGNORE plus the UNIQUE constraints on Customer.email and
-- Boat(regState, regNumber) make this safe to re-run - rows that already
-- exist are skipped rather than duplicated.
--
-- Placeholder dev data. passwordHash values are SHA-256 hashes of throwaway
-- plaintexts (Password1, Sailor22, Harbor33, Anchor44, Voyage55, Compass66),
-- precomputed as literals rather than calling SHA2() inline. Fast, unsalted,
-- local dev only - swap for real salted hashing when auth is built.

INSERT IGNORE INTO Customer
    (firstName, lastName, email, passwordHash, phone, streetAddress, city, state, zipCode, dateJoined)
VALUES
    ('Elena', 'Marsh', 'elena.marsh@example.com', '19513fdc9da4fb72a4a05eb66917548d3c90ff94d5419e1f2363eea89dfee1dd', '360-555-0201', '412 Harborview Dr', 'Moffat Bay', 'WA', '98110', '2025-03-14'),
    ('Desmond', 'Okafor', 'desmond.okafor@example.com', '79dbca7f9123dfe0a3fa9dc73f1bb2d15be4363f132670bd59dde0855399ae5d', '360-555-0202', '87 Tidewater Ln', 'Port Grayson', 'WA', '98221', '2025-06-02'),
    ('Yuki', 'Tanaka', 'yuki.tanaka@example.com', '9f823135be67747e31b1d0ef1126de84fad87acc965a2858de4194f18854894f', '360-555-0203', '1550 Anchorage Way', 'Moffat Bay', 'WA', '98110', '2025-09-19'),
    ('Rosa', 'Delgado', 'rosa.delgado@example.com', '6d1a72e73d6d9069b02d52e122975f56875599c9fa7163589cd1f134369f6de7', '360-555-0204', '23 Gull Point Rd', 'Sable Cove', 'OR', '97103', '2026-01-08'),
    ('Arthur', 'Penhale', 'arthur.penhale@example.com', '97bc5815a0ef8755209f00d17491c06776d378195e413b35d39b242a8ab19e65', '360-555-0205', '9 Old Pier St', 'Moffat Bay', 'WA', '98110', '2026-02-27'),
    ('Nadia', 'Brennan', 'nadia.brennan@example.com', '2318dad6a5fd33325059d18e9e2df1ed22fcd8cae3d30a6f69fa033f014194c2', '360-555-0206', '744 Saltgrass Ave', 'Port Grayson', 'WA', '98221', '2026-05-30');

-- Boats 1-3 are sized to the slips Rodriguez, C. reserved for them in the
-- Reservation seed: boatId 1 -> slip 8 (26 ft), boatId 2 -> slip 4 (40 ft),
-- boatId 3 -> slip 1 (50 ft). Every boat below is shorter than its slip.
--
-- boatId 6 (Wandering Albatross, 1968) is intentionally seeded with a NULL
-- hin to exercise the pre-1972 exemption case.
--
-- Intended ownership, for whoever writes the BoatOwnership rows: boats 1-3
-- belong to customers 1-3 respectively, boat 4 to customer 4, boats 5 and 6
-- both to customer 5 (one customer, two boats), leaving customer 6 with no
-- boat registered yet - a valid state, since a customer can join the wait
-- list before registering a vessel.
INSERT IGNORE INTO Boat
    (hin, boatName, regState, regNumber, boatType, boatLength, boatBeam, boatYear)
VALUES
    ('MFT412A3B404', 'Salt Whisper',       'WA', 'WN1204JT', 'Sailboat',  24.5,  8.2, 2014),
    ('BNT52C7D8188', 'Second Wind',        'WA', 'WN3391RK', 'Powerboat', 38.0, 13.5, 2019),
    ('CRS63E9F2224', 'Meridian',           'WA', 'WN0087PL', 'Catamaran', 47.5, 22.0, 2021),
    ('HLM74G1H6360', 'Gullwing',           'OR', 'OR5540BM', 'Sailboat',  31.0, 10.4, 2008),
    ('SBK85J3K0504', 'Little Bear',        'WA', 'WN7712DF', 'Powerboat', 22.0,  8.0, 2016),
    (NULL,           'Wandering Albatross','WA', 'WN0431XG', 'Sailboat',  36.0, 11.0, 1968);

-- =============================================================================
-- Section: Rodriguez, C. - Seed Data TBD
-- =============================================================================
-- TODO (Rodriguez, C.): add this section's INSERT statements here.

INSERT INTO Reservation
    (reservationId, confirmationNumber, customerId, boatId, slipId, startDate, monthlyRate)
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