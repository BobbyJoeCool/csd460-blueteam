/*
 * src/main/webapp/js/loginModal.js
 * Author: Miguel Fernandez
 * Blue Team - Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
 * Primary Author/Owner - Miguel Fernandez
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
 * The modal itself is the shared .modal, so showing it, hiding it, Escape,
 * the backdrop and putting focus back all go through js/modal.js - this
 * file only adds what is particular to signing in.
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

    /**
     * Shows the modal and moves focus into it.
     *
     * @param {string} [redirectTo] - where to land after a successful sign
     *   in, as a context-relative path like "/reservation" (LoginServlet
     *   prepends the context path itself, so never "/marinawebsite/...").
     *   Optional: leave it out and the modal falls back to the page the user
     *   is already on, which is right for a plain "Log In" control but wrong
     *   for a control that names somewhere else - a "Book a Slip" button
     *   should land on the reservation page, not back where it was clicked.
     */
    function open(redirectTo) {
        if (!modal) { return; }

        if (redirectTo) {
            // Both forms carry one - the sign-in form and the unlock-account
            // form - so unlocking lands in the same place signing in would.
            modal.querySelectorAll('input[name="redirectTo"]').forEach(
                function (field) { field.value = redirectTo; });

            // And Register here, so a new customer who registers instead
            // of signing in still lands on the page this control named -
            // e.g. the home page's Book a Slip button, which is set here
            // in the browser, after the server rendered the link.
            var registerLink = document.getElementById("loginRegisterLink");
            if (registerLink) {
                var url = new URL(registerLink.href);
                url.searchParams.set("redirectTo", redirectTo);
                registerLink.href = url.toString();
            }
        }

        // modal.js focuses the first field (Email) and remembers what to
        // hand focus back to.
        MoffatBay.modal.open(modal);
    }

    /**
     * Hides the modal and returns focus to whatever opened it.
     */
    function close() {
        MoffatBay.modal.close(modal);
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

        /* Opened by ?signIn=/somePage - a members-only page sent a signed-
           out visitor here (CustomerSession.sendToSignIn), and the JSP
           rendered the modal already open with that page as the return
           address. Put focus in the email field, then take signIn back
           out of the address bar so a refresh or a copied link doesn't
           pop the box open again. The return page is already in the
           form's hidden field, so nothing is lost. */
        if (window.URLSearchParams) {
            var params = new URLSearchParams(window.location.search);
            if (params.has("signIn")) {
                if (!modal.hidden) {
                    var emailField = document.getElementById("loginEmail");
                    if (emailField) { emailField.focus(); }
                }
                if (window.history && window.history.replaceState) {
                    params.delete("signIn");
                    var query = params.toString();
                    window.history.replaceState(
                        {},
                        "",
                        window.location.pathname + (query ? "?" + query : "") + window.location.hash
                    );
                }
            }
        }
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
