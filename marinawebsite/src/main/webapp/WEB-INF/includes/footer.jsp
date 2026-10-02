<%--
  Blue Team - Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
  Primary Author/Owner - Sara White

  Address, phone and office hours come from MarinaInfo (the "marina"
  application attribute) rather than being typed here.
--%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<footer class="site-footer">

    <div class="footer-columns">

        <section class="footer-address">
            <h2>Moffat Bay Marina</h2>

            <address>
                <c:out value="${marina.street}"/><br>
                <c:out value="${marina.cityStateZip}"/><br>
                <a href="${fn:escapeXml(marina.phoneLink)}"><c:out value="${marina.phone}"/></a>
            </address>
        </section>

        <section class="footer-office-hours">
            <h2>Office Hours</h2>

            <c:forEach var="row" items="${marina.officeHours}">
                <p><c:out value="${row.key}"/>: <c:out value="${row.value}"/></p>
            </c:forEach>

            <p class="self-service-note"><c:out value="${marina.slipHolderAccess}"/></p>
        </section>

        <section class="footer-quick-links">
            <h2>Quick Links</h2>

            <nav class="footer-nav" aria-label="Footer navigation">
                <a href="${pageContext.request.contextPath}/">
                    Home
                </a>

                <a href="${pageContext.request.contextPath}/about">
                    About Us
                </a>

                <a href="${pageContext.request.contextPath}/reservation">
                    Book a Slip
                </a>

                <a href="${pageContext.request.contextPath}/waitList">
                    Wait List
                </a>

                <a href="${pageContext.request.contextPath}/about#formHeading">
                    Contact
                </a>

                <a href="${pageContext.request.contextPath}/lodge.jsp">
                    Moffat Bay Lodge
                </a>
            </nav>
        </section>

    </div>

    <div class="footer-bottom">
        <p>
            &copy; 2026 Moffat Bay Marina. All rights reserved.
        </p>
    </div>

</footer>