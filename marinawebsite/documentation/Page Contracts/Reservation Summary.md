# Page Contract: Reservation Summary

## Page Name

Reservation Summary (Confirmation)

## Module / Week

Module 7 / Week 5 (Sep 7 – Sep 13, 2026)

## Assigned

- Front End: Carolina
- Back End: Miguel
- Testing: Robert

## Amended 2026-09-24: Confirmation Screen Only

This page is now **only** a confirmation screen, shown right after a reservation changes: booked (Reservation page), cancelled, given 30 days' notice, or that notice withdrawn (all three on My Reservations). It is no longer a page to browse to, and it no longer cancels anything. Changes are made on My Reservations; see that contract.

- **Access.** Whatever made the change calls `ReservationSummaryServlet.grantAccess()` (or `redirectTo()`, which grants and redirects), storing that one confirmation number in the session as `reservationSummaryAccess`. A GET for any other confirmation number redirects to `/reservations?reservationNumber=...`. The grant isn't used up on the first view, so a refresh still works; the next change replaces it, and signing in again starts a session without one.
- **What it shows.** The hero reads the reservation itself: cancelled → "Your Reservation Has Been Cancelled"; notice `Withdrawn` → "Your Lease Continues"; a notice open (`noticeOpen`) → "Your Lease End Date Is Set" with the last day; otherwise → "Your Slip Is Reserved".
- **No POST.** Cancelling moved to `POST /reservations/cancel` (`ReservationChangeServlet`), and only works before the lease starts. After that, `POST /reservations/notice` records a 30-day termination notice.
- **Manage section.** The Cancel button is gone; the page links to My Reservations instead.
- **Signed out.** The sign-in panel's button now returns to `/reservations`, since a fresh session has no grant to show a summary.

Sections below that describe direct access, the POST, or the Cancel button are **superseded** by this amendment and marked where they appear.

## Open Questions / Decisions Needed

### Front End Owns

- [x] **Reservation Bean properties displayed:** Full list in
  [What the Bean Carries](#what-the-bean-carries) below.
- [x] **Cost breakdown display:** Front End's choice — the bean supplies both
  the total and the itemised split. See the same section.

### Back End Owns

- [x] **How does this page receive the reservation data?** Decided — a
  **redirect** carrying the confirmation number, and this page looks the
  reservation up fresh from the database. The Reservation page already ships
  this way (`/reservationSummary?confirmation=MB-00061` — **not** `reservationSummary.jsp`,
  see the Reservation contract's "Handing over to the summary page" for that
  correction — going at the JSP directly would skip this servlet entirely),
  and it is the right call for
  a reason worth writing down: a forward would mean a browser refresh
  re-submits the booking and makes a second reservation. A redirect makes
  refresh a harmless re-read.

  It also means the page works when someone arrives at it later, from a
  bookmark or from Look Up Reservation next module, with no second code path.

- [x] **Request/session attribute names:** Decided.

  | Name | Where | What |
  | --- | --- | --- |
  | `confirmation` | query string | The confirmation number, e.g. `MB-00061` |
  | `reservation` | request attribute | A `ReservationDetails` bean, set on success |
  | `reservationSummaryError` | request attribute | A ready-to-display message, set instead of `reservation` when there is nothing to show |
  | `notice` | query string | `reservationCancelled` after a cancel, `terminationNoticeSubmitted` after a 30-day notice, `terminationNoticeWithdrawn` after withdrawing one, read by the shared status popup (**amended 2026-09-24**) |

  `reservation` and `reservationSummaryError` are never both set. The page shows one
  or the other.

- [x] **Is this page accessible directly by URL?** **Superseded 2026-09-24: no, only right after a change - see the amendment above.** Originally: yes. `GET
  /reservationSummary?confirmation=MB-00061` works at any time, not only
  straight after booking. Look Up Reservation will redirect here next module,
  so building it any other way would mean rewriting it in a week.

- [x] **Authentication check:** Yes, both of them.

  1. **Signed in.** No session, no reservation shown. The servlet forwards to
     the page rather than redirecting, so the page's own "Sign in to view your
     reservation" panel renders and the URL — confirmation number included —
     survives. `signInRedirectTo` is set as a request attribute for the sign-in
     button to hand the login modal, since the modal builds its own
     `redirectTo` from the request URI, which carries no query string.
  2. **Theirs.** The reservation's `customerID` is checked against
     `sessionScope.customerId` on every request. This is not optional:
     confirmation numbers run in sequence from MB-00001, so without it anyone
     could read a stranger's booking by editing the address bar. Robert raised
     this in the Reservation contract and he is right.

  Cancellation checks ownership **twice** — once to choose the message, and
  again inside the `UPDATE`'s `WHERE` clause so the database is what actually
  enforces it. Checking and then updating leaves a gap between the two where
  the answer could change.

- [x] **Missing/invalid reservation handling:** Decided — a missing
  confirmation number, one that matches nothing, and one that belongs to
  someone else all produce **the same** `reservationSummaryError` message and an HTTP
  404. Telling them apart would let someone map which confirmation numbers are
  real, which is the same reasoning the Login contract uses for its single
  generic failure message.

- [x] **Servlet URL mapping:** `/reservationSummary`, GET only (**amended 2026-09-24**; the POST moved to `/reservations/cancel`).

### Cancelling a Reservation

**Superseded 2026-09-24.** Cancelling moved to My Reservations (`POST /reservations/cancel`), and only a reservation whose lease hasn't started can be cancelled. The rules below still hold there. Originally: the Reservation contract put cancellation here, since this is the one place a
customer already has a reservation in front of them.

- **POST** to `/reservationSummary` with `action=cancel` and `confirmation`.
- Sets `reservationStatus` to `Cancelled` — the row is never deleted. The
  marina still needs to know the booking happened, and BR-16 keeps a
  reservation tied to the customer who made it.
- Only an `Active` reservation can be cancelled. Cancelling one twice does
  nothing the second time and says so.
- Redirects back to this page afterwards rather than forwarding, so the
  customer sees the cancelled state re-read from the database, and a refresh
  cannot re-submit the cancellation.

### What the Bean Carries

`ReservationDetails` is deliberately **flat** — every value is one property,
so each line on the page is one EL expression and nothing can be null two
levels down. A reservation row on its own is mostly IDs; the names behind them
live across four tables and the DAO joins them once.

| EL expression | Type | Notes |
| --- | --- | --- |
| `${reservation.confirmationNumber}` | String | e.g. `MB-00061` |
| `${reservation.startDate}` | java.util.Date | Lease start. A `java.util.Date` rather than `LocalDate` on purpose - JSTL's `<fmt:formatDate>` only accepts one, and `rs.getDate()` already returns a `java.sql.Date`, so nothing is converted |
| `${reservation.reservationStatus}` | String | `Active` / `Cancelled` / `Completed` |
| `${reservation.active}` | boolean | `reservationStatus` is `Active` |
| `${reservation.started}` | boolean | **Added 2026-09-24.** Start date is today or earlier |
| `${reservation.cancellable}` | boolean | **Added 2026-09-24.** Active and not started |
| `${reservation.noticeAllowed}` | boolean | **Added 2026-09-24.** Active, started, no notice open |
| `${reservation.noticeOpen}` | boolean | **Added 2026-09-24.** Notice status is `Submitted`, `Pending` or `Approved` |
| `${reservation.noticeStatus}` | String | **Added 2026-09-24.** From `TerminationNotice`; null if none |
| `${reservation.noticeDate}` / `${reservation.terminationDate}` | java.util.Date | **Added 2026-09-24.** When notice was given / the chosen last day |
| `${reservation.cancelled}` | boolean | Convenience for the cancelled styling |
| `${reservation.boatName}` | String | |
| `${reservation.boatType}` | String | Sailboat, powerboat and so on. May be null - optional at registration |
| `${reservation.boatLength}` | BigDecimal | Feet, one decimal |
| `${reservation.regNumber}` | String | May be null — boats can have a HIN instead |
| `${reservation.dockNumber}` | String | `A`, `B` or `C` |
| `${reservation.dockDescription}` | String | Where it sits in the marina |
| `${reservation.slipNumber}` | int | Within its dock |
| `${reservation.slipSizeFt}` | int | 26, 40 or 50 |
| `${reservation.monthlyRate}` | BigDecimal | The blended total the customer pays |
| `${reservation.electricalHookup}` | boolean | Whether electric is included. Named for the database column |
| `${reservation.electricMonthlyRate}` | BigDecimal | The electric fee, for itemising |
| `${reservation.baseMonthlyRate}` | BigDecimal | The total with electric taken back off |

- [x] **Cost breakdown display:** Both are available, so this is Front End's
  choice. `monthlyRate` alone is the total; `baseMonthlyRate` +
  `electricMonthlyRate` itemise it. The arithmetic is done in the bean, not the JSP — the page should never
  do maths it could get wrong.

**Money is `BigDecimal` here, not integer cents.** The Reservation page uses
cents because its JavaScript adds figures up live and JavaScript is bad at
decimal arithmetic. This page only displays a number the database already
worked out, so there is nothing to add up and no reason to convert twice.

## Scaffold Include

This page includes the shared header/footer and identifies itself for nav highlighting:

```jsp
<jsp:include page="/includes/header.jsp">
    <jsp:param name="activePage" value="reservation" />
</jsp:include>

<!-- Reservation Summary page content -->

<jsp:include page="/includes/footer.jsp" />
```

> The `activePage` value `"reservation"` must match what the header checks. See the scaffold contract for the full reference table.

## Front End Variables

**Amended 2026-09-24:** the page submits nothing; the table below is historical. Originally: the page displays a reservation; the only thing it submits is a cancellation.

| Field Name | Input Type | Required? | Format / Notes |
| --- | --- | --- | --- |
| `confirmation` | hidden | Yes | The confirmation number being cancelled |
| `action` | hidden | Yes | Fixed value `cancel` |

The Cancel control is a POST form, not a link — cancelling changes state, so it
must not sit on something a browser could follow on its own.

## Back End Parameters

What the Back End reads for each Front End field, plus anything it pulls from elsewhere (session, query string) rather than the form itself.

| Parameter Name | Type | Source | Notes |
| --- | --- | --- | --- |
| `confirmation` | text | Query string (GET) or form field (POST) | Which reservation to show or cancel |
| `action` | text | Form field (POST only) | Value `cancel` |
| `customerId` | int | HTTP session | Set by `LoginServlet`. Never read off the form — that would let anyone claim to be anyone |

## Database Returns

| Method / Query | Parameters In | Returns | Notes |
| --- | --- | --- | --- |
| `ReservationDAO.findDetailsByConfirmation` | `String confirmationNumber` | `ReservationDetails`, or `null` on no match | Joins Reservation to Boat, Slip, Dock, SlipSize and Rate. Deliberately does not filter by customer — the servlet checks ownership, so "no such reservation" and "not yours" stay separate outcomes in code even though they look identical to the user |
| `ReservationDAO.cancel` | `int reservationId, int customerId` | `boolean` — `true` if a row was cancelled | `customerId` is in the `WHERE` clause, so the database enforces ownership. `false` means not theirs, not there, or already cancelled |

## Validation Rules

- **Client-side (UX only, not trusted):** A confirm prompt before cancelling,
  since it can't be undone from the site. Front End's call.
- **Server-side (source of truth):**
  - A session is required. No `customerId`, no page.
  - The reservation must belong to the signed-in customer, checked on every
    GET and POST.
  - Only an `Active` reservation can be cancelled, enforced in the `UPDATE`'s
    `WHERE` clause rather than checked beforehand.
  - A missing, unknown or someone else's confirmation number all produce the
    same message.

## Error Handling

| Condition | Message Shown | Where Displayed |
| --- | --- | --- |
| No `confirmation` parameter | "We couldn't find that reservation. Check the confirmation number, or contact the marina office at (360) 555-0142." | On the page via `reservationSummaryError`; HTTP 404 |
| Confirmation number matches nothing | Same message | Same |
| Reservation belongs to another customer | Same message | Same — deliberately indistinguishable from the two above, so the page can't be used to discover which confirmation numbers exist |
| Not signed in | No message on this page | **Corrected** — this used to say "redirected to the landing page," which doesn't match what's built. `ReservationSummaryServlet` forwards (doesn't redirect) to this same page, HTTP 401, with `signInRedirectTo` set as a request attribute. `reservationSummary.jsp` renders its own "Sign in to view your reservation" panel and hands `signInRedirectTo` to the login modal, so the confirmation number in the URL survives and a successful sign-in lands right back here — a redirect to the landing page would have thrown that away |
| Cancel succeeded | "Reservation cancelled" | Shared status popup, via `?notice=reservationCancelled` |
| 30-day notice submitted | "30-day notice submitted" | Shared status popup, via `?notice=terminationNoticeSubmitted` |
| Confirmation number not the one just changed | No message | **Added 2026-09-24.** Redirect to My Reservations, filtered to that number |
| Database failure | Standard error page | `error.jsp`, per `web.xml` |

## Login State Differences

| Item | Logged In | Logged Out |
| --- | --- | --- |
| Reservation summary | Shown, if the reservation is theirs | **Corrected** — this page's own sign-in panel is shown (forward, not a redirect to the landing page), with the login modal opened from there; returns here after signing in |
| Someone else's reservation | Same "couldn't find that reservation" message as one that doesn't exist | n/a |
| Cancel button | **Removed 2026-09-24** - cancelling is on My Reservations | n/a |
