<%--
    TEMPLATE - copy this file to create a new top-level page, then rename
    the copy and fill in the header block below. Not a real page itself;
    delete anything in this comment once copied.

    Front End:   (name)
    Back End:    (name, or "N/A" if this page has none yet)
    Course:      CSD 460 - Capstone Project
    Module:      (module / week)
    Page:        (Page Name) (yourFileName.jsp)
    Contract:    DevNotes/Contracts/your-page-contract.md

    Every page shares this same shell:
      1. /includes/styles.jsp   - site.css, header.css, footer.css, loginModal.css
      2. this page's own stylesheet (linked AFTER styles.jsp, so it can override)
      3. /includes/header.jsp   - nav + brand; also pulls in the login modal,
                                   and with it formValidation.js + loginModal.js -
                                   don't load either of those two scripts again
                                   on this page
      4. page content in <main>
      5. /includes/footer.jsp
      6. this page's own scripts (if any), loaded last, after formValidation.js
         has already arrived via the header

    activePage below controls the nav's current-page highlight in
    header.jsp - set it to one of: home, about, reservation, contact,
    register. Leave it off (or unmatched) if this page isn't one of those.
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page isELIgnored="false" %>
<%-- Uncomment whichever of these this page actually needs:
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>
--%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>Page Title - Moffat Bay Marina</title>

    <jsp:include page="/includes/styles.jsp" /> <!-- Adds site.css, header.css, footer.css, loginModal.css -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/PAGE_NAME.css">
</head>
<body>

<jsp:include page="/includes/header.jsp">
    <jsp:param name="activePage" value="PAGE_NAME" />
</jsp:include>

<main>

    <!-- Page content goes here -->

</main>

<jsp:include page="/includes/footer.jsp" />

<%-- Page-specific scripts, if any - formValidation.js is already loaded
     by the header include above, don't add it again here.
<script src="${pageContext.request.contextPath}/js/PAGE_NAME.js"></script>
--%>

</body>
</html>
