/*
 * src/main/webapp/js/editUserInfo.js
 * Author: Miguel Fernandez
 * Blue Team - Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
 * Primary Author/Owner - Miguel Fernandez
 * CSD 460 - Capstone Project - Marina Website Project
 *
 * Behaviour for the Edit User Info form, per the Edit User Profile
 * contract's "Partial Update" section.
 *
 * The one thing this file exists for: only fields the customer actually
 * changed are submitted. EditProfileServlet reads a key's absence as
 * "untouched" and a key present-but-empty as "clear this column", so what
 * is and isn't in the POST body is load-bearing, not a nicety - sending
 * every field on every save would make "didn't touch it" and "set it to
 * what it already was" indistinguishable, and would defeat the dynamic
 * UPDATE the DAO builds.
 *
 * None of this is trusted. The servlet re-checks every value it receives -
 * see the contract's Validation Rules.
 *
 * Requires formValidation.js first (MoffatBay.form.*), which
 * includes/loginModal.jsp already loads on every page.
 */
var MoffatBay = window.MoffatBay || {};

MoffatBay.editUserInfo = (function () {
    "use strict";

    var form = document.getElementById("editProfileForm");
    if (!form) { return {}; }

    var saveButton = document.getElementById("saveChanges");
    var saveHint = document.getElementById("saveHint");

    /*
     * Every Customer column this page can write. Order matters only for
     * which field gets focus first on a client-side rejection.
     */
    var FIELDS = [
        "firstName", "lastName", "email", "phoneCountryCode", "phone",
        "streetAddress", "streetAddress2", "city", "state", "zipCode", "country"
    ];

    /* Fields the customer may not blank out. Mirrors
       EditProfileServlet.REQUIRED_FIELDS - state is deliberately absent,
       since it's only required when the country has states. */
    var REQUIRED = [
        "firstName", "lastName", "email", "phoneCountryCode", "phone",
        "streetAddress", "city", "zipCode", "country"
    ];

    /*
     * zipCode's error box is #zipError, not #zipCodeError - inherited from
     * Registration, where registration.js already depends on that exact id.
     * Renaming it there to be consistent would break that page, so the odd
     * one out gets mapped here instead.
     */
    var ERROR_ELEMENT_IDS = { zipCode: "zipError" };

    /* The value each field held when the page loaded, which is what's
       actually on file. Everything else is measured against this. */
    var initialValues = {};

    /*
     * And how each of those values READ at that moment - "Washington", not
     * "WA". Captured rather than looked up later, because a select can't
     * always be asked afterwards: switching country rebuilds the
     * state/province list, and Washington stops being one of the options at
     * all. Without this the confirmation panel has no way to name the value
     * it is about to overwrite.
     */
    var initialLabels = {};

    /**
     * The control carrying a field's submitted value. Phone is the odd one:
     * the visible box is #phoneDisplay (formatted, unnamed) and the value
     * that travels is in the hidden #phone.
     * @param {string} field - a name from FIELDS
     * @returns {Element|null} the input or select, or null if absent
     */
    function control(field) {
        return document.getElementById(field);
    }

    /**
     * The box a message for this field belongs in.
     * @param {string} field - a name from FIELDS
     * @returns {Element|null}
     */
    function errorElement(field) {
        return document.getElementById(ERROR_ELEMENT_IDS[field] || (field + "Error"));
    }

    /**
     * Puts a message under one field and marks the control invalid.
     * @param {string} field - a name from FIELDS
     * @param {string} message - text to show; "" clears it
     */
    function setFieldError(field, message) {
        var el = control(field);
        var box = errorElement(field);
        if (el) { el.classList.toggle("field-invalid", message !== ""); }
        if (box) { box.textContent = message; }
    }

    /**
     * Clears every field message on the form.
     */
    function clearErrors() {
        FIELDS.forEach(function (field) { setFieldError(field, ""); });
    }

    /**
     * A field's current value, trimmed. Reads the hidden #phone rather than
     * the formatted display, so what's compared is what would be sent.
     * @param {string} field - a name from FIELDS
     * @returns {string} the value, or "" if the field isn't on the page
     */
    function currentValue(field) {
        var el = control(field);
        return el ? el.value.trim() : "";
    }

    /**
     * Whether this field differs from what's on file. Comparison is
     * normalized the same way EditProfileServlet normalizes before it
     * builds its own diff - email lowercased, state and country uppercased -
     * so retyping an address in a different case isn't mistaken for an edit
     * and doesn't enable the Save button on its own.
     * @param {string} field - a name from FIELDS
     * @returns {boolean} true if the value has actually changed
     */
    function hasChanged(field) {
        var before = initialValues[field] || "";
        var after = currentValue(field);
        if (field === "email") {
            return before.toLowerCase() !== after.toLowerCase();
        }
        if (field === "state" || field === "country") {
            return before.toUpperCase() !== after.toUpperCase();
        }
        return before !== after;
    }

    /**
     * Every field that currently differs from what's on file.
     * @returns {string[]} field names, in FIELDS order
     */
    function changedFields() {
        return FIELDS.filter(hasChanged);
    }

    /*
     * What each field is called in the confirmation panel. Field names are
     * the Customer column names, which is right for the wire and wrong for
     * a person reading "streetAddress2" back to themselves.
     */
    var FIELD_LABELS = {
        firstName: "First name",
        lastName: "Last name",
        email: "Email",
        phoneCountryCode: "Country code",
        phone: "Phone",
        streetAddress: "Street address",
        streetAddress2: "Address line 2",
        city: "City",
        state: "State/Province",
        zipCode: "ZIP code",
        country: "Country"
    };

    /**
     * How a field's CURRENT value reads - "Washington" rather than "WA",
     * the formatted phone rather than ten bare digits. What gets submitted
     * is still the raw value; this is only for showing a person what they
     * are about to change.
     * @param {string} field - a name from FIELDS
     * @returns {string} the current value as the customer would recognise it
     */
    function currentLabel(field) {
        var el = control(field);
        if (!el || el.value === "") { return ""; }
        if (el.tagName === "SELECT") {
            return el.selectedOptions.length
                ? el.selectedOptions[0].textContent.trim()
                : el.value;
        }
        if (field === "phone") {
            return MoffatBay.form.formatPhoneDisplay(el.value);
        }
        return el.value.trim();
    }

    /**
     * Fills the confirmation panel with one row per changed field, old on
     * the left and new on the right, and shows it in place of the Save
     * button.
     *
     * Built from the form as it stands at this moment rather than from
     * anything captured earlier, so what is listed here and what gets
     * submitted cannot drift apart.
     *
     * @param {string[]} changed - the fields about to be saved
     */
    function showConfirmation(changed) {
        var panel = document.getElementById("confirmChanges");
        var list = document.getElementById("confirmChangesList");
        var row = document.getElementById("accountSubmitRow");
        if (!panel || !list) { return; }

        list.textContent = "";

        changed.forEach(function (field) {
            var wrapper = document.createElement("div");
            wrapper.className = "change-summary__row";

            var term = document.createElement("dt");
            term.textContent = FIELD_LABELS[field] || field;

            var detail = document.createElement("dd");

            var before = document.createElement("span");
            before.className = "change-summary__old";
            var beforeText = initialLabels[field] || "";
            if (beforeText === "") {
                before.innerHTML = "<em>empty</em>";
            } else {
                before.textContent = beforeText;
            }

            var arrow = document.createElement("span");
            arrow.className = "change-summary__arrow";
            arrow.textContent = "\u2192";
            arrow.setAttribute("aria-label", "changing to");

            var after = document.createElement("span");
            after.className = "change-summary__new";
            var afterText = currentLabel(field);
            if (afterText === "") {
                after.innerHTML = "<em>empty</em>";
            } else {
                after.textContent = afterText;
            }

            detail.appendChild(before);
            detail.appendChild(arrow);
            detail.appendChild(after);
            wrapper.appendChild(term);
            wrapper.appendChild(detail);
            list.appendChild(wrapper);
        });

        if (row) { row.hidden = true; }
        panel.hidden = false;
        document.getElementById("confirmSave").focus();
    }

    /**
     * Puts the Save button back and hides the confirmation panel, leaving
     * every field exactly as it was - "Go back" is a return to editing, not
     * an undo.
     */
    function hideConfirmation() {
        var panel = document.getElementById("confirmChanges");
        var row = document.getElementById("accountSubmitRow");
        if (panel) { panel.hidden = true; }
        if (row) { row.hidden = false; }
    }

    /**
     * Enables Save only when there's something to save, and marks the
     * edited fields so a change is visible before anything is submitted.
     */
    function refreshFormState() {
        var changed = changedFields();

        FIELDS.forEach(function (field) {
            var el = control(field);
            if (!el) { return; }
            /* Phone's visible box is the one to highlight, not the hidden
               input nobody can see. */
            var visible = field === "phone"
                ? (document.getElementById("phoneDisplay") || el)
                : el;
            visible.classList.toggle("is-changed", changed.indexOf(field) !== -1);
        });

        if (saveButton) { saveButton.disabled = changed.length === 0; }
        if (saveHint) {
            saveHint.textContent = changed.length === 0
                ? "Nothing changed yet."
                : (changed.length === 1
                    ? "1 field will be saved."
                    : changed.length + " fields will be saved.");
        }
    }

    /**
     * Client-side checks, mirroring what EditProfileServlet enforces. Only
     * ever runs against changed fields - an untouched field is already on
     * file and is none of this form's business.
     * @param {string[]} changed - field names being submitted
     * @returns {string|null} the first field that failed, or null if all pass
     */
    function firstInvalid(changed) {
        var firstBad = null;

        /**
         * @param {string} field - the field to mark
         * @param {string} message - what to show under it
         */
        function fail(field, message) {
            setFieldError(field, message);
            if (!firstBad) { firstBad = field; }
        }

        changed.forEach(function (field) {
            var value = currentValue(field);

            if (value === "" && REQUIRED.indexOf(field) !== -1) {
                fail(field, "This can't be empty.");
                return;
            }
            if (value === "") { return; }

            if (field === "email" && !MoffatBay.form.isValidEmail(value)) {
                fail(field, "Enter a valid email address.");
            }
            if (field === "phone"
                    && MoffatBay.form.extractPhoneDigits(value).length !== 10) {
                fail(field, "Phone number must contain exactly 10 digits.");
            }
            if (field === "phoneCountryCode"
                    && !MoffatBay.form.isValidCountryCode(value)) {
                fail(field, "Enter a valid country code.");
            }
            if (field === "zipCode" && !MoffatBay.form.isValidZip(value)) {
                fail(field, "Enter a valid ZIP code.");
            }
        });

        /* State is required whenever the country has states at all, checked
           against the country this save will end up with - the same rule
           EditProfileServlet applies. Deliberately not conditional on
           country having changed: going US -> Other -> US leaves country
           back at its original value, so it counts as untouched, while the
           list rebuild has left state blank. That combination still has to
           be caught. */
        var country = currentValue("country").toUpperCase();
        if (country !== "OTHER" && currentValue("state") === ""
                && changed.indexOf("state") !== -1) {
            fail("state", "Choose a state or province.");
        }

        return firstBad;
    }

    /**
     * Moves the messages EditProfileServlet set into the box beside each
     * field. They're rendered into a hidden block on the page rather than
     * into a script literal, so a message can never arrive as markup.
     */
    function applyServerErrors() {
        var source = document.getElementById("serverFieldErrors");
        if (!source) { return; }
        source.querySelectorAll(".js-field-error").forEach(function (item) {
            setFieldError(item.dataset.field, item.textContent);
        });
    }

    /**
     * Records what every field held on load, so "changed" always means
     * changed from what's actually on file - not from whatever it held a
     * keystroke ago.
     */
    function captureInitialValues() {
        FIELDS.forEach(function (field) {
            initialValues[field] = currentValue(field);
            initialLabels[field] = currentLabel(field);
        });
    }

    /**
     * personalInfoCard.jsp leaves the visible phone box empty and keeps the
     * real digits in the hidden #phone, because Registration starts blank
     * and registration.js fills the display in as someone types. Here the
     * number is already on file, so without this the customer sees an empty
     * phone field sitting over a hidden value - and blanking a field they
     * never touched would read as clearing their phone number.
     */
    function primePhoneDisplay() {
        var hidden = document.getElementById("phone");
        var display = document.getElementById("phoneDisplay");
        if (!hidden || !display) { return; }
        var digits = MoffatBay.form.extractPhoneDigits(hidden.value);
        hidden.value = digits;
        display.value = MoffatBay.form.formatPhoneDisplay(digits);
    }

    /**
     * Keeps the hidden #phone in step with whatever is typed in the visible
     * box, and reformats as it goes.
     */
    function bindPhone() {
        var hidden = document.getElementById("phone");
        var display = document.getElementById("phoneDisplay");
        if (!hidden || !display) { return; }

        display.addEventListener("input", function () {
            var digits = MoffatBay.form.extractPhoneDigits(display.value);
            hidden.value = digits;
            display.value = MoffatBay.form.formatPhoneDisplay(digits);
            refreshFormState();
        });
    }

    /**
     * Registration's "Clear Personal Info" button empties the whole card.
     * That's right on a blank form and wrong here: clearing every field
     * marks them all changed and blank, which the servlet rejects outright
     * as a structural error rather than as a correctable mistake. The card
     * has no parameter to suppress it, so it comes out on this page.
     */
    function removeClearButton() {
        var clear = document.getElementById("clearPersonalInfo");
        if (clear) { clear.remove(); }
    }

    /**
     * Country drives which region list applies, and whether one applies at
     * all - the control is disabled outright for OTHER, and a disabled
     * control submits nothing, not even an empty value.
     *
     * The swap itself is shared with Registration
     * (MoffatBay.form.applyCountryToRegion) rather than repeated here.
     * personalInfoCard.jsp renders the right list server-side on first
     * load, so this only matters once someone changes country on the page -
     * without it, choosing Canada would leave US states listed and choosing
     * Other would leave the control live.
     *
     * Going to OTHER, the servlet clears state itself when it sees country
     * becoming OTHER. Coming back from it is the case that needs care:
     * nothing would be submitted for state, so the save would land a
     * country that has states with no state in it and raise no error. The
     * rebuilt list comes back with nothing selected, which makes state
     * count as changed, so it travels with the submission and the
     * client-side check below refuses a blank one.
     */
    function bindCountry() {
        var country = document.getElementById("country");
        var state = document.getElementById("state");
        var stateLabel = document.getElementById("stateLabel");
        if (!country || !state) { return; }

        country.addEventListener("change", function () {
            MoffatBay.form.applyCountryToRegion(country, state, stateLabel);
            refreshFormState();
        });
    }

    /**
     * Builds the POST body by hand from the changed fields and submits
     * that, instead of letting the browser serialize the form.
     *
     * The form itself can't be trusted to serialize correctly here. Only
     * changed fields may appear in the body - that's how
     * EditProfileServlet tells "leave this alone" from "clear this" - and
     * the obvious way to arrange that, stripping the name off every
     * untouched control just before submitting, turned out to depend on
     * exactly when the browser reads the form back. It also can't send a
     * disabled control at all, which is a problem the moment state needs
     * to travel after a country switch.
     *
     * So the body is assembled here and posted through a throwaway form:
     * every changed field, by name, with the value read straight off its
     * control - disabled or not. What goes over the wire is then exactly
     * what this function decided, with nothing in between.
     *
     * @param {string[]} changed - the fields to send
     */
    function submitOnlyChanged(changed) {
        var carrier = document.createElement("form");
        carrier.method = "post";
        carrier.action = form.action;
        carrier.style.display = "none";

        changed.forEach(function (field) {
            var input = document.createElement("input");
            input.type = "hidden";
            input.name = field;
            input.value = currentValue(field);
            carrier.appendChild(input);
        });

        document.body.appendChild(carrier);
        carrier.submit();
    }

    removeClearButton();
    primePhoneDisplay();
    captureInitialValues();
    applyServerErrors();
    bindPhone();
    bindCountry();
    refreshFormState();

    form.addEventListener("input", function () {
        clearErrors();
        refreshFormState();
    });
    form.addEventListener("change", refreshFormState);

    form.addEventListener("submit", function (event) {
        clearErrors();

        var changed = changedFields();
        if (changed.length === 0) {
            /* The button is disabled in this state, so getting here means
               Enter was pressed in a text field. Nothing to save. */
            event.preventDefault();
            return;
        }

        var bad = firstInvalid(changed);
        if (bad) {
            event.preventDefault();
            var el = control(bad);
            if (el) { el.focus(); }
            return;
        }

        /* The real form never navigates. Saving happens from the
           confirmation panel below, which posts a form built for the
           purpose - see submitOnlyChanged. */
        event.preventDefault();
        showConfirmation(changed);
    });

    var confirmButton = document.getElementById("confirmSave");
    if (confirmButton) {
        confirmButton.addEventListener("click", function () {
            /* Re-read rather than trusting the list that was drawn: nothing
               can change behind the panel, but the submitted set should
               come from the form either way. */
            submitOnlyChanged(changedFields());
        });
    }

    var cancelButton = document.getElementById("cancelSave");
    if (cancelButton) {
        cancelButton.addEventListener("click", hideConfirmation);
    }

    /* Editing anything while the panel is up means the list behind it is
       already out of date, so it steps aside and the customer confirms
       again. */
    form.addEventListener("input", hideConfirmation);

    return {
        changedFields: changedFields,
        refreshFormState: refreshFormState
    };
})();
