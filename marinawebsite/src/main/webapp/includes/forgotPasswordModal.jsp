<%--
  src/main/webapp/includes/forgotPasswordModal.jsp

  The password reset from the Edit User Profile contract's "Password Change
  and the Lockout Model". Posts to /forgotPassword (ForgotPasswordServlet):
  email, verification code, new password.

  Included by includes/loginModal.jsp rather than by any one page, and so
  reaches everywhere the login modal does. That placement is the point, not
  a convenience: completing a reset is now the only way to clear a lockout,
  and a locked-out customer can't sign in - so a reset that only opened from
  Edit User Info would sit behind the very session they can't get. It also
  has to work on a different device, days later, which is why the servlet
  identifies the account by email and not by anything in the session.

  Reads from the request:
    forgotPasswordError - set by ForgotPasswordServlet on any failure. Its
                          presence renders this modal already open with the
                          message inside, the same way loginError does for
                          the sign-in modal.

  Note the single instance of the password checklist below. It is the only
  one on any page - passwordRules.jsp binds to its elements by id and says
  "at most one per page" for that reason. The Change Password modal borrows
  this same node rather than including a second copy; see accountModals.js.

  Author: Miguel Fernandez
  Blue Team - Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
  Primary Author/Owner - Miguel Fernandez
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<%-- Same context-relative rule as the login modal: ForgotPasswordServlet
     prepends getContextPath() itself. On a failed attempt the request URI
     is /forgotPassword, so a submitted redirectTo is reused rather than
     recomputed. --%>
<c:set var="forgotCurrentPath"
       value="${fn:substring(pageContext.request.requestURI,
                             fn:length(pageContext.request.contextPath),
                             fn:length(pageContext.request.requestURI))}"/>
<c:set var="forgotRedirectTo"
       value="${not empty param.redirectTo ? param.redirectTo : forgotCurrentPath}"/>

<link rel="stylesheet" href="${pageContext.request.contextPath}/css/passwordRules.css">

<div class="login-modal <c:if test='${not empty forgotPasswordError}'>is-open</c:if>"
     id="forgotPasswordModal"
     role="dialog"
     aria-modal="true"
     aria-labelledby="forgotPasswordTitle">

    <div class="login-modal__backdrop" data-forgot-close></div>

    <div class="login-modal__panel">

        <button type="button"
                class="login-modal__close"
                data-forgot-close
                aria-label="Close password reset">&times;</button>

        <h2 class="login-modal__title" id="forgotPasswordTitle">Reset your password</h2>

        <c:if test="${not empty forgotPasswordError}">
            <p class="login-modal__error" role="alert">
                <c:out value="${forgotPasswordError}"/>
            </p>
        </c:if>

        <p class="login-modal__note">
            Enter your email and we'll send a verification code. Resetting your
            password also unlocks an account that's been locked.
        </p>

        <form class="login-modal__form"
              id="forgotPasswordForm"
              action="${pageContext.request.contextPath}/forgotPassword"
              method="post"
              novalidate>

            <input type="hidden" name="redirectTo" value="${fn:escapeXml(forgotRedirectTo)}">

            <div class="login-modal__field">
                <label for="forgotEmail">Email address</label>
                <input type="email"
                       id="forgotEmail"
                       name="email"
                       value="${fn:escapeXml(param.email)}"
                       maxlength="100"
                       autocomplete="email"
                       required>
                <p class="login-modal__field-error" id="forgotEmailError"></p>
            </div>

            <div class="login-modal__field">
                <label for="verificationCode">Verification code</label>
                <input type="text"
                       id="verificationCode"
                       name="verificationCode"
                       inputmode="numeric"
                       maxlength="10"
                       autocomplete="one-time-code"
                       required>
                <%-- Said out loud on purpose. There is no mail server on this
                     project, so there is no code to receive - hiding that
                     would only leave a tester stuck at a box that can't be
                     filled. See the contract's note on the simulated code. --%>
                <p class="field-hint">Demo site - the code is 12345.</p>
                <p class="login-modal__field-error" id="verificationCodeError"></p>
            </div>

            <div class="login-modal__field">
                <label for="forgotNewPassword">New password</label>
                <input type="password"
                       id="forgotNewPassword"
                       name="newPassword"
                       autocomplete="new-password"
                       required>
                <p class="login-modal__field-error" id="forgotNewPasswordError"></p>
            </div>

            <div class="login-modal__field">
                <label for="forgotConfirmPassword">Confirm new password</label>
                <%-- No name attribute: this never reaches the server. It
                     exists to catch a typo before the password is changed to
                     something the customer didn't mean to type. --%>
                <input type="password"
                       id="forgotConfirmPassword"
                       autocomplete="new-password"
                       required>
                <p class="login-modal__field-error" id="forgotConfirmPasswordError"></p>
            </div>

            <div id="forgotRulesSlot">
                <jsp:include page="/includes/passwordRules.jsp" />
            </div>

            <button type="submit" class="login-modal__submit">Reset password</button>
        </form>

    </div>
</div>
