<%--
  src/main/webapp/WEB-INF/views/accessibility.jsp

  Accessibility statement (issue #336). Reached at /accessibility
  (AccessibilityServlet). Linked from the footer.

  Author: Miguel Fernandez
  Blue Team - Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
  Primary Author/Owner - Miguel Fernandez
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Accessibility - Moffat Bay Marina</title>

    <jsp:include page="/WEB-INF/includes/styles.jsp" />
    <link rel="stylesheet" href="${ctx}/css/policy.css?v=${applicationScope.assetVersion}">
</head>
<body>

<jsp:include page="/WEB-INF/includes/header.jsp" />

<header class="hero-band" id="accessibilityHero">
    <div class="hero-band__content">
        <h1>Accessibility</h1>
        <p class="hero-band__lede">We want everyone to be able to book a slip, manage a boat and reach the office.</p>
    </div>
    <p class="hero-band__credit">Image created with Google Gemini</p>
</header>

<main class="page-column policy-page">

    <p class="policy-updated">Last updated October 2, 2026</p>

    <section aria-labelledby="targetHeading">
        <h2 id="targetHeading">Our goal</h2>
        <p>
            We aim for this website to meet the
            <a href="https://www.w3.org/TR/WCAG21/">Web Content Accessibility Guidelines (WCAG) 2.1</a>
            at level AA. That's the standard most organizations use, and it
            covers things like working without a mouse, working with a screen
            reader, and text that's easy enough to read.
        </p>
    </section>

    <section aria-labelledby="doneHeading">
        <h2 id="doneHeading">What we've done</h2>
        <ul>
            <li>Every page and popup can be used with the keyboard alone. Popups keep
                focus inside them while they're open, close with Escape, and put
                focus back where it was when they close.</li>
            <li>Every form field has a visible label, and mistakes are explained
                in words beside the field, not only shown in color.</li>
            <li>Confirmations like "Yes, Cancel It" start with focus on the safe
                choice, so pressing Enter by accident never does anything that
                can't be undone.</li>
            <li>Images that carry information have text descriptions. The marina
                map's description names every dock and which slips are which
                size.</li>
        </ul>
    </section>

    <section aria-labelledby="reportHeading">
        <h2 id="reportHeading">Tell us about a problem</h2>
        <p>
            If something on the site is hard or impossible for you to use,
            please let us know. Say which page you were on and what happened,
            and we'll reply within two business days. If you're trying to book
            a slip, the office can also take your booking over the phone.
        </p>
        <address class="policy-contact">
            Phone: <a href="${fn:escapeXml(marina.phoneLink)}"><c:out value="${marina.phone}"/></a><br>
            Email: <a href="mailto:${fn:escapeXml(marina.email)}"><c:out value="${marina.email}"/></a><br>
            Or use the <a href="${ctx}/about#formHeading">contact form on About Us</a>.
        </address>
    </section>

</main>

<jsp:include page="/WEB-INF/includes/footer.jsp" />

</body>
</html>
