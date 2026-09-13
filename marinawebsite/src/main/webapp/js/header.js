/*
 * src/main/webapp/js/header.js
 * Blue Team - Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
 * CSD 460 - Capstone Project - Marina Website Project
 *
 * Open/close behavior for the mobile hamburger menu in the shared header
 * (includes/header.jsp). Only matters below the 600px breakpoint in
 * header.css - above that, .header-nav's children are always visible and
 * this toggle button is hidden, so nothing here has any effect.
 */
var MoffatBay = window.MoffatBay || {};

MoffatBay.headerNav = (function () {
    "use strict";

    var nav = document.querySelector(".header-nav");
    var toggle = document.querySelector("[data-nav-toggle]");

    if (!nav || !toggle) { return {}; }

    function isOpen() {
        return nav.classList.contains("is-open");
    }

    function setOpen(open) {
        nav.classList.toggle("is-open", open);
        toggle.setAttribute("aria-expanded", open ? "true" : "false");
    }

    toggle.addEventListener("click", function () {
        setOpen(!isOpen());
    });

    document.addEventListener("keydown", function (event) {
        if (event.key === "Escape" && isOpen()) {
            setOpen(false);
            toggle.focus();
        }
    });

    // Clicking outside the open menu closes it.
    document.addEventListener("click", function (event) {
        if (isOpen() && !nav.contains(event.target)) {
            setOpen(false);
        }
    });

    return {
        close: function () { setOpen(false); }
    };
})();
