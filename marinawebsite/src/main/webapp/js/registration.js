/*
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
    var phoneDisplay = document.getElementById("phoneDisplay");
    var phoneHidden = document.getElementById("phone");
    var phoneError = document.getElementById("phoneError");
    var countryCode = document.getElementById("phoneCountryCode");
    var countryCodeError = document.getElementById("phoneCountryCodeError");
    var zipCode = document.getElementById("zipCode");
    var zipError = document.getElementById("zipError");

    var boatCoreIds = ["boatName", "regState", "regNumber", "boatLength"];
    var boatOptionalIds = ["hin", "boatType", "boatBeam", "boatYear"];
    var boatFields = {};
    boatCoreIds.concat(boatOptionalIds).forEach(function (id) {
        boatFields[id] = document.getElementById(id);
    });
    var boatSectionError = document.getElementById("boatSectionError");
    var boatIdNote = document.getElementById("boatIdNote");
    var hinError = document.getElementById("hinError");
    var regNumberError = document.getElementById("regNumberError");
    var boatYearError = document.getElementById("boatYearError");

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

    function hinIsValid() {
        var value = boatFields.hin.value.trim();
        var valid = MoffatBay.form.isValidHIN(value);
        var message = "HIN should be 12 characters: 3 letters, then 9 more letters or numbers.";
        boatFields.hin.setCustomValidity(valid ? "" : message);
        hinError.textContent = (value.length > 0 && !valid) ? message : "";
        return valid;
    }

    function regNumberIsValid() {
        var value = boatFields.regNumber.value.trim();
        var valid = MoffatBay.form.isValidRegNumber(value);
        var message = "Registration Number should be 4 to 7 digits followed by 2 letters, e.g. 1234 AB.";
        boatFields.regNumber.setCustomValidity(valid ? "" : message);
        regNumberError.textContent = (value.length > 0 && !valid) ? message : "";
        return valid;
    }

    function boatYearIsValid() {
        var value = boatFields.boatYear.value.trim();
        var valid = value.length === 0 || MoffatBay.form.isValidBoatYear(value);
        var message = "Enter a 4-digit year, 1800 through " + new Date().getFullYear() + ".";
        boatFields.boatYear.setCustomValidity(valid ? "" : message);
        boatYearError.textContent = (value.length > 0 && !valid) ? message : "";
        return valid;
    }

    // HIN wasn't required (or in some cases didn't exist) on boats
    // built before 1972, so a pre-1972 boat has to be identified by
    // Registration State + Registration Number instead. A 1972-or-
    // later boat can use either the HIN by itself, or Registration
    // State + Registration Number - whichever the owner has handy.
    var HIN_REQUIRED_STARTING_YEAR = 1972;

    function boatIsPre1972() {
        var yearValue = boatFields.boatYear.value.trim();
        return yearValue !== ""
            && MoffatBay.form.isValidBoatYear(yearValue)
            && Number(yearValue) < HIN_REQUIRED_STARTING_YEAR;
    }

    function boatYearKnown() {
        var yearValue = boatFields.boatYear.value.trim();
        return yearValue !== "" && MoffatBay.form.isValidBoatYear(yearValue);
    }

    function identificationSatisfied() {
        var hinFilled = boatFields.hin.value.trim() !== "";
        var regFilled = boatFields.regState.value.trim() !== "" && boatFields.regNumber.value.trim() !== "";

        // Year unknown or pre-1972: HIN alone doesn't count, fall
        // back to requiring Registration State + Number.
        if (!boatYearKnown() || boatIsPre1972()) {
            return regFilled;
        }
        return hinFilled || regFilled;
    }

    function updateBoatIdNote() {
        if (!boatYearKnown()) {
            boatIdNote.textContent = "Enter a Boat Year above to see whether you need the HIN or Registration State & Number.";
        } else if (boatIsPre1972()) {
            boatIdNote.textContent = "Boats built before " + HIN_REQUIRED_STARTING_YEAR + " need Registration State & Number (HIN not required).";
        } else {
            boatIdNote.textContent = "Boats built in " + HIN_REQUIRED_STARTING_YEAR + " or later can use either the HIN or Registration State & Number.";
        }
    }

    // The boat section is entirely optional - skip every field and
    // there's nothing to register. But the moment any one of them
    // is filled in, Boat Name and Boat Length become required,
    // along with whichever identification the boat's year calls
    // for (see identificationSatisfied above), since the Boat
    // table won't accept a half-filled row.
    function boatSectionValid() {
        var anyFilled = boatCoreIds.concat(boatOptionalIds).some(function (id) {
            return boatFields[id].value.trim() !== "";
        });
        if (!anyFilled) {
            boatSectionError.textContent = "";
            return true;
        }

        var nameAndLengthFilled = boatFields.boatName.value.trim() !== ""
            && boatFields.boatLength.value.trim() !== "";
        var valid = nameAndLengthFilled && identificationSatisfied();
        boatSectionError.textContent = valid
            ? ""
            : "Fill in Boat Name, Boat Length, and either the HIN or Registration State & Number (see the note above) to register a boat, or clear all boat fields to skip it.";
        return valid;
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
        var hinValid = hinIsValid();
        var regNumberValid = regNumberIsValid();
        var boatYearValid = boatYearIsValid();
        updateBoatIdNote();
        var boatValid = boatSectionValid();

        confirmError.textContent = (confirmValue.length > 0 && !matches)
            ? "Passwords do not match."
            : "";

        var requiredFieldsFilled = true;
        form.querySelectorAll("[required]").forEach(function (field) {
            if (field.id === "confirmPassword") { return; }
            if (!field.value || field.value.trim() === "") { requiredFieldsFilled = false; }
        });

        submitBtn.disabled = !(
            pwValid && matches && phoneComplete && countryCodeValid && emailValid && zipValid &&
            hinValid && regNumberValid && boatYearValid && boatValid && requiredFieldsFilled
        );
    }

    password.addEventListener("input", updateFormState);
    confirmPassword.addEventListener("input", updateFormState);
    phoneDisplay.addEventListener("input", updateFormState);
    countryCode.addEventListener("input", updateFormState);
    zipCode.addEventListener("input", updateFormState);
    form.addEventListener("input", updateFormState);

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
        if (!form.checkValidity() || submitBtn.disabled) {
            event.preventDefault();
            form.reportValidity();
        }
    });

    document.getElementById("loginLinkTrigger").addEventListener("click", function (event) {
        event.preventDefault();
        MoffatBay.loginModal.open();
    });

    updateFormState();
})();
