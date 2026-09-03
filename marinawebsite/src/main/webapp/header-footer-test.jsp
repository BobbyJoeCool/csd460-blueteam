<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Test Page</title>

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/variables.css">

  <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/site.css">

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/loginModal.css">

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/header.css">

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/footer.css">
</head>

<body>

    <jsp:include page="/includes/header.jsp">
        <jsp:param name="activePage" value="home" />
    </jsp:include>

    <main>
        <h1>Test Page</h1>
        <p>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br>.<br></p>
    </main>

    <jsp:include page="/includes/footer.jsp" />

</body>
</html>