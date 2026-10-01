<%-- 
  Blue Team - Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
  Primary Author/Owner - Sara White

    Shared global stylesheets.
    Include this file in the <head> of each page using:

    <jsp:include page="/includes/styles.jsp" />

    Page-specific stylesheets should still be linked separately
    after this include.

    Also carries the anti-forgery token as a <meta> tag, since this is
    the one include in every page's <head>. Scripts read it through
    MoffatBay.form.csrfToken() (formValidation.js); see CsrfFilter.
--%>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<meta name="csrf-token" content="${fn:escapeXml(sessionScope.csrfToken)}">

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