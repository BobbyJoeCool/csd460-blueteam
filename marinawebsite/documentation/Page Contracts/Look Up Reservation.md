# Page Contract: My Reservations (Look Up Reservation)

## Page Name

My Reservations. Originally planned as "Look Up Reservation", and the files still carry that name (`lookUpReservation.jsp`, `LookUpReservationServlet`, `css/lookUpReservation.css`); everything a visitor sees says My Reservations.

## Module / Week

Module 8 / Week 6 (Sep 14 – Sep 20, 2026)

## Assigned

- Front End: Sara
- Back End: Carolina

## Decisions Made

### Front End

- [x] Filter fields use `reservationNumber`, `year`, `month`, `status`, and `sort`, all in one form.
- [x] Results display on the same `lookUpReservation.jsp` page.
- [x] Results use the `reservations` request attribute.
- [x] My Reservations only appears in the navigation when the customer is signed in.
- [x] Results can be sorted newest or oldest.
- [x] The filter form shows the filters currently applied, and offers "Clear filters" whenever any are.
- [x] **Added 2026-09-24. Ending a reservation happens here.** What a card offers depends on whether its lease has started (`startDate` today or earlier):
  - **Not started, Active:** **Cancel Reservation** (red outline). Opens a confirmation popup naming the reservation; "Yes, Cancel It" posts to `/reservations/cancel`.
  - **Started, Active, no notice open:** **Submit 30-Day Notice**. Opens a popup asking for the lease's last day, a date picker limited to 30–365 days from today (BR-21); "Submit Notice" posts to `/reservations/notice`.
  - **Notice open, more than 14 days before its last day:** **Withdraw Notice** (**added 2026-09-24**, BR-23). Opens a popup naming the reservation and its last day; "Yes, Withdraw It" posts to `/reservations/withdraw`. The hint under the button gives the last day to withdraw. The 14 is `Utils.NOTICE_WITHDRAWAL_CUTOFF_DAYS`, and a notice with no last day recorded can always be withdrawn.
  - **Notice open, past that cutoff:** no button, just a hint that it can no longer be withdrawn and when the deadline was.
  - **Not Active:** no button. A card with any notice shows a **30-Day Notice** line with its status, plus the last day while the notice is still open.
- [x] **Added 2026-09-24.** There is no link to the Reservation Summary from here. The Summary is only the confirmation screen after a booking, cancellation or notice.
- [x] **Added 2026-09-24.** Both popups use the shared `.modal` component (`site.css`) and `js/modal.js` for open/close; the buttons use the shared `.btn-outline` / `.btn-action` with the `.btn-danger` modifier.

### Back End

- [x] Customer must be signed in.
- [x] The servlet uses the session `customerId`.
- [x] Customers can only retrieve their own reservations.
- [x] The DAO returns a `List<ReservationDetails>`.
- [x] No match returns an empty list.
- [x] The page itself only reads. **Amended 2026-09-24:** its two popups post to `ReservationChangeServlet` (`/reservations/cancel`, `/reservations/notice`), which checks sign-in and ownership, and the DAO enforces the rules inside the write: cancel only if Active and not started; notice only if Active, started, and no open notice (a `Withdrawn` notice row is reused, since `TerminationNotice.reservationID` is UNIQUE). Success redirects to the Reservation Summary as confirmation. A refusal redirects back here with a one-time `actionError` banner.
- [x] **Added 2026-09-24.** `/reservations/withdraw` sets the notice to `Withdrawn` in one UPDATE whose WHERE clause checks everything: the customer's, Active, notice Submitted/Pending/Approved, and last day on or after today + `NOTICE_WITHDRAWAL_CUTOFF_DAYS` (or no last day). Success lands on the Summary ("Your Lease Continues"); a refusal comes back here with the reason.
- [x] **Added 2026-09-24.** The notice's last day is validated by `Utils.isValidTerminationDate` (30–365 days out). The servlet also hands the page `earliestTerminationDate` / `latestTerminationDate`, so the date picker's range comes from the same rule instead of a second copy in JavaScript.
- [x] Servlet mapping is `/reservations`.
- [x] Lookup uses `GET`.
- [x] Visiting the page with no filters lists all of the customer's reservations, newest first.
- [x] A filter value that isn't valid (e.g. `?month=13` typed into the URL) is ignored, never an error page.

---

## Login Requirement

My Reservations is only available to signed-in customers.

The servlet uses the `customerId` stored in the session to make sure customers can only retrieve reservations that belong to their own account.

Logged-out users are not allowed to search for reservations by confirmation number alone.

The navigation link for My Reservations is only displayed when a customer is signed in. A signed-out visitor who reaches `/reservations` anyway (bookmark, link, back button) gets a sign-in panel instead of the page, and returns to My Reservations after signing in.

## Scaffold Include

This page includes the shared header/footer and identifies itself for nav highlighting:

```jsp
<jsp:include page="/includes/header.jsp">
    <jsp:param name="activePage" value="lookup" />
</jsp:include>

<!-- My Reservations page content -->

<jsp:include page="/includes/footer.jsp" />
```

> The `activePage` value `"lookup"` must match what the header checks. `includes/header.jsp` highlights the My Reservations link for it. See the scaffold contract for the full reference table.

## Front End Variables

| Field Name | Input Type | Required? | Format / Notes |
| --- | --- | --- | --- |
| `reservationNumber` | Text | No | All or part of a confirmation number, e.g. `MB-00001` or `00001`. Letters, digits and hyphens only, up to 20 characters. |
| `year` | Select | No | Lists only the years the customer has reservations in, plus All Years |
| `month` | Select | No | 1–12, or All Months |
| `status` | Select | No | `Active`, `Cancelled`, or All Statuses |
| `sort` | Select | No | `newest` (default) or `oldest` |

## Back End Parameters

| Parameter Name | Type | Source | Notes |
| --- | --- | --- | --- |
| `customerId` | Integer | Session | Identifies the signed-in customer and limits results to that customer. Read with `Utils.signedInCustomerId`. |
| `reservationNumber` | String | Query string | Optional; partial match. Must match `^[A-Za-z0-9-]{1,20}$`, otherwise it's ignored and a message is shown |
| `year` | Integer | Query string | Optional; parsed with `Utils.parseIntInRange` (2000 to 5 years ahead). Invalid values are ignored |
| `month` | Integer | Query string | Optional; parsed with `Utils.parseIntInRange` (1–12). Invalid values are ignored |
| `status` | String | Query string | Optional; `Active` or `Cancelled`, anything else is ignored |
| `sort` | String | Query string | `oldest` sorts oldest first; anything else sorts newest first |

## Database Returns

| Method / Query | Parameters In | Returns | Notes |
| --- | --- | --- | --- |
| `findReservationsByCustomer(...)` | `int customerId`, `String reservationNumber`, `Integer year`, `Integer month`, `String status`, `boolean oldestFirst` | `List<ReservationDetails>` | Returns only reservations belonging to the signed-in customer. Returns an empty list if no match is found. `null` for any filter means "any". |
| `findReservationYears(customerId)` | `int customerId` | `List<Integer>` | The distinct start-date years the customer has reservations in, newest first. Feeds the Year filter. |

Both share `ReservationDAO`'s one `SELECT_DETAILS` query with `findDetailsByConfirmation`, so the three can't drift apart.

### ReservationDetails Fields Used by the JSP

The JSP displays the following values from each `ReservationDetails` object:

- `confirmationNumber`
- `reservationStatus` (shown as Lease Status)
- `startDate` (formatted `MMM d, yyyy`)
- `dockNumber` and `slipNumber`
- `slipSizeFt`
- `monthlyRate` (formatted as currency)
- `boatName` and `boatLength`
- `electricalHookup`

`guestName` is still on `ReservationDetails` but no longer shown: every reservation on this page belongs to the signed-in customer, so it repeated their own name on every card.

## Validation Rules

- **Client-side (UX only, not trusted):**
  - Every filter is optional.
  - Year, month, status and sort are dropdowns.
  - `js/lookUpReservation.js` checks the reservation number with `MoffatBay.form.isValidReservationSearch` before the form is sent.

- **Server-side (source of truth):**
  - A valid signed-in session with a `customerId` is required.
  - The `customerId` from the session is always included in the reservation query.
  - Customers cannot retrieve another customer's reservation.
  - Every filter is bound as a query parameter; none is built into the SQL text.
  - Sort defaults to newest first unless `oldest` is selected.

## Error Handling

| Condition | Message Shown | Where Displayed |
| --- | --- | --- |
| Customer has no reservations at all | `You don't have any reservations yet.` plus a Book a Slip button | Results area on `lookUpReservation.jsp` |
| Filters match nothing | `No reservations match these filters.` plus Clear filters | Results area on `lookUpReservation.jsp` |
| Reservation number has invalid characters | `Reservation numbers only contain letters, numbers and dashes, like MB-00001.` | Under the Reservation Number box (in the browser before sending, and from the server if it gets through) |
| Invalid year / month / status in the URL | None: the filter is ignored | — |
| Customer is not signed in | `Sign In to View Your Reservations` panel with a Sign In button (HTTP 401) | `lookUpReservation.jsp`, in place of the filters and results |
| Database lookup fails | Request fails with a servlet error | Server-side error handling (same as Reservation Summary) |

## Login State Differences

| Item | Logged In | Logged Out |
| --- | --- | --- |
| My Reservations nav link | Displayed | Hidden |
| Reservation lookup | Available | Not available; a sign-in panel is shown instead |
| Customer identification | Uses session `customerId` | No lookup allowed |
| Reservation results | Only reservations belonging to the signed-in customer | None |
