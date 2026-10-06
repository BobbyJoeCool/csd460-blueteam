/*
 * src/main/webapp/js/myFleet.js
 * Author: Robert Breutzmann
 * Blue Team - Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
 * CSD 460 - Capstone Project - Marina Website Project
 *
 * Behaviour for My Fleet: one modal that both adds and edits a boat, and a
 * second one that confirms a removal.
 *
 * Two things this file exists for.
 *
 * The first is the same rule Edit User Info follows: on an edit, only the
 * fields the customer actually changed are submitted. The servlet reads a
 * key's absence as "untouched" and a key present-but-empty as "clear this
 * column", so what is and isn't in the POST body is load-bearing rather
 * than a nicety - sending every field would make "didn't touch it" and
 * "set it to what it already was" indistinguishable, and would defeat the
 * dynamic UPDATE the DAO builds.
 *
 * The second is that Edit fills the shared boat card from the clicked
 * card's data-* attributes. The card's own default* parameters can't do it:
 * those are jsp:param values resolved once at server render, and Edit opens
 * client-side with no round trip. They still matter for the other path -
 * when a save fails, the server re-renders with openForm set and the
 * customer's typed values come back through the card - which is why this
 * file reads #boatModal's data-open-form on load.
 *
 * Submits go to /myFleet/add, /myFleet/edit and /myFleet/remove. The one
 * rule worth repeating from the contract: on an edit this sends ONLY the
 * fields that changed, plus boatId. A key's absence means
 * "untouched"; a key present and empty means "clear that column to NULL".
 *
 * None of this is trusted. The servlets re-check every value, re-check that
 * the boat belongs to the customer, and reject any field that isn't
 * editable - see the Validation Rules section of the My Fleet contract.
 *
 * Requires formValidation.js (loaded on every page by WEB-INF/includes/loginModal.jsp
 * through the header), modal.js (loaded on every page by the header), and
 * boatFields.js and editTracker.js (the change tracking shared with Edit
 * User Info), which myFleet.jsp loads first.
 */
var MoffatBay = window.MoffatBay || {};

MoffatBay.myFleet = (function () {
    "use strict";

    var boatModal = document.getElementById("boatModal");
    var boatForm = document.getElementById("boatForm");
    if (!boatModal || !boatForm) { return {}; }

    var rules = MoffatBay.boatFields;

    var modalTitle = document.getElementById("boatModalTitle");
    var modalError = document.getElementById("boatModalError");
    var boatIdInput = document.getElementById("boatId");
    var saveButton = document.getElementById("saveBoat");
    var saveHint = document.getElementById("saveBoatHint");

    var confirmPanel = document.getElementById("confirmChanges");
    var confirmList = document.getElementById("confirmChangesList");
    var confirmLede = document.getElementById("confirmChangesLede");

    var removeModal = document.getElementById("removeModal");
    var removeBoatId = document.getElementById("removeBoatId");
    var removeQuestion = document.getElementById("removeQuestion");

    var country = boatModal.dataset.country || "US";
    var addAction = boatForm.getAttribute("action");
    var editAction = addAction.replace(/\/add$/, "/edit");

    /* Every Boat column this page can write, in the order they appear in
       the card - which is also the order the confirmation lists them. */
    var FIELDS = [
        "boatName", "boatType", "boatLength", "boatBeam",
        "hin", "regNumber", "boatYear"
    ];

    /* What each field is called to a person. Field names are the Boat
       column names, which is right for the wire and wrong for reading
       "regNumber" back to yourself. */
    var FIELD_LABELS = {
        boatName: "Boat name",
        boatType: "Boat type",
        boatLength: "Boat length",
        boatBeam: "Boat beam",
        hin: "HIN",
        regNumber: "Registration number",
        boatYear: "Boat year"
    };

    /* Never editable once the boat exists: length decides the slip size and
       the monthly rate, so changing it could leave an Active reservation in
       a slip the boat no longer fits, priced wrong. HIN joins it per boat,
       but only when one is already stored - see openEdit. */
    var ALWAYS_LOCKED_ON_EDIT = ["boatLength"];

    /* The card's data-* attribute for each field. */
    var DATA_KEYS = {
        boatName: "boatName",
        boatType: "boatType",
        boatLength: "boatLength",
        boatBeam: "boatBeam",
        hin: "hin",
        regNumber: "regNumber",
        boatYear: "boatYear"
    };

    var mode = "add";          // "add" or "edit"

    var control = MoffatBay.editTracker.control;
    var valueOf = MoffatBay.editTracker.valueOf;

    /* What each field held when the modal opened, and which fields now
       differ from it (editTracker.js, shared with Edit User Info). A
       disabled field can never differ: it is locked on this boat and is
       not submitted. */
    var tracker = MoffatBay.editTracker.create({
        fields: FIELDS,
        ignores: function (field) {
            var el = control(field);
            return !el || el.disabled;
        }
    });
    var changedFields = tracker.changedFields;

    // The marina's phone number, from the header's data-marina-phone
    // (MarinaInfo on the server), so it's never typed into a script.
    function marinaPhone() {
        var header = document.querySelector(".site-header");
        return header ? header.dataset.marinaPhone : "";
    }

    function setBanner(message) {
        if (!modalError) { return; }
        modalError.textContent = message || "";
        modalError.hidden = !message;
    }

    function clearFieldErrors() {
        FIELDS.forEach(function (field) {
            var box = document.getElementById(field + "Error");
            if (box) { box.textContent = ""; }
        });
        var section = document.getElementById("boatSectionError");
        if (section) { section.textContent = ""; }
    }

    /* ------------------------------------------------------------------
       Opening and closing
       ------------------------------------------------------------------ */

    /**
     * Puts every field back to empty and unlocked, so an Add never inherits
     * anything an Edit left behind.
     */
    function resetForm() {
        boatForm.reset();
        FIELDS.forEach(function (field) {
            var el = control(field);
            if (!el) { return; }
            el.value = "";
            el.disabled = false;
            el.setCustomValidity("");
        });
        removeSetOnceMarker();
        removeFieldNotes();
        clearFieldErrors();
        setBanner("");
        hideConfirmation();
        MoffatBay.boatFields.updateLengthNotice();
    }

    /* Open/close, the close buttons and Escape all come from modal.js. */
    var openModal = MoffatBay.modal.open;
    var closeModal = MoffatBay.modal.close;

    /**
     * Add: a blank card, posting to /myFleet/add.
     */
    function openAdd() {
        mode = "add";
        resetForm();
        boatForm.setAttribute("action", addAction);
        boatIdInput.disabled = true;
        boatIdInput.value = "";
        modalTitle.textContent = "Add a Boat";
        setClearButtonLabel("Clear Boat Info");
        rules.applyCountry(country, {
            regNumberLabel: document.getElementById("regNumberLabel"),
            regNumberInput: control("regNumber"),
            foreignBadge: document.getElementById("foreignRegistrationBadge")
        });
        updateSaveState();
        openModal(boatModal);
    }

    /**
     * Edit: filled from the card's data-* attributes, posting to
     * /myFleet/edit with the boat's id in a hidden field.
     *
     * @param {HTMLElement} card - the .fleet-card that was clicked
     */
    function openEdit(card) {
        mode = "edit";
        resetForm();
        boatForm.setAttribute("action", editAction);

        boatIdInput.disabled = false;
        boatIdInput.value = card.dataset.boatId || "";

        modalTitle.textContent = "Edit " + (card.dataset.boatName || "Boat");
        setClearButtonLabel("Revert Changes");

        FIELDS.forEach(function (field) {
            var el = control(field);
            var key = DATA_KEYS[field];
            if (!el || !key) { return; }
            el.value = card.dataset[key] || "";
        });

        rules.applyCountry(country, {
            regNumberLabel: document.getElementById("regNumberLabel"),
            regNumberInput: control("regNumber"),
            foreignBadge: document.getElementById("foreignRegistrationBadge")
        });

        /* Length is always locked. HIN is locked only once one is stored:
           a boat registered with just a registration number can still have
           one added, once, and then never again. Disabled rather than
           readonly, so the browser does not submit them at all - a
           submitted boatLength on an edit is a structural rejection. */
        ALWAYS_LOCKED_ON_EDIT.forEach(function (field) {
            lockField(field, "Length decides the slip size and the monthly rate, so it "
                + "can't change here. Call the Marina on " + marinaPhone() + " to correct it.");
        });

        if ((card.dataset.hin || "") !== "") {
            lockField("hin", "A hull number doesn't change for the life of the boat.");
        } else {
            markSetOnce("hin", "No HIN on file for this boat. You can add one now — "
                + "once it's saved it can't be changed.");
        }

        snapshot();
        updateSaveState();
        openModal(boatModal);
    }

    function lockField(field, note) {
        var el = control(field);
        if (!el) { return; }
        el.disabled = true;
        addFieldNote(el, note);
    }

    /**
     * Marks a field that can be filled in once and then locks forever. The
     * grey of a disabled field says "you can't"; nothing else on screen
     * would say "you can, but only once".
     */
    function markSetOnce(field, note) {
        var el = control(field);
        if (!el) { return; }
        var label = el.parentNode ? el.parentNode.querySelector("label") : null;
        if (label && !label.querySelector(".fleet-set-once")) {
            var chip = document.createElement("span");
            chip.className = "fleet-set-once";
            chip.textContent = "Set once";
            label.appendChild(document.createTextNode(" "));
            label.appendChild(chip);
        }
        addFieldNote(el, note);
    }

    function addFieldNote(el, text) {
        if (!text || !el.parentNode) { return; }
        var note = document.createElement("p");
        note.className = "fleet-field-note";
        note.textContent = text;
        el.parentNode.appendChild(note);
    }

    function removeFieldNotes() {
        boatForm.querySelectorAll(".fleet-field-note").forEach(function (n) { n.remove(); });
    }

    function removeSetOnceMarker() {
        boatForm.querySelectorAll(".fleet-set-once").forEach(function (n) { n.remove(); });
    }

    /**
     * The card's Clear button becomes Revert Changes on an edit. Clearing
     * there would blank boatName, which the servlet rejects outright as a
     * structural error with no user-facing message - a dead end.
     */
    function setClearButtonLabel(text) {
        var clear = document.getElementById("clearBoatInfo");
        if (clear) { clear.textContent = text; }
    }

    /* ------------------------------------------------------------------
       What changed
       ------------------------------------------------------------------ */

    /**
     * Records what every field held when the modal opened, so "changed"
     * means changed from what is on file rather than from whatever it held
     * a moment ago.
     */
    function snapshot() {
        tracker.snapshot();
    }

    /**
     * Fills the confirmation panel with one row per changed field, old on
     * the left and new on the right, and shows it in place of the form's
     * actions. Built from the form as it stands right now rather than from
     * anything captured earlier, so what is listed and what gets submitted
     * cannot drift apart.
     *
     * @param {string[]} changed
     */
    function showConfirmation(changed) {
        if (!confirmPanel || !confirmList) { return; }

        tracker.fillConfirmation(confirmList, changed, FIELD_LABELS);

        if (confirmLede) {
            confirmLede.textContent = "Nothing has been set yet. Only "
                + (changed.length === 1 ? "this field" : "these " + changed.length + " fields")
                + " will be saved — everything else on "
                + (tracker.original("boatName") || "this boat") + " stays as it is.";
        }

        boatForm.hidden = true;
        confirmPanel.hidden = false;
        /* Disabled after a click to stop a double save; a Back-button
           return to this page brings it back still disabled. */
        document.getElementById("confirmSaveBoat").disabled = false;
        document.getElementById("confirmSaveBoat").focus();
    }

    /**
     * Puts the form back and hides the confirmation, leaving every field
     * exactly as it was - "Keep Editing" returns to editing, it does not undo.
     */
    function hideConfirmation() {
        if (confirmPanel) { confirmPanel.hidden = true; }
        boatForm.hidden = false;
    }

    /* ------------------------------------------------------------------
       Save state
       ------------------------------------------------------------------ */

    /**
     * On an edit the useful question is "is there anything to save at all" -
     * the fields arrive already filled in and already valid, so an enabled
     * button would invite a save that writes nothing. On an add it is the
     * ordinary one: are the required fields there.
     */
    function updateSaveState() {
        if (mode === "add") {
            if (saveHint) { saveHint.hidden = true; }
            saveButton.disabled = false;
            saveButton.textContent = "Save Boat";
            return;
        }

        var changed = changedFields();
        saveButton.textContent = "Save Changes";
        saveButton.disabled = changed.length === 0;

        if (saveHint) {
            saveHint.hidden = false;
            saveHint.textContent = changed.length === 0
                ? "Nothing changed yet."
                : (changed.length === 1
                    ? "1 field will be saved."
                    : changed.length + " fields will be saved.");
        }
    }

    /* ------------------------------------------------------------------
       Submitting
       ------------------------------------------------------------------ */

    /**
     * The client-side checks, for feedback only. The servlet runs all of
     * them again and is the one that decides.
     *
     * @returns {string} a message, or "" when everything passes
     */
    function checkFields() {
        if (valueOf("boatName") === "") { return "Enter a name for the boat."; }

        if (mode === "add" && valueOf("boatLength") === "") {
            return "Enter the boat's length in feet.";
        }

        return rules.firstProblem({
            hin: valueOf("hin"),
            regNumber: valueOf("regNumber"),
            boatYear: valueOf("boatYear"),
            boatLength: valueOf("boatLength"),
            boatBeam: valueOf("boatBeam")
        }, country);
    }

    /**
     * Posts only the changed fields, plus boatId (editTracker.js explains
     * why the body is built by hand rather than by the browser).
     *
     * @param {string[]} changed
     */
    function submitOnlyChanged(changed) {
        tracker.submitOnlyChanged(editAction, changed, { boatId: boatIdInput.value });
    }

    function handleSubmit(event) {
        event.preventDefault();
        setBanner("");

        var problem = checkFields();
        if (problem) {
            setBanner(problem);
            return;
        }

        if (mode === "add") {
            boatForm.submit();
            return;
        }

        var changed = changedFields();
        if (changed.length === 0) {
            setBanner("Nothing has changed, so there's nothing to save.");
            return;
        }

        /* The confirmation is the last step before anything is sent. It
           posts a form built for the purpose rather than this one, so the
           list shown and the body sent are the same set of fields. */
        showConfirmation(changed);
    }

    /* ------------------------------------------------------------------
       Remove
       ------------------------------------------------------------------ */

    function openRemove(card) {
        removeBoatId.value = card.dataset.boatId || "";
        removeQuestion.textContent = "Remove " + (card.dataset.boatName || "this boat")
            + " from your fleet?";
        openModal(removeModal);
    }

    /* ------------------------------------------------------------------
       Reopening after a failed save

       The server forwards back with openForm set and the customer's typed
       values already rendered into the card through its default* params.
       All this has to do is put the right modal back up, in the right mode,
       and move each server message into its field's error box.
       ------------------------------------------------------------------ */

    function applyServerFieldErrors() {
        var holder = document.getElementById("serverFieldErrors");
        if (!holder) { return; }

        holder.querySelectorAll(".js-field-error").forEach(function (item) {
            var field = item.dataset.field;
            var box = document.getElementById(field + "Error");
            if (box) {
                box.textContent = item.textContent;
            } else {
                setBanner(item.textContent);
            }
        });
    }

    function restoreAfterFailure() {
        var open = boatModal.dataset.openForm;
        if (!open) { return; }

        /* Capture what the server rendered into the card BEFORE anything
           resets it. On a failure forward those are the values the customer
           typed, arriving back through the card's default* params - losing
           them would mean retyping the whole form over one bad field. */
        var typed = {};
        FIELDS.forEach(function (field) { typed[field] = valueOf(field); });

        var card = null;
        if (open === "edit" && boatModal.dataset.editBoatId) {
            card = document.querySelector(
                '.fleet-card[data-boat-id="' + boatModal.dataset.editBoatId + '"]');
        }

        if (card) {
            openEdit(card);
        } else {
            openAdd();
        }

        /* openEdit filled the fields from the card, which holds what is ON
           FILE - that is what originals should be, so "changed" still means
           changed from what is stored rather than from the rejected attempt.
           The visible values go back to what the customer typed - but only
           for fields the request actually carried. An edit posts just the
           fields that changed, so every other field came back blank from
           the server; overwriting with those blanks emptied everything the
           customer hadn't touched. An Add posts every field, so it restores
           them all. A locked field keeps the stored value; it was never
           submitted. */
        var posted = boatModal.dataset.postedFields;
        var postedList = posted ? posted.split(",") : null;
        FIELDS.forEach(function (field) {
            var el = control(field);
            if (!el || el.disabled) { return; }
            if (open === "edit" && postedList && postedList.indexOf(field) === -1) { return; }
            el.value = typed[field] || "";
        });

        MoffatBay.boatFields.updateLengthNotice();
        updateSaveState();
        setBanner(boatModal.dataset.formError || "");
        applyServerFieldErrors();

        /* The failed save was a POST to /myFleet/add or /myFleet/edit, and
           that is the address the browser now shows. Put /myFleet back, so
           a refresh reloads the page instead of offering to resubmit. */
        if (window.history && window.history.replaceState) {
            window.history.replaceState(null, "", addAction.replace(/\/add$/, ""));
        }
    }

    /* ------------------------------------------------------------------
       Wiring
       ------------------------------------------------------------------ */

    ["openAddBoat", "openAddBoatEmpty"].forEach(function (id) {
        var btn = document.getElementById(id);
        if (btn) { btn.addEventListener("click", openAdd); }
    });

    document.querySelectorAll(".js-edit-boat").forEach(function (btn) {
        btn.addEventListener("click", function () {
            openEdit(btn.closest(".fleet-card"));
        });
    });

    document.querySelectorAll(".js-remove-boat").forEach(function (btn) {
        btn.addEventListener("click", function () {
            openRemove(btn.closest(".fleet-card"));
        });
    });

    boatForm.addEventListener("submit", handleSubmit);
    boatForm.addEventListener("input", function () {
        setBanner("");
        updateSaveState();
    });

    var confirmSave = document.getElementById("confirmSaveBoat");
    if (confirmSave) {
        confirmSave.addEventListener("click", function () {
            confirmSave.disabled = true;
            submitOnlyChanged(changedFields());
        });
    }

    var cancelSave = document.getElementById("cancelSaveBoat");
    if (cancelSave) { cancelSave.addEventListener("click", hideConfirmation); }

    /* The boat card's own Clear button. registration.js owns this on the
       Registration page and reservation.js on the Reservation page; neither
       file can be loaded here. On an edit it reverts rather than clears. */
    var clearBoat = document.getElementById("clearBoatInfo");
    if (clearBoat) {
        clearBoat.addEventListener("click", function () {
            if (mode === "edit") {
                FIELDS.forEach(function (field) {
                    var el = control(field);
                    if (el && !el.disabled) { el.value = tracker.original(field); }
                });
            } else {
                FIELDS.forEach(function (field) {
                    var el = control(field);
                    if (el) { el.value = ""; }
                });
            }
            setBanner("");
            clearFieldErrors();
            updateSaveState();
        });
    }

    restoreAfterFailure();

    return {
        openAdd: openAdd,
        close: function () { closeModal(boatModal); }
    };
}());
