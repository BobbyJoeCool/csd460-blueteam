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
