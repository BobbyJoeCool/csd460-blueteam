# Page Contract: Login

## Page Name

Login (Modal / Popup)

## Module / Week

Module 5 / Week 4 (Aug 31 – Sep 6, 2026)

## Assigned

- Front End: Miguel
- Back End: Robert
- Testing:

## Open Questions / Decisions Needed

### Front End Owns

- [ ] **Login field `name` attributes:** What are the exact `name` values for the email/username and password form fields? Front End picks these, Back End just needs to know what they're called so it can read what got submitted.
- [ ] **Form submission method:** Does the modal submit via a standard form POST (page reloads) or AJAX/fetch (modal stays open for inline error display)? This changes how both sides handle the request/response cycle.
- [ ] **Error display location:** Where in the modal does the error message render? Front End reads the error attribute Back End sets (see below) and places it.
- [ ] **Client-side email format validation:** Since the login identifier is the `email` column, Front End needs to check the username field looks like a real email address (`type="email"` and/or a pattern check) before letting the form submit. This is just for UX, it's not trusted. The back end still does its own lookup and treats a non-match the same as any other bad login.

### Back End Owns

- [x] **Session attributes set on successful login:** See [What the Session Remembers](#what-the-session-remembers) below.
- [x] **Customer Bean structure:** See [Customer Data Passed to the Front End](#customer-data-passed-to-the-front-end) below.
- [x] **Error attribute for invalid credentials:** See [What the Front End Sees on Failure](#what-the-front-end-sees-on-failure) below. Generic "username or password" message, plus a separate locked-out case.
- [x] **Post-login behavior:** See [Where the User Lands After Login](#where-the-user-lands-after-login) below. Driven by a `redirectTo` field the front end sends along.
- [x] **Servlet URL mapping:** `/login` (predecided).

---

### How the Username Works

The "username" on this login form is really just the customer's email. There's no separate username on file, email doubles as the login name. The front end can call the field whatever it wants on the label, the back end just needs to know which submitted field to treat as the email.

### How Passwords Are Checked

Passwords get hashed before we compare them, SHA-256, no salt (predecided). We never compare raw text, and the raw password never gets stored or logged anywhere. Whatever hashing method I use here has to match what Registration uses exactly, or nobody who just signed up will be able to log back in. I need to check that with Carolina instead of assuming it lines up.

### Locking an Account After Repeated Failures

After three wrong passwords in a row on the same account, that account locks. Once it's locked, any login attempt gets rejected right away, we don't even check the password, and the user sees a different message with a way to unlock it (see [What the Front End Sees on Failure](#what-the-front-end-sees-on-failure)).

A successful login always resets the failed count back to zero, so a few scattered typos over weeks won't add up. It has to be three wrong attempts in a row to trigger a lock. And attempts against an email that isn't in the system at all don't count toward anything, since there's no account to attach the count to.

That means each customer's record needs to track two things it doesn't right now: how many failed attempts have happened since the last successful login, and whether the account is currently locked. That's a small database change the team needs to plan for alongside building this page.

**Demo shortcut:** since we don't have a real email-based reset flow for this project, the locked-out message just includes a plain "Reset" button. Clicking it clears the lock and the failed count for that account. It's standing in for "the user got a reset email and picked a new password."

### What the Session Remembers

Once someone logs in, the rest of the site needs an easy way to know they're logged in and greet them by name, without every page having to look their info up again. So four things get remembered for the rest of the visit:

| What's remembered | Looks like | Why |
| --- | --- | --- |
| Whether they're logged in | `true` | Pages check for this to switch between "Log In" and "Welcome back" |
| Their full account info | the customer's name, email, address, etc. | So pages like "Edit My Info" don't need to look it up again |
| Their customer ID by itself | a number | Quick access for pages that only need the ID, not everything else |
| A short greeting name | `"Robert B."` | First name plus last initial, ready to drop into a nav bar greeting without every page having to build it itself |

Logging out clears all of it at once.

### Customer Data Passed to the Front End

After login, this is the account info the rest of the site has access to: first name, last name, email, phone, mailing address (street, city, state, zip), and the date they joined. There's also a short "First L." display name (like "Robert B.") built automatically from the first and last name, so no page has to build it on its own.

The password comes along too, in hashed form, since it's part of the same record. It should never actually get shown or referenced on any page though.

### What the Front End Sees on Failure

Two different failure messages, so the user knows what's going on. Neither one ever says which of username or password was wrong though, only whether the account is now locked:

- **Wrong username or password:** "The username or password you entered is incorrect." Shows on a simple error page with a link back to the homepage.
- **Account locked (3 failed attempts in a row):** "This account has been locked after multiple failed login attempts." Shows on that same error page, but with the demo "Reset" button added so the user can unlock it right there.

### Where the User Lands After Login

The front end tells the back end where to send the user afterward, by including a hidden field (`redirectTo`) with the login form:

- If the user got blocked from doing something (like trying to reserve a slip while logged out), this points to that page, so once they log in they land right back where they were headed.
- If the user just clicked "Log In" on their own, this points to whatever page they were already on.

The back end doesn't need to know which case it is, it just sends the user wherever `redirectTo` points once login succeeds, and falls back to the homepage if that value is missing or looks like it points off the site.

### Email Format Check on the Back End

The front end already checks the username field looks like a real email before it lets the form submit, but that check can be skipped or bypassed, so the back end quietly re-checks the format too. A badly formed email gets treated exactly like "no matching account," same generic error message, so this check can never be used to figure out whether a given email is in the system.

---

## Front End Variables

Every field or control the page's UI sends to the Back End (form fields, query-string params on a lookup page, etc.).

| Field Name | Input Type | Required? | Format / Notes |
| --- | --- | --- | --- |
| | | | |

## Back End Parameters

What the Back End reads for each Front End field, plus anything it pulls from elsewhere (session, query string) rather than the form itself.

| Parameter Name | Type | Source (form field / session / query string) | Notes |
| --- | --- | --- | --- |
| (identifier, email) | text | Form field | Exact field name still TBD by Front End; treated as the email no matter what the field is labeled |
| (password) | text | Form field | Exact field name still TBD by Front End |
| `redirectTo` | text | Form field (hidden) | Fixed name, required for [Where the User Lands After Login](#where-the-user-lands-after-login) to work. Front End sets its value, not its name |
| `action` | text | Query string, only on the demo reset click | e.g. `/login?action=reset`, tells the servlet this is the "unlock account" click and not a normal login submit |

## Validation Rules

- **Client-side (UX only, not trusted):** Front End's call, but probably just "both fields filled in, username looks like an email" before it lets you submit.
- **Server-side (source of truth):**
  - Both fields are required. A missing field gets treated the same as a failed login (generic invalid-credentials error), not its own message, so it doesn't give away which one was empty.
  - The email format gets re-checked here too, see [Email Format Check on the Back End](#email-format-check-on-the-back-end).
  - `redirectTo` only gets honored if it points somewhere on this site. Otherwise it falls back to the landing page, see [Where the User Lands After Login](#where-the-user-lands-after-login).
  - Passwords always get compared as hashes, never as plain text.

## Error Handling

Every user-facing error condition this page can hit, and exactly what the user sees.

| Condition | Message Shown | Where Displayed |
| --- | --- | --- |
| Unknown email, or wrong password with fewer than 3 prior failures | "The username or password you entered is incorrect." | `login-error.jsp`, with a link back to the landing page |
| Wrong password on the 3rd try in a row, or a login attempt against an account that's already locked | "This account has been locked after multiple failed login attempts." | `login-error.jsp`, with the demo "Reset" button in place of (or alongside) the landing-page link |
| Session expires mid-use on another page (not really this page's failure, but downstream pages depend on the session attributes this page sets) | N/A, out of scope for this contract. Each page that consumes the session defines its own logged-out fallback behavior | N/A |
