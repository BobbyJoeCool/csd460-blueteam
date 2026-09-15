/*
 * src/main/webapp/js/accountModals.js
 * Author: Miguel Fernandez
 * Blue Team - Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
 * Primary Author/Owner - Miguel Fernandez
 * CSD 460 - Capstone Project - Marina Website Project
 *
 * Open/close and client-side checks for the two password modals:
 *
 *   Forgot password  (includes/forgotPasswordModal.jsp) - on every page,
 *     since includes/loginModal.jsp pulls it in. A real form POST to
 *     /forgotPassword that navigates, because a locked-out visitor has no
 *     session and the servlet answers with a page, forwarding back here on
 *     failure exactly like LoginServlet does.
 *
 *   Change password  (includes/changePasswordModal.jsp) - Edit User Info
 *     only. Sent with fetch, because EditProfilePasswordServlet answers
 *     with JSON and the page is not supposed to move.
 *
 * The two look like twins and work almost nothing alike. That difference
 * comes from the servlets, not from preference.
 *
 * Neither is a security boundary - both servlets re-check everything.
 *
 * Requires formValidation.js (MoffatBay.form.PASSWORD_RULES) and
 * passwordRules.js (MoffatBay.passwordRules.check), both loaded by
 * includes/loginModal.jsp.
 */
var MoffatBay = window.MoffatBay || {};

MoffatBay.accountModals = (function () {
    "use strict";

    var forgotModal = document.getElementById("forgotPasswordModal");
    var changeModal = document.getElementById("changePasswordModal");

    var lastFocused = null;

    /**
     * Puts a message under one field and marks the input invalid.
     * @param {string} inputId - id of the input
     * @param {string} errorId - id of the message element under it
     * @param {string} message - text to show; "" clears it
     */
    function setFieldError(inputId, errorId, message) {
        var input = document.getElementById(inputId);
        var error = document.getElementById(errorId);
        if (input) { input.classList.toggle("field-invalid", message !== ""); }
        if (error) { error.textContent = message; }
    }

    /**
     * Clears every message inside one modal.
     * @param {Element} modal - the modal element
     */
    function clearErrors(modal) {
        if (!modal) { return; }
        modal.querySelectorAll(".login-modal__field-error").forEach(function (el) {
            el.textContent = "";
        });
        modal.querySelectorAll(".field-invalid").forEach(function (el) {
            el.classList.remove("field-invalid");
        });
    }

    /**
     * Moves the one password checklist on the page into the modal that's
     * open.
     *
     * There is deliberately only one. passwordRules.js looks its rule
     * elements up by id once, on load, and holds on to them - so a second
     * copy of the markup would give two boxes sharing one set of ids, and
     * only the first would ever tick. Moving the node keeps those element
     * references valid, since they're the same elements either way.
     *
     * @param {string} slotId - id of the container to move it into
     */
    function moveRulesTo(slotId) {
        var rules = document.getElementById("passwordRules");
        var slot = document.getElementById(slotId);
        if (rules && slot && rules.parentElement !== slot) {
            slot.appendChild(rules);
        }
    }

    /**
     * Shows a modal and moves focus into it.
     * @param {Element} modal - the modal to open
     * @param {string} firstFieldId - id of the field to focus
     * @param {string} slotId - where the password checklist should sit
     */
    function open(modal, firstFieldId, slotId) {
        if (!modal) { return; }
        lastFocused = document.activeElement;
        moveRulesTo(slotId);
        modal.classList.add("is-open");
        var first = document.getElementById(firstFieldId);
        if (first) { first.focus(); }
    }

    /**
     * Hides a modal and returns focus to whatever opened it.
     * @param {Element} modal - the modal to close
     */
    function close(modal) {
        if (!modal) { return; }
        modal.classList.remove("is-open");
        clearErrors(modal);
        /* The checklist goes home, so it's where the other modal expects to
           find it next time and never ends up inside a closed one. */
        moveRulesTo("forgotRulesSlot");
        if (lastFocused) { lastFocused.focus(); }
    }

    /**
     * Opens the forgot-password modal.
     * @param {string} [email] - pre-fills the email field, so a locked-out
     *   customer doesn't retype the address they just failed to sign in with
     */
    function openForgot(email) {
        var field = document.getElementById("forgotEmail");
        if (email && field && field.value === "") { field.value = email; }
        open(forgotModal, "forgotEmail", "forgotRulesSlot");
    }

    /**
     * Opens the change-password modal.
     */
    function openChange() {
        open(changeModal, "currentPassword", "changeRulesSlot");
    }

    /**
     * Shared checks for a new password and its confirmation.
     * @param {string} newId - id of the new password input
     * @param {string} newErrorId - id of its message element
     * @param {string} confirmId - id of the confirmation input
     * @param {string} confirmErrorId - id of its message element
     * @returns {string|null} the id of the first bad field, or null
     */
    function checkNewPassword(newId, newErrorId, confirmId, confirmErrorId) {
        var newValue = document.getElementById(newId).value;
        var confirmValue = document.getElementById(confirmId).value;

        if (newValue === "") {
            setFieldError(newId, newErrorId, "Enter a new password.");
            return newId;
        }
        if (!MoffatBay.passwordRules.check(newValue)) {
            setFieldError(newId, newErrorId, "Your password doesn't meet the rules below yet.");
            return newId;
        }
        if (confirmValue !== newValue) {
            setFieldError(confirmId, confirmErrorId, "Both passwords must match.");
            return confirmId;
        }
        return null;
    }

    /* ==================================================================
       Forgot password
       ================================================================== */

    if (forgotModal) {

        forgotModal.querySelectorAll("[data-forgot-close]").forEach(function (el) {
            el.addEventListener("click", function () { close(forgotModal); });
        });

        var forgotNew = document.getElementById("forgotNewPassword");
        if (forgotNew) {
            forgotNew.addEventListener("input", function () {
                MoffatBay.passwordRules.check(forgotNew.value);
            });
        }

        var forgotForm = document.getElementById("forgotPasswordForm");
        if (forgotForm) {
            forgotForm.addEventListener("input", function () { clearErrors(forgotModal); });

            forgotForm.addEventListener("submit", function (event) {
                clearErrors(forgotModal);

                var email = document.getElementById("forgotEmail");
                var code = document.getElementById("verificationCode");
                var firstBad = null;

                email.value = email.value.trim();
                if (email.value === "" || !MoffatBay.form.isValidEmail(email.value)) {
                    setFieldError("forgotEmail", "forgotEmailError", "Enter a valid email address.");
                    firstBad = "forgotEmail";
                }

                code.value = code.value.trim();
                if (code.value === "") {
                    setFieldError("verificationCode", "verificationCodeError",
                        "Enter the verification code.");
                    if (!firstBad) { firstBad = "verificationCode"; }
                }

                /* Checked here as well as on the server, and the wording
                   matters: the server answers a bad password and a bad code
                   with two different messages, and it checks the password
                   format first precisely so that difference can't be used to
                   find out which emails exist. Catching format problems
                   before the request goes keeps that out of play entirely. */
                var badPassword = checkNewPassword(
                    "forgotNewPassword", "forgotNewPasswordError",
                    "forgotConfirmPassword", "forgotConfirmPasswordError");
                if (badPassword && !firstBad) { firstBad = badPassword; }

                if (firstBad) {
                    event.preventDefault();
                    document.getElementById(firstBad).focus();
                }
            });
        }
    }

    /* ==================================================================
       Change password
       ================================================================== */

    if (changeModal) {

        changeModal.querySelectorAll("[data-change-close]").forEach(function (el) {
            el.addEventListener("click", function () { close(changeModal); });
        });

        var changeNew = document.getElementById("newPassword");
        if (changeNew) {
            changeNew.addEventListener("input", function () {
                MoffatBay.passwordRules.check(changeNew.value);
            });
        }

        var changeForm = document.getElementById("changePasswordForm");
        if (changeForm) {
            changeForm.addEventListener("input", function () {
                clearErrors(changeModal);
                var banner = document.getElementById("changePasswordError");
                if (banner) { banner.hidden = true; }
            });

            changeForm.addEventListener("submit", function (event) {
                event.preventDefault();
                clearErrors(changeModal);

                var current = document.getElementById("currentPassword");
                var banner = document.getElementById("changePasswordError");
                var submit = document.getElementById("changePasswordSubmit");

                if (current.value === "") {
                    setFieldError("currentPassword", "currentPasswordError",
                        "Enter your current password.");
                    current.focus();
                    return;
                }

                var badPassword = checkNewPassword(
                    "newPassword", "newPasswordError",
                    "confirmNewPassword", "confirmNewPasswordError");
                if (badPassword) {
                    document.getElementById(badPassword).focus();
                    return;
                }

                var body = new URLSearchParams();
                body.set("currentPassword", current.value);
                body.set("newPassword", document.getElementById("newPassword").value);

                submit.disabled = true;

                fetch(changeForm.dataset.action, {
                    method: "POST",
                    headers: { "Content-Type": "application/x-www-form-urlencoded" },
                    body: body.toString()
                }).then(function (response) {
                    return response.json();
                }).then(function (data) {
                    submit.disabled = false;
                    if (data.ok) {
                        changeForm.reset();
                        close(changeModal);
                        MoffatBay.statusPopup.show("Password updated");
                        return;
                    }
                    if (banner) {
                        banner.textContent = data.error || "That didn't work. Try again.";
                        banner.hidden = false;
                    }
                }).catch(function () {
                    submit.disabled = false;
                    if (banner) {
                        banner.textContent = "We couldn't reach the marina just then. Try again.";
                        banner.hidden = false;
                    }
                });
            });
        }
    }

    /* Escape closes whichever is open. Bound once rather than per modal, so
       there's one place that decides what Escape does. */
    document.addEventListener("keydown", function (event) {
        if (event.key !== "Escape") { return; }
        if (forgotModal && forgotModal.classList.contains("is-open")) { close(forgotModal); }
        if (changeModal && changeModal.classList.contains("is-open")) { close(changeModal); }
    });

    return {
        openForgot: openForgot,
        openChange: openChange,
        closeForgot: function () { close(forgotModal); },
        closeChange: function () { close(changeModal); }
    };
})();
