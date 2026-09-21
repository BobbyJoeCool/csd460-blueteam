# Legacy Build Scripts — Week 6 (Sep 14 – Sep 20, 2026)

These two files are how the database schema was actually built during Module 8
— the from-scratch file that was maintained at the time, plus the one update
that landed on top of it. **They are kept as the record of how the schema got
to where it is. Don't run them to stand up a database.**

To build the database, run the consolidated script two directories up:

```
mysql -u root -p < ../../MoffatBayMarinaDB_V1-8-0.sql
```

That single file produces the same schema and seed data these two produce in
sequence, and it is the one that gets maintained going forward.

## What's here

| File | What it did |
| --- | --- |
| `MoffatBayMarinaDB_V1-7-0.sql` | From-scratch build at 1.7.0 - the file that used to be the maintained one (see [`../Week5/README.md`](../Week5/README.md) for the four-step history folded into it). |
| `MoffatBayMarinaDB_V1-8-0_update.sql` | Data-only: resets every seeded `Employee` and `Customer` password to `Moffat<LastName><NN>!` so each one meets the site's password rules. 29 of the 59 seeded accounts previously failed those rules, so a tester signing in with a seed account was using a password the site would never let a real customer choose. |

## Why the files were consolidated

Same reason as Weeks 4 and 5: a required run order is a chance to run scripts
out of order, skip one, or hand a teammate a half-migrated database. A single
from-scratch file has one way to be run. The step-by-step history stays here
for anyone who needs to see how a particular column or value came about.

The 1.8.0 passwords are now seeded directly by the `INSERT` statements in the
consolidated file rather than being written by the original seed values and
then `UPDATE`-d afterwards, so a fresh build never briefly holds a
non-compliant password.

## Verifying the consolidation

The consolidated file was checked against this two-step path by building both
on a throwaway MySQL instance and diffing `mysqldump` output. Every table's
schema and every seed row match byte-for-byte.

The single intended difference is the `appliedDate` on the `DatabaseVersion`
row for 1.8.0: the update script writes `CURDATE()`, so it records whatever day
it happened to be run, while the consolidated file records the date the version
was actually authored (2026-09-17). That is the same convention the rest of the
lineage rows already follow — `CURDATE()` would claim every version in the
history happened today, which is untrue.
