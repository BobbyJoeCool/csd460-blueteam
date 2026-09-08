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

A dropdown of boats they already own, by name with the length next to it, like "Gullwing — 32.0 ft".

Boat name and length aren't typed in by hand, which covers two of the three things the assignment asks for. If someone can retype them then someone can claim their 44 ft boat is 24 ft and book a slip it doesn't fit in, and it'd mean a second version of "this boat" floating around that never connects to the real one.

Boat details are optional at signup, so a customer can arrive owning nothing. In that case the dropdown is greyed out, the button is off, and a Register a Boat panel opens by itself. If they do have boats there's a "Register another boat" button next to the dropdown.

That panel reuses the boat fields off the Registration page rather than me building a second copy of the same form. **Saving from it doesn't reload the page**, which is the important part. The boat gets saved in the background, turns up in the dropdown already selected, and anything already filled in is still sitting there. It's the first thing on the site that saves without reloading, and it's why the shared status popup in the header exists at all, since there's no new page for a confirmation to appear on.

### Choosing a Dock

Added Sep 8, from the discussion about giving people a say in where they end up.

The three docks sit in different parts of the marina, which is a real difference worth letting someone choose. Dock A is nearest the Ship Store, C is nearest the Office, Restaurant and Fuel Dock, and B is in between. So step 2 is three cards, one per dock, with that description on each and how many slips are free there.

**It only ever shows counts for the size the chosen boat needs.** A dock with three 26 ft slips free is no use to a 40 ft boat, so showing its total would be actively misleading. Until a boat is picked the cards can't say anything useful and sit greyed out. A dock with nothing of the right size can't be picked, and says so on the card rather than just fading.

The marina map (`Source_Information/marina_a.png`, copied to `webapp/images/marina_a.png`) sits underneath the cards in that same step, since that's where someone is deciding and it's the thing that makes the choice mean anything. It carries a caption repeating which slip numbers are which size, because that information is only in the image otherwise, and a long alt description saying the same thing for anyone who can't see it.

This doesn't change slip assignment. The customer picks a dock, and the system still picks the actual slip within it. It's only the choice that's new, not the picking.

### Prices

$10.50 a month for every foot of the boat, plus $10.50 a month flat if they want electric. Both live in the `Rate` table (added in `MoffatBayMarinaDB_V1-5-0_update.sql`) and neither is written into the page, so a price change doesn't mean editing JavaScript.

Two things people get backwards, so they're stated at the top of the page rather than left to be worked out from the total. The rent goes by the **boat's** length, not the slip's size, so a 32 ft boat in a 40 ft slip pays $336.00 and not $420.00. And electric is flat, the same $10.50 whether the boat is 20 ft or 50 ft. That boat with electric comes to $346.50 a month.

Worth knowing before it gets logged as a bug: **the 60 reservations already seeded don't follow this.** They were priced per slip size ($485 / $585 / $685) with nothing to do with boat length and no electric fee, because they predate the rule. Left alone on purpose, since every reservation records what it was actually sold at.

### When a Size Is Full

The page knows how many slips are free before anyone touches anything, so the moment they pick their boat it can say something. They don't fill the whole form in and find out when they press the button.

Full means every dock, not just one. If Dock A has no 40 ft slips left but B does, that isn't full, they just can't have A. It's only a wait list case when there's nowhere in the marina for that size. If they're told at submit rather than up front, the same holds: the dock they picked filling up while others still have room is a different thing from the size going, and only the second one gets the wait list question.

If the size is full they're told, then asked whether they want the wait list for it, and either way no reservation is made. If they're already waiting for that size the Join button is replaced with a line saying so, since double-clicking shouldn't put anyone on a list twice.

It's a courtesy though, not a promise. If the page sits open while someone else takes the last 40 ft slip, what's on screen is out of date, so the server has the final say on submit and can still come back and say the size went. Same message and same question either way, so from the customer's side it's one behaviour that turned up a bit later than usual.

**Boats over 50 ft are a separate case and get no wait list offer.** There's no size bigger to wait for, so offering it would be offering something that can never happen. They get the marina's phone number instead. Registration accepts a length up to 999.9 ft, so a 60 ft boat can genuinely exist on an account.

On "cancel the reservation", which the assignment asks for: the reservation just never gets made. There's nothing to cancel because nothing was booked, and a reservation can't exist without a slip attached, which is the whole problem in this situation. Making a fake one so we could immediately cancel it would put something untrue in the marina's records. "Cancelled" keeps its real meaning, a reservation that existed, held a slip, and got ended later.

### Back End Owns

The page is built and running on stand-in data, so this list is what it's waiting for. Names are just what the stand-in uses, rename anything as long as I know before I swap it out.

- [x] **Authentication:** Signed in required. `sessionScope.customerId` from `LoginServlet`, never read off the form. Signed out, the page becomes the sign-in prompt.
- [ ] **The customer's boats, on page load:** For each one an id, the name, the length, which slip size it needs (26/40/50, or 0 if it's over 50 ft), **what it costs a month in whole cents**, and whether it already has a reservation. See [Why cents](#why-cents) below. Empty list if they own none, which is what opens the boat panel, so an empty list and no answer have to look different.
- [ ] **The docks, with how many slips of each size are free on each one:** An id, the letter, the description, and counts for all three sizes with a zero where there are none rather than the size being left out. Per dock is the only availability figure I need, the totals on the size cards get summed from it. This is the one thing that makes the instant warning possible.
- [ ] **The two rates:** `SLIP_PER_FOOT_MONTHLY` and `ELECTRIC_MONTHLY` from the `Rate` table, in cents. Only for the wording of the note at the top, the boats arrive already priced. Careful, the per-foot one is **1050** for $10.50, not 105. There's a 105 in the arithmetic because boat lengths carry one decimal, so it's cents per tenth of a foot. I mixed those up and the page advertised slips at $1.05 a foot until I caught it.
- [ ] **Saving a boat from the panel:** Whether it worked; if so the new boat, and if not a message plain enough to show as-is. See [How the boat list updates](#how-the-boat-list-updates) below, it matters more than it looks.
- [ ] **A successful booking:** The confirmation number. Please send them somewhere fresh rather than leaving them on the submitted form, it's the one place where a refresh would genuinely book a second slip. See [Handing over to the summary page](#handing-over-to-the-summary-page) below.
- [ ] **A failed booking:** These need telling apart, because they land in five different places on the page and are worded differently: the size filled up marina-wide, just the dock they picked filled up, something wrong with the boat, something wrong with the date, or anything else. If it's the dock, say which one, so I can grey out that one and leave the others alone rather than blanking the whole size. One generic failure can't be put in the right place. Also please send back what they typed, still filled in.
- [ ] **Joining the wait list:** Takes `slipSizeFt` and **answers back**. Either it worked, or they were already on the list for that size. I need telling which, because the page can't know on its own and the second one has its own message. `WaitList` has nothing stopping duplicate rows, and two "Waiting" rows for one person would throw off the average wait time BR-20 wants, so please don't write a second one either.
- [x] **Is electric its own figure or folded into the total?** Its own. The summary shows it on a separate line, only when the box is ticked.
- [ ] **Servlet URL mappings:** For the booking, the boat save, and the wait list join.

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

On success the page sends them to `reservationSummary.jsp?confirmation=MB-00061`, so the summary page looks the reservation up fresh from that number. A redirect and not a forward, because a forward would mean a refresh could book a second slip.

**This needs Carolina and Miguel to agree, it isn't mine to decide.** Their contract still has "how does this page receive the reservation data" open and calls it the most critical handshake, and the page above has effectively answered it by shipping. Happy to change what I send if they'd rather have it another way, I just need telling.

One thing to raise with them either way: confirmation numbers run in sequence (MB-00001 up), so anyone can put someone else's in the address bar. The summary page needs to check the reservation actually belongs to whoever is signed in before it shows anything. Their contract has that as an open question too.

#### Why cents

Send the price already worked out, and as a whole number of cents rather than dollars. Two reasons. If the page knows the rate it'll end up doing the arithmetic, and then two places know how the marina prices things and they drift apart the first time one gets fixed. And JavaScript is genuinely bad at decimal maths, 32.7 × 10.5 comes out as 343.35000000000002 and that lands on somebody's screen. Whole cents means I only ever add integers.

#### Nothing can read the boats back yet

Worth saying plainly because it's easy to assume it's already there. The boats are in the database, Registration writes them at signup, but `BoatDAO` only has `insertBoat` and `insertOwnership` and `CustomerDAO` has nothing about boats. That query is new work, and it's the biggest thing the page is waiting on.

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

That's all of it. No boat name, no boat length, no slip number, no customer ID, no price. Name and length belong to the boat record, nobody picks a slip, only a dock, we know who they are because they're signed in, and sending a price from the page would just invite somebody to send a different one.

There's no slip size field either. An earlier version of the cards had radio buttons and it would have been, but they're display-only now and the boat decides the size.

**The Register a Boat panel** posts on its own and never rides along with a booking. Same fields and same names as the Registration page's boat card, so nothing needs renaming, see that contract's Front End Variables for the full list.

**Joining the wait list** sends one thing, `slipSizeFt`, which is `26`, `40` or `50`. It needs an answer back rather than just doing it, see the wait list item in [Back End Owns](#back-end-owns).

## Back End Parameters

*Sara's to fill in, see [Back End Owns](#back-end-owns) above for what the page needs.*

## Database Returns

*Sara's to fill in.*

## Validation Rules

- **Client-side (UX only, not trusted):** A boat has to be picked, and then a dock, before the button turns on. The date is required and the picker won't offer anything earlier than today. Availability is checked against the on-screen numbers every time the boat changes, and the button switches off when the size is full or nothing is picked yet. In the boat panel, name and length are required, and HIN, registration number and boat year get format-checked if they're filled in. Those are the same checks Registration does, and literally the same code: `registration.js` can't be loaded on this page (it wires up elements that only exist over there and would throw), but `formValidation.js` is already here via the header, so the rules are shared rather than copied.
- **Server-side (source of truth):** Sara's to define. What matters from my side is that I've assumed **all of the above gets checked again.** Anyone can go round a browser, so the numbers on screen, the greyed-out button and the date limit are conveniences and none of them are protection. The page is built to be told "no" after the fact and handle it properly.

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
| Boat already registered | "That HIN or boat registration is already in use." | Inside the panel |
| Booking couldn't be saved | "Your reservation could not be completed. Please try again." | Banner at the top of the form |
| Boat couldn't be saved | "Your boat could not be saved. Please try again." | Inside the panel |

Confirmations go through the shared status popup in the header. Errors don't, and shouldn't. An error has to stay put until it's dealt with and sit next to whatever's wrong, and a message that removes itself after five seconds is the wrong shape for that.

## Login State Differences

| Item | Logged In | Logged Out |
| --- | --- | --- |
| The Page | Comes up normally, pulling a the list of boats the customer owns | pulls the login popup, blocking the page |
