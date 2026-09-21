# Page Contract: Wait List Lookup

## Page Name

Wait List Lookup

## Module / Week

Module 9 / Week 7 (Sep 21 – Sep 27, 2026)

## Assigned

- Front End:
- Back End:

## Current Status (2026-09-18)

**Not started.** `waitListLookup.jsp` is the Coming Soon stub. What already exists and this page builds on:

- `WaitList` table (`databasescripts/MoffatBayMarinaDB_V1-8-0.sql`): `waitListID`, `customerID`, `slipSizeID`, `timeJoined`, `timeClosed`, `status` (`Waiting` / `Offered` / `Fulfilled` / `Cancelled`).
- `TerminationNotice` table: `reservationID`, `noticeDate`, `terminationDate`, `noticeStatus` (`Submitted` / `Pending` / `Approved` / `Withdrawn` / `Completed`). Nothing on the site writes to it yet, but it is the only place the schema records **when a slip tenancy ends** — which is what the wait estimate needs.
- `WaitListDAO.isWaiting()` / `insert()` — joining happens on the Reservation page's "all slips full" prompt (`/reservation/waitlist`). This page doesn't change that.
- `ReservationDAO.countAvailableForSize()` — open slips right now, by size.

## What the Page Does

One page, two layers:

1. **Anyone (signed in or not)** sees, for each slip size (26 / 40 / 50 ft), **how many people are in line** and **roughly how long someone joining today would wait**. No names, no dates joined — counts only.
2. **A signed-in customer** also sees **their own place in line** for every slip size they're waiting on: position, how many people are ahead, when they joined, and their personal estimated wait.

## Decisions Made / Open Questions

### Front End Owns

- [x] **No search form.** The page loads everything on GET; a signed-in customer's entries come from the session, so there's nothing to type.
- [ ] **Public summary layout.** One card or table row per slip size: size, number in line, estimated wait for a new joiner. If that size has open slips right now, show "Slips available now" with a Book a Slip link instead of a wait estimate.
- [ ] **"Your place in line" section.** Shown only when signed in and only if the customer has at least one open entry. Signed in with no entries → a one-line "You're not on the wait list." Signed out → a "Sign in to see your place in line" prompt that opens the login modal.
- [x] **Estimates are labeled as estimates.** Every wait shown reads "about …" / "estimated", never as a promise. Use the pre-formatted `estimateLabel` from the Bean rather than doing any math in the JSP.
- [ ] **Leave the wait list button** on each of the customer's entries, behind a confirmation popup — only if Back End's open question below is a yes.

### Back End Owns

- [x] **Public page, private details.** `/waitList` does not require sign-in. The per-customer section is filled only from `sessionScope.customerId`; a customer can never see anyone else's entry, and the public data is aggregate counts only.
- [x] **Who counts as "in line."** Entries with status `Waiting` or `Offered`. `Offered` means that customer has been offered a slip and hasn't answered yet — they are still ahead of you. `Fulfilled` and `Cancelled` are closed and never count.
- [x] **Order of the line (BR-20).** By `timeJoined`, oldest first; `waitListID` breaks a tie. Your position = the number of in-line entries for the same slip size ahead of you + 1.
- [x] **The estimate is computed in one place.** A plain Java class, `util/WaitEstimator`, with no database access — the DAOs fetch the inputs, the servlet hands them to the estimator, and the estimator returns the number and the display label. Keeps the formula unit-testable and out of both the SQL and the JSP.
- [ ] **Default average tenure.** The formula needs to know how long a slip tenancy lasts on average. Until the database has enough finished tenancies to measure (it has none today), it falls back to a fixed value. **Proposed: 24 months**, as a named constant in `WaitEstimator`. The team (or the "marina") should confirm the number.
- [ ] **Leave the wait list.** Recommend yes: `POST /waitList/leave` sets that entry to `Cancelled` with `timeClosed = NOW()`, only if it belongs to the session customer and is still `Waiting`. BR-20 already excludes cancelled entries from average-wait math, so this doesn't distort anything.
- [ ] **Seed history for the estimate.** The seed data has no `Completed` termination notices, so every estimate will use the fallback. Optional V1-9-0 update: add a handful of past, completed tenancies (a reservation with an end, plus its `Completed` notice) so testers can see the measured path run.
- [x] **Servlet URL mapping.** `/waitList` (GET, `WaitListServlet`, forwards to `waitListLookup.jsp`) and, if approved, `/waitList/leave` (POST, `WaitListLeaveServlet`) — the same one-URL-per-servlet split as `/reservation` + `/reservation/waitlist`.

---

## The Wait Estimate

### The idea

A slip frees up when its tenant leaves. If a marina has **N** slips of your size and a tenant keeps a slip for **T** months on average, then on average about **N ÷ T slips of that size open up each month**. If there are **P** people in line up to and including you, you'll reach the front after about **P** openings. So:

> **Estimated wait (months) = P × T ÷ N**

Example: 24 slips of 40 ft, average tenancy 24 months → about **1 slip opens per month**. Third in line → about **3 months**.

### Using the openings we already know about (BR-24)

Some openings aren't guesses: a tenant who has filed a termination notice is leaving on a known date. BR-24 says a valid notice must be counted when predicting availability, and a withdrawn one must not. So before falling back to the average, the estimate uses those known dates first:

1. List the **known upcoming openings** for that slip size, soonest first — every `TerminationNotice` on a slip of that size whose reservation is still `Active` and whose status is:
   - `Approved` → opens on `terminationDate`.
   - `Submitted` or `Pending` → no date set yet, so assume the earliest date BR-21 allows: `noticeDate + 30 days`.
   - `Withdrawn` / `Completed` → ignored.
   - Any date already in the past counts as today.
2. Let **K** = how many known openings there are, and **P** = your position.
3. **If P ≤ K**, your wait ends on the **P-th known opening date**. Wait = that date − today.
4. **If P > K**, the known openings cover the first K people. The rest wait on the average rate, starting from the last known opening (or today, if K = 0):

> **Estimated wait (months) = months until the K-th known opening + (P − K) × T ÷ N**

### Where each input comes from

| Symbol | Meaning | Source |
| --- | --- | --- |
| **P** | Your position: in-line entries ahead of you for this slip size, + 1. For the public "if you joined today" figure, P = number in line + 1. | `WaitList` |
| **N** | Slips of this size with `slipStatus = 'operational'`. Slips in `maintenance` or `unavailable` don't turn over. | `Slip` + `SlipSize` |
| **T** | Average tenancy in months for this slip size (see below). | `TerminationNotice` + `Reservation` |
| **K** and the dates | Known upcoming openings (above). | `TerminationNotice` + `Reservation` + `Slip` |

**Average tenancy T**, from the most specific data that's sufficient:

1. **This slip size's history** — average of (`terminationDate` − `Reservation.startDate`) over `Completed` notices for this slip size, if there are **at least 5**.
2. **Whole-marina history** — the same average across all slip sizes, if there are at least 5 in total.
3. **Default** — the fixed fallback (proposed 24 months).

The Bean reports which one was used (`tenureSource`), so the page can footnote "based on marina history" vs "based on a typical tenancy" if Front End wants to.

Reservations cancelled through Reservation Summary are **not** tenancies (the customer never occupied the slip over time; there's no termination notice), so they're left out of T.

### Special cases

| Case | What's shown |
| --- | --- |
| Slips of that size are open right now (`countAvailableForSize() > 0`) | Public: "Slips available now" + Book a Slip link, no estimate. A customer still on that list sees their position and "a slip is open now — the marina will contact you." |
| N = 0 (every slip of that size is out of service) | "No estimate available right now." |
| Estimate under 1 month | "less than a month" |
| Estimate from the average | Round **up** to the nearest half month: "about 3 months", "about 3½ months". Over 24 months → "more than 2 years". |
| Estimate lands on a known opening (P ≤ K) | "around Oct 14, 2026" — the actual date, since it's known. |

### A sanity check (optional)

BR-20 notes that fulfilled entries let the marina track real wait times. Once there are some, the average of (`timeClosed` − `timeJoined`) over `Fulfilled` entries per size is a real-world check on the formula. Not shown on the page this module; worth a note in the test plan if seed history is added.

---

## Scaffold Include

```jsp
<jsp:include page="/includes/header.jsp">
    <jsp:param name="activePage" value="waitlist" />
</jsp:include>

<!-- Wait List Lookup page content -->

<jsp:include page="/includes/footer.jsp" />
```

> `Shared HeaderFooter.md`'s table currently lists Wait List Lookup as "none — not a nav link." Now that the page is public, the team should decide whether it becomes one; if so, add `waitlist` to that table and to `header.jsp`.

## Front End Variables

| Field Name | Input Type | Required? | Format / Notes |
| --- | --- | --- | --- |
| *(none on GET)* | | | The page takes no input; everything comes from the database and the session |
| `waitListId` | hidden | Yes, Leave only | The entry to leave. Only if Leave is approved |

## Back End Parameters

| Parameter Name | Type | Source | Notes |
| --- | --- | --- | --- |
| `customerId` | `Integer` | Session (`sessionScope.customerId`) | Optional on GET — absent means signed out, and only the public summary is built. Required on Leave |
| `waitListId` | `int` | Form field (Leave only) | Untrusted — only acted on if it belongs to the session customer and is still `Waiting` |
| `notice` | `String` | Query string | `leftWaitList` after a successful Leave, drives the `statusPopup` toast |

## Database Returns

| Method / Query | Parameters In | Returns | Notes |
| --- | --- | --- | --- |
| *(new)* `WaitListDAO.countInLineBySize()` | `Connection` | `Map<Integer, Integer>` (sizeFt → count) | Every slip size present, `0` when nobody's waiting (`SlipSize LEFT JOIN WaitList`). Counts `Waiting` + `Offered` |
| *(new)* `WaitListDAO.findOpenEntriesForCustomer()` | `Connection`, `int customerId` | `List<WaitListEntry>`, **empty list** if none | The customer's `Waiting`/`Offered` entries, each with `peopleAhead` computed in SQL (count of in-line entries for the same size with an earlier `timeJoined`, `waitListID` breaking ties) |
| *(new)* `WaitListDAO.leave()` | `Connection`, `int waitListId`, `int customerId` | `boolean` | `true` if one row changed. `false` = not theirs, not `Waiting`, or doesn't exist — all treated the same |
| *(new)* `ReservationDAO.countOperationalSlipsBySize()` | `Connection` | `Map<Integer, Integer>` (sizeFt → N) | `slipStatus = 'operational'` only |
| *(new)* `ReservationDAO.findTenureStats()` | `Connection` | `Map<Integer, TenureStats>` (sizeFt → average months + sample size) | From `Completed` termination notices joined to their reservations and slips. A size with no history is absent from the map. The estimator pools them for the whole-marina fallback |
| *(new)* `ReservationDAO.findUpcomingOpenings()` | `Connection` | `Map<Integer, List<LocalDate>>` (sizeFt → dates, soonest first) | Rules in [Using the openings we already know about](#using-the-openings-we-already-know-about-br-24). Empty list for a size with none |
| `ReservationDAO.countAvailableForSize()` | `Connection`, `int slipSizeFt` | `int` | Already exists |

### Beans Used by the JSP

**`WaitListSummary`** — one per slip size, request attribute `waitListSummaries` (`List<WaitListSummary>`, ordered 26 → 40 → 50):

| Property | Type | Notes |
| --- | --- | --- |
| `sizeFt` | `int` | 26 / 40 / 50 |
| `inLineCount` | `int` | `Waiting` + `Offered` |
| `availableNow` | `boolean` | Open slips of this size right now |
| `estimateLabel` | `String` | Ready to print, for someone joining today. `null` when `availableNow` |
| `tenureSource` | `String` | `size`, `marina` or `default` — which T was used |

**`WaitListEntry`** — the signed-in customer's own entries, request attribute `myWaitListEntries` (`List<WaitListEntry>`; not set when signed out):

| Property | Type | Notes |
| --- | --- | --- |
| `waitListId` | `int` | For the Leave button |
| `sizeFt` | `int` | |
| `status` | `String` | `Waiting` or `Offered` — an `Offered` entry should say "A slip has been offered to you" instead of an estimate |
| `timeJoined` | `LocalDateTime` | |
| `peopleAhead` | `int` | |
| `position` | `int` | `peopleAhead + 1` |
| `estimateLabel` | `String` | Same rules as the summary's |

**`util/WaitEstimator`** (no DB access): `estimate(int position, List<LocalDate> knownOpenings, int operationalSlips, double avgTenureMonths, LocalDate today)` → an `Estimate` with `months` (`double`), `openingDate` (`LocalDate`, set only when it landed on a known opening), and `label` (`String`).

## Validation Rules

- **Client-side (UX only, not trusted):** Nothing to validate on GET. Leave, if built, confirms in a popup before posting.
- **Server-side (source of truth):** The customer section is built only from the session `customerId`. Leave requires a session, and only changes a `Waiting` entry owned by that customer. The public section never includes customer IDs, names or join times — counts only.

## Error Handling

| Condition | Message Shown | Where Displayed |
| --- | --- | --- |
| Signed out | "Sign in to see your place in line." with a Sign In button (opens the login modal) | "Your place in line" section |
| Signed in, not on any list | "You're not on the wait list." | "Your place in line" section |
| All slips of a size out of service (N = 0) | "No estimate available right now." | That size's summary row |
| Leave succeeds | "You've left the wait list." | `statusPopup` toast after redirect |
| Leave fails (not theirs / already closed / bad id) | "That wait list entry couldn't be found." — same text every case | `statusPopup` toast |
| Database failure | Standard servlet error page | `error.jsp` |

## Login State Differences

| Item | Logged In | Logged Out |
| --- | --- | --- |
| Wait list counts per slip size | Shown | Shown |
| Estimated wait for a new joiner | Shown | Shown |
| Your position, people ahead, your estimate | Shown for each of your open entries | Replaced by a sign-in prompt |
| Leave the wait list | Available on your own `Waiting` entries (if approved) | Not available |
| Joining the wait list | On the Reservation page, when a size is full (unchanged) | Not available — Reservation requires sign-in |
