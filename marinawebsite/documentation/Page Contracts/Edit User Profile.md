# Page Contract: Edit User Info

## Page Name

Edit User Info

## Module / Week

Module 9 / Week 7 (Sep 21 – Sep 27, 2026)

## Assigned

- Front End: Miguel
- Back End: Robert

## Open Questions / Decisions Needed

### Front End Owns

- [ ] **Form field `name` attributes:** Are these the same `name` values as the Registration form, or different? Reusing keeps things consistent. List every editable field's `name`.
- [x] **Which fields are editable?** See [Which Fields Are Editable](#which-fields-are-editable) below for the full column-by-column list — still needs the team's sign-off, not yet final.
- [x] **Password change fields:** Password change is a popup modal, not inline fields on the main form — see [Password Change (Popup Modal)](#password-change-popup-modal) below. Fields are `currentPassword`, `newPassword`, `confirmNewPassword`.
- [ ] **Forgot-password / lockout-recovery modal:** See [Password Change and the Lockout Model](#password-change-and-the-lockout-model) below. If adopted, this is a second popup modal, similar in shape to the Change Password modal but without a `currentPassword` field (replaced by the fake verification code), and it updates the Login page's existing lockout model as it stands today — not just an addition to this page. Needs Miguel + Robert sign-off before building.
- [ ] **How to show the customer's current information:** Three options on the table, team needs to pick one (or mix, per field type):
  1. **Placeholder text** inside each empty input (e.g. `placeholder="${customer.firstName}"`) that disappears the moment the user starts typing a replacement. Cheapest to build, but the moment you click into the field you lose sight of what it used to say, and a placeholder can't hold a value that's more than a few words (an address, for instance) without truncating.
  2. **Text next to the field showing the current value** (e.g. "Currently: Jane"), staying visible the whole time the user edits the field next to it. Doesn't disappear on focus, doesn't fight for space with placeholder styling, and reads clearly for longer values.
  3. **A separate "your current info" summary box** above or beside the form, listing every current value in one place, with the editable inputs left blank below it. Clean separation between "what it is now" and "what you're changing it to," but doubles up on layout since every value appears twice on the page.

  Whichever option is picked, it has to work per-field, not just per-page — leaving a field blank has to mean "no change," not "clear this value" (see [Partial Update](#partial-update-only-changed-fields-get-written) below), so the UI needs to make "I didn't touch this" visually distinct from "I want this blank."

### Back End Owns

- [ ] **Pre-populated data source:** Does Back End forward the current Customer Bean as a request attribute on GET, or does Front End read it from the session? What attribute name?
- [x] **Password change verification:** Yes — `CustomerDAO.verifyPassword()` (already exists, used by `LoginServlet`) checks `currentPassword` before anything is changed. If it doesn't match, the modal shows an inline error and nothing is written to the database — not even a `newPassword` that happens to be valid.
- [x] **Partial vs. full update:** Partial. Only fields the customer actually changed get written — see [Partial Update](#partial-update-only-changed-fields-get-written) below.
- [ ] **Email uniqueness on change:** If the user changes their email, does Back End check for duplicates? What error attribute and message does it set? (Same shape as Registration's duplicate-email check — see `Registration.md`'s Duplicate Email section — but needs its own decision here since this is an UPDATE against the customer's own existing row, not an INSERT.)
- [ ] **DAO method signature:** What does the update method look like? Needs to support "only these fields changed" — a full `Customer` object alone doesn't distinguish "left blank on purpose" from "not touched." Candidates: `updateCustomer(Connection, int customerId, Map<String,String> changedFields)`, or a partial-update Bean with nullable wrapper types, or one method per field. Team decides.
- [x] **All-or-nothing on validation:** If even one changed field fails validation, the **entire update is aborted** — no partial write. See [Validate Everything First](#validate-everything-first-then-write-nothing-or-write-everything) below.
- [ ] **Forgot-password / lockout-recovery flow:** See [Password Change and the Lockout Model](#password-change-and-the-lockout-model) below. This would replace or supplement the Login page's existing "Unlock Account" button (`CustomerDAO.unlockAccount()`, plain reset, no password involved) with a verification-code-based password reset — a real change to the Login model as it exists, not just new work on this page. Needs Miguel + Robert sign-off before building.
- [x] **Session refresh after update:** After a successful update, Back End must replace the Customer Bean in the session with the new values — otherwise the header greeting, and any other page reading `sessionScope.customer`, shows stale data until the next login.
- [ ] **Success/error response:** After saving, does Back End forward back to the same JSP with a success/error attribute, or redirect? What attribute names carry the messages?
- [ ] **Servlet URL mapping:** What URL does the profile-fields form POST to? What URL does the password-change modal POST to (same servlet with an `action` param, or its own servlet)? What URL is the GET for loading the page?

---

### Which Fields Are Editable

Every column on the `Customer` table (`databasescripts/MoffatBayMarinaDB_V1-4-0.sql`), whether the customer should be able to change it here, and why. Proposed defaults below — **the team still needs to check these off**, not treat them as decided.

| Column | Editable? | Notes |
| --- | --- | --- |
| `customerID` | No | Primary key. Never Not Rendered on this table, Not editable. |
| `firstName` | Yes | Same field as Registration. |
| `lastName` | Yes | Same field as Registration. |
| `email` | Needs discussion | It's both the contact address and the login username, and it's `UNIQUE` on the table. Editable is reasonable, but changing it needs the same duplicate-email check Registration has, and arguably a "type it twice" confirmation like the password fields get, since a typo here can lock someone out of their own account. Team should explicitly decide yes/no rather than default it in. |
| `passwordHash` | [ ] No, not directly | Never rendered, never taken from this form's fields. Only changes through the [Password Change (Popup Modal)](#password-change-popup-modal) flow, which is a separate `currentPassword`/`newPassword`/`confirmNewPassword` exchange, not a value typed into a "new password" box sitting on the main form.|
| `phone` | [ ] Yes | Same formatting/validation as Registration's Phone field. |
| `phoneCountryCode` | [ ] Yes | Travels with `phone`, same as Registration. |
| `streetAddress` | [ ] Yes | |
| `streetAddress2` | [ ] Yes | Optional, same as Registration. |
| `city` | [ ] Yes | |
| `state` | [ ] Yes | Follows `country`'s option list/label, same as Registration. |
| `zipCode` | [ ] Yes | |
| `country` | [ ] Yes | Changing this should also re-drive the State/Province field's option list and label client-side, same swap `registration.js` already does. |
| `dateJoined` | [ ] No | Historical fact about the account, not something a customer should be able to backdate or change. NotRendered |
| `failedLoginAttempts` | [ ] No | System-managed bookkeeping (`LoginServlet`/`CustomerDAO.recordFailedAttempt` / `resetFailedAttempts`), never customer-facing. |
| `accountLocked` | [ ] No | System-managed (`CustomerDAO.lockAccount` / `unlockAccount`), handled by the Login lockout flow, not this page — pending the [Password Change and the Lockout Model](#password-change-and-the-lockout-model) decision below, which could tie a forgot-password reset into unlocking the account. |

---

### Password Change (Popup Modal)

Password change is its **own popup modal**, not fields mixed in with the rest of the profile form — same pattern as the existing Login modal (`includes/loginModal.jsp` / `js/loginModal.js`, opened with `MoffatBay.loginModal.open()`). A new shared component, e.g. `includes/changePasswordModal.jsp` + `js/changePasswordModal.js` exposing `MoffatBay.changePasswordModal.open()`, gets built the same way, and Edit User Info includes it and adds a "Change Password" button that opens it. Being its own modal keeps a password change as one atomic action, separate from whatever else the customer is editing on the main form at the same time.

**Fields**, all `type="password"`:

- `currentPassword` — required. Verified against the account's existing hash via `CustomerDAO.verifyPassword()` before anything else happens. Wrong current password → inline error in the modal (e.g. "Current password is incorrect."), nothing changes, `newPassword` is not evaluated or discarded silently — the customer sees exactly why it didn't go through.
- `newPassword` — required. Same five rules as Registration's Password field (10+ characters, uppercase, lowercase, number, one of `! $ % * #`), checked live the same way: the modal includes `includes/passwordRules.jsp` and wires it up with `MoffatBay.passwordRules.check()`, reusing `formValidation.js`'s `PASSWORD_RULES` rather than duplicating the rule set a second time.
- `confirmNewPassword` — required client-side only, same as Registration's `confirmPassword`: checked live against `newPassword` for a match, never actually submitted to the server.

**Flow:** modal opens → customer fills in all three → client-side checks (rules met, confirm matches) same as Registration → submit → Back End verifies `currentPassword` first → if good, validates `newPassword` against the same rules server-side (never trust the client) → hashes it with `Utils.hashPassword()` (the same helper `RegisterServlet` already uses) → updates `Customer.passwordHash` → modal closes with a success message (reusing `includes/statusPopup.jsp`'s `MoffatBay.statusPopup.show("Password updated")`, matching how "Boat saved" already works on the Reservation page).

This is a fully separate request/response from the profile-fields form — a password change and an edit to, say, the phone number are two independent submissions, not one combined POST. Keeps the "abort everything if one field is bad" rule (below) scoped to the profile fields only; a bad current password doesn't have anything to do with whether the phone number update should go through, and vice versa.

#### Password Change and the Lockout Model

Should the password change, now that it exists, change how we handle the account lockout?

The standard way of doing this is sending an email with a verification code to authenticate that the user is who they say they are, then allowing them to change their password without needing to know the old one.  Since the emails are fake emails, there is no way to simulate this process, but we could have a modified modal that pops up with a message that exaplains that the user would normally be required to read an email with a verification code, and have an entry box where they have to enter a fake code that "Only an idiot would have on their luggage" `12345` to simulate getting a code in their email to verify.

This exact modal could be used with a "forgot password" option on the login screen as well to update the password if the user "forgets" it.

This takes extra work, and therefore Miguel and Robert need to agree on it before implimenting it, and it would requires seperate tests, with Miguel testing that the front end looks right and properly shows that the password model shows that a correct password is enetered and the second box matches, and Robert needs to show that the password testing on the back end actually changed by logging in with the new password and showing that the old password is invalid.

Worth being explicit about the scope of "yes" here: adopting this changes the Login page's lockout model as it exists today, not just this page. Login currently has a demo "Unlock Account" button (plain reset, no password involved, no verification step — see `marinawebsite/documentation/Page Contracts/Login.md`) that this would presumably replace or sit alongside. It also means building **two** similar-but-not-identical popup modals: the Change Password modal above (`currentPassword` + `newPassword` + `confirmNewPassword`) and this forgot-password modal (fake verification code + `newPassword` + `confirmNewPassword`, no `currentPassword` since the whole point is the user doesn't have it). Not updating `Login.md` yet — that's follow-up work if/when the team actually signs off on this.

---

### Partial Update: Only Changed Fields Get Written

The customer might only be changing their phone number — the UPDATE statement shouldn't touch `firstName`, `email`, or anything else just because the form technically has a box for it. Back End needs a way to tell "the customer left this field showing what it already was" apart from "the customer is deliberately blanking this out" (relevant for the optional fields like `streetAddress2`). Two ways to get there, team decides which:

1. **Diff against the loaded Customer.** Front End always submits every field (simplest form), and the servlet compares each submitted value against the Customer Bean it loaded for the GET, building the SET clause only from fields that actually differ. Simple to build, but doesn't distinguish "customer retyped their existing phone number unchanged" from "customer never touched the phone field" — both look identical to a diff. Probably fine, since the end result is the same value either way, but worth naming as a limitation.
2. **Front End only submits touched fields.** JavaScript tracks which inputs the customer actually interacted with (a `change` listener setting a `data-touched` flag, or simply: fields that differ from their pre-filled value at submit time) and the form only includes those in the POST body. The servlet then only has parameters for what's changing at all — nothing to diff, `request.getParameter("x") == null` already means "not changing x." Slightly more JS, but the server-side logic gets simpler and the two "unwitting no-op" cases above are no longer conflated.

Either way, the UPDATE statement itself needs to be built dynamically (which columns are in the `SET` clause depends on what changed), not a single fixed `UPDATE Customer SET firstName=?, lastName=?, ... WHERE customerID=?` that always touches every column.

This would include if the customer accidently puts a space or other whitespace in the fiels accidently, and needs to verify that the information in makes sense.

The front End should also have some sort of confirmation step, showing the user the exact changed that are being made:  
- Column: Old value -> New value

So if the user accidently puts a "s" in the "First Name" box, they have a visual confirmation box that shows they are changing their first name to "s" before they submit and are not surprised later.

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

## Database Returns

Every query or DAO method the Back End calls for this page, and its exact return shape — including what it returns on "no match" (null vs. empty object vs. exception).

| Method / Query | Parameters In | Returns | Notes |
| --- | --- | --- | --- |
| `CustomerDAO.verifyPassword()` | `String email`, `String submittedHash` | `boolean` | Already exists, reused from Login, for the "current password" check in the password modal |
| `CustomerDAO.findByEmail()` | `String email` | `Customer` or `null` | Already exists; reusable for a duplicate-email check if `email` ends up editable |
| *(new)* `CustomerDAO.updateCustomer()` | `Connection`, `int customerId`, changed fields only | Not yet decided — `boolean` success, updated `Customer`, or `void` with exception on failure | See [DAO method signature](#back-end-owns) open question above |
| *(new)* `CustomerDAO.updatePassword()` | `Connection` (or none), `int customerId`, `String newHash` | Not yet decided | Separate from `updateCustomer()` since it's a completely separate submission, see [Password Change (Popup Modal)](#password-change-popup-modal) |

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
| Email changed to one already in use (if email ends up editable) | TBD — same open question as Registration's duplicate-email handling | TBD |
| Update succeeds | TBD — success banner, popup (`MoffatBay.statusPopup.show(...)`), or something else | TBD |

## Login State Differences

| Item | Logged In | Logged Out |
| --- | --- | --- |
| Edit user information | Available to the signed-in user | Not reachable while logged out |
