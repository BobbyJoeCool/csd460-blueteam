/*
 * Blue Team - CSD 460 Capstone - Moffat Bay Marina
 * js/reservation.js
 * Author: Robert Breutzmann
 * Blue Team - Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
 * Primary Author/Owner - Robert Breutzmann
 *
 * The Reservation page: pricing, the availability flag, the register-a-boat
 * panel, and the wait-list prompt.
 *
 * Reservation data and form actions are supplied by the Java back end.
 *
 * This page holds NO rate. Each boat's monthly figure and the electric fee
 * are worked out server-side from the Rate table and handed over ready-made,
 * so the page only ever adds two whole numbers of cents together. Do not
 * reintroduce $10.50 here - a price change should touch no JavaScript.
 */
var MoffatBay = window.MoffatBay || {};

MoffatBay.reservation = (function () {
    "use strict";

 

    var form = document.getElementById("reservationForm");
    if (!form) { return {}; }          // signed out - the page is a sign-in prompt

    var boatSelect     = document.getElementById("boatId");
    var checkInDate    = document.getElementById("checkInDate");
    var electric       = document.getElementById("wantsElectric");
    var submitBtn      = document.getElementById("submitReservation");
    var submitBlockedReason = document.getElementById("submitBlockedReason");

    var boatError      = document.getElementById("boatError");
    var dateError      = document.getElementById("dateError");
    var formError      = document.getElementById("formError");

    /* One wording for a start date in the past, wherever it's reported:
       the short one under the Reserve button, the full one under the
       field. ReservationServlet sends the full one too. */
    var DATE_PAST_SHORT = "Start date can't be in the past.";
    var DATE_PAST_FULL  = "Start date can't be in the past. Choose today or later.";
    var DATE_FAR_SHORT  = "Start date must be within 12 months.";
    var DATE_FAR_FULL   = "Start date must be within 12 months of today.";

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
    var autoPickBtn    = document.getElementById("autoPickDock");
    var ratePerFootEl  = document.getElementById("ratePerFoot");
    var rateElectricEl = document.getElementById("rateElectric");

    var boatPanel      = document.getElementById("boatPanel");
    var boatPanelForm  = document.getElementById("boatPanelForm");
    var boatPanelError = document.getElementById("boatPanelError");
    var boatPanelLead  = document.getElementById("boatPanelLead");
    var openPanelBtn   = document.getElementById("openBoatPanel");
    var saveBoatBtn    = document.getElementById("saveBoat");

    var confirmModal   = document.getElementById("confirmBookingModal");
    var confirmText    = document.getElementById("confirmBookingText");
    var confirmBtn     = document.getElementById("confirmBooking");


    /* Free slips per dock per size. Rendered into the page at load for a
       lease starting today, then swapped for the chosen start date's counts
       once there is one (loadAvailabilityFor). Stale if the page sits open a
       while - the server has the final say on Submit. */
    var docks = readJson("dockAvailability", []);

    /* Which availability request is the latest, so an older answer that
       arrives late can't overwrite a newer date's counts. */
    var availabilityTicket = 0;

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
    /** POSTs form data and returns the JSON object from the servlet. */
    function postForm(url, body) {
        return fetch(url, {
            method: "POST",
            body: body,
            headers: {
                "Accept": "application/json",
                "X-CSRF-Token": MoffatBay.form.csrfToken()
            }
        }).then(function (response) {
            return response.json();
        });
    }



    // Shared formatter (formValidation.js), so live figures match the
    // server's <fmt:formatNumber type="currency"> exactly.
    function money(cents) {
        return MoffatBay.form.formatMoney(cents);
    }

    // The marina's phone number, from the header's data-marina-phone
    // (MarinaInfo on the server), so it's never typed into a script.
    function marinaPhone() {
        var header = document.querySelector(".site-header");
        return header ? header.dataset.marinaPhone : "";
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
                setText(dockHint, "Pick your boat above and we'll show which "
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

        if (autoPickBtn) {
            autoPickBtn.disabled = !size || freeSlips(size) === 0;
        }
    }

    /**
     * "Pick a dock for me" - checks the real dock radio with the most free
     * slips of the chosen size, so the form still submits a normal dockId
     * like any other selection. Ties are broken at random rather than
     * always favouring the same dock (e.g. always Dock A).
     */
    function pickDockForMe() {
        var opt = selectedOption();
        var size = opt ? Number(opt.dataset.slipSize) : 0;
        if (!size) { return; }

        var best = [];
        var bestFree = 0;

        dockRadios.forEach(function (radio) {
            if (radio.disabled) { return; }

            var dockId = Number(radio.value);
            var dock = null;
            for (var i = 0; i < docks.length; i++) {
                if (Number(docks[i].dockId) === dockId) { dock = docks[i]; }
            }

            var free = freeOnDock(dock, size);
            if (free > bestFree) {
                bestFree = free;
                best = [radio];
            } else if (free === bestFree && free > 0) {
                best.push(radio);
            }
        });

        if (!best.length) { return; }

        var chosen = best[Math.floor(Math.random() * best.length)];
        chosen.checked = true;
        setText(dockError, "");
        updateAvailability();
        updateSummary();
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
                setText(sizeHint, "Choose your boat below and we'll highlight "
                                + "the size it needs.");
            } else if (!boatSize) {
                setText(sizeHint, opt.dataset.boatName + " is "
                                + MoffatBay.form.formatFeet(opt.dataset.boatLength)
                                + ", which is larger than any slip we have.");
            } else {
                setText(sizeHint, opt.dataset.boatName + " is "
                                + MoffatBay.form.formatFeet(opt.dataset.boatLength) + ", so it needs a "
                                + boatSize + " ft slip.");
            }
        }
    }

    /** Fills the rates into the pricing note above the form. */
    function fillRates() {
        if (ratePerFootEl)  { setText(ratePerFootEl,  money(perFootCents)); }
        if (rateElectricEl) { setText(rateElectricEl, money(electricCents)); }
    }

    // ------------------------------------------------- reservation summary

    function updateSummary() {
        var opt = selectedOption();
        var wantsElec = !!(electric && electric.checked);

        setText(summaryBoat, opt
            ? opt.dataset.boatName + " (" + MoffatBay.form.formatFeet(opt.dataset.boatLength) + ")"
            : DASH);

        var dock = selectedDock();
        setText(summaryDock, dock ? "Dock " + dock.dockNumber : DASH);

        setText(summaryDate, checkInDate && checkInDate.value
            ? MoffatBay.form.formatDisplayDate(checkInDate.value)
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
            setText(submitBlockedReason, "Select a boat to continue.");
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
                + "Please call the marina at " + marinaPhone() + ".");
            setSubmitEnabled(false);
            setText(submitBlockedReason, "We don't have a slip that fits this boat.");
            return;
        }

        if (opt.dataset.reserved === "true") {
            availPanel.hidden = true;
            setText(boatError, (opt.dataset.boatName || "That boat")
                + " already has an active reservation.");
            setSubmitEnabled(false);
            setText(submitBlockedReason, "This boat already has an active reservation.");
            return;
        }

        var free = freeSlips(size);

        if (free === 0) {
            availPanel.hidden = false;
            availPanel.classList.add("is-full");
            setText(availMessage, "All of our " + size + " ft slips are " + reservedWhen() + ".");
            setSubmitEnabled(false);
            setText(submitBlockedReason, "All " + size + " ft slips are " + reservedWhen() + ".");
            showWaitList(size);
            return;
        }

        availPanel.hidden = true;
        availPanel.classList.remove("is-full");
        setText(availMessage, "");

        /* There is room somewhere, but they still have to say where, and
           when. Dock first, since it's the earlier step on the page. */
        var dockChosen = !!selectedDock();
        var hasDate    = !!(checkInDate && checkInDate.value);
        var problem    = dateProblem();

        setSubmitEnabled(dockChosen && hasDate && !problem);

        /* A past date gets its own reason. It used to fall under "Choose a
           start date", which reads as if the date they picked hadn't
           registered at all. */
        if (!dockChosen) {
            setText(submitBlockedReason, "Choose a dock to continue.");
        } else if (!hasDate) {
            setText(submitBlockedReason, "Choose a start date to continue.");
        } else if (problem) {
            setText(submitBlockedReason, problem === "past" ? DATE_PAST_SHORT : DATE_FAR_SHORT);
        } else {
            setText(submitBlockedReason, "");
        }
    }

    /**
     * How the full-size message ends: "currently reserved" for today's
     * counts, or naming the start date once the counts are for that date.
     */
    function reservedWhen() {
        if (checkInDate && checkInDate.value && !dateProblem()) {
            return "reserved for a lease starting "
                + MoffatBay.form.formatDisplayDate(checkInDate.value);
        }
        return "currently reserved";
    }

    /**
     * Swaps in the free-slip counts for a lease starting on the chosen date
     * (issue #324), so a size that is full today but opens before then can
     * be booked, and redraws. With no usable date it goes back to the
     * counts the page loaded with. If the request fails, the counts already
     * shown stay; the server checks again on Submit either way.
     * @param {string} dateIso - the start date field's value, yyyy-MM-dd
     */
    function loadAvailabilityFor(dateIso) {
        var ticket = ++availabilityTicket;

        if (!dateIso || dateProblem()) {
            docks = readJson("dockAvailability", []);
            refresh();
            return;
        }

        fetch("reservation/availability?start=" + encodeURIComponent(dateIso), {
            headers: { "Accept": "application/json" }
        }).then(function (response) {
            if (!response.ok) { throw new Error("availability " + response.status); }
            return response.json();
        }).then(function (fresh) {
            if (ticket !== availabilityTicket || !Array.isArray(fresh)) { return; }
            docks = fresh;
            refresh();
        }).catch(function (err) {
            if (window.console) { window.console.error(err); }
        });
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

    /* The panel is the shared .modal: modal.js shows it, focuses the first
       field (Boat Name), and closes it from the backdrop, the x, Cancel or
       Escape, handing focus back to whatever opened it. */
    function openBoatPanel() {
        if (!boatPanel) { return; }
        setBanner(boatPanelError, "");
        MoffatBay.modal.open(boatPanel);
    }

    function closeBoatPanel() {
        MoffatBay.modal.close(boatPanel);
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
        opt.textContent = boat.boatName + " — " + MoffatBay.form.formatFeet(boat.boatLength);

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
     *
     * The rules and their wording now live in js/boatFields.js, shared by
     * this panel, Registration and My Fleet. This used to be a second copy
     * of them, written here because registration.js can't be loaded on this
     * page (it wires up elements that only exist over there and would
     * throw) - the shared file exists so that reason stops costing a copy.
     *
     * The messages changed slightly when the two copies were merged; see
     * the note above MESSAGES in boatFields.js for which wording won and
     * why.
     *
     * @returns {string} a message, or "" if everything is fine
     */
    function checkBoatFields() {
        var boat = MoffatBay.boatFields;
        if (!boat) { return ""; }

        function valueOf(id) {
            return (document.getElementById(id) || {}).value || "";
        }

        return boat.firstProblem({
            hin: valueOf("hin"),
            regNumber: valueOf("regNumber"),
            boatYear: valueOf("boatYear"),
            boatLength: valueOf("boatLength"),
            boatBeam: valueOf("boatBeam")
        }, boatPanel ? boatPanel.dataset.country : "");
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

        // Sends the completed boat registration form to the reservation boat servlet.
        // The servlet saves the boat and returns the new boat data as JSON so it can
        // be added to the boat dropdown without reloading the page.
       
        var request = postForm(
            boatPanelForm.getAttribute("action"),
            new FormData(boatPanelForm)
        );


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

        // Sends the required slip size to the wait-list servlet.
        // The servlet determines whether the customer can be added and returns
        // a JSON response indicating success or whether they are already waiting.
        var waitData = new URLSearchParams();
        waitData.set("slipSizeFt", size);
        var waitUrl = form.getAttribute("action")
            .replace(/\/reservation$/, "/reservation/waitlist");
        var request = postForm(waitUrl, waitData);



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
                // The servlet, not the JSP. Going straight at
                // waitListLookup.jsp skips WaitListServlet.doGet(), so the
                // page renders with no summaries and tells someone who just
                // joined that they are not on the wait list.
                .replace(/\/reservation$/, "/waitList")
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
            setText(dateError, "Choose a start date.");
            ok = false;
        } else if (dateProblem()) {
            setText(dateError, dateProblemMessage());
            ok = false;
        }
        if (!ok) { return; }

        /* A monthly lease gets an "are you sure?", the same as a changed
           phone number on Your Account does. No popup on the page (it
           failed to render) means book straight away, as before. */
        if (!confirmModal || !confirmText || !confirmBtn) {
            sendReservation();
            return;
        }
        confirmText.textContent = bookingQuestion();
        confirmBtn.disabled = false;
        MoffatBay.modal.open(confirmModal);
    }

    /**
     * The confirm popup's question, e.g. "Book a 50 ft slip on Dock B,
     * starting Oct 15, 2026, for $483.00/mo?". Read from the Reservation
     * Summary's own text rather than worked out again, so the popup can't
     * say something different from the card beside it.
     */
    function bookingQuestion() {
        var size  = summarySlip  ? summarySlip.textContent.replace(/ Slip$/, "") : "";
        var dock  = summaryDock  ? summaryDock.textContent : "";
        var date  = summaryDate  ? summaryDate.textContent : "";
        var total = summaryTotal ? summaryTotal.textContent : "";
        return "Book a " + size + " slip on " + dock
             + ", starting " + date + ", for " + total + "?";
    }

    function sendReservation() {
        if (submitBtn) { submitBtn.disabled = true; }

        // Sends the reservation form to the reservation servlet for final validation
        // and database insertion. The servlet returns JSON containing either an error
        // condition or the confirmation number for a successfully created reservation.
        var request = postForm(
            form.getAttribute("action"),
            new FormData(form)
        );

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

            /* The server's field-level refusals go under their own field,
               the same place the page's own checks put them, rather than
               becoming the generic banner. */
            if (!result.ok && (result.dateError || result.dockError)) {
                if (result.dateError) { setText(dateError, result.dateError); }
                if (result.dockError) { setText(dockError, result.dockError); }
                return;
            }

            if (!result.ok) {
                setBanner(formError, result.error
                    || "Your reservation could not be completed. Please try again.");
                return;
            }

            // No ".jsp" - ReservationSummaryServlet is mapped to
            // /reservationSummary and looks the booking up. Going straight
            // at the JSP would skip the servlet and render an empty page.
            window.location.href = "reservationSummary?confirmation="
                + encodeURIComponent(result.confirmationNumber);

        }).catch(function (err) {
            if (submitBtn) { submitBtn.disabled = false; }
            setBanner(formError, "Your reservation could not be completed. Please try again.");
            if (window.console) { window.console.error(err); }
        });
    }

    // Shared with every page via formValidation.js.
    function todayIso() {
        return MoffatBay.form.todayIso();
    }

    /**
     * What's wrong with the chosen start date, if anything: "past" (before
     * today) or "far" (after the field's max, which ReservationServlet sets
     * from BR-26), or null when it's fine or empty. min and max stop the
     * picker offering those days, but not a date typed in by hand.
     */
    function dateProblem() {
        var value = checkInDate && checkInDate.value;
        if (!value) { return null; }
        if (value < todayIso()) { return "past"; }
        if (checkInDate.max && value > checkInDate.max) { return "far"; }
        return null;
    }

    /** The message under the date field for dateProblem(), or "". */
    function dateProblemMessage() {
        var problem = dateProblem();
        if (problem === "past") { return DATE_PAST_FULL; }
        if (problem === "far")  { return DATE_FAR_FULL; }
        return "";
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
    if (autoPickBtn)  { autoPickBtn.addEventListener("click", pickDockForMe); }
    if (electric)     { electric.addEventListener("change", updateSummary); }
    if (checkInDate)  {
        checkInDate.addEventListener("change", function () {
            /* Flag a past date the moment it's entered. min stops the
               picker offering one, but not a date typed in by hand, and
               the submit-time check never runs for one because the
               button is already disabled. */
            setText(dateError, dateProblemMessage());
            updateAvailability();
            updateSummary();
            loadAvailabilityFor(checkInDate.value);
        });
    }
    if (openPanelBtn) { openPanelBtn.addEventListener("click", openBoatPanel); }
    if (boatPanelForm){ boatPanelForm.addEventListener("submit", handleBoatSave); }

    var joinBtn = document.getElementById("joinWaitList");
    var declineBtn = document.getElementById("declineWaitList");
    if (joinBtn)    { joinBtn.addEventListener("click", handleJoinWaitList); }
    if (declineBtn) { declineBtn.addEventListener("click", hideWaitList); }

    form.addEventListener("submit", handleSubmit);

    /* One click, one booking. Go Back, the x, the backdrop and Escape just
       close the popup (modal.js) and leave the form as it was. */
    if (confirmBtn) {
        confirmBtn.addEventListener("click", function () {
            confirmBtn.disabled = true;
            MoffatBay.modal.close(confirmModal);
            sendReservation();
        });
    }

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

    /**
     * Arriving from My Fleet's "Book a Slip" link, which carries
     * ?boatId= so the customer lands here with the boat they were looking
     * at already chosen, rather than having to find it again in a dropdown
     * they just came from.
     *
     * Front end only, on purpose: the servlet doesn't need to know. An id
     * that isn't in the dropdown - someone else's boat, a removed one, or
     * a hand-typed number - is ignored and the page opens on its default
     * exactly as before. Nothing here is trusted; the boat is re-checked
     * against the customer on submit as it always was.
     */
    function preselectBoatFromQuery() {
        if (!boatSelect || boatSelect.disabled) { return; }

        var wanted = new URLSearchParams(window.location.search).get("boatId");
        if (!wanted) { return; }

        var match = Array.prototype.some.call(boatSelect.options, function (opt) {
            return opt.value === wanted;
        });
        if (match) { boatSelect.value = wanted; }
    }

    preselectBoatFromQuery();

    refresh();

    /* A date the browser kept from an earlier visit (Back, or a reload)
       needs that date's counts, not today's. */
    if (checkInDate && checkInDate.value) { loadAvailabilityFor(checkInDate.value); }

    return {
        show: openBoatPanel,
        close: closeBoatPanel
    };
}());
