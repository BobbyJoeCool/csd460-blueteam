# Page Role Assignments - Moffat Bay Marina

Weekly sign-up sheet: who's building each page due that module. Two people per page - one Front End, one Back End (Back End includes the database layer: schema changes, queries, and Bean structures). Testing is tracked separately from the build pair, since it happens after a page is functionally done, not alongside it - see the Testing table at the end of each module instead of inside each page's table.

Fill in names as the team commits to a module's split - leave a cell blank if genuinely undecided rather than guessing, so it's obvious at a glance what still needs a volunteer.

**Companion doc:** before writing any code for a page, copy `page-contract-template.md` into `DevNotes/page-contracts/<page-name>-contract.md` and fill it out together. That file is the actual source of truth for field names, parameter types, and DB return shapes - this file is just who's responsible for which piece.

## Role Legend

- **Front End** - HTML/CSS and any page-specific client-side behavior for this page (including modal/popup markup and JS, where a page is built as a popup rather than a full page).
- **Back End** - everything server-side for this page: reading form input, validation, session/auth handling, business logic (e.g. matching boat length to slip size), schema-level changes the page needs, the queries/DAO methods that connect to MySQL, and the Java Bean structures those queries return.
- **Testing** - the functional test plan for a page (per `TestPlanTemplate.docx` in `Course-Info`), running it, and capturing results/screenshots. Rotates on its own schedule, separate from who built the page.

## Preventing Front End / Back End Conflicts

1. **Agree on field names before writing any code.**
    - Variables made on the HTML page (forms) are owned by the Front End Dev.
      Front End picks the name; Back End reads it exactly as given via
      `request.getParameter("thatExactName")` - it's not a name Back End
      also gets to choose, it's Front End's name that Back End consumes.
    - Method call signatures and Bean structure in the Java code belong to the Back End dev - since Back End now covers the database layer too, there's no longer a second person to negotiate the return shape with, but it still needs to be written into the page contract doc so Front End knows exactly what Bean properties are available via EL.
    - Front End must get field names to Back End (and into the page contract doc) before Back End starts writing code - Back End should never be guessing at a name, or coding against one that's about to change. (If you get the list to Robert early, he can fill in the page document for easy viewing.)
2. **Fill out that page's contract doc first.** Copy `page-contract-template.md`, fill in Front End Variables, Back End Parameters, and Database Returns together, and treat it as the source of truth for that page - not whatever's currently in someone's code. Once agreed upon, any changes to it must be clearly communicated to the whole team.
3. **Validation ownership is split on purpose.**
    - Front End should validate user input to the point where it can give users clear feedback.
    - Back End should validate anything it receives, never trusting that what's given is valid - and that includes treating its own database calls the same way, surfacing clear, specific error information rather than letting a raw SQL exception bubble up unhandled.
4. **Integrate early.** Get an ugly end-to-end version connected on day one - form submits, Back End receives it, database round-trips something - before either side polishes in isolation. Waiting until the end to connect the pieces is where the real time gets lost.
    - Front End should get a rough draft working first, not worrying about looks early.
    - Back End needs to get functional early too.
    - Testing should think through the test plan, and write it, even before the code is done, so all the work isn't loaded into the last day or two.
    - ***The fully functional page should be complete by Friday/Saturday, to give the tester time to test and give feedback, and the developers time to fix anything found.***
5. **Reuse the shared header/footer/nav scaffolding once it exists.** It gets built once, in Module 5 (see the Landing entry below), and every page after that plugs into it rather than rebuilding it - just needs to highlight which page is active.
6. **Never commit directly to `main`.** Work in a feature branch per page or task, push it, and open a pull request. That's the signal to Robert, as repo owner, to review and merge - don't merge your own PRs. Remember to actually create the Pull Request - uploading a branch alone doesn't create a notification that one's ready.
7. **Keep the Kanban board current as work actually moves** - move your own items as you complete them, not just as a Sunday-night catch-up before the Kanban Update is due.

## Java & JSP Naming Conventions

Reference for anyone naming a variable, method, class, or file this project touches. Following Oracle's standard Java conventions keeps names predictable across the team, so nobody has to check someone else's file to guess how a name is capitalized.

| Element | Convention | Example |
| --- | --- | --- |
| Variables & method parameters | lowerCamelCase | `firstName`, `boatLength` |
| Methods | lowerCamelCase, usually verb-first | `getFirstName()`, `calculateSlipSize()` |
| Classes & Java Beans | UpperCamelCase (PascalCase) | `Customer`, `Reservation` |
| Constants | ALL_CAPS_WITH_UNDERSCORES | `MAX_SLIP_LENGTH` |
| Packages | all lowercase, dot-separated | `com.moffatbay.marina.dao` |
| HTML form `name` attributes | lowerCamelCase (team convention - not an HTML requirement, but matches the Java code reading it) | `name="boatLength"` |
| JSP file names | pick one style and stay consistent | `reservationSummary.jsp` or `reservation-summary.jsp` |
| Session / request attribute names | lowerCamelCase | `session.setAttribute("customer", ...)` |

**One real gotcha worth flagging:** SQL convention is typically `snake_case` for column names (`first_name`, `boat_length`), which doesn't match Java's camelCase. That mismatch is expected, not a bug - it's exactly what the Back End's Bean-building code is for, translating `resultSet.getString("first_name")` into `customer.setFirstName(...)`. Don't try to force column names into camelCase in the schema just to match Java; keep each language's own convention and let the DAO layer be the translation point.

## Week Three (Aug 24 - Aug 30, 2026)

### Module Three & Four: ERD and Database Development (Sprint 1)

No page tables this module - this is where the shared schema gets built, before any page work starts in Module 5. Robert leads the ERD and schema build (`customers`, `slips`, `reservations`, `wait_list`) plus the shared data-access functions the rest of the team will call once Back End rotation starts touching the database layer. Confirm every team member's local setup actually points at the shared MySQL test environment before Module 5 starts - this is the last easy week to catch a mismatch.

## Week Four (Aug 31 - Sep 6, 2026)

### Module Five: Web Development 1

Before coding starts: agree on and record field/variable names for all three pages below in their Page Contract docs. Work in a feature branch (not `main`) and open a pull request for Robert to review once a page's work is ready.

**Landing**

| Role | Assigned To |
| --- | --- |
| Landing Page (content + any backend) | Carolina |
| Shared Header/Footer Scaffold | Sara |

> Landing is static, so it doesn't need a standard Front End/Back End pair. Instead: one person builds the Landing page itself (hero, highlights row, CTAs - Front End and whatever minimal backend it needs, like the `loggedIn` to know if the Login Button says "Log In" or "Welcome {user}"), and the other builds the shared header/footer scaffold that every later page will plug into. Agree on the scaffolding's structure (container names, layout regions) before the two of you start in parallel, so the pieces actually fit together on the first merge.

**Login**

| Role | Assigned To |
| --- | --- |
| Front End | Miguel |
| Back End | Robert |

> Confirmed as a popup/modal in the finalized wireframes (`Module-2/Finalized WireFrames/Login Page.png`), not a standalone page. **Front End** here means building the modal itself (trigger, overlay, focus/close behavior) - it does not inherit the shared header/footer/nav scaffolding the way a full page does.

**Registration**

| Role | Assigned To |
| --- | --- |
| Front End | Robert |
| Back End |  Carolina|

**Testing - Module 5**

- To be determined between Sara and Miguel

| Page | Tester |
| --- | --- |
| Landing | |
| Login | |
| Registration | |

## Week Five (Sep 7 - Sep 13, 2026)

### Module Six: Web Development 2

Agree on and record field/variable names for this page in its Page Contract doc before coding. Branch and PR as above.

**Reservation (Book a Slip)**

| Role | Assigned To |
| --- | --- |
| Front End | |
| Back End | |

### Module Seven: Web Development 3

Agree on and record field/variable names for both pages below in their Page Contract docs before coding. Branch and PR as above.

**About Us**

| Role | Assigned To |
| --- | --- |
| Front End | |

> There is very little back end to About Us, so this page is very much going to be Front End only.  As such, one person assigned to it, and then 3 people assigned for testing this week.  

**Reservation Summary**

| Role | Assigned To |
| --- | --- |
| Front End | |
| Back End | |

**Testing - Modules 6 & 7**

| Page | Tester |
| --- | --- |
| Reservation (Book a Slip) | |
| About Us | |
| Reservation Summary | |

## Week Six (Sep 14 - Sep 20, 2026)

### Module Eight: Web Development 4

Agree on and record field/variable names for both pages below in their Page Contract docs before coding. Branch and PR as above.

**Contact Us**

| Role | Assigned To |
| --- | --- |
| Front End | |
| Back End | |

**Look Up Reservation**

| Role | Assigned To |
| --- | --- |
| Front End | |
| Back End | |

**Testing - Module 8**

| Page | Tester |
| --- | --- |
| Contact Us | |
| Look Up Reservation | |

## Week Seven (Sep 21 - Sep 27, 2026)

### Module Nine: Web Development 5

Agree on and record field/variable names for this page in its Page Contract doc before coding. Branch and PR as above. This is the last new-page module - budget slack this week for polishing anything lagging from Weeks 4-6, not just the one new page.

**Wait List Lookup**

| Role | Assigned To |
| --- | --- |
| Front End | |
| Back End | |

**Edit User Info/Register a New Boat**

| Role | Assigned To |
| --- | --- |
| Front End | |
| Back End | |

**Testing - Module 9**

| Page | Tester |
| --- | --- |
| Wait List Lookup | |

## Appendix: Rotation Tracker

Running tally so nobody ends up on Back End (or Testing) every single week. Update after each module's assignments are locked in - a simple count is enough to spot an imbalance before it's three weeks deep.

| Person | Front End | Back End | Testing |
| --- | --- | --- | --- |
| Robert | 1 | 1 | |
| Jose | 1 | | 1 |
| Sarah | 1 | | 1 |
| Carolina | 1 | | 1 |
