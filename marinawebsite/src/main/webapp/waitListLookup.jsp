<%--
    Front End:   Sara White
    Back End:    Miguel Fernandez
    Team:        Blue Team - Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
    Primary Author/Owner - Sara White
    Course:      CSD 460 - Capstone Project
    Module:      Module 9 / Week 7 - Web Development 5
    Page:        Wait List Lookup (waitListLookup.jsp)
    Contract:    documentation/Page Contracts/Wait List.md

 
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page isELIgnored="false" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>Wait List Lookup - Moffat Bay Marina</title>

    <jsp:include page="/includes/styles.jsp" /> <!-- Adds site.css, header.css, footer.css, loginModal.css -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/waitListLookup.css">
</head>

<body>

<jsp:include page="/includes/header.jsp" />

<header class="hero-band" id="waitListLookupHero">
    <div class="hero-band__content">
        <h1>See the Waitlist for Your Slip Size</h1>
    </div>

    <p class="hero-band__credit">
        Hero image created with Google Gemini
    </p>
</header>


<main class="waitlist-lookup-page">

    <!-- Public Waitlist (no login required)-->
    <section class="waitlist-availability-card">

        <h2>Current Waitlists by Slip Size</h2>

        <div class="waitlist-summary-grid">

            <c:forEach var="summary" items="${waitListSummaries}">

                <article class="waitlist-summary-card">

                    <h3>${summary.sizeFt} FT</h3>

                    <p>
                        <strong>Guests Waiting:</strong>
                        ${summary.inLineCount}
                    </p>

                    <c:choose>

                        <c:when test="${summary.availableNow}">
                            <p>
                                <strong>Availability:</strong>
                                Slips available now
                            </p>

                            <a class="btn-action"
                               href="${pageContext.request.contextPath}/reservation">
                                Book a Slip
                            </a>
                        </c:when>

                        <c:otherwise>
                            <p>
                                <strong>Estimated Wait:</strong>
                                ${summary.estimateLabel}
                            </p>
                        </c:otherwise>

                    </c:choose>

                </article>

            </c:forEach>

        </div>

    </section>


    <!-- Customer's personal waitlist information (must be logged in) -->
    <section class="your-waitlist-status">

        <h2>Your Place in Line</h2>

        <c:choose>

            <%-- Not signed in --%>
            <c:when test="${empty sessionScope.customerId}">

                <p>
                    Sign in to see your place in line.
                </p>

                <button type="button"
                        class="btn-primary"
                        onclick="MoffatBay.loginModal.open()">
                    Sign In
                </button>

            </c:when>


            <%-- Customer is not on a waitlist --%>
            <c:when test="${empty myWaitListEntries}">

                <p>You're not currently on the wait list.</p>

            </c:when>


            <%-- Customer is on at least one waitlist --%>
            <c:otherwise>

                <div class="waitlist-entry-grid">

                    <c:forEach var="entry" items="${myWaitListEntries}">

                        <article class="waitlist-entry-card">

                            <h3>${entry.sizeFt} FT Slip</h3>

                            <p>
                                <strong>Position:</strong>
                                ${entry.position}
                            </p>

                            <p>
                                <strong>People Ahead:</strong>
                                ${entry.peopleAhead}
                            </p>

                            <p>
                                <strong>Date Joined:</strong>
                                ${entry.timeJoined}
                            </p>

                            <p>
                                <strong>Estimated Wait:</strong>
                                ${entry.estimateLabel}
                            </p>

                        </article>

                    </c:forEach>

                </div>

            </c:otherwise>

        </c:choose>

    </section>

</main>

<jsp:include page="/includes/footer.jsp" />

</body>
</html>
