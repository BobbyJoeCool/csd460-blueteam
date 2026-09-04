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

> **General rule:** any link pointing to a page that doesn't exist yet should use `href="#"` so the element is clickable but doesn't navigate anywhere. Replace with the real path once that page's JSP is merged.



## Active Page Highlighting — Reference Implementation

Each page passes its identity to the header via `<jsp:param>` when including it:

```jsp
<jsp:include page="/includes/header.jsp">
    <jsp:param name="activePage" value="reservation" />
</jsp:include>
```

The header uses the walrus operator to conditionally apply a CSS class on the matching nav link:

```jsp
<nav>
    <a href="index.jsp"
       class="${param.activePage == 'home' ? 'nav-active' : ''}">Home</a>
    <a href="about.jsp"
       class="${param.activePage == 'about' ? 'nav-active' : ''}">About Us</a>
    <a href="reservation.jsp"
       class="${param.activePage == 'reservation' ? 'nav-active' : ''}">Reservations</a>
    <a href="contact.jsp"
       class="${param.activePage == 'contact' ? 'nav-active' : ''}">Contact</a>
</nav>
```

The CSS handles the visual distinction:

```css
.nav-active {
    border-bottom: 2px solid #fff;
    font-weight: bold;
}
```

### Agreed `activePage` Values

Every page must use its assigned string exactly. Update this table as pages are built.

| Page | `activePage` value |
| --- | --- |
| Landing | `home` |
| About Us | `about` |
| Reservation (Book a Slip) | `reservation` |
| Reservation Summary | *(none — not a nav link)* |
| Contact Us | `contact` |
| Look Up Reservation | *(none — not a nav link)* |
| Wait List Lookup | *(none — not a nav link)* |
| Edit User Info | *(none — not a nav link)* |

> Login is a modal, not a nav destination — it doesn't set `activePage`.

**Update, 2026-09-04:** the header/footer `About Us` / `Reservations` /
`Contact` links no longer use the placeholder `href="#"` from the general
rule above — they now point at `aboutUs.jsp` / `reservation.jsp` /
`contact.jsp`, since those pages exist (as "Coming Soon" placeholders, see
`includes/comingSoon.jsp`). `Reservation Summary`, `Look Up Reservation`,
`Wait List Lookup`, and `Edit User Info` also have placeholder pages now,
but were never nav links to begin with, so nothing to rewire for those
four.

## Front/Back End

There is no real front to back end connections beyond tracking whether the user is logged in with the sessionBean.  