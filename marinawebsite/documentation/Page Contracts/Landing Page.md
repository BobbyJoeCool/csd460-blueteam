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
