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
    var country = document.getElementById("country");
    var state = document.getElementById("state");
    var stateLabel = document.getElementById("stateLabel");

    var boatCoreIds = ["boatName", "regState", "regNumber", "boatLength"];
    var boatOptionalIds = ["hin", "boatType", "boatBeam", "boatYear"];
    var boatFields = {};
    boatCoreIds.concat(boatOptionalIds).forEach(function (id) {
        boatFields[id] = document.getElementById(id);
    });
    var boatSectionError = document.getElementById("boatSectionError");
    var identificationNote = document.getElementById("identificationNote");
    var foreignRegistrationBadge = document.getElementById("foreignRegistrationBadge");
    var regStateLabel = document.getElementById("regStateLabel");
    var hinError = document.getElementById("hinError");
    var regNumberError = document.getElementById("regNumberError");
    var boatYearError = document.getElementById("boatYearError");
    var clearBoatInfoBtn = document.getElementById("clearBoatInfo");
    var clearPersonalInfoBtn = document.getElementById("clearPersonalInfo");

    /*
     * Registration State/Province's option list swaps with Country
     * without a page reload - boatInfoCard.jsp renders the right list
     * server-side on first load/round-trip, this just mirrors the same
     * two option sets (see includes/stateOptions.jsp and
     * includes/provinceOptions.jsp) so the swap can happen client-side.
     */
    var US_STATES = [
        ["AL", "Alabama"], ["AK", "Alaska"], ["AZ", "Arizona"], ["AR", "Arkansas"],
        ["CA", "California"], ["CO", "Colorado"], ["CT", "Connecticut"], ["DE", "Delaware"],
        ["DC", "District of Columbia"], ["FL", "Florida"], ["GA", "Georgia"], ["HI", "Hawaii"],
        ["ID", "Idaho"], ["IL", "Illinois"], ["IN", "Indiana"], ["IA", "Iowa"],
        ["KS", "Kansas"], ["KY", "Kentucky"], ["LA", "Louisiana"], ["ME", "Maine"],
        ["MD", "Maryland"], ["MA", "Massachusetts"], ["MI", "Michigan"], ["MN", "Minnesota"],
        ["MS", "Mississippi"], ["MO", "Missouri"], ["MT", "Montana"], ["NE", "Nebraska"],
        ["NV", "Nevada"], ["NH", "New Hampshire"], ["NJ", "New Jersey"], ["NM", "New Mexico"],
        ["NY", "New York"], ["NC", "North Carolina"], ["ND", "North Dakota"], ["OH", "Ohio"],
        ["OK", "Oklahoma"], ["OR", "Oregon"], ["PA", "Pennsylvania"], ["RI", "Rhode Island"],
        ["SC", "South Carolina"], ["SD", "South Dakota"], ["TN", "Tennessee"], ["TX", "Texas"],
        ["UT", "Utah"], ["VT", "Vermont"], ["VA", "Virginia"], ["WA", "Washington"],
        ["WV", "West Virginia"], ["WI", "Wisconsin"], ["WY", "Wyoming"]
    ];

    var CA_PROVINCES = [
        ["AB", "Alberta"], ["BC", "British Columbia"], ["MB", "Manitoba"],
        ["NB", "New Brunswick"], ["NL", "Newfoundland and Labrador"], ["NS", "Nova Scotia"],
        ["NT", "Northwest Territories"], ["NU", "Nunavut"], ["ON", "Ontario"],
        ["PE", "Prince Edward Island"], ["QC", "Quebec"], ["SK", "Saskatchewan"], ["YT", "Yukon"]
    ];

    /**
     * Rebuilds the Registration State/Province <select>'s options, its
     * label text, and its (and Registration Number's) disabled state to
     * match the given country - "US" (states), "CA" (provinces), or
     * "OTHER" (disabled, nothing applies). Keeps a previously selected
     * value selected if it still exists in the new option list.
     */
    function applyCountryToBoatSection() {
        var value = country.value;
        var regState = boatFields.regState;
        var previousValue = regState.value;

        if (value === "CA") {
            regStateLabel.textContent = "Registration Province";
            regState.disabled = false;
            boatFields.regNumber.disabled = false;
            boatFields.regNumber.placeholder = "e.g. C1234 AB";
            rebuildRegionOptions(regState, CA_PROVINCES, previousValue);
        } else if (value === "OTHER") {
            regStateLabel.textContent = "Registration State";
            regState.disabled = true;
            boatFields.regNumber.disabled = true;
            rebuildRegionOptions(regState, [], previousValue);
        } else {
            regStateLabel.textContent = "Registration State";
            regState.disabled = false;
            boatFields.regNumber.disabled = false;
            boatFields.regNumber.placeholder = "e.g. 0007 JS";
            rebuildRegionOptions(regState, US_STATES, previousValue);
        }

        foreignRegistrationBadge.hidden = value !== "OTHER";
    }

    /**
     * Mirrors applyCountryToBoatSection, but for the mailing address's
     * own State/Province field (#state in personalInfoCard.jsp) instead
     * of Boat Registration's - same three-way swap (US states / CA
     * provinces / disabled "not applicable" for OTHER), just without a
     * Registration Number or badge to go with it. See the Registration
     * contract's "Country" section.
     */
    function applyCountryToAddressSection() {
        var value = country.value;
        var previousValue = state.value;

        if (value === "CA") {
            stateLabel.textContent = "Province";
            state.disabled = false;
            rebuildRegionOptions(state, CA_PROVINCES, previousValue);
        } else if (value === "OTHER") {
            stateLabel.textContent = "State";
            state.disabled = true;
            rebuildRegionOptions(state, [], previousValue);
        } else {
            stateLabel.textContent = "State";
            state.disabled = false;
            rebuildRegionOptions(state, US_STATES, previousValue);
        }
    }

    /**
     * Replaces select's <option> children with the given [value, label]
     * pairs (plus a disabled placeholder), keeping previousValue selected
     * if it's still one of the options.
     */
    function rebuildRegionOptions(select, regions, previousValue) {
        select.innerHTML = "";

        var stillValid = regions.some(function (region) { return region[0] === previousValue; });

        var placeholder = document.createElement("option");
        placeholder.value = "";
        placeholder.disabled = true;
        placeholder.textContent = regions.length === 0 ? "Not applicable" : "Select…";
        placeholder.selected = !stillValid;
        select.appendChild(placeholder);

        regions.forEach(function (region) {
            var option = document.createElement("option");
            option.value = region[0];
            option.textContent = region[1];
            option.selected = region[0] === previousValue;
            select.appendChild(option);
        });
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
        var valid = MoffatBay.form.isValidRegNumber(value, country.value);
        var message = country.value === "CA"
            ? "Registration Number should be a C followed by 4 to 8 digits then 2 letters, e.g. C1234 AB."
            : "Registration Number should be 4 to 7 digits followed by 2 letters, e.g. 1234 AB.";
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

    // HIN is the primary/default way to identify a boat, Registration
    // State + Number is the fallback - but as of the Registration
    // contract's HIN-first rework, neither is ever required to submit.
    // #identificationNote just tells an owner who has neither that they
    // can call the Marina, instead of blocking the form.
    function identificationMissing() {
        var hinFilled = boatFields.hin.value.trim() !== "";
        var regFilled = boatFields.regState.value.trim() !== "" && boatFields.regNumber.value.trim() !== "";
        return !hinFilled && !regFilled;
    }

    function boatSectionTouched() {
        return boatCoreIds.concat(boatOptionalIds).some(function (id) {
            return boatFields[id].value.trim() !== "";
        });
    }

    function updateIdentificationNote() {
        identificationNote.hidden = !(boatSectionTouched() && identificationMissing());
    }

    // The boat section is entirely optional - skip every field and
    // there's nothing to register. But the moment any one of them is
    // filled in, Boat Name and Boat Length become required, since the
    // Boat table won't accept a half-filled row. Identification is never
    // required - see updateIdentificationNote above.
    function boatSectionValid() {
        if (!boatSectionTouched()) {
            boatSectionError.textContent = "";
            return true;
        }

        var valid = boatFields.boatName.value.trim() !== ""
            && boatFields.boatLength.value.trim() !== "";
        boatSectionError.textContent = valid
            ? ""
            : "Fill in Boat Name and Boat Length to register a boat, or use Clear Boat Info to skip it.";
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
        updateIdentificationNote();
        var boatValid = boatSectionValid();

        confirmError.textContent = (confirmValue.length > 0 && !matches)
            ? "Passwords do not match."
            : "";

        var requiredFieldsFilled = true;
        form.querySelectorAll("[required]").forEach(function (field) {
            if (field.id === "confirmPassword" || field.disabled) { return; }
            if (!field.value || field.value.trim() === "") { requiredFieldsFilled = false; }
        });

        submitBtn.disabled = !(
            pwValid && matches && phoneComplete && countryCodeValid && emailValid && zipValid &&
            hinValid && regNumberValid && boatYearValid && boatValid && requiredFieldsFilled
        );
    }

    // Backspacing onto a formatting character (e.g. the ")" in "(319)")
    // would otherwise be swallowed: extractPhoneDigits strips it right
    // back out, so formatPhoneDisplay re-renders the same digits and
    // the field looks stuck. Detect that case and remove the digit
    // before the formatting character instead.
    phoneDisplay.addEventListener("keydown", function (event) {
        if (event.key !== "Backspace" || phoneDisplay.selectionStart !== phoneDisplay.selectionEnd) {
            return;
        }
        var pos = phoneDisplay.selectionStart;
        if (pos === 0 || !/\D/.test(phoneDisplay.value.charAt(pos - 1))) {
            return;
        }
        event.preventDefault();
        var beforeDigits = MoffatBay.form.extractPhoneDigits(phoneDisplay.value.slice(0, pos)).slice(0, -1);
        var afterDigits = MoffatBay.form.extractPhoneDigits(phoneDisplay.value.slice(pos));
        phoneDisplay.value = MoffatBay.form.formatPhoneDisplay(beforeDigits + afterDigits);
        var newPos = MoffatBay.form.formatPhoneDisplay(beforeDigits).length;
        phoneDisplay.setSelectionRange(newPos, newPos);
        updateFormState();
    });

    password.addEventListener("input", updateFormState);
    confirmPassword.addEventListener("input", updateFormState);
    phoneDisplay.addEventListener("input", updateFormState);
    countryCode.addEventListener("input", updateFormState);
    zipCode.addEventListener("input", updateFormState);
    form.addEventListener("input", updateFormState);

    // Country drives Registration State/Province's label, option list,
    // and disabled state over in boatInfoCard.jsp, plus the mailing
    // address's own State/Province field right below it here - see
    // applyCountryToBoatSection / applyCountryToAddressSection above and
    // the Registration contract's "Country" and "Boat Fields" sections.
    country.addEventListener("change", function () {
        applyCountryToBoatSection();
        applyCountryToAddressSection();
        updateFormState();
    });

    // Lets someone who started the (entirely optional) Boat Info card
    // and doesn't have identification handy - or changes their mind -
    // drop it in one click instead of fighting the Boat Name/Length
    // requirement with a half-filled card.
    clearBoatInfoBtn.addEventListener("click", function () {
        boatCoreIds.concat(boatOptionalIds).forEach(function (id) {
            boatFields[id].value = "";
            boatFields[id].setCustomValidity("");
        });
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
        applyCountryToBoatSection();
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
        if (!form.checkValidity() || submitBtn.disabled) {
            event.preventDefault();
            form.reportValidity();
        }
    });

    document.getElementById("loginLinkTrigger").addEventListener("click", function (event) {
        event.preventDefault();
        MoffatBay.loginModal.open();
    });

    applyCountryToBoatSection();
    applyCountryToAddressSection();
    updateFormState();
})();
