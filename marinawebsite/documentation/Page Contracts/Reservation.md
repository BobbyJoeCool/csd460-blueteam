# Page Contract: Reservation (Book a Slip)

## Page Name

Reservation (Book a Slip)

## Module / Week

Module 6 / Week 5 (Sep 7 – Sep 13, 2026)

## Assigned

- Front End: Robert
- Back End: Sara
- Testing: Carolina

## Open Questions / Decisions Needed

> **General rule:** any page that doesn't have real content yet should still exist as a JSP — use `includes/comingSoon.jsp` (pass `pageName` as a param) to create a stub page with the shared header/footer, so the link works instead of going nowhere.

### Front End Owns

- [ ] **Form field `name` attributes:** Agree on the exact `name` for every form field (e.g., `arrivalDate`, `departureDate`, `boatLength`). Front End owns these; Back End reads them verbatim.
- [ ] **Date input format:** What format do the date fields submit? (`yyyy-MM-dd`, `MM/dd/yyyy`?) Back End's parser must match exactly.
- [ ] **Slip selection UI:** If the user picks from a list of available slips, what `name` attribute carries the selected slip ID?

### Back End Owns

- [ ] **Authentication requirement:** Must the user be logged in? What session attribute provides the customer ID?
- [ ] **Boat length → slip size matching:** What DAO method does Back End call, and what does it return? (e.g., `findAvailableSlip(int boatLength, Date start, Date end)` returning a Slip Bean, a list, or null?)
- [ ] **Slip selection — auto-assign or user picks?** Does the system assign a slip automatically based on boat length, or does Back End return options for Front End to present? This determines whether there's a slip ID field in the form.
- [ ] **Pricing calculation:** Where does the rate come from, and does Back End return a price estimate before final submission? If so, what's the method signature and return shape?
- [ ] **Reservation Bean structure:** What properties does the Reservation Bean expose? (e.g., `reservationId`, `customerId`, `slipId`, `startDate`, `endDate`, `totalCost`) Define the full shape.
- [ ] **Success flow:** After a successful booking, does Back End forward to the Reservation Summary page or redirect? What request/session attributes carry the reservation data to the next page?
- [ ] **Error attributes:** What attribute names and messages does Back End set for each failure case (no availability, invalid dates, etc.) so Front End can display them?
- [ ] **Servlet URL mapping:** What URL does the reservation form POST to?

## Scaffold Include

This page includes the shared header/footer and identifies itself for nav highlighting:

```jsp
<jsp:include page="/includes/header.jsp">
    <jsp:param name="activePage" value="reservation" />
</jsp:include>

<!-- Reservation page content -->

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
| Book a slip | Opens the reservation page directly | Asks the user to sign in first |
