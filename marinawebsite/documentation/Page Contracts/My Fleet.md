# Page Contract: My Fleet

## Page Name

My Fleet

## Module / Week

Module 9 / Week 7 (Sep 21 – Sep 27, 2026)

## Assigned

- Front End: Robert
- Back End: Carolina

## Current Status (2026-09-18)

**Not started.** `myFleet.jsp` is the Coming Soon stub (`includes/comingSoon.jsp`). Nothing in this contract exists yet except the pieces it reuses:

- `includes/boatInfoCard.jsp` — the boat fields used on Registration and in the Reservation page's Register a Boat panel. Already supports pre-filling through its `default*` params, which is what the Edit form needs.
- `BoatDAO.insertBoat()` and `BoatDAO.insertOwnership()` — adding a boat is the same two inserts the Reservation page already does.
- `ReservationBoatServlet`'s validation rules — the rule set every add and edit on this page has to match (see [Validation Rules](#validation-rules)).
- `includes/statusPopup.jsp` / `MoffatBay.statusPopup` — the success toasts.

## What the Page Does

A signed-in customer lands on My Fleet and sees **one card per boat they currently own**. From there they can:

1. **See** every detail stored about each boat, plus whether it is **currently reserved at a slip** and where.
2. **Edit** a boat — the same way Edit User Info edits the customer: only changed fields are sent, the customer confirms an old → new summary before saving, and any bad field aborts the whole save.
3. **Remove** a boat from their fleet, behind a confirmation step.
4. **Add** a new boat.

"Currently own" means a `BoatOwnership` row for this customer with `endDate IS NULL` — the same rule `BoatDAO.findByCustomerId()` already uses for the Reservation page's boat dropdown.

## Decisions Made / Open Questions

### Front End Owns

- [ ] **Card layout.** Each card shows every column in [Which Fields Are Editable](#which-fields-are-editable) except `boatID`. A blank optional value (`HIN`, `regNumber`, `boatType`, `boatBeam`, `boatYear`) shows as "—" rather than being hidden, so the customer can see what's missing and add it.
- [ ] **Reservation badge on the card.** When the boat has an Active reservation, the card shows it, e.g. "Reserved — Dock A, Slip 12 · since Sep 11, 2026 · MB-00012". Recommend linking the confirmation number to Look Up Reservation (`/reservations?reservationNumber=MB-00012`). A boat with no Active reservation shows no badge (or a plain "Not reserved" line — Front End's call).
- [ ] **Empty state.** A customer with no boats sees a short message ("You haven't registered any boats yet.") and the Add a Boat button, not an empty grid.
- [x] **Add and Edit use the same form.** Both are one popup modal wrapping `includes/boatInfoCard.jsp`, the same way the Reservation page's `#boatPanel` does. Add opens it blank. Edit opens it pre-filled through the card's `default*` params, with `boatId` in a hidden field.
- [ ] **Locked fields in Edit.** `boatLength` and (once set) `HIN` render read-only in the Edit form. `boatInfoCard.jsp` has no switch for this today — Front End adds one (e.g. a `lockedFields` param) rather than forking the card.
- [x] **Edit confirmation step.** Same rule as Edit User Info: before submitting, the modal shows every changed field as "Field: old value → new value" and the customer confirms. Nothing is sent until they do.
- [x] **Remove confirmation step.** Clicking Remove opens a confirmation popup naming the boat ("Remove *Black Pearl* from your fleet?"), with an explicit confirm button and a cancel. Only the confirm button submits.
- [ ] **Remove on a reserved boat.** Recommend disabling the Remove button on a card that shows a reservation badge, with a hint ("Cancel this boat's reservation before removing it"). The server enforces this regardless — see [Removing a Boat](#removing-a-boat).

### Back End Owns

- [x] **Customer identity comes from the session only.** `customerId` is always `sessionScope.customerId`, never a form field.
- [x] **Every edit and remove re-checks ownership.** `boatId` arrives from a hidden form field, so it is untrusted. Before touching a boat, the servlet loads it with `BoatDAO.findOwnedBoat(conn, customerId, boatId)`. If that returns `null` (not their boat, or not a boat), the request is rejected with no write — exactly the same outcome whether the boat belongs to someone else or doesn't exist.
- [x] **Partial update, validate-all-then-write.** Same two rules as Edit User Info: only touched fields are submitted, and if any one of them fails validation, nothing is written. See [Editing a Boat](#editing-a-boat).
- [x] **"Delete" is a soft remove, not a `DELETE`.** See [Removing a Boat](#removing-a-boat).
- [ ] **One shared validator.** Add and Edit on this page must enforce exactly what `ReservationBoatServlet.validate()` enforces today. Recommend moving those rules into one shared class (e.g. `util/BoatValidator`) that returns every failing field as `Map<String, String>`, with `ReservationBoatServlet` showing just the first message as it does now. Two copies of the rules will drift.
- [x] **Servlet URL mapping.** One URL per action, one servlet class each, following the `/reservation` + `/reservation/boat` and `/editProfile` + `/editProfile/password` pattern rather than an `action` parameter:

  | URL | Method | Servlet | Does |
  | --- | --- | --- | --- |
  | `/myFleet` | GET | `MyFleetServlet` | Loads the fleet, forwards to `myFleet.jsp` |
  | `/myFleet/add` | POST | `MyFleetAddServlet` | Adds a boat + ownership row |
  | `/myFleet/edit` | POST | `MyFleetEditServlet` | Updates changed fields on an owned boat |
  | `/myFleet/remove` | POST | `MyFleetRemoveServlet` | Ends ownership of an owned boat |

- [x] **Success redirects, failure forwards.** Same shape as `EditProfileServlet`. A success redirects to `/myFleet?notice=boatAdded` / `boatUpdated` / `boatRemoved`, so a refresh can't resubmit; `statusPopup.js` turns the notice into a toast ("Boat added", "Boat updated", "Boat removed from your fleet"). A validation failure forwards back to `myFleet.jsp` with `fieldErrors`, `formError`, and `openForm` (`add` or `edit`, plus `editBoatId`) so the page reopens the same modal with the customer's typed values still in it.

---

### Which Fields Are Editable

Every column on the `Boat` table (`databasescripts/MoffatBayMarinaDB_V1-7-0.sql`), whether the customer can change it on this page, and why. **Needs the team's sign-off.**

| Column | Editable? | Notes |
| --- | --- | --- |
| `boatID` | No | Primary key. Never rendered; travels only as the hidden `boatId` field, and re-checked against ownership on every submit. |
| `boatName` | Yes | Required, max 50. The schema itself notes the name "may change with ownership." |
| `HIN` | No, once set | The hull's permanent ID — it doesn't change for the life of the boat. **Open question:** if a boat was added with no HIN (allowed when it has a `regNumber`), can the customer add one later? Recommend yes, once: editable only while the stored value is `NULL`, then locked. |
| `regNumber` | Yes | Registrations get renewed and re-issued (e.g. moving the boat to another state). Same format rules as Add, driven by the customer's `country`. `UNIQUE` — duplicate-checked on change, excluding this boat's own row. Can't be cleared while `HIN` is also `NULL` (the "HIN or Registration Number" rule). |
| `boatType` | Yes | Optional, max 30. Blank clears it to `NULL`. |
| `boatLength` | No | Drives slip size and the monthly rate. Changing it could leave an Active reservation in a slip the boat no longer fits, priced wrong. A customer who needs to correct it calls the Marina. Shown read-only in Edit. |
| `boatBeam` | Yes | Optional, 1–999.9. Blank clears it to `NULL`. Nothing on the site uses beam for slip fit today; if that changes, revisit. |
| `boatYear` | Yes | Optional, four digits, 1800 – current year. Blank clears it to `NULL`. |

`BoatOwnership` columns (`startDate`, `endDate`) are never edited directly — `endDate` is set only by [Removing a Boat](#removing-a-boat).

---

### Editing a Boat

Same flow as Edit User Info's profile form, applied to one boat:

1. Customer clicks **Edit** on a card → the modal opens pre-filled from that boat, `boatLength` (and `HIN`, if set) read-only.
2. JavaScript tracks which fields the customer actually changed. Only those are submitted, plus `boatId`.
3. A touched **optional** field the customer blanked is submitted as an explicit empty value, meaning "clear it to `NULL`." A touched **required** field (`boatName`) arriving empty is rejected outright as a structural error, not a normal field message.
4. Before submit, the modal shows the "Field: old → new" list; the customer confirms.
5. Server: ownership check → reject any submitted key that isn't an editable column (`boatLength`, or `hin` when already set, is rejected the same way — never silently ignored) → validate every changed field and collect every failure → only if all pass, `BoatDAO.updateBoat()` in a transaction.
6. Success → redirect with `notice=boatUpdated`.

The `UPDATE` is built dynamically from the changed fields, and column names come from a fixed whitelist in `BoatDAO` — never from the submitted key text itself.

### Removing a Boat

**A boat is never deleted from the `Boat` table.** `Reservation.boatID` is a foreign key to `Boat`, so a boat that has ever been reserved can't be deleted without breaking (or deleting) reservation history, and `BoatOwnership` exists specifically to record who owned what, when. Removing a boat means **ending the customer's ownership**:

```sql
UPDATE BoatOwnership SET endDate = CURRENT_DATE
WHERE boatID = ? AND customerID = ? AND endDate IS NULL;
```

The boat then drops off My Fleet and out of the Reservation page's dropdown (both only show `endDate IS NULL` rows), while every past reservation still points at a real boat.

**A boat with an Active reservation can't be removed.** The servlet re-checks this inside the transaction (not just trusting a disabled button) and rejects with a message pointing the customer to cancel the reservation first. Otherwise the marina would have an Active slip reservation for a boat no one owns.

**Open question — re-adding a removed boat.** `HIN` and `regNumber` stay `UNIQUE` on the `Boat` row after removal, so adding the same boat again later fails with "That HIN or boat registration is already in use." Options: (a) accept that for now — the customer calls the Marina; (b) on Add, if the HIN/registration matches a boat with **no current owner**, re-link it with a new `BoatOwnership` row instead of inserting. (b) is also the start of the "trading/selling a boat" flow `Edit User Profile.md` mentioned for this page. **Recommend (a) for this module** and treating trade/sell as out of scope unless the team wants it.

### Adding a Boat

Same fields, rules and two inserts as the Reservation page's Register a Boat panel (`insertBoat()` then `insertOwnership()`, one transaction, duplicate `HIN`/`regNumber` → friendly message). The only difference is the response: this page redirects with `notice=boatAdded` instead of returning JSON, since there's no dropdown to update in place.

## Scaffold Include

```jsp
<jsp:include page="/includes/header.jsp">
    <jsp:param name="activePage" value="myfleet" />
</jsp:include>

<!-- My Fleet page content -->

<jsp:include page="/includes/footer.jsp" />
```

> My Fleet isn't a header nav link — it's reached from the **My Fleet** button on Edit User Info. `"myfleet"` is reserved here in case it becomes one; add it to the `activePage` table in `Shared HeaderFooter.md`.

## Front End Variables

Field names reuse `boatInfoCard.jsp`'s existing `name` attributes, so the card works unchanged.

| Field Name | Input Type | Required? | Format / Notes |
| --- | --- | --- | --- |
| `boatId` | hidden | Yes, Edit and Remove only | The boat being edited/removed. Never shown. |
| `boatName` | text | Yes on Add; only if changed on Edit | `maxlength="50"` |
| `boatType` | text | No | `maxlength="30"` |
| `boatLength` | number | Yes on Add; **not sent** on Edit | 1–999.9, step 0.1. Read-only in Edit. |
| `boatBeam` | number | No | 1–999.9, step 0.1 |
| `hin` | text | HIN or `regNumber` on Add; on Edit, only while currently blank | `maxlength="12"`: 3 letters then 9 letters/digits. Read-only in Edit once set. |
| `regNumber` | text | HIN or `regNumber` on Add; only if changed on Edit | `maxlength="20"`; format follows the customer's country (US `WN1234 AB`, CA `C1234 AB`, OTHER disabled) |
| `boatYear` | text (numeric) | No | Four digits |

## Back End Parameters

| Parameter Name | Type | Source | Notes |
| --- | --- | --- | --- |
| `customerId` | `int` | Session (`sessionScope.customerId`) | Never from the form |
| `customer.country` | `String` | Session (`sessionScope.customer`) | Picks the `regNumber` format rule, same as `ReservationBoatServlet` |
| `boatId` | `int` | Form field (Edit, Remove) | Untrusted — always passed through `findOwnedBoat()` first |
| `boatName` | `String` | Form field | Trimmed; required, ≤ 50 |
| `boatType` | `String` | Form field | Trimmed; ≤ 30; blank → `NULL` |
| `boatLength` | `BigDecimal` | Form field (Add only) | 1–999.9. Present on an Edit → request rejected |
| `boatBeam` | `BigDecimal` | Form field | 1–999.9; blank → `NULL` |
| `hin` | `String` | Form field | Uppercased; pattern `^[A-Za-z]{3}[A-Za-z0-9]{9}$`. On Edit, accepted only if the stored `HIN` is `NULL` |
| `regNumber` | `String` | Form field | Uppercased; country-specific pattern; duplicate-checked on change |
| `boatYear` | `Integer` | Form field | 1800 – current year; blank → `NULL` |
| `notice` | `String` | Query string (GET `/myFleet`) | `boatAdded` / `boatUpdated` / `boatRemoved` — drives the toast |

## Database Returns

| Method / Query | Parameters In | Returns | Notes |
| --- | --- | --- | --- |
| *(new)* `BoatDAO.findFleetByCustomerId()` | `Connection`, `int customerId` | `List<Boat>`, **empty list** if none | Every `Boat` column for boats with an open `BoatOwnership` row, `LEFT JOIN`ed to that boat's Active `Reservation` → `Slip` → `Dock`. Ordered by `boatName`. Kept separate from `findByCustomerId()`, which the Reservation page relies on for its lighter three-column shape. |
| *(new)* `BoatDAO.findOwnedBoat()` | `Connection`, `int customerId`, `int boatId` | `Boat` or `null` | `null` when the boat isn't currently owned by this customer, or doesn't exist — callers treat both the same |
| *(new)* `BoatDAO.updateBoat()` | `Connection`, `int boatId`, `Map<String, String> changedFields` | `void`, throws `SQLException` (caller rolls back) | Key absent = untouched; key present + empty = set `NULL` (optional columns only). Column names from a fixed whitelist |
| *(new)* `BoatDAO.regNumberInUseByAnotherBoat()` | `Connection`, `String regNumber`, `int boatId` | `boolean` | Excludes this boat's own row |
| *(new)* `BoatDAO.hinInUseByAnotherBoat()` | `Connection`, `String hin`, `int boatId` | `boolean` | Only needed if adding a HIN to a HIN-less boat is approved |
| *(new)* `BoatDAO.endOwnership()` | `Connection`, `int boatId`, `int customerId` | `int` rows updated | `0` = nothing to end (not theirs / already removed) → reject |
| `BoatDAO.insertBoat()` | `Connection`, `Boat` | `int` new `boatID` | Already exists |
| `BoatDAO.insertOwnership()` | `Connection`, `int boatId`, `int customerId` | `void` | Already exists |

### Boat Bean Properties Used by the JSP

Existing: `boatId`, `boatName`, `boatType`, `boatLength`, `boatBeam`, `boatYear`, `regNumber`, `hasActiveReservation`, and the HIN.

> **EL gotcha:** the getter is `getHIN()`, so in a JSP it's **`${boat.HIN}`**, not `${boat.hin}`. (The usage example in `boatInfoCard.jsp`'s header comment shows `${boat.hin}` — that would render blank. Fix the comment while you're in there.)

New, filled only by `findFleetByCustomerId()`, all `null` when the boat has no Active reservation:

| Property | Type | From |
| --- | --- | --- |
| `activeConfirmationNumber` | `String` | `Reservation.confirmationNumber` |
| `activeDockNumber` | `String` | `Dock.dockNumber` |
| `activeSlipNumber` | `Integer` | `Slip.slipNumber` |
| `activeStartDate` | `LocalDate` | `Reservation.startDate` |

The Reservation page never lets a boat hold two Active reservations, so one set of fields is enough. If the query ever finds two, it keeps the earliest `startDate`.

## Validation Rules

- **Client-side (UX only, not trusted):** Same live checks `boatInfoCard.jsp` already gets on Registration and the Reservation page (required marks, HIN pattern, registration format by country, year digits, "HIN or Registration Number"). Edit also tracks touched fields and builds the old → new confirmation list.
- **Server-side (source of truth):** Exactly `ReservationBoatServlet`'s rules, through the shared validator — but returning **every** failing field, not just the first. On Edit: ownership check first, then reject any non-editable key, then validate all changed fields, then write all or nothing. On Remove: ownership check, then Active-reservation check inside the transaction, then `endOwnership()`.

## Error Handling

| Condition | Message Shown | Where Displayed |
| --- | --- | --- |
| One or more fields fail validation (Add or Edit) | Each failing field's own message, all at once; nothing saved | Inline under each field in the reopened modal |
| `HIN` or `regNumber` already belongs to another boat | "That HIN or boat registration is already in use." | Inline under the field (or modal banner if it only surfaces at insert) |
| Neither HIN nor Registration Number | "Enter either a HIN or a Registration Number." | Modal banner (`#boatSectionError`) |
| Remove on a boat with an Active reservation | "This boat is reserved at Dock A, Slip 12. Cancel that reservation before removing the boat." | Status popup on `myFleet.jsp` |
| `boatId` missing, not a number, or not owned by this customer | "That boat couldn't be found in your fleet." — same text for every case | Status popup; nothing written |
| Non-editable field (`boatLength`, a set `HIN`) or blank `boatName` submitted on Edit | Not a user-facing message — a Front End bug or tampering. Rejected outright. | N/A |
| Add / Edit / Remove succeeds | "Boat added" / "Boat updated" / "Boat removed from your fleet" | `MoffatBay.statusPopup` toast after redirect |
| Database failure | Standard servlet error page | `error.jsp` |

## Login State Differences

| Item | Logged In | Logged Out |
| --- | --- | --- |
| `/myFleet` page | Shows the customer's own boats | Redirected to the landing page (`/`), same guard as `EditProfileServlet` |
| Add / Edit / Remove | Available, for the customer's own boats only | Not reachable; a direct POST is rejected with no write |
| My Fleet button (on Edit User Info) | Shown | Not reachable — Edit User Info itself requires sign-in |
