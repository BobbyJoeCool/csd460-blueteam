<%--
  src/main/webapp/includes/changePasswordModal.jsp

  Changing your own password while signed in, per the Edit User Profile
  contract. Posts to /editProfile/password (EditProfilePasswordServlet),
  which answers with JSON rather than a page - so unlike every other form on
  this site, this one is sent from JavaScript and the page never navigates.
  See accountModals.js.

  Included only by editUserInfo.jsp. It has no reason to exist anywhere
  else: it needs a session, and the servlet reads the customer from the
  session rather than from anything submitted. The forgot-password modal is
  the opposite case and lives with the login modal instead.

  Carries its own password checklist, keyed on data-rule rather than on the
  element ids includes/passwordRules.jsp uses - see the note on that markup
  below, and the matching one in forgotPasswordModal.jsp.

  Author: Miguel Fernandez
  Blue Team - Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
  Primary Author/Owner - Miguel Fernandez
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<div class="login-modal"
     id="changePasswordModal"
     role="dialog"
     aria-modal="true"
     aria-labelledby="changePasswordTitle">

    <div class="login-modal__backdrop" data-change-close></div>

    <div class="login-modal__panel">

        <button type="button"
                class="login-modal__close"
                data-change-close
                aria-label="Close change password">&times;</button>

        <h2 class="login-modal__title" id="changePasswordTitle">Change your password</h2>

        <%-- Errors from the servlet land here rather than beside a field.
             It answers with one message at a time, and the one it sends most
             often - the current password being wrong - belongs to the form
             as a whole as much as to any single box. --%>
        <p class="login-modal__error" id="changePasswordError" role="alert" hidden></p>

        <%-- The endpoint lives on the form rather than in the JS, so the
             context path is written once, by the container that knows it. --%>
        <form class="login-modal__form"
              id="changePasswordForm"
              data-action="${pageContext.request.contextPath}/editProfile/password"
              novalidate>

            <div class="login-modal__field">
                <label for="currentPassword">Current password</label>
                <input type="password"
                       id="currentPassword"
                       name="currentPassword"
                       autocomplete="current-password"
                       required>
                <p class="login-modal__field-error" id="currentPasswordError"></p>
            </div>

            <div class="login-modal__field">
                <label for="newPassword">New password</label>
                <input type="password"
                       id="newPassword"
                       name="newPassword"
                       autocomplete="new-password"
                       required>
                <p class="login-modal__field-error" id="newPasswordError"></p>
            </div>

            <div class="login-modal__field">
                <label for="confirmNewPassword">Confirm new password</label>
                <%-- Never submitted - checked here only, so a typo can't
                     become the password. --%>
                <input type="password"
                       id="confirmNewPassword"
                       autocomplete="new-password"
                       required>
                <p class="login-modal__field-error" id="confirmNewPasswordError"></p>
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

            <button type="submit" class="login-modal__submit" id="changePasswordSubmit">
                Update password
            </button>
        </form>

    </div>
</div>
