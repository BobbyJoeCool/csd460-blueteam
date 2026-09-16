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
 * Requires formValidation.js (MoffatBay.form.*), loaded by
 * includes/loginModal.jsp. Deliberately does NOT use passwordRules.js -
 * see checkRules below for why.
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
     * Ticks off the password rules inside one modal.
     *
     * Deliberately not the shared passwordRules.js helper. That one looks
     * its rule elements up by id once, when the page loads, and holds on to
     * them - and these modals travel with the login modal to every page,
     * including Registration, which has a checklist of its own using those
     * same ids. Two boxes sharing one set of ids means only whichever comes
     * first in the document ever ticks, and since the header renders before
     * the page body, that would be the hidden modal rather than the form
     * the customer is actually filling in.
     *
     * So each modal carries its own checklist keyed on data-rule, and this
     * walks that copy. The rules themselves still come from the single
     * place they are defined, MoffatBay.form.PASSWORD_RULES, so there is
     * still one answer to what a valid password is.
     *
     * @param {Element} modal - the modal whose checklist to update
     * @param {string} value - the password to test
     * @returns {boolean} true only if every rule passed
     */
    function checkRules(modal, value) {
        var allMet = true;
        Object.keys(MoffatBay.form.PASSWORD_RULES).forEach(function (key) {
            var met = MoffatBay.form.PASSWORD_RULES[key].test(value);
            if (!met) { allMet = false; }
            if (!modal) { return; }
            var item = modal.querySelector('[data-rule="' + key + '"]');
            if (item) { item.classList.toggle("met", met); }
        });
        return allMet;
    }

    /**
     * Clears every tick in a modal's checklist, so a reopened modal doesn't
     * still show the last attempt's progress.
     * @param {Element} modal - the modal to reset
     */
    function clearRules(modal) {
        if (!modal) { return; }
        modal.querySelectorAll("[data-rule]").forEach(function (item) {
            item.classList.remove("met");
        });
    }

    /**
     * Shows a modal and moves focus into it.
     * @param {Element} modal - the modal to open
     * @param {string} firstFieldId - id of the field to focus
     */
    function open(modal, firstFieldId) {
        if (!modal) { return; }
        lastFocused = document.activeElement;
        clearRules(modal);
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
        clearRules(modal);
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
        open(forgotModal, "forgotEmail");
    }

    /**
     * Opens the change-password modal.
     */
    function openChange() {
        open(changeModal, "currentPassword");
    }

    /**
     * Shared checks for a new password and its confirmation.
     * @param {Element} modal - the modal these fields live in
     * @param {string} newId - id of the new password input
     * @param {string} newErrorId - id of its message element
     * @param {string} confirmId - id of the confirmation input
     * @param {string} confirmErrorId - id of its message element
     * @returns {string|null} the id of the first bad field, or null
     */
    function checkNewPassword(modal, newId, newErrorId, confirmId, confirmErrorId) {
        var newValue = document.getElementById(newId).value;
        var confirmValue = document.getElementById(confirmId).value;

        if (newValue === "") {
            setFieldError(newId, newErrorId, "Enter a new password.");
            return newId;
        }
        if (!checkRules(modal, newValue)) {
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
                checkRules(forgotModal, forgotNew.value);
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
                var badPassword = checkNewPassword(forgotModal,
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
                checkRules(changeModal, changeNew.value);
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

                var badPassword = checkNewPassword(changeModal,
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
