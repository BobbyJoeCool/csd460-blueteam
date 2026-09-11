/*
 * Blue Team - CSD 460 Capstone - Moffat Bay Marina
 * js/statusPopup.js
 * Author: Robert Breutzmann
 * Blue Team - Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
 * Primary Author/Owner - Robert Breutzmann
 *
 * The shared status popup. Loaded by includes/statusPopup.jsp, which is
 * itself pulled in by header.jsp, so this is available on every page.
 *
 * Any page can say:
 *     MoffatBay.statusPopup.show("Boat saved");
 *
 * Confirmations only. Errors belong next to whatever is wrong and have to
 * stay put - see the status popup contract's "It Is Not For Errors".
 */
var MoffatBay = window.MoffatBay || {};

MoffatBay.statusPopup = (function () {
    "use strict";

    var HOLD_MS = 5000;

    var region = document.getElementById("statusPopupRegion");
    var timer = null;

    /*
     * Each entry builds its own text. Returning null means "I can't make a
     * sensible message from what I was given" - nothing is then shown,
     * rather than printing a half-finished sentence.
     *
     * The wording lives here and only here. The server sends a keyword, not
     * a sentence: a URL is whatever was in the link somebody clicked, so if
     * the wording travelled in the address bar then anyone could put their
     * own words on the marina's page with a doctored link.
     */
    var MESSAGES = {
        loggedIn:   function () { return "Logged in successfully"; },
        loggedOut:  function () { return "You've been logged out"; },
        registered: function () { return "Account created — welcome aboard"; },

        reservationCancelled: function () {
            return "Reservation cancelled";
        },
        /* The cancel went through but changed nothing, which in practice
           means it had already been cancelled - usually a double click or
           a resubmitted form. Says so rather than claiming success. */
        reservationNotCancelled: function () {
            return "That reservation was already cancelled";
        },

        waitListJoined: function (size) {
            return size ? "You're on the wait list for a " + size + " ft slip"
                        : null;
        }
    };

    /* The only three slip sizes that exist. Anything else is not a size. */
    var VALID_SIZES = ["26", "40", "50"];

    /**
     * Clears any running countdown.
     */
    function stopTimer() {
        if (timer !== null) {
            window.clearTimeout(timer);
            timer = null;
        }
    }

    /**
     * Starts (or restarts) the countdown to hiding the message.
     */
    function startTimer() {
        stopTimer();
        timer = window.setTimeout(hide, HOLD_MS);
    }

    /**
     * Removes the message. Safe to call when nothing is showing.
     */
    function hide() {
        stopTimer();
        if (region) { region.textContent = ""; }
    }

    /**
     * Shows a message, replacing whatever is already there.
     *
     * Never takes focus - yanking someone out of what they are typing to
     * announce good news would be worse than saying nothing at all.
     *
     * @param {string} message - the text to show; ignored if empty
     */
    function show(message) {
        if (!region || !message) { return; }

        hide();

        var box = document.createElement("div");
        box.className = "status-popup";

        /* textContent, never innerHTML. Nothing reaching this function is
           ever treated as markup. */
        var text = document.createElement("span");
        text.className = "status-popup__text";
        text.textContent = message;

        var close = document.createElement("button");
        close.type = "button";
        close.className = "status-popup__close";
        close.setAttribute("aria-label", "Dismiss message");
        close.textContent = "×";
        close.addEventListener("click", hide);

        box.appendChild(text);
        box.appendChild(close);

        /* The countdown pauses while the pointer is over the box or the X
           has keyboard focus, so a message can't vanish mid-read. Restarts
           the full five rather than counting the remainder - simpler, and
           erring toward showing it longer is the right direction. */
        box.addEventListener("mouseenter", stopTimer);
        box.addEventListener("mouseleave", startTimer);
        box.addEventListener("focusin", stopTimer);
        box.addEventListener("focusout", startTimer);

        region.appendChild(box);

        /* Next frame, so the browser sees the starting state first and
           actually animates into .is-visible instead of jumping. */
        window.requestAnimationFrame(function () {
            box.classList.add("is-visible");
        });

        startTimer();
    }

    /**
     * Reads a notice keyword out of the address bar on page load, shows the
     * matching message, then takes the keyword back out of the address bar
     * so a refresh doesn't announce the same thing over and over.
     */
    function showFromQueryString() {
        if (!region || !window.URLSearchParams) { return; }

        var params = new URLSearchParams(window.location.search);
        var notice = params.get("notice");

        /* RegisterServlet already redirects with ?registered=true, and the
           landing page has been ignoring it since Module 5. Honouring the
           old spelling means registration needs no back-end change. */
        if (!notice && params.get("registered") === "true") {
            notice = "registered";
        }

        if (!notice) { return; }

        /* hasOwnProperty rather than MESSAGES[notice]: a plain object
           inherits constructor, toString and friends, so ?notice=constructor
           would otherwise find one of those and try to call it. */
        if (!Object.prototype.hasOwnProperty.call(MESSAGES, notice)) { return; }

        /* An unrecognised size is dropped rather than passed through, which
           makes the builder return null, which shows nothing. The size is
           the only thing that travels in the URL, and it survives being
           there because it is checked against a fixed list before use - not
           escaped and hoped for. */
        var size = params.get("size");
        var safeSize = (VALID_SIZES.indexOf(size) !== -1) ? size : null;

        var text = MESSAGES[notice](safeSize);
        if (!text) { return; }

        show(text);

        if (window.history && window.history.replaceState) {
            params.delete("notice");
            params.delete("size");
            params.delete("registered");
            var query = params.toString();
            window.history.replaceState(
                {},
                "",
                window.location.pathname + (query ? "?" + query : "") + window.location.hash
            );
        }
    }

    showFromQueryString();

    return {
        show: show,
        hide: hide
    };
}());
