<%--
  src/main/webapp/editUserInfo.jsp

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
  Defence in depth. EditProfileServlet already bounces a logged-out request,
  but this page is reachable by its own path too, and it renders a customer's
  name, address and email - it should never render for nobody.
--%>
<c:if test="${empty sessionScope.customer}">
    <c:redirect url="/" />
</c:if>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Your Account - Moffat Bay Marina</title>

    <jsp:include page="/includes/styles.jsp" />
    <%-- registration.css owns .form-column, .column-heading and the
         split rows that personalInfoCard.jsp's markup depends on, so any
         page including that card has to load it too - reservation.css
         already does the same for the boat card. --%>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/registration.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/passwordRules.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/editUserInfo.css">
</head>
<body>

<jsp:include page="/includes/header.jsp">
    <jsp:param name="activePage" value="editprofile" />
</jsp:include>

<%-- The hero sits OUTSIDE <main>, as myFleet.jsp's does and for the same
     reason: registration.css restyles bare `main` with a max-width and
     padding, so a banner inside it would be boxed in rather than spanning
     the window and meeting the site header. --%>
<header class="hero-band" id="accountHero">
    <div class="hero-band__content">
        <h1>Your Account</h1>
        <p class="hero-band__lede">
            Update your contact details and mailing address. We only save
            what you actually change.
        </p>
    </div>
    <p class="hero-band__credit">Hero image created with Google Gemini</p>
</header>

<main>

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

        <%--
          The same card Registration uses, pre-filled from the session
          Customer. Ten default* params - there is no defaultEmail, the card
          has never carried the email field (it lives in Registration's own
          right column), so this page renders its own below.
        --%>
        <jsp:include page="/includes/personalInfoCard.jsp">
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
                <button type="button" class="btn-secondary" id="openChangePassword">
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
                <a class="btn-secondary account-fleet-link"
                   href="${pageContext.request.contextPath}/myFleet">My Fleet</a>
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

</main>

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
            <button type="button" class="btn-outline" id="cancelSave" data-modal-close>Go Back</button>
            <button type="button" class="btn-primary" id="confirmSave">Yes, Save</button>
        </div>

    </div>
</div>

<jsp:include page="/includes/footer.jsp" />

<%-- Signed-in only, so it lives on this page rather than with the login
     modal. formValidation.js isn't loaded here - includes/loginModal.jsp
     already pulls it in through the header, on every page. --%>
<jsp:include page="/includes/changePasswordModal.jsp" />

<script src="${pageContext.request.contextPath}/js/editUserInfo.js" defer></script>
<script>
    document.addEventListener("DOMContentLoaded", function () {
        var change = document.getElementById("openChangePassword");
        var forgot = document.getElementById("openForgotPassword");

        if (change) {
            change.addEventListener("click", MoffatBay.accountModals.openChange);
        }

        if (forgot) {
            forgot.addEventListener("click", function (event) {
                event.preventDefault();
                /* Pre-filled from the form's own email box, which holds
                   what's on file unless it's just been edited. */
                var email = document.getElementById("email");
                MoffatBay.accountModals.openForgot(email ? email.value : "");
            });
        }
    });
</script>

</body>
</html>
