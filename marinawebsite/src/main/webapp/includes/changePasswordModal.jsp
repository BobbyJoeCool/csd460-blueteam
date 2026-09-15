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

  No password checklist of its own. There is exactly one on the page, in
  forgotPasswordModal.jsp, and accountModals.js moves that single node into
  #changeRulesSlot below while this modal is open - passwordRules.js binds
  its rules by element id, so a second copy would leave two boxes where only
  the first ever ticked.

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

            <div id="changeRulesSlot"></div>

            <button type="submit" class="login-modal__submit" id="changePasswordSubmit">
                Update password
            </button>
        </form>

    </div>
</div>
