/*
 * Blue Team - CSD 460 Capstone - Moffat Bay Marina
 * js/reservation.js
 * Author: Robert Breutzmann
 *
 * The Reservation page: pricing, the availability flag, the register-a-boat
 * panel, and the wait-list prompt.
 *
 * RUNNING ON A FAKE BACK END. Nothing here talks to a real server yet. See
 * USE_FAKE_BACKEND below, and the block of fake* functions at the bottom.
 * Every point that will depend on Sara's side is marked "BACKEND:".
 *
 * This page holds NO rate. Each boat's monthly figure and the electric fee
 * are worked out server-side from the Rate table and handed over ready-made,
 * so the page only ever adds two whole numbers of cents together. Do not
 * reintroduce $10.50 here - a price change should touch no JavaScript.
 */
var MoffatBay = window.MoffatBay || {};

MoffatBay.reservation = (function () {
    "use strict";

    /* STUB - flip to false when the real endpoints exist, then delete the
       fake* functions at the bottom of this file and this flag with them. */
    var USE_FAKE_BACKEND = true;

    var form = document.getElementById("reservationForm");
    if (!form) { return {}; }          // signed out - the page is a sign-in prompt

    var boatSelect     = document.getElementById("boatId");
    var checkInDate    = document.getElementById("checkInDate");
    var electric       = document.getElementById("wantsElectric");
    var submitBtn      = document.getElementById("submitReservation");

    var boatError      = document.getElementById("boatError");
    var dateError      = document.getElementById("dateError");
    var formError      = document.getElementById("formError");

    var availPanel     = document.getElementById("availabilityPanel");
    var availMessage   = document.getElementById("availabilityMessage");
    var waitPrompt     = document.getElementById("waitListPrompt");
    var waitQuestion   = document.getElementById("waitListQuestion");
    var waitError      = document.getElementById("waitListError");

    var summarySlip    = document.getElementById("summarySlip");
    var summaryBoat    = document.getElementById("summaryBoat");
    var summaryDate    = document.getElementById("summaryDate");
    var summaryElecLn  = document.getElementById("summaryElectricLine");
    var summaryElec    = document.getElementById("summaryElectric");
    var summaryTotal   = document.getElementById("summaryTotal");

    var sizeHint       = document.getElementById("sizeHint");
    var dockHint       = document.getElementById("dockHint");
    var dockError      = document.getElementById("dockError");
    var summaryDock    = document.getElementById("summaryDock");
    var dockRadios     = Array.prototype.slice.call(
                             form.querySelectorAll('input[name="dockId"]'));
    var ratePerFootEl  = document.getElementById("ratePerFoot");
    var rateElectricEl = document.getElementById("rateElectric");

    var boatPanel      = document.getElementById("boatPanel");
    var boatPanelForm  = document.getElementById("boatPanelForm");
    var boatPanelError = document.getElementById("boatPanelError");
    var boatPanelLead  = document.getElementById("boatPanelLead");
    var openPanelBtn   = document.getElementById("openBoatPanel");
    var saveBoatBtn    = document.getElementById("saveBoat");

    var lastFocused = null;

    /* Free slips per dock per size, rendered into the page at load. Stale if
       the page sits open a while - the server has the final say on Submit. */
    var docks = readJson("dockAvailability", []);

    /* Both from the Rate table, rendered into the page. perFootCents is used
       ONLY for the wording of the pricing note - the page still never prices
       a boat itself, it uses the figure each boat arrives with. */
    var rates = readJson("reservationRates", {});
    var electricCents = Number(rates.electricCents
        || (electric ? electric.dataset.electricCents : 0) || 0);
    var perFootCents = Number(rates.perFootCents || 0);

    // -------------------------------------------------------------- helpers

    function readJson(id, fallback) {
        var el = document.getElementById(id);
        if (!el) { return fallback; }
        try { return JSON.parse(el.textContent); }
        catch (e) { return fallback; }
    }

    function money(cents) {
        return "$" + (cents / 100).toFixed(2);
    }

    function setText(el, message) {
        if (el) { el.textContent = message || ""; }
    }

    function setBanner(el, message) {
        if (!el) { return; }
        el.textContent = message || "";
        el.hidden = !message;
    }

    function selectedOption() {
        if (!boatSelect || boatSelect.selectedIndex < 0) { return null; }
        var opt = boatSelect.options[boatSelect.selectedIndex];
        return (opt && opt.value) ? opt : null;
    }

    /** Free slips of a size on one dock. Anything unknown counts as none. */
    function freeOnDock(dock, sizeFt) {
        var n = dock && dock.available ? dock.available[String(sizeFt)] : 0;
        return typeof n === "number" ? n : 0;
    }

    /**
     * Free slips of a size across the whole marina, summed from the docks.
     * The per-dock numbers are the only availability figure the back end
     * sends, so the totals on the size cards are worked out from them rather
     * than being a second number that could disagree.
     */
    function freeSlips(sizeFt) {
        return docks.reduce(function (total, dock) {
            return total + freeOnDock(dock, sizeFt);
        }, 0);
    }

    /** The dock the customer has picked, or null. */
    function selectedDock() {
        for (var i = 0; i < dockRadios.length; i++) {
            if (dockRadios[i].checked) {
                var id = Number(dockRadios[i].value);
                for (var j = 0; j < docks.length; j++) {
                    if (Number(docks[j].dockId) === id) { return docks[j]; }
                }
            }
        }
        return null;
    }

    /**
     * Repaints the dock choices for the boat that is chosen.
     *
     * Only ever shows counts for the size that boat needs. A dock with three
     * 26 ft slips free is no use to a 40 ft boat, so showing its total would
     * be actively misleading.
     */
    function updateDockCards() {
        var opt = selectedOption();
        var size = opt ? Number(opt.dataset.slipSize) : 0;

        dockRadios.forEach(function (radio) {
            var card = radio.closest(".dock-card");
            var dockId = Number(radio.value);
            var dock = null;
            for (var i = 0; i < docks.length; i++) {
                if (Number(docks[i].dockId) === dockId) { dock = docks[i]; }
            }

            var stock = card.querySelector('[data-dock-stock="' + dockId + '"]');
            var free = size ? freeOnDock(dock, size) : 0;

            if (!size) {
                setText(stock, "");
                radio.disabled = true;
                radio.checked = false;
            } else {
                setText(stock, free === 0
                    ? "No " + size + " ft slips free here"
                    : free + " of our " + size + " ft slips free here");
                radio.disabled = free === 0;
                if (free === 0) { radio.checked = false; }
            }

            card.classList.toggle("is-unavailable", !!size && free === 0);
            card.classList.toggle("is-waiting", !size);
        });

        if (dockHint) {
            if (!opt) {
                setText(dockHint, "Pick your vessel above and we'll show which "
                                + "docks have room for it.");
            } else if (!size) {
                setText(dockHint, "");
            } else if (freeSlips(size) === 0) {
                setText(dockHint, "Every dock is full for " + size + " ft slips "
                                + "at the moment.");
            } else {
                setText(dockHint, "Docks with a " + size + " ft slip free. "
                                + "We'll assign you a slip on whichever you pick.");
            }
        }
    }

    // ------------------------------------------------- slip size cards

    var DASH = "\u2014";

    /** The card element for a size, or null. */
    function cardFor(size) {
        return document.querySelector('.slip-card[data-size="' + size + '"]');
    }

    /**
     * Repaints the three slip cards. They are INFORMATIONAL - nothing is
     * picked here. They show how many of each size are free, and once a
     * vessel is chosen the size it needs is highlighted.
     *
     * A boat fits exactly one size (BR-09), so the vessel decides this; the
     * customer never chooses a size that its boat can't use.
     */
    function updateSizeCards() {
        var opt = selectedOption();
        var boatSize = opt ? Number(opt.dataset.slipSize) : 0;

        [26, 40, 50].forEach(function (size) {
            var card = cardFor(size);
            if (!card) { return; }

            var free = freeSlips(size);
            var stock = card.querySelector('[data-stock="' + size + '"]');
            var match = card.querySelector('[data-match="' + size + '"]');

            setText(stock, free === 0 ? "None available"
                                      : free + (free === 1 ? " available" : " available"));
            card.classList.toggle("is-soldout", free === 0);

            var matched = !!opt && size === boatSize;
            card.classList.toggle("is-matched", matched);
            /* Dimmed only once there is a boat to compare against - with none
               chosen, all three read equally. */
            card.classList.toggle("is-dimmed", !!opt && !matched);
            if (match) { match.hidden = !matched; }
        });

        if (sizeHint) {
            if (!opt) {
                setText(sizeHint, "Choose your vessel below and we'll highlight "
                                + "the size it needs.");
            } else if (!boatSize) {
                setText(sizeHint, opt.dataset.boatName + " is "
                                + opt.dataset.boatLength
                                + " ft, which is larger than any slip we have.");
            } else {
                setText(sizeHint, opt.dataset.boatName + " is "
                                + opt.dataset.boatLength + " ft, so it needs a "
                                + boatSize + " ft slip.");
            }
        }
    }

    /** Fills the rates into the pricing note above the form. */
    function fillRates() {
        if (ratePerFootEl)  { setText(ratePerFootEl,  (perFootCents / 100).toFixed(2)); }
        if (rateElectricEl) { setText(rateElectricEl, (electricCents / 100).toFixed(2)); }
    }

    // ------------------------------------------------- reservation summary

    function updateSummary() {
        var opt = selectedOption();
        var wantsElec = !!(electric && electric.checked);

        setText(summaryBoat, opt
            ? opt.dataset.boatName + " (" + opt.dataset.boatLength + " ft)"
            : DASH);

        var dock = selectedDock();
        setText(summaryDock, dock ? "Dock " + dock.dockNumber : DASH);

        setText(summaryDate, checkInDate && checkInDate.value
            ? checkInDate.value
            : DASH);

        if (summaryElecLn) { summaryElecLn.hidden = !wantsElec; }
        setText(summaryElec, money(electricCents) + "/mo");

        var size = opt ? Number(opt.dataset.slipSize) : 0;

        if (!opt || !size) {
            setText(summarySlip, DASH);
            setText(summaryTotal, DASH);
            return;
        }

        setText(summarySlip, size + " ft Slip");

        /* Both figures came from the page, already worked out server-side.
           Whole cents, so no decimal multiplication and no rounding. */
        var total = Number(opt.dataset.monthlyCents || 0)
                  + (wantsElec ? electricCents : 0);
        setText(summaryTotal, money(total) + "/mo");
    }

    // -------------------------------------------------------- availability

    /**
     * The whole point of the page: the customer is told their size is full
     * the moment they pick their boat, not after filling everything in.
     *
     * A courtesy, not a guarantee - the counts can go stale while the page
     * sits open, so the server re-checks on Submit and can still come back
     * with the same answer later.
     */
    function updateAvailability() {
        var opt = selectedOption();

        hideWaitList();
        setText(boatError, "");

        if (!opt) {
            if (availPanel) { availPanel.hidden = true; }
            setSubmitEnabled(false);
            return;
        }

        var size = Number(opt.dataset.slipSize);

        /* No category fits. Not a wait-list case - there is no bigger size to
           wait for, so offering it would be offering something that can never
           come through. */
        if (!size) {
            availPanel.hidden = false;
            availPanel.classList.add("is-full");
            setText(availMessage,
                "We don't have a slip that fits a boat over 50 feet. "
                + "Please call the marina at (360) 555-0142.");
            setSubmitEnabled(false);
            return;
        }

        if (opt.dataset.reserved === "true") {
            availPanel.hidden = true;
            setText(boatError, (opt.dataset.boatName || "That boat")
                + " already has an active reservation.");
            setSubmitEnabled(false);
            return;
        }

        var free = freeSlips(size);

        if (free === 0) {
            availPanel.hidden = false;
            availPanel.classList.add("is-full");
            setText(availMessage, "All of our " + size + " ft slips are currently reserved.");
            showWaitList(size);
            setSubmitEnabled(false);
            return;
        }

        availPanel.hidden = true;
        availPanel.classList.remove("is-full");
        setText(availMessage, "");

        /* There is room somewhere, but they still have to say where. */
        setSubmitEnabled(!!selectedDock());
    }

    /** Redraws every part of the page that depends on the chosen boat. */
    function refresh() {
        updateSizeCards();
        updateDockCards();
        updateAvailability();
        updateSummary();
    }

    function setSubmitEnabled(on) {
        if (submitBtn) { submitBtn.disabled = !on; }
    }

    function showWaitList(size) {
        if (!waitPrompt) { return; }
        waitPrompt.hidden = false;
        waitPrompt.dataset.size = String(size);
        setText(waitQuestion,
            "Would you like to be added to the wait list for a " + size
            + " ft slip? We'll contact you when one opens up.");
        setText(waitError, "");
    }

    function hideWaitList() {
        if (waitPrompt) { waitPrompt.hidden = true; }
    }

    // -------------------------------------------------------- boat panel

    function openBoatPanel() {
        if (!boatPanel) { return; }
        lastFocused = document.activeElement;
        boatPanel.hidden = false;
        setBanner(boatPanelError, "");
        var first = document.getElementById("boatName");
        if (first) { first.focus(); }
    }

    function closeBoatPanel() {
        if (!boatPanel) { return; }
        boatPanel.hidden = true;
        if (lastFocused) { lastFocused.focus(); }
    }

    /**
     * Adds a freshly saved boat to the dropdown and selects it, without the
     * page reloading. Everything already filled in stays exactly as it was -
     * that is the entire reason this panel doesn't just submit the page.
     */
    function addBoatToDropdown(boat) {
        if (!boatSelect) { return; }

        var opt = document.createElement("option");
        opt.value = boat.boatId;
        opt.dataset.boatLength   = boat.boatLength;
        opt.dataset.slipSize     = boat.slipSizeFt;
        opt.dataset.monthlyCents = boat.monthlyCents;
        opt.dataset.boatName     = boat.boatName;
        opt.dataset.reserved     = "false";
        opt.textContent = boat.boatName + " — " + boat.boatLength + " ft";

        boatSelect.appendChild(opt);
        boatSelect.disabled = false;

        // Drop the "No boats registered" placeholder if it is still there.
        if (boatSelect.options.length > 1 && !boatSelect.options[0].value
                && boatSelect.options[0].textContent === "No boats registered") {
            boatSelect.remove(0);
        }

        boatSelect.value = String(boat.boatId);

        /* The save round trip also brings back a fresh count for this boat's
           counts, which can have gone stale while the page sat open, and it
           is free to refresh here. Registering a boat doesn't itself use up
           a slip, so this is opportunistic rather than necessary. */
        if (Array.isArray(boat.docks)) {
            docks = boat.docks;
        }

        refresh();
    }

    /**
     * The format checks the Registration page does on the same fields.
     * registration.js can't be loaded here (it wires up elements that only
     * exist over there and would throw), but formValidation.js is already
     * on the page via the header, so the checks themselves are shared rather
     * than a second copy of the rules.
     *
     * @returns {string} a message, or "" if everything is fine
     */
    function checkBoatFields() {
        var f = MoffatBay.form;
        if (!f) { return ""; }

        var hin  = (document.getElementById("hin")       || {}).value || "";
        var reg  = (document.getElementById("regNumber") || {}).value || "";
        var year = (document.getElementById("boatYear")  || {}).value || "";

        var country = boatPanel ? boatPanel.dataset.country : "";

        if (!f.isValidHIN(hin.trim().toUpperCase())) {
            return "HIN should be 12 characters: 3 letters, then 9 more "
                 + "letters or numbers.";
        }
        if (!f.isValidRegNumber(reg.trim().toUpperCase(), country)) {
            return country === "CA"
                ? "Enter a valid Canadian Registration Number, e.g. C1234 AB."
                : "Enter a valid Registration Number, including the state "
                  + "prefix, e.g. WN1234 AB.";
        }
        if (year.trim() !== "" && !f.isValidBoatYear(year.trim())) {
            return "Enter a valid four-digit boat year.";
        }
        return "";
    }

    function handleBoatSave(event) {
        event.preventDefault();
        setBanner(boatPanelError, "");

        var name   = (document.getElementById("boatName")  || {}).value || "";
        var length = (document.getElementById("boatLength")|| {}).value || "";

        var formatProblem = checkBoatFields();
        if (formatProblem) {
            setBanner(boatPanelError, formatProblem);
            return;
        }

        if (saveBoatBtn) { saveBoatBtn.disabled = true; }

        // BACKEND: replace with a real POST to the boat-save endpoint.
        // Expects back { ok, boatId, boatName, boatLength, slipSizeFt,
        // monthlyCents } on success - the same shape as one entry in the
        // page-load boat list - optionally with a refreshed "docks" array
        // alongside it. Or { ok: false, error } with a message plain enough
        // to show as-is.
        var request = USE_FAKE_BACKEND
            ? fakeSaveBoat(name.trim(), length.trim())
            : Promise.reject(new Error("Boat save endpoint not wired up yet."));

        request.then(function (result) {
            if (saveBoatBtn) { saveBoatBtn.disabled = false; }

            if (!result.ok) {
                setBanner(boatPanelError, result.error);
                return;
            }

            addBoatToDropdown(result);
            boatPanelForm.reset();
            closeBoatPanel();
            MoffatBay.statusPopup.show("Boat saved");

        }).catch(function (err) {
            if (saveBoatBtn) { saveBoatBtn.disabled = false; }
            setBanner(boatPanelError, "Your boat could not be saved. Please try again.");
            if (window.console) { window.console.error(err); }
        });
    }

    // ---------------------------------------------------------- wait list

    function handleJoinWaitList() {
        var size = waitPrompt ? waitPrompt.dataset.size : null;
        if (!size) { return; }

        setText(waitError, "");
        var joinBtn = document.getElementById("joinWaitList");
        if (joinBtn) { joinBtn.disabled = true; }

        // BACKEND: replace with a real POST to the wait-list endpoint,
        // sending slipSizeFt. Expects back { ok } on success, or
        // { ok: false, alreadyWaiting: true } if they are already on the
        // list for that size, so the page can say so instead of silently
        // putting them on it twice.
        var request = USE_FAKE_BACKEND
            ? fakeJoinWaitList(size)
            : Promise.reject(new Error("Wait list endpoint not wired up yet."));

        request.then(function (result) {
            if (joinBtn) { joinBtn.disabled = false; }

            if (result.alreadyWaiting) {
                setText(waitError, "You're already on the wait list for a "
                                 + size + " ft slip.");
                if (joinBtn) { joinBtn.hidden = true; }
                return;
            }

            if (!result.ok) {
                setText(waitError, result.error
                    || "You could not be added to the wait list. Please try again.");
                return;
            }

            window.location.href = form.getAttribute("action")
                .replace(/\/reservation$/, "/waitListLookup.jsp")
                + "?notice=waitListJoined&size=" + encodeURIComponent(size);

        }).catch(function (err) {
            if (joinBtn) { joinBtn.disabled = false; }
            setText(waitError,
                "You could not be added to the wait list. Please try again.");
            if (window.console) { window.console.error(err); }
        });
    }

    // ------------------------------------------------------------- submit

    function handleSubmit(event) {
        event.preventDefault();

        setBanner(formError, "");
        setText(boatError, "");
        setText(dockError, "");
        setText(dateError, "");

        var opt = selectedOption();
        var ok = true;

        if (!opt) {
            setText(boatError, "Select a boat for this reservation.");
            ok = false;
        }
        if (opt && Number(opt.dataset.slipSize) && !selectedDock()) {
            setText(dockError, "Choose which dock you'd like to be on.");
            ok = false;
        }
        if (!checkInDate || !checkInDate.value) {
            setText(dateError, "Choose a check-in date of today or later.");
            ok = false;
        } else if (checkInDate.value < todayIso()) {
            setText(dateError, "Choose a check-in date of today or later.");
            ok = false;
        }
        if (!ok) { return; }

        if (submitBtn) { submitBtn.disabled = true; }

        // BACKEND: this is where the form actually posts. Delete the fake
        // branch and let the form submit normally, or keep a fetch here if
        // the endpoint returns JSON. Expects a confirmation number on
        // success, or the "that size filled up" answer.
        var request = USE_FAKE_BACKEND
            ? fakeSubmitReservation(opt)
            : Promise.reject(new Error("Reservation endpoint not wired up yet."));

        request.then(function (result) {
            if (submitBtn) { submitBtn.disabled = false; }

            if (result.sizeFull) {
                /* Caught at the last moment rather than on selection. Same
                   notice and same question either way, so from the
                   customer's side it is one consistent behaviour.

                   Two flavours now there is a dock to pick: the one dock they
                   chose filled up but others still have room, or the size went
                   marina-wide. Only the second is a wait-list case. */
                var goneSize = String(result.slipSizeFt);
                docks.forEach(function (dock) {
                    if (!dock.available) { return; }
                    if (!result.dockId || Number(dock.dockId) === Number(result.dockId)) {
                        dock.available[goneSize] = 0;
                    }
                });
                refresh();
                return;
            }

            if (!result.ok) {
                setBanner(formError, result.error
                    || "Your reservation could not be completed. Please try again.");
                return;
            }

            window.location.href = "reservationSummary.jsp?confirmation="
                + encodeURIComponent(result.confirmationNumber);

        }).catch(function (err) {
            if (submitBtn) { submitBtn.disabled = false; }
            setBanner(formError, "Your reservation could not be completed. Please try again.");
            if (window.console) { window.console.error(err); }
        });
    }

    function todayIso() {
        var d = new Date();
        var m = String(d.getMonth() + 1).padStart(2, "0");
        var day = String(d.getDate()).padStart(2, "0");
        return d.getFullYear() + "-" + m + "-" + day;
    }

    // ================================================================
    // FAKE BACK END - delete this whole block with USE_FAKE_BACKEND.
    //
    // Deterministic on purpose so every outcome can actually be reached
    // while testing, instead of waiting for a random one:
    //   boat name contains "dup"  -> duplicate registration
    //   boat name contains "fail" -> save failed
    //   otherwise                 -> saved
    // ================================================================

    function fakeDelay(value, ms) {
        return new Promise(function (resolve) {
            window.setTimeout(function () { resolve(value); }, ms || 400);
        });
    }

    function fakeSaveBoat(name, lengthText) {
        var length = parseFloat(lengthText);

        if (!name || !lengthText) {
            return fakeDelay({ ok: false,
                error: "Boat Name and Boat Length are required when adding a boat." });
        }
        if (isNaN(length) || length <= 0 || length > 999.9) {
            return fakeDelay({ ok: false,
                error: "Enter a boat length between 1 and 999.9 feet." });
        }
        if (name.toLowerCase().indexOf("dup") !== -1) {
            return fakeDelay({ ok: false,
                error: "That HIN or boat registration is already in use." });
        }
        if (name.toLowerCase().indexOf("fail") !== -1) {
            return fakeDelay({ ok: false,
                error: "Your boat could not be saved. Please try again." });
        }

        var tenths = Math.round(length * 10);
        var size = length <= 26 ? 26 : (length <= 40 ? 40 : (length <= 50 ? 50 : 0));

        return fakeDelay({
            ok: true,
            boatId: "stub-" + Date.now(),
            boatName: name,
            boatLength: length.toFixed(1),
            slipSizeFt: size,
            monthlyCents: tenths * 105,     // server's job for real; $10.50/ft
            /* Handed back unchanged: registering a boat doesn't use up a
               slip, so nothing about availability actually moves here. It
               rides along only because it's a free chance to refresh
               numbers that may have gone stale while the page sat open. */
            docks: docks
        });
    }

    /* Type a size of 50 to see the "already on the list" answer. */
    function fakeJoinWaitList(size) {
        if (String(size) === "50") {
            return fakeDelay({ ok: false, alreadyWaiting: true });
        }
        return fakeDelay({ ok: true });
    }

    function fakeSubmitReservation(opt) {
        var size = Number(opt.dataset.slipSize);

        if (freeSlips(size) === 0) {
            return fakeDelay({ ok: false, sizeFull: true, slipSizeFt: size });
        }
        return fakeDelay({ ok: true, confirmationNumber: "MB-00061" });
    }

    // ================================================================
    // Wiring
    // ================================================================

    if (checkInDate) { checkInDate.min = todayIso(); }

    fillRates();

    if (boatSelect) {
        boatSelect.addEventListener("change", refresh);
    }
    dockRadios.forEach(function (radio) {
        radio.addEventListener("change", function () {
            setText(dockError, "");
            updateAvailability();
            updateSummary();
        });
    });
    if (electric)     { electric.addEventListener("change", updateSummary); }
    if (checkInDate)  { checkInDate.addEventListener("change", updateSummary); }
    if (openPanelBtn) { openPanelBtn.addEventListener("click", openBoatPanel); }
    if (boatPanelForm){ boatPanelForm.addEventListener("submit", handleBoatSave); }

    if (boatPanel) {
        boatPanel.querySelectorAll("[data-boat-close]").forEach(function (el) {
            el.addEventListener("click", closeBoatPanel);
        });
        document.addEventListener("keydown", function (event) {
            if (event.key === "Escape" && !boatPanel.hidden) { closeBoatPanel(); }
        });
    }

    var joinBtn = document.getElementById("joinWaitList");
    var declineBtn = document.getElementById("declineWaitList");
    if (joinBtn)    { joinBtn.addEventListener("click", handleJoinWaitList); }
    if (declineBtn) { declineBtn.addEventListener("click", hideWaitList); }

    form.addEventListener("submit", handleSubmit);

    /* The boat card's own Clear button. registration.js owns this on the
       Registration page, but that file can't be loaded here - it wires up
       elements that only exist over there and would throw. */
    var clearBoat = document.getElementById("clearBoatInfo");
    if (clearBoat && boatPanelForm) {
        clearBoat.addEventListener("click", function () {
            boatPanelForm.reset();
            setBanner(boatPanelError, "");
        });
    }

    /* No boats at all: open the panel for them rather than leaving them
       staring at a dead dropdown with no explanation. */
    if (boatSelect && boatSelect.disabled) {
        if (boatPanelLead) { boatPanelLead.hidden = false; }
        openBoatPanel();
    }

    refresh();

    return {
        show: openBoatPanel,
        close: closeBoatPanel
    };
}());
