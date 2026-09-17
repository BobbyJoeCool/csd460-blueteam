/*
 * Blue Team - Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
 * Primary Author/Owner - Robert Breutzmann
 * src/main/webapp/js/passwordToggle.js
 *
 * Show/hide "eye" button for every password field on the site. Loaded
 * once, from includes/header.jsp, so every page that carries the header
 * (and the login, forgot-password and change-password modals that ride
 * along with it) gets the toggle without any per-page markup.
 *
 * On load it finds every <input type="password"> and wraps it:
 *
 *     <div class="password-toggle">
 *         <input type="password" class="password-toggle__input" ...>
 *         <button type="button" class="password-toggle__btn">(eye)</button>
 *     </div>
 *
 * Styling lives in css/passwordToggle.css (linked by includes/styles.jsp),
 * so a new password field anywhere needs no extra CSS or JS - it just
 * needs to be type="password" and on a page that includes the header.
 *
 * The icon shows the field's current state: a closed eye while the
 * password is hidden, an open eye while it's visible. A field reverts to
 * hidden whenever its form is reset, so a modal reopened after a reset
 * never starts with a password on show.
 *
 * Exposes MoffatBay.passwordToggle.enhance(input) for a field added to
 * the page after load.
 */
var MoffatBay = window.MoffatBay || {};

MoffatBay.passwordToggle = (function () {
    "use strict";

    var EYE_OPEN =
        '<svg viewBox="0 0 24 24" aria-hidden="true" focusable="false">' +
        '<path d="M2 12s3.6-7 10-7 10 7 10 7-3.6 7-10 7S2 12 2 12z"/>' +
        '<circle cx="12" cy="12" r="3"/>' +
        '</svg>';

    var EYE_CLOSED =
        '<svg viewBox="0 0 24 24" aria-hidden="true" focusable="false">' +
        '<path d="M2 10s3.6 6 10 6 10-6 10-6"/>' +
        '<path d="M4.5 13.2 3 15.5M9 15.6l-.7 2.6M15 15.6l.7 2.6M19.5 13.2 21 15.5"/>' +
        '</svg>';

    /**
     * Shows or hides one field's password and syncs its button to match.
     * @param {HTMLInputElement} input - the wrapped password field
     * @param {HTMLButtonElement} button - that field's toggle button
     * @param {boolean} visible - true to show the password as plain text
     */
    function setVisible(input, button, visible) {
        input.type = visible ? "text" : "password";
        button.innerHTML = visible ? EYE_OPEN : EYE_CLOSED;
        button.setAttribute("aria-pressed", visible ? "true" : "false");
        button.setAttribute("aria-label", visible ? "Hide password" : "Show password");
    }

    /**
     * Wraps one password field and gives it a toggle button. Safe to call
     * twice on the same field - the second call does nothing.
     * @param {HTMLInputElement} input - an <input type="password">
     */
    function enhance(input) {
        if (input.dataset.passwordToggle === "ready") { return; }
        input.dataset.passwordToggle = "ready";

        var wrapper = document.createElement("div");
        wrapper.className = "password-toggle";
        input.parentNode.insertBefore(wrapper, input);
        wrapper.appendChild(input);
        input.classList.add("password-toggle__input");

        var button = document.createElement("button");
        button.type = "button";
        button.className = "password-toggle__btn";
        if (input.id) { button.setAttribute("aria-controls", input.id); }
        wrapper.appendChild(button);
        setVisible(input, button, false);

        button.addEventListener("click", function () {
            setVisible(input, button, input.type === "password");
        });

        if (input.form) {
            input.form.addEventListener("reset", function () {
                setVisible(input, button, false);
            });
        }
    }

    document.querySelectorAll('input[type="password"]').forEach(enhance);

    return {
        enhance: enhance
    };
})();
