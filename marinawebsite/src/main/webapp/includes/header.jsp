<%--
  Blue Team - Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
  Primary Author/Owner - Sara White

  src/main/webapp/includes/header.jsp

  Shared site header. Included by every page, which is what lets it show
  the signed-in state everywhere without each page checking the session
  for itself.

  Reads:
    param.activePage        - which nav link to highlight, passed by the
                              including page via <jsp:param>.
    sessionScope.loggedIn   - set by LoginServlet; swaps Log In for
                              Welcome + Log Out.
    sessionScope.displayName - "Elena M.", already formatted by the
                              Customer bean.
    marina.phone            - MarinaInfo's phone number, put on the header
                              as data-marina-phone so page scripts can
                              quote it without typing it themselves.
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<header class="site-header" data-marina-phone="${fn:escapeXml(marina.phone)}">
   <div class="header-brand">
    <a class="logo" href="${pageContext.request.contextPath}/">
        <img
            src="${pageContext.request.contextPath}/images/AnchorLogo.png"
            alt="">
        <span>Moffat Bay Marina</span>
    </a>
</div>

    <nav class="header-nav" aria-label="Main navigation">

        <%-- Hamburger toggle - only visible at mobile widths (see
             header.css). Toggles the .is-open class on .header-nav via
             js/header.js, which is what reveals #headerNavLinks (and the
             Log Out form, when signed in) as a dropdown. --%>
        <button type="button"
                class="nav-toggle"
                aria-label="Menu"
                aria-expanded="false"
                aria-controls="headerNavLinks"
                data-nav-toggle>
            <span class="nav-toggle__bar"></span>
            <span class="nav-toggle__bar"></span>
            <span class="nav-toggle__bar"></span>
        </button>

        <div class="header-nav__links" id="headerNavLinks">
            <a href="${pageContext.request.contextPath}/"
            class="${param.activePage == 'home' ? 'nav-active' : ''}">Home</a>
            <a href="${pageContext.request.contextPath}/about"
            class="${param.activePage == 'about' ? 'nav-active' : ''}">About Us</a>
          <div class="nav-dropdown" data-dropdown>

            <button type="button"
                    class="nav-dropdown__trigger
                    ${param.activePage == 'reservation'
                    or param.activePage == 'waitlist'
                    or param.activePage == 'lookup'
                    ? 'nav-active' : ''}"
                    aria-expanded="false"
                    aria-controls="planYourStayMenu"
                    data-dropdown-toggle>
                Plan Your Stay
                <span class="nav-dropdown__arrow" aria-hidden="true">▼</span>
            </button>

    <div class="nav-dropdown__menu"
         id="planYourStayMenu">

        <a href="${pageContext.request.contextPath}/reservation"
           class="${param.activePage == 'reservation' ? 'nav-active' : ''}">
            Book a Slip
        </a>

        <a href="${pageContext.request.contextPath}/waitList"
           class="${param.activePage == 'waitlist' ? 'nav-active' : ''}">
            View Wait List
        </a>

        <%-- Also in the Welcome menu below, on purpose: testers looked
             for their bookings in both places, so both lead there. --%>
        <c:if test="${not empty sessionScope.customerId}">
            <a href="${pageContext.request.contextPath}/reservations"
               class="${param.activePage == 'lookup' ? 'nav-active' : ''}">
                My Reservations
            </a>
        </c:if>

    </div>
</div>
        </div>

        <%-- Signed-in state. loggedIn and displayName are both set by
             LoginServlet (see the Login contract's "What the Session
             Remembers"); displayName already arrives formatted as
             "Elena M.", so nothing here has to build it.

             The header is on every page, so this is what makes the
             signed-in state visible site-wide rather than each page
             checking the session for itself. --%>
        <c:choose>
            <c:when test="${sessionScope.loggedIn}">

                <%-- The customer's own pages: My Reservations, My Fleet and
                     Your Account. Same dropdown component as Plan Your
                     Stay; the --account modifier anchors the menu to the
                     right edge and keeps it a popup on mobile, where it
                     sits in the compact row. My Reservations is in Plan
                     Your Stay as well, so on that page both triggers show
                     as active. --%>
                <div class="nav-dropdown nav-dropdown--account" data-dropdown>

                    <button type="button"
                            class="nav-dropdown__trigger
                            ${param.activePage == 'editprofile'
                            or param.activePage == 'myfleet'
                            or param.activePage == 'lookup'
                            ? 'nav-active' : ''}"
                            aria-expanded="false"
                            aria-controls="accountMenu"
                            data-dropdown-toggle>
                        Welcome, <c:out value="${sessionScope.displayName}"/>
                        <span class="nav-dropdown__arrow" aria-hidden="true">▼</span>
                    </button>

                    <div class="nav-dropdown__menu" id="accountMenu">

                        <a href="${pageContext.request.contextPath}/reservations"
                           class="${param.activePage == 'lookup' ? 'nav-active' : ''}">
                            My Reservations
                        </a>

                        <a href="${pageContext.request.contextPath}/myFleet"
                           class="${param.activePage == 'myfleet' ? 'nav-active' : ''}">
                            My Fleet
                        </a>

                        <a href="${pageContext.request.contextPath}/editProfile"
                           class="${param.activePage == 'editprofile' ? 'nav-active' : ''}">
                            Your Account
                        </a>

                    </div>
                </div>

                <%-- POST, not a link: logging out changes state, so it
                     shouldn't sit on something a browser could follow on
                     its own. --%>
                <form class="nav-logout-form"
                      action="${pageContext.request.contextPath}/logout"
                      method="post">
                    <jsp:include page="/includes/csrfField.jsp" />
                    <button type="submit" class="nav-cta">Log Out</button>
                </form>

            </c:when>
            <c:otherwise>

                <button type="button"
                    class="nav-cta"
                    onclick="MoffatBay.loginModal.open()">Log In
                </button>

            </c:otherwise>
        </c:choose>
    </nav>
</header>

<script src="${pageContext.request.contextPath}/js/header.js" defer></script>

<!-- Open/close for the shared .modal component (My Fleet, My Reservations).
     Deferred like the pages' own scripts, and earlier in the page, so it
     is ready before any of them runs. -->
<script src="${pageContext.request.contextPath}/js/modal.js" defer></script>

<!-- Show/hide eye on every password field on the page, the modals below
     included. Deferred, so it runs after the whole page has been parsed. -->
<script src="${pageContext.request.contextPath}/js/passwordToggle.js" defer></script>

	<!-- Reusable login modal (pulls in its own scripts) -->
	<jsp:include page="/includes/loginModal.jsp" />

	<!-- Shared status popup - the "that worked" message. Renders empty on
	     every page; any page can fill it with
	     MoffatBay.statusPopup.show("..."). Pulls in its own script. -->
	<jsp:include page="/includes/statusPopup.jsp" />
