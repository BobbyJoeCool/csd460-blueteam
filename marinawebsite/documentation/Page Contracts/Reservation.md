# Page Contract: Reservation (Book a Slip)

## Page Name

Reservation (Book a Slip)

## Module / Week

Module 6 / Week 5 (Sep 7 – Sep 13, 2026)

## Assigned

- Front End: Robert
- Back End: Sara
- Testing: Carolina

## Open Questions / Decisions Needed

### Front End Owns

- [x] **Form field `name` attributes:** Decided, see [Front End Variables](#front-end-variables) below.
- [x] **Date input format:** A plain `<input type="date">`, so it always submits `yyyy-MM-dd`. Won't accept anything before today.
- [x] **Slip selection UI:** Decided, see [Choosing a Slip Size](#choosing-a-slip-size) below.
- [x] **Boat selection UI:** Decided, see [Choosing a Boat](#choosing-a-boat) below.
- [x] **Dock selection UI:** Decided, see [Choosing a Dock](#choosing-a-dock) below.

---

### Choosing a Slip Size

The marina's three sizes sit across the top of the page as cards, showing how many of each are free right now, what each one suits, and a name for it (Standard, Premier, Grand).

**Nothing is picked on those cards.** They're there to show what's available. A boat only fits one size (BR-09), so the boat is what decides it. Pick a boat and the right card lights up with a "Fits your boat" tag, and the other two fade back. Nobody picks slip A-7 off a map either, the system still assigns the actual slip.

Correcting myself here: an earlier version of this contract said the Module 2 wireframe had no slip picker on it, and used that to justify not building one. It does have one. What it's picking is a slip *size* rather than a particular slip, so we land in the same place, but the reasoning was wrong.

The counts on those cards are the whole marina, added up from the three docks. There's only one availability figure coming from the back end and it's per dock, so the totals can't drift away from the per-dock numbers underneath them.

The rest of the page follows the wireframe too, four steps down the left (boat, dock, electric, start date) with the Reservation Summary adding up down the right.

### Choosing a Boat

A dropdown of boats they already own, by name with the length next to it, like "Gullwing - 32.0 ft".

Boat name and length aren't typed in by hand, which covers two of the three things the assignment asks for. If someone can retype them then someone can claim their 44 ft boat is 24 ft and book a slip it doesn't fit in, and it'd mean a second version of "this boat" floating around that never connects to the real one.

Boat details are optional at signup, so a customer can arrive owning nothing. In that case the dropdown is greyed out, the button is off, and a Register a Boat panel opens by itself. If they do have boats there's a "Register another boat" button next to the dropdown.

That panel reuses the boat fields off the Registration page rather than me building a second copy of the same form. **Saving from it doesn't reload the page**, which is the important part. The boat gets saved in the background, turns up in the dropdown already selected, and anything already filled in is still sitting there. It's the first thing on the site that saves without reloading, and it's why the shared status popup in the header exists at all, since there's no new page for a confirmation to appear on.

**Fixed since first built:** the panel's page-behind-it originally kept scrolling while the panel was open (and the mouse wheel would inconsistently scroll the panel or the page underneath it). The main page's scroll is now locked for as long as the panel is open (`document.body.style.overflow = "hidden"`, cleared on close), and the panel's own header (close button, title) is pinned with `position: sticky` so it stays visible even if the form inside scrolls.

### Choosing a Dock

The three docks sit in different parts of the marina, which is a real difference worth letting someone choose. So step 2 is three cards, one per dock, with a description on each and how many slips are free there.

**Update, dock naming/landmarks changed (`MoffatBayMarinaDB_V1-7-0_update.sql`):** originally Dock A was described as nearest the Ship Store, C nearest the Office, Restaurant and Fuel Dock, and B in between. That's been replaced with a clearer compass-name-plus-single-landmark scheme, closer to what `marina_a.png` actually shows: **Dock A is the Eastern Dock**, closest to the Ship Store; **Dock B is the Central Dock**, closest to the Office & Restaurant (moved here from Dock C's description — the map places the Office & Restaurant marker measurably closer to B); **Dock C is the Western Dock**, closest to the Fueling Station only. Each dock's description is now three lines (name, compass label, landmark) rather than one sentence, rendered with `white-space: pre-line` in `reservation.css` so the dock cards show it as a short stat block instead of a run-on sentence.

**Also added:** a "Pick a dock for me" button under the dock cards, for anyone with no preference. It checks the real dock radio with the most free slips of the boat's size — no new server endpoint, it's a client-side convenience in `reservation.js` that just selects one of the existing radios, so it submits exactly like a manual pick. Ties are broken with `Math.random()` rather than always favoring the same dock.

**It only ever shows counts for the size the chosen boat needs.** A dock with three 26 ft slips free is no use to a 40 ft boat, so showing its total would be actively misleading. Until a boat is picked the cards can't say anything useful and sit greyed out. A dock with nothing of the right size can't be picked, and says so on the card rather than just fading.

The marina map (`Source_Information/marina_a.png`, copied to `webapp/images/marina_a.png`) sits underneath the cards in that same step, since that's where someone is deciding and it's the thing that makes the choice mean anything. It carries a caption repeating which slip numbers are which size, because that information is only in the image otherwise, and a long alt description saying the same thing for anyone who can't see it.

This doesn't change slip assignment. The customer picks a dock, and the system still picks the actual slip within it.

### Prices

\$10.50 a month for every foot of the boat, plus \$10.50 a month flat if they want electric. Both live in the `Rate` table (added in `MoffatBayMarinaDB_V1-5-0_update.sql`) and neither is written into the page, so a price change doesn't mean editing JavaScript, it means updating the database.

Two things people get backwards, so they're stated at the top of the page rather than left to be worked out from the total. The rent goes by the **boat's** length, not the slip's size, so a 32 ft boat in a 40 ft slip pays \$336.00 and not \$420.00. And electric is flat, the same \$10.50 whether the boat is 20 ft or 50 ft. That boat with electric comes to \$346.50 a month.

Worth knowing before it gets logged as a bug: **the 60 reservations already seeded don't follow this.** They were priced per slip size (\$485 / \$585 / \$685) with nothing to do with boat length and no electric fee, because they predate the rule. Left alone on purpose, since every reservation records what it was actually sold at.  (This can be left alone in the data as a legacy rule, or updated to match the old pricing.)

### When a Size Is Full

The page knows how many slips are free before anyone touches anything, so the moment they pick their boat it can say something. They don't fill the whole form in and find out when they press the button.

Full means every dock, not just one. If Dock A has no 40 ft slips left but B does, that isn't full, they just can't have A. It's only a wait list case when there's nowhere in the marina for that size. If they're told at submit rather than up front, the same holds: the dock they picked filling up while others still have room is a different thing from the size going, and only the second one gets the wait list question.

If the size is full they're told, then asked whether they want the wait list for it, and either way no reservation is made. If they're already waiting for that size the Join button is replaced with a line saying so, since double-clicking shouldn't put anyone on a list twice.

It's a courtesy though, not a promise. If the page sits open while someone else takes the last 40 ft slip, what's on screen is out of date, so the server has the final say on submit and can still come back and say the size went. Same message and same question either way, so from the customer's side it's one behaviour that turned up a bit later than usual.

**Boats over 50 ft are a separate case and get no wait list offer.** There's no size bigger to wait for, so offering it would be offering something that can never happen. They get the marina's phone number instead. Registration accepts a length up to 999.9 ft, so a 60 ft boat can genuinely exist on an account.

The assignment asks to be able to cancel a reservation, which should exists on the Reservation Lookup Page or the Reservation Summary Page (probably the Reservation Summary Page, as the Reservation Lookup can redirect to the Reservation Summary Page when a reservation is found).

### Back End Owns

**Update: this whole list was written while the page ran on stand-in data. All of it is now built.** Left the original wording below (with the answer folded in) rather than deleting the checklist, since it still documents exactly what each response needs to look like.

- [x] **Authentication:** Signed in required. `sessionScope.customerId` from `LoginServlet`, never read off the form. Signed out, the page becomes the sign-in prompt.
- [x] **The customer's boats, on page load:** Built — `ReservationServlet.doGet()` calls `BoatDAO.findByCustomerId()`, then fills in slip size and monthly cents per boat (`slipSizeFor()` / `toCents()`) before handing the list to the JSP as `ownedBoats`. Matches the shape asked for exactly: id, name, length, slip size (0 if over 50 ft), whole-cents monthly cost, and `hasActiveReservation`. An empty list (`ownedBoats` empty) is what makes `boatSelect.disabled` true, which is what auto-opens the Register a Boat panel.
- [x] **The docks, with how many slips of each size are free on each one:** Built — `ReservationDAO.findDockAvailability()`, returned as `docks` (id, dock number, description, and a `26`/`40`/`50` count map with explicit zeroes, never a missing key). Rendered into the page as the `dockAvailability` JSON script tag `reservation.js` reads on load.
- [x] **The two rates:** Built — `Rate` table (`SLIP_PER_FOOT_MONTHLY`, `ELECTRIC_MONTHLY`), read via `ReservationDAO.getRate()`, exposed to the page as `perFootCents`/`electricCents` (confirmed still in whole cents per tenth-of-a-foot, `1050` not `105`, matching the warning here).
- [x] **Saving a boat from the panel:** Built — `ReservationBoatServlet` (`/reservation/boat`). Success: `{"ok":true,"boatId":...,"boatName":...,"boatLength":...,"slipSizeFt":...,"monthlyCents":...}` — the same shape as one entry in the page-load boat list, as asked for below. Failure: `{"ok":false,"error":"..."}`, plain enough to show as-is. **Also since fixed:** the servlet originally had no `@MultipartConfig`, so `reservation.js` posting this form as `FormData` (always `multipart/form-data`) meant the server never actually saw any of the submitted fields — every save looked like a blank submission and failed with "required" errors no matter what was typed. Fixed by adding `@MultipartConfig` to both this servlet and `ReservationServlet`. Also added: saving now requires at least one of HIN or Registration Number (previously neither was ever required, matching Registration's rule — this page's rule is deliberately stricter, since you can't reserve a slip for a boat nobody can identify).
- [x] **A successful booking:** Built — `{"ok":true,"confirmationNumber":"MB-00061"}`, and the page redirects (`window.location.href`, not a form submit) to `/reservationSummary?confirmation=MB-00061` — **note: no `.jsp`** (see the correction under [Handing over to the summary page](#handing-over-to-the-summary-page) below, this section originally said `reservationSummary.jsp`, which is wrong).
- [x] **A failed booking:** Built, and told apart exactly as asked: `{"ok":false,"boatError":"..."}`, `{"ok":false,"dockError":"..."}`, `{"ok":false,"dateError":"..."}`, and for a full size, `{"ok":false,"sizeFull":true,"slipSizeFt":40}` (marina-wide) or the same plus `"dockId":3` (just that one dock, so the page greys out only that dock's card for that size instead of the whole size).
- [x] **Joining the wait list:** Built (this was the last piece finished) — `ReservationWaitlistServlet` (`/reservation/waitlist`), takes `slipSizeFt`, answers `{"ok":true}`, `{"ok":false,"alreadyWaiting":true}`, or `{"ok":false,"error":"..."}`. `WaitListDAO.isWaiting()` is checked before `WaitListDAO.insert()` specifically so a double-click (or the "already waiting" case) can't write a second `Waiting` row for the same customer/size. **Scope note:** only the "join" side is built. There's no way yet to look the wait list up, see your position in it, or cancel an entry — that's the separate, not-yet-built Wait List Lookup page (see its own contract).
- [x] **Is electric its own figure or folded into the total?** Its own. The summary shows it on a separate line, only when the box is ticked.
- [x] **Servlet URL mappings:** Built — `/reservation` (page load + booking), `/reservation/boat` (boat save), `/reservation/waitlist` (wait list join).
- [x] **Cancelling a reservation:** Built, and landed where this section guessed it would — on the Reservation Summary page (`ReservationSummaryServlet`, `POST` with `action=cancel`), not the Reservation Lookup page.

#### How the boat list updates

Worth writing out, because "it appears in the dropdown" hides a few things that have to be true.

When someone saves a boat from the panel, I need back an id, the name, the length, the slip size it needs, and what it costs a month in cents. **The same shape as one entry in the page-load boat list**, because it's going into the same dropdown and the page can't have two ideas of what a boat looks like. If it comes back in a different shape I have to write a second lot of code to unpack it, and the two will drift.

Given that, the page then, without reloading:

1. adds the boat to the dropdown and selects it
2. re-does the slip size cards, so the size it needs lights up
3. re-does the dock cards, so they show counts for that size
4. re-does the price and the summary
5. closes the panel and says "Boat saved" in the header popup

and touches nothing else. A start date typed in before the panel was opened is still sitting there afterwards. That's the whole reason this saves in the background instead of posting the page, so it's the thing to actually check when testing it.

You can also send a refreshed `docks` array back with it and I'll use it. Registering a boat doesn't use up a slip so nothing really moves, but it's a free chance to refresh numbers that may have gone stale while the page sat open. Entirely optional, the page is fine without it.

#### Handing over to the summary page

On success the page sends them to
`/reservationSummary?confirmation=MB-00061` (**correction: not `reservationSummary.jsp`** — going straight at the JSP would skip `ReservationSummaryServlet` entirely and render an empty page, same class of bug as hitting `/reservation.jsp` directly instead of `/reservation`), so the summary page looks the reservation up fresh from that number. A redirect and not a forward, because a forward would mean a refresh could book a second slip.

**Resolved — built as described:** Carolina and Miguel's side did agree to this handshake. `ReservationSummaryServlet.doGet()` reads `confirmation` from the query string and looks it up via `ReservationDAO.findDetailsByConfirmation()`.

**Also resolved:** confirmation numbers do run in sequence (`MB-00001` up), so the summary page does check ownership — `ReservationSummaryServlet` compares the looked-up reservation's `customerID` against `sessionScope.customerId` and shows the same "reservation not found" message either way (no such confirmation, or one that isn't yours) rather than distinguishing the two, so probing sequential numbers can't be used to tell which confirmation numbers are real.

#### Why cents

Send the price already worked out, and as a whole number of cents rather than dollars. Two reasons. If the page knows the rate it'll end up doing the arithmetic, and then two places know how the marina prices things and they drift apart the first time one gets fixed. And JavaScript is genuinely bad at decimal maths, 32.7 × 10.5 comes out as 343.35000000000002 and that lands on somebody's screen. Whole cents means I only ever add integers.

#### Nothing can read the boats back yet

**Resolved.** This used to be the biggest open item on the page — `BoatDAO` only had `insertBoat`/`insertOwnership`, nothing that read boats back. `BoatDAO.findByCustomerId(Connection, int customerId)` now exists and is what `ReservationServlet.doGet()` calls for the page-load boat list.

## Scaffold Include

```jsp
<jsp:include page="/includes/header.jsp">
    <jsp:param name="activePage" value="reservation" />
</jsp:include>

<!-- Reservation page content -->

<jsp:include page="/includes/footer.jsp" />
```

> The `activePage` value `"reservation"` must match what the header checks.

## Front End Variables

What the page sends when someone books.

| Field Name | Input Type | Required? | Format / Notes |
| --- | --- | --- | --- |
| `boatId` | select | Yes | Which of their boats it's for. Name and length ride along with it, so neither is sent separately. Greyed out when they own none. |
| `dockId` | radio | Yes | Which dock they want. Only the docks with a free slip of their boat's size can be picked. |
| `checkInDate` | date | Yes | Always `yyyy-MM-dd`. Won't take anything before today. Maps to `Reservation.startDate`. |
| `wantsElectric` | checkbox | No | Off by default, and only present when ticked, the way checkboxes work. |

No boat name, no boat length, no slip number, no customer ID, no price. Name and length belong to the boat record, nobody picks a slip, only a dock, we know who they are because they're signed in, and sending a price from the page would just invite somebody to send a different one.  THe slip size is already calculated.

**The Register a Boat panel** posts on its own and never rides along with a booking. Same fields and same names as the Registration page's boat card, so nothing needs renaming, see that contract's Front End Variables for the full list.

**Joining the wait list** sends one thing, `slipSizeFt`, which is `26`, `40` or`50`. It needs an answer back rather than just doing it, see the wait list item in [Back End Owns](#back-end-owns).

## Back End Parameters

**Filled in — built.**

| Parameter Name | Type | Source (form field / session / query string) | Notes |
| --- | --- | --- | --- |
| `customerId` | `Integer` | Session (`sessionScope.customerId`) | Never read off the form |
| `boatId` | `Integer` | Form field | Must be one of the signed-in customer's own boats — checked against a fresh `BoatDAO.findByCustomerId()` lookup, not trusted from the request |
| `dockId` | `Integer` | Form field | |
| `checkInDate` | `LocalDate` | Form field | Must parse and not be before today |
| `wantsElectric` | `boolean` | Form field | `true` only if the parameter is present at all, matching how an unchecked checkbox submits nothing |
| `slipSizeFt` (wait list only) | `Integer` | Form field | Must be `26`, `40`, or `50` |

## Database Returns

**Filled in — built.**

| Method / Query | Parameters In | Returns | Notes |
| --- | --- | --- | --- |
| `BoatDAO.findByCustomerId()` | `Connection`, `customerId` | `List<Boat>` | Empty list if the customer owns no boats |
| `ReservationDAO.findDockAvailability()` | `Connection` | `List<DockAvailability>` | One entry per dock, counts for all three sizes, zero rather than a missing key |
| `ReservationDAO.getRate()` | `Connection`, `rateCode` | `BigDecimal` | Throws `SQLException` if the rate code isn't found — a missing rate is a configuration bug, not a normal "no data" case |
| `ReservationDAO.findAvailableSlip()` | `Connection`, `dockId`, `slipSizeFt` | `Integer` slip id, or `null` | `null` means that dock has nothing free of that size right now. Locks the returned row with `FOR UPDATE` so two requests can't both grab the last slip |
| `ReservationDAO.countAvailableForSize()` | `Connection`, `slipSizeFt` | `int` | Marina-wide count, used to tell "just this dock is full" from "the whole size is gone" |
| `ReservationDAO.insert()` | `Connection`, `Reservation` | `String` confirmation number | Inserts with a temporary placeholder, then updates to the final `MB-#####` format once the generated `reservationID` is known |
| `WaitListDAO.isWaiting()` | `Connection`, `customerId`, `slipSizeFt` | `boolean` | Checked before `insert()` so a customer can't end up with two `Waiting` rows for the same size |
| `WaitListDAO.insert()` | `Connection`, `customerId`, `slipSizeFt` | none (throws on failure) | |

## Validation Rules

- **Client-side (UX only, not trusted):** A boat has to be picked, then a dock, **then a start date** (**updated** — originally only boat + dock gated the button; the date is now checked too, both on boat/dock change and on the date field's own `change` event, not just at submit time) before the button turns on. The date picker won't offer anything earlier than today. Availability is checked against the on-screen numbers every time the boat changes, and the button switches off when the size is full or nothing is picked yet. **Added:** a status line under the button (`#submitBlockedReason`) now names whichever one of those is still missing ("Choose a dock to continue.", "Choose a start date to continue.", etc.), instead of just a disabled button with no explanation. In the boat panel, name and length are required, and HIN, registration number and boat year get format-checked if they're filled in; **also now required: at least one of HIN or Registration Number** (previously neither was ever required — this page is deliberately stricter than Registration here, since a boat with no identifier at all shouldn't be reservable). Those are the same checks Registration does, and literally the same code: `registration.js` can't be loaded on this page (it wires up elements that only exist over there and would throw), but `formValidation.js` is already here via the header, so the rules are shared rather than copied.
- **Server-side (source of truth):** Built, in `ReservationServlet.doPost()` and `ReservationBoatServlet.doPost()` — everything the client-side list above checks gets checked again. Boat ownership is re-verified against a fresh DB lookup (never trusts a submitted `boatId` just because it parsed), the slip pick is re-derived from boat length server-side, and `findAvailableSlip()` locks its result with `FOR UPDATE` so two requests racing for the last slip of a size can't both win. None of the client-side conveniences (greyed-out button, date picker's minimum, the boat panel's HIN-or-reg-number nudge) are trusted as protection on their own.

## Error Handling

| Condition | Message Shown | Where Displayed |
| --- | --- | --- |
| Not signed in | "Please sign in to reserve a slip." | The sign-in popup, opened for them, returning them here |
| They own no boats | "You'll need a registered boat before you can reserve a slip." | Above the boat panel, which opens on its own |
| No boat picked | "Select a boat for this reservation." | Under the dropdown |
| The boat isn't theirs | "Select a boat for this reservation." | Under the dropdown. Same message on purpose, so a probed boat id can't be told from an empty one |
| No dock picked | "Choose which dock you'd like to be on." | Under the dock cards |
| Date missing or in the past | "Choose a check-in date of today or later." | Under the date field |
| Size is full, however it's caught | "All of our 40 ft slips are currently reserved." plus the wait list question | The availability panel under the cards, button off |
| Boat over 50 ft | "We don't have a slip that fits a boat over 50 feet. Please call the marina at (360) 555-0142." | The availability panel, button off, no wait list offered |
| Boat already has a reservation | "Gullwing already has an active reservation." | Under the dropdown |
| Already on the wait list | "You're already on the wait list for a 40 ft slip." | The wait list panel, replacing the Join button |
| Couldn't be added to the wait list | "You could not be added to the wait list. Please try again." | The wait list panel |
| Wait list joined | "You're on the wait list for a 40 ft slip." | The wait list page, after they're sent there |
| Boat panel details wrong | Whatever was wrong with it | Inside the panel, which stays open |
| Boat panel has neither HIN nor Registration Number (**new**) | "Enter either a HIN or a Registration Number." | Inside the panel, both client- and server-side |
| Boat already registered | "That HIN or boat registration is already in use." | Inside the panel |
| Booking couldn't be saved | "Your reservation could not be completed. Please try again." | Banner at the top of the form |
| Boat couldn't be saved | "Your boat could not be saved. Please try again." | Inside the panel |

Confirmations go through the shared status popup in the header. Errors don't, and shouldn't. An error has to stay put until it's dealt with and sit next to whatever's wrong, and a message that removes itself after five seconds is the wrong shape for that.

## Login State Differences

| Item | Logged In | Logged Out |
| --- | --- | --- |
| The Page | Comes up normally, pulling a the list of boats the customer owns | pulls the login popup, blocking the page |
