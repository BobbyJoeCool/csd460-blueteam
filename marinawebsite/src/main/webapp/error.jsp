<%--
    Generic error page, wired up in WEB-INF/web.xml as the target for a
    404 and for any uncaught exception (java.lang.Throwable). Deliberately
    shows only a generic message - never the exception itself - so a DB
    outage or a bug doesn't leak a stack trace/class name to the visitor.
    Tomcat still logs the underlying exception to its own server log
    (catalina.out) before forwarding here, so nothing is lost for
    debugging - it just never reaches the response.

    One error page, one message, regardless of what actually went wrong
    (404, uncaught exception, whatever else lands here) - deliberately not
    branching on status code. Plain centered text in a parchment-style
    card - see css/error.css. Kept inline here rather than pulled into
    its own include since this is the only page that uses it.
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>Lost At Sea - Moffat Bay Marina</title>

    <jsp:include page="/includes/styles.jsp" /> <!-- Adds site.css, header.css, footer.css, loginModal.css -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/error.css">
</head>
<body>

<jsp:include page="/includes/header.jsp" />

<main>
    <div class="error-pirate">
        <div class="error-pirate-parchment">

            <h1>Lost At Sea</h1>

            <p class="error-pirate-message">
                This page has gone adrift - it may not exist, may have moved, or
                something went wrong finding it.
            </p>

            <a class="error-pirate-home-link" href="${pageContext.request.contextPath}/index.jsp">
                Back to Home Port
            </a>

        </div>
    </div>
</main>

<jsp:include page="/includes/footer.jsp" />

</body>
</html>
