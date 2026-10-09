<%--
  src/main/webapp/WEB-INF/includes/changePasswordModal.jsp

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
  element ids WEB-INF/includes/passwordRules.jsp uses - see the note on that markup
  below, and the matching one in forgotPasswordModal.jsp.

  Author: Miguel Fernandez
  Blue Team - Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
  Primary Author/Owner - Miguel Fernandez
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%-- The site's shared .modal (site.css), opened and closed through
     js/modal.js like every other popup. --%>
<div class="modal login-modal"
     id="changePasswordModal"
     role="dialog"
     aria-modal="true"
     aria-labelledby="changePasswordTitle"
     hidden>

    <button type="button" class="modal__backdrop" data-modal-close
            aria-label="Close change password" tabindex="-1"></button>

    <div class="modal__box modal__box--narrow">

        <div class="modal__header">
            <h2 class="modal__title" id="changePasswordTitle">Change your password</h2>
            <button type="button" class="modal__close" data-modal-close
                    aria-label="Close change password">&times;</button>
        </div>

        <%-- Errors from the servlet land here rather than beside a field.
             It answers with one message at a time, and the one it sends most
             often - the current password being wrong - belongs to the form
             as a whole as much as to any single box. --%>
        <p class="form-banner login-modal__banner" id="changePasswordError" role="alert" hidden></p>

        <%-- The endpoint lives on the form rather than in the JS, so the
             context path is written once, by the container that knows it. --%>
        <form class="login-modal__form"
              id="changePasswordForm"
              data-action="${pageContext.request.contextPath}/editProfile/password"
              novalidate>

            <div class="form-group">
                <label for="currentPassword">Current password</label>
                <input type="password"
                       id="currentPassword"
                       name="currentPassword"
                       autocomplete="current-password"
                       required>
                <p class="field-error" id="currentPasswordError"></p>
            </div>

            <div class="form-group">
                <label for="newPassword">New password</label>
                <%-- pattern and minlength mirror Utils.PASSWORD_PATTERN for the
                     browser; passwordrules tells password generators (Safari,
                     iCloud Keychain, 1Password) the same rules, since they
                     don't read pattern. --%>
                <input type="password"
                       id="newPassword"
                       name="newPassword"
                       autocomplete="new-password"
                       required
                       minlength="10"
                       pattern="(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])(?=.*[!$%*#]).{10,}"
                       passwordrules="minlength: 10; required: lower; required: upper; required: digit; required: [!$%*#];"
                       title="Password must be at least 10 characters and contain an uppercase letter, a lowercase letter, a number, and one special character (! $ % * #)."
                       aria-describedby="changePasswordRules">
                <p class="field-error" id="newPasswordError"></p>
            </div>

            <div class="form-group">
                <label for="confirmNewPassword">Confirm new password</label>
                <%-- Never submitted - checked here only, so a typo can't
                     become the password. --%>
                <input type="password"
                       id="confirmNewPassword"
                       autocomplete="new-password"
                       required>
                <p class="field-error" id="confirmNewPasswordError"></p>
            </div>

            <%--
              A checklist of its own rather than <jsp:include> of
              WEB-INF/includes/passwordRules.jsp, and deliberately without
              its ids. passwordRules.js looks its rules up by element id and
              caches them on load, so a second copy of that markup anywhere on
              the same page gives two boxes sharing one set of ids and only the
              first one in the document ever ticks. This modal ships with
              the login modal, which the header pulls into every page -
              including Registration, which has its own checklist. The ids
              are what collide, so these are keyed on data-rule instead and
              ticked by accountModals.js. Same classes, so passwordRules.css
              styles it identically. The container's own id is unique to this
              modal and is only there for the New password field's
              aria-describedby.
            --%>
            <div class="password-rules" id="changePasswordRules" data-password-rules>
                <p>Your password must contain:</p>
                <ul>
                    <li data-rule="length">At least 10 characters</li>
                    <li data-rule="upper">One uppercase letter</li>
                    <li data-rule="lower">One lowercase letter</li>
                    <li data-rule="number">One number</li>
                    <li data-rule="special">One special character (! $ % * #)</li>
                </ul>
            </div>

            <button type="submit" class="btn-primary login-modal__submit" id="changePasswordSubmit">
                Update password
            </button>
        </form>

    </div>
</div>
