<%--
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
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<header class="site-header">
   <div class="header-brand">
    <a class="logo" href="${pageContext.request.contextPath}/">
        <img
            src="${pageContext.request.contextPath}/images/AnchorLogo.png"
            alt="">
        <span>Moffat Bay Marina</span>
    </a>
</div>

    <nav class="header-nav" aria-label="Main navigation">
        <a href="${pageContext.request.contextPath}/index.jsp"
        class="${param.activePage == 'home' ? 'nav-active' : ''}">Home</a>
        <a href="${pageContext.request.contextPath}/aboutUs.jsp"
        class="${param.activePage == 'about' ? 'nav-active' : ''}">About Us</a>
        <a href="${pageContext.request.contextPath}/reservation"
        class="${param.activePage == 'reservation' ? 'nav-active' : ''}">Reservations</a>
        <a href="${pageContext.request.contextPath}/contact.jsp"
        class="${param.activePage == 'contact' ? 'nav-active' : ''}">Contact</a>

        <%-- Signed-in state. loggedIn and displayName are both set by
             LoginServlet (see the Login contract's "What the Session
             Remembers"); displayName already arrives formatted as
             "Elena M.", so nothing here has to build it.

             The header is on every page, so this is what makes the
             signed-in state visible site-wide rather than each page
             checking the session for itself. --%>
        <c:choose>
            <c:when test="${sessionScope.loggedIn}">

                <span class="nav-welcome">
                    Welcome, <c:out value="${sessionScope.displayName}"/>
                </span>

                <%-- POST, not a link: logging out changes state, so it
                     shouldn't sit on something a browser could follow on
                     its own. --%>
                <form class="nav-logout-form"
                      action="${pageContext.request.contextPath}/logout"
                      method="post">
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

	<!-- Reusable login modal (pulls in its own scripts) -->
	<jsp:include page="/includes/loginModal.jsp" />

	<!-- Shared status popup - the "that worked" message. Renders empty on
	     every page; any page can fill it with
	     MoffatBay.statusPopup.show("..."). Pulls in its own script. -->
	<jsp:include page="/includes/statusPopup.jsp" />
