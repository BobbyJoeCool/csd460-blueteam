/*
 * Blue Team - Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
 * Primary Author/Owner - Robert Breutzmann
 * src/main/webapp/js/modal.js
 *
 * Open and close for the site's shared .modal component (site.css), so
 * each page's script only says WHEN a modal opens and what goes in it:
 *
 *   MoffatBay.modal.open(modal)   shows it, focuses the first control, and
 *                                 remembers what had focus before.
 *   MoffatBay.modal.close(modal)  hides it and puts focus back.
 *
 * Wired for every .modal on the page, once, here: anything inside it with
 * data-modal-close closes it (the backdrop, the x, a Cancel button), and
 * Escape closes the open modal that comes last in the page - the one on
 * top when two are open. Coming back to a page with the browser's Back
 * button closes any popup that was open when the page was left.
 *
 * Every popup on the site uses this: My Fleet, My Reservations, Your
 * Account, Book a Slip (the boat panel and the booking confirmation), and
 * the Sign in / Reset password / Change password popups, whose own scripts
 * (loginModal.js, accountModals.js) call open() and close() here.
 *
 * Loaded on every page by includes/header.jsp, deferred, ahead of any
 * page's own deferred script.
 */
var MoffatBay = window.MoffatBay || {};

MoffatBay.modal = (function () {
    "use strict";

    /* What had focus before each modal opened, keyed by the modal. */
    var openers = new WeakMap();

    /* Everything that can take keyboard focus inside a modal. */
    var FOCUSABLE = "a[href], button:not(:disabled), input:not([type=hidden]):not(:disabled), "
        + "select:not(:disabled), textarea:not(:disabled), [tabindex]:not([tabindex='-1'])";

    /**
     * The controls inside a modal that Tab can reach right now - visible
     * ones only, so a hidden banner's or a collapsed section's controls
     * don't become invisible stops.
     * @param {HTMLElement} modal - the .modal element
     * @returns {HTMLElement[]}
     */
    function focusables(modal) {
        return Array.prototype.filter.call(modal.querySelectorAll(FOCUSABLE), function (el) {
            return el.offsetParent !== null && el.getAttribute("tabindex") !== "-1";
        });
    }

    /**
     * Shows a modal and moves focus into it.
     *
     * Focus goes to the control marked data-modal-initial if there is one.
     * A confirmation marks its SAFE answer ("Keep Reservation", "Cancel"),
     * so Enter pressed straight after it opens never does the irreversible
     * thing. Otherwise focus goes to the first field, or the first button
     * that doesn't just close the popup.
     *
     * @param {HTMLElement} modal - the .modal element
     */
    function open(modal) {
        if (!modal) { return; }
        openers.set(modal, document.activeElement);
        modal.hidden = false;
        var first = modal.querySelector("[data-modal-initial]")
            || modal.querySelector(
                "input:not([type=hidden]):not(:disabled), select, textarea, button:not([data-modal-close])");
        if (first) { first.focus(); }
    }

    /**
     * Hides a modal and returns focus to whatever opened it.
     * @param {HTMLElement} modal - the .modal element
     */
    function close(modal) {
        if (!modal) { return; }
        modal.hidden = true;
        var opener = openers.get(modal);
        openers.delete(modal);
        if (opener && typeof opener.focus === "function") { opener.focus(); }
    }

    document.querySelectorAll(".modal").forEach(function (modal) {
        modal.querySelectorAll("[data-modal-close]").forEach(function (el) {
            el.addEventListener("click", function () { close(modal); });
        });
    });

    /* Escape closes the modal on top; Tab and Shift+Tab stay inside it.
       Every modal says aria-modal="true", which tells a screen reader the
       page behind is out of reach - this makes that true for the keyboard
       too, instead of Tab walking out into the page under the backdrop. */
    document.addEventListener("keydown", function (event) {
        if (event.key !== "Escape" && event.key !== "Tab") { return; }
        var open = document.querySelectorAll(".modal:not([hidden])");
        if (!open.length) { return; }
        var top = open[open.length - 1];

        if (event.key === "Escape") {
            close(top);
            return;
        }

        var stops = focusables(top);
        if (!stops.length) { event.preventDefault(); return; }
        var first = stops[0];
        var last = stops[stops.length - 1];
        var inside = top.contains(document.activeElement);

        if (event.shiftKey && (document.activeElement === first || !inside)) {
            event.preventDefault();
            last.focus();
        } else if (!event.shiftKey && (document.activeElement === last || !inside)) {
            event.preventDefault();
            first.focus();
        }
    });

    /* The Back button. Browsers keep a snapshot of the page you just left
       (the back/forward cache) and Back restores that snapshot rather than
       reloading - and a page is usually left from INSIDE a popup, by its
       "Save Changes" / "Yes, cancel it" button. Without this, Back lands on the
       popup still open, as if the save hadn't happened. event.persisted is
       true only for a snapshot restore, never a normal load, so a popup a
       page opens on purpose while loading (My Fleet after a failed save) is
       left alone. Pages re-enable their own confirm buttons when a popup is
       next opened. */
    window.addEventListener("pageshow", function (event) {
        if (!event.persisted) { return; }
        document.querySelectorAll(".modal:not([hidden])").forEach(close);
    });

    return {
        open: open,
        close: close
    };
})();
