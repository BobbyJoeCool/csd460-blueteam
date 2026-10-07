<%--
  src/main/webapp/WEB-INF/views/myFleet.jsp

  My Fleet - every boat the signed-in customer currently owns, with what
  each one is doing right now, per documentation/Page Contracts/My Fleet.md.

  Reached at /myFleet (MyFleetServlet), never as myFleet.jsp directly, the
  same rule every servlet-backed page here follows.

  Reads:
    fleet       - List<Boat>, one per boat with an open BoatOwnership row,
                  each carrying its Active reservation's dock, slip, start
                  date and confirmation number when it has one. Empty or
                  absent renders the empty state, which is what this page
                  when the customer has no boats.
    formError   - a banner message above the fleet.
    fieldErrors - Map<String, String> field name -> message, moved into each
                  field's error box inside the modal by myFleet.js.
    openForm    - "add" or "edit": reopen that modal after a failed save.
    editBoatId  - which boat the reopened Edit modal belongs to.

  Author: Robert Breutzmann
  Blue Team - Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
  Primary Author/Owner - Robert Breutzmann (Front End) / Carolina Rodriguez (Back End)
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<%--
  Signed out, MyFleetServlet forwards here with signInRequired set, and the
  page shows the shared sign-in panel instead of a fleet (issue #257).

  Defence in depth. Reached signed out any other way, hand it to the servlet
  rather than render a customer's boats for nobody. Same guard as
  editUserInfo.jsp.
--%>
<c:if test="${empty sessionScope.customer and not requestScope.signInRequired}">
    <c:redirect url="/myFleet" />
</c:if>

<c:set var="ctx" value="${pageContext.request.contextPath}" />

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Fleet - Moffat Bay Marina</title>

    <jsp:include page="/WEB-INF/includes/styles.jsp" />
    <link rel="stylesheet" href="${ctx}/css/myFleet.css?v=${applicationScope.assetVersion}">
</head>
<body>

<jsp:include page="/WEB-INF/includes/header.jsp">
    <jsp:param name="activePage" value="myfleet" />
</jsp:include>

<%-- The hero sits outside <main>, like every hero on the site (see
     .hero-band in site.css), so it spans the window. --%>
<section class="hero-band" id="fleetHero" aria-labelledby="fleetHeroTitle">
    <div class="hero-band__content">
        <h1 id="fleetHeroTitle">My Fleet</h1>
        <p class="hero-band__lede">
            Every boat you own, and where it's berthed. Edit a boat's
            details, remove one you no longer own, or register a new one.
        </p>
    </div>
    <p class="hero-band__credit">Image created with Google Gemini</p>
</section>

<main id="main" tabindex="-1">

<c:choose>
<c:when test="${requestScope.signInRequired}">

    <jsp:include page="/WEB-INF/includes/signInPanel.jsp">
        <jsp:param name="heading" value="Sign In to View Your Fleet" />
        <jsp:param name="message" value="Your boats are listed here after you sign in." />
    </jsp:include>

</c:when>
<c:otherwise>

    <div class="fleet-page">

        <%-- A successful edit is confirmed by the "Boat updated" toast, after
             the popup has already shown exactly what was about to change. --%>

        <%-- Page-level errors only (e.g. a Remove that was turned down). An
             error from a failed Add or Edit belongs to the popup that reopens
             with it - myFleet.js puts it in that popup's own banner - so it
             doesn't linger on the page after the popup is closed. --%>
        <c:if test="${not empty formError and empty openForm}">
            <div class="form-banner form-banner--error" id="formError" role="alert">
                <c:out value="${formError}" />
            </div>
        </c:if>

        <div class="fleet-header">
            <h2 class="fleet-header__title">
                Your Boats
                <c:if test="${not empty fleet}">
                    <span class="fleet-count-badge">${fn:length(fleet)} ${fn:length(fleet) == 1 ? 'boat' : 'boats'}</span>
                </c:if>
            </h2>
        </div>

        <c:choose>

            <c:when test="${not empty fleet}">

                <%-- Two columns once there are four boats; one per row below
                     that. The class carries the count so the stylesheet can
                     decide, rather than the server. --%>
                <div class="fleet-list ${fn:length(fleet) >= 4 ? 'fleet-list--two-up' : ''}" id="fleetList">

                    <c:forEach var="boat" items="${fleet}">

                        <%-- EL gotcha: the getter is getHIN(), so it is
                             ${boat.HIN} and NOT ${boat.hin}, which renders
                             blank. Noted in the My Fleet contract. --%>
                        <c:set var="boatHin" value="${boat.HIN}" />

                        <article class="detail-card fleet-card"
                                 data-boat-id="${fn:escapeXml(boat.boatId)}"
                                 data-boat-name="${fn:escapeXml(boat.boatName)}"
                                 data-boat-type="${fn:escapeXml(boat.boatType)}"
                                 data-boat-length="${fn:escapeXml(boat.boatLength)}"
                                 data-boat-beam="${fn:escapeXml(boat.boatBeam)}"
                                 data-boat-year="${fn:escapeXml(boat.boatYear)}"
                                 data-hin="${fn:escapeXml(boatHin)}"
                                 data-reg-number="${fn:escapeXml(boat.regNumber)}"
                                 data-reserved="${boat.hasActiveReservation}">

                            <h3 class="card-title"><c:out value="${boat.boatName}" /></h3>

                            <div class="status-pill-row">
                                <c:choose>
                                    <c:when test="${boat.hasActiveReservation}">
                                        <p class="status-pill status-pill--active">
                                            <span class="status-pill__dot" aria-hidden="true">&#9679;</span>
                                            <span class="status-pill__label">Reserved &mdash;
                                                Dock <c:out value="${boat.activeDockNumber}" />,
                                                Slip <c:out value="${boat.activeSlipNumber}" />
                                                <%-- The code painted on the slip itself. Composed
                                                     here from the dock letter and slip number, not
                                                     stored - see "Slip Naming" in
                                                     documentation/definitions_decisions.md. --%>
                                                <span class="status-pill__code">(<c:out value="${boat.activeDockNumber}" />-<fmt:formatNumber value="${boat.activeSlipNumber}" minIntegerDigits="2" />)</span>
                                            </span>
                                            <%-- Boat.getActiveStartDateDisplay() arrives
                                                 already formatted: fmt:formatDate cannot take a
                                                 LocalDate (same pattern as Customer's
                                                 getDateJoinedDisplay()). --%>
                                            <span class="status-pill__detail">since
                                                <c:out value="${boat.activeStartDateDisplay}" />
                                                &middot; <c:out value="${boat.activeConfirmationNumber}" /></span>
                                        </p>
                                    </c:when>
                                    <c:otherwise>
                                        <p class="status-pill status-pill--idle">
                                            <span class="status-pill__dot" aria-hidden="true">&#9675;</span>
                                            <span class="status-pill__label">Open to Reserve</span>
                                            <%-- ?boatId= opens the Reservation page with this boat
                                                 already picked; reservation.js reads it on load. --%>
                                            <a class="status-pill__link"
                                               href="${ctx}/reservation?boatId=${fn:escapeXml(boat.boatId)}">Book a Slip <span aria-hidden="true">&rarr;</span></a>
                                        </p>
                                    </c:otherwise>
                                </c:choose>
                            </div>

                            <div class="record-badges fleet-badges">
                                <div class="record-badge ${empty boat.boatType ? 'record-badge--empty' : ''}">
                                    <span class="record-badge__label">Type</span>
                                    <span class="record-badge__value"><c:choose><c:when test="${empty boat.boatType}">&mdash;</c:when><c:otherwise><c:out value="${boat.boatType}" /></c:otherwise></c:choose></span>
                                </div>
                                <div class="record-badge ${empty boatHin ? 'record-badge--empty' : ''}">
                                    <span class="record-badge__label">HIN</span>
                                    <span class="record-badge__value"><c:choose><c:when test="${empty boatHin}">&mdash;</c:when><c:otherwise><c:out value="${boatHin}" /></c:otherwise></c:choose></span>
                                </div>
                                <div class="record-badge">
                                    <span class="record-badge__label">Length</span>
                                    <span class="record-badge__value"><fmt:formatNumber value="${boat.boatLength}" maxFractionDigits="1" /> ft</span>
                                </div>
                                <div class="record-badge ${empty boat.regNumber ? 'record-badge--empty' : ''}">
                                    <span class="record-badge__label">Registration</span>
                                    <span class="record-badge__value"><c:choose><c:when test="${empty boat.regNumber}">&mdash;</c:when><c:otherwise><c:out value="${boat.regNumber}" /></c:otherwise></c:choose></span>
                                </div>
                                <div class="record-badge ${empty boat.boatBeam ? 'record-badge--empty' : ''}">
                                    <span class="record-badge__label">Beam</span>
                                    <span class="record-badge__value"><c:choose><c:when test="${empty boat.boatBeam}">&mdash;</c:when><c:otherwise><fmt:formatNumber value="${boat.boatBeam}" maxFractionDigits="1" /> ft</c:otherwise></c:choose></span>
                                </div>
                                <div class="record-badge ${empty boat.boatYear ? 'record-badge--empty' : ''}">
                                    <span class="record-badge__label">Year</span>
                                    <span class="record-badge__value"><c:choose><c:when test="${empty boat.boatYear}">&mdash;</c:when><c:otherwise><c:out value="${boat.boatYear}" /></c:otherwise></c:choose></span>
                                </div>
                            </div>

                            <div class="fleet-card__actions">
                                <button type="button" class="btn-action js-edit-boat">Edit</button>
                                <c:choose>
                                    <c:when test="${boat.hasActiveReservation}">
                                        <%-- Courtesy, not enforcement: the servlet re-checks this
                                             inside the transaction regardless. --%>
                                        <button type="button" class="btn-action" disabled>Remove</button>
                                        <a class="fleet-card__reservation"
                                           href="${ctx}/reservations?reservationNumber=${fn:escapeXml(boat.activeConfirmationNumber)}">View Reservation <c:out value="${boat.activeConfirmationNumber}" /> <span aria-hidden="true">&rarr;</span></a>
                                        <span class="fleet-card__hint">This boat can't be removed from your account while it's part of an active reservation.</span>
                                    </c:when>
                                    <c:otherwise>
                                        <button type="button" class="btn-outline js-remove-boat">Remove</button>
                                    </c:otherwise>
                                </c:choose>
                            </div>

                        </article>
                    </c:forEach>
                </div>
            </c:when>

            <c:otherwise>
                <div class="detail-card fleet-empty">
                    <p class="fleet-empty__message">You haven't registered any boats yet.</p>
                    <button type="button" class="btn-primary" id="openAddBoatEmpty">Add a Boat</button>
                </div>
            </c:otherwise>

        </c:choose>

        <c:if test="${not empty fleet}">
            <div class="fleet-add-row">
                <button type="button" class="btn-primary" id="openAddBoat">Add a Boat</button>
            </div>
        </c:if>

    </div>

</c:otherwise>
</c:choose>

</main>

<%-- Everything from here to the footer is the signed-in page's popups. --%>
<c:if test="${not requestScope.signInRequired}">

<%--
  Server-set field messages, parked here rather than written straight into
  the boat card's error boxes - those live inside boatInfoCard.jsp and this
  page can't reach into an include. myFleet.js moves each one into
  #<field>Error when it reopens the modal. Hidden so nothing flashes up in a
  stack first, and escaped here rather than built into a script literal, so a
  message can never be markup. Same pattern as editUserInfo.jsp.

  On a validation failure MyFleetAddServlet / MyFleetEditServlet forward
  back here with "fieldErrors" (field name -> message), "formError",
  "openForm" ("add" or "edit") and "editBoatId". myFleet.js reads openForm on
  load and reopens the right modal with the typed values still in it.
--%>
<c:if test="${not empty fieldErrors}">
    <div id="serverFieldErrors" hidden>
        <c:forEach var="fieldError" items="${fieldErrors}">
            <span class="js-field-error"
                  data-field="${fn:escapeXml(fieldError.key)}"><c:out value="${fieldError.value}" /></span>
        </c:forEach>
    </div>
</c:if>

<%-- One modal for both Add and Edit, wrapping the shared boat card - the same
     arrangement the Reservation page's #boatPanel uses. Add opens it blank;
     Edit fills it from the clicked card's data-* attributes. --%>
<div class="modal" id="boatModal" role="dialog" aria-modal="true"
     aria-labelledby="boatModalTitle"
     data-country="${fn:escapeXml(sessionScope.customer.country)}"
     data-open-form="${fn:escapeXml(openForm)}"
     data-edit-boat-id="${fn:escapeXml(editBoatId)}"
     data-posted-fields="${fn:escapeXml(postedFields)}"
     data-form-error="${not empty openForm ? fn:escapeXml(formError) : ''}" hidden>

    <button type="button" class="modal__backdrop" data-modal-close aria-label="Close"></button>

    <div class="modal__box">

        <div class="modal__header">
            <h2 class="modal__title" id="boatModalTitle">Add a Boat</h2>
            <button type="button" class="modal__close" data-modal-close aria-label="Close">&times;</button>
        </div>

        <div class="form-banner form-banner--error" id="boatModalError" role="alert" hidden></div>

        <%-- Posts to /myFleet/add (MyFleetAddServlet); myFleet.js swaps the
             action to /myFleet/edit (MyFleetEditServlet) in edit mode.

             Add sends every field. Edit sends ONLY the changed ones plus
             boatId - a key's absence means "untouched", a key present and
             empty means "clear this column to NULL". boatLength and a HIN
             that is already set are never sent, because they render disabled;
             if one arrives anyway, reject it rather than ignoring it. --%>
        <form id="boatForm" action="${ctx}/myFleet/add" method="post" novalidate>
            <jsp:include page="/WEB-INF/includes/csrfField.jsp" />

            <%-- Disabled so it is not submitted on an Add; myFleet.js enables
                 it for an Edit. --%>
            <input type="hidden" name="boatId" id="boatId" value="" disabled>

            <div class="form-column">
                <%-- country drives the Registration Number format inside the
                     card, which reads param.country. It has to be passed
                     explicitly: on a validation-failure forward it is not in
                     the request, and the card would silently fall back to US. --%>
                <jsp:include page="/WEB-INF/includes/boatInfoCard.jsp">
                    <jsp:param name="country" value="${sessionScope.customer.country}" />
                </jsp:include>
            </div>

            <div class="modal__actions" id="boatFormActions">
                <button type="button" class="btn-outline" data-modal-close>Cancel</button>
                <button type="submit" class="btn-primary" id="saveBoat">Save Changes</button>
            </div>
            <p class="fleet-save-hint" id="saveBoatHint" hidden>Nothing changed yet.</p>

        </form>

        <%--
          The confirmation step from the contract's Editing a Boat section:
          the exact old -> new for every field about to be written, shown
          before anything is. Built by myFleet.js from the live form values,
          so it can never list a different set of changes than the ones that
          get submitted.
        --%>
        <div class="confirm-changes" id="confirmChanges" hidden>
            <h2 class="confirm-changes__title">Save these changes?</h2>
            <p class="fleet-confirm__lede" id="confirmChangesLede"></p>
            <dl class="change-summary__list" id="confirmChangesList"></dl>
            <div class="confirm-changes__actions">
                <button type="button" class="btn-outline" id="cancelSaveBoat">Keep Editing</button>
                <button type="button" class="btn-primary" id="confirmSaveBoat">Save Changes</button>
            </div>
        </div>

    </div>
</div>

<%-- Remove confirmation. Separate from the boat modal on purpose: it asks a
     different question, and must not be reachable by accident from the form. --%>
<div class="modal" id="removeModal" role="dialog" aria-modal="true"
     aria-labelledby="removeModalTitle" hidden>

    <button type="button" class="modal__backdrop" data-modal-close aria-label="Close"></button>

    <div class="modal__box modal__box--narrow">

        <div class="modal__header">
            <h2 class="modal__title" id="removeModalTitle">Remove this boat?</h2>
            <button type="button" class="modal__close" data-modal-close aria-label="Close">&times;</button>
        </div>

        <p class="modal__question" id="removeQuestion"></p>
        <p class="modal__note">
            The boat leaves your fleet and stops appearing when you book a
            slip. Any reservation it has already had is kept.
        </p>

        <%-- Posts boatId to /myFleet/remove. MyFleetRemoveServlet ENDS the
             BoatOwnership row rather than deleting the Boat - a boat that has
             ever been reserved can't be deleted without breaking reservation
             history - and re-checks for an Active reservation itself; the
             disabled button on a reserved card is courtesy, not enforcement. --%>
        <form id="removeForm" action="${ctx}/myFleet/remove" method="post">
            <jsp:include page="/WEB-INF/includes/csrfField.jsp" />
            <input type="hidden" name="boatId" id="removeBoatId" value="">
            <div class="modal__actions">
                <button type="button" class="btn-outline" data-modal-close data-modal-initial>Keep Boat</button>
                <button type="submit" class="btn-action btn-danger" id="confirmRemove">Yes, Remove It</button>
            </div>
        </form>

    </div>
</div>

</c:if>

<jsp:include page="/WEB-INF/includes/footer.jsp" />

<c:if test="${not requestScope.signInRequired}">
    <script src="${ctx}/js/boatFields.js?v=${applicationScope.assetVersion}"></script>
    <script src="${ctx}/js/editTracker.js?v=${applicationScope.assetVersion}" defer></script>
    <script src="${ctx}/js/myFleet.js?v=${applicationScope.assetVersion}" defer></script>
</c:if>

</body>
</html>
