/*
 * src/main/webapp/js/loginModal.js
 * Author: Miguel Fernandez
 * CSD 460 - Capstone Project - Marina Website Project
 *
 * Open/close behavior for the Login modal, plus the client-side checks
 * from the Login contract's "Client-side (UX only, not trusted)" line.
 * None of this is a security boundary - LoginServlet re-checks both
 * fields and the email format server-side regardless.
 *
 * Requires formValidation.js to be loaded first (uses
 * MoffatBay.form.isValidEmail).
 *
 * Any page can open the modal with:
 *     MoffatBay.loginModal.open();
 * e.g. from the nav Log In control, or from the Registration page's
 * duplicate-email popup.
 */
var MoffatBay = window.MoffatBay || {};

MoffatBay.loginModal = (function () {
    "use strict";

    var modal = document.getElementById("loginModal");
    var form = document.getElementById("loginForm");
    var lastFocused = null;

    /**
     * Shows the modal and moves focus into it.
     */
    function open() {
        if (!modal) { return; }
        lastFocused = document.activeElement;
        modal.classList.add("is-open");
        var email = document.getElementById("loginEmail");
        if (email) { email.focus(); }
    }

    /**
     * Hides the modal and returns focus to whatever opened it.
     */
    function close() {
        if (!modal) { return; }
        modal.classList.remove("is-open");
        if (lastFocused) { lastFocused.focus(); }
    }

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
     * Clears both field messages.
     */
    function clearErrors() {
        setFieldError("loginEmail", "loginEmailError", "");
        setFieldError("loginPassword", "loginPasswordError", "");
    }

    if (modal) {

        // Backdrop and the X both close.
        modal.querySelectorAll("[data-login-close]").forEach(function (el) {
            el.addEventListener("click", close);
        });

        document.addEventListener("keydown", function (event) {
            if (event.key === "Escape" && modal.classList.contains("is-open")) {
                close();
            }
        });
    }

    if (form) {

        form.addEventListener("submit", function (event) {
            clearErrors();

            var emailInput = document.getElementById("loginEmail");
            var passwordInput = document.getElementById("loginPassword");

            var email = emailInput.value.trim();
            emailInput.value = email;

            var ok = true;

            if (email === "") {
                setFieldError("loginEmail", "loginEmailError", "Enter your email address.");
                ok = false;
            } else if (!MoffatBay.form.isValidEmail(email)) {
                // Same pattern the server uses, so the two never disagree.
                setFieldError("loginEmail", "loginEmailError", "Enter a valid email address.");
                ok = false;
            }

            if (passwordInput.value === "") {
                setFieldError("loginPassword", "loginPasswordError", "Enter your password.");
                ok = false;
            }

            if (!ok) {
                event.preventDefault();
                (email === "" || !MoffatBay.form.isValidEmail(email)
                    ? emailInput
                    : passwordInput).focus();
            }
        });

        form.addEventListener("input", clearErrors);
    }

    return {
        open: open,
        close: close
    };
})();
