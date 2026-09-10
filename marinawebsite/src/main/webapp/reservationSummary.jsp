<%--
    Front End:   Carolina Rodriguez
    Back End:    Miguel Fernandez (pending - backend connection)

    BACKEND 
    -----------------
    The servlet should look up the reservation using the confirmation number,
    verify that it belongs to the currently logged-in customer,
    set one "reservation" request attribute,
    and then forward the request here.
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page isELIgnored="false" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<%-- JSP connect here. --%>
<%-- Backend pending --%>

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
            <button type="button" class="btn-primary"
                    onclick="MoffatBay.loginModal.open()">Sign in</button>
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
            <div class="summary-success-mark" aria-hidden="true">&#10003;</div>
            <p class="summary-eyebrow">Reservation Confirmed</p>
            <h1>Your Slip Is Reserved</h1>
            <p class="summary-lede">
                Keep your confirmation number handy for reservation lookup and future changes.
            </p>
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
                <div class="summary-detail-stack">
                    <section class="summary-section" aria-labelledby="vesselHeading">
                        <div class="summary-section__heading">
                            <span class="summary-section__number" aria-hidden="true">1</span>
                            <div>
                                <p class="summary-section__kicker">Vessel</p>
                                <h2 id="vesselHeading"><c:out value="${reservation.boatName}" /></h2>
                            </div>
                        </div>

                        <dl class="detail-grid">
                            <div>
                                <dt>Boat Type</dt>
                                <dd><c:out value="${reservation.boatType}" default="Not provided" /></dd>
                            </div>
                            <div>
                                <dt>Boat Length</dt>
                                <dd><fmt:formatNumber value="${reservation.boatLength}" minFractionDigits="1" maxFractionDigits="1" /> ft</dd>
                            </div>
                            <div>
                                <dt>Registration</dt>
                                <dd><c:out value="${reservation.regNumber}" default="Not provided" /></dd>
                            </div>
                        </dl>
                    </section>

                    <section class="summary-section" aria-labelledby="slipHeading">
                        <div class="summary-section__heading">
                            <span class="summary-section__number" aria-hidden="true">2</span>
                            <div>
                                <p class="summary-section__kicker">Slip Assignment</p>
                                <h2 id="slipHeading">Dock <c:out value="${reservation.dockNumber}" />, Slip <c:out value="${reservation.slipNumber}" /></h2>
                            </div>
                        </div>

                        <dl class="detail-grid">
                            <div>
                                <dt>Slip Size</dt>
                                <dd><c:out value="${reservation.slipSizeFt}" /> ft</dd>
                            </div>
                            <div>
                                <dt>Dock</dt>
                                <dd>Dock <c:out value="${reservation.dockNumber}" /></dd>
                            </div>
                            <div>
                                <dt>Slip Number</dt>
                                <dd><c:out value="${reservation.slipNumber}" /></dd>
                            </div>
                        </dl>
                    </section>

                    <section class="summary-section" aria-labelledby="leaseHeading">
                        <div class="summary-section__heading">
                            <span class="summary-section__number" aria-hidden="true">3</span>
                            <div>
                                <p class="summary-section__kicker">Lease Details</p>
                                <h2 id="leaseHeading">Starts <fmt:formatDate value="${reservation.startDate}" pattern="MMMM d, yyyy" /></h2>
                            </div>
                        </div>

                        <dl class="detail-grid">
                            <div>
                                <dt>Start Date</dt>
                                <dd><fmt:formatDate value="${reservation.startDate}" pattern="MMMM d, yyyy" /></dd>
                            </div>
                            <div>
                                <dt>Electric Hookup</dt>
                                <dd>
                                    <c:choose>
                                        <c:when test="${reservation.wantsElectric == true}">Yes</c:when>
                                        <c:when test="${reservation.wantsElectric == false}">No</c:when>
                                        <c:otherwise>Pending backend</c:otherwise>
                                    </c:choose>
                                </dd>
                            </div>
                            <div>
                                <dt>Lease Type</dt>
                                <dd>Month-to-month</dd>
                            </div>
                        </dl>
                    </section>
                </div>

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

                            <c:if test="${reservation.wantsElectric == true and not empty reservation.electricMonthlyRate}">
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

            <section class="summary-actions" aria-labelledby="actionsHeading">
                <div>
                    <p class="summary-section__kicker">Need to make a change?</p>
                    <h2 id="actionsHeading">Manage Your Reservation</h2>
                    <p>
                        You can return to the reservation page now. Cancellation will be connected
                        here when the Reservation Summary backend endpoint is ready.
                    </p>
                </div>

                <div class="summary-actions__buttons">
                    <a class="btn-primary summary-link-button"
                       href="${pageContext.request.contextPath}/reservation.jsp">Back to Reservations</a>
                    <%-- BACKEND: wire this button to the cancellation endpoint once the
                         servlet mapping and server-side validation are finalized. --%>
                    <button type="button" class="summary-cancel-button" disabled
                            title="Cancellation backend not connected yet">
                        Cancel Reservation
                    </button>
                </div>
            </section>
        </div>
    </c:otherwise>
</c:choose>
</main>

<jsp:include page="/includes/footer.jsp" />

</body>
</html>