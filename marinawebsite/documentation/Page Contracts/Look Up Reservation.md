# Page Contract: Look Up Reservation

## Page Name

Look Up Reservation

## Module / Week

Module 8 / Week 6 (Sep 14 – Sep 20, 2026)

## Assigned

- Front End: Sara
- Back End: Carolina

## Decisions Made

### Front End

- [x] Search fields use `reservationNumber`, `year`, `month`, and `sort`.
- [x] Results display on the same `lookUpReservation.jsp` page.
- [x] Results use the `reservations` request attribute.
- [x] Look Up Reservation only appears in the navigation when the customer is signed in.
- [x] Results can be sorted newest or oldest.

### Back End

- [x] Customer must be signed in.
- [x] The servlet uses the session `customerId`.
- [x] Customers can only retrieve their own reservations.
- [x] The DAO returns a `List<ReservationDetails>`.
- [x] No match returns an empty list.
- [x] The page is read-only.
- [x] Servlet mapping is `/reservations`.
- [x] Lookup uses `GET`.

---

## Login Requirement

Look Up Reservation is only available to signed-in customers.

The servlet uses the `customerId` stored in the session to make sure customers can only retrieve reservations that belong to their own account.

Logged-out users are not allowed to search for reservations by confirmation number alone.

The navigation link for Look Up Reservation is only displayed when a customer is signed in.

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

| Field Name | Input Type | Required? | Format / Notes |
| --- | --- | --- | --- |
| `reservationNumber` | Text | No | Reservation confirmation number such as `MB-00001` |
| `year` | Select | No | Can be left as All Years |
| `month` | Select | No | Can be left as All Months |
| `sort` | Select | No | `newest` or `oldest` |

## Back End Parameters

| Parameter Name | Type | Source | Notes |
| --- | --- | --- | --- |
| `customerId` | Integer | Session | Identifies the signed-in customer and limits results to that customer |
| `reservationNumber` | String | Query string | Optional reservation number filter |
| `year` | String | Query string | Optional year filter |
| `month` | String | Query string | Optional month filter |
| `sort` | String | Query string | Controls newest or oldest ordering |

## Database Returns

| Method / Query | Parameters In | Returns | Notes |
| --- | --- | --- | --- |
| `findReservationsByCustomer(...)` | `customerId`, `reservationNumber`, `year`, `month`, `order` | `List<ReservationDetails>` | Returns only reservations belonging to the signed-in customer. Returns an empty list if no match is found. |

### ReservationDetails Fields Used by the JSP

The JSP displays the following values from each `ReservationDetails` object:

- `confirmationNumber`
- `guestName`
- `slipNumber`
- `startDate`
- `monthlyRate`
- `reservationStatus`
- `boatName`

## Validation Rules

- **Client-side (UX only, not trusted):**
  - Reservation number, year, and month are optional.
  - Year and month are selected from dropdown lists.

- **Server-side (source of truth):**
  - A valid signed-in session with a `customerId` is required.
  - The `customerId` from the session is always included in the reservation query.
  - Customers cannot retrieve another customer's reservation.
  - Sort defaults to newest first unless `oldest` is selected.

## Error Handling

## Error Handling

| Condition | Message Shown | Where Displayed |
| --- | --- | --- |
| No matching reservation | `No reservation found.` | Results area on `lookUpReservation.jsp` |
| Customer is not signed in | Sign-in is required before reservation lookup | Look Up Reservation page / login flow |
| Database lookup fails | Request fails with a servlet error | Server-side error handling |

## Login State Differences

| Item | Logged In | Logged Out |
| --- | --- | --- |
## Login State Differences

| Item | Logged In | Logged Out |
| --- | --- | --- |
| Look Up Reservation nav link | Displayed | Hidden |
| Reservation lookup | Available | Not available |
| Customer identification | Uses session `customerId` | No lookup allowed |
| Reservation results | Only reservations belonging to the signed-in customer | None |
