# Page Contract: Reservation Summary

## Page Name

Reservation Summary (Confirmation)

## Module / Week

Module 7 / Week 5 (Sep 7 – Sep 13, 2026)

## Assigned

- Front End: Carolina
- Back End: Miguel
- Testing: Robert

## Open Questions / Decisions Needed

### Front End Owns

- [ ] **Reservation Bean properties displayed:** Which exact EL expressions does Front End use? (e.g., `${reservation.confirmationId}`, `${reservation.startDate}`, `${reservation.totalCost}`) Front End needs the full list from Back End.
- [ ] **Cost breakdown display:** Does Front End show just a total or an itemized breakdown (rate × nights)? The Bean or forwarded attributes need to include whatever Front End will render.

### Back End Owns

- [ ] **How does this page receive the reservation data?** Is it a forward from the Reservation servlet (request attributes), a redirect with a reservation ID in the query string triggering a fresh DB lookup, or session-scoped data? This is the most critical handshake.
- [ ] **Request/session attribute names:** If forwarded, what exact attribute names carry the Reservation Bean or its fields? If query string, what parameter name holds the reservation ID?
- [ ] **Is this page accessible directly by URL?** Can a user revisit via `/reservationSummary?id=123`, or is it only reachable immediately after booking? If directly accessible, Back End needs a GET handler that queries by reservation ID.
- [ ] **Authentication check:** Does Back End verify the reservation belongs to the logged-in customer before displaying it?
- [ ] **Missing/invalid reservation handling:** What attribute name and error message does Back End set when the reservation context is missing or invalid?
- [ ] **Servlet URL mapping:** What URL maps to this page? (e.g., `/reservationSummary`)

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
| Reservation summary | Available to the signed-in user | Not reachable while logged out |
