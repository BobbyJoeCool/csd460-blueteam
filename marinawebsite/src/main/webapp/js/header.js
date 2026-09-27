/*
 * src/main/webapp/js/header.js
 * Blue Team - Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
 * CSD 460 - Capstone Project - Marina Website Project
 *
 * Open/close behavior for the mobile hamburger menu in the shared header
 * and the Plan Your Stay navigation dropdown.
 */

var MoffatBay = window.MoffatBay || {};


/* =============================================================
   Mobile hamburger navigation
   ========================================================== */

MoffatBay.headerNav = (function () {
    "use strict";

    var nav = document.querySelector(".header-nav");
    var toggle = document.querySelector("[data-nav-toggle]");

    if (!nav || !toggle) {
        return {};
    }

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
        close: function () {
            setOpen(false);
        }
    };
})();


/* =============================================================
   Plan Your Stay dropdown
   ========================================================== */

MoffatBay.stayMenu = (function () {
    "use strict";

    var dropdown = document.querySelector("[data-stay-menu]");
    var toggle = document.querySelector("[data-stay-menu-toggle]");

    if (!dropdown || !toggle) {
        return {};
    }

    function isOpen() {
        return dropdown.classList.contains("is-open");
    }

    function setOpen(open) {
        dropdown.classList.toggle("is-open", open);
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

    // Clicking outside the dropdown closes it.
    document.addEventListener("click", function (event) {
        if (isOpen() && !dropdown.contains(event.target)) {
            setOpen(false);
        }
    });

    return {
        close: function () {
            setOpen(false);
        }
    };
})();