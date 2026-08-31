# Page Contract: Registration

## Page Name

Registration

## Module / Week

Module 5 / Week 4 (Aug 31 – Sep 6, 2026)

## Assigned

- Front End: Robert
- Back End: Carolina
- Testing:

## Open Questions / Decisions Needed

### Front End Owns

- [x] **Form field `name` attributes:** Decided, see [What the Form Collects](#what-the-form-collects) below.
- [x] **Confirm-password handling:** Checked client-side only. See [Confirm Password](#confirm-password) below.
- [x] **Input length limits (HTML side):** Set, see the table below. Matched against the Customer and Boat columns from Module 3/4.
- [x] **Address field shape:** Decided, splitting into four separate fields instead of one box. See [The Address Field](#the-address-field) below.
- [x] **Boat registration fields:** Decided, adding every column the Boat table has, not just Boat Name and Boat Length. See [Boat Fields](#boat-fields) below.

---

### What the Form Collects

The Module 2 wireframe (`Module-2/Finalized WireFrames/Registration Page.pdf`) is the starting point, but the address and boat fields below go beyond what's on that mockup, see [The Address Field](#the-address-field) and [Boat Fields](#boat-fields) for why. The form ends up collecting:

- First Name
- Last Name
- E-mail
- Phone
- Street Address (Optional)
- City (Optional)
- State (Optional)
- Zip Code (Optional)
- Boat Name
- Registration State
- Registration Number
- Boat Length
- Hull ID Number / HIN (Optional)
- Boat Type (Optional)
- Boat Beam (Optional)
- Boat Year (Optional)
- Password
- Re-type Password
- a Submit button

Field names I'm using, matched to what they map to later: `firstName`, `lastName`, `email`, `phone`, `streetAddress`, `city`, `state`, `zipCode`, `boatName`, `regState`, `regNumber`, `boatLength`, `hin`, `boatType`, `boatBeam`, `boatYear`, `password`, `confirmPassword`.

### Password Rules

The wireframe spells out the password rule right on the page: at least 10 characters, one uppercase letter, one lowercase letter, one number, and one special character from `! $ % * #`. As the user types, the page checks the password against these rules live and shows whichever specific rule isn't met yet right under the field (the mockup shows "Password must contain at least one uppercase letter" as an example). This is all client-side JavaScript, just for the user's benefit while typing. The back end still has to enforce the same rule when the password actually gets submitted, since a request can always skip the browser entirely.

### Confirm Password

The "Re-type Password" field only exists to catch typos before the user submits. I'm checking client-side that it matches the password field, live, the same way the password rules get checked. Once it matches, the form's good to submit.

The confirm password value itself never gets sent to the back end. There's nothing useful for the server to do with a second copy of the same password once the browser's already confirmed they match, so only `password` goes in the POST.

### The Address Field

The wireframe has one "Address (Optional)" text box, but the Customer table needs `streetAddress`, `city`, `state`, and `zipCode` as separate columns. Rather than have the back end try to parse one free-text box into four pieces, the form is splitting it into four separate fields up front: Street Address, City, State, and Zip Code. All four stay optional, matching both the wireframe's "(Optional)" tag and the fact that none of those columns are required on the Customer table.

### Boat Fields

The wireframe only asked for Boat Name and Boat Length, but the Boat table has more columns than that, and some of them are required to insert a row at all. So the form is collecting every column the Boat table has, not just the two from the original mockup:

- **Boat Name, Registration State, Registration Number, and Boat Length are required.** The Boat table won't accept a row without them.
- **HIN (Hull ID Number), Boat Type, Boat Beam, and Boat Year are all optional.** The table allows them to be blank. HIN in particular is allowed to be blank on purpose, older boats built before 1972 aren't required to have one.

One more thing worth flagging to Carolina: Registration State and Registration Number together have to be unique on the Boat table (no two boats can share the same registration in the same state), so that's a possible error case on submit that isn't just "this field is blank."

### Duplicate Email

Email has to be unique on the Customer table, so submitting with an email that's already registered has to fail. The front end has no way to know ahead of time what emails are taken, it can't catch this one live like the password fields, so this depends entirely on the back end actually checking for it and telling the front end it happened. Carolina needs a function on her end that checks the email against existing accounts (either a lookup before the INSERT, or catching the database's unique constraint if the INSERT is attempted anyway) and reports back specifically that it was a duplicate email, not some other failure.

Once that signal exists, the front end shows it as a popup once the response comes back, rather than the live inline style used for the password fields, since it's only knowable after submit. Back End still owns the exact attribute name and wording that trigger it, see the open checklist item above.

Since a duplicate email almost always means the person already has an account, the popup also offers to log in instead of just closing. It includes a button that opens the Login modal (per the [Login contract](login-contract.md)) with its `redirectTo` field set to the landing page, so once they actually log in, they land on the homepage instead of getting sent back to a half-filled-out registration form.

### Back End Owns

- [ ] **Password hashing:** Back End hashes before INSERT — same algorithm as Login's comparison. Confirm they match.
- [ ] **Customer table column mapping:** Which `customers` table columns does each form field map to? The INSERT statement and Bean must match the schema from Module 3/4.
- [ ] **DAO method signature:** What does the registration method look like? (e.g., `registerCustomer(Customer c)` returning what — new customer ID, boolean, the full Bean?) Front End needs to know what's available after success.
- [ ] **Duplicate email response:** Needs a function that actually checks the submitted email against existing accounts and reports back specifically that it was a duplicate, see [Duplicate Email](#duplicate-email) above. Once that exists, what request attribute name and message does it set so Front End knows to show the popup?
- [ ] **Auto-login after registration:** After a successful INSERT, does Back End set session attributes (same as Login contract) so the user is immediately logged in, or redirect to the login modal?
- [ ] **Post-registration redirect/forward:** Where does Back End send the response — forward to the same JSP with a success attribute, redirect to landing, or something else? What attribute names carry the success state?
- [ ] **Input length limits (DB/server side):** Max lengths for each field must match the database column sizes and the HTML `maxlength` — coordinate with Front End.
- [ ] **Servlet URL mapping:** What URL does the registration form POST to? (e.g., `/register`)

## Front End Variables

Every field or control the page's UI sends to the Back End (form fields, query-string params on a lookup page, etc.).

| Field Name | Input Type | Required? | Format / Notes |
| --- | --- | --- | --- |
| `firstName` | text | Yes | `maxlength="50"`, matches `Customer.firstName` |
| `lastName` | text | Yes | `maxlength="50"`, matches `Customer.lastName` |
| `email` | email | Yes | `maxlength="100"`, matches `Customer.email`; also gets checked client-side for a valid email shape |
| `phone` | tel | Yes on the wireframe (not marked optional like Address is) | `maxlength="20"`, matches `Customer.phone` |
| `streetAddress` | text | **No, Optional** | `maxlength="100"`, matches `Customer.streetAddress`, see [The Address Field](#the-address-field) above |
| `city` | text | **No, Optional** | `maxlength="50"`, matches `Customer.city` |
| `state` | text | **No, Optional** | `maxlength="2"`, matches `Customer.state` (2-letter code) |
| `zipCode` | text | **No, Optional** | `maxlength="10"`, matches `Customer.zipCode` (allows the 5+4 format) |
| `boatName` | text | Yes | `maxlength="50"`, matches `Boat.boatName` (NOT NULL on that table) |
| `regState` | text | Yes | `maxlength="2"`, matches `Boat.regState` (NOT NULL, 2-letter code) |
| `regNumber` | text | Yes | `maxlength="20"`, matches `Boat.regNumber` (NOT NULL); combined with `regState` this has to be unique, see [Boat Fields](#boat-fields) above |
| `boatLength` | number | Yes | Matches `Boat.boatLength`, a decimal up to 999.9 feet, one decimal place |
| `hin` | text | **No, Optional** | `maxlength="12"`, matches `Boat.HIN`; blank is expected for pre-1972 boats |
| `boatType` | text | **No, Optional** | `maxlength="30"`, matches `Boat.boatType` (e.g. sailboat, powerboat, catamaran) |
| `boatBeam` | number | **No, Optional** | Matches `Boat.boatBeam`, a decimal up to 999.9 feet, one decimal place |
| `boatYear` | number | **No, Optional** | Matches `Boat.boatYear`, a whole number model year |
| `password` | password | Yes | 10+ characters, needs an uppercase letter, a lowercase letter, a number, and one of `! $ % * #`. Checked live as the user types |
| `confirmPassword` | password | Yes, client-side only | Never submitted, see [Confirm Password](#confirm-password) above |

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

- **Client-side (UX only, not trusted):** First name, last name, email, phone, boat name, registration state, registration number, and boat length are all required before the form lets you submit. Everything else (street address, city, state, zip, HIN, boat type, boat beam, boat year) is optional. Email gets checked for a valid shape. Password gets checked live against all five rules above (length, uppercase, lowercase, number, special character). Re-type Password gets checked live against the password field for a match.
- **Server-side (source of truth):** TBD, this is Carolina's call. Whatever she lands on has to enforce the same rules as above, since none of the client-side checks can be trusted on their own.

## Error Handling

Every user-facing error condition this page can hit, and exactly what the user sees.

| Condition | Message Shown | Where Displayed |
| --- | --- | --- |
| Password missing one of the five rules while typing | "Password must contain at least [whichever rule isn't met yet]." (e.g. "Password must contain at least one uppercase letter") | Directly under the Password field, live as the user types |
| Re-type Password doesn't match Password | "Passwords do not match." | Directly under the Re-type Password field, live as the user types |
| A required field is left blank on submit | Browser's default "please fill out this field" prompt (native HTML `required` validation) | Next to the empty field |
| Email already registered (caught by Back End on submit, not something Front End can check ahead of time) | Popup: something like "An account with this email already exists." Exact wording is Back End's call, see [Duplicate Email](#duplicate-email) above. Popup also includes a "Log In" button | Popup, shown once the submit response comes back. "Log In" opens the Login modal with `redirectTo` set to the landing page, so a successful login lands there |
