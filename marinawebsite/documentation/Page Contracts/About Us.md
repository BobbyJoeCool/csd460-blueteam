# Page Contract: About Us

## Page Name

About Us

## Module / Week

Module 7 / Week 5 (Sep 7 – Sep 13, 2026)

## Assigned

- Front End: Miguel
- Back End: Sara
- Testing: Robert

> **Update (Sep 7):** Professor-directed change — Contact Us is cut as a standalone page; its contact info and backend fold into this page instead. This is no longer a back-end-lite page, so it's now a real Front End/Back End pair (previously Miguel solo, Sara testing). Robert picks up testing since he wasn't involved building either half.

## Open Questions / Decisions Needed

> **General rule:** any page that doesn't have real content yet should still exist as a JSP — use `includes/comingSoon.jsp` (pass `pageName` as a param) to create a stub page with the shared header/footer, so the link works instead of going nowhere.

### Front End Owns

- [ ] **Any session-dependent content beyond the scaffold?** Does anything on this page change based on login state beyond what the scaffold already handles? If not, Front End builds a static JSP.
- [ ] **Contact form field `name` attributes (carried over from Contact Us):** Agree on the exact `name` for every field (e.g., `contactName`, `contactEmail`, `subject`, `messageBody`).
- [ ] **Required vs. optional fields:** Which fields are required? Front End marks them visually and validates client-side; Back End validates server-side — both must agree on the same set.
- [ ] **Input length limits (HTML side):** Set `maxlength` on each field; must match server-side and DB column sizes.

### Back End Owns

- [ ] **Does this page need a servlet at all?** Confirm the scope now that it's handling a contact submission, not just static content.
- [ ] **Servlet mapping:** What URL maps to this page / handles the form POST? (e.g., `/about`, or a separate `/submitInquiry`)
- [ ] **What does Back End do with the submission (carried over from Contact Us — decide this first, it drives everything else):** Store in a database table, send an email, both, or just return a success message?
- [ ] **Pre-fill for logged-in users:** Does Back End forward customer name/email as request attributes on the GET so Front End can pre-populate?
- [ ] **Success response:** After submission, what does Back End return — a forward back to the same JSP with a success attribute, or a redirect?
- [ ] **Error attributes:** What attribute names and messages does Back End set for validation failures?

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
