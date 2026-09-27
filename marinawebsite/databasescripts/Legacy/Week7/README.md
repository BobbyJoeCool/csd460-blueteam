# Legacy Build Scripts — Week 7 (Sep 21 – Sep 27, 2026)

These two files are how the database was actually built during Module 9: the from-scratch file that was maintained at the time, plus the one update that landed on top of it. **They are kept as the record of how the schema got to where it is. Don't run them to stand up a database.**

To build the database, run the consolidated script two directories up:

```
mysql -u root -p < ../../MoffatBayMarinaDB_V1-9-0.sql
```

That single file produces the same schema and seed data these two produce in sequence, and it is the one that gets maintained going forward.

## What's here

| File | What it did |
| --- | --- |
| `MoffatBayMarinaDB_V1-8-0.sql` | From-scratch build at 1.8.0 - the file that used to be the maintained one (see [`../Week6/README.md`](../Week6/README.md) for the two-step history folded into it). |
| `MoffatBayMarinaDB_V1-9-0_update.sql` | Data-only: adds three boats that are never reserved, so the My Fleet page's front-end tests have fleets to work with. On the 1.8.0 seed data every boat had an active reservation and no customer owned more than two, so the "Open to Reserve" badge, the Reserve a Slip link, an enabled Remove button, and the 4+ boat two-column layout could not be seen on a fresh build. Afterwards Desmond Okafor owns 2 boats (1 reserved) and Arthur Penhale owns 4 (2 reserved, and Morning Tide with its optional fields left blank). |

## Why the files were consolidated

Same reason as Weeks 4, 5 and 6: a required run order is a chance to run scripts out of order, skip one, or hand a teammate a half-migrated database. A single from-scratch file has one way to be run. The step-by-step history stays here for anyone who needs to see how a particular column or value came about.

The 1.9.0 boats are now seeded directly by the `Boat` and `BoatOwnership` `INSERT` statements in the consolidated file, as boats 61-63. The update script had to look customers up by email and boats by HIN, because a database that had been used for testing could already have extra boats; a fresh build has no such rows, so the consolidated file can use the IDs directly.

## Verifying the consolidation

The consolidated file was checked against this two-step path by building both on a throwaway MySQL instance and diffing `mysqldump` output. Every table's schema and every seed row match byte-for-byte, including the IDs the new boats and ownership rows receive.

The single intended difference is the `appliedDate` on the `DatabaseVersion` row for 1.9.0: the update script writes `CURDATE()`, so it records whatever day it happened to be run, while the consolidated file records the date the version was actually authored (2026-09-23). That is the same convention the rest of the lineage rows already follow.
