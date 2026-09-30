/*
 * src/main/webapp/js/header.js
 * Blue Team - Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
 * CSD 460 - Capstone Project - Marina Website Project
 *
 * Open/close behavior for the mobile hamburger menu in the shared header
 * and its dropdowns (Plan Your Stay, and the signed-in Welcome menu).
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
   Header dropdowns - Plan Your Stay, and the signed-in Welcome menu
   ========================================================== */

MoffatBay.dropdowns = (function () {
    "use strict";

    // Wires one [data-dropdown]: its [data-dropdown-toggle] button opens
    // and closes it, and Escape or a click outside closes it.
    function init(dropdown) {
        var toggle = dropdown.querySelector("[data-dropdown-toggle]");

        if (!toggle) {
            return null;
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

        // Clicking outside the dropdown closes it - including a click on
        // the other dropdown's button, so only one is ever open.
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
    }

    var menus = [];

    document.querySelectorAll("[data-dropdown]").forEach(function (dropdown) {
        var menu = init(dropdown);
        if (menu) {
            menus.push(menu);
        }
    });

    return {
        closeAll: function () {
            menus.forEach(function (menu) {
                menu.close();
            });
        }
    };
})();
