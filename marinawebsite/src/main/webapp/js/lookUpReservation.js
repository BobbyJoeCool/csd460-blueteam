/*
 * Blue Team - Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
 * Primary Author/Owner - Sara White
 * src/main/webapp/js/lookUpReservation.js
 *
 * My Reservations filter form. Catches a reservation number with characters
 * no confirmation number has before the search is sent, using the shared
 * rule in formValidation.js (MoffatBay.form.isValidReservationSearch) - the
 * same one LookUpReservationServlet checks on the server.
 *
 * formValidation.js is already on the page (the header's login modal loads
 * it), and this file is deferred, so it runs after both exist.
 *
 * Also opens the popups on each reservation card - Cancel Reservation
 * before a lease starts, Submit 30-Day Notice after, Withdraw Notice while
 * a notice can still be taken back - and fills them in from
 * the card that was clicked. Open/close is modal.js's (MoffatBay.modal);
 * everything here is only what goes in them. Neither popup is a control:
 * ReservationChangeServlet re-checks everything.
 */
(function () {
    "use strict";

    var cancelModal = document.getElementById("cancelModal");
    var noticeModal = document.getElementById("noticeModal");
    var withdrawModal = document.getElementById("withdrawModal");
    if (!cancelModal || !noticeModal || !withdrawModal || !window.MoffatBay || !MoffatBay.modal) {
        return;
    }

    var noticeForm = document.getElementById("noticeForm");
    var lastDay = document.getElementById("lastDay");
    var lastDayError = document.getElementById("lastDayError");

    /**
     * Opens one of the popups for the card a button sits in: sets which
     * reservation its form posts, and the sentence naming it.
     * @param {HTMLElement} modal - #cancelModal or #noticeModal
     * @param {HTMLElement} card - the .reservation-card that was clicked
     * @param {string} questionId - the element that names the reservation
     * @param {string} text - that sentence
     */
    function openFor(modal, card, questionId, text) {
        modal.querySelector(".js-modal-confirmation").value = card.dataset.confirmation || "";
        // Disabled after the last submit; a Back-button return keeps that.
        modal.querySelector("button[type=submit]").disabled = false;
        document.getElementById(questionId).textContent = text;
        MoffatBay.modal.open(modal);
    }

    /**
     * Describes a card's reservation in one phrase, e.g.
     * "MB-00061 for Second Wind at Dock A, Slip 4".
     * @param {HTMLElement} card - the .reservation-card
     * @returns {string}
     */
    function describe(card) {
        return (card.dataset.confirmation || "This reservation")
            + " for " + (card.dataset.boatName || "your boat")
            + " at " + (card.dataset.location || "the marina");
    }

    /**
     * Shows or clears the error under the Last Day picker. The range is
     * whatever the server put in the input's min and max, so the 30-day
     * rule isn't repeated here. yyyy-MM-dd strings compare correctly as
     * plain text.
     * @returns {boolean} true if a date in range is chosen
     */
    function checkLastDay() {
        var value = lastDay.value;
        var message = "";
        if (!value) {
            message = "Choose your lease end date.";
        } else if (value < lastDay.min || value > lastDay.max) {
            message = "Choose a day from " + MoffatBay.form.formatDisplayDate(lastDay.min)
                + " to " + MoffatBay.form.formatDisplayDate(lastDay.max) + ".";
        }
        lastDayError.textContent = message;
        lastDay.classList.toggle("field-invalid", message !== "");
        lastDay.setAttribute("aria-invalid", message ? "true" : "false");
        return message === "";
    }

    document.querySelectorAll(".js-open-cancel").forEach(function (button) {
        button.addEventListener("click", function () {
            var card = button.closest(".reservation-card");
            openFor(cancelModal, card, "cancelQuestion",
                "Cancel reservation " + describe(card) + ", starting "
                + (card.dataset.start || "soon") + "?");
        });
    });

    document.querySelectorAll(".js-open-notice").forEach(function (button) {
        button.addEventListener("click", function () {
            var card = button.closest(".reservation-card");
            lastDay.value = lastDay.min;
            checkLastDay();
            openFor(noticeModal, card, "noticeQuestion",
                "End the lease on reservation " + describe(card) + ".");
        });
    });

    document.querySelectorAll(".js-open-withdraw").forEach(function (button) {
        button.addEventListener("click", function () {
            var card = button.closest(".reservation-card");
            var ending = card.dataset.lastDay ? ", ending " + card.dataset.lastDay : "";
            openFor(withdrawModal, card, "withdrawQuestion",
                "Withdraw the notice on reservation " + describe(card) + ending + "?");
        });
    });

    lastDay.addEventListener("input", checkLastDay);

    noticeForm.addEventListener("submit", function (event) {
        if (!checkLastDay()) {
            event.preventDefault();
            lastDay.focus();
        }
    });

    /* One click, one submission, for both popups. */
    [cancelModal, noticeModal, withdrawModal].forEach(function (modal) {
        modal.querySelector("form").addEventListener("submit", function (event) {
            if (event.defaultPrevented) { return; }
            modal.querySelector("button[type=submit]").disabled = true;
        });
    });
})();

(function () {
    "use strict";

    var form = document.getElementById("lookupForm");
    var number = document.getElementById("reservationNumber");
    var numberError = document.getElementById("reservationNumberError");

    // Signed out: the page shows a sign-in panel instead of the form.
    if (!form || !number || !numberError || !window.MoffatBay || !MoffatBay.form) {
        return;
    }

    var MESSAGE = "Reservation numbers only contain letters, numbers and dashes, like MB-00001.";

    /**
     * Shows or clears the error under the Reservation Number box.
     * @returns {boolean} true if the value is fine (blank counts as fine)
     */
    function checkNumber() {
        var valid = MoffatBay.form.isValidReservationSearch(number.value);
        numberError.textContent = valid ? "" : MESSAGE;
        number.classList.toggle("field-invalid", !valid);
        number.setAttribute("aria-invalid", valid ? "false" : "true");
        return valid;
    }

    number.addEventListener("input", checkNumber);

    form.addEventListener("submit", function (event) {
        if (!checkNumber()) {
            event.preventDefault();
            number.focus();
        }
    });
})();
