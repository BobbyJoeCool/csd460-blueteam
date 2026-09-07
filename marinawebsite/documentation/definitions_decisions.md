# Definitions

This document spells out the commonly used "fake truths" about the Marina.  For example, hours, contact info, DOck and Slip information.

The purpose is to provide a source of truth to provide consistency across the entire website when working with multiple developers.
Rather than looking to a different page to see what it has, developers can look here and get the "real" fake data.

## Contact

| | |
| --- | --- |
| Address | 1400 Harbor Loop Road, Joviedsa Island, WA 98250 |
| Phone | (360) 555-0142 |
| Email | office@moffatbaymarina.com |
| VHF | Channel 16 |

## Hours

| Day | Hours |
| --- | --- |
| Monday - Friday | 6:00 am - 7:00 pm |
| Saturday | 6:00 am - 7:00 pm |
| Sunday | 7:00 am - 5:00 pm |
| Fuel dock | 7:00 am - dusk, daily |

## Dock and Slip Sizes

Source of truth: the client's marina map 
![[Source_Information/marina_a.png]]

| Size | Total | Per Dock | Slip numbers (per dock) |
| --- | --- | --- | --- |
| 26 ft | 30 | 10 | 8-12, 20-24 |
| 40 ft | 24 | 8 | 4-7, 16-19 |
| 50 ft | 18 | 6 | 1-3, 13-15 |

## Slip Pricing

Source of truth: the `Rate` table, added in `MoffatBayMarinaDB_V1-5-0_update.sql`.
These figures are listed here so everyone quotes the same numbers, but the
database is authoritative - if the two ever disagree, the table wins and this
section is out of date.

| What | Code in `Rate` | Amount |
| --- | --- | --- |
| Slip rent | `SLIP_PER_FOOT_MONTHLY` | $10.50 per foot of boat, per month |
| Electric hookup (optional) | `ELECTRIC_MONTHLY` | $10.50 per month, flat |

Both include the 5% increase applied this term; the previous $10.00 rate never
existed in the database.

Two things that are easy to get backwards:

- **Rent follows the BOAT's length, not the slip's size.** A 32 ft boat in a
  40 ft slip pays 32 x $10.50 = $336.00, not $420.00. Slip size decides whether
  the boat fits; boat length decides what it costs.
- **Electric is flat, not per foot.** $10.50 whether the boat is 20 ft or 50 ft.

Worked example - a 32.0 ft boat with electric: $336.00 + $10.50 = **$346.50/month**.

The arithmetic always lands on a whole number of cents, since boat lengths carry
one decimal place and one decimal place times $10.50 cannot produce a fraction
of a cent. There is no rounding rule to agree on.

**The 60 seeded reservations do not follow this.** They were priced at a flat
rate per slip size ($485 / $585 / $685) with no reference to boat length and no
electric fee, because they predate the pricing rule. Left as-is deliberately -
`Reservation.monthlyRate` records what each booking was actually sold at, so old
rows keeping old prices is correct behaviour, not a bug to fix.

## Password Hashing

Password hashing (for both `Employee` and `Customer` accounts) is done with SHA-256, computed in SQL via `SHA2(<plaintext>, 256)`. For example, `SHA2('Password1', 256)` enters the database as `19513fdc9da4fb72a4a05eb66917548d3c90ff94d5419e1f2363eea89dfee1dd`.

This means our program MUST use SHA-256 hashing (unsalted) in order to authenticate correctly.

## Enums

The database has no dedicated ENUM type support for lookup tables beyond `SlipSize`, so these three columns are defined as SQL `ENUM` instead. Listed here so every developer works from the same fixed value list rather than re-deriving it from the schema.

### Slip.slipStatus

| Value | Meaning |
| --- | --- |
| `operational` | Default. Slip is bookable. |
| `maintenance` | Slip is temporarily out of service for upkeep/repair. |
| `unavailable` | Slip is out of service for a reason other than maintenance. |

### Contact.reasonForContact

| Value |
| --- |
| `Reservation Question` |
| `Waitlist Question` |
| `Billing` |
| `Maintenance Issue` |
| `General Inquiry` |
| `Other` |

### Customer.country

Not a SQL `ENUM` (plain `VARCHAR(5)`, see `MoffatBayMarinaDB_V1-2-0_update.sql`), but application code enforces this fixed list the same way, so it's listed here too.

| Value | Meaning |
| --- | --- |
| `US` | United States. Default. |
| `CA` | Canada. Drives Boat Registration's Registration Province option list and number format, see the Registration contract's "Boat Fields" section. |
| `OTHER` | Anywhere else. Doesn't capture which country — only used to show the "call the Marina" badge above Boat Registration and disable that section's Registration State/Province field. |

### TerminationNotice.noticeStatus

| Value | Meaning |
| --- | --- |
| `Submitted` | Customer has submitted the 30-day termination notice. |
| `Pending` | Notice is under staff review. |
| `Approved` | Notice has been approved; `terminationDate` is set. |
| `Withdrawn` | Customer withdrew the notice before it took effect. |
| `Completed` | Lease has ended as scheduled. |

## Tag Line

Your Harbor Between Horizons
