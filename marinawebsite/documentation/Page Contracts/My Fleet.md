# Page Contract: My Fleet

## Page Name

My Fleet

## Module / Week

Module 9 / Week 7 (Sep 21 – Sep 27, 2026)

## Assigned

- Front End: Robert
- Back End: Carolina

## Current Status (2026-10-10)

**Built and tested, Front End and Back End.** Loading the fleet, adding a boat, editing an owned boat, and removing a boat (a soft ownership update) all work.

**Since 2026-10-09, My Fleet is where a new customer registers their first boat.** Registration no longer has boat fields; its **Create Account & Go to My Fleet** button creates the account and lands here (see the Registration contract). Book a Slip's Register a Boat panel is the only other place a boat can be added.

Four amendments were made to the version signed off on 2026-09-18. They're marked **Amended 2026-09-21** in place and listed together under [Amendments](#amendments).

Pieces this page reuses:

- `WEB-INF/includes/boatInfoCard.jsp` — the boat fields, shared with Book a Slip's Register a Boat panel. **Used unchanged** (see Amendment 2).
- `util/BoatValidator` — the one set of add-a-boat and edit-a-boat rules (see [Validation Rules](#validation-rules)).
- `BoatDAO.addOrReclaim()` — adds the boat and its ownership in one transaction, or reuses the row of a boat nobody owns now (#254).
- `WEB-INF/includes/statusPopup.jsp` / `MoffatBay.statusPopup` — the success toasts.
- `js/editTracker.js` — the touched-field tracking and old → new confirmation, shared with Your Account (#285). Each page only says how its fields differ (Your Account ignores case on email, state and country; My Fleet never counts a locked field as changed).
- `js/boatFields.js` — the shared client-side boat checks, also used by Book a Slip.

## Amendments

Four changes to the 2026-09-18 version. The first three are Front End mechanics; the fourth changes what a successful edit does and adds back-end work.

| # | What changed | Why |
| --- | --- | --- |
| 1 | Edit pre-fills from `data-*` attributes, not the card's `default*` params | `default*` resolves at server render; Edit opens client-side with no round trip |
| 2 | The `lockedFields` param on `boatInfoCard.jsp` is dropped | JS already fills the modal per boat, so it sets the locked state in the same pass; the shared card isn't touched at all |
| 3 | The status badge is **always** shown, not only when reserved | "What is this boat doing right now" is the question the page exists to answer, and a boat with no reservation is still an answer |
| 4 | A successful edit shows an old → new summary, not just a toast | The toast says something happened; the panel says what |

Amendment 4 was optional and **was not built**. A successful edit shows the plain "Boat updated" toast (`notice=boatUpdated`); the old → new list is shown before saving instead, in the confirmation step.

## What the Page Does

A signed-in customer lands on My Fleet and sees **one card per boat they currently own**. From there they can:

1. **See** every detail stored about each boat, plus its current status — reserved at a slip, or open to reserve.
2. **Edit** a boat — the same way Edit User Info edits the customer: only changed fields are sent, the customer confirms an old → new summary before saving, and any bad field aborts the whole save.
3. **Remove** a boat from their fleet, behind a confirmation step.
4. **Add** a new boat.
5. **Go straight to the relevant reservation page** — to the boat's existing reservation, or to book one with this boat already selected.

"Currently own" means a `BoatOwnership` row for this customer with `endDate IS NULL` — the same rule `BoatDAO.findByCustomerId()` already uses for the Reservation page's boat dropdown.

## Decisions Made / Open Questions

### Front End Owns

- [x] **Page layout.** One card per row by default at **70% of the content width, centred**, with the "Your Boats" rule pulled in to match — a full-width divider over inset cards reads as a bug. At **four or more boats** the list becomes two columns. On a phone it is always one per row. The threshold is a CSS choice, not a server one: the JSP renders one list and the stylesheet decides.
- [x] **Header and Add Boat button. Updated 2026-10-10.** The header reads "Your Boats" with a count badge beside it ("3 boats") once there is at least one boat. The **Add Boat** button (`#openAddBoat`) sits on its own line directly under that heading, centred, above the rule that closes the header. It's there whether or not the customer has boats, so there is one Add button on the page, not one for the empty state and another under the list. On a phone it stretches to full width.
- [x] **Card layout.** Each card shows every column in [Which Fields Are Editable](#which-fields-are-editable) except `boatID`, as a grid of **field badges** — three across on a full-width card, two across in the two-column layout and on a phone. Each grid column is a `max-content` track, so every badge in a column is exactly as wide as that column's longest value and no wider; `justify-content: space-around` spreads the columns. Values are centred inside their badge. Full details in [Visual Design](#visual-design).
- [x] **Blank values.** A blank optional value (`HIN`, `regNumber`, `boatType`, `boatBeam`, `boatYear`) **keeps its badge** but renders dashed and untinted with an em dash, rather than being hidden or filled. Missing reads as missing, so the customer can see what's absent and add it.
- [x] **Status badge. Amended 2026-09-21.** Always present, centred above the fields. Two states:

  | State | Badge |
  | --- | --- |
  | Active reservation | Ocean blue. "Reserved — Dock A, Slip 2 (A-02) · since Sep 11, 2026 · MB-00002" |
  | No Active reservation | Neutral grey. "Open to Reserve", plus a **Book a Slip →** link |

  The slip code (`A-02`) follows the convention in `documentation/definitions_decisions.md` under "Slip Naming" — composed in the JSP from `activeDockNumber` and `activeSlipNumber`, not stored. The long form is always spelled out alongside it.

  > The previous version of this bullet said a boat with no Active reservation "shows no badge (or a plain 'Not reserved' line)". That is superseded.

- [x] **Card actions.** Edit and Remove on every card. A reserved card also carries **View Reservation MB-00002 →**, linking to `/reservations?reservationNumber=MB-00002`. An unreserved card's **Book a Slip →** link carries `?boatId=` — see [Reservation Page Pre-select](#reservation-page-pre-select).
- [x] **Empty state.** A customer with no boats sees a card reading "You haven't registered any boats yet." instead of an empty grid, with the Add Boat button above it under the heading. Matches My Reservations' "You don't have any reservations yet."
- [x] **Add and Edit use the same form.** Both are one popup modal wrapping `WEB-INF/includes/boatInfoCard.jsp`, the same way the Reservation page's `#boatPanel` does. Add opens it blank.
- [x] **How Edit pre-fills. Amended 2026-09-21.** Edit fills the modal from **`data-*` attributes on the boat's card**, with `boatId` in a hidden field.

  > The previous version said Edit pre-fills "through the card's `default*` params". It can't: `default*` are `jsp:param` values resolved once at server render, and Edit opens client-side with no round trip. Rendering one modal per boat doesn't work either — `boatInfoCard.jsp` hardcodes `id="boatName"`, `id="hin"`, `id="boatLengthError"` and the rest, so N modals means N copies of every id.
  >
  > **`default*` is still used**, for the other path: the validation-failure forward, where the server re-renders with `openForm` and the customer's typed values have to come back. Two mechanisms, two genuinely different situations.

- [x] **Locked fields in Edit. Amended 2026-09-21.** `boatLength` and (once set) `HIN` render with the HTML **`disabled`** attribute, set by JS in the same pass that fills the modal. `WEB-INF/includes/boatInfoCard.jsp` is **not modified**.

  > The previous version said Front End would add a `lockedFields` param to the shared card. Dropped: JS is already populating the modal per boat, so the param buys nothing and would touch a card that Registration and Reservation both render.
  >
  > `disabled` rather than `readonly` on purpose. `readonly` still allows focus and text selection; `disabled` greys the field, takes it out of the tab order, and — the point — **is never submitted**. Since a submitted `boatLength` on an edit is a structural rejection (below), this makes the markup enforce the rule instead of relying on JS to strip the field.
  >
  > No "Locked" badge on the field — the grey fill carries it, with a hint underneath explaining why. A HIN-less boat's live HIN field **does** get a "Set once" marker, because an empty editable field looks like any other optional field and nothing else says it locks after the first save.

- [x] **The card's Clear button.** `#clearBoatInfo` reads "Clear Boat Info" in Add mode and **"Revert Changes"** in Edit mode, where it re-fills every field from the card's stored values instead of blanking them. Clearing in Edit would blank `boatName`, which is a structural rejection with no user-facing message — a dead end.
- [x] **Edit confirmation step.** Same rule as Edit User Info: before submitting, the modal shows every changed field as "Field: old value → new value" and the customer confirms. Nothing is sent until they do. Rendered inside the modal, since the form already is.
- [x] **Remove confirmation step.** Clicking Remove opens a confirmation popup naming the boat ("Remove *Black Pearl* from your fleet?"), with an explicit confirm button and a cancel. Only the confirm button submits. **Labels (2026-10-06, #269):** **Keep Boat** (focused first) and a red **Yes, Remove It**, the same pattern as every destructive confirmation on the site.
- [x] **Remove on a reserved boat.** The Remove button renders disabled, with a hint beside it ("This boat can't be removed from your account while it's part of an active reservation." - **reworded 2026-09-24**; a started lease can no longer simply be cancelled, so the old "cancel it first" wording was wrong). The server enforces this regardless — see [Removing a Boat](#removing-a-boat).
- [x] **One shared client-side validator.** The HIN pattern, the country → `regNumber` format switch, the year check and the "HIN or Registration Number" rule live once, in **`js/boatFields.js`**, used by My Fleet and Book a Slip's Register a Boat panel: `hinIsValid(value)`, `regNumberIsValid(value, country)`, `boatYearIsValid(value)`, `identificationRule(hin, regNumber)`, `applyCountry(country)`. It is the front-end twin of `util/BoatValidator`, so the browser's rules and the server's can't drift apart. (Registration used it too until its boat fields moved here, 2026-10-09.)

### Back End Owns

- [x] **Customer identity comes from the session only.** `customerId` is always `sessionScope.customerId`, never a form field.
- [x] **Every edit and remove re-checks ownership.** `boatId` arrives from a hidden form field, so it is untrusted. Before touching a boat, the servlet loads it with `BoatDAO.findOwnedBoat(conn, customerId, boatId)`. If that returns `null` (not their boat, or not a boat), the request is rejected with no write — exactly the same outcome whether the boat belongs to someone else or doesn't exist.
- [x] **Partial update, validate-all-then-write.** Same two rules as Edit User Info: only touched fields are submitted, and if any one of them fails validation, nothing is written. See [Editing a Boat](#editing-a-boat).
- [x] **"Delete" is a soft remove, not a `DELETE`.** See [Removing a Boat](#removing-a-boat).
- [x] **One shared server-side validator.** My Fleet Add and Edit use `util/BoatValidator` for shared server-side boat validation. `BoatValidator` uses the normalized validation helpers in `Utils.java` so My Fleet follows the same boat rules used elsewhere in the application.
- [x] **Servlet URL mapping.** One URL per action, one servlet class each, following the `/reservation` + `/reservation/boat` and `/editProfile` + `/editProfile/password` pattern rather than an `action` parameter:

  | URL | Method | Servlet | Does |
  | --- | --- | --- | --- |
  | `/myFleet` | GET | `MyFleetServlet` | Loads the fleet, forwards to `myFleet.jsp` |
  | `/myFleet/add` | POST | `MyFleetAddServlet` | Adds a boat + ownership row |
  | `/myFleet/edit` | POST | `MyFleetEditServlet` | Updates changed fields on an owned boat |
  | `/myFleet/remove` | POST | `MyFleetRemoveServlet` | Ends ownership of an owned boat |

  **Back End implementation status (2026-09-24):**

- `MyFleetServlet` loads the signed-in customer's current fleet.
- `MyFleetAddServlet` adds a new `Boat` row and `BoatOwnership` row in one transaction.
- `MyFleetEditServlet` verifies ownership, validates only submitted editable fields, and calls `BoatDAO.updateBoat()`.
- `MyFleetRemoveServlet` verifies ownership and Active reservation status, then ends ownership with `BoatDAO.endOwnership()`.
- `customerId` comes from the session only.
- Remove is a soft remove; no `Boat` row is deleted.

  These are plain form POSTs that redirect — **not** the fetch/JSON shape `ReservationBoatServlet` uses. That page returns JSON because it has a dropdown to update in place; My Fleet just reloads.

- [x] **Success redirects, failure forwards.** Same shape as `EditProfileServlet`. A success redirects to `/myFleet?notice=boatAdded` / `boatUpdated` / `boatRemoved`, so a refresh can't resubmit; `statusPopup.js` turns the notice into a toast. A validation failure forwards back to `myFleet.jsp` with `fieldErrors`, `formError`, and `openForm` (`add` or `edit`, plus `editBoatId` and `postedFields`) so the page reopens the same modal with the customer's typed values still in it.
- [x] **Edit success handling.** The optional Amendment 4 post-save old → new summary was not implemented. A successful Edit redirects to `/myFleet?notice=boatUpdated` and the page shows the standard success toast. The old → new confirmation still happens before submit on the Front End.

---

### Which Fields Are Editable

Every column on the `Boat` table (`databasescripts/MoffatBayMarinaDB_V1-10-0.sql`), whether the customer can change it on this page, and why.

| Column | Editable? | Notes |
| --- | --- | --- |
| `boatID` | No | Primary key. Never rendered; travels only as the hidden `boatId` field, and re-checked against ownership on every submit. |
| `boatName` | Yes | Required, max 50. The schema itself notes the name "may change with ownership." |
| `HIN` | **Yes, once — while `NULL`** | The hull's permanent ID. **Resolved 2026-09-21:** a boat added with no HIN (allowed when it has a `regNumber`) **can** have one added later, but only while the stored value is `NULL`. Once saved it is locked for good. Without this, a boat registered with only a Registration Number could never get its HIN without phoning the Marina. Requires `BoatDAO.hinInUseByAnotherBoat()`. |
| `regNumber` | Yes | Registrations get renewed and re-issued (e.g. moving the boat to another state). Same format rules as Add, driven by the customer's `country`. `UNIQUE` — duplicate-checked on change, excluding this boat's own row. Can't be cleared while `HIN` is also `NULL` (the "HIN or Registration Number" rule). |
| `boatType` | Yes | Optional, max 30. Blank clears it to `NULL`. |
| `boatLength` | No | Drives slip size and the monthly rate. Changing it could leave an Active reservation in a slip the boat no longer fits, priced wrong. A customer who needs to correct it calls the Marina. Rendered `disabled` in Edit. |
| `boatBeam` | Yes | Optional, 1–999.9. Blank clears it to `NULL`. Nothing on the site uses beam for slip fit today; if that changes, revisit. |
| `boatYear` | Yes | Optional, four digits, 1800 – current year. Blank clears it to `NULL`. |

`BoatOwnership` columns (`startDate`, `endDate`) are never edited directly — `endDate` is set only by [Removing a Boat](#removing-a-boat).

---

### Visual Design

The mockup these were settled against: <https://claude.ai/artifact/RGQ1TbQnb6QyUt2cvvXDyS> (private; ask Robert for access).

Every colour derives from the six approved colours in `css/site.css` — no new palette entries. Each is named as a semantic variable there rather than inlined at the point of use, and the shared pieces (field badge, status pill, card title, card shell) live in `site.css` rather than `myFleet.css`, since other pages want them.

| Element | Treatment |
| --- | --- |
| Boat name | Georgia small caps (`font-variant: small-caps`), centred, 23px. Capitals full height, lowercase at x-height, so it reads as a title rather than a row label. |
| Card | `--color-bg-card` fill, `var(--radius-card)` corners, the same token every card on the site uses. Inner radii stay at 6–7px so nested corners read correctly. |
| Field badge | `var(--color-golden-hour)` border over a tint of the same (`color-mix(... 17%, var(--color-surface-neutral))`) — the one palette accent otherwise used only for hovers, so field badges never compete with the ocean-blue status badge. |
| Badge label | Warm brown, small caps, over a rule of the same colour at 30% running the badge's inner width. `color-mix(in srgb, var(--color-golden-hour) 45%, var(--color-charcoal-navy))` — 5.33:1 on the badge fill, 5.50:1 on the card. |
| Badge value | Deep marine `#0d3b4d`, semibold — the data outweighs its own heading. |
| Blank field | Same badge, dashed and untinted, em dash in muted grey. |
| Status badge | Ocean blue tint when reserved; neutral grey when open. |
| Buttons and links | Minimum 44px touch target everywhere, including on a phone. |

---

### Reservation Page Pre-select

The **Book a Slip →** link on an unreserved boat's status badge is `/reservation?boatId=NN`, and the Reservation page opens with that boat already selected in its `#boatId` dropdown. **Built:** `js/reservation.js` reads the query parameter on load and selects the boat if it's one of the customer's own; anything else is ignored. No servlet change.

The **View Reservation** link on a reserved boat needs nothing new: `/reservations?reservationNumber=...` already works.

---

### Editing a Boat

Same flow as Edit User Info's profile form, applied to one boat:

1. Customer clicks **Edit** on a card → the modal opens, filled from that card's `data-*` attributes, with `boatLength` (and `HIN`, if set) `disabled`. Save starts **disabled** with the hint "Nothing changed yet.", the same rule `editUserInfo.js` uses.
2. JavaScript tracks which fields the customer actually changed. Only those are submitted, plus `boatId`.
3. A touched **optional** field the customer blanked is submitted as an explicit empty value, meaning "clear it to `NULL`." A touched **required** field (`boatName`) arriving empty gets the normal field message, "Enter a name for the boat.", under Boat Name in the reopened modal (**changed 2026-09-30, #255**: it used to be rejected outright with a raw 400 page before `BoatValidator` could run).
4. Before submit, the modal shows the "Field: old → new" list; the customer confirms. Nothing is sent until they do.
5. Server: ownership check → reject any submitted key that isn't an editable column (`boatLength`, or `hin` when already set, is rejected the same way — never silently ignored) → validate every changed field and collect every failure → only if all pass, `BoatDAO.updateBoat()` in a transaction.
6. Success → redirect, and the page shows the "Boat updated" toast.

The `UPDATE` is built dynamically from the changed fields, and column names come from a fixed whitelist in `BoatDAO` — never from the submitted key text itself.

> The `disabled` attribute means the browser won't send `boatLength` or a locked `HIN` at all. The servlet still rejects them rather than dropping them silently: if one arrives, something is wrong.

### Removing a Boat

**A boat is never deleted from the `Boat` table.** `Reservation.boatID` is a foreign key to `Boat`, so a boat that has ever been reserved can't be deleted without breaking (or deleting) reservation history, and `BoatOwnership` exists specifically to record who owned what, when. Removing a boat means **ending the customer's ownership**:

```sql
UPDATE BoatOwnership SET endDate = CURRENT_DATE
WHERE boatID = ? AND customerID = ? AND endDate IS NULL;
```

The boat then drops off My Fleet and out of the Reservation page's dropdown (both only show `endDate IS NULL` rows), while every past reservation still points at a real boat.

**A boat with an Active reservation can't be removed.** The servlet re-checks this inside the transaction (not just trusting a disabled button) and refuses with "This boat can't be removed from your account while it's part of an active reservation", naming the slip. Otherwise the marina would have an Active slip reservation for a boat no one owns.

**Re-adding a removed boat (#254, 2026-10-01).** The removed boat keeps its row, so adding it again later reuses that row and its history. See the 2026-10-01 note under [Validation Rules](#validation-rules).

### Adding a Boat

Same fields and rules as Book a Slip's Register a Boat panel: `BoatValidator.validateAdd(...)` with `requireIdentifier = true`, then `BoatDAO.addOrReclaim()` in one transaction. The only difference is the response: this page redirects with `notice=boatAdded` instead of returning JSON, since there's no dropdown to update in place.

## Scaffold Include

```jsp
<jsp:include page="/WEB-INF/includes/header.jsp">
    <jsp:param name="activePage" value="myfleet" />
</jsp:include>

<!-- My Fleet page content -->

<jsp:include page="/WEB-INF/includes/footer.jsp" />
```

> My Fleet is reached from **My Fleet** in the header's Welcome menu (highlighted for `"myfleet"`), the **My Fleet** button on Your Account, and Registration's **Create Account & Go to My Fleet** button.

`country` must be passed into the boat card as a `jsp:param` from `sessionScope.customer.country`, the way `reservation.jsp` does — the card reads `param.country` to pick the Registration Number format, and on a validation-failure forward that parameter isn't in the request, so without it the format silently falls back to US.

## Front End Variables

Field names reuse `boatInfoCard.jsp`'s existing `name` attributes, so the card works unchanged.

| Field Name | Input Type | Required? | Format / Notes |
| --- | --- | --- | --- |
| `boatId` | hidden | Yes, Edit and Remove only | The boat being edited/removed. Never shown. |
| `boatName` | text | Yes on Add; only if changed on Edit | `maxlength="50"` |
| `boatType` | text | No | `maxlength="30"` |
| `boatLength` | number | Yes on Add; **not sent** on Edit | 1–999.9, step 0.1. `disabled` in Edit, so the browser omits it. |
| `boatBeam` | number | No | 1–999.9, step 0.1 |
| `hin` | text | HIN or `regNumber` on Add; on Edit, only while currently blank | `maxlength="12"`: 3 letters then 9 letters/digits. `disabled` in Edit once set. |
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
| `registered` | `String` | Query string (GET `/myFleet`) | `true` when Registration's **Create Account & Go to My Fleet** sent the customer here; the status popup says "Account created — welcome aboard" |

## Database Returns

**Implemented for My Fleet:**

- `BoatDAO.findFleetByCustomerId()`
- `BoatDAO.findOwnedBoat()`
- `BoatDAO.updateBoat()`
- `BoatDAO.regNumberInUseByAnotherBoat()`
- `BoatDAO.hinInUseByAnotherBoat()`
- `BoatDAO.endOwnership()`
- `BoatDAO.activeReservationLocation()`
- `BoatDAO.addOrReclaim()` (#254)

| Method / Query | Parameters In | Returns | Notes |
| --- | --- | --- | --- |
| *(new)* `BoatDAO.findFleetByCustomerId()` | `Connection`, `int customerId` | `List<Boat>`, **empty list** if none | Every `Boat` column for boats with an open `BoatOwnership` row, `LEFT JOIN`ed to that boat's Active `Reservation` → `Slip` → `Dock`. Ordered by `boatName`. Kept separate from `findByCustomerId()`, which the Reservation page relies on for its lighter three-column shape. |
| *(new)* `BoatDAO.findOwnedBoat()` | `Connection`, `int customerId`, `int boatId` | `Boat` or `null` | `null` when the boat isn't currently owned by this customer, or doesn't exist — callers treat both the same |
| *(new)* `BoatDAO.updateBoat()` | `Connection`, `int boatId`, `Map<String, String> changedFields` | `void`, throws `SQLException` (caller rolls back) | Key absent = untouched; key present + empty = set `NULL` (optional columns only). Column names from a fixed whitelist |
| *(new)* `BoatDAO.regNumberInUseByAnotherBoat()` | `Connection`, `String regNumber`, `int boatId` | `boolean` | Excludes this boat's own row |
| *(new)* `BoatDAO.hinInUseByAnotherBoat()` | `Connection`, `String hin`, `int boatId` | `boolean` | **Required** — the HIN-once decision above approved it |
| **(new)** `BoatDAO.endOwnership()` | `Connection`, `int boatId`, `int customerId` | `int` rows updated | `0` = nothing to end (not theirs / already removed) → reject |
| **(new)** `BoatDAO.activeReservationLocation()` | `Connection`, `int boatId` | `String` or `null` | Returns the Active reservation location, such as `Dock A, Slip 2 (A-02)`, for the Remove warning |
| `BoatDAO.addOrReclaim()` | `Connection`, `Boat`, `int customerId` | `int` `boatID` | Inserts the boat and its ownership, or, when the HIN or Registration Number belongs to a boat nobody owns now, updates that row and opens a new ownership. Replaced the separate `insertBoat()` + `insertOwnership()` calls on Add (#254) |

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
| `activeStartDateDisplay` | `String` | `activeStartDate` already formatted ("Sep 11, 2026"), since `fmt:formatDate` can't take a `LocalDate`. This is what the status badge prints |

The Reservation page never lets a boat hold two Active reservations, so one set of fields is enough. If the query ever finds two, it keeps the earliest `startDate`.

The slip code (`A-02`) is **composed in the JSP** from `activeDockNumber` and `activeSlipNumber` — there is no slip-code column and Back End doesn't return one.

## Validation Rules

- **Client-side (UX only, not trusted):** the same live checks `boatInfoCard.jsp` gets in Book a Slip's Register a Boat panel (required marks, HIN pattern, registration format by country, year digits, "HIN or Registration Number"), through the shared `js/boatFields.js`. Edit also tracks touched fields and builds the old → new confirmation list.
- **Server-side (source of truth):** `util/BoatValidator` — `validateAdd(...)` on Add, `validateEdit(...)` on Edit — the same rules Book a Slip's panel uses, but this page shows **every** failing field, not just the first. On Edit: ownership check first, then reject any non-editable key, then validate all changed fields, then write all or nothing. On Remove: ownership check, then Active-reservation check inside the transaction, then `endOwnership()`.
- **Updated 2026-10-01 (#253):** `BoatValidator.validateAdd(...)` is the one set of add-a-boat rules. My Fleet and Book a Slip both pass `requireIdentifier = true`. (Registration passed `false` until it stopped taking a boat, 2026-10-09.) The HIN and Registration Number messages now say what a valid one looks like ("HIN should be 12 characters…", "…e.g. WN1234 AB").
- **Re-adding a removed boat, added 2026-10-01 (#254):** removing a boat keeps its row, so a boat whose HIN or Registration Number is already on file is now handled by who owns it. If **nobody owns it now** (its owner removed it, or sold it), adding it **reuses the existing row**: `BoatDAO.addOrReclaim` updates the details and opens a new ownership, so the boat keeps one ID and its reservation history. If **this customer** already owns it: "That boat is already in your fleet." If **another customer** owns it: "This boat is registered to another account. Please contact the marina office." (never saying whose). A HIN and Registration Number that belong to two different boats, or a Registration Number whose boat on file has a different HIN, are refused with a call-the-office message. The same rules apply on Book a Slip and My Fleet, the two places a boat can be added. Edit still refuses any HIN or Registration Number another boat row uses.

## Error Handling

| Condition | Message Shown | Where Displayed |
| --- | --- | --- |
| One or more fields fail validation (Add or Edit) | Each failing field's own message, all at once; nothing saved | Inline under each field in the reopened modal |
| The boat is already in this customer's fleet | "That boat is already in your fleet." | Inline under the HIN or Registration Number field |
| Another customer currently owns the boat | "This boat is registered to another account. Please contact the marina office." | Inline under the field that matched |
| The HIN and Registration Number belong to two different boats | "That HIN and registration number belong to two different boats. Please contact the marina office." | Modal banner (`#boatSectionError`) |
| The Registration Number is on file with a different HIN | "That registration number belongs to another boat. Please contact the marina office." | Inline under Registration Number |
| The boat is on file but nobody owns it now (removed, or sold) | Not an error: the existing boat is reused, keeping its history (#254) | Saved normally, "Boat added" toast |
| Edit: `HIN` or `regNumber` already belongs to another boat | "That HIN is already in use." / "That boat registration is already in use." | Inline under the field |
| Neither HIN nor Registration Number | "Enter either a HIN or a Registration Number." | Modal banner (`#boatSectionError`) |
| Remove on a boat with an Active reservation | "This boat can't be removed from your account while it's part of an active reservation (Dock A, Slip 2 (A-02))." (**reworded 2026-09-24**) | Red banner above the fleet (`formError`); nothing written |
| Edit or Remove for a `boatId` this customer doesn't own (or that doesn't exist) | "That boat couldn't be found in your fleet." — same text either way | Red banner above the fleet (`formError`); nothing written |
| `boatId` missing or not a number | Not a user-facing message — the page never sends that | Standard 400 page; nothing written |
| Blank `boatName` submitted on Edit (JavaScript off, or a stale page) | "Enter a name for the boat." (**changed 2026-09-30, #255**; was a raw 400 page) | Inline under Boat Name in the reopened Edit modal |
| Non-editable field (`boatLength`, a set `HIN`) submitted on Edit | Not a user-facing message — a Front End bug or tampering. Rejected outright. | N/A |
| Add succeeds | "Boat added" | `MoffatBay.statusPopup` toast after redirect |
| Remove succeeds | "Boat removed from your fleet" | `MoffatBay.statusPopup` toast after redirect |
| Edit succeeds | "Boat updated" | `MoffatBay.statusPopup` toast after redirect |
| Database failure | Standard servlet error page | `error.jsp` |

## Login State Differences

| Item | Logged In | Logged Out |
| --- | --- | --- |
| `/myFleet` page | Shows the customer's own boats | Signed out, the page shows the shared sign-in panel (`WEB-INF/includes/signInPanel.jsp`, 401) in place of the fleet; an add, edit or remove after the session timed out redirects back to `/myFleet`, which shows the same panel. Signing in lands on My Fleet (**changed 2026-10-02, #257**; before that it went to the landing page with the sign-in box open, #299). `CustomerSession.showSignInPanel` / `sendToSignIn`, same as `EditProfileServlet`. |
| Add / Edit / Remove | Available, for the customer's own boats only | Not reachable. A POST (usually a session that timed out mid-edit) writes nothing and gets the same sign-in redirect back to My Fleet. |
| My Fleet in the Welcome menu, and the My Fleet button on Your Account | Shown | Not shown — the Welcome menu replaces Log In only when signed in, and Your Account itself requires sign-in |
| Book a Slip / View Reservation links | Shown on the relevant cards | Not reachable — the page itself requires sign-in |
