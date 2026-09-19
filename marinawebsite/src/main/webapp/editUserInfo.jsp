<%--
  src/main/webapp/editUserInfo.jsp

  Edit User Info - the signed-in customer's own account page, per
  documentation/Page Contracts/Edit User Profile.md.

  Reached at /editProfile (EditProfileServlet), never as editUserInfo.jsp
  directly - the servlet's doGet is what promotes the post-save diff out of
  the session, so going straight at the JSP skips it and the page renders
  without the summary. Same rule as every other servlet-backed page here.

  Reads:
    sessionScope.customer - the Customer bean LoginServlet put in session.
                            Pre-fills every field; no extra lookup needed.
    changes               - Map<String, String[]> {old, new} for the fields
                            that just changed, set by EditProfileServlet.doGet
                            for exactly one render after a successful save.
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

<%--
  Field name -> the words a person would use for it, for the "what changed"
  summary. Kept here rather than in the servlet: it's display text, and the
  page is what decides how a column is named to a customer.
--%>
<jsp:useBean id="fieldLabels" class="java.util.LinkedHashMap" scope="page" />
<c:set target="${fieldLabels}" property="firstName" value="First name" />
<c:set target="${fieldLabels}" property="lastName" value="Last name" />
<c:set target="${fieldLabels}" property="email" value="Email" />
<c:set target="${fieldLabels}" property="phoneCountryCode" value="Country code" />
<c:set target="${fieldLabels}" property="phone" value="Phone" />
<c:set target="${fieldLabels}" property="streetAddress" value="Street address" />
<c:set target="${fieldLabels}" property="streetAddress2" value="Address line 2" />
<c:set target="${fieldLabels}" property="city" value="City" />
<c:set target="${fieldLabels}" property="state" value="State/Province" />
<c:set target="${fieldLabels}" property="zipCode" value="ZIP code" />
<c:set target="${fieldLabels}" property="country" value="Country" />

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

<main>

    <section class="hero-band" id="accountHero">
        <div class="hero-band__content">
            <h1>Your Account</h1>
            <p class="hero-band__lede">
                Update your contact details and mailing address. We only save
                what you actually change.
            </p>
        </div>
    </section>

    <%--
      What just changed. Rendered from the session flash EditProfileServlet
      promotes in doGet, so it survives the redirect-after-save but shows
      exactly once - a refresh doesn't re-announce an old edit.
    --%>
    <c:if test="${not empty changes}">
        <div class="form-banner form-banner--success" id="changeSummary" role="status">
            <p class="change-summary__title">Saved. Here's what changed:</p>
            <dl class="change-summary__list">
                <c:forEach var="change" items="${changes}">
                    <div class="change-summary__row">
                        <dt>
                            <c:choose>
                                <c:when test="${not empty fieldLabels[change.key]}">
                                    <c:out value="${fieldLabels[change.key]}" />
                                </c:when>
                                <c:otherwise><c:out value="${change.key}" /></c:otherwise>
                            </c:choose>
                        </dt>
                        <dd>
                            <span class="change-summary__old">
                                <c:choose>
                                    <c:when test="${empty change.value[0]}"><em>empty</em></c:when>
                                    <c:otherwise><c:out value="${change.value[0]}" /></c:otherwise>
                                </c:choose>
                            </span>
                            <span class="change-summary__arrow" aria-label="changed to">&rarr;</span>
                            <span class="change-summary__new">
                                <c:choose>
                                    <c:when test="${empty change.value[1]}"><em>empty</em></c:when>
                                    <c:otherwise><c:out value="${change.value[1]}" /></c:otherwise>
                                </c:choose>
                            </span>
                        </dd>
                    </div>
                </c:forEach>
            </dl>
        </div>
    </c:if>

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
                   href="${pageContext.request.contextPath}/myFleet.jsp">My Fleet</a>
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

        <%--
          The confirmation step from the contract's "Partial Update" section:
          the exact old -> new for every field about to be written, shown
          before anything is.

          Inline rather than a modal, deliberately. The page already has two
          modals, the changed fields are marked in place, and a dialog would
          cover the very fields it's asking about - this reads as the same
          thing continuing rather than an interruption. Built by
          editUserInfo.js from the live form values, so it can never show a
          different set of changes than the ones that get submitted.

          Distinct from the summary at the top of the page: that one reports
          what was saved, after the fact, from the session. This one asks.
        --%>
        <div class="confirm-changes" id="confirmChanges" hidden>
            <h2 class="confirm-changes__title">Save these changes?</h2>
            <dl class="change-summary__list" id="confirmChangesList"></dl>
            <div class="confirm-changes__actions">
                <button type="button" class="btn-primary" id="confirmSave">
                    Yes, save
                </button>
                <button type="button" class="btn-clear-section" id="cancelSave">
                    Go back
                </button>
            </div>
        </div>

    </form>

</main>

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
