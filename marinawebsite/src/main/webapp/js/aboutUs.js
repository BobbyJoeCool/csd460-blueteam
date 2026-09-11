/*
 * src/main/webapp/js/aboutUs.js
 * Author: Miguel Fernandez
 * Blue Team - Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
 * Primary Author/Owner - Miguel Fernandez
 * CSD 460 - Capstone Project - Marina Website Project
 *
 * Client-side checks for the About Us contact form, plus the character
 * counter under the message box.
 *
 * None of this is trusted. The back end validates every one of these
 * again - see the About Us contract's Validation Rules. This exists so
 * someone finds out about a missing field before they press the button,
 * not so the server can skip checking.
 *
 * Requires formValidation.js to be loaded first (uses
 * MoffatBay.form.isValidEmail), which styles.jsp already pulls in.
 */
var MoffatBay = window.MoffatBay || {};

MoffatBay.aboutUs = (function () {
    "use strict";

    var MESSAGE_LIMIT = 2000;
    /* Turn the counter red for the last tenth, so it warns before it bites. */
    var NEAR_LIMIT = MESSAGE_LIMIT * 0.9;

    var form = document.getElementById("contactForm");
    var messageField = document.getElementById("message");
    var counter = document.getElementById("messageCount");

    /**
     * Puts a message under one field and marks the control invalid.
     * @param {string} fieldId - id of the input, select or textarea
     * @param {string} message - text to show; "" clears it
     */
    function setFieldError(fieldId, message) {
        var field = document.getElementById(fieldId);
        var error = document.getElementById(fieldId + "Error");
        if (field) { field.classList.toggle("field-invalid", message !== ""); }
        if (error) { error.textContent = message; }
    }

    /**
     * Clears every field message on the form.
     */
    function clearErrors() {
        ["firstName", "lastName", "email", "boatName",
         "boatLength", "reasonForContact", "message"]
            .forEach(function (id) { setFieldError(id, ""); });
    }

    /**
     * Reads a field's value with the whitespace taken off, and writes the
     * trimmed value back so what gets submitted is what was checked.
     * @param {string} fieldId - id of the field
     * @returns {string} the trimmed value, or "" if the field is missing
     */
    function trimmedValue(fieldId) {
        var field = document.getElementById(fieldId);
        if (!field) { return ""; }
        field.value = field.value.trim();
        return field.value;
    }

    /**
     * Updates the character count under the message box.
     */
    function updateCounter() {
        if (!messageField || !counter) { return; }
        var used = messageField.value.length;
        counter.textContent = used;
        counter.parentElement.classList.toggle("is-near-limit", used >= NEAR_LIMIT);
    }

    if (messageField && counter) {
        messageField.addEventListener("input", updateCounter);
        /* Run once on load: a rejected submission comes back with the
           message still in the box, and the counter should agree with it. */
        updateCounter();
    }

    if (form) {
        form.addEventListener("submit", function (event) {
            clearErrors();

            var firstName = trimmedValue("firstName");
            var lastName = trimmedValue("lastName");
            var email = trimmedValue("email");
            var boatLength = trimmedValue("boatLength");
            var reason = trimmedValue("reasonForContact");
            var message = trimmedValue("message");

            var firstInvalid = null;

            /**
             * Records a field as invalid, remembering the first one so
             * focus lands where the reader should start.
             * @param {string} fieldId - id of the field
             * @param {string} text - the message to show
             */
            function fail(fieldId, text) {
                setFieldError(fieldId, text);
                if (!firstInvalid) { firstInvalid = fieldId; }
            }

            if (firstName === "") {
                fail("firstName", "Enter your first name.");
            }
            if (lastName === "") {
                fail("lastName", "Enter your last name.");
            }

            if (email === "") {
                fail("email", "Enter your email address.");
            } else if (!MoffatBay.form.isValidEmail(email)) {
                /* Same pattern the server uses, so the two can't disagree
                   about what counts as an address. */
                fail("email", "Enter a valid email address.");
            }

            /* Optional, but if it's filled in it has to be a real length.
               Empty is fine; nonsense is not. */
            if (boatLength !== "") {
                var length = Number(boatLength);
                if (Number.isNaN(length) || length <= 0) {
                    fail("boatLength", "Enter a length in feet, or leave this blank.");
                } else if (length > 9999.9) {
                    fail("boatLength", "That length is longer than any boat we can moor.");
                }
            }

            if (reason === "") {
                fail("reasonForContact", "Choose a reason so we can route your message.");
            }

            if (message === "") {
                fail("message", "Enter your message.");
            } else if (message.length > MESSAGE_LIMIT) {
                fail("message", "Please keep your message under "
                        + MESSAGE_LIMIT + " characters.");
            }

            if (firstInvalid) {
                event.preventDefault();
                var field = document.getElementById(firstInvalid);
                if (field) { field.focus(); }
            }
        });

        /* Typing anywhere clears the messages, so corrected fields stop
           looking wrong before the form is submitted again. */
        form.addEventListener("input", clearErrors);
    }

    return {
        clearErrors: clearErrors
    };
})();
