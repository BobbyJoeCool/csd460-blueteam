<%--
    Front End:   Sara White 
    Back End:    Carolina Rodriguez
    Team:        Blue Team - Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
    Primary Author/Owner - Sara White
    Course:      CSD 460 - Capstone Project
    Module:      Module 8 / Week 6 - Web Development 4
    Page:        Look Up Reservation (lookUpReservation.jsp)
    Contract:    marinawebsite/documentation/Page Contracts/Look Up Reservation.md

    This JSP provides the front-end interface for signed-in customers
    to look up their marina reservations.

    The page sends search criteria to the /reservations servlet using
    a GET request. Customers can search by reservation number, year,
    and month, and they can sort results by newest or oldest.

    If a lookup is performed and no matching reservation is found,
    the page displays a "No reservation found." message.

--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page isELIgnored="false" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>Look Up Reservation - Moffat Bay Marina</title>

    <jsp:include page="/includes/styles.jsp" /> <!-- Adds site.css, header.css, footer.css, loginModal.css -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/lookUpReservation.css">
</head>

<body>

    <jsp:include page="/includes/header.jsp">
        <jsp:param name="activePage" value="lookup" />
    </jsp:include>

    <section class="hero-band" id="lookUpReservationHero">
        <div class="hero-band__content">
            <h1>Look Up Your Reservation</h1>

            <p class="hero-band__lede">
                View your upcoming and past reservations.
            </p>
        </div>
    </section>

    <main class="lookup-page">

        <section class="reservation-lookup">

            <h2>Find Your Reservation</h2>

            <form method="get"
                  action="${pageContext.request.contextPath}/reservations"
                  class="lookup-form">

                <div class="form-group">

                    <!-- Optional input for reservation number -->
                    <label for="reservationNumber">
                        Reservation Number
                    </label>

                    <input
                        type="text"
                        id="reservationNumber"
                        name="reservationNumber">

                </div>

                <div class="form-group">

                    <!-- Optional input for year -->
                    <label for="year">Year</label>

                    <select id="year" name="year">
                        <option value="">All Years</option>
                        <option value="2026">2026</option>
                        <option value="2025">2025</option>
                        <option value="2024">2024</option>
                        <option value="2023">2023</option>
                        <option value="2022">2022</option>
                    </select>

                </div>

                <div class="form-group">

                    <!-- Optional input for month -->
                    <label for="month">Month</label>

                    <select id="month" name="month">
                        <option value="">All Months</option>
                        <option value="1">January</option>
                        <option value="2">February</option>
                        <option value="3">March</option>
                        <option value="4">April</option>
                        <option value="5">May</option>
                        <option value="6">June</option>
                        <option value="7">July</option>
                        <option value="8">August</option>
                        <option value="9">September</option>
                        <option value="10">October</option>
                        <option value="11">November</option>
                        <option value="12">December</option>
                    </select>

                </div>

                <button type="submit" class="btn-primary">
                    Look Up Reservation
                </button>

            </form>

        </section>

<c:choose>

    <c:when test="${not empty reservations}">   

        <section class="reservation-results">

            <div class="results-header">

                <h2>Your Reservations</h2>

                <form method="get"
                    action="${pageContext.request.contextPath}/reservations"
                    class="sort-form">

                    <!-- Preserve current search filters when sorting -->
                    <input type="hidden"
                        name="reservationNumber"
                        value="${param.reservationNumber}">

                    <input type="hidden"
                        name="year"
                        value="${param.year}">

                    <input type="hidden"
                        name="month"
                        value="${param.month}">

                    <label for="sort">Sort By</label>

                    <select id="sort" name="sort">
                        <option value="newest">Newest First</option>
                        <option value="oldest">Oldest First</option>
                    </select>

                    <button type="submit" class="btn-secondary">
                        Sort
                    </button>

                </form>

            </div>

                <c:forEach var="reservation" items="${reservations}">

                    <article class="reservation-card">

                        <h3>
                            Reservation #${reservation.confirmationNumber}
                        </h3>

                        <div class="reservation-details">

                                <p>
                                    <strong>Guest Name</strong><br>
                                    ${reservation.guestName}

                                </p>

                                <p>
                                    <strong>Slip</strong><br>
                                    ${reservation.slipNumber}
                                </p>

                                <p>
                                    <strong>Start Date</strong><br>
                                    ${reservation.startDate}
                                </p>

                                <p>
                                    <strong>Monthly Rate</strong><br>
                                    ${reservation.monthlyRate}
                                </p>
                            </div>

                            <div class="reservation-details__column">
                                <p>
                                    <strong>Lease Status</strong><br>
                                    ${reservation.reservationStatus}
                                </p>

                                <p>
                                    <strong>Boat</strong><br>
                                    ${reservation.boatName}
                                </p>

                            </div>

                        </div>

                    </article>

                </c:forEach>

        </section>

    </c:when>

    <c:when test="${lookupPerformed}">
        <section class="reservation-results">
        <p class="lookup-message lookup-message--error">
            No reservation found.
        </p>
        </section>
    </c:when>

</c:choose> 
    
    </main>

<jsp:include page="/includes/footer.jsp" />

</body>
</html>
