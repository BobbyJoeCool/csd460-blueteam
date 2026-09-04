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

> **General rule:** any link pointing to a page that doesn't exist yet should use `href="#"` so the element is clickable but doesn't navigate anywhere. Replace with the real path once that page's JSP is merged.

- [ ] **CTA link targets:** What `href` values do the Call-to-Action buttons use? (e.g., `reservation.jsp`, `about.jsp`) Use `href="#"` for any page not yet built.
- [ ] **Session attribute name for login state:** What is the exact session attribute name and type the scaffold checks to toggle between "Log In" and "Welcome {name}"? (Must match the Login contract.)
- [ ] **User display name attribute:** What Bean property or session attribute provides the display name for the greeting — `firstName`, `fullName`, something else?
- [ ] **Does the landing page need a servlet?** If the only dynamic element is the logged-in greeting handled by the scaffold's session check, the page may be a plain JSP with no servlet. Confirm so Back End knows the scope of work.

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
| Reserve a Slip | Button | No | Calls `MoffatBay.loginModal.open()`; does not submit form data |
| Create an Account | Link | No | Navigates to `${pageContext.request.contextPath}/registration.jsp` |

## Back End Parameters

The landing page does not currently read form values or call a dedicated servlet.

| Parameter Name | Type | Source | Notes |
| --- | --- | --- | --- |
| `activePage` | `String` | JSP include parameter | Passed to `header.jsp` with the value `"home"` |
| `registered` | `String` | Query string | `RegisterServlet` redirects with `registered=true`; currently not displayed by `index.jsp` |
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
| Registration succeeds | No message currently displayed | `RegisterServlet` redirects to `/?registered=true`, but `index.jsp` does not yet read it |
| Hero image cannot load | No message; background color remains visible | Hero section |
| Landing page fails to load | Standard Tomcat error response | Browser |
