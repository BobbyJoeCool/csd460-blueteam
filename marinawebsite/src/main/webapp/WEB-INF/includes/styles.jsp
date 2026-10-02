<%-- 
  Blue Team - Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
  Primary Author/Owner - Sara White

    Shared global stylesheets.
    Include this file in the <head> of each page using:

    <jsp:include page="/WEB-INF/includes/styles.jsp" />

    Page-specific stylesheets should still be linked separately
    after this include.

    Also carries the anti-forgery token as a <meta> tag, since this is
    the one include in every page's <head>. Scripts read it through
    MoffatBay.form.csrfToken() (formValidation.js); see CsrfFilter.
--%>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<meta name="csrf-token" content="${fn:escapeXml(sessionScope.csrfToken)}">

<%-- Site icon: the header's anchor (images/AnchorLogo.png) on a deep marine
     square. favicon.ico holds 16, 32 and 48 px; the two PNGs are for phone
     home screens. Kept in images/ so CsrfFilter treats them as static files. --%>
<link rel="icon" href="${pageContext.request.contextPath}/images/favicon.ico?v=${applicationScope.assetVersion}" sizes="16x16 32x32 48x48">
<link rel="icon" type="image/png" href="${pageContext.request.contextPath}/images/icon-192.png?v=${applicationScope.assetVersion}" sizes="192x192">
<link rel="apple-touch-icon" href="${pageContext.request.contextPath}/images/apple-touch-icon.png?v=${applicationScope.assetVersion}">

<link rel="stylesheet"
      href="${pageContext.request.contextPath}/css/site.css?v=${applicationScope.assetVersion}">

<link rel="stylesheet"
      href="${pageContext.request.contextPath}/css/header.css?v=${applicationScope.assetVersion}">

<link rel="stylesheet"
      href="${pageContext.request.contextPath}/css/footer.css?v=${applicationScope.assetVersion}">

<link rel="stylesheet"
      href="${pageContext.request.contextPath}/css/loginModal.css?v=${applicationScope.assetVersion}">

<link rel="stylesheet"
      href="${pageContext.request.contextPath}/css/statusPopup.css?v=${applicationScope.assetVersion}">

<link rel="stylesheet"
      href="${pageContext.request.contextPath}/css/passwordToggle.css?v=${applicationScope.assetVersion}">