# Page Contract: About Us

## Page Name

About Us

## Module / Week

Module 7 / Week 5 (Sep 7 – Sep 13, 2026)

## Assigned

- Full Page: Miguel
- Testing: Sara

## Open Questions / Decisions Needed

> **General rule:** any page that doesn't have real content yet should still exist as a JSP — use `includes/comingSoon.jsp` (pass `pageName` as a param) to create a stub page with the shared header/footer, so the link works instead of going nowhere.

### Front End Owns

- [ ] **Any session-dependent content beyond the scaffold?** Does anything on this page change based on login state beyond what the scaffold already handles? If not, Front End builds a static JSP.

### Back End Owns

- [ ] **Does this page need a servlet at all?** If it's purely static content inside the shared scaffold, Back End's only job may be servlet mapping / web.xml wiring. Confirm the scope.
- [ ] **Servlet mapping (if needed):** What URL maps to this page? (e.g., `/about`)

## Scaffold Include

This page includes the shared header/footer and identifies itself for nav highlighting:

```jsp
<jsp:include page="/includes/header.jsp">
    <jsp:param name="activePage" value="about" />
</jsp:include>

<!-- About Us page content -->

<jsp:include page="/includes/footer.jsp" />
```

> The `activePage` value `"about"` must match what the header checks. See the scaffold contract for the full reference table.

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
| About Us page | Page can be opened normally | Page can be opened normally |
