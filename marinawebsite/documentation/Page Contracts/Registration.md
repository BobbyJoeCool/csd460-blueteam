# Page Contract: Registration

## Page Name

Registration

## Module / Week

Module 5 / Week 4 (Aug 31 – Sep 6, 2026)

## Assigned

- Front End: Robert
- Back End: Carolina
- Testing:

## Current Status (2026-10-10)

**Built.** Registration creates the customer's account only. **Since 2026-10-09 it no longer takes a boat**: the boat column was removed, and a customer who wants to register a boat straight away uses the **Create Account & Go to My Fleet** button, which creates the account, signs them in and lands them on My Fleet with the Add Boat button waiting. Boat fields, their rules and their messages are documented in the My Fleet contract now.

## Open Questions / Decisions Needed

### Front End Owns

- [x] **Form field `name` attributes:** Decided, see [What the Form Collects](#what-the-form-collects) below.
- [x] **Confirm-password handling:** Checked live in the browser and again by the server. See [Confirm Password](#confirm-password) below.
- [x] **Input length limits (HTML side):** Set, see the table below. Matched against the Customer columns.
- [x] **Address field shape:** Decided, four separate fields instead of one box. See [The Address Field](#the-address-field) below.
- [x] **Country field:** Decided, 2026-09-04. See [Country](#country) below.
- [x] **Boat registration:** **Moved to My Fleet, 2026-10-09.** See [Registering a Boat](#registering-a-boat) below.

---

### What the Form Collects

The Module 2 wireframe (`Module-2/Finalized WireFrames/Registration Page.pdf`) is the starting point; the address fields go beyond it, see [The Address Field](#the-address-field). The page has two columns, **Personal Information** (the shared `WEB-INF/includes/personalInfoCard.jsp`) and **User Information**, under a "* Required field" note:

- First Name
- Last Name
- Country Code (defaults to 1)
- Phone
- Country
- Street Address
- Address Line 2 (Optional, apartment/suite/PO box)
- City
- State / Province (not applicable when Country is `OTHER`)
- Zip Code
- Email
- Password
- Re-type Password
- Two submit buttons: **Create Account**, and **Create Account & Go to My Fleet** under "Want to register a boat?"

Field names, matched to what they map to: `firstName`, `lastName`, `phoneCountryCode`, `phone`, `country`, `streetAddress`, `streetAddress2`, `city`, `state`, `zipCode`, `email`, `password`, `confirmPassword`, plus the hidden `redirectTo` and the second button's `registerBoatNext`.

A **Clear Personal Info** button under the left column empties that column and puts Country back to US and Country Code back to 1. Under the buttons: "By creating an account you agree to our Privacy Policy" (linking `/privacy`), and "Already have an account? Log in".

### Password Rules

At least 10 characters, one uppercase letter, one lowercase letter, one number, and one special character from `! $ % * #`. The shared checklist (`WEB-INF/includes/passwordRules.jsp` + `js/passwordRules.js`) sits under the password fields and ticks each rule off live as the customer types. Both submit buttons stay disabled until every rule is met.

The Password field also carries `minlength="10"`, a `pattern` matching `Utils.PASSWORD_PATTERN`, and a `passwordrules` attribute, so the browser and password managers (Safari, iCloud Keychain, 1Password) suggest a password that already passes. This is all for the customer's benefit; `RegisterServlet` enforces the same rule on submit, since a request can always skip the browser.

### Confirm Password

`confirmPassword` is checked live against `password` ("Passwords do not match." under Re-type Password) and is also submitted, so `RegisterServlet` checks the two match before creating the account. It is never stored.

### Phone Number

The visible Phone box always shows the number formatted as `(###)-###-####` however it's typed or pasted; JavaScript strips it to digits on every keystroke and rebuilds the display (`MoffatBay.form.bindPhoneDisplay`, shared with Your Account). Backspacing over a bracket or dash removes the digit before it.

What's submitted isn't that visible box. A hidden field named `phone` always holds just the raw 10 digits, kept in sync with the display, so Back End always gets a clean 10-digit `phone`. The visible box has no `name`.

Country Code is a separate small box in front of Phone, defaulting to `1`, sent as its own `phoneCountryCode` field: 1 to 3 digits, no leading zero. It has its own column, `Customer.phoneCountryCode VARCHAR(3) NOT NULL DEFAULT '1'`.

### The Address Field

The wireframe has one "Address (Optional)" text box, but the Customer table stores `streetAddress`, `city`, `state` and `zipCode` separately, so the form asks for them separately rather than parsing one box. A second line, `streetAddress2`, holds an apartment, suite or PO box and has its own column.

**Required, not optional.** The built form, and `CustomerValidator` on the server, require Street Address, City and Zip Code, and State unless Country is `OTHER`. Only Address Line 2 is optional. This replaced the wireframe's "(Optional)".

### Country

**Added 2026-09-04**, not on the original wireframe. A required `country` `<select>` right after Phone, with three options: `US` (United States, the default), `CA` (Canada) or `OTHER`. `OTHER` doesn't record which country; it only changes the State field below it:

| Country | State field label | Options | Required? |
| --- | --- | --- | --- |
| `US` | "State" | `WEB-INF/includes/stateOptions.jsp` | Yes |
| `CA` | "Province" | `WEB-INF/includes/provinceOptions.jsp` | Yes |
| `OTHER` | "State" | "Not applicable", field disabled | No; stored as `NULL` |

`registration.js` swaps the label, list and disabled state live through the shared `MoffatBay.form.applyCountryToRegion` in `formValidation.js`, the same code Your Account uses (#281).

`Customer.country VARCHAR(5) NOT NULL DEFAULT 'US'` (`VARCHAR(5)`, not `CHAR(2)`, since `OTHER` is a stored value, not an ISO code). The customer's country also picks the Registration Number format on My Fleet and Book a Slip.

**Zip Code is not format-aware, flagged for the team:** Canada uses alphanumeric postal codes (e.g. `V8V 3K1`), but `zipCode` (`ZIP_PATTERN` client- and server-side) only accepts the US 5-digit or ZIP+4 shape regardless of Country, so a real Canadian or foreign postal code fails registration. Not fixed; decide whether Zip Code should follow Country before it comes up for a real customer.

### Registering a Boat

**Moved to My Fleet, 2026-10-09.** Registration used to have an optional Boat Information column (the shared `boatInfoCard.jsp`), saved in the same transaction as the account. It's gone. Instead:

- **Create Account & Go to My Fleet** (`name="registerBoatNext" value="true"`) is a second submit button for the same form. It creates the account exactly like Create Account, then lands on `/myFleet?registered=true` instead of the `redirectTo` page.
- A boat is added on My Fleet (Add Boat) or from Book a Slip's Register a Boat panel. Both require a HIN or a Registration Number.

### Duplicate Email

Email is unique on the Customer table, so a second account with the same email has to fail, and the page can't know in advance which emails are taken.

**As built (since 2026-10-09):** `RegisterServlet` no longer looks the email up first. The insert hits the column's `UNIQUE` constraint, and the servlet forwards back with **"That email is already in use."** in the banner at the top of the page (`formError`), with everything typed still in the form. `emailError` (the message box under the Email field) is still on the page but nothing sets it now.

The "Log in" link under the buttons opens the Login modal, carrying the page's `redirectTo` (or `/`), so a customer who already has an account can sign in from here instead.

### Back End Owns

- [x] **Password hashing:** `RegisterServlet` hashes the password with `Utils.hashPassword()` (SHA-256), the same method `LoginServlet` uses to check it.
- [x] **Customer table column mapping:** Form values are placed into a `Customer` object and inserted by `CustomerDAO.insertCustomer()`.
- [x] **DAO method signature:** `CustomerDAO.insertCustomer(Connection, Customer, String passwordHash)` returns the generated `customerID`.
- [x] **Customer field validation:** `util/CustomerValidator.validate(fields, country, true)`, shared with Your Account (#284), so both pages accept the same values and word each mistake the same way. The banner shows one message: "Please complete all required fields." if anything required is blank, otherwise the first problem in form order. The password checks are this page's own.
- [x] **Duplicate email response:** see [Duplicate Email](#duplicate-email) above.
- [x] **Auto-login after registration:** **Changed 2026-09-30 (#299, beta test):** the customer is signed in automatically. `RegisterServlet` loads the new account back by email and calls `CustomerSession.start()`, the same method `LoginServlet` uses. If loading the account back fails, the account still exists, so it falls back to the home page, signed out, rather than an error page.
- [x] **Post-registration redirect:** Create Account redirects to the `redirectTo` the customer arrived with (checked with `Utils.safeRedirectTarget`); Create Account & Go to My Fleet redirects to `/myFleet`. Either way `registered=true` is added, so the status popup says "Account created — welcome aboard" there. No `redirectTo`, an unsafe one, or one pointing back at `/register` goes to `/`. Validation and database failures forward back to `registration.jsp`, so the typed values and the message are still there.
- [x] **Input length limits:** Checked server-side by `CustomerValidator`, including `streetAddress2` (100 characters).
- [x] **Servlet URL mapping:** `/register` (GET shows the page, POST creates the account).
- [x] **Abuse limits:** `/register` is one of the forms `PostRateLimitFilter` covers (10 posts a minute per address, then 429), and like every POST it needs `CsrfFilter`'s token.

## Front End Variables

| Field Name | Input Type | Required? | Format / Notes |
| --- | --- | --- | --- |
| `firstName` | text | Yes | Matches `Customer.firstName` (50) |
| `lastName` | text | Yes | Matches `Customer.lastName` (50) |
| `phoneCountryCode` | text | Yes, defaults to `"1"` | `inputmode="numeric"`, `maxlength="3"`; 1 to 3 digits, no leading zero |
| `phone` | hidden (formatted display shown separately) | Yes | Always exactly 10 raw digits, see [Phone Number](#phone-number) |
| `country` | select | Yes, defaults to `"US"` | `US` / `CA` / `OTHER`, see [Country](#country) |
| `streetAddress` | text | Yes | Matches `Customer.streetAddress` (100) |
| `streetAddress2` | text | No | Matches `Customer.streetAddress2` (100) |
| `city` | text | Yes | Matches `Customer.city` (50) |
| `state` | select | Unless Country is `OTHER` | 2-letter state or province code; list, label and disabled state follow `country` |
| `zipCode` | text | Yes | `maxlength="10"`, 5 digits or ZIP+4 |
| `email` | email | Yes | Matches `Customer.email` (100); checked in the browser for a valid shape |
| `password` | password | Yes | 10+ characters with an uppercase letter, a lowercase letter, a number and one of `! $ % * #`; checked live |
| `confirmPassword` | password | Yes | Must match `password`; checked live and by the server |
| `redirectTo` | hidden | No | **Added 2026-09-30 (#299).** Where to land after registering, as a context-relative path. Set by the Login modal's Register here link (`/register?redirectTo=/reservation`, for example) and kept through failed attempts, because those forward. Ignored when `registerBoatNext` is sent |
| `registerBoatNext` | submit button value | No | **Added 2026-10-09.** `true` when the customer pressed Create Account & Go to My Fleet |

**Placeholders (updated 2026-09-30, #304, beta test):** name and city fields have none, email shows `you@example.com`, and the rest read as examples (`e.g. 123 Harbor Rd`, `e.g. 98250`). A site-wide `::placeholder` colour in `site.css` keeps example text lighter than typed text at 4.9:1 contrast.

## Back End Parameters

| Parameter Name | Type | Source (form field / session / query string) | Notes |
| --- | --- | --- | --- |
| `firstName` | `String` | Form field | Trimmed; required; maximum 50 characters |
| `lastName` | `String` | Form field | Trimmed; required; maximum 50 characters |
| `email` | `String` | Form field | Trimmed and lowercased; required; maximum 100 characters; must match `Utils.EMAIL_PATTERN` |
| `phoneCountryCode` | `String` | Form field | Required; 1–3 digits with no leading zero |
| `phone` | `String` | Form field | Required; exactly 10 digits |
| `streetAddress` | `String` | Form field | Required; maximum 100 characters |
| `streetAddress2` | `String` | Form field | Optional; maximum 100 characters; blank stored as `NULL` |
| `city` | `String` | Form field | Required; maximum 50 characters |
| `state` | `String` | Form field | Uppercased; required unless `country` is `OTHER`; exactly two characters if supplied; blank stored as `NULL` |
| `zipCode` | `String` | Form field | Required; five digits or ZIP+4 |
| `country` | `String` | Form field | Uppercased; required; `US`, `CA` or `OTHER` |
| `password` | `String` | Form field | Required; must match `Utils.PASSWORD_PATTERN`; hashed before storage |
| `confirmPassword` | `String` | Form field | Required; must equal `password` |
| `redirectTo` | `String` | Form field (hidden) | Passed through `Utils.safeRedirectTarget`, falling back to `/` |
| `registerBoatNext` | `String` | Form field (submit button) | `"true"` sends the new customer to `/myFleet` |

## Database Returns

| Method / Query | Parameters In | Returns | Notes |
| --- | --- | --- | --- |
| `CustomerDAO.insertCustomer()` | `Connection`, `Customer`, `String passwordHash` | Generated `customerID` as `int` | Runs in its own transaction; a duplicate email throws a duplicate-key `SQLException` (see [Duplicate Email](#duplicate-email)) |
| `CustomerDAO.findByEmail()` | `String email` | `Customer` or `null` | Called after the insert commits, to load the new account for `CustomerSession.start()` |

## Validation Rules

- **Client-side (UX only, not trusted):** Both submit buttons stay disabled until every required field is filled (a disabled State counts as filled), the email has a valid shape, the phone has all 10 digits, the country code is valid, the ZIP is 5 digits or ZIP+4, all five password rules pass, and Re-type Password matches. Phone formats as you type. The State field's label, list and disabled state follow Country live.
- **Server-side (source of truth):** `RegisterServlet` runs `CustomerValidator` over every customer field with every required field required, then checks the password fields itself: both filled, the password matches the rules, and the two match. The first failure is shown in the banner and nothing is saved.

## Error Handling

| Condition | Message Shown | Where Displayed |
| --- | --- | --- |
| Password still missing a rule, while typing | The rule stays unticked in the "Your password must contain" checklist | Under the password fields, live |
| Re-type Password doesn't match | "Passwords do not match." | Under Re-type Password, live |
| Phone incomplete, while typing | "Phone number needs all 10 digits." | Under Phone, live |
| Country code invalid, while typing | "Enter a 1 to 3 digit country code (no leading zero)." | Under the country code box, live |
| ZIP invalid, while typing | "Enter a 5-digit ZIP, or ZIP+4 like 12345-6789." | Under Zip Code, live |
| Email invalid, while typing | "Enter a valid email address." | Under Email, live |
| A required field blank on submit (JavaScript off, or a hand-made request) | "Please complete all required fields." | Red banner under the hero (`formError`) |
| State missing for US or CA | "State/Province is required." | Banner |
| A customer field fails its format check | `CustomerValidator`'s message for it, e.g. "Enter a valid ZIP code." or "First name cannot exceed 50 characters." | Banner |
| Password doesn't meet the rules | "Password does not meet the required rules." | Banner |
| Passwords don't match | "Passwords do not match." | Banner |
| Email already registered | "That email is already in use." | Banner |
| Any other database failure | "Registration could not be completed. Please try again." | Banner |
| Too many posts from one address | "Easy Does It" page: "That form has been sent a lot in the last minute, so we've paused it…" (429) | `error.jsp` |
| Account created | "Account created — welcome aboard" | Shared status popup, on the page the customer lands on |

## Login State Differences

| Item | Logged In | Logged Out |
| --- | --- | --- |
| Registration page | Opens normally; nothing stops a signed-in customer from making a second account. Registering signs the browser in as the new account | Opens normally |
| Header | Welcome menu and Log Out | Log In button |
