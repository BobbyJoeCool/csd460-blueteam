**Project:** Blue Team — Moffat Bay Marina
**Course:** CSD 460 - Capstone Project
**Description:** \<one to two sentences describing what this test plan covers — which page(s), which flow, and what aspects (content, navigation, responsiveness, public access, database, etc.)>
**Date:** \<yyyy/mm/dd>

To complete the test case plan, fill out the information for Project, Course, Description and Date in the header above.

## Table of Contents

<!-- Each link's anchor is the heading text lowercased, punctuation removed, and spaces turned into hyphens — e.g. "## Test 1: About Us Navigation" becomes "#test-1-about-us-navigation". Update the anchor here any time you change a test's title. -->

- [**Test 1:** \<short test title>](#test-1-short-test-title)
- [**Test 2:** \<short test title>](#test-2-short-test-title)
- \<add or remove rows to match the number of tests below, updating each anchor to match its final heading text>

For each test, the <u>developer</u> should: provide a test description, a test objective, the developer name and date tested. For each step, fill out the actions to be taken and describe the expected results, and check Pass or Fail. The <u>peer tester</u> should provide their name, date tested, check Pass or Fail for each step, and fill out the Screenshots list below the table with the matching screenshot number for each item.

## Test 1: \<Test Title>

**Test Objective:** \<what this test verifies, in one to two sentences>

> [!note] Note for Carolina
> Replace "\<Test Title>" in the heading above with a short, specific title, fill in the Test Objective, and update this test's link in the Table of Contents to match (see the anchor-format comment up there).

**Developer:** \<name> · **Date tested:** \<yyyy/mm/dd>
**Peer tester:** \<name> · **Date tested:** \<yyyy/mm/dd>

> [!note] Note for Carolina
> Fill in your name and the date you tested as Developer. Leave the Peer tester name and date blank for whoever tests after you.

| Step | Action | Expected Results | Developer | Tester |
|---|---|---|---|---|
| 1 | \<action to take> | \<what should happen> | ☐&nbsp;Pass<br>☐&nbsp;Fail | ☐&nbsp;Pass<br>☐&nbsp;Fail |
| 2 | \<action to take> | \<what should happen> | ☐&nbsp;Pass<br>☐&nbsp;Fail | ☐&nbsp;Pass<br>☐&nbsp;Fail |
| 3 | \<action to take> | \<what should happen> | ☐&nbsp;Pass<br>☐&nbsp;Fail | ☐&nbsp;Pass<br>☐&nbsp;Fail |

> [!note] Note for Carolina
> Write a concrete action and a specific, checkable expected result for each step — avoid vague results like "page works correctly." Include exact test data (login credentials, field values, confirmation numbers) so the peer tester can reproduce the steps exactly. If a step is a database check, include the full SQL query below the table and the exact expected row count/values. Check exactly one Pass/Fail box per column per row as you actually run each step; leave both boxes unchecked until then.

**Comments:**

> [!note] Developer (Carolina)
> \<2-3+ sentences: what passed, any bugs found, and any fixes made before handing off to peer testing>

> [!note] Peer Tester (\<name>)
> \<filled in by the peer tester>

**Screenshots**

> [!note] Note for Carolina
> List one numbered item per step that has a visually checkable result (skip steps that are pure backend/database checks with no UI to capture). Write the caption describing what it should show first; once the screenshot is actually captured, save it under `Screenshots/Test_1/` named `T1_S1.png`, `T1_S2.png`, etc., and embed it under that item exactly like this: `![caption](Screenshots/Test_1/T1_S1.png)`.

1. \<what the screenshot should show, tied to Step 1's expected result>
    ![\<caption>](Screenshots/Test_1/T1_S1.png)
2. \<what the screenshot should show, tied to Step 2's expected result>
    ![\<caption>](Screenshots/Test_1/T1_S2.png)
3. \<what the screenshot should show, tied to Step 3's expected result>
    ![\<caption>](Screenshots/Test_1/T1_S3.png)

## Test 2: \<Test Title>

**Test Objective:** \<what this test verifies, in one to two sentences>

> [!note] Note for Carolina
> Same as Test 1 above: replace the title, fill in the objective, and update the Table of Contents anchor.

**Developer:** \<name> · **Date tested:** \<yyyy/mm/dd>
**Peer tester:** \<name> · **Date tested:** \<yyyy/mm/dd>

| Step | Action | Expected Results | Developer | Tester |
|---|---|---|---|---|
| 1 | \<action to take> | \<what should happen> | ☐&nbsp;Pass<br>☐&nbsp;Fail | ☐&nbsp;Pass<br>☐&nbsp;Fail |
| 2 | \<action to take> | \<what should happen> | ☐&nbsp;Pass<br>☐&nbsp;Fail | ☐&nbsp;Pass<br>☐&nbsp;Fail |
| 3 | \<action to take> | \<what should happen> | ☐&nbsp;Pass<br>☐&nbsp;Fail | ☐&nbsp;Pass<br>☐&nbsp;Fail |

**Comments:**

> [!note] Developer (Carolina)
> \<2-3+ sentences: what passed, any bugs found, and any fixes made before handing off to peer testing>

> [!note] Peer Tester (\<name>)
> \<filled in by the peer tester>

**Screenshots**

1. \<what the screenshot should show, tied to Step 1's expected result>
    ![\<caption>](Screenshots/Test_2/T2_S1.png)
2. \<what the screenshot should show, tied to Step 2's expected result>
    ![\<caption>](Screenshots/Test_2/T2_S2.png)
3. \<what the screenshot should show, tied to Step 3's expected result>
    ![\<caption>](Screenshots/Test_2/T2_S3.png)

<!--
Copy the "## Test N" block above for each additional test needed this week.
Number tests sequentially, list each one in the Table of Contents with a matching link, and name its screenshots Screenshots/Test_N/TN_S#.png.
This template's "Note for Carolina" callouts are placeholders for whoever is writing the test — swap the name if someone else is drafting it, and delete each note once its spot is filled in.
Delete this comment block before submitting.
-->
