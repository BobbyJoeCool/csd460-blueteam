/*
 * src/main/webapp/js/boatFields.js
 * Author: Robert Breutzmann
 * Blue Team - Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
 * CSD 460 - Capstone Project - Marina Website Project
 *
 * The boat-field rules, in one place: what counts as a valid HIN,
 * Registration Number, year and dimension, the "HIN or Registration
 * Number" rule, the message a person reads when one of them fails, and
 * the way Registration Number changes with the owner's country.
 *
 * Why this file exists. Every page with the boat card on it -
 * Registration, the Reservation page's Register a Boat panel, and now My
 * Fleet - has to enforce the same rules, and until now each one carried
 * its own copy. registration.js had per-field checks writing into each
 * field's own error box; reservation.js had a single checkBoatFields()
 * returning one message, with a comment explaining that it couldn't just
 * load registration.js (that file reaches for #registrationForm and
 * #submitBtn on load and would throw anywhere else). Two copies had
 * already drifted apart in wording - see MESSAGES below. My Fleet would
 * have made three.
 *
 * The split of work here and in formValidation.js: formValidation.js owns
 * the primitives - "is this string a HIN", "is this a valid year" - and
 * is loaded on every page by includes/loginModal.jsp through the header.
 * This file owns everything built on top of those that is specific to a
 * boat: which combinations are allowed, what to say when they aren't, and
 * how the country changes the Registration Number field. The primitives
 * are also what the server enforces (Utils.isValidBoatYear and friends),
 * so keeping them there and the boat rules here means neither file is a
 * copy of the other.
 *
 * None of this is trusted. Every rule in here is enforced again server
 * side - see the Validation Rules section of the My Fleet and Registration
 * contracts.
 *
 * Requires formValidation.js first (MoffatBay.form.*).
 */
var MoffatBay = window.MoffatBay || {};

MoffatBay.boatFields = (function () {
    "use strict";

    var f = MoffatBay.form;

    /*
     * One message per rule, for every page.
     *
     * Registration and Reservation had drifted here before this file
     * existed: Registration said "Registration Number should be a 2-letter
     * state code, 4 to 7 digits, then 2 letters, e.g. WN1234 AB." while
     * Reservation said "Enter a valid Registration Number, including the
     * state prefix, e.g. WN1234 AB." Same rule, two sentences. The
     * Registration wording is kept because it states the format rather
     * than only naming the part most people get wrong, so a person who
     * has never seen the field can fix it from the message alone. The
     * Reservation page's banner therefore reads slightly differently than
     * it used to; that is the intended result of unifying them.
     */
    var MESSAGES = {
        hin: "HIN should be 12 characters: 3 letters, then 9 more letters or numbers.",

        regNumberUS: "Registration Number should be a 2-letter state code, 4 to 7 digits, "
                   + "then 2 letters, e.g. WN1234 AB.",

        regNumberCA: "Registration Number should be a C followed by 4 to 8 digits then "
                   + "2 letters, e.g. C1234 AB.",

        identification: "Enter either a HIN or a Registration Number.",

        boatYear: function () {
            return "Enter a 4-digit year, " + f.MIN_BOAT_YEAR
                 + " through " + new Date().getFullYear() + ".";
        },

        dimension: function (label) {
            return label + " should be a number of feet, more than 0 and no more than "
                 + f.MAX_BOAT_DIMENSION + ".";
        }
    };

    /**
     * The Registration Number message for a given country. Split out
     * because the rule itself differs by country, so the sentence
     * describing it has to as well.
     *
     * @param {string} country - "US", "CA" or "OTHER"
     * @returns {string} the message to show when the number doesn't match
     */
    function regNumberMessage(country) {
        return country === "CA" ? MESSAGES.regNumberCA : MESSAGES.regNumberUS;
    }

    /* ------------------------------------------------------------------
       The rules. Each takes a raw field value and answers yes or no.
       Blank passes every one of them: a field nobody filled in is not a
       field anybody got wrong. What makes a blank field a problem is
       identificationSatisfied() below, or a page's own required-field
       handling - not these.
       ------------------------------------------------------------------ */

    /**
     * @param {string} value - the HIN as typed
     * @returns {boolean} true when blank or a well-formed HIN
     */
    function hinIsValid(value) {
        return f.isValidHIN(String(value || "").trim().toUpperCase());
    }

    /**
     * @param {string} value - the registration number as typed
     * @param {string} country - the owner's country, which picks the format
     * @returns {boolean} true when blank or well-formed for that country
     */
    function regNumberIsValid(value, country) {
        return f.isValidRegNumber(String(value || "").trim().toUpperCase(), country);
    }

    /**
     * @param {string} value - the year as typed
     * @returns {boolean} true when blank or a four-digit year in range
     */
    function boatYearIsValid(value) {
        var text = String(value || "").trim();
        return text === "" || f.isValidBoatYear(text);
    }

    /**
     * Length and beam share one rule, the same one the server applies in
     * Utils.isValidBoatDimension.
     *
     * @param {string} value - the measurement as typed
     * @returns {boolean} true when blank or a number of feet in range
     */
    function boatDimensionIsValid(value) {
        var text = String(value || "").trim();
        return text === "" || f.isValidBoatDimension(text);
    }

    /**
     * The "HIN or Registration Number" rule: a boat has to be identifiable
     * by at least one of the two.
     *
     * Registration is the exception and does not call this - a boat is
     * optional there, and an owner with neither is told to call the Marina
     * rather than blocked. Reservation and My Fleet both require it,
     * because on those pages a boat is being registered outright.
     *
     * @param {string} hin
     * @param {string} regNumber
     * @returns {boolean} true when at least one of the two is filled in
     */
    function identificationSatisfied(hin, regNumber) {
        return String(hin || "").trim() !== "" || String(regNumber || "").trim() !== "";
    }

    /**
     * Every rule at once, for a page that shows one message at a time
     * rather than one per field. Order matters: identification first,
     * because "you haven't identified the boat" is a more useful thing to
     * be told than "that HIN is malformed" when the HIN is simply absent.
     *
     * @param {Object} values - {hin, regNumber, boatYear, boatLength, boatBeam}
     * @param {string} country - the owner's country
     * @returns {string} the first failing rule's message, or "" if all pass
     */
    function firstProblem(values, country) {
        var v = values || {};

        if (!identificationSatisfied(v.hin, v.regNumber)) { return MESSAGES.identification; }
        if (!hinIsValid(v.hin)) { return MESSAGES.hin; }
        if (!regNumberIsValid(v.regNumber, country)) { return regNumberMessage(country); }
        if (!boatYearIsValid(v.boatYear)) { return MESSAGES.boatYear(); }
        if (!boatDimensionIsValid(v.boatLength)) { return MESSAGES.dimension("Boat Length"); }
        if (!boatDimensionIsValid(v.boatBeam)) { return MESSAGES.dimension("Boat Beam"); }

        return "";
    }

    /**
     * Every failing rule at once, keyed by field name, for a page that
     * shows a message under each field.
     *
     * @param {Object} values - {hin, regNumber, boatYear, boatLength, boatBeam}
     * @param {string} country - the owner's country
     * @returns {Object} field name -> message, empty when everything passes
     */
    function allProblems(values, country) {
        var v = values || {};
        var problems = {};

        if (!hinIsValid(v.hin)) { problems.hin = MESSAGES.hin; }
        if (!regNumberIsValid(v.regNumber, country)) { problems.regNumber = regNumberMessage(country); }
        if (!boatYearIsValid(v.boatYear)) { problems.boatYear = MESSAGES.boatYear(); }
        if (!boatDimensionIsValid(v.boatLength)) { problems.boatLength = MESSAGES.dimension("Boat Length"); }
        if (!boatDimensionIsValid(v.boatBeam)) { problems.boatBeam = MESSAGES.dimension("Boat Beam"); }

        return problems;
    }

    /**
     * Points the Registration Number field at the right country's format:
     * the label, the example in the placeholder, and whether the field
     * applies at all. "OTHER" disables it and reveals the note telling the
     * owner to call the Marina, since the site only knows the US and
     * Canadian formats.
     *
     * Every element is optional - a page passes what it has. My Fleet has
     * no country selector at all (it reads the customer's stored country
     * once, server side), so it calls this with just the label and input.
     *
     * @param {string} country - "US", "CA" or "OTHER"
     * @param {Object} els - {regNumberLabel, regNumberInput, foreignBadge}
     */
    function applyCountry(country, els) {
        var parts = els || {};
        var isCanada = country === "CA";
        var isOther = country === "OTHER";

        if (parts.regNumberLabel) {
            parts.regNumberLabel.textContent = isCanada
                ? "Registration Number (Province)"
                : "Registration Number (State)";
        }

        if (parts.regNumberInput) {
            parts.regNumberInput.disabled = isOther;
            if (!isOther) {
                parts.regNumberInput.placeholder = isCanada ? "e.g. C1234 AB" : "e.g. WN1234 AB";
            }
        }

        if (parts.foreignBadge) {
            parts.foreignBadge.hidden = !isOther;
        }
    }

    return {
        MESSAGES: MESSAGES,
        regNumberMessage: regNumberMessage,
        hinIsValid: hinIsValid,
        regNumberIsValid: regNumberIsValid,
        boatYearIsValid: boatYearIsValid,
        boatDimensionIsValid: boatDimensionIsValid,
        identificationSatisfied: identificationSatisfied,
        firstProblem: firstProblem,
        allProblems: allProblems,
        applyCountry: applyCountry
    };
}());
