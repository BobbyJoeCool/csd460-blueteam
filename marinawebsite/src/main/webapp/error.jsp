<%--
    Generic error page, wired up in WEB-INF/web.xml as the target for a
    404 and for any uncaught exception (java.lang.Throwable). Deliberately
    shows only a generic message - never the exception itself - so a DB
    outage or a bug doesn't leak a stack trace/class name to the visitor.
    Tomcat still logs the underlying exception to its own server log
    (catalina.out) before forwarding here, so nothing is lost for
    debugging - it just never reaches the response.
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page isELIgnored="false" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<c:set var="isNotFound" value="${requestScope['jakarta.servlet.error.status_code'] == 404}" />
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>${isNotFound ? 'Page Not Found' : 'Something Went Wrong'} - Moffat Bay Marina</title>

    <jsp:include page="/includes/styles.jsp" /> <!-- Adds site.css, header.css, footer.css, loginModal.css -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/error.css">
</head>
<body>

<jsp:include page="/includes/header.jsp" />

<main class="error-main">
    <c:choose>
        <c:when test="${isNotFound}">
            <h1>Page Not Found</h1>
            <p>The page you're looking for doesn't exist, or may have moved.</p>
        </c:when>
        <c:otherwise>
            <h1>Something Went Wrong</h1>
            <p>An unexpected error occurred. Please try again in a moment.</p>
        </c:otherwise>
    </c:choose>
    <a class="btn-secondary" href="${pageContext.request.contextPath}/index.jsp">Back to Home</a>
</main>

<jsp:include page="/includes/footer.jsp" />

</body>
</html>
