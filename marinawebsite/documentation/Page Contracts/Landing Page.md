# Page Contract: Landing Page

## Page Name

Landing Page

## Module / Week

Module 5 / Week 4 (Aug 31 – Sep 6, 2026)

## Assigned

- Front End: Carolina (Landing page content + any backend)
- Back End: (minimal — see notes)
- Shared Header/Footer Scaffold: Sara
- Testing:

## What the Page Shows

Top to bottom: the hero ("Your Harbor Between Horizons") with a **Book a Slip** button; **Why Moffat Bay?** (three cards: Three Slip Sizes, Prime Location, Full-Service Amenities); the **Slip Pricing** card with the reservation call to action at its foot; and **Stay Ashore at Moffat Bay Lodge**, a photo card linking to `/lodge.jsp` (a Coming Soon page).

## Open Questions / Decisions Needed

> **General rule:** any page that doesn't have real content yet should still exist as a JSP — use `WEB-INF/includes/comingSoon.jsp` (pass `pageName` as a param) to create a stub page with the shared header/footer, so the link works instead of going nowhere. `lodge.jsp` is one.

- [x] **CTA link targets:** Decided. Every link goes through a servlet, never at a JSP directly (going straight at a JSP skips the servlet's `doGet()` and the page loads with none of its data). The hero's **Book a Slip** links to `/reservation` when signed in; signed out it opens the login modal with `redirectTo` set to `/reservation`, so a fresh sign-in lands straight on Book a Slip. The pricing card's button is **Book a Slip** (`/reservation`) when signed in and **Create an Account** (`/register`) when signed out.
- [x] **Session attribute name for login state:** `sessionScope.loggedIn` (boolean), set by `CustomerSession.start()` on sign-in or registration. Matches the Login contract.
- [x] **User display name attribute:** `sessionScope.displayName` — a pre-formatted "First L." greeting name (e.g. "Elena M."), built by the Customer bean. Read by the shared header, not this page.
- [x] **Does the landing page need a servlet?** **Yes (issue #349, Miguel).** `LandingServlet` (mapped to the site root `""`, and to `/index.jsp` so the old address still works) reads the slip and electric rates from the `Rate` table for the Slip Pricing card, then forwards to `/WEB-INF/views/index.jsp`. The JSP lives under `WEB-INF` like every other page, so it can't be loaded without its data.
- [x] **Slip Pricing card (issue #349):** Decided. The card shows the per-foot rate, the most each slip size can cost (a boat that fills the slip: size × per-foot rate), the flat electric fee, and "Month-to-month leases. 30 days' notice to leave.", with the reservation call to action ("Ready to Reserve Your Slip?") at the bottom. Rent follows the boat's length, so each size says "Up to" rather than a fixed price. Tier names (Standard, Premier, Grand) match Book a Slip.

## Scaffold Include

This page includes the shared header/footer and identifies itself for nav highlighting:

```jsp
<jsp:include page="/WEB-INF/includes/header.jsp">
    <jsp:param name="activePage" value="home" />
</jsp:include>

<!-- Landing page content -->

<jsp:include page="/WEB-INF/includes/footer.jsp" />
```

> The `activePage` value `"home"` must match what the header checks. See the Shared Header/Footer contract for the full reference table.

## Front End Variables

The landing page has no form and submits nothing.

| Field or Control | Type | Required? | Format / Notes |
| --- | --- | --- | --- |
| `activePage` | JSP include parameter | Yes | Passes `"home"` to `header.jsp` so Home is highlighted |
| Hero Book a Slip (signed out) | Button | No | `data-sign-in="/reservation"`; `loginModal.js` opens the login modal with that as the return page. No `onclick` — the Content-Security-Policy blocks inline script |
| Hero Book a Slip (signed in) | Link | No | `/reservation` |
| Create an Account (signed out) | Link | No | `/register` |
| Book a Slip, pricing card (signed in) | Link | No | `/reservation` |
| Visit Moffat Bay Lodge | Link | No | `/lodge.jsp` (Coming Soon) |

## Back End Parameters

The landing page reads no form values. `LandingServlet` sets two request attributes for the Slip Pricing card.

| Parameter Name | Type | Source | Notes |
| --- | --- | --- | --- |
| `activePage` | `String` | JSP include parameter | Passed to `header.jsp` with the value `"home"` |
| `perFootRate` | `BigDecimal` | Request attribute (`LandingServlet`) | `SLIP_PER_FOOT_MONTHLY` from `Rate`. Unset if the lookup failed |
| `electricRate` | `BigDecimal` | Request attribute (`LandingServlet`) | `ELECTRIC_MONTHLY` from `Rate`. Unset if the lookup failed |
| `loggedIn` | `Boolean` | Session (`sessionScope.loggedIn`) | Picks the hero button and the pricing card's call to action |
| `registered` | `String` | Query string | `registered=true` (from `RegisterServlet`) makes `js/statusPopup.js` show "Account created — welcome aboard", then strips it from the URL. The same file handles `?notice=` keywords that land here: `loggedOut`, `accountDeleted`, and `loggedIn` / `passwordReset` when that's where the customer was |

## Database Returns

| Method / Query | Parameters In | Returns | Notes |
| --- | --- | --- | --- |
| `ReservationDAO.getRate(conn, rateCode)` | `SLIP_PER_FOOT_MONTHLY`, then `ELECTRIC_MONTHLY` | `BigDecimal` rate amount | The same lookup Book a Slip uses, so a price change in `Rate` shows on both pages |

## Validation Rules

- **Client-side (UX only, not trusted):** No input fields. Button and modal behavior is handled by `loginModal.js`.
- **Server-side (source of truth):** The page submits no data. Login and registration validation are handled by their own servlets.

## Error Handling

| Condition | Message Shown | Where Displayed |
| --- | --- | --- |
| Login fails | Defined by the Login contract | Login modal, reopened on this page |
| Registration succeeds with no other page to return to | "Account created — welcome aboard" | Shared status popup, via `?registered=true` |
| Logged out | "You've been logged out" | Shared status popup, via `?notice=loggedOut` |
| Account deleted | "Your account has been deleted" | Shared status popup, via `?notice=accountDeleted` |
| Hero image cannot load | No message; the background colour stays | Hero |
| Rates can't be read from the database | No error. The card leaves out its figures and says "You'll see the exact price for your boat when you book."; the rest of the page loads normally, and the failure goes to the server log | Slip Pricing card |
| Anything else fails while loading | The site's error page ("Rough Seas" for a 500) | `error.jsp`, per `web.xml` |

## Login State Differences

| Item | Logged In | Logged Out |
| --- | --- | --- |
| Hero "Book a Slip" | Link to `/reservation` | Opens the login modal with `redirectTo` set to `/reservation` |
| Pricing card call to action | "Check availability and book your spot today." with **Book a Slip** (`/reservation`) | "Create an account or sign in to check availability and book your spot today." with **Create an Account** (`/register`) |
