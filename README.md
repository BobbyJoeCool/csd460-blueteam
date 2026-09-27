<img src="https://capsule-render.vercel.app/api?type=waving&color=0:0d3b4d,45:0a6e8c,100:f4a261&height=210&section=header&text=Moffat%20Bay%20Marina&fontSize=52&fontColor=e8d9b0&fontAlign=50&fontAlignY=36&desc=Your%20Harbor%20Between%20Horizons&descAlign=50&descAlignY=56&descSize=18&animation=fadeIn" width="100%" alt="Moffat Bay Marina">

<p align="center">
  <a href="#"><img src="https://readme-typing-svg.demolab.com?font=Georgia&size=24&duration=3200&pause=900&color=0A6E8C&center=true&vCenter=true&width=620&lines=72+slips+across+three+docks;Reserve+your+spot+in+paradise;Built+by+Blue+Team+for+CSD+460" alt="Moffat Bay Marina"></a>
</p>

<p align="center">
  <img alt="Java" src="https://img.shields.io/badge/Java-25-ED8B00?style=for-the-badge&logo=openjdk&logoColor=white">
  <img alt="Jakarta EE" src="https://img.shields.io/badge/Jakarta%20EE-6.0-1B6AC6?style=for-the-badge&logo=jakartaee&logoColor=white">
  <img alt="Apache Tomcat" src="https://img.shields.io/badge/Tomcat-11.0-F8DC75?style=for-the-badge&logo=apachetomcat&logoColor=black">
  <img alt="MySQL" src="https://img.shields.io/badge/MySQL-8.0-4479A1?style=for-the-badge&logo=mysql&logoColor=white">
  <img alt="Maven" src="https://img.shields.io/badge/Maven-3.9-C71A36?style=for-the-badge&logo=apachemaven&logoColor=white">
</p>

<p align="center">
  <img alt="Status" src="https://img.shields.io/badge/status-all%20pages%20built-2a9d8f?style=flat-square">
  <img alt="Schema" src="https://img.shields.io/badge/schema-v1.9.0-0a6e8c?style=flat-square">
  <img alt="Module" src="https://img.shields.io/badge/module-9-ff6f59?style=flat-square">
  <img alt="Team" src="https://img.shields.io/badge/team-Blue-16262e?style=flat-square">
</p>

---

## About

Moffat Bay Marina is a fictional marina on Joviedsa Island in Washington's San Juan Islands. This repository is the team's build of its customer-facing website. Visitors can read about the marina, send it a message, and see how long the wait list is for each slip size without an account. Once registered and signed in, a customer can:

- reserve one of the marina's 72 slips for one of their boats, or join the wait list when that slip size is full;
- see and manage their reservations: cancel one that hasn't started, give 30 days' notice on one that has, or withdraw that notice;
- see their own place in line on the wait list, with an estimated wait;
- add, edit and remove boats on My Fleet;
- edit their profile and change their password.

Every page on the build schedule is now built. What's left is QA, peer review and polish (Modules 10 and 11).

It's a full-stack Jakarta EE application: JSP and JSTL on the front end, Java servlets and DAOs on the back end, MySQL underneath, packaged with Maven and deployed to Tomcat.

Built for **CSD 460 — Capstone Project**.

## The Team

| | Role this module (Module 9 — Wait List, My Fleet) |
| --- | --- |
| **Robert Breutzmann** — *Team Lead* | Front End: My Fleet |
| **Miguel Fernandez** | Back End: Wait List |
| **Carolina Rodriguez** | Back End: My Fleet |
| **Sara White** | Front End: Wait List |

Roles rotate every module. See [`Page Role Assignments.md`](marinawebsite/documentation/Page%20Role%20Assignments.md) for the full history and how assignments are decided.

## The Marina

These are the numbers the whole site is built around. They're kept in [`definitions_decisions.md`](marinawebsite/documentation/definitions_decisions.md) so every page tells the same story:

| | |
| --- | --- |
| **Docks** | Three — A, B and C |
| **Slips** | 72 total, 24 per dock |
| **Slip sizes** | 26 ft, 40 ft and 50 ft |
| **Slip pricing** | $10.50/ft of boat length, monthly, plus an optional flat $10.50/month for electric hookup |
| **Address** | 1400 Harbor Loop Road, Joviedsa Island, WA 98250 |
| **Hours** | 6:00 am – 7:00 pm Monday – Saturday, 7:00 am – 5:00 pm Sunday |

## What's Built

Each page is built by a Front End / Back End pair that rotates every module. Who built what:

| Page | Front End | Back End | Status |
| --- | --- | --- | --- |
| Landing page | Carolina Rodriguez | Carolina Rodriguez | Complete — Module 5 |
| Shared header, footer and navigation | Sara White | — | Complete — Module 5 |
| Login (modal, available site-wide) | Miguel Fernandez | Robert Breutzmann | Complete — Module 5 |
| Registration | Robert Breutzmann | Carolina Rodriguez | Complete — Module 5 |
| Reservation (Book a Slip) | Robert Breutzmann | Sara White | Complete — Module 6 |
| About Us (includes contact info and the contact form) | Miguel Fernandez | Sara White | Complete — Module 7 |
| Reservation Summary | Carolina Rodriguez | Miguel Fernandez | Complete — Module 7 |
| My Reservations (Look Up Reservation) | Sara White | Carolina Rodriguez | Complete — Module 8 |
| Edit User Info / Register a New Boat | Miguel Fernandez | Robert Breutzmann | Complete — Module 8 |
| Wait List | Sara White | Miguel Fernandez | Complete — Module 9 |
| My Fleet | Robert Breutzmann | Carolina Rodriguez | Complete — Module 9 |

Landing is the one page without a true pair. It was static enough that Carolina built the page and whatever minimal back end it needed, while Sara built the shared header/footer scaffold every later page plugs into.

A few things changed after their page was first finished:

- **My Reservations** gained Cancel, 30-Day Notice and Withdraw Notice actions in Module 9, handled by `ReservationChangeServlet`.
- **Reservation Summary** is now a confirmation screen only. It appears right after a booking, cancellation or notice, and any other request is sent to My Reservations, where reservations are looked at and managed.
- **Forgot Password** (opened from the Login modal) replaced the Login modal's old demo "Unlock Account" button. A successful reset also unlocks an account that was locked after three failed sign-ins. **Change Password** was added to Edit User Info alongside it.

`lodge.jsp` is an unscheduled placeholder. It exists only so the Moffat Bay Lodge link on the landing page and in the footer resolves rather than 404s.

Contact Us was cut as its own page by a professor-directed syllabus change (Sep 7, 2026) and folded into About Us. `contact.jsp` has since been removed. The contact info and form live on About Us now, still posting to the same `/contact` servlet, which keeps `ContactServlet` and `ContactDAO` in play.

### Pages at a Glance

| Page | URL | Signed in? | Reached from |
| --- | --- | --- | --- |
| Landing | `/` | No | Logo, Home |
| About Us | `/about` | No | Header |
| Book a Slip | `/reservation` | To book | Plan Your Stay menu, landing page, My Fleet |
| View Wait List | `/waitList` | No (your own place in line shows only when signed in) | Plan Your Stay menu |
| My Reservations | `/reservations` | Yes | Plan Your Stay menu (only shown when signed in) |
| Reservation Summary | `/reservationSummary` | Yes | Only after booking, cancelling or giving notice |
| Registration | `/registration.jsp` | No | Landing page, Login modal |
| Edit User Info | `/editProfile` | Yes | "Welcome, *name*" in the header |
| My Fleet | `/myFleet` | Yes | Edit User Info |

## Tech Stack

| Layer | |
| --- | --- |
| Language | Java 25 |
| Web | Jakarta EE 6.0 servlets, JSP, JSTL |
| Database | MySQL 8.0 with the Connector/J driver |
| Build | Maven → `.war` |
| Server | Apache Tomcat 11 |
| Tests | JUnit 4 (`mvn test`) |
| Front end | Hand-written HTML, CSS and vanilla JavaScript, no frameworks |

## Getting Started

### Prerequisites

- **JDK 25 or newer** (the build targets Java release 25; see `maven.compiler.release` in `pom.xml`)
- **Apache Maven 3.9+**
- **Apache Tomcat 11** (or 10.1+)
- **MySQL 8.0 or newer**

> [!IMPORTANT]
> **Don't use XAMPP's bundled Tomcat.** It ships Tomcat 8.5, which implements the old `javax.servlet` API. This project uses `jakarta.servlet`, so the app will deploy but every servlet will fail with errors that point nowhere near the real cause. Install Tomcat 11 separately.

### 1. Clone and set up credentials

```bash
git clone https://github.com/BobbyJoeCool/csd460-blueteam.git
cd csd460-blueteam/marinawebsite
```

**There's nothing to create here.** `marinawebsite/.env` is committed on purpose. The assignment gives the whole team one shared database name, user and password, so there's no real secret in it, and a fresh clone runs with no credential hand-off. See the "Environment" note in `.gitignore` for the full reasoning, and don't copy the pattern into a non-classroom repo.

It already contains:

```env
DB_HOST=localhost
DB_PORT=3306
DB_NAME=moffatBayMarinaDB
DB_USER=captainAhab
DB_PASSWORD=<in the committed file>
```

`captainAhab` is created and granted rights by the database script in step 2, so build the database first if the site can't connect.

### 2. Build the database

One script builds everything from scratch:

```bash
mysql -u root -p < databasescripts/MoffatBayMarinaDB_V1-9-0.sql
```

> [!WARNING]
> **This script is destructive.** It drops `MoffatBayMarinaDB` if it already exists and rebuilds it with only the seed data. That's the intent for a fresh setup, but don't run it against a database holding work you want to keep.

`MoffatBayMarinaDB_V1-9-0.sql` builds all thirteen tables (including `Rate` and the `DatabaseVersion` ledger) and their seed data in one pass, at the schema's current version. It replaces the step-by-step path that actually built the schema: `V1-0-0` plus every update through `V1-9-0`. Those files live under `databasescripts/Legacy/` (`Week4/` through `Week7/`) purely as history, and running them one by one is not the way to stand a database up. Each week's folder has a README explaining what its scripts did.

Every seeded account's password follows one pattern, so you don't need to open the script to sign in as a test user:

```text
Moffat + <LastName> + <two-digit customerID> + !
```

`elena.marsh@example.com` (customer 1) is `MoffatMarsh01!`, and `joshua.foster@example.com` (customer 10) is `MoffatFoster10!`.

A few seeded customers are set up for particular tests:

| Account | Why use it |
| --- | --- |
| `elena.marsh@example.com` / `MoffatMarsh01!` | The shared demo account. Other testers may have changed its boats and reservations. |
| `desmond.okafor@example.com` / `MoffatOkafor02!` | Two boats, one reserved and one not: shows the "Open to Reserve" status and an enabled Remove button on My Fleet. |
| `arthur.penhale@example.com` / `MoffatPenhale05!` | Four boats (two reserved): shows My Fleet's two-column layout, and Morning Tide has its optional fields left blank. |

The Forgot Password reset asks for an emailed verification code. The site doesn't send real email, so the code is always `12345`.

Check which version you're running at any time:

```bash
mysql -u root -p MoffatBayMarinaDB < databasescripts/currentVersion.sql
```

The `DatabaseVersion` table records every version that's been applied, so when something behaves differently on two machines, that's the first thing to compare.

### 3. Build and deploy

```bash
mvn clean package
```

Copy `target/marinawebsite.war` into Tomcat's `webapps/` folder and start Tomcat. The site is then at:

```text
http://localhost:8080/marinawebsite/
```

> [!TIP]
> Redeploying? Delete both the old `.war` **and** the unpacked `marinawebsite/` folder from `webapps/` first. Tomcat won't overwrite an existing exploded directory, so you'll keep seeing the old build and wonder why your change did nothing.

## Testing

`mvn test` runs the JUnit tests for the shared helpers in `Utils`: input parsing, the boat size, HIN and registration-number rules, slip-size matching, safe redirects, and the 30-day notice and withdrawal dates. `mvn clean package` runs them too, so a broken rule fails the build.

Each page also has a written functional test plan, with the results and screenshots from running it. The finished plans are in [`documentation/Test Plans/`](marinawebsite/documentation/Test%20Plans), and each module's working copies are under `Class_Information/Module-*`.

## How We Work

Each page has a **page contract** in [`documentation/Page Contracts/`](marinawebsite/documentation/Page%20Contracts), written before the code. It records what the front end sends, what the back end sets, and which side owns each open decision, so two people can build opposite halves of the same page without waiting on each other.

Every schema or seed-data change ships as a **numbered update script** that changes an existing database in place and records itself in the `DatabaseVersion` table, so everyone can confirm they're running the same schema. Once a week the updates are folded into a new from-scratch script, and the old scripts move to `databasescripts/Legacy/` as history. New updates start from `databasescripts/updateTemplate.sql`.

The [ERD](marinawebsite/documentation/ERD.md) and [Business Rules](marinawebsite/documentation/BusinessRules.md) docs are the source of truth for the data model and the logic built on top of it (slip-fit checks, login lockout, 30-day notice, wait list order, etc.). `definitions_decisions.md` above is the source of truth for the marina's "fake facts" (hours, pricing, contact info) that every page needs to agree on.

Each page gets one Front End and one Back End developer, with testing tracked separately per module. See [The Team](#the-team) for who's on what right now.

Work happens on branches and lands on `main` through pull requests.

## A Note on AI Assistance

Parts of this project were built with help from [Claude](https://claude.ai), including JavaDoc comments, documentation, seed data, and help working through problems. Individual files note it in their headers where it applies. Every line was reviewed, tested and understood by the team member who committed it.

---

<p align="center">
  <sub>Blue Team &nbsp;·&nbsp; CSD 460 Capstone &nbsp;·&nbsp; 2026</sub>
</p>

<img src="https://capsule-render.vercel.app/api?type=waving&color=0:f4a261,55:0a6e8c,100:0d3b4d&height=120&section=footer" width="100%" alt="">
