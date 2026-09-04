<%--
  "Coming Soon" placeholder body - the <main> content for every planned
  page that doesn't have real content yet (see the Registration contract's
  sibling docs in DevNotes/Contracts/ for what each one will eventually
  be). Pirate/under-construction motif per team decision, built with
  original inline SVGs (no external assets/licensing to track) recolored
  to the site's existing palette from site.css - see css/comingSoon.css.

  Usage - pass the page's display name so the message can reference it:

    <main>
        <jsp:include page="/includes/comingSoon.jsp">
            <jsp:param name="pageName" value="About Us" />
        </jsp:include>
    </main>

  "pageName" is optional; falls back to a generic "This page" wording if
  left off.
--%>
<%@ page isELIgnored="false" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>

<c:set var="pageNameValue" value="${empty param.pageName ? 'This page' : param.pageName}" />

<div class="coming-soon">

    <div class="coming-soon-caution" aria-hidden="true">
        <span>UNDER CONSTRUCTION</span>
        <span>UNDER CONSTRUCTION</span>
        <span>UNDER CONSTRUCTION</span>
        <span>UNDER CONSTRUCTION</span>
    </div>

    <div class="coming-soon-parchment">

        <%--
          width/height on the <svg> and fill="none" on the ring are set
          inline (not just via comingSoon.css) as a fallback: a shape
          with no fill defaults to solid black, and an <svg> with only a
          viewBox can render much larger than intended if its stylesheet
          doesn't apply in time - together that's a giant black circle
          instead of a skull outline. Belt-and-braces so a slow/failed
          CSS load can't produce that.
        --%>
        <svg class="coming-soon-emblem" width="84" height="84" viewBox="0 0 100 100" role="img" aria-label="Skull and crossbones">
            <circle cx="50" cy="50" r="48" class="emblem-ring" fill="none" />
            <g class="emblem-mark">
                <ellipse cx="50" cy="42" rx="20" ry="18" />
                <circle cx="41" cy="40" r="5" class="emblem-eye" />
                <circle cx="59" cy="40" r="5" class="emblem-eye" />
                <path d="M45 52 L50 60 L55 52 Z" />
                <path d="M38 56 q12 8 24 0" class="emblem-jaw" fill="none" />
                <line x1="18" y1="78" x2="82" y2="60" class="emblem-bone" />
                <line x1="18" y1="60" x2="82" y2="78" class="emblem-bone" />
            </g>
        </svg>

        <h1>Ye Be Early, Matey!</h1>

        <svg class="coming-soon-divider" width="160" height="14" viewBox="0 0 200 16" aria-hidden="true">
            <path d="M0 8 Q 25 0, 50 8 T 100 8 T 150 8 T 200 8" fill="none" />
        </svg>

        <p class="coming-soon-message">
            <c:out value="${pageNameValue}" /> be still under construction -
            our crew is hard at work charting this page.
        </p>

        <p class="coming-soon-submessage">
            Weigh anchor back at the homeport while we finish the map.
        </p>

        <a class="coming-soon-home-link" href="${pageContext.request.contextPath}/index.jsp">
            Back to Home Port
        </a>

        <p class="coming-soon-credit">Graphics for this page were designed by Claude Code.</p>

    </div>

    <%-- Same width/height + fill="none" fallback as the emblem above. --%>
    <svg class="coming-soon-wheel" width="140" height="140" viewBox="0 0 100 100" aria-hidden="true">
        <circle cx="50" cy="50" r="8" fill="none" />
        <circle cx="50" cy="50" r="42" fill="none" />
        <circle cx="50" cy="50" r="48" fill="none" />
        <g class="wheel-spokes">
            <line x1="50" y1="2" x2="50" y2="98" />
            <line x1="2" y1="50" x2="98" y2="50" />
            <line x1="15" y1="15" x2="85" y2="85" />
            <line x1="85" y1="15" x2="15" y2="85" />
        </g>
        <circle class="wheel-peg" cx="50" cy="4" r="4" />
        <circle class="wheel-peg" cx="50" cy="96" r="4" />
        <circle class="wheel-peg" cx="4" cy="50" r="4" />
        <circle class="wheel-peg" cx="96" cy="50" r="4" />
    </svg>

</div>
