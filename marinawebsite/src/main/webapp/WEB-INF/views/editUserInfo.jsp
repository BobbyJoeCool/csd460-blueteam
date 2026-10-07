<%--
  src/main/webapp/WEB-INF/views/editUserInfo.jsp

  Edit User Info - the signed-in customer's own account page, per
  documentation/Page Contracts/Edit User Profile.md.

  Reached at /editProfile (EditProfileServlet), never as editUserInfo.jsp
  directly - the servlet's doGet is the page's front door, and a save
  redirects back through it with ?notice=profileUpdated for the toast. Same
  rule as every other servlet-backed page here.

  Reads:
    sessionScope.customer - the Customer bean LoginServlet put in session.
                            Pre-fills every field; no extra lookup needed.
    formError             - a banner message above the form.
    fieldErrors           - Map<String, String> field name -> message, read
                            into the error box beside each field by
                            editUserInfo.js. Note zipCode's box is #zipError,
                            not #zipCodeError, inherited from Registration.

  Author: Miguel Fernandez
  Blue Team - Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
  Primary Author/Owner - Miguel Fernandez (Front End) / Robert Breutzmann (Back End)
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<%--
  Signed out, EditProfileServlet forwards here with signInRequired set, and
  the page shows the shared sign-in panel instead of the form (issue #257).

  Defence in depth. Reached signed out any other way, hand it to the
  servlet rather than render a customer's name, address and email for
  nobody.
--%>
<c:if test="${empty sessionScope.customer and not requestScope.signInRequired}">
    <c:redirect url="/editProfile" />
</c:if>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Your Account - Moffat Bay Marina</title>

    <jsp:include page="/WEB-INF/includes/styles.jsp" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/passwordRules.css?v=${applicationScope.assetVersion}">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/editUserInfo.css?v=${applicationScope.assetVersion}">
</head>
<body>

<jsp:include page="/WEB-INF/includes/header.jsp">
    <jsp:param name="activePage" value="editprofile" />
</jsp:include>

<%-- The hero sits outside <main>, like every hero on the site (see
     .hero-band in site.css), so it spans the window. --%>
<section class="hero-band" id="accountHero" aria-labelledby="accountHeroTitle">
    <div class="hero-band__content">
        <h1 id="accountHeroTitle">Your Account</h1>
        <p class="hero-band__lede">
            Update your contact details and mailing address. We only save
            what you actually change.
        </p>
    </div>
    <p class="hero-band__credit">Image created with Google Gemini</p>
</section>

<main id="main" tabindex="-1" class="page-column">

<c:choose>
<c:when test="${requestScope.signInRequired}">

    <jsp:include page="/WEB-INF/includes/signInPanel.jsp">
        <jsp:param name="heading" value="Sign In to View Your Account" />
        <jsp:param name="message" value="Your contact details and mailing address are shown here after you sign in." />
    </jsp:include>

</c:when>
<c:otherwise>

    <c:if test="${not empty formError}">
        <div class="form-banner form-banner--error" id="formError" role="alert">
            <c:out value="${formError}" />
        </div>
    </c:if>

    <%--
      Server-set field messages, parked here rather than written straight
      into the card's error boxes - those boxes live inside
      personalInfoCard.jsp and this page can't reach into an include. JS
      moves each one into #<field>Error on load. Hidden so nothing flashes
      up in a stack before that runs, and escaped here rather than built
      into a script literal, so a message can never be markup.
    --%>
    <c:if test="${not empty fieldErrors}">
        <div id="serverFieldErrors" hidden>
            <c:forEach var="fieldError" items="${fieldErrors}">
                <span class="js-field-error"
                      data-field="${fn:escapeXml(fieldError.key)}"><c:out value="${fieldError.value}" /></span>
            </c:forEach>
        </div>
    </c:if>

    <form class="account-form"
          id="editProfileForm"
          action="${pageContext.request.contextPath}/editProfile"
          method="post"
          novalidate>
        <jsp:include page="/WEB-INF/includes/csrfField.jsp" />

        <%--
          The same card Registration uses, pre-filled from the session
          Customer. Ten default* params - there is no defaultEmail, the card
          has never carried the email field (it lives in Registration's own
          right column), so this page renders its own below.
        --%>
        <jsp:include page="/WEB-INF/includes/personalInfoCard.jsp">
            <jsp:param name="defaultFirstName" value="${sessionScope.customer.firstName}" />
            <jsp:param name="defaultLastName" value="${sessionScope.customer.lastName}" />
            <jsp:param name="defaultPhoneCountryCode" value="${sessionScope.customer.phoneCountryCode}" />
            <jsp:param name="defaultPhone" value="${sessionScope.customer.phone}" />
            <jsp:param name="defaultStreetAddress" value="${sessionScope.customer.streetAddress}" />
            <jsp:param name="defaultStreetAddress2" value="${sessionScope.customer.streetAddress2}" />
            <jsp:param name="defaultCity" value="${sessionScope.customer.city}" />
            <jsp:param name="defaultState" value="${sessionScope.customer.state}" />
            <jsp:param name="defaultZipCode" value="${sessionScope.customer.zipCode}" />
            <jsp:param name="defaultCountry" value="${sessionScope.customer.country}" />
        </jsp:include>

        <div class="form-column" id="accountColumn">

            <h2 class="column-heading">Sign-in &amp; Account</h2>

            <div class="form-group" id="emailGroup">
                <label for="email">Email <span class="required-mark">*</span></label>
                <input type="email" id="email" name="email" required
                       maxlength="100"
                       autocomplete="email"
                       value="${fn:escapeXml(not empty param.email ? param.email : sessionScope.customer.email)}">
                <p class="field-hint">This is also how you sign in.</p>
                <div class="field-error" id="emailError"></div>
            </div>

            <div class="form-group" id="memberSinceGroup">
                <label for="memberSince">Member since</label>
                <%--
                  Read-only: dateJoined isn't editable, but it's the one
                  account fact a customer might actually want to look up.

                  Not through <fmt:formatDate>: Customer carries dateJoined
                  as a LocalDate, and fmt:formatDate only accepts a
                  java.util.Date. dateJoinedDisplay formats it with the
                  site-wide date pattern (Utils.DISPLAY_DATE_PATTERN), so it
                  reads "Sep 15, 2026" like every other date on the site.
                --%>
                <input type="text" id="memberSince" disabled
                       value="${fn:escapeXml(sessionScope.customer.dateJoinedDisplay)}">
            </div>

            <div class="account-actions">
                <button type="button" class="btn-outline" id="openChangePassword">
                    Change password
                </button>
                <p class="field-hint">
                    <a href="#" id="openForgotPassword">Forgot your current password?</a>
                </p>
            </div>

            <div class="account-actions account-actions--fleet">
                <h3 class="account-subheading">Your boats</h3>
                <p class="field-hint">
                    Registering, editing and selling boats all live together on
                    My Fleet.
                </p>
                <a class="btn-outline account-fleet-link"
                   href="${pageContext.request.contextPath}/myFleet">My Fleet</a>
            </div>

            <%-- Issue #337. The download is a plain link (AccountDataServlet
                 answers with a file, so the page stays put). Delete opens
                 #deleteAccountModal below, outside this form. --%>
            <div class="account-actions account-actions--data">
                <h3 class="account-subheading">Your data</h3>
                <p class="field-hint">
                    Get a copy of everything we hold about you, or close your
                    account. Our <a href="${pageContext.request.contextPath}/privacy">Privacy Policy</a>
                    explains what's kept.
                </p>
                <a class="btn-outline account-fleet-link"
                   href="${pageContext.request.contextPath}/editProfile/data"
                   download>Download my data</a>
                <button type="button" class="btn-outline btn-danger" id="openDeleteAccount">
                    Delete my account
                </button>
            </div>

        </div>

        <div class="submit-row" id="accountSubmitRow">
            <%--
              Starts disabled and stays that way until something actually
              differs from what's on file. Registration gates its button on
              "is the form valid"; here the useful question is "is there
              anything to save at all" - the fields arrive already filled in
              and already valid, so an enabled button would invite a save
              that writes nothing.
            --%>
            <button type="submit" class="btn-primary" id="saveChanges" disabled>
                Save changes
            </button>
            <p class="submit-blocked-reason" id="saveHint">
                Nothing changed yet.
            </p>
        </div>

    </form>

</c:otherwise>
</c:choose>

</main>

<%-- Everything from here to the footer is the signed-in page's popups. --%>
<c:if test="${not requestScope.signInRequired}">

<%--
  The confirmation step from the contract's "Partial Update" section: the
  exact old -> new for every field about to be written, shown before
  anything is. A popup (the shared .modal, opened by modal.js), the same
  way every "are you sure" on the site is asked. Built by editUserInfo.js
  from the live form values, so it can never list a different set of
  changes than the ones that get submitted. After saving, the page shows
  only the "Profile updated" toast.
--%>
<div class="modal" id="confirmChangesModal" role="dialog" aria-modal="true"
     aria-labelledby="confirmChangesTitle" hidden>

    <button type="button" class="modal__backdrop" data-modal-close aria-label="Close"></button>

    <div class="modal__box modal__box--narrow">

        <div class="modal__header">
            <h2 class="modal__title" id="confirmChangesTitle">Save these changes?</h2>
            <button type="button" class="modal__close" data-modal-close aria-label="Close">&times;</button>
        </div>

        <p class="modal__note">Only these fields will be saved. Everything else stays as it is.</p>
        <dl class="change-summary__list" id="confirmChangesList"></dl>

        <div class="modal__actions">
            <button type="button" class="btn-outline" id="cancelSave" data-modal-close>Keep Editing</button>
            <button type="button" class="btn-primary" id="confirmSave">Save Changes</button>
        </div>

    </div>
</div>

<%--
  Delete my account (issue #337). Posts to /editProfile/delete
  (AccountDeleteServlet), which checks the password and that no lease is
  still running, then empties the account and signs the customer out.
  On a refusal it renders this page again with deleteError set, and the
  popup opens itself (data-open-on-load, read by editUserInfo.js) with the
  reason in the banner.

  Focus starts on the password box rather than on Cancel, unlike the
  site's other confirmations: typing the password is the confirmation,
  so Enter can't delete anything by accident.
--%>
<div class="modal" id="deleteAccountModal" role="dialog" aria-modal="true"
     aria-labelledby="deleteAccountTitle" hidden
     <c:if test="${not empty deleteError}">data-open-on-load</c:if>>

    <button type="button" class="modal__backdrop" data-modal-close aria-label="Close"></button>

    <div class="modal__box modal__box--narrow">

        <div class="modal__header">
            <h2 class="modal__title" id="deleteAccountTitle">Delete your account?</h2>
            <button type="button" class="modal__close" data-modal-close aria-label="Close">&times;</button>
        </div>

        <p class="form-banner form-banner--error login-modal__banner" id="deleteAccountError"
           role="alert" ${empty deleteError ? 'hidden' : ''}><c:out value="${deleteError}" /></p>

        <p class="modal__question">This can't be undone.</p>
        <ul class="modal__note delete-account-list">
            <li>Your name, email, phone number and address are removed.</li>
            <li>Your boats leave your fleet and you come off the wait list.</li>
            <li>Past reservations are kept for the marina's records, without your name.</li>
            <li>You can't do this while you have a current or upcoming reservation.</li>
        </ul>

        <form id="deleteAccountForm" action="${pageContext.request.contextPath}/editProfile/delete" method="post">
            <jsp:include page="/WEB-INF/includes/csrfField.jsp" />

            <div class="form-group">
                <label for="deletePassword">Enter your password to confirm</label>
                <input type="password" id="deletePassword" name="currentPassword"
                       autocomplete="current-password" required data-modal-initial>
            </div>

            <div class="modal__actions">
                <button type="button" class="btn-outline" data-modal-close>Keep My Account</button>
                <button type="submit" class="btn-action btn-danger">Yes, Delete My Account</button>
            </div>
        </form>

    </div>
</div>

</c:if>

<jsp:include page="/WEB-INF/includes/footer.jsp" />

<%-- Signed-in only, so it lives on this page rather than with the login
     modal. formValidation.js isn't loaded here - WEB-INF/includes/loginModal.jsp
     already pulls it in through the header, on every page. --%>
<c:if test="${not requestScope.signInRequired}">
<jsp:include page="/WEB-INF/includes/changePasswordModal.jsp" />

<script src="${pageContext.request.contextPath}/js/editTracker.js?v=${applicationScope.assetVersion}" defer></script>
<script src="${pageContext.request.contextPath}/js/editUserInfo.js?v=${applicationScope.assetVersion}" defer></script>
</c:if>

</body>
</html>
