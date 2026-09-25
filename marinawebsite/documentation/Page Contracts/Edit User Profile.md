# Page Contract: Edit User Info

## Page Name

Edit User Info

## Module / Week

Module 8 / Week 6 (Sep 14 – Sep 20, 2026)

> Corrected from a stale "Module 9 / Week 7" — see `Page Role Assignments.md`.

## Assigned

- Front End: Miguel
- Back End: Robert

## Current Status (2026-09-14)

**Back End is done and tested; Front End has not started.** `editUserInfo.jsp` is still the original "coming soon" placeholder - nothing in this contract is visible or usable on the site yet. What exists and works, ready to build against:

- `EditProfileServlet` (`/editProfile`) - the main profile-fields form's GET and POST, including partial update, validation, the `country`/`state` clearing rule, and the redirect-plus-session-flash pattern for the post-save diff.
- `EditProfilePasswordServlet` (`/editProfile/password`) - the Change Password flow.
- `ForgotPasswordServlet` (`/forgotPassword`) - the lockout-recovery reset flow; also removes the old one-click "Unlock Account" button from `Login.md`'s flow with no replacement UI yet.
- The `CustomerDAO` methods each of the above needs (see [Database Returns](#database-returns)).

None of the three modals/pages this contract describes (the main form, the Change Password popup, the forgot-password popup, the "My Fleet" stub link) exist in any `.jsp`/`.js` file yet - every mention of them below is the spec to build against, not a description of something already there.

## Open Questions / Decisions Needed

### Front End Owns

- [ ] **Form field `name` attributes:** Are these the same `name` values as the Registration form, or different? Reusing keeps things consistent. List every editable field's `name`.
- [x] **Which fields are editable?** See [Which Fields Are Editable](#which-fields-are-editable) below for the full column-by-column list — still needs the team's sign-off, not yet final.
- [x] **Password change fields:** Password change is a popup modal, not inline fields on the main form — see [Password Change (Popup Modal)](#password-change-popup-modal) below. Fields are `currentPassword`, `newPassword`, `confirmNewPassword`.
- [x] **Forgot-password / lockout-recovery modal:** **Decided — Miguel + Robert signed off (Sep 2026); building this module.** Second popup modal, same shape as the Change Password modal but without `currentPassword` (replaced by the fake verification code `12345`). See [Password Change and the Lockout Model](#password-change-and-the-lockout-model) below.
- [ ] **How to show the customer's current information:** Three options on the table, team needs to pick one (or mix, per field type):
  1. **Placeholder text** inside each empty input (e.g. `placeholder="${customer.firstName}"`) that disappears the moment the user starts typing a replacement. Cheapest to build, but the moment you click into the field you lose sight of what it used to say, and a placeholder can't hold a value that's more than a few words (an address, for instance) without truncating.
  2. **Text next to the field showing the current value** (e.g. "Currently: Jane"), staying visible the whole time the user edits the field next to it. Doesn't disappear on focus, doesn't fight for space with placeholder styling, and reads clearly for longer values.
  3. **A separate "your current info" summary box** above or beside the form, listing every current value in one place, with the editable inputs left blank below it. Clean separation between "what it is now" and "what you're changing it to," but doubles up on layout since every value appears twice on the page.

  Whichever option is picked, it has to work per-field, not just per-page — leaving a field blank has to mean "no change," not "clear this value" (see [Partial Update](#partial-update-only-changed-fields-get-written) below), so the UI needs to make "I didn't touch this" visually distinct from "I want this blank."

### Back End Owns

- [x] **Pre-populated data source:** Front End reads `sessionScope.customer` directly via EL — no request attribute, no extra DB read. `LoginServlet` already puts `Customer` in the session, and it's kept current by the session refresh rule below. The GET handler's only job is the redirect-if-not-logged-in guard.
- [x] **Password change verification:** Yes — `CustomerDAO.verifyPassword()` (already exists, used by `LoginServlet`) checks `currentPassword` before anything is changed. If it doesn't match, the modal shows an inline error and nothing is written to the database — not even a `newPassword` that happens to be valid.
- [x] **Partial vs. full update:** Partial. Only fields the customer actually changed get written — see [Partial Update](#partial-update-only-changed-fields-get-written) below.
- [x] **Email uniqueness on change:** Yes. New `CustomerDAO.emailInUseByAnotherCustomer(String email, int customerId)` — `SELECT customerID FROM Customer WHERE email = ? AND customerID != ?` — deliberately not a reuse of `findByEmail()`, since that check has no way to exempt the customer's own current row.
- [x] **DAO method signature:** `CustomerDAO.updateCustomer(Connection conn, int customerId, Map<String, String> changedFields)`. A key absent from the map means untouched. A key present with an empty/null value means "clear it" — legal only for nullable/optional columns (`streetAddress2`; check the current schema for any others) — and the DAO binds SQL `NULL`, not an empty string. A **required** field arriving as a key with an empty/null value never reaches the DAO — the servlet rejects the request outright before validation runs, since a well-behaved Front End should never produce that state (see Partial Update below).
- [x] **All-or-nothing on validation:** If even one changed field fails validation, the **entire update is aborted** — no partial write. See [Validate Everything First](#validate-everything-first-then-write-nothing-or-write-everything) below.
- [x] **Forgot-password / lockout-recovery flow:** **Decided — replaces the Login page's "Unlock Account" button entirely.** A locked-out customer unlocks their account by successfully completing the forgot-password reset through this modal; there is no separate unlock action anymore. New `CustomerDAO.resetPasswordAndUnlock(Connection conn, int customerId, String newPasswordHash)` clears both `accountLocked` and `failedLoginAttempts` in the same transaction as the password update — kept distinct from the plain Change Password modal's `updatePassword()`, since that caller already proved they know the current password and should never touch lockout state. **`Login.md` is updated (2026-09-14)** - see its "Locking an Account After Repeated Failures" and "What the Session Remembers" sections.
- [x] **Session refresh after update:** After a successful update, Back End must replace the Customer Bean in the session with the new values — otherwise the header greeting, and any other page reading `sessionScope.customer`, shows stale data until the next login.
- [x] **Success/error response:** Different shape for each outcome. A validation failure is a sticky forward back to `editUserInfo.jsp` with named request attributes (`formError`, per-field errors), matching Registration's already-built pattern rather than the popup this contract originally specified - safe to leave as a forward, since resubmitting an already-rejected form on refresh just re-runs the same rejected validation. A **success** redirects instead (`/editProfile?notice=profileUpdated`), the same reasoning `RegisterServlet` already follows for its own success case: a forward would let a page refresh silently resubmit and re-apply the same update. The `?notice=` keyword drives the confirmation the same way `statusPopup.js` already handles `loggedIn`/`registered`/`passwordReset`. **Amended 2026-09-24:** the field-by-field old → new list is shown **before** saving, in a confirmation popup, and no longer after. A successful save shows only the "Profile updated" toast. The session flash that used to carry the after-save diff has been removed.
- [x] **Servlet URL mapping:** `/editProfile` (GET + POST, main profile form) and `/editProfile/password` (POST, password-change modal) as two separate servlet classes — `EditProfileServlet` and `EditProfilePasswordServlet` — mirroring the `/reservation` + `/reservation/boat` split (`ReservationServlet`/`ReservationBoatServlet`), not an `action` parameter on one servlet.

---

### Which Fields Are Editable

Every column on the `Customer` table (`databasescripts/MoffatBayMarinaDB_V1-8-0.sql` — the schema has been consolidated twice since this contract first cited `V1-4-0.sql`, see `databasescripts/Legacy/Week5/` and `databasescripts/Legacy/Week6/`), whether the customer should be able to change it here, and why. Confirmed below.

| Column | Editable? | Notes |
| --- | --- | --- |
| `customerID` | No | Primary key. Never Not Rendered on this table, Not editable. |
| `firstName` | Yes | Same field as Registration. |
| `lastName` | Yes | Same field as Registration. |
| `email` | Yes | Both the contact address and login username, `UNIQUE` on the table. Duplicate-check on change via `CustomerDAO.emailInUseByAnotherCustomer()`, excluding the customer's own row. No "type it twice" confirmation added — not requested. |
| `passwordHash` | No, not directly | Never rendered, never taken from this form's fields. Only changes through the [Password Change (Popup Modal)](#password-change-popup-modal) flow, or through the forgot-password reset flow via `resetPasswordAndUnlock()`. |
| `phone` | Yes | Same formatting/validation as Registration's Phone field. |
| `phoneCountryCode` | Yes | Travels with `phone`, same as Registration. |
| `streetAddress` | Yes | Required — a blank submission is rejected, not treated as "clear." |
| `streetAddress2` | Yes | Optional and nullable — an explicitly blank submission clears it to `NULL`. |
| `city` | Yes | Required — a blank submission is rejected. |
| `state` | Yes | Required. Follows `country`'s option list/label, same as Registration. |
| `zipCode` | Yes | Required — a blank submission is rejected. |
| `country` | Yes | Required. Changing this should also re-drive the State/Province field's option list and label client-side, same swap `registration.js` already does. |
| `dateJoined` | No | Historical fact about the account, not something a customer should be able to backdate or change. Not rendered. |
| `failedLoginAttempts` | No | System-managed bookkeeping. Cleared as a side effect of `resetPasswordAndUnlock()`, never set directly by this page. |
| `accountLocked` | No, not directly | System-managed. `CustomerDAO.unlockAccount()` is retired — cleared only as a side effect of a successful `resetPasswordAndUnlock()` via the [forgot-password flow](#password-change-and-the-lockout-model). |

---

### Boats — Handled by a Dedicated "My Fleet" Page

`Page Role Assignments.md`'s Module 8 note called for this page to reuse the Register a Boat popup modal, but boat management is out of scope here entirely — it's shipping as its own page, **My Fleet**, next module: editing a boat, adding a boat, trading a boat, and selling a boat, all as one piece of work rather than split across pages.

The plan is for this page to eventually get a **"My Fleet" button** linking to a stub page showing a Coming Soon placeholder — the same pattern other not-yet-built pages already use. **Not built yet** - there is currently no such button, and no `myFleet.jsp`, anywhere on the site. Front End's to add whenever the real Edit User Info page gets built.

---

### Password Change (Popup Modal)

Password change is its **own popup modal**, not fields mixed in with the rest of the profile form — same pattern as the existing Login modal (`includes/loginModal.jsp` / `js/loginModal.js`, opened with `MoffatBay.loginModal.open()`). A new shared component, e.g. `includes/changePasswordModal.jsp` + `js/changePasswordModal.js` exposing `MoffatBay.changePasswordModal.open()`, gets built the same way, and Edit User Info includes it and adds a "Change Password" button that opens it. Being its own modal keeps a password change as one atomic action, separate from whatever else the customer is editing on the main form at the same time.

**Fields**, all `type="password"`:

- `currentPassword` — required. Verified against the account's existing hash via `CustomerDAO.verifyPassword()` before anything else happens. Wrong current password → inline error in the modal (e.g. "Current password is incorrect."), nothing changes, `newPassword` is not evaluated or discarded silently — the customer sees exactly why it didn't go through.
- `newPassword` — required. Same five rules as Registration's Password field (10+ characters, uppercase, lowercase, number, one of `! $ % * #`), checked live the same way: the modal includes `includes/passwordRules.jsp` and wires it up with `MoffatBay.passwordRules.check()`, reusing `formValidation.js`'s `PASSWORD_RULES` rather than duplicating the rule set a second time.
- `confirmNewPassword` — required client-side only, same as Registration's `confirmPassword`: checked live against `newPassword` for a match, never actually submitted to the server.

**Flow:** modal opens → customer fills in all three → client-side checks (rules met, confirm matches) same as Registration → submit → Back End verifies `currentPassword` first → if good, validates `newPassword` against the same rules server-side (never trust the client) → hashes it with `Utils.hashPassword()` (the same helper `RegisterServlet` already uses) → updates `Customer.passwordHash` → modal closes with a success message (reusing `includes/statusPopup.jsp`'s `MoffatBay.statusPopup.show("Password updated")`, matching how "Boat saved" already works on the Reservation page).

This is a fully separate request/response from the profile-fields form — a password change and an edit to, say, the phone number are two independent submissions, not one combined POST. Keeps the "abort everything if one field is bad" rule (below) scoped to the profile fields only; a bad current password doesn't have anything to do with whether the phone number update should go through, and vice versa.

**Status:** Back End's side is done - `EditProfilePasswordServlet` (`/editProfile/password`) is built and tested against exactly this field contract. The modal itself is **not built** - that's Front End's to design and build; nothing currently on the site opens it or links to it.

#### Password Change and the Lockout Model

Should the password change, now that it exists, change how we handle the account lockout?

The standard way of doing this is sending an email with a verification code to authenticate that the user is who they say they are, then allowing them to change their password without needing to know the old one.  Since the emails are fake emails, there is no way to simulate this process, but we could have a modified modal that pops up with a message that exaplains that the user would normally be required to read an email with a verification code, and have an entry box where they have to enter a fake code that "Only an idiot would have on their luggage" `12345` to simulate getting a code in their email to verify.

This exact modal could be used with a "forgot password" option on the login screen as well to update the password if the user "forgets" it.

This takes extra work, so it requires separate tests: Miguel testing that the front end looks right and properly shows that the password modal shows a correct password entered and the second box matching, and Robert showing that the back end actually changed the password by logging in with the new password and showing that the old password is now invalid.

**Decided (Sep 2026): Miguel and Robert signed off. Building this module.**

Scope of the "yes": this changes the Login page's lockout model, not just this page. Login's existing "Unlock Account" button (plain reset, no password, no verification — see `Login.md`) is **retired**, full stop — unlocking is meant to happen by successfully completing a password reset through a forgot-password modal, not through a separate button. **`Login.md` is updated (2026-09-14)** to describe this.

**Status:** Back End's side is done - `ForgotPasswordServlet` (`/forgotPassword`) is built, tested, and ready, per the Front End Variables / Back End Parameters tables below. The forgot-password modal itself (Front End's popup UI, plus wiring a trigger into the Login modal's locked-out state and into the Change Password modal above) is **not built** - that's Front End's to design and build against the servlet's field contract, not something Back End should stand in for. Until it exists, a locked-out account has no in-UI recovery path.

Identifying which account to reset uses `email`, the same identifier Login itself uses - a locked-out visitor has no logged-in session to identify them any other way, and the flow has to work regardless of whether it's completed right after the lockout or from an entirely different device later on. `ForgotPasswordServlet` looks the account up by email and applies the identical anti-enumeration handling `LoginServlet` already uses for its own login error: an unregistered email and a correct-email-wrong-code submission produce the exact same message, so a submission can never be used to check which emails are registered. When this modal is opened from the "forgot your current password?" link on this page instead, it's pre-filled with the signed-in customer's own email rather than left blank - same field either way, just pre-populated when it's already known.

---

### Partial Update: Only Changed Fields Get Written

The customer might only be changing their phone number — the UPDATE statement shouldn't touch `firstName`, `email`, or anything else just because the form technically has a box for it. Back End needs a way to tell "the customer left this field showing what it already was" apart from "the customer is deliberately blanking this out" (relevant for the optional fields like `streetAddress2`). Two ways to get there, team decides which:

1. **Diff against the loaded Customer.** Front End always submits every field (simplest form), and the servlet compares each submitted value against the Customer Bean it loaded for the GET, building the SET clause only from fields that actually differ. Simple to build, but doesn't distinguish "customer retyped their existing phone number unchanged" from "customer never touched the phone field" — both look identical to a diff. Probably fine, since the end result is the same value either way, but worth naming as a limitation.
2. **Front End only submits touched fields.** JavaScript tracks which inputs the customer actually interacted with (a `change` listener setting a `data-touched` flag, or simply: fields that differ from their pre-filled value at submit time) and the form only includes those in the POST body. The servlet then only has parameters for what's changing at all — nothing to diff, `request.getParameter("x") == null` already means "not changing x." Slightly more JS, but the server-side logic gets simpler and the two "unwitting no-op" cases above are no longer conflated.

**Decided: Option 2, with one refinement.** A touched field is submitted with its new value normally. A touched **optional** field the customer clears (e.g. blanking `streetAddress2`) is submitted as an explicit empty value — the servlet treats "key present, value empty" as "set this column to NULL," not as "not changing it." A touched **required** field must never arrive empty — if it does, the servlet rejects the whole request outright (a distinct, structural error, not a normal per-field validation message), since that state means something upstream is broken, not that the customer made a typo.

`state` is a special case worth naming: it's normally required, but the front end disables that dropdown entirely when `country` is `OTHER` (no state/province concept applies), and a disabled field submits nothing at all - not even an explicit blank. So switching `country` to `OTHER` would otherwise leave the old state code stuck in the database forever, untouched and unreachable. The servlet handles this as a business rule rather than a front-end workaround: whenever `country` is actively being changed to `OTHER` in a submission, `state` is cleared along with it, whether or not the form sent anything for it.

Either way, the UPDATE statement itself needs to be built dynamically (which columns are in the `SET` clause depends on what changed), not a single fixed `UPDATE Customer SET firstName=?, lastName=?, ... WHERE customerID=?` that always touches every column.

This would include if the customer accidently puts a space or other whitespace in the fiels accidently, and needs to verify that the information in makes sense.

The front End should also have some sort of confirmation step, showing the user the exact changed that are being made:  
- Column: Old value -> New value

So if the user accidently puts a "s" in the "First Name" box, they have a visual confirmation box that shows they are changing their first name to "s" before they submit and are not surprised later.

**Built as (amended 2026-09-24):** a **"Save these changes?" popup** (the site's shared `.modal`, opened by `modal.js`) listing each changed field old → new, with **Go Back** and **Yes, Save**. It replaced an inline panel under the form. This is now the site-wide rule: confirm what **will** change in a popup before saving, then a toast after.

### Validate Everything First, Then Write Nothing or Write Everything

**If even one changed field fails validation, the whole update is aborted** — none of the other, valid changes get written either. Concretely: validate every changed field first, collect every failure (not just the first one hit), and only if that whole pass comes back clean does the servlet touch the database at all. This mirrors how `RegisterServlet`/`ReservationServlet` already run inside a transaction (`conn.setAutoCommit(false)`, roll back on any problem) — same shape here, just against an UPDATE instead of an INSERT. A customer fixing their phone number shouldn't have that quietly fail because they also fat-fingered their zip code in the same submission; they should see both problems at once and have neither change applied yet.

## Scaffold Include

This page includes the shared header/footer and identifies itself for nav highlighting:

```jsp
<jsp:include page="/includes/header.jsp">
    <jsp:param name="activePage" value="editprofile" />
</jsp:include>

<!-- Edit User Info page content -->

<jsp:include page="/includes/footer.jsp" />
```

> The `activePage` value `"editprofile"` must match what the header checks. See the scaffold contract for the full reference table.

## Front End Variables

Every field or control the page's UI sends to the Back End (form fields, query-string params on a lookup page, etc.). Proposed, pending [Which Fields Are Editable](#which-fields-are-editable) above being confirmed.

| Field Name | Input Type | Required? | Format / Notes |
| --- | --- | --- | --- |
| `firstName` | text | Only if changed | `maxlength="50"`, matches `Customer.firstName`; see [Partial Update](#partial-update-only-changed-fields-get-written) |
| `lastName` | text | Only if changed | `maxlength="50"`, matches `Customer.lastName` |
| `email` | email | Only if changed | Pending team decision, see [Which Fields Are Editable](#which-fields-are-editable) |
| `phoneCountryCode` | text | Only if changed | Same format as Registration |
| `phone` | text (hidden, formatted display shown separately) | Only if changed | Same 10-digit-raw pattern as Registration, see `Registration.md`'s Phone Number section |
| `streetAddress` | text | Only if changed | `maxlength="100"` |
| `streetAddress2` | text | Only if changed | `maxlength="100"`, optional even when the field itself is being changed |
| `city` | text | Only if changed | `maxlength="50"` |
| `state` | select | Only if changed | Follows `country`, same as Registration |
| `zipCode` | text | Only if changed | `maxlength="10"` |
| `country` | select | Only if changed | One of `US` / `CA` / `OTHER` |
| `currentPassword` | password | Yes, in the password modal only | Never pre-filled; see [Password Change (Popup Modal)](#password-change-popup-modal) |
| `newPassword` | password | Yes, in the password modal only | Same five rules as Registration's Password field |
| `confirmNewPassword` | password | Yes, client-side only, in the password modal only | Never submitted, checked live against `newPassword` |
| `email` (forgot-password modal) | email | Yes, in the forgot-password modal only | Identifies the account, same as Login's own `email` field. Pre-filled when it's already known (the address that was locked out, or the signed-in customer's own) |
| `verificationCode` | text | Yes, in the forgot-password modal only | Fake verification code; must equal `12345` |
| `newPassword` (forgot-password modal) | password | Yes, in the forgot-password modal only | Same five rules as the Change Password modal's `newPassword` |
| `confirmNewPassword` (forgot-password modal) | password | Yes, client-side only, in the forgot-password modal only | Never submitted, checked live against the forgot-password modal's `newPassword` |

## Back End Parameters

What the Back End reads for each Front End field, plus anything it pulls from elsewhere (session, query string) rather than the form itself.

| Parameter Name | Type | Source (form field / session / query string) | Notes |
| --- | --- | --- | --- |
| `customerId` | `int` | Session (`sessionScope.customerId`) | Never taken from the form — always the signed-in customer, so nobody can edit someone else's row by tampering with a hidden field |
| `firstName` | `String` | Form field, present only if changed (see [Partial Update](#partial-update-only-changed-fields-get-written)) | Maximum 50 characters if present |
| `lastName` | `String` | Form field, present only if changed | Maximum 50 characters if present |
| `email` | `String` | Form field, present only if changed | Pending team decision — duplicate check needed if editable, see above |
| `phoneCountryCode` | `String` | Form field, present only if changed | 1–3 digits, no leading zero |
| `phone` | `String` | Form field, present only if changed | Exactly 10 digits |
| `streetAddress` | `String` | Form field, present only if changed | |
| `streetAddress2` | `String` | Form field, present only if changed | Blank submitted value stored as `NULL` |
| `city` | `String` | Form field, present only if changed | |
| `state` | `String` | Form field, present only if changed | Converted to uppercase |
| `zipCode` | `String` | Form field, present only if changed | Five-digit or ZIP+4 |
| `country` | `String` | Form field, present only if changed | Must be `US`, `CA`, or `OTHER` |
| `currentPassword` | `String` | Form field (password modal) | Verified via `CustomerDAO.verifyPassword()` before anything else |
| `newPassword` | `String` | Form field (password modal) | Validated against the five password rules, then hashed |
| `email` (forgot-password modal) | `String` | Form field (forgot-password modal) | Looked up via `CustomerDAO.findByEmail()`; unrecognized email and wrong code produce the identical response, see above |
| `verificationCode` | `String` | Form field (forgot-password modal) | Must equal `12345` (simulated email verification) |
| `newPassword` (forgot-password) | `String` | Form field (forgot-password modal) | Same five rules, then hashed via `resetPasswordAndUnlock()` |

## Database Returns

Every query or DAO method the Back End calls for this page, and its exact return shape — including what it returns on "no match" (null vs. empty object vs. exception).

| Method / Query | Parameters In | Returns | Notes |
| --- | --- | --- | --- |
| `CustomerDAO.verifyPassword()` | `int customerId`, `String submittedHash` | `boolean` | The `customerId` overload is new (Login already had the `String email` one) - used here since the Change Password modal already has a trusted `customerId` from the session, and email is no longer a stable identifier once this page lets a customer change it |
| `CustomerDAO.findByEmail()` | `String email` | `Customer` or `null` | Already exists; used for lookups that only have an email to start from (login, registration) |
| *(new)* `CustomerDAO.findById()` | `Connection`, `int customerId` | `Customer` or `null` | Added so session refresh after a profile update never depends on an email that may have just changed |
| *(new)* `CustomerDAO.emailInUseByAnotherCustomer()` | `Connection`, `String email`, `int customerId` | `boolean` | Excludes the customer's own row; used only when `email` is a changed field |
| *(new)* `CustomerDAO.resetPasswordAndUnlock()` | `Connection`, `int customerId`, `String newPasswordHash` | `void`, throws on failure | Clears `accountLocked` and `failedLoginAttempts` in the same transaction as the password update; used only by the forgot-password flow, never the plain Change Password modal |
| *(new)* `CustomerDAO.updateCustomer()` | `Connection`, `int customerId`, `Map<String, String> changedFields` | `void`, throws `SQLException` on failure (caller rolls back the transaction) | See [DAO method signature](#back-end-owns) above |
| *(new)* `CustomerDAO.updatePassword()` | `Connection`, `int customerId`, `String newHash` | `void`, throws `SQLException` on failure | Separate from `updateCustomer()` and from `resetPasswordAndUnlock()` — this one is only reached after `verifyPassword()` succeeds, see [Password Change (Popup Modal)](#password-change-popup-modal) |

## Validation Rules

- **Client-side (UX only, not trusted):** Same per-field format checks as Registration for whichever fields are editable (email shape, phone digit count, zip format, etc.). The password modal live-checks `newPassword` against the five rules and `confirmNewPassword` against `newPassword`, identical to Registration's Password/Re-type Password behavior. Whatever field-blank-vs-unchanged mechanism gets picked in [Partial Update](#partial-update-only-changed-fields-get-written) also has to be visually clear to the customer, not just a server-side detail.
- **Server-side (source of truth):** Every field that came through as "changed" gets the same format validation Registration already runs for that field. **All changed fields are validated before any database write happens; if any one of them fails, the entire update is rejected and nothing is saved** — see [Validate Everything First](#validate-everything-first-then-write-nothing-or-write-everything). The password modal's `currentPassword` is verified before `newPassword` is even evaluated; a wrong current password rejects the change outright regardless of whether `newPassword` would otherwise have been valid.

## Error Handling

Every user-facing error condition this page can hit, and exactly what the user sees.

| Condition | Message Shown | Where Displayed |
| --- | --- | --- |
| One or more changed fields fail validation | Every failing field's specific message shown together (not just the first one found); nothing is saved | Inline, next to each failing field on the main form |
| Current password doesn't match, in the password modal | "Current password is incorrect." | Inline in the password modal, under `currentPassword` |
| New password doesn't meet the rules | Same live rule-checklist behavior as Registration | Under `newPassword`, via `includes/passwordRules.jsp` |
| Confirm New Password doesn't match New Password | "Passwords do not match." | Under `confirmNewPassword`, live as the user types |
| Email changed to a value already in use by another customer | Same message shape as Registration's duplicate-email error | Inline, under the `email` field |
| Update succeeds | "Profile updated" toast (**amended 2026-09-24**: no after-save diff; the old → new list is shown before saving, in the "Save these changes?" popup) | Status popup |
| Forgot-password verification code is wrong | "That code doesn't match — check your email and try again." (simulated; the only valid code is `12345`) | Inline in the forgot-password modal, under the code field |
| A required field is submitted blank | Not a user-facing message — this indicates a Front End or tampering bug. Request is rejected outright. | N/A |

**How field-level errors reach the page:** one request attribute, `fieldErrors` (`Map<String, String>`, field name → message), not a separate named attribute per field - eleven of those would be unwieldy at this field count, unlike Registration's two or three. The page reads each entry into the error element already sitting next to that field (`document.getElementById(fieldName + "Error")`), the same elements Registration already uses. One naming exception: `zipCode`'s error element is `id="zipError"`, inherited from Registration/`registration.js`, which already depends on that exact id - so the lookup special-cases `zipCode` → `zipError` rather than the general `fieldName + "Error"` pattern.

## Login State Differences

| Item | Logged In | Logged Out |
| --- | --- | --- |
| Edit user information | Available to the signed-in user | Not reachable while logged out |
