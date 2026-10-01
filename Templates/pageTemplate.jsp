<%--
    TEMPLATE - copy this file to create a new top-level page, then rename
    the copy and fill in the header block below. Not a real page itself;
    delete anything in this comment once copied.

    Front End:   (name)
    Back End:    (name, or "N/A" if this page has none yet)
    Course:      CSD 460 - Capstone Project
    Module:      (module / week)
    Page:        (Page Name) (yourFileName.jsp)

    Every page shares this same shell:
      1. /WEB-INF/includes/styles.jsp   - site.css, header.css, footer.css, loginModal.css
      2. this page's own stylesheet (linked AFTER styles.jsp, so it can override)
      3. /WEB-INF/includes/header.jsp   - nav + brand; also pulls in the login modal,
                                   and with it formValidation.js + loginModal.js -
                                   don't load either of those two scripts again
                                   on this page
      4. page content in <main>
      5. /WEB-INF/includes/footer.jsp
      6. this page's own scripts (if any), loaded last, after formValidation.js
         has already arrived via the header

    activePage below controls the nav's current-page highlight in
    header.jsp - set it to one of: home, about, reservation, waitlist,
    lookup, myfleet, editprofile. Leave it off (or unmatched) if this page
    isn't one of those.

    Telling the customer what happened - pick by what the message is about:
      - Toast (the shared status popup, MoffatBay.statusPopup.show() or
        ?notice=...): success only, usually right after a redirect -
        "Boat saved", "Reservation cancelled". It goes away by itself, so
        never use it for an error.
      - Banner (<div class="form-banner" role="alert">): an error about the
        whole form or page - the save failed, the session ran out, the
        server refused. Sits above the form and stays until the next try.
        Inside a popup, the banner goes at the top of the popup.
      - Field message (<div class="field-error">): an error about one field
        - "Enter a valid email". Directly under that field, and the field
        gets .field-invalid.

    Layout and buttons (site.css has the details):
      - A photo hero goes OUTSIDE <main>, as <header class="hero-band">.
      - <main class="page-column"> for a form or reading page, or
        "page-column page-column--wide" for a multi-column one.
      - One .btn-primary per view (the page, or an open popup); .btn-action
        and .btn-outline for everything else. No page-specific button
        classes.
      - Popups use the shared .modal markup and js/modal.js.
      - Every stylesheet and script link ends in
        ?v=${applicationScope.assetVersion}, so browsers fetch the new file
        after a deploy instead of reusing an old copy.
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

    <jsp:include page="/WEB-INF/includes/styles.jsp" /> <!-- Adds site.css, header.css, footer.css, loginModal.css -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/PAGE_NAME.css?v=${applicationScope.assetVersion}">
</head>
<body>

<jsp:include page="/WEB-INF/includes/header.jsp">
    <jsp:param name="activePage" value="PAGE_NAME" />
</jsp:include>

<%-- Optional photo hero - delete if this page has none.
<header class="hero-band" id="PAGE_NAMEHero">
    <div class="hero-band__content">
        <h1>Page Title</h1>
        <p class="hero-band__lede">One line about the page.</p>
    </div>
    <p class="hero-band__credit">Image created with Google Gemini</p>
</header>
--%>

<main class="page-column">

    <!-- Page content goes here -->

</main>

<jsp:include page="/WEB-INF/includes/footer.jsp" />

<%-- Page-specific scripts, if any - formValidation.js is already loaded
     by the header include above, don't add it again here.
<script src="${pageContext.request.contextPath}/js/PAGE_NAME.js?v=${applicationScope.assetVersion}"></script>
--%>

</body>
</html>
