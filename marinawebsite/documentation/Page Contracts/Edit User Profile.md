# Page Contract: Edit User Info

## Page Name

Edit User Info. Visitors see it as **Your Account** (the page title, the hero, and the Welcome menu link); the files keep the original name (`editUserInfo.jsp`, `editUserInfo.js`, `EditProfileServlet`).

## Module / Week

Module 8 / Week 6 (Sep 14 – Sep 20, 2026)

## Assigned

- Front End: Miguel
- Back End: Robert

## Current Status (2026-10-10)

**Built and tested, Front End and Back End.** Reached at `/editProfile` from **Your Account** in the header's Welcome menu. The page:

- edits the customer's own details (the same Personal Information card Registration uses, plus Email), saving only what changed, after an old → new confirmation popup;
- changes the password (Change Password popup) or resets it (Forgot Password popup);
- links to **My Fleet**, where boats are registered, edited and removed;
- downloads everything the marina holds about the customer, or deletes the account (issue #337).

## Decisions

### Front End Owns

- [x] **Form field `name` attributes:** The same names as Registration, since the page includes the same `WEB-INF/includes/personalInfoCard.jsp`: `firstName`, `lastName`, `phoneCountryCode`, `phone`, `country`, `streetAddress`, `streetAddress2`, `city`, `state`, `zipCode`, plus this page's own `email`.
- [x] **Which fields are editable?** See [Which Fields Are Editable](#which-fields-are-editable).
- [x] **How the current information is shown:** Every field opens **already filled in** with the value on file (the card's `default*` params, from `sessionScope.customer`). **Save changes** stays disabled, with "Nothing changed yet." under it, until a field actually differs from what's on file. Clicking it opens the old → new confirmation, so "I didn't touch this" and "I want this blank" can't be confused.
- [x] **Password change:** its own popup, not fields on the main form. See [Change Password](#change-password).
- [x] **Forgot password / lockout recovery:** a second popup, the same shape without the current password. See [Forgot Password and the Lockout Model](#forgot-password-and-the-lockout-model).
- [x] **Read-only facts:** **Member since** shows `dateJoined` as a disabled field ("Sep 15, 2026"). It isn't editable, but it's the one account fact a customer might want to look up.

### Back End Owns

- [x] **Pre-populated data source:** The JSP reads `sessionScope.customer` directly — no request attribute, no extra DB read. `CustomerSession.start()` puts it in the session, and it's kept current by the session refresh rule below.
- [x] **Partial vs. full update:** Partial. Only fields the customer actually changed get written — see [Partial Update](#partial-update-only-changed-fields-get-written).
- [x] **Customer field validation:** `util/CustomerValidator`, shared with Registration (#284), so both pages accept the same values and word each mistake the same way.
- [x] **Email uniqueness on change:** `CustomerDAO.emailInUseByAnotherCustomer(conn, email, customerId)` — deliberately not `findByEmail()`, which can't exempt the customer's own row. Checked inside the same transaction as the write.
- [x] **DAO method signature:** `CustomerDAO.updateCustomer(Connection conn, int customerId, Map<String, String> changedFields)`. A key absent from the map means untouched; a key present with an empty value means "clear it" (binds SQL `NULL`), legal only for optional columns.
- [x] **All-or-nothing on validation:** If even one changed field fails, nothing is written. See [Validate Everything First](#validate-everything-first-then-write-nothing-or-write-everything).
- [x] **Session refresh after update:** After a save, the servlet reloads the customer with `CustomerDAO.findById()` and replaces both `customer` and `displayName` in the session, so the header greeting and every page reading `sessionScope.customer` show the new values at once.
- [x] **Success/error response:** A validation failure forwards back to `editUserInfo.jsp` with `formError` ("Please fix the highlighted fields below.") and `fieldErrors`, so the typed values stay. A success **redirects** to `/editProfile?notice=profileUpdated`, so a refresh can't re-apply the update, and the status popup says "Profile updated". **Amended 2026-09-24:** the old → new list is shown **before** saving, in a confirmation popup, not after.
- [x] **Servlet URL mapping:** one URL per action, one servlet each:

  | URL | Method | Servlet | Does |
  | --- | --- | --- | --- |
  | `/editProfile` | GET, POST | `EditProfileServlet` | Shows the page; saves the profile fields |
  | `/editProfile/password` | POST | `EditProfilePasswordServlet` | Changes the password; answers JSON |
  | `/forgotPassword` | POST | `ForgotPasswordServlet` | Resets the password and clears a lockout |
  | `/editProfile/data` | GET | `AccountDataServlet` | Downloads the customer's data as JSON |
  | `/editProfile/delete` | POST | `AccountDeleteServlet` | Deletes the account |

---

### Which Fields Are Editable

Every column on the `Customer` table (`databasescripts/MoffatBayMarinaDB_V1-10-0.sql`), whether the customer can change it here, and why.

| Column | Editable? | Notes |
| --- | --- | --- |
| `customerID` | No | Primary key. Never rendered; always taken from the session. |
| `firstName` | Yes | Required. |
| `lastName` | Yes | Required. |
| `email` | Yes | Required. Both the contact address and the sign-in name ("This is also how you sign in."), `UNIQUE` on the table. Duplicate-checked on change, excluding the customer's own row. |
| `passwordHash` | No, not directly | Never rendered, never taken from this form. Changes only through [Change Password](#change-password) or the [forgot-password reset](#forgot-password-and-the-lockout-model). |
| `phone` | Yes | Required. Same formatting as Registration. |
| `phoneCountryCode` | Yes | Required. Travels with `phone`. |
| `streetAddress` | Yes | Required — a blank submission is refused, not treated as "clear." |
| `streetAddress2` | Yes | Optional — an explicitly blank submission clears it to `NULL`. |
| `city` | Yes | Required. |
| `state` | Yes | Required unless country is `OTHER`. Follows `country`'s option list and label, same as Registration. |
| `zipCode` | Yes | Required. |
| `country` | Yes | Required. Re-drives the State/Province field client-side, the same `MoffatBay.form.applyCountryToRegion` Registration uses. |
| `dateJoined` | No | Shown read-only as **Member since**. |
| `failedLoginAttempts` | No | System-managed. Cleared as a side effect of `resetPasswordAndUnlock()`. |
| `accountLocked` | No | System-managed. Cleared only by a successful [forgot-password reset](#forgot-password-and-the-lockout-model). |

---

### Boats — My Fleet

Boats aren't edited here. The **Your boats** section says "Registering, editing and selling boats all live together on My Fleet." and links there with a **My Fleet** button. See the My Fleet contract.

---

### Change Password

A popup (`WEB-INF/includes/changePasswordModal.jsp`, "Change your password"), opened by the **Change password** button. Separate from the profile form, so a password change and a phone number edit are two independent submissions, and a wrong current password has nothing to do with whether the phone number saves.

**Fields**, all `type="password"`:

- `currentPassword` — required. Checked with `CustomerDAO.verifyPassword(customerId, hash)` before anything else happens.
- `newPassword` — required. The same five rules as Registration, ticked off live in the popup's own checklist (keyed on `data-rule`, so it can't collide with another checklist's ids). Carries `pattern`, `minlength` and `passwordrules` so password managers suggest a valid one.
- `confirmNewPassword` — checked live against `newPassword`; has no `name`, so it is never sent.

**Flow:** the popup sends the form with `fetch` (the page never navigates) → `EditProfilePasswordServlet` checks the session, then `currentPassword`, then the rules on `newPassword` → hashes it with `Utils.hashPassword()` → `CustomerDAO.updatePassword()` → answers `{"ok":true}`. The popup closes and the status popup says "Password updated". Any other browser signed in to the account is signed out (`CustomerSession.endOtherSessions`); this one stays signed in. On failure it answers `{"ok":false,"error":"..."}` and the message shows in the popup's banner.

#### Forgot Password and the Lockout Model

A locked account (three wrong passwords in a row, see the Login contract) unlocks only by completing a password reset. A real site would email a verification code; this project has no mail server, so the code is simulated: `12345`, and the popup says so ("Demo site - the code is 12345.").

The popup is `WEB-INF/includes/forgotPasswordModal.jsp`, included by the login modal so it's on every page — a locked-out customer can't sign in, so a reset reachable only from this page would sit behind the very sign-in they can't complete. Three things open it:

- **Forgot your current password?** on this page, pre-filled with the Email field's value.
- **Forgot password?** under the login modal's Password field, pre-filled with whatever was typed there.
- **Reset your password** in the login modal's locked-out state, pre-filled with the address that was just locked.

`ForgotPasswordServlet` (`/forgotPassword`) identifies the account by **email**, not the session, so it works for a signed-out visitor and on a different device later. An unregistered email, a deleted account, and a wrong code all get the same message, the same anti-enumeration rule Login uses, so a submission can never reveal which emails are registered. On success, `CustomerDAO.resetPasswordAndUnlock()` changes the password and clears both `accountLocked` and `failedLoginAttempts` in one transaction, every signed-in session for the account is ended, and the customer is redirected back to the page they were on with `notice=passwordReset` ("Password reset — sign in with your new password"). There is no automatic sign-in. A failure redirects back too, with the message in the session for one read, and the popup reopens with it.

---

### Partial Update: Only Changed Fields Get Written

**Decided: the front end only submits touched fields.** `js/editTracker.js` (shared with My Fleet's Edit, #285) records what each field held when the page loaded, and on submit posts only the fields whose value now differs. Email, state and country are compared ignoring case, the way the servlet normalizes them. The servlet then reads a key's absence as "not changing it":

- A changed field is sent with its new value.
- A changed **optional** field the customer blanked (`streetAddress2`) is sent as an explicit empty value, meaning "set it to `NULL`."
- A **required** field must never arrive empty. If one does, something upstream is broken, so the servlet refuses the whole request with "That request could not be processed. Please reload the page and try again." in the banner, rather than a per-field message.
- **State and country `OTHER`:** the State dropdown is disabled for `OTHER`, and a disabled field submits nothing. So whenever `country` is actively changed to `OTHER`, the servlet clears `state` along with it, whether or not the form sent one.

The servlet also compares each submitted value with the one on file, so a field retyped unchanged isn't written. The `UPDATE` is built from the changed fields only, with column names from a fixed whitelist in `CustomerDAO`, never from the submitted keys.

**Confirmation (amended 2026-09-24):** **Save changes** opens a **"Save these changes?"** popup (the shared `.modal`) listing each changed field as old → new, "Only these fields will be saved. Everything else stays as it is.", with **Keep Editing** and **Save Changes**. Only Save Changes submits. This is the site-wide rule: confirm what **will** change in a popup before saving, then a toast after.

### Validate Everything First, Then Write Nothing or Write Everything

If even one changed field fails validation, the whole update is refused — none of the other, valid changes are written. Every changed field is validated first and every failure collected, so the customer sees all of them at once; only a clean pass touches the database, inside a transaction (`setAutoCommit(false)`, rolled back on any problem).

---

### Your Data (issue #337)

- **Download my data** — a plain link to `/editProfile/data`. `AccountDataServlet` answers with a file, `moffat-bay-marina-my-data.json`: `exportedOn`, `from`, and the customer's `account`, `boats`, `reservations`, `waitList` and `contactMessages` (contact-form messages sent from their current email address). The page stays put.
- **Delete my account** — opens a "Delete your account?" popup that says what happens ("This can't be undone." Personal details removed; boats leave the fleet and wait list entries close; past reservations kept for the marina's records without the name; not possible with a current or upcoming reservation). Focus starts on the password box, since typing the password is the confirmation; **Keep My Account** and a red **Yes, Delete My Account**. It posts the password as `currentPassword` to `/editProfile/delete`. `AccountDeleteServlet` checks the password, then, inside one transaction, refuses if any lease isn't over, closes the customer's open wait list entries, ends every boat ownership, and anonymises the Customer row (`CustomerDAO.anonymise()`). Every session for the account is ended, and the customer lands on `/?notice=accountDeleted` ("Your account has been deleted"). A refusal re-renders the page with `deleteError`, and the popup reopens with the reason in its banner.

## Scaffold Include

```jsp
<jsp:include page="/WEB-INF/includes/header.jsp">
    <jsp:param name="activePage" value="editprofile" />
</jsp:include>

<!-- Your Account page content -->

<jsp:include page="/WEB-INF/includes/footer.jsp" />
```

> The `activePage` value `"editprofile"` highlights **Your Account** in the Welcome menu. See the Shared Header/Footer contract for the full table.

## Front End Variables

| Field Name | Input Type | Required? | Format / Notes |
| --- | --- | --- | --- |
| `firstName` | text | Only if changed | Matches `Customer.firstName` (50) |
| `lastName` | text | Only if changed | Matches `Customer.lastName` (50) |
| `email` | email | Only if changed | `maxlength="100"` |
| `phoneCountryCode` | text | Only if changed | Same format as Registration |
| `phone` | hidden (formatted display shown separately) | Only if changed | Exactly 10 raw digits, see the Registration contract's Phone Number section |
| `streetAddress` | text | Only if changed | Matches `Customer.streetAddress` (100) |
| `streetAddress2` | text | Only if changed | Optional even when changed; blank clears it |
| `city` | text | Only if changed | Matches `Customer.city` (50) |
| `state` | select | Only if changed | Follows `country`, same as Registration |
| `zipCode` | text | Only if changed | `maxlength="10"` |
| `country` | select | Only if changed | `US` / `CA` / `OTHER` |
| `currentPassword` | password | Yes, Change Password popup | Never pre-filled |
| `newPassword` | password | Yes, Change Password popup | Same five rules as Registration |
| `confirmNewPassword` | password | Yes, client-side only | No `name`; never submitted |
| `email` (Forgot Password popup) | email | Yes | Identifies the account. Pre-filled when known |
| `verificationCode` | text | Yes | The simulated code, `12345` |
| `newPassword` (Forgot Password popup) | password | Yes | Same five rules |
| `redirectTo` (Forgot Password popup) | hidden | No | The page to return to, context-relative |
| `currentPassword` (Delete popup) | password | Yes | Confirms the deletion |

## Back End Parameters

| Parameter Name | Type | Source (form field / session / query string) | Notes |
| --- | --- | --- | --- |
| `customerId` | `int` | Session (`sessionScope.customerId`) | Never taken from a form — always the signed-in customer, so nobody can edit someone else's row by tampering with a hidden field |
| `firstName` … `country` | `String` | Form fields, present only if changed | Trimmed; checked by `CustomerValidator`; `email` lowercased, `state` and `country` uppercased before saving |
| `currentPassword` | `String` | Form field (Change Password, Delete) | Verified with `CustomerDAO.verifyPassword(customerId, hash)` before anything else |
| `newPassword` | `String` | Form field (Change Password, Forgot Password) | Must match `Utils.PASSWORD_PATTERN`; then hashed |
| `email` (Forgot Password) | `String` | Form field | Trimmed and lowercased; looked up with `CustomerDAO.findByEmail()` |
| `verificationCode` | `String` | Form field (Forgot Password) | Must equal `12345` |
| `redirectTo` (Forgot Password) | `String` | Form field (hidden) | Passed through `Utils.safeRedirectTarget` |
| `notice` | `String` | Query string | `profileUpdated` after a save |

## Database Returns

| Method / Query | Parameters In | Returns | Notes |
| --- | --- | --- | --- |
| `CustomerDAO.updateCustomer()` | `Connection`, `int customerId`, `Map<String, String> changedFields` | `void`, throws `SQLException` (caller rolls back) | Column names from a fixed whitelist |
| `CustomerDAO.emailInUseByAnotherCustomer()` | `Connection`, `String email`, `int customerId` | `boolean` | Excludes the customer's own row; only when `email` changed |
| `CustomerDAO.findById()` | `Connection`, `int customerId` | `Customer` or `null` | Session refresh after a save, so it never depends on an email that may have just changed |
| `CustomerDAO.verifyPassword()` | `int customerId`, `String submittedHash` | `boolean` | Change Password and Delete. (Login uses the `String email` overload) |
| `CustomerDAO.updatePassword()` | `Connection`, `int customerId`, `String newHash` | `void`, throws `SQLException` | Change Password only; never touches lockout state |
| `CustomerDAO.findByEmail()` | `String email` | `Customer` or `null` | Forgot Password's account lookup |
| `CustomerDAO.resetPasswordAndUnlock()` | `Connection`, `int customerId`, `String newHash` | `void`, throws `SQLException` | Forgot Password only. Clears `accountLocked` and `failedLoginAttempts` with the password |
| `AccountDataDAO.account()` / `boats()` / `reservations()` / `waitList()` / `contactMessages()` | `Connection`, `int customerId` | `List<Map<String, Object>>` | One per section of the download; empty list when there's nothing |
| `ReservationDAO.hasLeaseNotOver()` | `Connection`, `int customerId` | `boolean` | Delete refuses when `true` |
| `WaitListDAO.cancelOpenEntriesForCustomer()` | `Connection`, `int customerId` | `int` rows changed | Delete |
| `BoatDAO.endAllOwnerships()` | `Connection`, `int customerId` | `int` rows changed | Delete |
| `CustomerDAO.anonymise()` | `Connection`, `int customerId` | `void` | Delete. Removes personal details but keeps the row, so past reservations still point at it |

## Validation Rules

- **Client-side (UX only, not trusted):** On save, `editUserInfo.js` checks the changed fields: a required field can't be empty, the email has a valid shape, the phone has 10 digits, the country code and ZIP are valid, and a state is chosen when the country has states. Each message sits under its field. The Change Password popup live-checks the five rules and the confirm match; the Forgot Password popup checks the email shape, that a code was entered, and the same password rules.
- **Server-side (source of truth):** Every changed field gets `CustomerValidator`'s check. All changed fields are validated before any write; if any fails, nothing is saved. The Change Password popup's `currentPassword` is verified before `newPassword` is even looked at.

## Error Handling

| Condition | Message Shown | Where Displayed |
| --- | --- | --- |
| Nothing changed | "Nothing changed yet." Save stays disabled | Under the Save button |
| A changed field fails a client-side check | e.g. "This can't be empty.", "Enter a valid email address.", "Phone number must contain exactly 10 digits.", "Enter a valid ZIP code.", "Choose a state or province." | Under that field |
| One or more changed fields fail server-side | "Please fix the highlighted fields below." plus each field's own `CustomerValidator` message; nothing saved | Banner above the form, and under each failing field (`fieldErrors`; `zipCode`'s box is `#zipError`, inherited from Registration) |
| Email changed to one another account uses | "An account with this email already exists." | Under Email, with the banner |
| A required field submitted blank (JavaScript off, a stale page, or tampering) | "That request could not be processed. Please reload the page and try again." | Banner; nothing saved |
| Update succeeds | "Profile updated" | Status popup, via `?notice=profileUpdated` |
| Change Password: a field left blank | "Enter your current password." / "Enter a new password." | Under the field |
| Change Password: rules not met, or the two don't match | "Your password doesn't meet the rules below yet." / "Both passwords must match." | Under the field |
| Change Password: current password wrong | "Current password is incorrect." | Popup banner |
| Change Password: new password fails the server's rule check | "New password does not meet the required rules." | Popup banner |
| Change Password succeeds | "Password updated" | Status popup; the popup closes |
| Forgot Password: wrong code, unknown email, or deleted account | "That code doesn't match - check your email and try again." | Forgot Password popup banner |
| Forgot Password succeeds | "Password reset — sign in with your new password" | Status popup, on the page the customer was on |
| Delete: password blank | "Enter your password to delete your account." | Delete popup banner |
| Delete: password wrong | "That password is incorrect." | Delete popup banner |
| Delete: a lease isn't over | "You have a current or upcoming reservation. Cancel it, or give 30 days' notice, before deleting your account." | Delete popup banner |
| Delete succeeds | "Your account has been deleted" | Status popup on the landing page |
| Database failure | The site's error page | `error.jsp` |

## Login State Differences

| Item | Logged In | Logged Out |
| --- | --- | --- |
| Your Account page | The customer's own details, ready to edit | A GET shows the page with the shared sign-in panel ("Sign In to View Your Account", `WEB-INF/includes/signInPanel.jsp`, 401) in place of the form. A save, download or delete after the session timed out redirects back to `/editProfile`, which shows the same panel. Signing in lands back on `/editProfile` (**changed 2026-10-02, #257**). `CustomerSession.showSignInPanel` / `sendToSignIn` |
| Change Password popup | Available | Not on the page. A POST without a session gets "Please sign in before changing your password." |
| Forgot Password popup | Available | Available, from the login modal |
