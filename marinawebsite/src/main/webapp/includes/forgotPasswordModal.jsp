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

  Reads from the session (set by ForgotPasswordServlet on any failure, and
  removed here as soon as they're read):
    forgotFlashError - the message. Its presence renders this modal already
                       open with the message inside, the same way loginError
                       does for the sign-in modal.
    forgotFlashEmail - what they typed, so the email field refills.

  The password checklist below is this modal's own, keyed on data-rule
  rather than on the element ids includes/passwordRules.jsp uses. That
  include says "at most one per page" because passwordRules.js caches its
  rules by id, and this modal travels to every page - Registration's own
  checklist would be the second copy. See the comment on the markup.

  Author: Miguel Fernandez
  Blue Team - Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
  Primary Author/Owner - Miguel Fernandez
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<%-- The failure message from ForgotPasswordServlet, read once and cleared.
     In the session rather than a request attribute because the failure path
     redirects back to the page instead of forwarding (a redirect drops
     request attributes) - the same flash approach loginModal.jsp uses. --%>
<c:set var="forgotPasswordError" value="${sessionScope.forgotFlashError}"/>
<c:set var="forgotEmail" value="${sessionScope.forgotFlashEmail}"/>
<c:remove var="forgotFlashError" scope="session"/>
<c:remove var="forgotFlashEmail" scope="session"/>

<%-- Same context-relative rule as the login modal: ForgotPasswordServlet
     prepends getContextPath() itself. A failed attempt redirects back to
     the origin page, so the current path is already the right target. --%>
<%-- The original URI, not the forwarded one - a servlet that forwards to
     its own JSP leaves getRequestURI() reporting the forward's target, so
     the reset would send the customer to a raw .jsp that skips its
     servlet's doGet. See the fuller note in includes/loginModal.jsp. --%>
<c:set var="forgotOriginalUri"
       value="${not empty requestScope['jakarta.servlet.forward.request_uri']
                ? requestScope['jakarta.servlet.forward.request_uri']
                : pageContext.request.requestURI}"/>
<c:set var="forgotCurrentPath"
       value="${fn:substring(forgotOriginalUri,
                             fn:length(pageContext.request.contextPath),
                             fn:length(forgotOriginalUri))}"/>
<c:set var="forgotRedirectTo"
       value="${not empty param.redirectTo ? param.redirectTo : forgotCurrentPath}"/>

<link rel="stylesheet" href="${pageContext.request.contextPath}/css/passwordRules.css">

<%-- The site's shared .modal (site.css), opened and closed through
     js/modal.js like every other popup. --%>
<div class="modal login-modal"
     id="forgotPasswordModal"
     role="dialog"
     aria-modal="true"
     aria-labelledby="forgotPasswordTitle"
     <c:if test="${empty forgotPasswordError}">hidden</c:if>>

    <button type="button" class="modal__backdrop" data-modal-close
            aria-label="Close password reset" tabindex="-1"></button>

    <div class="modal__box modal__box--narrow">

        <div class="modal__header">
            <h2 class="modal__title" id="forgotPasswordTitle">Reset your password</h2>
            <button type="button" class="modal__close" data-modal-close
                    aria-label="Close password reset">&times;</button>
        </div>

        <c:if test="${not empty forgotPasswordError}">
            <p class="form-banner login-modal__banner" role="alert">
                <c:out value="${forgotPasswordError}"/>
            </p>
        </c:if>

        <p class="modal__note login-modal__note">
            Enter your email and we'll send a verification code. Resetting your
            password also unlocks an account that's been locked.
        </p>

        <form class="login-modal__form"
              id="forgotPasswordForm"
              action="${pageContext.request.contextPath}/forgotPassword"
              method="post"
              novalidate>
            <jsp:include page="/includes/csrfField.jsp" />

            <input type="hidden" name="redirectTo" value="${fn:escapeXml(forgotRedirectTo)}">

            <div class="form-group">
                <label for="forgotEmail">Email address</label>
                <input type="email"
                       id="forgotEmail"
                       name="email"
                       value="${fn:escapeXml(forgotEmail)}"
                       maxlength="100"
                       autocomplete="email"
                       required>
                <p class="field-error" id="forgotEmailError"></p>
            </div>

            <div class="form-group">
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
                <p class="field-error" id="verificationCodeError"></p>
            </div>

            <div class="form-group">
                <label for="forgotNewPassword">New password</label>
                <input type="password"
                       id="forgotNewPassword"
                       name="newPassword"
                       autocomplete="new-password"
                       required>
                <p class="field-error" id="forgotNewPasswordError"></p>
            </div>

            <div class="form-group">
                <label for="forgotConfirmPassword">Confirm new password</label>
                <%-- No name attribute: this never reaches the server. It
                     exists to catch a typo before the password is changed to
                     something the customer didn't mean to type. --%>
                <input type="password"
                       id="forgotConfirmPassword"
                       autocomplete="new-password"
                       required>
                <p class="field-error" id="forgotConfirmPasswordError"></p>
            </div>

            <%--
              A checklist of its own rather than <jsp:include> of
              includes/passwordRules.jsp, and deliberately without ids.
              passwordRules.js looks its rules up by element id and caches
              them on load, so a second copy of that markup anywhere on the
              same page gives two boxes sharing one set of ids and only the
              first one in the document ever ticks. This modal ships with
              the login modal, which the header pulls into every page -
              including Registration, which has its own checklist. The ids
              are what collide, so these are keyed on data-rule instead and
              ticked by accountModals.js. Same classes, so passwordRules.css
              styles it identically.
            --%>
            <div class="password-rules" data-password-rules>
                <p>Your password must contain:</p>
                <ul>
                    <li data-rule="length">At least 10 characters</li>
                    <li data-rule="upper">One uppercase letter</li>
                    <li data-rule="lower">One lowercase letter</li>
                    <li data-rule="number">One number</li>
                    <li data-rule="special">One special character (! $ % * #)</li>
                </ul>
            </div>

            <button type="submit" class="btn-primary login-modal__submit">Reset password</button>
        </form>

    </div>
</div>
