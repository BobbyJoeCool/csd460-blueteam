# Page Contract: Shared Header/Footer/Nav Scaffold

## Page Name

Shared Header / Footer / Navigation Scaffold (not a standalone page — included by every page)

## Module / Week

Module 5 / Week 4 (Aug 31 – Sep 6, 2026)

## Assigned

- Front End: Sara
- Back End: (consumed by all Back End developers)
- Testing:

## Open Questions / Decisions Needed

> **General rule:** any page that doesn't have real content yet should still exist as a JSP — use `WEB-INF/includes/comingSoon.jsp` (pass `pageName` as a param) to create a stub page with the shared header/footer, so the link works instead of going nowhere. `lodge.jsp` (Moffat Bay Lodge) is the one stub left.

**Every nav link goes through a servlet**, never at a JSP directly (`/reservation`, not `reservation.jsp`). Going straight at a JSP skips the servlet's `doGet()` and the page renders with none of its data. The page JSPs live under `WEB-INF/views/`, so they can't be reached directly anyway.

## How a Page Uses the Scaffold

Three includes, all under `WEB-INF/includes/`:

```jsp
<head>
    ...
    <jsp:include page="/WEB-INF/includes/styles.jsp" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/myPage.css?v=${applicationScope.assetVersion}">
</head>
<body>

<jsp:include page="/WEB-INF/includes/header.jsp">
    <jsp:param name="activePage" value="reservation" />
</jsp:include>

<!-- page content, with <main id="main" tabindex="-1"> -->

<jsp:include page="/WEB-INF/includes/footer.jsp" />
</body>
```

- **`styles.jsp`** — the shared stylesheets (`site.css`, `header.css`, `footer.css`, `loginModal.css`, `statusPopup.css`, `passwordToggle.css`), the site icon, and the anti-forgery token as `<meta name="csrf-token">` for scripts (`MoffatBay.form.csrfToken()`). Page stylesheets go after it. Every stylesheet and script carries `?v=${applicationScope.assetVersion}` so a new deploy isn't served from the browser's cache.
- **`header.jsp`** — the skip link, the header and nav, and the pieces every page shares (below).
- **`footer.jsp`** — the footer.

Every page's `<main>` carries `id="main"` and `tabindex="-1"`, the target of the header's **Skip to main content** link (WCAG 2.4.1).

## Active Page Highlighting

Each page passes its identity to the header with `<jsp:param name="activePage">`. The header adds `nav-active` to the matching link, and to the dropdown trigger that holds it:

```jsp
<a href="${pageContext.request.contextPath}/about"
   class="${param.activePage == 'about' ? 'nav-active' : ''}">About Us</a>
```

### Agreed `activePage` Values

Every page must use its assigned string exactly. Update this table as pages are built.

| Page | `activePage` value | What's highlighted |
| --- | --- | --- |
| Landing | `home` | Home |
| About Us | `about` | About Us |
| Reservation (Book a Slip) | `reservation` | Plan Your Stay → **Book a Slip** (renamed from "Reservations" 2026-09-24, so it can't be confused with My Reservations) |
| Reservation Summary | `reservation` | Plan Your Stay → Book a Slip, since it's the confirmation that follows a booking |
| Wait List Lookup | `waitlist` | Plan Your Stay → **View Wait List** |
| My Reservations (Look Up Reservation) | `lookup` | **My Reservations**, which is in both menus (Plan Your Stay and Welcome, beta test #292), so both triggers show as active |
| Edit User Info | `editprofile` | Welcome → **Your Account** (renamed from "User Profile" 2026-09-30, #267, to match the page title) |
| My Fleet | `myfleet` | Welcome → **My Fleet** |
| Registration | `register` | Nothing (not a nav link) |
| Privacy Policy, Accessibility, Moffat Bay Lodge, error page | *(none)* | Nothing |

> Login is a modal, not a nav destination — it doesn't set `activePage`. Contact Us was cut as a page (2026-09-07); the contact form lives on About Us, and the footer's **Contact** link goes to `/about#formHeading`.

## The Header

Left to right:

- **Logo** — the anchor icon and "Moffat Bay Marina", linking to the site root `/`.
- **Home** and **About Us** links.
- **Plan Your Stay** dropdown — **Book a Slip** (`/reservation`), **View Wait List** (`/waitList`), and, signed in only, **My Reservations** (`/reservations`).
- **Account control** — signed out, a **Log In** button (`data-sign-in`, which opens the login modal and returns to the current page). Signed in, a **Welcome, {displayName}** dropdown holding **My Reservations**, **My Fleet** and **Your Account** (`/editProfile`), in that order, followed by a **Log Out** button.

**Log Out is a form, not a link.** Logging out changes state, so it POSTs to `/logout`, with the anti-forgery field (`WEB-INF/includes/csrfField.jsp`) like every POST on the site. `LogoutServlet` invalidates the session and redirects to `/?notice=loggedOut`. `.nav-logout-form` is `display: inline-flex` in `header.css` so the form doesn't break the nav's flex row.

**On a phone** a hamburger button (`.nav-toggle`) shows the links as a dropdown; the Welcome menu stays a popup in the compact row.

**Both dropdowns** are one component (`js/header.js`, `MoffatBay.dropdowns`). Each closes on Escape, on a click outside it, or when keyboard focus tabs out of it (#260), so an open menu never sits over content a keyboard user has moved on to.

The header also carries `data-marina-phone` (from `MarinaInfo`), so page scripts can quote the marina's phone number without typing it themselves.

### What the Header Brings With It

Because the header is on every page, it's where the site-wide pieces live, so no page has to include them itself:

- `js/header.js` (menus), `js/modal.js` (the shared `.modal` popup), and `js/passwordToggle.js` (the show/hide eye on every password field).
- `WEB-INF/includes/loginModal.jsp` — the login modal, which brings `forgotPasswordModal.jsp`, `formValidation.js`, `loginModal.js` and `accountModals.js` with it. See the Login contract.
- `WEB-INF/includes/statusPopup.jsp` — the shared status popup, the "that worked" message. Any page can fill it with `MoffatBay.statusPopup.show("...")`, or by redirecting with a `?notice=` keyword that `js/statusPopup.js` turns into wording.

### What the Header Reads

| Name | Source | Use |
| --- | --- | --- |
| `param.activePage` | `<jsp:param>` from the page | Which link and trigger to highlight |
| `sessionScope.loggedIn` | Set by `CustomerSession.start()` | Log In vs. Welcome + Log Out |
| `sessionScope.displayName` | Set by `CustomerSession.start()`, refreshed after a profile save | The greeting, already formatted "Elena M." |
| `sessionScope.customerId` | Set by `CustomerSession.start()` | Whether Plan Your Stay shows My Reservations |
| `marina.phone` | `MarinaInfo`, an application attribute | `data-marina-phone` |

## The Footer

Three columns, then a bottom bar. Address, phone and hours come from `MarinaInfo` (the `marina` application attribute), not typed into the footer:

- **Moffat Bay Marina** — street, city/state/ZIP, and the phone number as a `tel:` link.
- **Office Hours** — one line per day group, plus the slip holders' after-hours access note.
- **Quick Links** — Home, About Us, Book a Slip (`/reservation`, #327), Wait List (`/waitList`), Contact (`/about#formHeading`), Moffat Bay Lodge (`/lodge.jsp`).
- **Bottom bar** — Privacy Policy (`/privacy`) and Accessibility (`/accessibility`), then "© 2026 Moffat Bay Marina. All rights reserved."

The footer has no login-state behavior.

## Login State Differences

| Item | Logged In | Logged Out |
| --- | --- | --- |
| Header account control | "Welcome, {displayName}" menu (My Reservations, My Fleet, Your Account) plus Log Out | Log In button |
| Plan Your Stay menu | Book a Slip, View Wait List, My Reservations | Book a Slip, View Wait List |
| Login modal include | Still included (a page can still open it) | Included; opened by Log In and by any `data-sign-in` control |
| Footer | Same | Same |
