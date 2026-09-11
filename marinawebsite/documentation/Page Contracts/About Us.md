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

- [x] **Any session-dependent content beyond the scaffold?** Only the contact
  form's pre-fill. A signed-in customer's name and email arrive already filled
  in, read straight from the `Customer` bean the Login servlet puts in session
  (`${sessionScope.customer.firstName}` and friends). That needs nothing from
  Back End — the attribute is already there. Signed out, the fields are empty.
  The rest of the page is the same for everyone.

- [x] **Contact form field `name` attributes:** Decided — **the field names are
  the `Contact` table's column names**, one to one:

  `firstName`, `lastName`, `email`, `boatName`, `boatLength`,
  `reasonForContact`, `message`

  Deliberately not prefixed (`contactFirstName` and so on). The form has exactly
  one purpose and its fields land in exactly one table, so a rename between the
  input and the column would be a translation step that exists only to be got
  wrong. Full detail in [Front End Variables](#front-end-variables) below.

- [x] **Required vs. optional fields:** Decided, taken from the table's own NOT
  NULL constraints rather than invented:

  | Required | Optional |
  | --- | --- |
  | `firstName`, `lastName`, `email`, `reasonForContact`, `message` | `boatName`, `boatLength` |

  Boat details are optional because someone can have a question before they
  have a boat — the wait list exists for exactly those people (BR-19).

- [x] **Input length limits (HTML side):** Set from the column widths, see the
  Front End Variables table. `message` is `TEXT` in the database so it has no
  real ceiling; the form caps it at 2000 characters with a live counter, on the
  grounds that a message longer than that is a phone call.

- [x] **`reasonForContact` control:** A `<select>` of the six `ENUM` values from
  `definitions_decisions.md`, not a text box. The column is an `ENUM`, so
  anything else would be rejected by the database anyway — better to make it
  unpickable than to explain it afterwards.

### Back End Owns

- [x] **Does this page need a servlet at all?** Decided, and built: two servlets. `AboutServlet` (`/about`) just forwards to `aboutUs.jsp` — the page itself needs no server-side data. `ContactServlet` (`/contact`) is the separate one that actually handles the form submission.
- [x] **Servlet mapping:** Decided — the form POSTs to `/contact` (`ContactServlet`). `ContactServlet` also now answers `GET /contact` (forwards to `/aboutUs.jsp`), so navigating there directly no longer 405s.
- [x] **What does Back End do with the submission:** Stores it. `ContactServlet` validates, builds a `Contact` object, and calls `ContactDAO.insert()` to write a row to the `Contact` table. No email is sent.
- [x] **Pre-fill for logged-in users:** Nothing needed from Back End. The page
  reads the `Customer` bean `LoginServlet` already puts in session, so a
  signed-in customer's name and email arrive filled in with no GET handler
  involved. Answered by Front End — one less thing on this list.
- [x] **Success response:** **Decided, and changed since first built.** Originally forwarded back to `aboutUs.jsp` with a `contactSuccess` request attribute (see the Error Handling table's note below) — that let a page refresh right after submitting resubmit the same contact message. Now `ContactServlet` **redirects** (not forwards) to `/aboutUs.jsp?notice=contactSent` on success, so a refresh just reloads the page instead of resubmitting the form. `aboutUs.jsp` shows the success banner off that query param now, not off `contactSuccess`.
- [x] **Error attributes:** Decided — `contactError`, a request attribute, set on validation failure. That path still forwards (not redirects), since a forward is what lets the rejected submission redisplay with everything the customer typed still in it (see the note under Error Handling below).

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

Everything the contact form submits. The form POSTs to `/contact` (`ContactServlet`) — decided, see [Back End Owns](#back-end-owns) above.

| Field Name | Input Type | Required? | Format / Notes |
| --- | --- | --- | --- |
| `firstName` | text | Yes | `maxlength="50"`, matches `Contact.firstName`. Pre-filled from session when signed in |
| `lastName` | text | Yes | `maxlength="50"`, matches `Contact.lastName`. Pre-filled from session when signed in |
| `email` | email | Yes | `maxlength="255"`, matches `Contact.email`. Pre-filled from session when signed in. Checked with `MoffatBay.form.isValidEmail`, the same pattern `Utils.isValidEmail` uses server-side |
| `boatName` | text | **No** | `maxlength="100"`, matches `Contact.boatName`. Free text — not a link to the `Boat` table, so someone can name a boat they haven't registered |
| `boatLength` | number | **No** | `step="0.1"`, matches `Contact.boatLength` `DECIMAL(6,2)`. If filled in, must be a positive number no greater than 9999.9 |
| `reasonForContact` | select | Yes | One of the six `Contact.reasonForContact` ENUM values. A `<select>`, so nothing outside the list can be submitted from the page |
| `message` | textarea | Yes | Capped at 2000 characters with a live counter. `Contact.message` is `TEXT`, so this cap is the form's choice, not the column's |

Everything is trimmed before submit, and the trimmed value is written back into
the field, so what gets sent is what was checked.

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

- **Client-side (UX only, not trusted):** Every required field non-empty, email
  matching the shared pattern, `boatLength` a positive number if filled in, a
  reason chosen, and the message within 2000 characters. Errors appear under
  the field they belong to and focus moves to the first one. All of this is
  convenience — turning JavaScript off skips every bit of it.
- **Server-side (source of truth):** Back End's, but it has to re-check the
  same set, because the list above can be bypassed entirely. Two that matter
  more than the rest:
  - `reasonForContact` must be one of the six ENUM values. The page offers a
    `<select>`, but a hand-made POST can carry anything, and the database will
    reject an unknown value with an error the customer shouldn't have to see.
  - `boatLength` must parse as a number and fit `DECIMAL(6,2)`. It's optional,
    so blank has to be stored as `NULL` rather than rejected or stored as 0.

## Error Handling

Front End renders whatever Back End sets; the attribute names below are a
proposal, rename them and I'll follow.

| Condition | Message Shown | Where Displayed |
| --- | --- | --- |
| A required field is empty | "Enter your first name." and equivalents | Under the field, client-side, before submit |
| Email isn't a valid shape | "Enter a valid email address." | Under the email field, client-side |
| `boatLength` filled in but not a number | "Enter a length in feet, or leave this blank." | Under the field, client-side |
| Message over 2000 characters | Counter turns red past 1800; message on submit | Under the message box |
| Server-side validation rejects the submission | Back End's wording, shown as-is | `contactError` request attribute, as a banner above the form. The form comes back with what was typed still in it |
| Submission saved | "Thanks — we'll be in touch." | **Updated:** shown based on `?notice=contactSent` in the URL after a redirect, not a `contactSuccess` request attribute after a forward (see [Back End Owns](#back-end-owns) above for why this changed) |
| Database failure | Standard error page | `error.jsp`, per `web.xml` |

**The form redisplays from `param` values on a rejection**, so a rejected submission comes back
filled in rather than blank — this only works because the rejection case forwards
rather than redirects; a redirect would lose what they typed. The success case is
the opposite on purpose: it redirects specifically so the request parameters are
gone and a refresh can't resubmit them.

## Login State Differences

| Item | Logged In | Logged Out |
| --- | --- | --- |
| About Us page | Page can be opened normally | Page can be opened normally |
| Contact form name and email | Pre-filled from the `Customer` bean in session | Empty |
| Everything else on the page | Identical | Identical |
