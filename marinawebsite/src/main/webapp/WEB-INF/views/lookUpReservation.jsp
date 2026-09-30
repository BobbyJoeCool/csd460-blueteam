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
      actionError       - a cancel or 30-day notice that was turned down,
                          shown once.
      earliestTerminationDate / latestTerminationDate (yyyy-MM-dd),
      earliestTerminationDisplay, minNoticeDays
                        - the notice popup's date range (BR-21).
      noticeWithdrawalCutoffDays
                        - how many days before a notice's last day it can
                          still be withdrawn (BR-23), for the card's wording.

    Each card offers Cancel Reservation before its lease starts, Submit
    30-Day Notice after, and Withdraw Notice while a notice is open and
    it's not yet too close to the last day. Each opens a popup and posts to
    ReservationChangeServlet (/reservations/cancel, /reservations/notice,
    /reservations/withdraw), which lands on the Reservation Summary as the
    confirmation.
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

    <header class="hero-band" id="lookUpReservationHero">
        <div class="hero-band__content">
            <h1>My Reservations</h1>

            <p class="hero-band__lede">
                Your upcoming and past slip reservations.
            </p>
        </div>
        <p class="hero-band__credit">Hero image created with Google Gemini</p>
    </header>

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

        <%-- A cancel or notice ReservationChangeServlet turned down. --%>
        <c:if test="${not empty actionError}">
            <div class="form-banner lookup-banner" role="alert">
                <c:out value="${actionError}" />
            </div>
        </c:if>

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

                        <article class="reservation-card"
                                 data-confirmation="${fn:escapeXml(reservation.confirmationNumber)}"
                                 data-boat-name="${fn:escapeXml(reservation.boatName)}"
                                 data-location="Dock ${fn:escapeXml(reservation.dockNumber)}, Slip ${reservation.slipNumber}"
                                 data-start="<fmt:formatDate value='${reservation.startDate}' pattern='MMM d, yyyy' />"
                                 data-last-day="<fmt:formatDate value='${reservation.terminationDate}' pattern='MMM d, yyyy' />">

                            <h3>Reservation <c:out value="${reservation.confirmationNumber}" /></h3>

                            <div class="reservation-details">

                                <div class="reservation-details__column">
                                    <p>
                                        <strong>Start Date</strong><br>
                                        <fmt:formatDate value="${reservation.startDate}" pattern="MMM d, yyyy" />
                                    </p>

                                    <%-- Only while a notice is in progress: that's when
                                         the lease has an end date. --%>
                                    <c:if test="${reservation.noticeOpen}">
                                        <p>
                                            <strong>Lease End Date</strong><br>
                                            <c:choose>
                                                <c:when test="${not empty reservation.terminationDate}">
                                                    <fmt:formatDate value="${reservation.terminationDate}" pattern="MMM d, yyyy" />
                                                </c:when>
                                                <c:otherwise>Not set yet</c:otherwise>
                                            </c:choose>
                                        </p>
                                    </c:if>

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

                                    <c:if test="${not empty reservation.noticeStatus}">
                                        <p>
                                            <strong>30-Day Notice</strong><br>
                                            <c:out value="${reservation.noticeStatus}" />
                                        </p>
                                    </c:if>

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

                            <%-- What can be done depends on whether the lease has
                                 started (ReservationDetails decides; the servlet
                                 and DAO re-check). Before: cancel outright. After:
                                 30 days' notice. With a notice open: withdraw it,
                                 until the cutoff before its last day (BR-23).
                                 Each button opens a popup below. --%>
                            <c:if test="${reservation.cancellable or reservation.noticeAllowed or (reservation.active and reservation.noticeOpen)}">
                                <div class="reservation-card__actions">
                                    <c:choose>
                                        <c:when test="${reservation.cancellable}">
                                            <button type="button" class="btn-outline btn-danger js-open-cancel">Cancel Reservation</button>
                                            <span class="reservation-card__hint">Available until your lease starts.</span>
                                        </c:when>
                                        <c:when test="${reservation.noticeAllowed}">
                                            <button type="button" class="btn-outline js-open-notice">Submit 30-Day Notice</button>
                                            <span class="reservation-card__hint">Your lease has started, so ending it takes at least 30 days' notice.</span>
                                        </c:when>
                                        <c:when test="${reservation.noticeWithdrawable}">
                                            <button type="button" class="btn-outline js-open-withdraw">Withdraw Notice</button>
                                            <span class="reservation-card__hint">
                                                <c:choose>
                                                    <c:when test="${not empty reservation.withdrawDeadlineDisplay}">Changed your mind? You may withdraw this notice until ${noticeWithdrawalCutoffDays} days before your lease end date (<c:out value="${reservation.withdrawDeadlineDisplay}" />).</c:when>
                                                    <c:otherwise>Changed your mind? You may withdraw this notice until ${noticeWithdrawalCutoffDays} days before your lease end date.</c:otherwise>
                                                </c:choose>
                                            </span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="reservation-card__hint">This notice can no longer be withdrawn. A notice may be withdrawn until ${noticeWithdrawalCutoffDays} days before the lease end date, which was <c:out value="${reservation.withdrawDeadlineDisplay}" />.</span>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </c:if>

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

<c:if test="${not signInRequired and not empty reservations}">

<%-- Cancel confirmation. Filled in by lookUpReservation.js from the card
     that was clicked; open/close comes from modal.js. --%>
<div class="modal" id="cancelModal" role="dialog" aria-modal="true"
     aria-labelledby="cancelModalTitle" hidden>

    <button type="button" class="modal__backdrop" data-modal-close aria-label="Close"></button>

    <div class="modal__box modal__box--narrow">

        <div class="modal__header">
            <h2 class="modal__title" id="cancelModalTitle">Cancel this reservation?</h2>
            <button type="button" class="modal__close" data-modal-close aria-label="Close">&times;</button>
        </div>

        <p class="modal__question" id="cancelQuestion"></p>
        <p class="modal__note">
            Cancelling can't be undone. The slip is released, and you would
            need to book again to get one.
        </p>

        <form method="post" action="${pageContext.request.contextPath}/reservations/cancel">
            <input type="hidden" name="confirmation" class="js-modal-confirmation" value="">
            <div class="modal__actions">
                <button type="button" class="btn-outline" data-modal-close>Keep Reservation</button>
                <button type="submit" class="btn-action btn-danger">Yes, Cancel It</button>
            </div>
        </form>

    </div>
</div>

<%-- 30-day termination notice (BR-21). The date range comes from
     LookUpReservationServlet, which reads it from Utils - the rule has one
     home, and TerminationNotice/ReservationChangeServlet check it again. --%>
<div class="modal" id="noticeModal" role="dialog" aria-modal="true"
     aria-labelledby="noticeModalTitle" hidden>

    <button type="button" class="modal__backdrop" data-modal-close aria-label="Close"></button>

    <div class="modal__box modal__box--narrow">

        <div class="modal__header">
            <h2 class="modal__title" id="noticeModalTitle">Submit 30-Day Notice</h2>
            <button type="button" class="modal__close" data-modal-close aria-label="Close">&times;</button>
        </div>

        <p class="modal__question" id="noticeQuestion"></p>
        <p class="modal__note">
            Your lease is month-to-month and needs at least ${minNoticeDays}
            days' notice. Choose your lease end date: the last day your boat
            will be in the slip.
        </p>

        <form method="post" action="${pageContext.request.contextPath}/reservations/notice" id="noticeForm" novalidate>
            <input type="hidden" name="confirmation" class="js-modal-confirmation" value="">

            <div class="form-group lookup-notice__date">
                <label for="lastDay">Lease End Date</label>
                <input type="date" id="lastDay" name="lastDay" required
                       min="${earliestTerminationDate}" max="${latestTerminationDate}"
                       value="${earliestTerminationDate}"
                       aria-describedby="lastDayHint lastDayError">
                <p class="field-hint" id="lastDayHint">
                    The earliest you can choose is <c:out value="${earliestTerminationDisplay}" />.
                </p>
                <p class="field-error" id="lastDayError"></p>
            </div>

            <div class="modal__actions">
                <button type="button" class="btn-outline" data-modal-close>Go Back</button>
                <button type="submit" class="btn-action">Submit Notice</button>
            </div>
        </form>

    </div>
</div>

<%-- Withdraw a 30-day notice (BR-23). Allowed until
     Utils.NOTICE_WITHDRAWAL_CUTOFF_DAYS before the notice's last day; the
     button only shows while it is, and the DAO checks again. --%>
<div class="modal" id="withdrawModal" role="dialog" aria-modal="true"
     aria-labelledby="withdrawModalTitle" hidden>

    <button type="button" class="modal__backdrop" data-modal-close aria-label="Close"></button>

    <div class="modal__box modal__box--narrow">

        <div class="modal__header">
            <h2 class="modal__title" id="withdrawModalTitle">Withdraw your 30-day notice?</h2>
            <button type="button" class="modal__close" data-modal-close aria-label="Close">&times;</button>
        </div>

        <p class="modal__question" id="withdrawQuestion"></p>
        <p class="modal__note">
            Your lease carries on month to month at the same rate, as if the
            notice had never been given. You may withdraw a notice until
            ${noticeWithdrawalCutoffDays} days before your lease end date, and
            you can give notice again later.
        </p>

        <form method="post" action="${pageContext.request.contextPath}/reservations/withdraw">
            <input type="hidden" name="confirmation" class="js-modal-confirmation" value="">
            <div class="modal__actions">
                <button type="button" class="btn-outline" data-modal-close>Keep Notice</button>
                <button type="submit" class="btn-action">Yes, Withdraw It</button>
            </div>
        </form>

    </div>
</div>

</c:if>

<jsp:include page="/includes/footer.jsp" />

<script src="${pageContext.request.contextPath}/js/lookUpReservation.js" defer></script>

</body>
</html>
