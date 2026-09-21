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
  <img alt="Status" src="https://img.shields.io/badge/status-in%20development-f4a261?style=flat-square">
  <img alt="Schema" src="https://img.shields.io/badge/schema-v1.8.0-0a6e8c?style=flat-square">
  <img alt="Module" src="https://img.shields.io/badge/module-9-ff6f59?style=flat-square">
  <img alt="Team" src="https://img.shields.io/badge/team-Blue-16262e?style=flat-square">
</p>

---

## About

Moffat Bay Marina is a fictional marina on Joviedsa Island in Washington's San
Juan Islands. This repository is the team's build of its customer-facing
website: visitors can read about the marina, register an account, sign in, and
reserve one of the marina's 72 slips, look up a reservation they've already
made, and edit their profile and boats. The wait list and the My Fleet page are
the last two still being built — see [What's Built](#whats-built).

It's a full-stack Jakarta EE application — JSP and JSTL on the front end, Java
servlets and DAOs on the back end, MySQL underneath, packaged with Maven and
deployed to Tomcat.

Built for **CSD 460 — Capstone Project**.

## The Team

| | Role this module (Module 9 — Wait List, My Fleet) |
| --- | --- |
| **Robert Breutzmann** — *Team Lead* | Front End: My Fleet |
| **Miguel Fernandez** | Back End: Wait List |
| **Carolina Rodriguez** | Back End: My Fleet |
| **Sara White** | Front End: Wait List |

Role rotates every module — see
[`Page Role Assignments.md`](marinawebsite/documentation/Page%20Role%20Assignments.md)
for the full history and how assignments are decided.

## The Marina

The numbers the whole site is built around, kept in
[`definitions_decisions.md`](marinawebsite/documentation/definitions_decisions.md)
so every page tells the same story:

| | |
| --- | --- |
| **Docks** | Three — A, B and C |
| **Slips** | 72 total, 24 per dock |
| **Slip sizes** | 26 ft, 40 ft and 50 ft |
| **Slip pricing** | $10.50/ft of boat length, monthly, plus an optional flat $10.50/month for electric hookup |
| **Address** | 1400 Harbor Loop Road, Joviedsa Island, WA 98250 |
| **Hours** | 6:00 am – 7:00 pm Monday – Saturday, 7:00 am – 5:00 pm Sunday |

## What's Built

Each page is built by a Front End / Back End pair that rotates every module.
Who built what:

| Page | Front End | Back End | Status |
| --- | --- | --- | --- |
| Landing page | Carolina Rodriguez | Carolina Rodriguez | Complete — Module 5 |
| Shared header, footer and navigation | Sara White | — | Complete — Module 5 |
| Login (modal, available site-wide) | Miguel Fernandez | Robert Breutzmann | Complete — Module 5 |
| Registration | Robert Breutzmann | Carolina Rodriguez | Complete — Module 5 |
| Reservation (Book a Slip) | Robert Breutzmann | Sara White | Complete — Module 6 |
| About Us (includes contact info and the contact form) | Miguel Fernandez | Sara White | Complete — Module 7 |
| Reservation Summary | Carolina Rodriguez | Miguel Fernandez | Complete — Module 7 |
| Look Up Reservation | Sara White | Carolina Rodriguez | Complete — Module 8 |
| Edit User Info / Register a New Boat | Miguel Fernandez | Robert Breutzmann | Complete — Module 8 |
| Wait List | Sara White | Miguel Fernandez | In progress — Module 9 |
| My Fleet | Robert Breutzmann | Carolina Rodriguez | In progress — Module 9 |

Landing is the one page without a true pair: it was static enough that Carolina
built the page and whatever minimal back end it needed, while Sara built the
shared header/footer scaffold every later page plugs into.

`lodge.jsp` is an unscheduled placeholder — it exists only so the Moffat Bay
Lodge link in the footer resolves rather than 404s.

Contact Us was cut as its own page by a professor-directed syllabus change
(Sep 7, 2026) and folded into About Us. `contact.jsp` has since been removed;
the contact info and form live on About Us now, still posting to the same
`/contact` servlet, which keeps `ContactServlet` and `ContactDAO` in play.

## Tech Stack

| Layer | |
| --- | --- |
| Language | Java 25 |
| Web | Jakarta EE 6.0 servlets, JSP, JSTL |
| Database | MySQL 8.0 with the Connector/J driver |
| Build | Maven → `.war` |
| Server | Apache Tomcat 11 |
| Front end | Hand-written HTML, CSS and vanilla JavaScript — no frameworks |

## Getting Started

### Prerequisites

- **JDK 25 or newer** (the build targets Java release 25 — see `maven.compiler.release` in `pom.xml`)
- **Apache Maven 3.9+**
- **Apache Tomcat 11** (or 10.1+)
- **MySQL 8.0**

> [!IMPORTANT]
> **Don't use XAMPP's bundled Tomcat.** It ships Tomcat 8.5, which implements
> the old `javax.servlet` API. This project uses `jakarta.servlet`, so the app
> will deploy but every servlet will fail with errors that point nowhere near
> the real cause. Install Tomcat 11 separately.

### 1. Clone and set up credentials

```bash
git clone https://github.com/BobbyJoeCool/csd460-blueteam.git
cd csd460-blueteam/marinawebsite
```

**There's nothing to create here.** `marinawebsite/.env` is committed on
purpose — the assignment hands the whole team one shared database name, user,
and password, so there's no real secret in it and a fresh clone runs with no
credential hand-off. See the "Environment" note in `.gitignore` for the full
reasoning, and don't copy the pattern into a non-classroom repo.

It already contains:

```env
DB_HOST=localhost
DB_PORT=3306
DB_NAME=moffatBayMarinaDB
DB_USER=captainAhab
DB_PASSWORD=<in the committed file>
```

`captainAhab` is created and granted rights by the database script in step 2,
so build the database first if the site can't connect.

### 2. Build the database

One script builds everything from scratch:

```bash
mysql -u root -p < databasescripts/MoffatBayMarinaDB_V1-8-0.sql
```

> **This script is destructive** — it drops `MoffatBayMarinaDB` if it already
> exists and rebuilds it empty. That's the intent for a fresh setup, but don't
> run it against a database holding work you want to keep.

`MoffatBayMarinaDB_V1-8-0.sql` builds all thirteen tables (including `Rate`,
added in 1.5.0, and the `DatabaseVersion` ledger) and their seed data in one
pass, at the schema's current version. It replaces the step-by-step path that
actually built it — `V1-0-0` plus every update through `V1-8-0` — which lives
under `databasescripts/Legacy/` (`Week4/`, `Week5/`, then `Week6/`) purely as
history; running those individually is not the way to stand a database up.

Every seeded account's password follows one pattern, so you don't need to open
the script to sign in as a test user:

```
Moffat + <LastName> + <two-digit customerID> + !
```

`elena.marsh@example.com` (customer 1) is `MoffatMarsh01!`, and
`joshua.foster@example.com` (customer 10) is `MoffatFoster10!`. Version 1.8.0
reset all 59 seeded accounts to this pattern because 29 of them had seed
passwords the site's own validation would reject — a tester could sign in with
a password a real customer would never be allowed to choose.

Check where you landed at any time:

```bash
mysql -u root -p MoffatBayMarinaDB < databasescripts/currentVersion.sql
```

The `DatabaseVersion` table records every migration that's been applied, so
when something behaves differently on two machines, that's the first thing to
compare.

### 3. Build and deploy

```bash
mvn clean package
```

Copy `target/marinawebsite.war` into Tomcat's `webapps/` folder and start
Tomcat. The site is then at:

```
http://localhost:8080/marinawebsite/
```

> [!TIP]
> Redeploying? Delete both the old `.war` **and** the unpacked `marinawebsite/`
> folder from `webapps/` first. Tomcat won't overwrite an existing exploded
> directory, so you'll keep seeing the old build and wonder why your change did
> nothing.

## How We Work

Each page has a **page contract** in
[`documentation/Page Contracts/`](marinawebsite/documentation/Page%20Contracts)
written before the code. It records what the front end sends, what the back end
sets, and which side owns each open decision — so two people can build opposite
halves of the same page without waiting on each other.

Every schema change is a **numbered migration** rather than an edit to the
original script, and it's recorded in the `DatabaseVersion` table, so everyone
can confirm they're running the same schema.

The [ERD](marinawebsite/documentation/ERD.md) and
[Business Rules](marinawebsite/documentation/BusinessRules.md) docs are the
source of truth for the data model and the logic built on top of it (slip-fit
checks, login lockout, etc.); `definitions_decisions.md` above is the source
of truth for the marina's "fake facts" — hours, pricing, contact info — that
every page needs to agree on.

Each page gets one Front End and one Back End developer, with testing tracked
separately per module — see [The Team](#the-team) for who's on what right now.

Work happens on branches and lands on `main` through pull requests.

## A Note on AI Assistance

Parts of this project were built with help from [Claude](https://claude.ai),
including JavaDoc comments, documentation, and assistance working through
problems. Individual files note it in their headers where it applies. Every
line was reviewed, tested and understood by the team member who committed it.

---

<p align="center">
  <sub>Blue Team &nbsp;·&nbsp; CSD 460 Capstone &nbsp;·&nbsp; 2026</sub>
</p>

<img src="https://capsule-render.vercel.app/api?type=waving&color=0:f4a261,55:0a6e8c,100:0d3b4d&height=120&section=footer" width="100%" alt="">
