# Page Contract: Look Up Reservation

## Page Name

Look Up Reservation

## Module / Week

Module 8 / Week 6 (Sep 14 – Sep 20, 2026)

## Assigned

- Front End: Sara
- Back End: Carolina

## Open Questions / Decisions Needed

### Front End Owns

- [ ] **Search field `name` attributes:** What does the user search by — confirmation number, email, or both? Agree on the exact form field `name` values.
- [ ] **Result Bean properties displayed:** What EL expressions does Front End use to render results? (e.g., `${reservation.confirmationId}`, `${reservation.startDate}`) Front End needs the full list from Back End.
- [ ] **Same-page or separate results:** Does the form and results display on the same JSP (toggling sections via request attributes), or does Front End build a separate results JSP?
- [ ] **Search form visibility by login state:** See [Guest Lookup vs. Logged-In Lookup](#guest-lookup-vs-logged-in-lookup) below. If logged-in users get an auto-populated list/dropdown instead of a search form, Front End needs two different views — "here are your reservations" with no form, and "enter your confirmation number and last name" with one — not a single form for everybody.

### Back End Owns

- [ ] **Authentication requirement:** Must the user be logged in? See [Guest Lookup vs. Logged-In Lookup](#guest-lookup-vs-logged-in-lookup) below — Sara and Carolina need to agree on whether logged-out lookup is allowed at all, and if so, what it requires that a logged-in lookup doesn't.
- [ ] **DAO method signature:** What's the lookup method? (e.g., `findReservationByConfirmation(String id)` returning a single Reservation, or `findReservationsByCustomer(int customerId)` returning a `List<Reservation>`?) Define parameters and return shape, including what "no match" returns (null, empty list). Likely two separate methods, one per login state — see below.
- [ ] **Single vs. multiple results:** Can the query return more than one reservation? If so, Back End returns a list; Front End needs to know the Bean properties for each row.
- [ ] **No-match attribute:** What request attribute name and message does Back End set when nothing is found?
- [ ] **Cancel/modify actions:** Is this page read-only, or can the user cancel a reservation? If actionable, that's an additional POST endpoint and DAO method to define.
- [ ] **Security:** If lookup is by confirmation number without login, can anyone view the reservation? Does Back End also require a matching email? See [Guest Lookup vs. Logged-In Lookup](#guest-lookup-vs-logged-in-lookup) below for the standard confirmation-number-plus-last-name pattern this would follow.
- [ ] **Servlet URL mapping:** What URL does the form POST to? What URL is the GET for the page itself?

---

### Guest Lookup vs. Logged-In Lookup

Should a reservation be reachable without being logged in at all, and if a logged-out lookup is allowed, should it ask for more than a logged-in lookup does? Sara and Carolina need to agree on this before the search form or the DAO method get built, since it changes both the Front End form fields and the Back End query signature.

The standard pattern across reservation/booking systems (airlines, cruise lines, hotel booking platforms) is a two-tier lookup. A logged-in user sees their own reservations automatically, no search form at all — typically a list or dropdown, since an account can have more than one active reservation. A logged-out user has to prove they own the reservation by supplying something only the booking party would know: the confirmation/reservation number is the primary identifier, but it's never accepted alone, since a bare confirmation number is too easy to guess or enumerate. It's paired with a second piece of identifying information the guest would also know — most commonly last name, sometimes email instead of or in addition to it — and the lookup returns exactly that one reservation, nothing else.

Applied here: a logged-in customer would get a list (or dropdown) of their own current reservations pulled by session `customerId`, no form needed — the same shape as how [Edit User Info](edit-user-info-contract.md) pre-populates from the session rather than asking the customer to look anything up. A logged-out visitor would get a search form asking for the confirmation number **and** last name (both required, not either/or — a bare confirmation number shouldn't be enough by itself), and the query would return only that single matching reservation, with no way to browse or list any others tied to the same name.

This is two different DAO methods, not one: `findReservationsByCustomer(int customerId)` for the logged-in case, and something like `findReservationByConfirmationAndLastName(String confirmationId, String lastName)` for the logged-out case — they don't share a signature, since one trusts the session and the other has to verify two pieces of submitted data.

## Scaffold Include

This page includes the shared header/footer and identifies itself for nav highlighting:

```jsp
<jsp:include page="/includes/header.jsp">
    <jsp:param name="activePage" value="lookup" />
</jsp:include>

<!-- Look Up Reservation page content -->

<jsp:include page="/includes/footer.jsp" />
```

> The `activePage` value `"lookup"` must match what the header checks. See the scaffold contract for the full reference table.

## Front End Variables

Every field or control the page's UI sends to the Back End (form fields, query-string params on a lookup page, etc.).

| Field Name | Input Type | Required? | Format / Notes |
| --- | --- | --- | --- |
| | | | |

## Back End Parameters

What the Back End reads for each Front End field, plus anything it pulls from elsewhere (session, query string) rather than the form itself.

| Parameter Name | Type | Source (form field / session / query string) | Notes |
| --- | --- | --- | --- |
| | | | |

## Database Returns

Every query or DAO method the Back End calls for this page, and its exact return shape — including what it returns on "no match" (null vs. empty object vs. exception).

| Method / Query | Parameters In | Returns | Notes |
| --- | --- | --- | --- |
| | | | |

## Validation Rules

- **Client-side (UX only, not trusted):**
- **Server-side (source of truth):**

## Error Handling

Every user-facing error condition this page can hit, and exactly what the user sees.

| Condition | Message Shown | Where Displayed |
| --- | --- | --- |
| | | |

## Login State Differences

| Item | Logged In | Logged Out |
| --- | --- | --- |
| Reservation lookup | Available to the signed-in user; standard pattern would be an auto-populated list/dropdown of their own reservations, no search form needed | Pending team decision — see [Guest Lookup vs. Logged-In Lookup](#guest-lookup-vs-logged-in-lookup) above. If allowed, standard pattern is a confirmation number + last name search form, one matching reservation returned, no browsing |
