<%--
  src/main/webapp/lodge.jsp

  Placeholder for the Moffat Bay Lodge page. Stands here now so the Lodge
  card on the landing page has somewhere real to go, per the general rule
  in the page contracts: a page that doesn't have content yet still exists
  as a JSP using includes/comingSoon.jsp, so the link works instead of
  going nowhere.

  Author: Robert Breutzmann
  Blue Team - Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
  Primary Author/Owner - Robert Breutzmann
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Moffat Bay Lodge - Moffat Bay Marina</title>

    <jsp:include page="/includes/styles.jsp" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/comingSoon.css">
</head>
<body>

<jsp:include page="/includes/header.jsp" />

<main>
    <jsp:include page="/includes/comingSoon.jsp">
        <jsp:param name="pageName" value="Moffat Bay Lodge" />
    </jsp:include>
</main>

<jsp:include page="/includes/footer.jsp" />

</body>
</html>
