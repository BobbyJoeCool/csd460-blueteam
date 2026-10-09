/*
 * src/main/webapp/js/header.js
 * Blue Team - Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
 * CSD 460 - Capstone Project - Marina Website Project
 *
 * Open/close behavior for the mobile hamburger menu in the shared header
 * and its dropdowns (Plan Your Stay, and the signed-in Welcome menu). On
 * a desktop the dropdowns open on hover and stay open once clicked.
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

    // How long a hover-opened menu waits before closing once the mouse
    // leaves, so it survives the small gap between the button and the
    // panel, or a slightly wobbly move down into it.
    var HOVER_CLOSE_DELAY_MS = 200;

    // A real mouse - not a touch screen, which only "hovers" on tap.
    var mouseQuery = window.matchMedia("(hover: hover) and (pointer: fine)");

    // Twin of header.css's mobile breakpoint. At this width Plan Your Stay
    // opens in place inside the hamburger list, where opening on hover
    // would shove the links below it up and down as the mouse passes.
    var hamburgerQuery = window.matchMedia("(max-width: 40rem)");

    function hoverOpens() {
        return mouseQuery.matches && !hamburgerQuery.matches;
    }

    var menus = [];

    function closeOthers(keep) {
        menus.forEach(function (menu) {
            if (menu !== keep) {
                menu.close();
            }
        });
    }

    // Wires one [data-dropdown]. On a desktop, hovering over it opens it
    // and moving the mouse away closes it again. Clicking its
    // [data-dropdown-toggle] button pins it open until the button is
    // clicked again, Escape is pressed, something outside it is clicked,
    // or focus tabs out of it. On a touch screen it's click-only, so a tap
    // opens it and the next tap closes it.
    function init(dropdown) {
        var toggle = dropdown.querySelector("[data-dropdown-toggle]");

        if (!toggle) {
            return null;
        }

        var closeTimer = null;

        var menu = {
            close: function () {
                setOpen(false);
            }
        };

        function isOpen() {
            return dropdown.classList.contains("is-open");
        }

        // .is-pinned marks a menu that was clicked open, so the mouse
        // leaving doesn't close it. header.css also keeps its button
        // highlighted while it's pinned.
        function isPinned() {
            return dropdown.classList.contains("is-pinned");
        }

        function setOpen(open) {
            clearTimeout(closeTimer);
            dropdown.classList.toggle("is-open", open);
            if (!open) {
                dropdown.classList.remove("is-pinned");
            }
            toggle.setAttribute("aria-expanded", open ? "true" : "false");
        }

        // A click on a menu the mouse already opened pins it rather than
        // closing it out from under the pointer.
        toggle.addEventListener("click", function () {
            if (isPinned()) {
                setOpen(false);
                return;
            }
            closeOthers(menu);
            setOpen(true);
            dropdown.classList.add("is-pinned");
        });

        // The panel is inside the dropdown, so moving from the button down
        // into the menu never counts as leaving. Together with Escape
        // below, that meets WCAG 1.4.13 (Content on Hover or Focus): the
        // menu can be moved into, stays put, and can be dismissed.
        dropdown.addEventListener("mouseenter", function () {
            if (!hoverOpens()) {
                return;
            }
            clearTimeout(closeTimer);
            if (!isOpen()) {
                closeOthers(menu);
                setOpen(true);
            }
        });

        dropdown.addEventListener("mouseleave", function () {
            if (!hoverOpens() || isPinned() || !isOpen()) {
                return;
            }
            closeTimer = setTimeout(function () {
                setOpen(false);
            }, HOVER_CLOSE_DELAY_MS);
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

        // Tabbing out of the menu closes it too, so it can't sit open over
        // the content a keyboard user has moved on to (WCAG 2.2 "Focus Not
        // Obscured"). relatedTarget is null when focus leaves the page,
        // which contains() treats as outside, so that closes it as well.
        dropdown.addEventListener("focusout", function (event) {
            if (isOpen() && !dropdown.contains(event.relatedTarget)) {
                setOpen(false);
            }
        });

        return menu;
    }

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
