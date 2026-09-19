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
 */
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
