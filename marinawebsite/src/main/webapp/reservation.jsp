<%--
    Front End:   Robert Breutzmann
    Back End:    Sara White (not built yet - this page runs on stub data)
    Course:      CSD 460 - Capstone Project
    Module:      Module 6 / Week 5 - Web Development 2
    Page:        Reservation (Book a Slip) (reservation.jsp)
    Contract:    marinawebsite/documentation/Page Contracts/Reservation.md
    Wireframe:   Module-2/Finalized WireFrames/Reservation Page.png
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page isELIgnored="false" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<%-- BACKEND: delete this include. ReservationServlet.doGet sets the same
     three request attributes. --%>
<jsp:include page="/includes/_stubReservationData.jsp" />

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>Reserve a Slip - Moffat Bay Marina</title>

    <jsp:include page="/includes/styles.jsp" /> <!-- site, header, footer, loginModal, statusPopup -->
    <%-- registration.css carries the shared form-card styles the boat panel
         reuses (.form-group, .field-error, .callout-badge, ...). --%>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/registration.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/reservation.css">
</head>
<body>

<jsp:include page="/includes/header.jsp">
    <jsp:param name="activePage" value="reservation" />
</jsp:include>

<main>

<c:choose>

    <%-- Signed out: the page can't know whose boats to list, so it becomes
         the sign-in prompt. The login modal works out its own redirectTo
         from the current path, so they land back here. --%>
    <c:when test="${empty sessionScope.customerId}">
        <header class="reservation-hero">
            <p class="reservation-eyebrow">Month-to-Month Marina Lease</p>
            <h1>Reserve Your Slip</h1>
            <p class="reservation-lede">Please sign in to reserve a slip.</p>
        </header>
        <div class="reservation-signin">
            <button type="button" class="btn-primary"
                    onclick="MoffatBay.loginModal.open()">Sign in</button>
            <p>
                No account yet?
                <a href="${pageContext.request.contextPath}/registration.jsp">Create one</a>.
            </p>
        </div>
        <script>
            window.addEventListener("DOMContentLoaded", function () {
                MoffatBay.loginModal.open();
            });
        </script>
    </c:when>

    <c:otherwise>

        <header class="reservation-hero">
            <p class="reservation-eyebrow">Month-to-Month Marina Lease</p>
            <h1>Reserve Your Slip</h1>
            <p class="reservation-lede">
                Choose your vessel and dock, add power if you need it, and pick your start date.
            </p>
        </header>

        <div class="reservation-wrap">

            <p class="lease-notice">
                <span class="lease-notice__icon" aria-hidden="true">i</span>
                All slips are rented on a month-to-month basis. 30 days' notice
                is required to terminate a lease.
            </p>

            <%-- The rates, stated once. Rent follows the BOAT's length, not
                 the slip's size, which is the thing people get backwards, so
                 it is said plainly here rather than left to be inferred from
                 the total. Both figures come from the Rate table. --%>
            <p class="pricing-note">
                <strong>$<span id="ratePerFoot"></span> per foot</strong> of your
                boat's length, per month &mdash; so the price follows your boat,
                not the size of the slip it sits in.
                <br />Add an electric hookup for a flat
                <strong>$<span id="rateElectric"></span> a month</strong>.
            </p>

            <%-- Free slips per dock per size, known at page load. This is what
                 lets a full size be flagged the moment a boat is picked, rather
                 than after Submit. The totals on the size cards above are summed
                 from this, so there is only one availability figure to keep
                 right. --%>
            <script id="dockAvailability" type="application/json">[<c:forEach var="d" items="${docks}" varStatus="st">{"dockId":${d.dockId},"dockNumber":"${d.dockNumber}","available":{"26":${d.available['26']},"40":${d.available['40']},"50":${d.available['50']}}}<c:if test="${not st.last}">,</c:if></c:forEach>]</script>
            <script id="reservationRates" type="application/json">{"perFootCents":${perFootCents},"electricCents":${electricCents}}</script>

            <%-- ===== Slip availability, full width ===== =====================
                 Not a picker. These show what is free; the vessel chosen in
                 step 1 decides which one applies, and that card highlights.
                 ============================================================ --%>
            <section class="slip-band" aria-labelledby="slipBandHeading">
                <h2 class="step-heading" id="slipBandHeading">Our Slips</h2>
                <p class="step-hint" id="sizeHint">
                    Choose your vessel below and we'll highlight the size it needs.
                </p>

                <ul class="slip-sizes">
                    <li class="slip-card" data-size="26">
                        <span class="slip-card__head">
                            <span class="slip-card__name">26 ft Slip</span>
                            <span class="slip-card__tier">Standard</span>
                        </span>
                        <span class="slip-card__stock" data-stock="26"></span>
                        <span class="slip-card__desc">
                            Perfect for smaller cruisers, day boats, and
                            runabouts. Includes power and fresh water.
                        </span>
                        <span class="slip-card__match" data-match="26" hidden>Fits your boat</span>
                    </li>

                    <li class="slip-card" data-size="40">
                        <span class="slip-card__head">
                            <span class="slip-card__name">40 ft Slip</span>
                            <span class="slip-card__tier">Premier</span>
                        </span>
                        <span class="slip-card__stock" data-stock="40"></span>
                        <span class="slip-card__desc">
                            Ideal for mid-size vessels and sailboats up to 40 ft.
                            Shore power and pump-out service included.
                        </span>
                        <span class="slip-card__match" data-match="40" hidden>Fits your boat</span>
                    </li>

                    <li class="slip-card" data-size="50">
                        <span class="slip-card__head">
                            <span class="slip-card__name">50 ft Slip</span>
                            <span class="slip-card__tier">Grand</span>
                        </span>
                        <span class="slip-card__stock" data-stock="50"></span>
                        <span class="slip-card__desc">
                            Spacious berth for large yachts. Dedicated dock
                            attendant and full utilities.
                        </span>
                        <span class="slip-card__match" data-match="50" hidden>Fits your boat</span>
                    </li>
                </ul>

                <%-- Full size, or nothing that fits. Sits under the cards it
                     refers to, full width. --%>
                <div class="availability-panel" id="availabilityPanel" hidden>
                    <p class="availability-message" id="availabilityMessage"></p>

                    <div class="waitlist-prompt" id="waitListPrompt" hidden>
                        <p id="waitListQuestion"></p>
                        <div class="waitlist-actions">
                            <button type="button" class="btn-primary" id="joinWaitList">Join the wait list</button>
                            <button type="button" class="btn-clear-section" id="declineWaitList">No thanks</button>
                        </div>
                        <div class="field-error" id="waitListError"></div>
                    </div>
                </div>
            </section>

            <div class="reservation-layout">

                <form id="reservationForm" class="reservation-steps"
                      action="${pageContext.request.contextPath}/reservation" method="post" novalidate>

                    <%-- BACKEND: a general failure message goes here. --%>
                    <div class="form-banner" id="formError" role="alert" hidden></div>

                    <%-- ===== Step 1: vessel ===== --%>
                    <section class="step-card">
                        <h2 class="step-heading">1. Choose Your Vessel</h2>

                        <div class="form-group">
                            <label for="boatId">Boat <span class="required-mark">*</span></label>

                            <c:choose>
                                <c:when test="${empty ownedBoats}">
                                    <select id="boatId" name="boatId" disabled>
                                        <option value="">No boats registered</option>
                                    </select>
                                </c:when>
                                <c:otherwise>
                                    <select id="boatId" name="boatId">
                                        <option value="">Choose a boat&hellip;</option>
                                        <c:forEach var="b" items="${ownedBoats}">
                                            <option value="${b.boatId}"
                                                    data-boat-length="${b.boatLength}"
                                                    data-slip-size="${b.slipSizeFt}"
                                                    data-monthly-cents="${b.monthlyCents}"
                                                    data-boat-name="${fn:escapeXml(b.boatName)}"
                                                    data-reserved="${b.hasActiveReservation}">${fn:escapeXml(b.boatName)} &mdash; ${b.boatLength} ft<c:if test="${b.hasActiveReservation}"> (reserved)</c:if></option>
                                        </c:forEach>
                                    </select>
                                </c:otherwise>
                            </c:choose>

                            <div class="field-hint">
                                Your boat's length decides which slip size it needs.
                            </div>
                            <div class="field-error" id="boatError"></div>

                            <button type="button" class="btn-clear-section" id="openBoatPanel">
                                <c:choose>
                                    <c:when test="${empty ownedBoats}">Register your boat</c:when>
                                    <c:otherwise>Register another boat</c:otherwise>
                                </c:choose>
                            </button>
                        </div>
                    </section>

                    <%-- ===== Step 2: dock ===== ===========================
                         Which dock, not which slip. The slip itself is still
                         assigned automatically, but the docks sit in different
                         parts of the marina, so which one you are on is a real
                         choice worth giving people.

                         Only shows counts for the size the chosen boat needs -
                         a dock with three 26 ft slips free is no use to a 40 ft
                         boat, so showing its total would be misleading.
                         ==================================================== --%>
                    <section class="step-card">
                        <h2 class="step-heading">2. Choose Your Dock</h2>

                        <p class="step-hint" id="dockHint">
                            Pick your vessel above and we'll show which docks have
                            room for it.
                        </p>

                        <fieldset class="dock-choices">
                            <legend class="visually-hidden">Dock</legend>
                            <c:forEach var="d" items="${docks}">
                                <label class="dock-card" data-dock="${d.dockId}">
                                    <input type="radio" name="dockId" value="${d.dockId}" disabled>
                                    <span class="dock-card__body">
                                        <span class="dock-card__name">Dock ${d.dockNumber}</span>
                                        <span class="dock-card__desc">${fn:escapeXml(d.dockDescription)}</span>
                                        <span class="dock-card__stock" data-dock-stock="${d.dockId}"></span>
                                    </span>
                                </label>
                            </c:forEach>
                        </fieldset>

                        <div class="field-error" id="dockError"></div>

                        <figure class="marina-map">
                            <img src="${pageContext.request.contextPath}/images/marina_a.png"
                                 alt="Map of Moffat Bay Marina showing Dock A closest to the Ship
                                      Store, Dock B in the middle, and Dock C closest to the Office,
                                      Restaurant and Fuel Dock. Each dock has 24 slips: numbers 8 to
                                      12 and 20 to 24 are 26 ft, numbers 4 to 7 and 16 to 19 are
                                      40 ft, and the rest are 50 ft.">
                            <figcaption>
                                Slips 8&ndash;12 and 20&ndash;24 on every dock are 26 ft,
                                4&ndash;7 and 16&ndash;19 are 40 ft, and the rest are 50 ft.
                                We'll assign you a slip on the dock you choose.
                            </figcaption>
                        </figure>
                    </section>

                    <%-- ===== Step 3: electric ===== --%>
                    <section class="step-card">
                        <h2 class="step-heading">3. Electric Hookup</h2>

                        <div class="form-group form-group-check">
                            <label for="wantsElectric">
                                <input type="checkbox" id="wantsElectric" name="wantsElectric"
                                       value="yes" data-electric-cents="${electricCents}">
                                Yes, I need an electric hookup
                            </label>
                            <div class="field-hint">A flat monthly fee, the same whatever the size of your boat.</div>
                        </div>
                    </section>

                    <%-- ===== Step 4: start date ===== --%>
                    <section class="step-card">
                        <h2 class="step-heading">4. Lease Start Date</h2>

                        <div class="form-group">
                            <label for="checkInDate">Start Date <span class="required-mark">*</span></label>
                            <%-- min is set to today by reservation.js, so nothing
                                 has to be rendered server-side. --%>
                            <input type="date" id="checkInDate" name="checkInDate">
                            <div class="field-error" id="dateError"></div>
                        </div>
                    </section>
                </form>

                <%-- ===== Reservation Summary ===== --%>
                <aside class="summary-card" aria-live="polite">
                    <div class="summary-card__head">
                        <p class="summary-card__eyebrow">Reservation Summary</p>
                        <p class="summary-card__marina">Moffat Bay Marina</p>
                    </div>

                    <div class="summary-card__body">
                        <dl class="summary-lines">
                            <div class="summary-line">
                                <dt>Slip</dt>
                                <dd id="summarySlip">&mdash;</dd>
                            </div>
                            <div class="summary-line">
                                <dt>Vessel</dt>
                                <dd id="summaryBoat">&mdash;</dd>
                            </div>
                            <div class="summary-line">
                                <dt>Dock</dt>
                                <dd id="summaryDock">&mdash;</dd>
                            </div>
                            <div class="summary-line">
                                <dt>Start Date</dt>
                                <dd id="summaryDate">&mdash;</dd>
                            </div>
                            <div class="summary-line" id="summaryElectricLine" hidden>
                                <dt>Electric hookup</dt>
                                <dd id="summaryElectric">&mdash;</dd>
                            </div>
                            <div class="summary-line summary-total">
                                <dt>Monthly Rate</dt>
                                <dd id="summaryTotal">&mdash;</dd>
                            </div>
                        </dl>

                        <button type="submit" form="reservationForm"
                                class="btn-primary summary-cta" id="submitReservation" disabled>
                            Reserve My Slip
                        </button>

                        <ul class="summary-notes">
                            <li>30-day notice to vacate</li>
                            <li>Instant confirmation by email</li>
                        </ul>
                    </div>
                </aside>
            </div>
        </div>

        <%-- Register a Boat panel. Saves in the background - the page never
             reloads and nothing already filled in is lost. Reuses the
             Registration page's boat card. --%>
        <div class="boat-panel" id="boatPanel" role="dialog" aria-modal="true"
             aria-labelledby="boatPanelTitle"
             data-country="${fn:escapeXml(sessionScope.customer.country)}" hidden>
            <div class="boat-panel__backdrop" data-boat-close></div>

            <div class="boat-panel__box">
                <button type="button" class="boat-panel__close" data-boat-close
                        aria-label="Close">&times;</button>

                <h2 id="boatPanelTitle">Register a Boat</h2>

                <p class="boat-panel__lead" id="boatPanelLead" hidden>
                    You'll need a registered boat before you can reserve a slip.
                </p>

                <div class="form-banner" id="boatPanelError" role="alert" hidden></div>

                <form id="boatPanelForm" novalidate>
                    <jsp:include page="/includes/boatInfoCard.jsp">
                        <jsp:param name="country" value="${sessionScope.customer.country}" />
                    </jsp:include>

                    <div class="submit-row">
                        <button type="submit" class="btn-primary" id="saveBoat">Save boat</button>
                    </div>
                </form>
            </div>
        </div>

    </c:otherwise>
</c:choose>

</main>

<jsp:include page="/includes/footer.jsp" />

<script src="${pageContext.request.contextPath}/js/reservation.js"></script>

</body>
</html>
