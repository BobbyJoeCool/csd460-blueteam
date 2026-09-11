# Page Contract: Landing Page

## Page Name

Landing Page

## Module / Week

Module 5 / Week 4 (Aug 31 – Sep 6, 2026)

## Assigned

- Front End: Carolina (Landing page content + any backend)
- Back End: (minimal — see notes)
- Shared Header/Footer Scaffold: Sara
- Testing:

## Open Questions / Decisions Needed

> **General rule:** any page that doesn't have real content yet should still exist as a JSP — use `includes/comingSoon.jsp` (pass `pageName` as a param) to create a stub page with the shared header/footer, so the link works instead of going nowhere.

- [x] **CTA link targets:** Decided. **Update:** both CTAs now point at the `/reservation` servlet, not `reservation.jsp` directly — going straight at the JSP skips `ReservationServlet.doGet()` and the page loads with no boat/dock/pricing data (same fix applied everywhere else on the site). "Reserve a Slip" links to `/reservation` (logged in) or opens the login modal with `redirectTo` set to `/reservation` (logged out), so a fresh sign-in lands the customer straight on the reservation page instead of back on the landing page. Bottom CTA links to `/reservation` as "Book a Slip" (logged in) or `registration.jsp` as "Create an Account" (logged out).
- [x] **Session attribute name for login state:** `sessionScope.loggedIn` (boolean), set by `LoginServlet`. Matches the Login contract.
- [x] **User display name attribute:** `sessionScope.displayName` — a pre-formatted "First L." greeting name (e.g. "Elena M."), built by the Customer bean and set by `LoginServlet`.
- [x] **Does the landing page need a servlet?** No. The only dynamic elements are login-state checks using `<c:choose>` in the JSP and the scaffold's session-driven header swap. No dedicated servlet.

## Scaffold Include

This page includes the shared header/footer and identifies itself for nav highlighting:

```jsp
<jsp:include page="/includes/header.jsp">
    <jsp:param name="activePage" value="home" />
</jsp:include>

<!-- Landing page content -->

<jsp:include page="/includes/footer.jsp" />
```

> The `activePage` value `"home"` must match what the header checks. See the scaffold contract for the full reference table.

## Front End Variables

The landing page does not contain a form and does not submit landing-page fields to a servlet.

| Field or Control | Type | Required? | Format / Notes |
| --- | --- | --- | --- |
| `activePage` | JSP include parameter | Yes | Passes `"home"` to `header.jsp` so Home can be highlighted |
| Reserve a Slip (logged out) | Button | No | Calls `MoffatBay.loginModal.open('/reservation')`; does not submit form data, just sets where the modal redirects to after a successful sign-in |
| Reserve a Slip (logged in) | Link | No | Navigates to `/reservation` (the servlet — **updated**, was `reservation.jsp` directly) |
| Create an Account (logged out) | Link | No | Navigates to `registration.jsp` |
| Book a Slip (logged in) | Link | No | Navigates to `/reservation` (the servlet — **updated**, was `reservation.jsp` directly) |

## Back End Parameters

The landing page does not currently read form values or call a dedicated servlet.

| Parameter Name | Type | Source | Notes |
| --- | --- | --- | --- |
| `activePage` | `String` | JSP include parameter | Passed to `header.jsp` with the value `"home"` |
| `registered` | `String` | Query string | `RegisterServlet` redirects with `registered=true`. **Update:** this is now read and displayed — `js/statusPopup.js` special-cases `registered=true` (treating it the same as `?notice=registered`) and shows "Account created — welcome aboard" via the shared status popup on whichever page it lands on, then strips both params from the URL |
| Login session attribute | TBD | HTTP session | Read by the shared header; exact name must match `LoginServlet` |

## Database Returns

The landing page does not query the database directly.

| Method / Query | Parameters In | Returns | Notes |
| --- | --- | --- | --- |
| None | None | None | Authentication and database operations are handled by the login and registration servlets |

## Validation Rules

- **Client-side (UX only, not trusted):** The landing page has no input fields requiring validation. Button and modal behavior is handled by `loginModal.js`.
- **Server-side (source of truth):** The landing page submits no data and requires no server-side validation. Login and registration validation are handled by their respective servlets.

## Error Handling

| Condition | Message Shown | Where Displayed |
| --- | --- | --- |
| Login fails | Defined by the Login page contract | Reusable login modal |
| Registration succeeds | "Account created — welcome aboard" (**updated** — this used to say no message was displayed) | Shared status popup (`includes/statusPopup.jsp`), triggered by `?registered=true` on the redirect from `RegisterServlet` |
| Hero image cannot load | No message; background color remains visible | Hero section |
| Landing page fails to load | Standard Tomcat error response | Browser |

## Login State Differences

| Item | Logged In | Logged Out |
| --- | --- | --- |
| Hero "Reserve a Slip" | Direct link to `/reservation` (**updated**, was `reservation.jsp`) | Opens the login modal with `redirectTo` set to `/reservation` |
| Bottom CTA | "Book a Slip" linking to `/reservation` (**updated**, was `reservation.jsp`), with "Check availability and book your spot today." | "Create an Account" linking to `registration.jsp`, with "Create an account or sign in to check availability and book your spot today." |
