<%--
    Front End:   Sara White
    Back End:    Carolina Rodriguez
    Team:        Blue Team - Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
    Primary Author/Owner - Sara White
    Course:      CSD 460 - Capstone Project
    Module:      Module 8 / Week 6 - Web Development 4
    Page:        My Reservations (lookUpReservation.jsp, served at /reservations)
    Contract:    marinawebsite/documentation/Page Contracts/Look Up Reservation.md

    Lists the signed-in customer's reservations, newest first. Opening the
    page with no filters shows all of them; the filter form (reservation
    number, year, month, status, sort) narrows the list. Everything is a
    GET to the /reservations servlet (LookUpReservationServlet), so a
    filtered view can be bookmarked or refreshed.

    Reads (all set by LookUpReservationServlet):
      signInRequired / signInRedirectTo - nobody is signed in; show the
                          sign-in panel instead of the list.
      reservations      - List<ReservationDetails>, already filtered/sorted.
      reservationYears  - the years this customer has reservations in, for
                          the Year filter.
      searchNumber, selectedYear, selectedMonth, selectedStatus,
      oldestFirst       - the filters as applied, so the form shows them.
      filtersApplied    - picks between the two empty-state messages.
      filterError       - a reservation number with characters no
                          confirmation number has.
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page isELIgnored="false" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%--
  This page only works when LookUpReservationServlet has run first. Reached
  any other way - the address /lookUpReservation.jsp typed directly, or the
  header's login modal sending a sign-in back here, since the modal
  remembers this file's path rather than /reservations - hand the request to
  the servlet. A forward, not a redirect, so a failed sign-in's error message
  survives and the login modal re-opens with it.
--%>
<c:if test="${requestScope.reservationYears == null and not requestScope.signInRequired}">
    <jsp:forward page="/reservations" />
</c:if>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>My Reservations - Moffat Bay Marina</title>

    <jsp:include page="/includes/styles.jsp" /> <!-- Adds site.css, header.css, footer.css, loginModal.css -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/lookUpReservation.css">
</head>

<body>

    <jsp:include page="/includes/header.jsp">
        <jsp:param name="activePage" value="lookup" />
    </jsp:include>

    <section class="hero-band" id="lookUpReservationHero">
        <div class="hero-band__content">
            <h1>My Reservations</h1>

            <p class="hero-band__lede">
                Your upcoming and past slip reservations.
            </p>
        </div>
    </section>

    <main class="lookup-page">

<c:choose>

    <%-- Signed out: same panel and flow as reservationSummary.jsp. The
         servlet also answers 401 here. --%>
    <c:when test="${signInRequired}">

        <section class="lookup-signin">
            <h2>Sign In to View Your Reservations</h2>
            <p>Your reservations are available after you sign in.</p>

            <button type="button" class="btn-primary"
                    onclick="MoffatBay.loginModal.open('${fn:escapeXml(signInRedirectTo)}')">Sign In</button>

            <p>
                No account yet?
                <a href="${pageContext.request.contextPath}/registration.jsp">Create one</a>.
            </p>
        </section>

    </c:when>

    <c:otherwise>

        <section class="reservation-lookup">

            <h2>Filter Your Reservations</h2>

            <form method="get"
                  action="${pageContext.request.contextPath}/reservations"
                  class="lookup-form"
                  id="lookupForm">

                <div class="form-group lookup-form__number">
                    <label for="reservationNumber">Reservation Number</label>

                    <%-- After a rejected search, show what they typed so
                         they can fix it; otherwise the filter as applied. --%>
                    <input type="text"
                           id="reservationNumber"
                           name="reservationNumber"
                           maxlength="20"
                           placeholder="e.g. MB-00001"
                           aria-describedby="reservationNumberHint reservationNumberError"
                           value="${fn:escapeXml(not empty filterError ? param.reservationNumber : searchNumber)}">

                    <p class="field-hint" id="reservationNumberHint">
                        Optional. Part of the number works too.
                    </p>
                    <p class="field-error" id="reservationNumberError">
                        <c:out value="${filterError}" />
                    </p>
                </div>

                <div class="form-group">
                    <label for="year">Year</label>

                    <select id="year" name="year">
                        <option value="">All Years</option>
                        <%-- Only years this customer has reservations in. --%>
                        <c:forEach var="y" items="${reservationYears}">
                            <option value="${y}" ${y == selectedYear ? 'selected' : ''}>${y}</option>
                        </c:forEach>
                    </select>
                </div>

                <div class="form-group">
                    <label for="month">Month</label>

                    <select id="month" name="month">
                        <option value="">All Months</option>
                        <c:forEach var="monthName"
                                   items="January,February,March,April,May,June,July,August,September,October,November,December"
                                   varStatus="m">
                            <option value="${m.count}" ${m.count == selectedMonth ? 'selected' : ''}>${monthName}</option>
                        </c:forEach>
                    </select>
                </div>

                <div class="form-group">
                    <label for="status">Status</label>

                    <select id="status" name="status">
                        <option value="">All Statuses</option>
                        <option value="Active" ${selectedStatus == 'Active' ? 'selected' : ''}>Active</option>
                        <option value="Cancelled" ${selectedStatus == 'Cancelled' ? 'selected' : ''}>Cancelled</option>
                    </select>
                </div>

                <div class="form-group">
                    <label for="sort">Sort By</label>

                    <select id="sort" name="sort">
                        <option value="newest">Newest First</option>
                        <option value="oldest" ${oldestFirst ? 'selected' : ''}>Oldest First</option>
                    </select>
                </div>

                <div class="lookup-form__actions">
                    <button type="submit" class="btn-primary">Apply Filters</button>

                    <c:if test="${filtersApplied or oldestFirst or not empty filterError}">
                        <a class="lookup-clear"
                           href="${pageContext.request.contextPath}/reservations">Clear filters</a>
                    </c:if>
                </div>

            </form>

        </section>

        <c:choose>

            <c:when test="${not empty reservations}">

                <section class="reservation-results" aria-labelledby="resultsHeading">

                    <div class="results-header">
                        <h2 id="resultsHeading">Your Reservations</h2>
                        <p class="results-count">
                            ${fn:length(reservations)}
                            ${fn:length(reservations) == 1 ? 'reservation' : 'reservations'}
                        </p>
                    </div>

                    <c:forEach var="reservation" items="${reservations}">

                        <article class="reservation-card">

                            <h3>Reservation <c:out value="${reservation.confirmationNumber}" /></h3>

                            <div class="reservation-details">

                                <div class="reservation-details__column">
                                    <p>
                                        <strong>Start Date</strong><br>
                                        <fmt:formatDate value="${reservation.startDate}" pattern="MMM d, yyyy" />
                                    </p>

                                    <p>
                                        <strong>Dock / Slip</strong><br>
                                        Dock <c:out value="${reservation.dockNumber}" />,
                                        Slip <c:out value="${reservation.slipNumber}" />
                                    </p>

                                    <p>
                                        <strong>Slip Size</strong><br>
                                        <c:out value="${reservation.slipSizeFt}" /> ft
                                    </p>
                                </div>

                                <div class="reservation-details__column">
                                    <p>
                                        <strong>Lease Status</strong><br>
                                        <c:out value="${reservation.reservationStatus}" />
                                    </p>

                                    <p>
                                        <strong>Monthly Rate</strong><br>
                                        <fmt:formatNumber value="${reservation.monthlyRate}" type="currency" />/mo
                                    </p>

                                    <p>
                                        <strong>Boat</strong><br>
                                        <c:out value="${reservation.boatName}" />
                                        (<fmt:formatNumber value="${reservation.boatLength}" maxFractionDigits="1" /> ft)
                                    </p>

                                    <p>
                                        <strong>Electrical Hookup</strong><br>
                                        ${reservation.electricalHookup ? 'Yes' : 'No'}
                                    </p>
                                </div>

                            </div>

                        </article>

                    </c:forEach>

                </section>

            </c:when>

            <c:when test="${filtersApplied}">
                <section class="reservation-results lookup-empty">
                    <p class="lookup-message">No reservations match these filters.</p>
                    <a class="lookup-clear" href="${pageContext.request.contextPath}/reservations">Clear filters</a>
                </section>
            </c:when>

            <c:otherwise>
                <section class="reservation-results lookup-empty">
                    <p class="lookup-message">You don't have any reservations yet.</p>
                    <a class="btn-primary" href="${pageContext.request.contextPath}/reservation">Book a Slip</a>
                </section>
            </c:otherwise>

        </c:choose>

    </c:otherwise>

</c:choose>

    </main>

<jsp:include page="/includes/footer.jsp" />

<script src="${pageContext.request.contextPath}/js/lookUpReservation.js" defer></script>

</body>
</html>
