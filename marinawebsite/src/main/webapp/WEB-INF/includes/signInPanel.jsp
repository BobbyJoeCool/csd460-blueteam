<%--
  Blue Team - Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
  Primary Author/Owner - Miguel Fernandez

  src/main/webapp/WEB-INF/includes/signInPanel.jsp

  The signed-out view of every customer-only page (Book a Slip, My
  Reservations, Reservation Summary, My Fleet, Your Account), so a visitor
  following a saved link, or whose session timed out, stays on the page
  they asked for and is told why it's empty. Issue #257: before this, those
  pages handled it four different ways, two of them a silent trip to the
  home page.

  The servlet sets this up with CustomerSession.showSignInPanel, which
  answers 401 and forwards to the page's view with signInRequired and
  signInRedirectTo set. The page then includes this in place of its
  content:

    <jsp:include page="/WEB-INF/includes/signInPanel.jsp">
        <jsp:param name="heading" value="Sign In to View Your Fleet" />
        <jsp:param name="message" value="Your boats are listed here after you sign in." />
    </jsp:include>

  Params:
    heading      - required. The panel's heading.
    message      - optional line under the heading.
    headingLevel - "1" on a page with no hero (Reservation Summary), so the
                   page still has an h1. Defaults to an h2 under the hero's.

  Reads requestScope.signInRedirectTo for the Sign In button. It has to be
  passed explicitly: the login modal otherwise works out where to return
  from the request URI, which after a forward is the JSP's own path.
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<section class="signin-panel" aria-labelledby="signInPanelHeading">
    <c:choose>
        <c:when test="${param.headingLevel == '1'}">
            <h1 id="signInPanelHeading"><c:out value="${param.heading}" /></h1>
        </c:when>
        <c:otherwise>
            <h2 id="signInPanelHeading"><c:out value="${param.heading}" /></h2>
        </c:otherwise>
    </c:choose>

    <c:if test="${not empty param.message}">
        <p><c:out value="${param.message}" /></p>
    </c:if>

    <button type="button" class="btn-primary"
            data-sign-in="${fn:escapeXml(requestScope.signInRedirectTo)}">Sign In</button>

    <p>
        No account yet?
        <a href="${pageContext.request.contextPath}/register">Create one</a>.
    </p>
</section>
