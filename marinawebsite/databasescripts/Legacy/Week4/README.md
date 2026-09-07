# Legacy Build Scripts — Week 4 (Aug 31 – Sep 6, 2026)

These five files are how the database schema was actually built, one step at a
time, during Module 5 / Week 4. **They are kept as the record of how the schema
got to where it is. Don't run them to stand up a database.**

To build the database, run the consolidated script one directory up:

```
mysql -u root -p < ../../MoffatBayMarinaDB_V1-4-0.sql
```

That single file produces the same schema these five produce in sequence, and it
is the one that gets maintained going forward.

## What's here

| File | What it did |
| --- | --- |
| `MoffatBayMarinaDB_V1-0-0.sql` | Original from-scratch build: all 11 tables plus seed data. |
| `MoffatBayMarinaDB_V1-1-0_update.sql` | `Customer`: `failedLoginAttempts`, `accountLocked`, `phoneCountryCode`, `streetAddress2`. |
| `MoffatBayMarinaDB_V1-2-0_update.sql` | `Customer`: `country`. |
| `MoffatBayMarinaDB_V1-3-0_update.sql` | `Boat`: dropped `regState`; `regNumber` nullable and unique on its own. |
| `MoffatBayMarinaDB_V1-4-0_update.sql` | `Reservation`: `reservationStatus`. |

## One known bug in V1-3-0 — read this if your database predates the consolidation

V1-3-0 folded the state prefix into the registration number with:

```sql
UPDATE Boat SET regNumber = CONCAT(regState, regNumber)
```

The problem is that every seeded `regNumber` **already carried its state prefix**
— `'WN1204JT'`, not `'1204JT'`. So the concat doubled it, turning `WN1204JT` into
`WAWN1204JT` and `OR5540BM` into `OROR5540BM`.

It isn't cosmetic. `RegisterServlet.REG_NUMBER_PATTERN` expects two letters, four
to seven digits, then two letters. Checked against all 60 seeded boats:

- **before** V1-3-0 ran: 60 of 60 matched
- **after** V1-3-0 ran: 0 of 60 matched

`MoffatBayMarinaDB_V1-4-0.sql` seeds the correct undoubled values, so a database
built fresh from it is already right and needs nothing done to it.

A database built the old way still has the doubled values. Rebuilding from the
consolidated script is the simplest fix. To repair in place instead, without
dropping anything:

```sql
USE MoffatBayMarinaDB;

-- Check first - this should list the doubled rows and nothing else.
SELECT boatID, boatName, regNumber
FROM Boat
WHERE regNumber REGEXP '^[A-Za-z]{4}';

-- Then repair: drop the duplicated 2-letter prefix.
UPDATE Boat
SET regNumber = SUBSTRING(regNumber, 3)
WHERE regNumber REGEXP '^[A-Za-z]{4}';
```

Only run the `UPDATE` if the `SELECT` returns the rows you expect. Any boat
registered through the site *after* V1-3-0 was applied already has a correct
single-prefix number and must not be touched — the `REGEXP '^[A-Za-z]{4}'` guard
is what keeps those out, since a correct number has exactly two leading letters
before its digits.

## Why the files were consolidated

Five scripts in a required order is five chances to run them out of order, skip
one, or hand a teammate a half-migrated database. A single from-scratch file has
one way to be run. The step-by-step history stays here for anyone who needs to
see how a particular column came about.
