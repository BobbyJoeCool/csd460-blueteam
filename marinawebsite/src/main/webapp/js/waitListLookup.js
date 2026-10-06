/*
 * Blue Team - Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
 * Primary Author/Owner - Robert Breutzmann
 * src/main/webapp/js/waitListLookup.js
 *
 * Opens the Leave Wait List popup from a Your Place in Line card (issue
 * #346) and fills it in from the card that was clicked: which entry the
 * form posts, and the slip size in the title. Open/close is modal.js's
 * (MoffatBay.modal); WaitListLeaveServlet re-checks everything.
 *
 * Only loaded when the customer is on at least one list, so the popup is
 * always on the page when this runs.
 */
(function () {
    "use strict";

    var modal = document.getElementById("leaveWaitListModal");
    if (!modal || !window.MoffatBay || !MoffatBay.modal) {
        return;
    }

    var entryField = document.getElementById("leaveWaitListId");
    var title = document.getElementById("leaveWaitListTitle");
    var submit = modal.querySelector("button[type=submit]");

    document.querySelectorAll(".js-open-leave").forEach(function (button) {
        button.addEventListener("click", function () {
            var card = button.closest("[data-wait-list-id]");
            entryField.value = card.dataset.waitListId || "";
            title.textContent = card.dataset.size
                ? "Leave the " + card.dataset.size + " ft wait list?"
                : "Leave the wait list?";
            // Disabled after the last submit; a Back-button return keeps that.
            submit.disabled = false;
            MoffatBay.modal.open(modal);
        });
    });

    /* One click, one submission. */
    modal.querySelector("form").addEventListener("submit", function () {
        submit.disabled = true;
    });
})();
