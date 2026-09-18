**Project:** Blue Team — Moffat Bay Marina
**Course:** CSD 460 - Capstone Project
**Description:** Test plan for the Look Up Reservation page (Sara — Front End, Carolina — Back End) and the Edit User Profile page (Miguel — Front End, Robert — Back End).
**Date:** 2026/09/13

To complete the test case plan, fill out the information for Project, Course, Description and Date in the header above.

## Table of Contents

<!-- Each link's anchor is the heading text lowercased, punctuation removed, and spaces turned into hyphens — e.g. "## Test 1: About Us Navigation" becomes "#test-1-about-us-navigation". Update the anchor here any time you change a test's title. -->

- [Table of Contents](#table-of-contents)
- [Test 1: Email Change Invalidates the Old Login](#test-1-email-change-invalidates-the-old-login)
- [Test 2: Partial Save Writes Only the Changed Columns](#test-2-partial-save-writes-only-the-changed-columns)
- [Test 3: Change Password Retires the Old One Immediately](#test-3-change-password-retires-the-old-one-immediately)
- [Test 4: Lockout Reset Clears the Lock and Replaces the Password](#test-4-lockout-reset-clears-the-lock-and-replaces-the-password)
- [Test 5: \<Test Title\>](#test-5-test-title)
- [Test 6: \<Test Title\>](#test-6-test-title)
- [Test 7: Signed-In Customer Can Retrieve Own Reservation](#test-7-signed-in-customer-can-retrieve-own-reservation)
- [Test 8: Customer Cannot Retrieve Another Customer's Reservation](#test-8-customer-cannot-retrieve-another-customers-reservation)
- [Test 9: \<Test Title\>](#test-9-test-title)
- [Test 10: \<Test Title\>](#test-10-test-title)

For each test, the <u>developer</u> should: provide a test description, a test objective, the developer name and date tested. For each step, fill out the actions to be taken and describe the expected results, and enter **Pass** or **Fail**. The <u>peer tester</u> should provide their name, date tested, enter **Pass** or **Fail** for each step, and fill out the Screenshots list below the table with the matching screenshot number for each item.

> [!note] Shared test account across Tests 1-4
> All four of Robert's tests below run against one continuous test customer rather than the shared Elena Marsh demo account, so nothing here disturbs the account other testers rely on. Run them in order — 1, then 2, then 3, then 4 — since each one starts from the state the previous one left behind (the email changes in Test 1, three fields change in Test 2, the password changes in Test 3, and it changes again in Test 4). Starting test data, before Test 1's first step:
> - First name: `QA` · Last name: `EditTest`
> - Email: `qa.edittest@example.com`
> - Password: `TestPass1!`
> - Phone country code: `1` · Phone: `3605550199`
> - Street address: `100 Test Way` · Address line 2: *(blank)*
> - City: `Anacortes` · State: `WA` · ZIP: `98221` · Country: `US`

## Test 1: Email Change Invalidates the Old Login

**Test Objective:** Verify that changing a customer's email address on Edit User Info takes effect for authentication immediately — the old email can no longer sign in, and only the new one can.

**Developer:** Robert · **Date tested:** 2026/09/16
**Peer tester:** Carolina · **Date tested:** \<yyyy/mm/dd>

| Step | Action | Expected Results | Developer | Tester |
|---|---|---|---|---|
| 1 | Register a new customer at `/register` using the test data above (email `qa.edittest@example.com`, password `TestPass1!`). | Account is created and the page confirms success (registered notice / redirect to sign in). | **Pass** | \<Pass/Fail> |
| 2 | Sign in with `qa.edittest@example.com` / `TestPass1!`. | Login succeeds; header greeting reads "Welcome, QA E." | **Pass** | \<Pass/Fail> |
| 3 | Click the header greeting to open Edit User Info. Change only the Email field to `qa.edittest.updated@example.com`, leave every other field as-is, click **Save changes**, confirm on the inline "Save these changes?" panel, then click **Yes, save**. | Page redirects to `/editProfile?notice=profileUpdated`; a "Profile updated" toast appears; the "Saved. Here's what changed" summary lists exactly one row: Email, `qa.edittest@example.com` → `qa.edittest.updated@example.com`. | **Pass** | \<Pass/Fail> |
| 4 | Log out via the header's Log Out button. | Redirected to the landing page; header shows Sign In again. | **Pass** | \<Pass/Fail> |
| 5 | Attempt to sign in with the **old** email `qa.edittest@example.com` and password `TestPass1!`. | Login fails with the generic "email or password is incorrect" message (the same anti-enumeration message used for any bad credential, not an account-not-found message). | **Pass** | \<Pass/Fail> |
| 6 | Sign in with the **new** email `qa.edittest.updated@example.com` and password `TestPass1!`. | Login succeeds; header greeting reads "Welcome, QA E." again. | **Pass** | \<Pass/Fail> |

**Comments:**

> [!note] Developer (Robert)
> I added a toggle for password visibility so you can see what you are typing.
> [!note] Developer (Robert)
> Something I noticed that is unrelated to this test is that when you create an account, you are not automatically logged in. Some sites do this where when you create an account you are logged in and directed to where you had attempted to reach. In the case of this test, that's back on the landing page. Worth looking at the registration contract to see if creating an account should log you in as that account automatically.
> [!note] Peer Tester (Carolina)
> \<filled in by the peer tester>

**Screenshots**

1. The registration success notice / redirect after Step 1's account creation.
    ![\<caption>](Screenshots/Test_1/T1_S1.png)
2. Header greeting reading "Welcome, QA E." after Step 2's login.
    ![\<caption>](Screenshots/Test_1/T1_S2.png)
3. The "Saved. Here's what changed" summary showing the Email row after Step 3.
    ![\<caption>](Screenshots/Test_1/T1_S3.png)
4. The landing page header showing Sign In again after Step 4's logout.
    ![\<caption>](Screenshots/Test_1/T1_S4.png)
5. The login modal's generic incorrect-credentials error after Step 5's old-email attempt.
    ![\<caption>](Screenshots/Test_1/T1_S5.png)
6. Header greeting reading "Welcome, QA E." again after Step 6's new-email login.
    ![\<caption>](Screenshots/Test_1/T1_S6.png)

## Test 2: Partial Save Writes Only the Changed Columns

**Test Objective:** Verify that saving a partial profile update writes exactly the fields the customer changed to the `Customer` table, and leaves every other column — including `passwordHash`, `dateJoined`, and the lockout columns — byte-for-byte unchanged.

**Developer:** Robert · **Date tested:** 2026/09/16
**Peer tester:** Carolina · **Date tested:** \<yyyy/mm/dd>

| Step | Action | Expected Results | Developer | Tester |
|---|---|---|---|---|
| 1 | Signed in as `qa.edittest.updated@example.com` (continuing from Test 1), run the "Before" query below against the database. | Query returns exactly one row for this customer; record every column's value. | **Pass** | \<Pass/Fail> |
| 2 | On Edit User Info, change exactly three fields — Last name to `EditTestVerified`, City to `Mount Vernon`, ZIP code to `98273` — and leave every other field untouched. Click **Save changes**, review the confirmation panel, then click **Yes, save**. | The confirmation panel (and, after saving, the "Saved. Here's what changed" summary) lists exactly three rows: Last name, City, ZIP code — no others. | **Pass** | \<Pass/Fail> |
| 3 | Run the "After" query below against the database. | Query returns exactly one row for this customer. | **Pass**| \<Pass/Fail> |
| 4 | Diff the "Before" and "After" rows column by column. | `lastName` = `EditTestVerified`, `city` = `Mount Vernon`, `zipCode` = `98273`. Every other column — `firstName`, `email`, `phone`, `phoneCountryCode`, `streetAddress`, `streetAddress2`, `state`, `country`, `passwordHash`, `dateJoined`, `failedLoginAttempts`, `accountLocked` — is identical to the "Before" row. | **Pass** | \<Pass/Fail> |

**SQL query (run before Step 2 and again after, same query both times):**

```sql
SELECT customerID, firstName, lastName, email, phone, phoneCountryCode,
       streetAddress, streetAddress2, city, state, zipCode, country,
       passwordHash, dateJoined, failedLoginAttempts, accountLocked
FROM Customer
WHERE email = 'qa.edittest.updated@example.com';
```

**Expected row count:** 1, both times. Expected diff: only `lastName`, `city`, `zipCode` change; all twelve other columns match between the two runs.

**Comments:**

> [!note] Developer (Robert)
> The test successfully updated as expected. I ran into no issues with the process.
> [!note] Peer Tester (Carolina)
> \<filled in by the peer tester>

**Screenshots**

1. The database client showing the "Before" row returned by Step 1's query.
    ![\<caption>](Screenshots/Test_2/T2_S1.png)
2. The "Saved. Here's what changed" summary after Step 2, showing exactly Last name, City, and ZIP code.
    ![\<caption>](Screenshots/Test_2/T2_S2.png)
3. The database client showing the "After" row returned by Step 3's query.
    ![\<caption>](Screenshots/Test_2/T2_S3.png)
4. The Before and After rows shown together (side-by-side or stacked), with Step 4's confirmed matches/differences visible.
    ![\<caption>](Screenshots/Test_2/T2_S4.png)

## Test 3: Change Password Retires the Old One Immediately

**Test Objective:** Verify that the Change Password modal on Edit User Info updates the stored password hash correctly, and that only the new password authenticates afterward.

**Developer:** Robert · **Date tested:** 2026/9/16
**Peer tester:** Carolina · **Date tested:** \<yyyy/mm/dd>

| Step | Action | Expected Results | Developer | Tester |
|---|---|---|---|---|
| 1 | Signed in as `qa.edittest.updated@example.com` / `TestPass1!` (continuing from Test 2), open Edit User Info and click **Change password**. | The Change Password modal opens with Current password, New password, and Confirm new password fields, plus the live password rules checklist. | **Pass** | \<Pass/Fail> |
| 2 | Enter Current password `TestPass1!`, New password `TestPass2!`, Confirm new password `TestPass2!`, and click **Update password**. | The modal closes with no page navigation; a "Password updated" toast appears. | **Pass** | \<Pass/Fail> |
| 3 | Log out via the header's Log Out button. | Redirected to the landing page; header shows Sign In again. | **Pass** | \<Pass/Fail> |
| 4 | Attempt to sign in with `qa.edittest.updated@example.com` and the **old** password `TestPass1!`. | Login fails with the generic incorrect-credentials message. | **Pass** | \<Pass/Fail> |
| 5 | Sign in with `qa.edittest.updated@example.com` and the **new** password `TestPass2!`. | Login succeeds; header greeting reads "Welcome, QA E." | **Pass** | \<Pass/Fail> |

**Comments:**

> [!note] Developer (Robert)
> I ran into no issues with this test. Everything functioned as expected and no unexpected issues came up. Same note from above about the password error and username error presenting the same results.
 
> [!note] Peer Tester (Carolina)
> \<filled in by the peer tester>

**Screenshots**

1. The Change Password modal open, mid-fill, with the rules checklist visible (Step 1).
    ![\<caption>](Screenshots/Test_3/T3_S1.png)
2. The "Password updated" toast after Step 2.
    ![\<caption>](Screenshots/Test_3/T3_S2.png)
3. The landing page header showing Sign In again after Step 3's logout.
    ![\<caption>](Screenshots/Test_3/T3_S3.png)
4. The login modal's incorrect-credentials error after Step 4's old-password attempt.
    ![\<caption>](Screenshots/Test_3/T3_S4.png)
5. Header greeting reading "Welcome, QA E." after Step 5's new-password login.
    ![\<caption>](Screenshots/Test_3/T3_S5.png)

## Test 4: Lockout Reset Clears the Lock and Replaces the Password

**Test Objective:** Verify that three failed sign-in attempts lock the account, that the forgot-password reset (reached from the login modal's locked-out state) both clears the lockout and sets a new password, and that only the new password works afterward.

**Developer:** Robert · **Date tested:** 2026/9/16
**Peer tester:** Carolina · **Date tested:** \<yyyy/mm/dd>

| Step | Action | Expected Results | Developer | Tester |
|---|---|---|---|---|
| 1 | Attempt to sign in as `qa.edittest.updated@example.com` with an incorrect password three times in a row (e.g. `wrong1`, `wrong2`, `wrong3`). | The first two attempts show the generic incorrect-credentials message. After the third, the login modal switches to its locked-out state: the sign-in form is replaced with a message and a **Reset your password** button. | **Pass** | \<Pass/Fail> |
| 2 | Click **Reset your password**. | The Forgot Password modal opens, with the Email field pre-filled with `qa.edittest.updated@example.com`. | **Pass** | \<Pass/Fail> |
| 3 | Enter Verification code `12345` (the site's fixed demo code), New password `TestPass3!`, Confirm new password `TestPass3!`, and submit. | Redirected with a "Password reset — sign in with your new password" confirmation; no auto-login occurs (still signed out). | **Pass** | \<Pass/Fail> |
| 4 | Attempt to sign in with `qa.edittest.updated@example.com` and the password from Test 3, `TestPass2!`. | Login fails with the generic incorrect-credentials message — it does **not** report the account as locked, confirming the reset cleared the lockout rather than merely changing the password on top of it. | **Pass** | \<Pass/Fail> |
| 5 | Sign in with `qa.edittest.updated@example.com` and the new password `TestPass3!`. | Login succeeds; header greeting reads "Welcome, QA E." | **Pass** | \<Pass/Fail> |

**Comments:**

> [!note] Developer (Robert)
> I ran into no issues with this test. Everything functioned as expected and no unexpected issues came up. Same note from above about the password error and username error presenting the same results.
> [!note] Peer Tester (Carolina)
> \<filled in by the peer tester>
]
**Screenshots**

1. The login modal's locked-out state after Step 1's third failed attempt, showing the **Reset your password** button.
    ![\<caption>](Screenshots/Test_4/T4_S1.png)
2. The Forgot Password modal from Step 2, with the email pre-filled.
    ![\<caption>](Screenshots/Test_4/T4_S2.png)
3. The "Password reset" confirmation toast after Step 3.
    ![\<caption>](Screenshots/Test_4/T4_S3.png)
4. The login modal's plain incorrect-credentials error (not a lockout message) after Step 4's old-password attempt — confirming the reset cleared the lockout rather than stacking a new password on top of it.
    ![\<caption>](Screenshots/Test_4/T4_S4.png)
5. Header greeting reading "Welcome, QA E." after Step 5's successful login with the new password.
    ![\<caption>](Screenshots/Test_4/T4_S5.png)

## Test 5: \<Test Title>

**Test Objective:** \<what this test verifies for Sara's Front-End portion of the Look Up Reservation page, in one to two sentences>

> [!note] Note for Sara
> Replace "\<Test Title>" in the heading above with a short, specific title, fill in the Test Objective, and update this test's link in the Table of Contents to match (see the anchor-format comment up there).

**Developer:** Sara · **Date tested:** \<yyyy/mm/dd>
**Peer tester:** Miguel · **Date tested:** \<yyyy/mm/dd>
> [!note] Note for Sara
> Fill in the date you tested as Developer. Leave the Peer tester date blank for Miguel to fill in when he tests.

| Step | Action | Expected Results | Developer | Tester |
|---|---|---|---|---|
| 1 | \<action to take> | \<what should happen> | \<Pass/Fail> | \<Pass/Fail> |
| 2 | \<action to take> | \<what should happen> | \<Pass/Fail> | \<Pass/Fail> |
| 3 | \<action to take> | \<what should happen> | \<Pass/Fail> | \<Pass/Fail> |

> [!note] Note for Sara
> Write a concrete action and a specific, checkable expected result for each step — avoid vague results like "page works correctly." Include exact test data (login credentials, field values, confirmation numbers) so the peer tester can reproduce the steps exactly. If a step is a database check, include the full SQL query below the table and the exact expected row count/values. Replace each `\<Pass/Fail>` placeholder with **Pass** or **Fail** as you actually run each step; leave it as the placeholder until then.

**Comments:**

> [!note] Developer (Sara)
> \<2-3+ sentences: what passed, any bugs found, and any fixes made before handing off to peer testing>

> [!note] Peer Tester (Miguel)
> \<filled in by the peer tester>

**Screenshots**

> [!note] Note for Sara
> List one numbered item per step that has a visually checkable result (skip steps that are pure backend/database checks with no UI to capture). Write the caption describing what it should show first; once the screenshot is actually captured, save it under `Screenshots/Test_5/` named `T5_S1.png`, `T5_S2.png`, etc., and embed it under that item exactly like this: `![caption](Screenshots/Test_5/T5_S1.png)`.

1. \<what the screenshot should show, tied to Step 1's expected result>
    ![\<caption>](Screenshots/Test_5/T5_S1.png)
2. \<what the screenshot should show, tied to Step 2's expected result>
    ![\<caption>](Screenshots/Test_5/T5_S2.png)
3. \<what the screenshot should show, tied to Step 3's expected result>
    ![\<caption>](Screenshots/Test_5/T5_S3.png)

## Test 6: \<Test Title>

**Test Objective:** \<what this test verifies for Sara's Front-End portion of the Look Up Reservation page, in one to two sentences>

> [!note] Note for Sara
> Same as Test 5 above: replace the title, fill in the objective, and update the Table of Contents anchor.

**Developer:** Sara · **Date tested:** \<yyyy/mm/dd>
**Peer tester:** Miguel · **Date tested:** \<yyyy/mm/dd>

| Step | Action | Expected Results | Developer | Tester |
|---|---|---|---|---|
| 1 | \<action to take> | \<what should happen> | \<Pass/Fail> | \<Pass/Fail> |
| 2 | \<action to take> | \<what should happen> | \<Pass/Fail> | \<Pass/Fail> |
| 3 | \<action to take> | \<what should happen> | \<Pass/Fail> | \<Pass/Fail> |

**Comments:**

> [!note] Developer (Sara)
> \<2-3+ sentences: what passed, any bugs found, and any fixes made before handing off to peer testing>

> [!note] Peer Tester (Miguel)
> \<filled in by the peer tester>

**Screenshots**

1. \<what the screenshot should show, tied to Step 1's expected result>
    ![\<caption>](Screenshots/Test_6/T6_S1.png)
2. \<what the screenshot should show, tied to Step 2's expected result>
    ![\<caption>](Screenshots/Test_6/T6_S2.png)
3. \<what the screenshot should show, tied to Step 3's expected result>
    ![\<caption>](Screenshots/Test_6/T6_S3.png)

### Test 7: Signed-In Customer Can Retrieve Own Reservation

**Test Objective:** Verify that the Look Up Reservation backend returns a reservation that belongs to the signed-in customer.

**Developer:** Carolina · **Date tested:** 2026/09/18

**Peer tester:** Robert · **Date tested:** <yyyy/mm/dd>

| Step | Action | Expected Results | Developer | Tester |
|---|---|---|---|---|
| 1 | Sign in using `elena.marsh@example.com` and password `MoffatMarsh01!`. | Login succeeds and the Look Up Reservation link is available. | **Pass** | <Pass/Fail> |
| 2 | Open Look Up Reservation and search for reservation number `MB-00001`, year `2026`, and month `June`. | The request is sent to `/reservations` and the reservation is returned for the signed-in customer. | **Pass** | <Pass/Fail> |
| 3 | Review the returned reservation details. | Elena's reservation is displayed with the confirmation number, guest name, slip number, start date, monthly rate, lease status, and boat name. | **Pass** | <Pass/Fail> |

**Comments:**

> [!note] Developer (Carolina)
> The reservation lookup worked as expected and returned Elena’s reservation when I searched for MB-00001 while signed in as her. The correct reservation details were displayed, including the guest name, slip, start date, monthly rate, lease status, and boat name. I did not run into any backend issues during this test, but front-end does need cosmetic touches for buttons.

> [!note] Peer Tester (Robert)
>
> <filled in by the peer tester>

**Screenshots**

1. \<what the screenshot should show, tied to Step 1's expected result>
    ![\<caption>](Screenshots/Test_7/T7_S1.png)
2. \<what the screenshot should show, tied to Step 2's expected result>
    ![\<caption>](Screenshots/Test_7/T7_S2.png)
3. \<what the screenshot should show, tied to Step 3's expected result>
    ![\<caption>](Screenshots/Test_7/T7_S3.png)

## Test 8: Customer Cannot Retrieve Another Customer's Reservation

**Test Objective:** Verify that the Look Up Reservation backend only returns reservations that belong to the signed-in customer.

**Developer:** Carolina · **Date tested:** 2026/09/18

**Peer tester:** Robert · **Date tested:** <yyyy/mm/dd>

| Step | Action | Expected Results | Developer | Tester |
|---|---|---|---|---|
| 1 | Sign in using `elena.marsh@example.com` and password `MoffatMarsh01!`. | Login succeeds and Elena's customer session is active. | **Pass** | <Pass/Fail> |
| 2 | Open Look Up Reservation and search for reservation number `MB-00004`. Leave Year as All Years and Month as All Months. | The backend searches using Elena's session customer ID along with the reservation number. | **Pass** | <Pass/Fail> |
| 3 | Review the result. | The reservation is not displayed and the page shows `No reservation found.` | **Pass** | <Pass/Fail> |

**Comments:**

> [!note] Developer (Carolina)
> The lookup correctly did not return a reservation that did not belong to the signed-in customer. Instead, the page showed “No reservation found.” The backend is using the customer ID from the session to limit reservation results. I did have to adjust the error message because at first the page was not displaying any response when no reservation was found. After that fix, no additional backend issues came up.

> [!note] Peer Tester (Robert)
>
> <filled in by the peer tester>

**Screenshots**

1. \<what the screenshot should show, tied to Step 1's expected result>
    ![\<caption>](Screenshots/Test_8/T8_S1.png)
2. \<what the screenshot should show, tied to Step 2's expected result>
    ![\<caption>](Screenshots/Test_8/T8_S2.png)
3. \<what the screenshot should show, tied to Step 3's expected result>
    ![\<caption>](Screenshots/Test_8/T8_S3.png)

## Test 9: \<Test Title>

**Test Objective:** \<what this test verifies for Miguel's Front-End portion of the Edit User Profile page, in one to two sentences>

> [!note] Note for Miguel
> Replace "\<Test Title>" in the heading above with a short, specific title, fill in the Test Objective, and update this test's link in the Table of Contents to match (see the anchor-format comment up there).

**Developer:** Miguel · **Date tested:** \<yyyy/mm/dd>
**Peer tester:** Sara · **Date tested:** \<yyyy/mm/dd>

> [!note] Note for Miguel
> Fill in the date you tested as Developer. Leave the Peer tester date blank for Sara to fill in when she tests.

| Step | Action | Expected Results | Developer | Tester |
|---|---|---|---|---|
| 1 | \<action to take> | \<what should happen> | \<Pass/Fail> | \<Pass/Fail> |
| 2 | \<action to take> | \<what should happen> | \<Pass/Fail> | \<Pass/Fail> |
| 3 | \<action to take> | \<what should happen> | \<Pass/Fail> | \<Pass/Fail> |

> [!note] Note for Miguel
> Write a concrete action and a specific, checkable expected result for each step — avoid vague results like "page works correctly." Include exact test data (login credentials, field values) so the peer tester can reproduce the steps exactly. Replace each `\<Pass/Fail>` placeholder with **Pass** or **Fail** as you actually run each step; leave it as the placeholder until then.

**Comments:**

> [!note] Developer (Miguel)
> \<2-3+ sentences: what passed, any bugs found, and any fixes made before handing off to peer testing>

> [!note] Peer Tester (Sara)
> \<filled in by the peer tester>

**Screenshots**

1. \<what the screenshot should show, tied to Step 1's expected result>
    ![\<caption>](Screenshots/Test_9/T9_S1.png)
2. \<what the screenshot should show, tied to Step 2's expected result>
    ![\<caption>](Screenshots/Test_9/T9_S2.png)
3. \<what the screenshot should show, tied to Step 3's expected result>
    ![\<caption>](Screenshots/Test_9/T9_S3.png)

## Test 10: \<Test Title>

**Test Objective:** \<what this test verifies for Miguel's Front-End portion of the Edit User Profile page, in one to two sentences>

> [!note] Note for Miguel
> Same as Test 9 above: replace the title, fill in the objective, and update the Table of Contents anchor.

**Developer:** Miguel · **Date tested:** \<yyyy/mm/dd>
**Peer tester:** Sara · **Date tested:** \<yyyy/mm/dd>

| Step | Action | Expected Results | Developer | Tester |
|---|---|---|---|---|
| 1 | \<action to take> | \<what should happen> | \<Pass/Fail> | \<Pass/Fail> |
| 2 | \<action to take> | \<what should happen> | \<Pass/Fail> | \<Pass/Fail> |
| 3 | \<action to take> | \<what should happen> | \<Pass/Fail> | \<Pass/Fail> |

**Comments:**

> [!note] Developer (Miguel)
> \<2-3+ sentences: what passed, any bugs found, and any fixes made before handing off to peer testing>

> [!note] Peer Tester (Sara)
> \<filled in by the peer tester>

**Screenshots**

1. \<what the screenshot should show, tied to Step 1's expected result>
    ![\<caption>](Screenshots/Test_10/T10_S1.png)
2. \<what the screenshot should show, tied to Step 2's expected result>
    ![\<caption>](Screenshots/Test_10/T10_S2.png)
3. \<what the screenshot should show, tied to Step 3's expected result>
    ![\<caption>](Screenshots/Test_10/T10_S3.png)

<!--
Copy the "## Test N" block above for each additional test needed this module.
Number tests sequentially, list each one in the Table of Contents with a matching link, and name its screenshots Screenshots/Test_N/TN_S#.png.
This template's "Note for <name>" callouts are placeholders for whoever is writing the test — swap the name if someone else is drafting it, and delete each note once its spot is filled in.
Delete this comment block before submitting.
-->
