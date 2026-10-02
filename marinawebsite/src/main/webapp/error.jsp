<%--
  Blue Team - Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
  Primary Author/Owner - Robert Breutzmann

    Generic error page, wired up in WEB-INF/web.xml as the target for
    every error status and for any uncaught exception (java.lang.Throwable),
    so a visitor never sees Tomcat's own grey page (which names the Tomcat
    version). Deliberately shows only a generic message - never the
    exception itself - so a DB outage or a bug doesn't leak a stack
    trace/class name to the visitor. Tomcat still logs the underlying
    exception to its own server log (catalina.out) before forwarding here,
    so nothing is lost for debugging - it just never reaches the response.

    The heading and message are picked from the status code, so a 400 or
    405 doesn't claim the page was lost. 403 is what CsrfFilter sends for a
    form with a missing or stale token, so its wording says to reload and
    try again; 429 is what PostRateLimitFilter sends when one visitor posts
    a form too often. Anything unrecognised (including a 404, or opening this page
    directly) gets the original "Lost At Sea" wording. Plain centered text
    in a parchment-style card - see css/error.css. Kept inline here rather
    than pulled into its own include since this is the only page that uses
    it.
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<c:set var="status" value="${requestScope['jakarta.servlet.error.status_code']}" />
<c:choose>
    <c:when test="${status == 400}">
        <c:set var="errorTitle" value="Ran Aground" />
        <c:set var="errorMessage" value="Something in that request didn't make sense to us. Head back and try again." />
    </c:when>
    <c:when test="${status == 403}">
        <c:set var="errorTitle" value="That Form Went Stale" />
        <c:set var="errorMessage" value="The form had been open too long, or it didn't come from our site, so nothing was sent. Go back, reload the page and try again." />
    </c:when>
    <c:when test="${status == 405}">
        <c:set var="errorTitle" value="Wrong Way Round" />
        <c:set var="errorMessage" value="That address only works from a button on the site, not by opening it directly." />
    </c:when>
    <c:when test="${status == 429}">
        <c:set var="errorTitle" value="Easy Does It" />
        <c:set var="errorMessage" value="That form has been sent a lot in the last minute, so we've paused it. Wait a minute, then go back and try again." />
    </c:when>
    <c:when test="${status == 500}">
        <c:set var="errorTitle" value="Rough Seas" />
        <c:set var="errorMessage" value="Something went wrong on our end. Please try again in a moment." />
    </c:when>
    <c:otherwise>
        <c:set var="errorTitle" value="Lost At Sea" />
        <c:set var="errorMessage" value="This page has gone adrift - it may not exist, may have moved, or something went wrong finding it." />
    </c:otherwise>
</c:choose>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>${errorTitle} - Moffat Bay Marina</title>

    <jsp:include page="/WEB-INF/includes/styles.jsp" /> <!-- Adds site.css, header.css, footer.css, loginModal.css -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/error.css?v=${applicationScope.assetVersion}">
</head>
<body>

<jsp:include page="/WEB-INF/includes/header.jsp" />

<main id="main" tabindex="-1">
    <div class="error-pirate">
        <div class="error-pirate-parchment">

            <h1>${errorTitle}</h1>

            <p class="error-pirate-message">${errorMessage}</p>

            <a class="btn-action" href="${pageContext.request.contextPath}/">
                Back to Home Port
            </a>

        </div>
    </div>
</main>

<jsp:include page="/WEB-INF/includes/footer.jsp" />

</body>
</html>
