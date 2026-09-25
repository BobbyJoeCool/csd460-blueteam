## Beta Tester Instructions

Two separate things need to go to a beta tester, and they serve opposite purposes: a **task script** that stays deliberately vague about *how* to do something (that vagueness is the point. It's what tests navigation), and a **reference card** of a few real-world values a tester has no way to invent on the spot, which has nothing to do with navigation and would only introduce a different kind of confusion if left out.

### Task Script (give this to the tester)

Don't narrate steps or name buttons. State the goal and let them find the path; write down anywhere they hesitate, guess, or ask "wait, how do I—". Give this as one block, in order, since later tasks depend on earlier ones (you need an account before you can book, a boat before you can reserve a slip for it):

1. Create an account for yourself on the site.
2. Add a boat to your account — pick any name and length you like; use the reference card below only if it asks for something you don't know off-hand (like a HIN). (Make sure the boat length is between 41 and 50 feet, or less than 26 feet so it will be able to be booked at a slip!)
3. Book a slip for that boat.
4. Navigate to the Home Screen.
5. Without any hints from me (or uding the back button), find your reservation again and confirm the details are right.
6. Update one piece of your account information (anything — phone number, address, whatever you'd actually change) and confirm the change stuck.

Don't tell them these are separate "tests" up front — let the task read as one normal use of the site, since that's what actually exposes whether the flow between pages makes sense. Ask the Core Questions below once they're done, while it's fresh.

### Reference Card (keep this next to you, not given to the tester up front)

Only hand over a value if the tester gets stuck on a field and asks — handing this over unprompted defeats the point of testing whether the page explains itself.

- **HIN and Registration Number are both optional.** The site accepts a boat with neither — if a tester skips these fields entirely without being told to, that's a valid, useful result, not a failed task.
- **If a tester wants to fill in a HIN anyway:** it needs to be exactly 3 letters followed by 9 letters/numbers, 12 characters total — e.g. `ABC123456789`.
- **If a tester wants to fill in a Registration Number anyway:** for a US boat, 2 letters (a state code) + 4 to 7 digits + 2 letters, e.g. `WN1234AB`; for a Canadian boat, the letter `C` + 4 to 8 digits + 2 letters, e.g. `C1234AB`.
- **Password rule, if they ask why it's rejecting theirs:** at least 10 characters, one uppercase, one lowercase, one number, and one special character from `! $ % * #` — don't give them a password to use, since watching whether the live rule-checklist actually helps them get there is part of what's being tested.

## Beta Tester Questions (Look, Feel, Functionality)

Draft question set for a non-programmer beta tester, meant to be answered live or in writing and turned into actionable fixes. Covers the Moffat Bay Marina site: the public pages (Landing, About Us with the marina's contact info, Wait List) and the signed-in slip booking flow (Registration, Login, Reservation, Look Up Reservation, Reservation Summary, My Fleet / Edit User Info).

### Core Questions

These five questions meet the *requirements* of the assignment.  It will give us (hopefully) usefull feedback on the site that we can turn into something actionable.

1. Was the website easy to navigate, and could you find the main pages without help?
2. Were the instructions, labels, buttons, and forms clear and easy to understand?
3. Did anything on the website feel confusing, broken, hard to read, or inconsistent?
4. Did the main features work the way you expected, such as registering, logging in, making or viewing a reservation, and updating account information?
5. What is one thing you would improve about the website before it is considered finished?

### Deeper Follow-Ups (optional — use if a tester has time or a short answer above needs unpacking)

The five core questions above overlap with several of these by design; treat these as the "why" behind a short answer, not a second required round (if the person you get to help you is willing to sit through a longer question session.)

**First impressions / visual design**

1. When the Landing page first loaded, what was the very first thing you noticed, and was it what you'd expect to notice first on a marina slip-booking site?
2. On a scale of 1-5, how "professional" or "trustworthy" does the site look? What specifically made you rate it that way?
3. Were the colors, fonts, and images consistent from page to page, or did anything feel like it belonged to a different site?
4. Was any text too small, hard to read against its background, or cut off/overlapping on your screen?

**Navigation**

5. Without me telling you, could you find the page to book a slip within 10 seconds? If not, where did you look first?
6. Did you ever feel lost or unsure what page you were on, or how to get back to where you started?
7. Are the menu/button labels clear, or did any of them make you guess what would happen when you clicked?

**Core functionality — registration & login**

8. Walk me through registering an account; was anything confusing, and did the error messages (if you triggered any, like a bad email format) make sense?
9. After logging in, was it obvious what to do next?

**Core functionality — booking flow**

10. When making a reservation, did you always know what step you were on and what was left to do?
11. Did the site clearly confirm your reservation was successful, and did the confirmation give you enough detail (dates, price, confirmation number) to feel sure it worked?
12. Could you look up an existing reservation without help? What information did it ask for, and did that feel reasonable?

**Errors and edge cases**

13. Did you encounter anything that looked broken? A button that did nothing, a page that didn't load, a typo, or an error message that didn't make sense?
14. If you entered something wrong on purpose (blank field, bad email, unavailable dates), did the site tell you clearly what to fix?

**Overall**

15. If a friend actually needed a slip for their boat at Moffat Bay, would this site give them enough confidence to book one through it? Why or why not?

**Optional extras**

16. How did the site feel on your phone, if you tried it there?
17. How would you rate the page load speed? Did anything feel slow?
18. What's one feature you wished the site had that it doesn't?
19. Describe the site in three words.
20. Was there any point where you wanted to give up or ask for help? What caused it?
