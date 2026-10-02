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
 * A button opens the modal by carrying data-sign-in, optionally with the
 * page to land on after (data-sign-in="/reservation"). Markup never uses
 * onclick="...": the Content-Security-Policy (SecurityHeadersFilter)
 * blocks inline script. Scripts can still call:
 *     MoffatBay.loginModal.open();
 * e.g. the Registration page's duplicate-email popup.
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
        MoffatBay.form.setFieldError(inputId, errorId, message);
    }

    /**
     * Clears both field messages.
     */
    function clearErrors() {
        setFieldError("loginEmail", "loginEmailError", "");
        setFieldError("loginPassword", "loginPasswordError", "");
    }


    /* Every Sign In / Log In button: the nav, the home page's Book a Slip,
       and the signed-out views of the members-only pages. An empty
       data-sign-in means "come back to this page". */
    document.querySelectorAll("[data-sign-in]").forEach(function (button) {
        button.addEventListener("click", function () {
            open(button.dataset.signIn);
        });
    });

    /* Both ways into the password reset: "Forgot password?" under the
       sign-in form, and "Reset your password" in the locked-out state.
       Only one of them is on any given render.

       The email to pre-fill: the locked-out button carries the address
       that was just locked (data-email); otherwise, whatever is typed in
       the sign-in form's Email field. openForgot() only fills the reset's
       field if it's empty, so it never overwrites one that came back
       after a failed reset. accountModals.js loads after this file, so
       it's looked up at click time. */
    document.querySelectorAll("[data-forgot-trigger]").forEach(function (trigger) {
        trigger.addEventListener("click", function () {
            var typed = document.getElementById("loginEmail");
            var email = trigger.dataset.email
                    || (typed ? typed.value.trim() : "");
            close();
            MoffatBay.accountModals.openForgot(email);
        });
    });

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
