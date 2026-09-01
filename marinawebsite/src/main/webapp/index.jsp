<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Moffat Bay Marina</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/variables.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/loginModal.css">
</head>
<body>

    <h1>Moffat Bay Marina</h1>
    <button type="button" onclick="MoffatBay.loginModal.open()">Log In</button>

    <jsp:include page="/includes/loginModal.jsp" />

</body>
</html>