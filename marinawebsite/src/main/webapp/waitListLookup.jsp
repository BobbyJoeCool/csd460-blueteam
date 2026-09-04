<%--
    Front End:   Robert Breutzmann
    Back End:    N/A
    Course:      CSD 460 - Capstone Project
    Module:      Module 9 / Week 7 - Web Development 5
    Page:        Wait List Lookup (waitListLookup.jsp)
    Contract:    DevNotes/Contracts/wait-list-lookup-contract.md

    Placeholder page - real content not built yet, see the contract above.
    Body is the shared "Coming Soon" include (includes/comingSoon.jsp).
    No activePage value in DevNotes/Contracts/Shared HeaderFooter.md's
    table yet, so no nav item highlights for this one.
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page isELIgnored="false" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>Wait List Lookup - Moffat Bay Marina</title>

    <jsp:include page="/includes/styles.jsp" /> <!-- Adds site.css, header.css, footer.css, loginModal.css -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/comingSoon.css">
</head>
<body>

<jsp:include page="/includes/header.jsp" />

<main>
    <jsp:include page="/includes/comingSoon.jsp">
        <jsp:param name="pageName" value="The Wait List Lookup page" />
    </jsp:include>
</main>

<jsp:include page="/includes/footer.jsp" />

</body>
</html>
