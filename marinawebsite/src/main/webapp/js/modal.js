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
 * Used by My Fleet, My Reservations and Your Account. The login and password modals use
 * their own older .is-open pattern (accountModals.js, loginModal.js) and
 * don't go through this.
 *
 * Loaded on every page by includes/header.jsp, deferred, ahead of any
 * page's own deferred script.
 */
var MoffatBay = window.MoffatBay || {};

MoffatBay.modal = (function () {
    "use strict";

    /* What had focus before each modal opened, keyed by the modal. */
    var openers = new WeakMap();

    /**
     * Shows a modal and moves focus into it.
     * @param {HTMLElement} modal - the .modal element
     */
    function open(modal) {
        if (!modal) { return; }
        openers.set(modal, document.activeElement);
        modal.hidden = false;
        var first = modal.querySelector(
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

    document.addEventListener("keydown", function (event) {
        if (event.key !== "Escape") { return; }
        var open = document.querySelectorAll(".modal:not([hidden])");
        if (open.length) { close(open[open.length - 1]); }
    });

    /* The Back button. Browsers keep a snapshot of the page you just left
       (the back/forward cache) and Back restores that snapshot rather than
       reloading - and a page is usually left from INSIDE a popup, by its
       "Yes, save" / "Yes, cancel it" button. Without this, Back lands on the
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
