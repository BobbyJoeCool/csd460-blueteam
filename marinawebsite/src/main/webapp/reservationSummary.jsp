<%--
    Front End:   Carolina Rodriguez
    Back End:    Miguel Fernandez

    BACK END - now connected
    ------------------------
    ReservationSummaryServlet (/reservationSummary) looks the reservation up
    by confirmation number, checks it belongs to the signed-in customer, and
    forwards here with one "reservation" attribute - a ReservationDetails.

    It sets instead of that, and this page renders instead of the summary:
      reservationSummaryError   nothing to show: no confirmation number, none
                                matching, or one belonging to someone else.
                                All three are deliberately the same message.
      signInRedirectTo          where to return after signing in, handed to
                                the login modal by the Sign in button.

    Cancelling POSTs back here with action=cancel and the confirmation
    number. See documentation/Page Contracts/Reservation Summary.md.
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page isELIgnored="false" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>



<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>Reservation Summary - Moffat Bay Marina</title>

    <jsp:include page="/includes/styles.jsp" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/reservationSummary.css">
</head>
<body>

<jsp:include page="/includes/header.jsp">
    <jsp:param name="activePage" value="reservation" />
</jsp:include>

<main>
<c:choose>
    <%-- Contract: reservation summary is not available while signed out. --%>
    <c:when test="${empty sessionScope.customerId}">
        <header class="summary-hero summary-hero--signin">
            <p class="summary-eyebrow">Reservation Details</p>
            <h1>Sign In to View Your Reservation</h1>
            <p class="summary-lede">
                Your reservation details are available after you sign in.
            </p>
        </header>

        <div class="summary-signin">
            <%-- signInRedirectTo is set by ReservationSummaryServlet. The modal
                 builds its own redirectTo from the request URI, which carries no
                 query string, so without this the confirmation number is lost on
                 the way back. --%>
            <button type="button" class="btn-primary"
                    onclick="MoffatBay.loginModal.open('${signInRedirectTo}')">Sign in</button>
            <p>
                No account yet?
                <a href="${pageContext.request.contextPath}/registration.jsp">Create one</a>.
            </p>
        </div>
    </c:when>

    <c:when test="${not empty reservationSummaryError or empty reservation}">
        <header class="summary-hero">
            <p class="summary-eyebrow">Reservation Details</p>
            <h1>Reservation Not Found</h1>
            <p class="summary-lede">
                <c:choose>
                    <c:when test="${not empty reservationSummaryError}">
                        <c:out value="${reservationSummaryError}" />
                    </c:when>
                    <c:otherwise>
                        We couldn't find the reservation you requested.
                    </c:otherwise>
                </c:choose>
            </p>
        </header>

        <div class="summary-error-actions">
            <a class="btn-primary summary-link-button"
               href="${pageContext.request.contextPath}/reservation.jsp">Return to Reservations</a>
        </div>
    </c:when>

<c:otherwise>
    <header class="summary-hero">

        <c:choose>
            <c:when test="${reservation.cancelled}">
                <div class="summary-cancelled-mark" aria-hidden="true">&#10005;</div>
                <p class="summary-eyebrow">Reservation Cancelled</p>
                <h1>Your Reservation Has Been Cancelled</h1>
                <p class="summary-lede">
                    This reservation is no longer active.
                </p>
            </c:when>

            <c:otherwise>
                <div class="summary-success-mark" aria-hidden="true">&#10003;</div>
                <p class="summary-eyebrow">Reservation Confirmed</p>
                <h1>Your Slip Is Reserved</h1>
                <p class="summary-lede">
                    Keep your confirmation number handy for reservation lookup and future changes.
                </p>
            </c:otherwise>
        </c:choose>

        <p class="confirmation-number">
            <span>Confirmation</span>
            <strong><c:out value="${reservation.confirmationNumber}" /></strong>
        </p>

    </header>

        <div class="summary-wrap">
            <section class="summary-status-band" aria-label="Reservation status">
                <div>
                    <span class="summary-status-label">Status</span>
                    <strong class="summary-status-value"><c:out value="${reservation.reservationStatus}" /></strong>
                </div>
                <p>
                    Month-to-month lease &bull; 30 days' notice is required to terminate your lease.
                </p>
            </section>

            <div class="summary-layout">

                <aside class="receipt-card" aria-labelledby="receiptHeading">
                    <div class="receipt-card__head">
                        <p>Reservation Summary</p>
                        <h2 id="receiptHeading">Moffat Bay Marina</h2>
                    </div>

                    <div class="receipt-card__body">
                        <dl class="receipt-lines">
                            <div>
                                <dt>Vessel</dt>
                                <dd><c:out value="${reservation.boatName}" /></dd>
                            </div>
                            <div>
                                <dt>Slip</dt>
                                <dd><c:out value="${reservation.slipSizeFt}" /> ft</dd>
                            </div>
                            <div>
                                <dt>Location</dt>
                                <dd>Dock <c:out value="${reservation.dockNumber}" />, Slip <c:out value="${reservation.slipNumber}" /></dd>
                            </div>
                            <div>
                                <dt>Start Date</dt>
                                <dd><fmt:formatDate value="${reservation.startDate}" pattern="MMM d, yyyy" /></dd>
                            </div>

                            <c:if test="${not empty reservation.baseMonthlyRate}">
                                <div>
                                    <dt>Slip Rental</dt>
                                    <dd><fmt:formatNumber value="${reservation.baseMonthlyRate}" type="currency" /></dd>
                                </div>
                            </c:if>

                            <c:if test="${reservation.electricalHookup and not empty reservation.electricMonthlyRate}">
                                <div>
                                    <dt>Electric</dt>
                                    <dd><fmt:formatNumber value="${reservation.electricMonthlyRate}" type="currency" /></dd>
                                </div>
                            </c:if>

                            <div class="receipt-total">
                                <dt>Monthly Rate</dt>
                                <dd><fmt:formatNumber value="${reservation.monthlyRate}" type="currency" />/mo</dd>
                            </div>
                        </dl>

                        <p class="receipt-note">
                            Your monthly rate begins on your lease start date. Keep your confirmation
                            number for reservation lookup and cancellation requests.
                        </p>
                    </div>
                </aside>
            </div>
            </div>

            <section class="summary-actions" aria-labelledby="actionsHeading">
                <div>
                    <p class="summary-section__kicker">Need to make a change?</p>
                    <h2 id="actionsHeading">Manage Your Reservation</h2>
                    <p>
                        You can return to the reservation page, or cancel this
                        reservation. Cancelling can't be undone - you would need
                        to book again.
                    </p>
                </div>

                <div class="summary-actions__buttons">
                    <a class="btn-primary summary-link-button"
                       href="${pageContext.request.contextPath}/reservation.jsp">Back to Reservations</a>
                    <%-- Only an Active reservation can be cancelled. The servlet
                         checks this as well - the confirm() below is a courtesy,
                         not a control. --%>
                    <c:if test="${reservation.active}">
                        <form method="post"
                              action="${pageContext.request.contextPath}/reservationSummary"
                              onsubmit="return confirm('Cancel this reservation? This cannot be undone.');">
                            <input type="hidden" name="action" value="cancel">
                            <input type="hidden" name="confirmation"
                                   value="${reservation.confirmationNumber}">
                            <button type="submit" class="summary-cancel-button">
                                Cancel Reservation
                            </button>
                        </form>
                    </c:if>
                </div>
            </section>
        </div>
    </c:otherwise>
</c:choose>
</main>

<jsp:include page="/includes/footer.jsp" />

</body>
</html>