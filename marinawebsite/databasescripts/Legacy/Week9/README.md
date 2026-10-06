# Legacy Build Scripts — Week 9 (Oct 5 – Oct 11, 2026)

These two files are how the database actually got to 1.10.0: the from-scratch file that was maintained until then, plus the one update that landed on top of it. **They are kept as the record of how the schema got to where it is. Don't run them to stand up a database.**

To build the database, run the consolidated script two directories up:

```
mysql -u root -p < ../../MoffatBayMarinaDB_V1-10-0.sql
```

That single file produces the same schema and seed data these two produce in sequence, and it is the one that gets maintained going forward.

**Already have a 1.9.0 database you want to keep?** Run `MoffatBayMarinaDB_V1-10-0_update.sql` from this folder instead. It changes the database in place and keeps your data.

## What's here

| File | What it did |
| --- | --- |
| `MoffatBayMarinaDB_V1-9-0.sql` | From-scratch build at 1.9.0 - the file that used to be the maintained one (see [`../Week7/README.md`](../Week7/README.md) for the two-step history folded into it). |
| `MoffatBayMarinaDB_V1-10-0_update.sql` | Adds `Contact.submittedAt`, the date and time each Contact Us message arrived (issue #326), so staff can see how long a message has waited and answer the oldest first. It defaults to the current time, so the site's insert needs no change. The ten seeded messages get dates before their replies. |

## Why the files were consolidated

Same reason as Weeks 4 to 7: a required run order is a chance to run scripts out of order, skip one, or hand a teammate a half-migrated database. A single from-scratch file has one way to be run.

The consolidated file sets the seeded messages' `submittedAt` in the `Contact` `INSERT` itself. The update script matches the same ten rows by email and `contactID`, so a message sent while testing keeps the time the script ran rather than being given a seed date.

## The one intended difference

As in Week 7, the `appliedDate` on the `DatabaseVersion` row for 1.10.0 differs: the update script writes `CURDATE()`, while the consolidated file records the date the version was authored (2026-10-06). Messages sent while testing on an updated database also carry the script's run time, which a fresh build has no rows to show.
