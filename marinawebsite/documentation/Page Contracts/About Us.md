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

## What the Page Shows

Top to bottom: **A working harbor in the San Juans** (the marina's story); **The marina at a glance** (Docks, Slips, Slip sizes: 26 ft ×30, 40 ft ×24, 50 ft ×18); **Find us and reach us** (address, phone, email, VHF channel, office hours and fuel dock hours, and the slip holders' after-hours note, all from `MarinaInfo`, the `marina` application attribute); **The docks** (the marina map); and **Send us a message**, the contact form (`#formHeading`, where the footer's Contact link lands).

## Open Questions / Decisions Needed

> **General rule:** any page that doesn't have real content yet should still exist as a JSP — use `WEB-INF/includes/comingSoon.jsp` (pass `pageName` as a param) to create a stub page with the shared header/footer, so the link works instead of going nowhere.

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

- [x] **Does this page need a servlet at all?** Decided, and built: two servlets. `AboutServlet` (`/about`) just forwards to `/WEB-INF/views/aboutUs.jsp` — the page's marina details come from the `marina` application attribute, so it needs no lookup of its own. `ContactServlet` (`/contact`) handles the form submission.
- [x] **Servlet mapping:** Decided — the form POSTs to `/contact` (`ContactServlet`). `ContactServlet` also answers `GET /contact` (forwards to the same About Us view), so navigating there directly doesn't 405. `/contact` is one of the forms `PostRateLimitFilter` covers (10 posts a minute per address), and like every POST it needs `CsrfFilter`'s token.
- [x] **What does Back End do with the submission:** Stores it. `ContactServlet` validates, builds a `Contact` object, and calls `ContactDAO.insert()` to write a row to the `Contact` table. No email is sent.
- [x] **Pre-fill for logged-in users:** Nothing needed from Back End. The page
  reads the `Customer` bean `LoginServlet` already puts in session, so a
  signed-in customer's name and email arrive filled in with no GET handler
  involved. Answered by Front End — one less thing on this list.
- [x] **Success response:** **Decided, and changed since first built.** Originally forwarded back with a `contactSuccess` request attribute, which let a refresh resubmit the same message. Now `ContactServlet` **redirects** to `/about?notice=contactSent` on success, so a refresh just reloads the page, and the shared status popup says "Thanks — we'll be in touch as soon as we can."
- [x] **Error attributes:** Decided — `contactError`, a request attribute, set on validation failure. That path still forwards (not redirects), since a forward is what lets the rejected submission redisplay with everything the customer typed still in it (see the note under Error Handling below).

## Scaffold Include

This page includes the shared header/footer and identifies itself for nav highlighting:

```jsp
<jsp:include page="/WEB-INF/includes/header.jsp">
    <jsp:param name="activePage" value="about" />
</jsp:include>

<!-- About Us page content -->

<jsp:include page="/WEB-INF/includes/footer.jsp" />
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
| `boatLength` | number | **No** | `step="0.1"`, matches `Contact.boatLength` `DECIMAL(6,2)`. If filled in, must be a positive number no greater than 999.9 — the same limit as every other boat form (`Utils.MAX_BOAT_DIMENSION`); this was 9999.9 until the shared-validation cleanup |
| `reasonForContact` | select | Yes | One of the six `Contact.reasonForContact` ENUM values. A `<select>`, so nothing outside the list can be submitted from the page |
| `message` | textarea | Yes | Capped at 2000 characters with a live counter. `Contact.message` is `TEXT`, so this cap is the form's choice, not the column's |

Everything is trimmed before submit, and the trimmed value is written back into
the field, so what gets sent is what was checked.

## Back End Parameters

What the Back End reads for each Front End field, plus anything it pulls from elsewhere (session, query string) rather than the form itself.

| Parameter Name | Type | Source (form field / session / query string) | Notes |
| --- | --- | --- | --- |
| `firstName` | `String` | Form field | Trimmed; required; maximum 50 characters |
| `lastName` | `String` | Form field | Trimmed; required; maximum 50 characters |
| `email` | `String` | Form field | Trimmed; required; maximum 255 characters; must pass `Utils.isValidEmail` |
| `boatName` | `String` | Form field | Trimmed; optional; maximum 100 characters; blank stored as `NULL` |
| `boatLength` | `BigDecimal` | Form field | Optional; if filled in, a positive number within `Utils.MAX_BOAT_DIMENSION` (999.9); blank stored as `NULL` |
| `reasonForContact` | `String` | Form field | Required; one of the six values in `ContactServlet.VALID_REASONS` |
| `message` | `String` | Form field | Trimmed; required; maximum 2000 characters |
| `customer` | `Customer` | Session (`sessionScope.customer`) | Read by the JSP only, to pre-fill name and email. The servlet never reads the session; a message is stored the same whether or not anyone is signed in |

## Database Returns

Every query or DAO method the Back End calls for this page, and its exact return shape — including what it returns on "no match" (null vs. empty object vs. exception).

| Method / Query | Parameters In | Returns | Notes |
| --- | --- | --- | --- |
| `ContactDAO.insert()` | `Connection`, `Contact` | `int` new `contactID` | Writes one `Contact` row, with the time it was sent. Throws `SQLException` if no row is inserted or no ID comes back |

## Validation Rules

- **Client-side (UX only, not trusted):** Every required field non-empty, email
  matching the shared pattern, `boatLength` a positive number if filled in, a
  reason chosen, and the message within 2000 characters. Errors appear under
  the field they belong to and focus moves to the first one. All of this is
  convenience — turning JavaScript off skips every bit of it.
- **Server-side (source of truth):** `ContactServlet` re-checks the same set, because the list above can be bypassed entirely, and returns the first failure. Two that matter more than the rest:
  - `reasonForContact` must be one of the six ENUM values. The page offers a
    `<select>`, but a hand-made POST can carry anything, and the database will
    reject an unknown value with an error the customer shouldn't have to see.
  - `boatLength` must parse as a number and fit `DECIMAL(6,2)`. It's optional,
    so blank has to be stored as `NULL` rather than rejected or stored as 0.

## Error Handling

| Condition | Message Shown | Where Displayed |
| --- | --- | --- |
| A required field is empty | "Enter your first name." and equivalents | Under the field, client-side, before submit |
| Email isn't a valid shape | "Enter a valid email address." | Under the email field, client-side |
| `boatLength` filled in but not a number | "Enter a length in feet, or leave this blank." | Under the field, client-side |
| Message over 2000 characters | Counter turns red past 1800; message on submit | Under the message box |
| Server-side validation rejects the submission | The first failure, e.g. "Enter your first name.", "Choose a reason so we can route your message.", "That length is longer than any boat we can moor.", "Please keep your message under 2000 characters." | `contactError`, as a banner above the form. The form comes back with what was typed still in it |
| Too many messages from one address | "Easy Does It" page (429) | `error.jsp` |
| Submission saved | "Thanks — we'll be in touch as soon as we can." | Shared status popup, via `?notice=contactSent` after the redirect |
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
