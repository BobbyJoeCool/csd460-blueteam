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
- Country Code (defaults to 1)
- Phone
- Street Address (Optional)
- Address Line 2 (Optional, apartment/suite/PO box)
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

Field names I'm using, matched to what they map to later: `firstName`, `lastName`, `email`, `phoneCountryCode`, `phone`, `streetAddress`, `streetAddress2`, `city`, `state`, `zipCode`, `boatName`, `regState`, `regNumber`, `boatLength`, `hin`, `boatType`, `boatBeam`, `boatYear`, `password`, `confirmPassword`.

### Password Rules

The wireframe spells out the password rule right on the page: at least 10 characters, one uppercase letter, one lowercase letter, one number, and one special character from `! $ % * #`. As the user types, the page checks the password against these rules live and shows whichever specific rule isn't met yet right under the field (the mockup shows "Password must contain at least one uppercase letter" as an example). This is all client-side JavaScript, just for the user's benefit while typing. The back end still has to enforce the same rule when the password actually gets submitted, since a request can always skip the browser entirely.

### Confirm Password

The `confirmPassword` field is checked client-side to give the user immediate feedback and is also submitted to the Back End. `RegisterServlet` verifies that it matches `password`. The confirmation value is used only for validation and is never stored in the database.

### Phone Number

The visible Phone box always shows the number formatted as `(###)-###-####` no matter how it's typed in, pasted, with dashes, dots, spaces, parens, or none of that, since a little JavaScript strips everything down to digits on every keystroke and rebuilds the display from those digits. Only digits ever matter; anything else typed just gets thrown away.

What actually gets submitted isn't that visible field though. The formatted text is just for the user to look at. Underneath it there's a hidden field, still named `phone`, that always holds just the raw 10 digits, no parens or dashes, kept in sync with the visible one on every keystroke. So Back End always gets a clean 10-digit `phone`, never has to deal with parsing out a formatted string.

Country Code is a separate small box in front of Phone, defaulting to `1`, since that's not really part of the 10-digit number itself. Comes across as its own `phoneCountryCode` field, not bundled into `phone`.

The 10-digit `phone` value fits fine in the existing `Customer.phone` column. `phoneCountryCode` now has its own column too — `Customer.phoneCountryCode VARCHAR(3) NOT NULL DEFAULT '1'`, added in `MoffatBayMarinaDB_V1-1-0_update.sql`.

### The Address Field

The wireframe has one "Address (Optional)" text box, but the Customer table needs `streetAddress`, `city`, `state`, and `zipCode` as separate columns. Rather than have the back end try to parse one free-text box into four pieces, the form is splitting it into four separate fields up front: Street Address, City, State, and Zip Code. All four stay optional, matching both the wireframe's "(Optional)" tag and the fact that none of those columns are required on the Customer table.

There's also a second line under Street Address (`streetAddress2`) for apartment number, suite, PO box, that kind of thing, since that's a standard part of any address form and the single Street Address box shouldn't have to carry both. This one doesn't have a column on the Customer table yet at all, not even a single combined one, so it needs a new `streetAddress2` column added alongside the schema change already flagged above. Always optional.

**Update, built form deviates from this section:** `registration.jsp` as built marks Street Address, City, State, and Zip Code `required` — only `streetAddress2` is actually optional. That's a change from "(Optional)" on the Module 2 wireframe and from what this section originally said; flagging it here since it wasn't a documented decision. Confirm with the team whether that's intentional before Back End writes server-side validation against it.

### Boat Fields

The wireframe only asked for Boat Name and Boat Length, but the Boat table has more columns than that, and some of them are required to insert a row at all. So the form is collecting every column the Boat table has, not just the two from the original mockup:

- **Boat Name and Boat Length are always required.** The Boat table won't accept a row without them.
- **Identification depends on the boat's year.** HIN wasn't required (and on some boats didn't exist) before 1972, so:
  - Boat Year 1972 or later: either the HIN by itself, or Registration State + Registration Number together, satisfies it.
  - Boat Year before 1972, or left blank: Registration State + Registration Number are required, HIN alone doesn't count.

  A note box under the Boat Year field updates live to tell the user which rule currently applies.
- **Boat Type and Boat Beam are always optional**, no conditions attached.

One more thing worth flagging to Carolina: Registration State and Registration Number together have to be unique on the Boat table (no two boats can share the same registration in the same state), so that's a possible error case on submit that isn't just "this field is blank."

### Duplicate Email

Email has to be unique on the Customer table, so submitting with an email that's already registered has to fail. The front end has no way to know ahead of time what emails are taken, it can't catch this one live like the password fields, so this depends entirely on the back end actually checking for it and telling the front end it happened. Carolina needs a function on her end that checks the email against existing accounts (either a lookup before the INSERT, or catching the database's unique constraint if the INSERT is attempted anyway) and reports back specifically that it was a duplicate email, not some other failure.

**Update, built form deviates from this section:** this section originally called for a popup. What's actually built in `registration.jsp` is a plain sticky-form redisplay instead — the form re-shows itself with every field's value carried over from `param.*` (works with a server-side forward, not a redirect, since a forward preserves the original request's parameters), plus three request-scope attributes the JSP already reads:

- `formError` — a general banner at the top of the form (`role="alert"`)
- `emailError` — shown inline under the Email field; this is where a duplicate-email message would go
- `passwordError` — shown inline under the Password field

So the concrete answer to "what attribute name and message does Back End set" (still an open checklist item below) is: **Back End should set `emailError`** on a duplicate-email failure and forward back to `registration.jsp` (not redirect), so the request parameters and this attribute are both still available to render. Whether that should instead be a popup, per the original plan, is a question for the team — the same modal-vs-page discussion that came up for the Login error display. There's a static "Already have an account? Log in" link on the page already, but it's just a placeholder (`preventDefault()`, does nothing yet) and isn't wired to the duplicate-email case specifically — the "opens the Login modal with `redirectTo` set to the landing page" behavior described below isn't implemented yet either way.

### Back End Owns


- [x] **Password hashing:** `RegisterServlet` hashes the submitted password with `Utils.hashPassword()` before inserting it. `LoginServlet` uses the same hashing method when checking a password.
- [x] **Customer table column mapping:** Form values are placed into a `Customer` object and inserted by `CustomerDAO.insertCustomer()`.
- [x] **DAO method signature:** `CustomerDAO.insertCustomer(Connection, Customer, String)` returns the generated `customerID`.
- [x] **Duplicate email response:** `CustomerDAO.findByEmail()` checks for an existing account. On a match, Back End sets `emailError` to `"An account with this email already exists."` and forwards to `registration.jsp`.
- [x] **Optional boat registration:** When any boat information is entered, `RegisterServlet` validates the boat and uses `BoatDAO.insertBoat()` to return the generated `boatID`.
- [x] **Boat ownership:** After inserting a boat, `BoatDAO.insertOwnership()` connects its `boatID` to the new `customerID` through the `BoatOwnership` table.
- [x] **Auto-login after registration:** The customer is not automatically logged in. Registration redirects to the landing page after success.
- [x] **Post-registration redirect/forward:** Success redirects to `/?registered=true`. Validation or database failures forward to `/registration.jsp` so request parameters and error attributes remain available.
- [ ] **Input length limits:** Most database limits are enforced server-side. Validation still needs to confirm `streetAddress2` does not exceed 100 characters and `boatType` does not exceed 30 characters.
- [x] **Servlet URL mapping:** `/register`.

## Front End Variables

Every field or control the page's UI sends to the Back End (form fields, query-string params on a lookup page, etc.).

| Field Name | Input Type | Required? | Format / Notes |
| --- | --- | --- | --- |
| `firstName` | text | Yes | `maxlength="50"`, matches `Customer.firstName` |
| `lastName` | text | Yes | `maxlength="50"`, matches `Customer.lastName` |
| `email` | email | Yes | `maxlength="100"`, matches `Customer.email`; also gets checked client-side for a valid email shape |
| `phoneCountryCode` | text | Yes, defaults to `"1"` | `inputmode="numeric"`, `maxlength="3"`; 1 to 3 digits, no leading zero; matches `Customer.phoneCountryCode`, see [Phone Number](#phone-number) above |
| `phone` | text (hidden, formatted display shown separately) | Yes on the wireframe (not marked optional like Address is) | Always exactly 10 raw digits, no formatting characters; matches `Customer.phone`, see [Phone Number](#phone-number) above |
| `streetAddress` | text | **Yes** — built as required, deviating from this contract's original "Optional," see [The Address Field](#the-address-field) above | `maxlength="100"`, matches `Customer.streetAddress` |
| `streetAddress2` | text | **No, Optional** | `maxlength="100"`, matches `Customer.streetAddress2`, see [The Address Field](#the-address-field) above |
| `city` | text | **Yes** — built as required, see [The Address Field](#the-address-field) above | `maxlength="50"`, matches `Customer.city` |
| `state` | text | **Yes** — built as required, see [The Address Field](#the-address-field) above | `maxlength="2"`, matches `Customer.state` (2-letter code) |
| `zipCode` | text | **Yes** — built as required, see [The Address Field](#the-address-field) above | `maxlength="10"`, matches `Customer.zipCode` (allows the 5+4 format) |
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
| `firstName` | `String` | Form field | Required; maximum 50 characters |
| `lastName` | `String` | Form field | Required; maximum 50 characters |
| `email` | `String` | Form field | Required; converted to lowercase; maximum 100 characters |
| `phoneCountryCode` | `String` | Form field | Required; 1–3 digits with no leading zero |
| `phone` | `String` | Form field | Required; exactly 10 digits |
| `streetAddress` | `String` | Form field | Required by the currently built form and servlet |
| `streetAddress2` | `String` | Form field | Optional; blank value stored as `NULL` |
| `city` | `String` | Form field | Required; maximum 50 characters |
| `state` | `String` | Form field | Required; converted to uppercase; exactly two characters |
| `zipCode` | `String` | Form field | Required; five-digit or ZIP+4 format |
| `boatName` | `String` | Form field | Conditionally required when adding a boat |
| `regState` | `String` | Form field | Converted to uppercase; conditionally required |
| `regNumber` | `String` | Form field | Converted to uppercase; conditionally required |
| `boatLength` | `BigDecimal` | Form field | Conditionally required; must be greater than zero and no more than 999.9 |
| `hin` | `String` | Form field | Optional depending on the boat identification rule; converted to uppercase |
| `boatType` | `String` | Form field | Optional |
| `boatBeam` | `BigDecimal` | Form field | Optional; if supplied, must be greater than zero and no more than 999.9 |
| `boatYear` | `Integer` | Form field | Optional; if supplied, must be between 1800 and the current year |
| `password` | `String` | Form field | Required; validated and hashed before storage |
| `confirmPassword` | `String` | Form field | Required by the current servlet; must equal `password` |

## Database Returns

Every query or DAO method the Back End calls for this page, and its exact return shape — including what it returns on "no match" (null vs. empty object vs. exception).

| Method / Query | Parameters In | Returns | Notes |
| --- | --- | --- | --- |
| `CustomerDAO.findByEmail()` | `String email` | `Customer` or `null` | Used to detect an already registered email |
| `CustomerDAO.insertCustomer()` | `Connection`, `Customer`, `String passwordHash` | Generated `customerID` as `int` | Uses the registration transaction connection |
| `BoatDAO.insertBoat()` | `Connection`, `Boat` | Generated `boatID` as `int` | Called only when boat information was entered |
| `BoatDAO.insertOwnership()` | `Connection`, `boatID`, `customerID` | No return value | Inserts the customer/boat relationship into `BoatOwnership` |
| Registration transaction | Customer and optional boat data | Commit or `SQLException` | All inserts commit together; any failure rolls back the complete registration |

## Validation Rules

- **Client-side (UX only, not trusted):** First name, last name, email, phone, country code, boat name, registration state, registration number, and boat length are all required before the form lets you submit. Everything else (street address, address line 2, city, state, zip, HIN, boat type, boat beam, boat year) is optional. Email gets checked for a valid shape. Phone isn't submittable until all 10 digits are entered, formatting happens live as you type, see [Phone Number](#phone-number) above. Password gets checked live against all five rules above (length, uppercase, lowercase, number, special character). Re-type Password gets checked live against the password field for a match.
- **Server-side (source of truth):** `RegisterServlet` validates all required customer fields, email format, country code, 10-digit phone number, address lengths, state length, ZIP format, password rules, and matching passwords. Boat registration is optional. If every boat field is blank, no boat is created. If any boat field is entered, Boat Name and Boat Length are required. A boat built in 1972 or later requires either a valid HIN or Registration State and Registration Number. A boat built before 1972, or one with no year supplied, requires Registration State and Registration Number. Boat length, beam, and year must also be valid numeric values within the accepted ranges.

## Error Handling

Every user-facing error condition this page can hit, and exactly what the user sees.

| Condition | Message Shown | Where Displayed |
| --- | --- | --- |
| Password missing one of the five rules while typing | "Password must contain at least [whichever rule isn't met yet]." (e.g. "Password must contain at least one uppercase letter") | Directly under the Password field, live as the user types |
| Re-type Password doesn't match Password | "Passwords do not match." | Directly under the Re-type Password field, live as the user types |
| A required field is left blank on submit | Browser's default "please fill out this field" prompt (native HTML `required` validation) | Next to the empty field |
| Email already registered (caught by Back End on submit, not something Front End can check ahead of time) | Popup: something like "An account with this email already exists." Exact wording is Back End's call, see [Duplicate Email](#duplicate-email) above. Popup also includes a "Log In" button | Popup, shown once the submit response comes back. "Log In" opens the Login modal with `redirectTo` set to the landing page, so a successful login lands there |
