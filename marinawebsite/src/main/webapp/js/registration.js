/*
 * Blue Team - Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
 * Primary Author/Owner - Robert Breutzmann
 * src/main/webapp/js/registration.js
 *
 * Client-side validation and form-state wiring for the Registration page.
 * Requires formValidation.js to be loaded first (uses MoffatBay.form.*).
 */
(function () {
    "use strict";

    var form = document.getElementById("registrationForm");
    var email = document.getElementById("email");
    var emailError = document.getElementById("emailError");
    var password = document.getElementById("password");
    var confirmPassword = document.getElementById("confirmPassword");
    var confirmError = document.getElementById("confirmPasswordError");
    var submitBtn = document.getElementById("submitBtn");
    var myFleetSubmitBtn = document.getElementById("myFleetSubmitBtn");
    var phoneDisplay = document.getElementById("phoneDisplay");
    var phoneHidden = document.getElementById("phone");
    var phoneError = document.getElementById("phoneError");
    var countryCode = document.getElementById("phoneCountryCode");
    var countryCodeError = document.getElementById("phoneCountryCodeError");
    var zipCode = document.getElementById("zipCode");
    var zipError = document.getElementById("zipError");
    var country = document.getElementById("country");
    var state = document.getElementById("state");
    var stateLabel = document.getElementById("stateLabel");

    var clearPersonalInfoBtn = document.getElementById("clearPersonalInfo");

    /**
     * The mailing address's State/Province (#state in personalInfoCard.jsp)
     * follows Country: US states, Canadian provinces, or disabled for
     * OTHER. The lists and the swap are shared with Edit User Info in
     * formValidation.js (MoffatBay.form.applyCountryToRegion). See the
     * Registration contract's "Country" section.
     */
    function applyCountryToAddressSection() {
        MoffatBay.form.applyCountryToRegion(country, state, stateLabel);
    }

    function syncPhoneFromDisplay() {
        var digits = MoffatBay.form.extractPhoneDigits(phoneDisplay.value);
        phoneHidden.value = digits;
        phoneDisplay.value = MoffatBay.form.formatPhoneDisplay(digits);

        var complete = digits.length === 10;
        phoneDisplay.setCustomValidity(complete ? "" : "Enter a 10-digit phone number.");
        phoneError.textContent = (digits.length > 0 && !complete)
            ? "Phone number needs all 10 digits."
            : "";
        return complete;
    }

    function countryCodeIsValid() {
        countryCode.value = countryCode.value.replace(/\D/g, "").slice(0, 3);
        var value = countryCode.value;
        var valid = MoffatBay.form.isValidCountryCode(value);
        var message = "Enter a 1 to 3 digit country code (no leading zero).";
        countryCode.setCustomValidity(valid ? "" : message);
        countryCodeError.textContent = (value.length > 0 && !valid) ? message : "";
        return valid;
    }

    // Populate the display field from whatever raw digits came back
    // in the hidden field (e.g. a validation round-trip after a
    // failed submit), rather than starting the display blank.
    phoneDisplay.value = MoffatBay.form.formatPhoneDisplay(MoffatBay.form.extractPhoneDigits(phoneHidden.value));

    // Validity check only - deliberately does not touch emailError's
    // text, so a server-rendered error (e.g. "already registered")
    // survives the initial page-load pass below and only gets
    // replaced once the user actually edits the field (see the
    // dedicated "input" listener further down).
    function emailIsValid() {
        var value = email.value.trim();
        var valid = value.length === 0 || MoffatBay.form.isValidEmail(value);
        email.setCustomValidity(valid ? "" : "Enter a valid email address.");
        return value.length > 0 && valid;
    }

    function zipIsValid() {
        var value = zipCode.value.trim();
        var valid = value.length === 0 || MoffatBay.form.isValidZip(value);
        var message = "Enter a 5-digit ZIP, or ZIP+4 like 12345-6789.";
        zipCode.setCustomValidity(valid ? "" : message);
        zipError.textContent = (value.length > 0 && !valid) ? message : "";
        return value.length > 0 && valid;
    }


    function updateFormState() {
        var pwValue = password.value;
        var confirmValue = confirmPassword.value;
        var pwValid = MoffatBay.passwordRules.check(pwValue);
        var matches = confirmValue.length > 0 && pwValue === confirmValue;
        var phoneComplete = syncPhoneFromDisplay();
        var countryCodeValid = countryCodeIsValid();
        var emailValid = emailIsValid();
        var zipValid = zipIsValid();

        confirmError.textContent = (confirmValue.length > 0 && !matches)
            ? "Passwords do not match."
            : "";

        var requiredFieldsFilled = true;
        form.querySelectorAll("[required]").forEach(function (field) {
            if (field.id === "confirmPassword" || field.disabled) { return; }
            if (!field.value || field.value.trim() === "") { requiredFieldsFilled = false; }
        });

        var formValid = (
            pwValid && matches && phoneComplete && countryCodeValid && emailValid && zipValid &&
            requiredFieldsFilled
        );

        submitBtn.disabled = !formValid;
        myFleetSubmitBtn.disabled = !formValid; 
    }

    // Formatting as you type, and Backspace over a bracket or dash - shared
    // with Your Account (formValidation.js).
    MoffatBay.form.bindPhoneDisplay(phoneDisplay, phoneHidden, updateFormState);

    password.addEventListener("input", updateFormState);
    confirmPassword.addEventListener("input", updateFormState);
    countryCode.addEventListener("input", updateFormState);
    zipCode.addEventListener("input", updateFormState);
    form.addEventListener("input", updateFormState);

    // Country controls the mailing address State/Province label,
    // option list, and disabled state.
    country.addEventListener("change", function () {
        applyCountryToAddressSection();
        updateFormState();
    });

    var PERSONAL_INFO_TEXT_IDS = [
        "firstName", "lastName", "streetAddress", "streetAddress2", "city", "state", "zipCode"
    ];

    clearPersonalInfoBtn.addEventListener("click", function () {
        PERSONAL_INFO_TEXT_IDS.forEach(function (id) {
            var field = document.getElementById(id);
            field.value = "";
            field.setCustomValidity("");
        });
        countryCode.value = "1";
        phoneDisplay.value = "";
        phoneHidden.value = "";
        country.value = "US";
        applyCountryToAddressSection();
        updateFormState();
    });

    // Only takes over the emailError text once the user actually
    // edits the field - keeps a server-rendered error (e.g.
    // "already registered") visible until then.
    email.addEventListener("input", function () {
        var value = email.value.trim();
        var valid = value.length === 0 || MoffatBay.form.isValidEmail(value);
        emailError.textContent = (value.length > 0 && !valid) ? "Enter a valid email address." : "";
        updateFormState();
    });

    form.addEventListener("submit", function (event) {
    if (!form.checkValidity()) {
        event.preventDefault();
        form.reportValidity();
    }
    });

    // Signing in from here goes where registering would have: the page
    // the customer came to register from, or the home page - never back
    // to this form, which is no use to someone who's signed in.
    document.getElementById("loginLinkTrigger").addEventListener("click", function (event) {
        event.preventDefault();
        var back = form.elements.redirectTo && form.elements.redirectTo.value;
        MoffatBay.loginModal.open(back || "/");
    });


    applyCountryToAddressSection();
    updateFormState();
})();
