# Page Contract: Reservation (Book a Slip)

## Page Name

Reservation (Book a Slip)

## Module / Week

Module 6 / Week 5 (Sep 7 – Sep 13, 2026)

## Assigned

- Front End: Robert
- Back End: Sara
- Testing: Carolina

> **How to read this contract:** this is the Front End half. It describes what the page looks like, what it asks the customer for, what it sends, and what it needs handed back to it. It deliberately does **not** describe how any of that gets saved or looked up — that's Sara's half, and the Back End Parameters and Database Returns sections below are left for her to fill in rather than guessed at here.

---

## What This Page Has To Do

From the assignment, in plain terms:

- Let a customer reserve a slip. The reservation has to actually be saved.
- The customer picks their boat's length, their boat's name, and a check-in date.
- The marina has a fixed number of slips in each size — 30 of the 26-foot, 24 of the 40-foot, 18 of the 50-foot. Those come off the marina map, and they're written down in `definitions_decisions.md` under "Dock and Slip Sizes."
- If every slip that fits their boat is already taken, tell them so.
- Then ask whether they'd like to go on the wait list for that size, and if they say yes, put them on it.
- Either way — whether they join the wait list or not — no reservation is made.

Everything below is how the page delivers that.

---

## How Pricing Works

**$10.50 per foot of the boat, per month.** Plus an **optional electric hookup at $10.50 a month**, flat.

Two things that are easy to get wrong here:

- **The price follows the boat, not the slip.** A 32-foot boat pays for 32 feet, even though it's sitting in a 40-foot slip. Slip size decides *whether* the boat fits; boat length decides *what it costs*. These are two different numbers and the page shouldn't blur them.
- **Electric is a flat monthly fee, not per foot.** It's $10.50 whether the boat is 20 feet or 50.

Both figures already include the 5% increase — the rate used to be $10.00 per foot and $10.00 for electric. The page shows the new numbers; there's no old price displayed anywhere and no transition period to handle.

A worked example, which is also roughly what the page should show:

> **Gullwing — 32.0 ft**
> 32.0 ft × $10.50 = **$336.00 / month**
> Electric hookup: **+ $10.50 / month**
> **Total: $346.50 / month**

The total updates live as soon as a boat is picked or the electric box is ticked. Nothing needs to be asked of the server to work that out — the boat's length is already sitting in the dropdown, and both rates are fixed.

The math always lands on a whole number of cents, so there's no rounding decision to make. Boat lengths carry one decimal place, and one decimal place times $10.50 can't produce a fraction of a cent.

---

## What The Customer Fills In

Three things, and that's the whole form:

**1. Their boat** — a dropdown listing the boats they own, by name, with the length shown next to it:

> Gullwing — 32.0 ft
> Second Wind — 24.5 ft

This one control covers two of the three items the assignment asks for. Boat name and boat length aren't typed in, because they're facts about a boat the marina already has on file. Letting someone retype them would mean a customer could claim a 44-foot boat is 24 feet and book a slip it doesn't fit in, and it'd create a second, floating idea of "this boat" that never connects to the one already registered.

Each entry in the dropdown quietly carries the boat's length and the slip size it needs, so the page can price the booking and check availability the instant a boat is chosen.

**2. A check-in date** — a normal date picker. It won't accept a date in the past.

**3. Electric hookup** — an optional checkbox. Off by default. Ticking it adds $10.50 to the monthly total shown on the page.

Below those is a running summary of the monthly cost, and the Submit button.

There is **no** slip picker. The customer doesn't choose slip A-7 off a map — they say how big their boat is and one gets assigned. The Module 2 wireframe doesn't show a slip picker either, so this matches what was designed.

---

## If They Don't Have a Boat Yet

Registering a boat is optional when someone creates their account, so a customer can easily arrive here owning nothing. They also might own several — that's allowed, and the wait list exists partly because someone can be waiting for a slip before they've even bought the boat.

**Owning no boats:** the dropdown is empty and greyed out, Submit is switched off, and a "Register Your Boat" panel opens on its own with a line above it:

> You'll need a registered boat before you can reserve a slip.

**Owning at least one:** the dropdown lists them, and a "Register another boat" button sits next to it to open the same panel whenever they want.

### The Boat Panel Saves Without Leaving The Page

This is the important part, and it's the one genuinely new piece of behavior on the site.

When someone fills in the boat panel and saves it, **the page does not reload and nothing already typed is lost.** The boat is saved in the background. A moment later the new boat appears in the dropdown, already selected, the panel closes, and the price and availability update to match. The check-in date they'd already picked is still sitting there untouched.

The panel itself reuses the boat fields from the Registration page (`includes/boatInfoCard.jsp`) rather than building a second set — same fields, same labels, same live checks as they type, so it behaves exactly the way it does on Registration. It picks up the customer's country from their account, so they don't get asked for it again.

If the boat can't be saved — a length that isn't a number, a registration number already on file — the panel stays open with the reason shown inside it, and again, nothing else on the page is disturbed.

> **Note for the team:** every form on this site currently saves by submitting the page and reloading. This panel is the first thing that doesn't, because "save it without leaving the page" can't be done any other way. Nothing else on the Reservation page needs that treatment.

---

## Which Slip Size a Boat Needs

Three sizes exist. A boat goes in the smallest one it fits in:

| Boat length | Slip size it needs |
| --- | --- |
| Up to 26 feet | 26-foot |
| Just over 26, up to 40 feet | 40-foot |
| Just over 40, up to 50 feet | 50-foot |
| Over 50 feet | *nothing here fits* |

**A boat is only ever offered its own size, never a bigger one.** If the 40-foot slips are full, a 32-foot boat is told the 40-foot slips are full and offered the 40-foot wait list. It doesn't quietly get dropped into a 50-foot slip.

Two reasons. The assignment says to wait-list them "for that size slip," and a wait list entry records exactly one size — so if the page shuffled people into larger slips, nobody could say afterward what a given person was actually waiting for. It also keeps the 50-foot slips free for the boats that genuinely need them.

**Boats over 50 feet are a separate case, not a wait list case.** Registration accepts a boat length up to 999.9 feet, so a 60-foot boat can exist on someone's account. There's no 60-foot category to wait for, and offering the wait list would be offering something that can never come through. Those customers get a message pointing them at the marina's phone number instead, and no wait list prompt at all.

---

## Telling Them Straight Away When Their Size Is Full

**The customer finds out the moment they pick their boat — not after they've filled everything in and pressed Submit.**

When the page loads it's already been told how many slips of each size are free. So as soon as a boat is selected, the page can react instantly, with nothing to wait for:

| Situation | What the customer sees |
| --- | --- |
| Slips available | A quiet line: *"3 of our 50 ft slips are open."* The form works normally. |
| None available | The full notice and the wait list question. Submit is switched off — there's nothing to submit. |
| Boat over 50 feet | The over-50 message. Submit switched off, and no wait list offered. |

Same thing happens if they register a new boat mid-visit — the numbers refresh as part of saving it, so a brand new boat gets flagged just as fast.

**This is a courtesy, not a guarantee, and the page shouldn't pretend otherwise.** If someone leaves the page open while another customer books the last 40-foot slip, the count on screen is stale. The server has the final say when Submit is actually pressed, and it can still come back and say the size filled up. The page handles that by showing the exact same notice and the same wait list question it would have shown up front — so from the customer's point of view it's one consistent behavior, just arriving a few seconds later than usual.

---

## When The Size Is Full

1. **Tell them.** *"All of our 40 ft slips are currently reserved."*
2. **Ask.** *"Would you like to be added to the wait list for a 40 ft slip? We'll contact you when one opens up."* — with a "Join the wait list" button and a "No thanks" button.
3. **If they join,** they get confirmation and land on the wait list page.
4. **If they don't,** the question goes away and they stay on the page. Nothing is recorded.
5. **Either way, they do not have a reservation.**

If they're already waiting for that size, the button is replaced with *"You're already on the wait list for a 40 ft slip."* rather than letting them join twice — double-clicking a button shouldn't put someone on a list twice over.

### About "Cancel the Reservation"

The assignment says to cancel the reservation in either case. Worth being clear about what that means here, so it doesn't read like a missed requirement in the write-up:

**The reservation is never created in the first place.** There's nothing to cancel, because nothing was ever booked. A reservation record can't exist without a slip attached to it, and in this situation there is no slip — that's the entire problem. Creating a fake one just to immediately mark it cancelled would put something untrue in the marina's records.

So the attempt ends with either a wait list entry or nothing at all, and "cancelled" keeps its real meaning: a reservation that genuinely existed, held a slip, and was ended later on.

---

## Front End Variables

What the page sends when the reservation form is submitted:

| Field Name | Input Type | Required? | Format / Notes |
| --- | --- | --- | --- |
| `boatId` | select | Yes | Identifies which of the customer's boats this is for. The name and length shown in the dropdown come along with it, so neither is sent separately. Greyed out with a placeholder when they own no boats. |
| `checkInDate` | date | Yes | A standard date picker, so it always sends `yyyy-MM-dd`. Can't be earlier than today. |
| `wantsElectric` | checkbox | No | Off by default. Present only when ticked, the way checkboxes work. Adds $10.50 a month. |

**Nothing else is sent.** No boat name, no boat length, no slip number, no customer ID, no price. Name and length belong to the boat record. Nobody picks a slip. The customer is already known from being signed in. And the price is worked out from fixed rates, so sending it from the page would just be inviting someone to send a different one.

**The boat panel** (the fields from `includes/boatInfoCard.jsp`) saves on its own, separately from the reservation form — it never rides along with a booking. Its fields keep the exact names Registration already uses, so nothing has to be renamed or specially handled:

| Field Name | Input Type | Required? | Format / Notes |
| --- | --- | --- | --- |
| `boatName` | text | Yes | Up to 50 characters |
| `boatLength` | number | Yes | Up to 999.9 feet, one decimal place |
| `hin` | text | No | Up to 12 characters |
| `regNumber` | text | No | Up to 20 characters; the expected format follows the customer's country, same as on Registration |
| `boatType` | text | No | Up to 30 characters |
| `boatBeam` | number | No | Up to 999.9 feet |
| `boatYear` | text | No | Four digits, 1800 through this year |

**The wait list opt-in** sends one thing:

| Field Name | Input Type | Required? | Format / Notes |
| --- | --- | --- | --- |
| `slipSizeFt` | hidden | Yes | `26`, `40`, or `50` — which size they're waiting for |

---

## What I Need From The Back End

Not how any of it works — just what has to reach the page, and what the page will hand over.

**On page load, so the page can render at all:**

1. **The customer's current boats**, each with its name, its length, and something to identify it by. Name and length are both shown in the dropdown and the length drives the price, so a list without lengths isn't usable. If they own none, an empty list is fine and expected — that's what triggers the "register a boat first" panel. Please don't send back nothing at all in that case; an empty list and "no answer" need to look different to the page.

2. **How many slips are currently free in each of the three sizes.** All three sizes present every time, with a zero where none are free rather than the size being left out. This is the single thing that makes the instant flagging possible — without it the page can't tell anyone their size is full until after they've pressed Submit, which is the behavior we're specifically trying to avoid.

**When a boat is saved from the panel,** the page needs back: whether it worked; if it did, the new boat's name, length, and identifier so it can be dropped straight into the dropdown and selected; and a refreshed count of free slips for the size that boat needs, since it's already a round trip and that's the one number that may have gone stale. If it didn't work, a message plain enough to show the customer as-is.

**When a booking succeeds,** the page needs the confirmation number, so the customer can be sent to the summary page and see it.

**When a booking fails,** the page needs to know *which* of these it was, because they're displayed in completely different places on screen and worded differently:

- The size filled up in the meantime → the availability panel, with the wait list question attached
- Something wrong with the boat they picked → underneath the dropdown
- Something wrong with the date → underneath the date field
- Something else went wrong → a banner across the top of the form

A single generic failure message can't be placed correctly, so these do need to be distinguishable. The exact names for these are Sara's to pick — I just need them settled before I build the display, and I'll match whatever she chooses.

**A couple of small requests:**

- **Please send the customer back to the form with what they typed still in it** on a failure. Losing a check-in date because a slip filled up is a miserable experience, especially when the next thing we do is ask them to join a wait list.
- **Please send them somewhere fresh after a successful booking**, rather than leaving them sitting on the submitted form. It's the one place on this site where an accidental refresh would genuinely double-book and take a second slip out of inventory.
- **Does electric come back as its own figure, or already folded into the monthly total?** This decides whether the summary page can show "Slip $336.00 / Electric $10.50" as two lines or only a single total. I'd prefer two, but I can build either — I just need to know which before I lay out the summary.

---

## Back End Parameters

*Left for Sara — see the note at the top of this contract.*

## Database Returns

*Left for Sara — see the note at the top of this contract.*

---

## Validation Rules

**Client-side (a courtesy while they're filling it in — never the real check):**

- A boat has to be chosen before Submit switches on.
- A check-in date is required, and the picker won't offer anything before today.
- Availability is checked against the on-screen counts every time the boat selection changes, and Submit switches off when the size is full.
- Inside the boat panel, name and length are required, and HIN and registration number are checked for the right shape when filled in — the same live checks the Registration page already does, since they're the same fields.

**Server-side (the real check):** Sara's to define. What matters from my side is that the page assumes **everything above gets checked again** and doesn't treat any of it as settled. Anyone can bypass a browser entirely, so the on-screen availability count, the disabled Submit button, and the date restriction are all conveniences rather than protections. The page is built to handle being told "no" after the fact — see [Telling Them Straight Away](#telling-them-straight-away-when-their-size-is-full).

---

## Error Handling

Everything a customer might see, and where on the page it shows up:

| Condition | Message Shown | Where Displayed |
| --- | --- | --- |
| Not signed in | *"Please sign in to reserve a slip."* | The sign-in popup, opened for them, returning them here afterward |
| They own no boats | *"You'll need a registered boat before you can reserve a slip."* | Above the boat panel, which opens on its own |
| No boat chosen | *"Select a boat for this reservation."* | Under the dropdown |
| The chosen boat isn't theirs | *"Select a boat for this reservation."* | Under the dropdown — **deliberately identical to the message above**, so someone poking at boat numbers can't tell a real one from a made-up one |
| Date missing or in the past | *"Choose a check-in date of today or later."* | Under the date field |
| **That size is full** — whether caught on selection or at Submit | *"All of our 40 ft slips are currently reserved."* plus the wait list question | The availability panel above Submit; Submit switched off |
| Boat over 50 feet | *"We don't have a slip that fits a boat over 50 feet. Please call the marina at (360) 555-0142."* | The availability panel; Submit switched off, **no wait list offered** |
| That boat already has a reservation | *"Gullwing already has an active reservation (MB-00042)."* | Under the dropdown |
| Already on the wait list for that size | *"You're already on the wait list for a 40 ft slip."* | The wait list panel, replacing the Join button |
| Wait list joined | *"You're on the wait list for a 40 ft slip. We'll contact you when one opens up."* | The wait list page, after they're sent there |
| Boat panel details wrong | Whatever was wrong with it | Inside the panel, which stays open |
| Boat already registered to someone | *"That HIN or boat registration is already in use."* | Inside the panel |
| Booking couldn't be saved | *"Your reservation could not be completed. Please try again."* | A banner across the top of the form |
| Boat couldn't be saved | *"Your boat could not be saved. Please try again."* | Inside the panel |

---

## Login State Differences

| Item | Logged In | Logged Out |
| --- | --- | --- |
| Book a slip | Opens the reservation page directly | Asks the user to sign in first |
| Boat dropdown | Lists the boats they currently own | Not shown |
| Register Your Boat panel | Available | Not shown |
| Availability counts | Shown on the page | Not shown — the page is just the sign-in prompt |
| Pricing | Shown, and updates as they choose | Not shown |

The page genuinely can't work signed out — there's no way to know whose boats to list or whose name to put on a reservation. Miguel already pointed the landing page's "Reserve a Slip" button straight here for signed-in visitors, so most people arrive already sorted.

---

## Still To Sort Out With The Team

Things that aren't mine to decide alone, listed so they don't get lost:

1. **The existing reservations are priced the old way.** See [Worth Flagging](#worth-flagging-the-existing-reservations-dont-follow-this) above. Leave them as history, or reprice them?

2. **The check-in date doesn't affect what's available.** A reservation is a month-to-month lease with a start date and no end date, so a slip is either being leased right now or it isn't — there's no way to ask "will this be free in December?" So the date is collected and recorded, but it doesn't widen or narrow what the customer can book. Someone can pick a check-in date three months out and the slip is treated as taken from now. That's consistent with a lease that bills from the start date, but it isn't date-range availability, and if anyone on the team is expecting the latter, that's a schema conversation and not something this page can solve. My recommendation is to ship it this way and write the limitation down.

3. **Can one boat hold two reservations at once?** I've assumed no — one hull, one slip — and written the error message for it above. But nothing in the business rules covers it and nothing stops it happening, so it's an assumption, not a fact. If the marina would allow a boat to hold two slips, that check comes out.

4. **Boats that already have a reservation still appear in the dropdown**, marked *(reserved)*, rather than being hidden. Hiding them would make the page look broken to someone whose only boat is already docked — they'd see an empty dropdown and no explanation. Picking one gives the message above.

---

## Scaffold Include

This page includes the shared header/footer and identifies itself for nav highlighting:

```jsp
<jsp:include page="/includes/header.jsp">
    <jsp:param name="activePage" value="reservation" />
</jsp:include>

<!-- Reservation page content -->

<jsp:include page="/includes/footer.jsp" />
```

> The `activePage` value `"reservation"` must match what the header checks. See the scaffold contract for the full reference table.

`reservation.jsp` is currently just the shared "Coming Soon" placeholder. That comes out when the real form goes in.

---

## Testing Notes (Carolina)

**The wait list can't be reached on a freshly built database.** Counting what's actually seeded, every size still has room:

| Size | Total | Already reserved | **Free** |
| --- | --- | --- | --- |
| 26 ft | 30 | 22 | 8 |
| 40 ft | 24 | 23 | **1** |
| 50 ft | 18 | 15 | 3 |

(A comment in the setup script claims the 40-foot slips are completely full and only 2 of the 50-foot ones are open. They aren't — the data drifted from the comment at some point. The numbers above are what's really in there.)

So the cheapest way to reach the headline requirement is to **book that last 40-foot slip** with a boat between 26 and 40 feet, then try to book another one. The 26-foot and 50-foot sizes would need 8 and 3 bookings to empty out.

Also worth covering:

- A customer with no boats at all — the panel opening by itself, the greyed-out dropdown.
- Adding a boat in the panel and confirming it shows up in the dropdown **without the page reloading**, already selected, with a check-in date typed in beforehand still sitting there.
- The price updating as boats are switched and the electric box is ticked — and confirming it's based on the **boat's** length, not the slip's size. A 32-foot boat in a 40-foot slip should read $336.00, not $420.00.
- A boat over 50 feet — confirming the wait list is *not* offered.
- Pressing "Join the wait list" twice — confirming they only end up on it once.
- Two browsers booking that last 40-foot slip at the same moment — the second should get the full notice and the wait list question, not a second reservation.
- Someone else's confirmation number typed into the summary page address — it shouldn't show them anything.
