<%--
  src/main/webapp/myFleet.jsp

  Placeholder for the My Fleet page - adding, editing, trading and selling
  boats, all in one place, next module. Stands here now so the "My Fleet"
  button on Edit User Info has somewhere real to go, per the general rule
  in the page contracts: a page that doesn't have content yet still exists
  as a JSP using includes/comingSoon.jsp, so the link works instead of
  going nowhere.

  Author: Miguel Fernandez
  Blue Team - Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
  Primary Author/Owner - Miguel Fernandez
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Fleet - Moffat Bay Marina</title>

    <jsp:include page="/includes/styles.jsp" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/comingSoon.css">
</head>
<body>

<jsp:include page="/includes/header.jsp" />

<main>
    <jsp:include page="/includes/comingSoon.jsp">
        <jsp:param name="pageName" value="My Fleet" />
    </jsp:include>
</main>

<jsp:include page="/includes/footer.jsp" />

</body>
</html>
