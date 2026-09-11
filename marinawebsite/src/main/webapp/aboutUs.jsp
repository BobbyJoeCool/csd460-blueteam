<%--
    Front End:   Miguel Fernandez
    Back End:    Sara White
    Course:      CSD 460 - Capstone Project
    Module:      Module 7 / Week 5 - Web Development 3
    Page:        About Us (aboutUs.jsp)
    Contract:    documentation/Page Contracts/About Us.md

    Contact Us was cut as a standalone page on Sep 7 (professor-directed
    change) and its contact information and form moved here, so this page
    is both the marina's story and the way to get hold of it.

    Every fact on this page - address, phone, hours, dock and slip counts -
    comes from documentation/definitions_decisions.md, which is the single
    source of truth for them. If a number here disagrees with that file,
    that file is right.

    The form's fields map one-to-one onto the Contact table's columns, so
    the field names are the column names. See the contract's Front End
    Variables table.
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page isELIgnored="false" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>About Us - Moffat Bay Marina</title>

    <jsp:include page="/includes/styles.jsp" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/aboutUs.css">
</head>
<body>

<jsp:include page="/includes/header.jsp">
    <jsp:param name="activePage" value="about" />
</jsp:include>

<main>

    <%-- ================================================================
         Intro band. Same treatment as the Registration page's, so the
         two secondary pages open the same way.
         ================================================================ --%>
    <section class="intro-band">
        <h1>About Moffat Bay Marina</h1>
        <p>Your Harbor Between Horizons</p>
    </section>

    <div class="about-page">

        <%-- ============================================================
             The marina's story
             ============================================================ --%>
        <section class="about-story" aria-labelledby="storyHeading">
            <div class="about-story__text">
                <h2 id="storyHeading">A working harbor in the San Juans</h2>

                <p>
                    Moffat Bay Marina sits on the sheltered eastern shore of
                    Joviedsa Island, in the heart of Washington's San Juan
                    Islands. The bay curves in far enough to take the weather
                    off the strait, which is why boats have tied up here long
                    before there was a dock to tie up to.
                </p>

                <p>
                    We are a small marina and we like it that way. Seventy-two
                    slips across three docks means the office knows the boats
                    by name, and it means a slip is somewhere you keep a boat
                    rather than a space in a car park. The fuel dock, the ship
                    store, the office and the restaurant are all a short walk
                    from wherever you are tied up.
                </p>

                <p>
                    Whether you are here for a season or passing through on
                    your way north, you get the same harbor: quiet water, a
                    short walk to everything, and open horizon in both
                    directions.
                </p>
            </div>

            <figure class="about-story__figure">
                <img src="${pageContext.request.contextPath}/images/Slip_Closeup.png"
                     alt="A boat tied up at a Moffat Bay Marina slip at sunset,
                          with a shore power pedestal on the dock beside it.">
                <figcaption>Every slip has shore power and fresh water.</figcaption>
            </figure>
        </section>

        <%-- ============================================================
             The marina by the numbers. Straight from
             definitions_decisions.md.
             ============================================================ --%>
        <section class="about-facts" aria-labelledby="factsHeading">
            <h2 id="factsHeading">The marina at a glance</h2>

            <div class="about-facts__grid">
                <div class="about-fact">
                    <span class="about-fact__figure">3</span>
                    <h3>Docks</h3>
                    <p>
                        Docks A, B and C. A is closest to the Ship Store, C is
                        closest to the Office, Restaurant and Fuel Dock, and B
                        sits between them.
                    </p>
                </div>

                <div class="about-fact">
                    <span class="about-fact__figure">72</span>
                    <h3>Slips</h3>
                    <p>
                        Twenty-four on every dock, in three sizes, so a slip is
                        matched to the boat rather than the other way round.
                    </p>
                </div>

                <div class="about-fact">
                    <span class="about-fact__figure">3</span>
                    <h3>Slip sizes</h3>
                    <p>
                        26 ft, 40 ft and 50 ft. Thirty 26 ft slips, twenty-four
                        40 ft, and eighteen 50 ft across the marina.
                    </p>
                </div>
            </div>
        </section>

        <%-- ============================================================
             Hours and contact details. Carried over from the Contact Us
             page when it was cut.
             ============================================================ --%>
        <section class="about-contact" aria-labelledby="contactHeading">
            <h2 id="contactHeading">Find us and reach us</h2>

            <div class="about-contact__grid">

                <div class="about-contact__card">
                    <h3>Where we are</h3>
                    <address>
                        Moffat Bay Marina<br>
                        1400 Harbor Loop Road<br>
                        Joviedsa Island, WA 98250
                    </address>
                </div>

                <div class="about-contact__card">
                    <h3>How to reach us</h3>
                    <p class="about-contact__line">
                        <span class="about-contact__label">Phone</span>
                        <a href="tel:+13605550142">(360) 555-0142</a>
                    </p>
                    <p class="about-contact__line">
                        <span class="about-contact__label">Email</span>
                        <a href="mailto:office@moffatbaymarina.com">office@moffatbaymarina.com</a>
                    </p>
                    <p class="about-contact__line">
                        <span class="about-contact__label">VHF</span>
                        Channel 16
                    </p>
                </div>

                <div class="about-contact__card">
                    <h3>Office hours</h3>
                    <table class="about-hours">
                        <tbody>
                            <tr><th scope="row">Mon - Fri</th><td>6:00 am - 7:00 pm</td></tr>
                            <tr><th scope="row">Saturday</th><td>6:00 am - 7:00 pm</td></tr>
                            <tr><th scope="row">Sunday</th><td>7:00 am - 5:00 pm</td></tr>
                            <tr><th scope="row">Fuel dock</th><td>7:00 am - dusk, daily</td></tr>
                        </tbody>
                    </table>
                    <p class="about-hours__note">
                        The marina itself is self-service and open 24 hours to
                        slip holders.
                    </p>
                </div>

            </div>
        </section>

        <%-- ============================================================
             The marina map. Same image the Reservation page uses, here
             for anyone wanting to see the layout before they book.
             ============================================================ --%>
        <section class="about-map" aria-labelledby="mapHeading">
            <h2 id="mapHeading">The docks</h2>

            <figure>
                <img src="${pageContext.request.contextPath}/images/marina_a.png"
                     alt="Map of Moffat Bay Marina showing three linear docks
                          labelled A, B and C, each with twenty-four numbered
                          slips. On every dock, slips 8 to 12 and 20 to 24 are
                          26 ft, slips 4 to 7 and 16 to 19 are 40 ft, and the
                          rest are 50 ft. The Ship Store sits nearest Dock A,
                          the Office and Restaurant between B and C, and the
                          Fuel Dock beyond Dock C.">
                <figcaption>
                    On every dock: slips 8-12 and 20-24 are 26 ft, slips 4-7
                    and 16-19 are 40 ft, and the remainder are 50 ft.
                </figcaption>
            </figure>
        </section>

        <%-- ============================================================
             Contact form. Field names are the Contact table's column
             names, so the back end maps them one to one.

             Pre-filled for a signed-in customer from the Customer bean
             already in session - no back-end work needed for that, the
             session attribute is set at login. Someone signed out gets
             empty fields.
             ============================================================ --%>
        <section class="about-form-section" aria-labelledby="formHeading">
            <h2 id="formHeading">Send us a message</h2>

            <p class="about-form-section__lead">
                Questions about a reservation, the wait list, billing or
                anything else - fill this in and the office will get back to
                you. If it's urgent, call us on
                <a href="tel:+13605550142">(360) 555-0142</a>.
            </p>

            <%-- Set by the back end after a successful submission. --%>
            <c:if test="${not empty contactSuccess}">
                <p class="form-banner form-banner--success" role="status">
                    <c:out value="${contactSuccess}"/>
                </p>
            </c:if>

            <%-- Set by the back end when the submission is rejected. --%>
            <c:if test="${not empty contactError}">
                <p class="form-banner" role="alert">
                    <c:out value="${contactError}"/>
                </p>
            </c:if>

            <form class="contact-form"
                  id="contactForm"
                  action="${pageContext.request.contextPath}/contact"
                  method="post"
                  novalidate>

                <div class="contact-form__row">
                    <div class="form-group">
                        <label for="firstName">
                            First Name <span class="required-mark">*</span>
                        </label>
                        <input type="text"
                               id="firstName"
                               name="firstName"
                               maxlength="50"
                               autocomplete="given-name"
                               value="${fn:escapeXml(not empty param.firstName
                                        ? param.firstName
                                        : sessionScope.customer.firstName)}"
                               required>
                        <p class="field-error" id="firstNameError"></p>
                    </div>

                    <div class="form-group">
                        <label for="lastName">
                            Last Name <span class="required-mark">*</span>
                        </label>
                        <input type="text"
                               id="lastName"
                               name="lastName"
                               maxlength="50"
                               autocomplete="family-name"
                               value="${fn:escapeXml(not empty param.lastName
                                        ? param.lastName
                                        : sessionScope.customer.lastName)}"
                               required>
                        <p class="field-error" id="lastNameError"></p>
                    </div>
                </div>

                <div class="form-group">
                    <label for="email">
                        Email <span class="required-mark">*</span>
                    </label>
                    <input type="email"
                           id="email"
                           name="email"
                           maxlength="255"
                           autocomplete="email"
                           value="${fn:escapeXml(not empty param.email
                                    ? param.email
                                    : sessionScope.customer.email)}"
                           required>
                    <p class="field-error" id="emailError"></p>
                </div>

                <div class="contact-form__row">
                    <div class="form-group">
                        <label for="boatName">
                            Boat Name <span class="field-hint">(optional)</span>
                        </label>
                        <input type="text"
                               id="boatName"
                               name="boatName"
                               maxlength="100"
                               value="${fn:escapeXml(param.boatName)}">
                        <p class="field-error" id="boatNameError"></p>
                    </div>

                    <div class="form-group">
                        <label for="boatLength">
                            Boat Length (ft) <span class="field-hint">(optional)</span>
                        </label>
                        <input type="number"
                               id="boatLength"
                               name="boatLength"
                               min="0"
                               max="9999.99"
                               step="0.1"
                               value="${fn:escapeXml(param.boatLength)}">
                        <p class="field-error" id="boatLengthError"></p>
                    </div>
                </div>

                <div class="form-group">
                    <label for="reasonForContact">
                        Reason for Contact <span class="required-mark">*</span>
                    </label>
                    <%-- The six values are the Contact.reasonForContact ENUM,
                         listed in definitions_decisions.md. A <select> rather
                         than free text so nothing outside the list can arrive. --%>
                    <select id="reasonForContact" name="reasonForContact" required>
                        <option value="">Choose one...</option>
                        <c:forEach var="reason"
                                   items="${['Reservation Question',
                                             'Waitlist Question',
                                             'Billing',
                                             'Maintenance Issue',
                                             'General Inquiry',
                                             'Other']}">
                            <option value="${fn:escapeXml(reason)}"
                                    ${param.reasonForContact eq reason ? 'selected' : ''}>
                                ${fn:escapeXml(reason)}
                            </option>
                        </c:forEach>
                    </select>
                    <p class="field-error" id="reasonForContactError"></p>
                </div>

                <div class="form-group">
                    <label for="message">
                        Message <span class="required-mark">*</span>
                    </label>
                    <textarea id="message"
                              name="message"
                              rows="7"
                              maxlength="2000"
                              required>${fn:escapeXml(param.message)}</textarea>
                    <p class="contact-form__counter">
                        <span id="messageCount">0</span> / 2000
                    </p>
                    <p class="field-error" id="messageError"></p>
                </div>

                <div class="contact-form__actions">
                    <button type="submit" class="btn-primary">Send Message</button>
                </div>
            </form>
        </section>

    </div>
</main>

<jsp:include page="/includes/footer.jsp" />

<script src="${pageContext.request.contextPath}/js/aboutUs.js" defer></script>

</body>
</html>
