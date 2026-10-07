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
 * WEB-INF/includes/loginModal.jsp already loads on every page, and
 * editTracker.js (the change tracking shared with My Fleet), which
 * editUserInfo.jsp loads just before this file.
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

    var control = MoffatBay.editTracker.control;

    /* A field's current value, trimmed. Reads the hidden #phone rather than
       the formatted display, so what's compared is what would be sent. */
    var currentValue = MoffatBay.editTracker.valueOf;

    /*
     * What's on file, and which fields now differ from it (editTracker.js,
     * shared with My Fleet). Compared the way EditProfileServlet normalizes
     * before it builds its own diff - email lowercased, state and country
     * uppercased - so retyping an address in a different case isn't mistaken
     * for an edit and doesn't enable Save on its own. A disabled field still
     * counts: State is disabled for country OTHER and still has to travel.
     */
    var tracker = MoffatBay.editTracker.create({
        fields: FIELDS,
        same: function (field, before, after) {
            if (field === "email") {
                return before.toLowerCase() === after.toLowerCase();
            }
            if (field === "state" || field === "country") {
                return before.toUpperCase() === after.toUpperCase();
            }
            return before === after;
        },
        describe: currentLabel
    });
    var changedFields = tracker.changedFields;

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
        MoffatBay.form.setFieldError(control(field), errorElement(field), message);
    }

    /**
     * Clears every field message on the form.
     */
    function clearErrors() {
        FIELDS.forEach(function (field) { setFieldError(field, ""); });
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
     * Fills the confirmation popup with one row per changed field, old on
     * the left and new on the right (editTracker.js), and opens it
     * (modal.js).
     *
     * @param {string[]} changed - the fields about to be saved
     */
    function showConfirmation(changed) {
        var modal = document.getElementById("confirmChangesModal");
        var list = document.getElementById("confirmChangesList");
        if (!modal || !list) { return; }

        tracker.fillConfirmation(list, changed, FIELD_LABELS);

        document.getElementById("confirmSave").disabled = false;
        MoffatBay.modal.open(modal);
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
        tracker.snapshot();
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
     * box, and reformats as it goes - the same wiring as Registration
     * (formValidation.js), including Backspace over the area code's ")".
     */
    function bindPhone() {
        var hidden = document.getElementById("phone");
        var display = document.getElementById("phoneDisplay");
        if (!hidden || !display) { return; }

        MoffatBay.form.bindPhoneDisplay(display, hidden, refreshFormState);
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
     * Posts only the changed fields (editTracker.js explains why the body
     * is built by hand rather than by the browser).
     * @param {string[]} changed - the fields to send
     */
    function submitOnlyChanged(changed) {
        tracker.submitOnlyChanged(form.action, changed);
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
           confirmation popup, which posts a form built for the
           purpose - see submitOnlyChanged. */
        event.preventDefault();
        showConfirmation(changed);
    });

    var confirmButton = document.getElementById("confirmSave");
    if (confirmButton) {
        confirmButton.addEventListener("click", function () {
            /* One click, one save. Re-read rather than trusting the list
               that was drawn: nothing can change behind the popup, but the
               submitted set should come from the form either way. Keep Editing,
               the x, the backdrop and Escape all just close the popup
               (modal.js), leaving every field as it was. */
            confirmButton.disabled = true;
            submitOnlyChanged(changedFields());
        });
    }

    /* The two password links under the form. Their popups belong to
       accountModals.js, loaded earlier through the header. */
    var changeLink = document.getElementById("openChangePassword");
    if (changeLink) {
        changeLink.addEventListener("click", MoffatBay.accountModals.openChange);
    }

    var forgotLink = document.getElementById("openForgotPassword");
    if (forgotLink) {
        forgotLink.addEventListener("click", function (event) {
            event.preventDefault();
            /* Pre-filled from the form's own email box, which holds
               what's on file unless it's just been edited. */
            var email = document.getElementById("email");
            MoffatBay.accountModals.openForgot(email ? email.value : "");
        });
    }

    /* Delete my account (issue #337). The popup's form is a plain POST to
       AccountDeleteServlet; all this does is open it. When the servlet
       refuses (wrong password, a lease still running) it renders this
       page again with the popup marked data-open-on-load and the reason
       inside, so the customer lands back where they were. */
    var deleteModal = document.getElementById("deleteAccountModal");
    var deleteButton = document.getElementById("openDeleteAccount");
    if (deleteModal && deleteButton) {
        deleteButton.addEventListener("click", function () {
            var banner = document.getElementById("deleteAccountError");
            if (banner) { banner.hidden = true; }
            MoffatBay.modal.open(deleteModal);
        });
        if (deleteModal.hasAttribute("data-open-on-load")) {
            MoffatBay.modal.open(deleteModal);
        }
    }

    return {
        changedFields: changedFields,
        refreshFormState: refreshFormState
    };
})();
