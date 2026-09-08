<%--
  ===========================================================================
  STUB DATA - DELETE THIS FILE AND ITS INCLUDE FROM reservation.jsp WHEN THE
  BACK END LANDS. It exists so the whole Reservation page can be built,
  clicked through and demonstrated before ReservationServlet exists.

  It sets EXACTLY the request attributes the real servlet will set, so
  reservation.jsp reads real data and fake data identically and does not
  change at all when this goes away. If reservation.jsp needs editing at
  that point, this stub was not matching the real shape - which is worth
  finding out.

  Replaced by, in ReservationServlet.doGet:
    ownedBoats    the customer's boats. NOTE: nothing can read these back
                  yet - BoatDAO only has insertBoat and insertOwnership, no
                  read methods at all, and CustomerDAO has nothing
                  boat-related. The boats are in the database (RegisterServlet
                  writes them at signup); the query to fetch them is new work.
    docks         one entry per dock with how many slips of each size are
                  free ON THAT DOCK. The totals shown on the size cards at
                  the top of the page are summed from this, so this is the
                  only availability figure the back end needs to produce.
    electricCents the ELECTRIC_MONTHLY figure from the Rate table.
    perFootCents  the SLIP_PER_FOOT_MONTHLY figure, for the pricing note.

  Each row is a Map here rather than a bean purely so the stub needs no new
  model class. EL reads ${boat.boatName} the same either way, which is the
  point - swapping in real beans changes nothing in the JSP.

  HOW TO TEST THE OTHER STATES: edit the numbers below.
    - stubNoBoats = true          the "register a boat first" flow
    - give a 40 ft entry a count  the normal, slips-available flow
    - zero every 26 ft entry      a second size full
    - zero one dock only          that dock unavailable, the others fine
  Shipped with 40 ft full on every dock on purpose: that is the assignment's
  headline case (notify, offer the wait list, make no reservation) and the
  live database cannot currently produce it, since every size still has room.
  ===========================================================================
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*" %>
<%
    boolean stubNoBoats = false;

    List<Map<String, Object>> stubBoats = new ArrayList<>();
    if (!stubNoBoats) {
        // monthlyCents = tenths-of-a-foot x 105, i.e. $10.50 per foot of
        // boat. Worked out here the way the server will work it out, so the
        // page never needs to know the rate.
        stubBoats.add(new LinkedHashMap<>(Map.of(
                "boatId", 1, "boatName", "Salt Whisper", "boatLength", "24.5",
                "slipSizeFt", 26, "monthlyCents", 25725, "hasActiveReservation", false)));
        stubBoats.add(new LinkedHashMap<>(Map.of(
                "boatId", 2, "boatName", "Gullwing", "boatLength", "32.0",
                "slipSizeFt", 40, "monthlyCents", 33600, "hasActiveReservation", false)));
        stubBoats.add(new LinkedHashMap<>(Map.of(
                "boatId", 3, "boatName", "Meridian", "boatLength", "47.5",
                "slipSizeFt", 50, "monthlyCents", 49875, "hasActiveReservation", true)));
        // Over 50 ft: no slip category fits, so this one must be told to
        // call the marina and must NOT be offered the wait list.
        stubBoats.add(new LinkedHashMap<>(Map.of(
                "boatId", 4, "boatName", "Leviathan", "boatLength", "58.0",
                "slipSizeFt", 0, "monthlyCents", 60900, "hasActiveReservation", false)));
    }

    // Descriptions match the seeded Dock rows and the marina map - they are
    // the reason anyone cares which dock they are on.
    List<Map<String, Object>> stubDocks = new ArrayList<>();
    stubDocks.add(new LinkedHashMap<>(Map.of(
            "dockId", 1, "dockNumber", "A",
            "dockDescription", "Closest to the Ship Store.",
            "available", new LinkedHashMap<>(Map.of("26", 3, "40", 0, "50", 1)))));
    stubDocks.add(new LinkedHashMap<>(Map.of(
            "dockId", 2, "dockNumber", "B",
            "dockDescription", "Between Dock A and Dock C.",
            "available", new LinkedHashMap<>(Map.of("26", 3, "40", 0, "50", 1)))));
    stubDocks.add(new LinkedHashMap<>(Map.of(
            "dockId", 3, "dockNumber", "C",
            "dockDescription", "Closest to the Office, Restaurant and Fuel Dock.",
            "available", new LinkedHashMap<>(Map.of("26", 2, "40", 0, "50", 1)))));

    request.setAttribute("ownedBoats", stubBoats);
    request.setAttribute("docks", stubDocks);
    request.setAttribute("electricCents", 1050);
    // SLIP_PER_FOOT_MONTHLY from the Rate table, in cents: $10.50 -> 1050.
    // NOT the 105 used in the monthlyCents arithmetic above - that one is
    // cents per TENTH of a foot, because boat lengths carry one decimal.
    request.setAttribute("perFootCents", 1050);
%>
