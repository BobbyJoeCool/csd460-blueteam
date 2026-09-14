# Legacy Build Scripts — Week 5 (Sep 7 – Sep 11, 2026)

These four files are how the database schema was actually built, one step at a
time, from the Week 4 consolidation through the Reservation page work. **They
are kept as the record of how the schema got to where it is. Don't run them to
stand up a database.**

To build the database, run the consolidated script two directories up:

```
mysql -u root -p < ../../MoffatBayMarinaDB_V1-7-0.sql
```

That single file produces the same schema these four produce in sequence (on
top of `MoffatBayMarinaDB_V1-4-0.sql` below), and it is the one that gets
maintained going forward.

## What's here

| File | What it did |
| --- | --- |
| `MoffatBayMarinaDB_V1-4-0.sql` | From-scratch build at 1.4.0 - the file that used to be the maintained one (see [`../Week4/README.md`](../Week4/README.md) for the five-step history folded into it). |
| `MoffatBayMarinaDB_V1-5-0_update.sql` | Adds the `Rate` table (per-foot slip rent and flat electric fee); repairs `Boat.regNumber` values doubled by the old V1-3-0 update (a no-op on a database built from V1-4-0.sql, whose seed data was already correct). |
| `MoffatBayMarinaDB_V1-6-0_update.sql` | `Reservation`: adds `electricalHookup`. |
| `MoffatBayMarinaDB_V1-7-0_update.sql` | Data-only: rewrites `Dock.dockDescription` as a three-line name/compass-label/landmark stat block. |

## Why the files were consolidated

Same reason as Week 4: a required run order is a chance to run scripts out of
order, skip one, or hand a teammate a half-migrated database. A single
from-scratch file has one way to be run. The step-by-step history stays here
for anyone who needs to see how a particular column or value came about.
