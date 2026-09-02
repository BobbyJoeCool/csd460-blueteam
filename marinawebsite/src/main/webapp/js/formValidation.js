/*
 * Blue Team - CSD 460 Capstone - Moffat Bay Marina
 * Shared client-side form helpers: phone formatting, password rule
 * checking, email format checking. Any page can pull this in with
 *   <script src="${pageContext.request.contextPath}/js/formValidation.js"></script>
 * and use window.MoffatBay.form.* - written first for Registration,
 * meant for Login / Edit User Info / anywhere else that repeats these
 * same checks instead of copy-pasting the logic per page.
 */
var MoffatBay = window.MoffatBay || {};

MoffatBay.form = (function () {
    "use strict";
    // Requires local-part chars, "@", domain chars, a dot, then 2+ letter TLD.
    var EMAIL_PATTERN = /^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/;

    /**
     * Checks whether value is a well-formed email address.
     * @param {string} value - the string to check
     * @returns {boolean} true if value matches EMAIL_PATTERN
     */
    function isValidEmail(value) {
        return EMAIL_PATTERN.test(value || "");
    }

    // Requires exactly 5 digits, optionally followed by a hyphen and 4 more digits.
    var ZIP_PATTERN = /^\d{5}(-\d{4})?$/;

    /**
     * Checks whether value is a valid 5-digit or ZIP+4 postal code.
     * @param {string} value - the string to check
     * @returns {boolean} true if value matches ZIP_PATTERN
     */
    function isValidZip(value) {
        return ZIP_PATTERN.test(value || "");
    }

    /**
     * Strips everything but digits and caps at 10 - the shared notion
     * of "a phone number" for every page that collects one.
     * @param {string} value - raw input, in any format
     * @returns {string} up to 10 digit characters, no formatting
     */
    function extractPhoneDigits(value) {
        return (value || "").replace(/\D/g, "").slice(0, 10);
    }

    /**
     * Progressively formats however many digits have been entered so
     * far as "(###) ###-####". No parens show up at all until all 3
     * area code digits are in, then both appear together; each dash
     * shows up the moment the next group starts.
     * @param {string} digits - raw digit string (e.g. from extractPhoneDigits)
     * @returns {string} the formatted (partial or complete) phone display
     */
    function formatPhoneDisplay(digits) {
        var d = (digits || "").slice(0, 10);
        if (d.length === 0) { return ""; }
        if (d.length < 3) { return d; }
        if (d.length === 3) { return "(" + d + ")"; }
        if (d.length < 7) { return "(" + d.slice(0, 3) + ") " + d.slice(3); }
        return "(" + d.slice(0, 3) + ")-" + d.slice(3, 6) + "-" + d.slice(6);
    }

    // Requires 1 to 3 digits, the first of which can't be 0 - matches the
    // shape of a real E.164 country calling code (e.g. "1", "44", "351")
    // and the Customer.phoneCountryCode column's VARCHAR(3).
    var COUNTRY_CODE_PATTERN = /^[1-9]\d{0,2}$/;

    /**
     * Checks whether value is a plausible phone country calling code:
     * 1 to 3 digits, no leading zero (see COUNTRY_CODE_PATTERN above).
     * Doesn't check it against the actual ITU-T assigned list, just the shape.
     * @param {string} value - the country code to check
     * @returns {boolean} true if value matches COUNTRY_CODE_PATTERN
     */
    function isValidCountryCode(value) {
        return COUNTRY_CODE_PATTERN.test(value || "");
    }

    /**
     * A boat's model year: 4 digits, starting with 18, 19, or 20 (no
     * boat has a model year before 1800, and typing garbage like
     * "9999" shouldn't pass), and not later than the current year -
     * nobody can register a boat that hasn't been built yet.
     * @param {string} value - the year string to check
     * @returns {boolean} true if value is a plausible boat model year
     */
    function isValidBoatYear(value) {
        // Requires exactly 4 digits, the first two being 18, 19, or 20.
        if (!/^(18|19|20)\d{2}$/.test(value || "")) { return false; }
        return Number(value) <= new Date().getFullYear();  // False is entered year is after current year.
    }

    /*
     * State vessel Certificate of Number format, per 33 CFR 174.17
     * "Format of number": 4 to 7 Arabic numerals followed by 2 capital
     * letters, which may be separated by a hyphen or space (e.g.
     * "1234 AB" or "1234567-CD"). The state abbreviation that's
     * normally the first part of the full number isn't included here
     * since Registration State is its own field on this form.
     */
    // Requires 4 to 7 digits, an optional hyphen or space, then exactly 2 letters.
    var REG_NUMBER_PATTERN = /^\d{4,7}[- ]?[A-Za-z]{2}$/;

    /**
     * Checks whether value matches the state vessel Certificate of
     * Number format (see REG_NUMBER_PATTERN above).
     * @param {string} value - the registration number to check; "" counts as valid, the field is optional
     * @returns {boolean} true if value is empty or matches REG_NUMBER_PATTERN
     */
    function isValidRegNumber(value) {
        return value === "" || REG_NUMBER_PATTERN.test(value);
    }

    /*
     * Hull Identification Number format, per 33 CFR 181.23 "Format of
     * the Hull Identification Number": 12 characters total, made up of
     * a 3-letter Manufacturer Identification Code (MIC) followed by 9
     * more letters/digits (a serial number plus a certification/model
     * year code - the exact split of those last 9 characters changed
     * between the pre-1984, 1984-2016, and 2017+ HIN formats, so this
     * deliberately only enforces the one rule that's held constant
     * across all of them: 3 letters, then 9 alphanumeric characters).
     */
    // Requires exactly 3 letters followed by exactly 9 letters/digits (12 characters total).
    var HIN_PATTERN = /^[A-Za-z]{3}[A-Za-z0-9]{9}$/;

    /**
     * Checks whether value matches the Hull Identification Number
     * format (see HIN_PATTERN above).
     * @param {string} value - the HIN to check; "" counts as valid, the field is optional
     * @returns {boolean} true if value is empty or matches HIN_PATTERN
     */
    function isValidHIN(value) {
        return value === "" || HIN_PATTERN.test(value);
    }

    var PASSWORD_RULES = {
        length: { label: "At least 10 characters", test: function (v) { return v.length >= 10; } },
        upper: { label: "One uppercase letter", test: function (v) { return /[A-Z]/.test(v); } },
        lower: { label: "One lowercase letter", test: function (v) { return /[a-z]/.test(v); } },
        number: { label: "One number", test: function (v) { return /\d/.test(v); } },
        special: { label: "One special character (! $ % * #)", test: function (v) { return /[!$%*#]/.test(v); } }
    };

    /**
     * Runs every rule in PASSWORD_RULES against value.
     * @param {string} value - the password to check
     * @param {Object.<string, Element>} [ruleElements] - optional {ruleKey: element} map; each element gets a "met" class toggled on/off so a page can show/hide checkmarks per rule
     * @returns {boolean} true only if every rule passed
     */
    function checkPasswordRules(value, ruleElements) {
        var allMet = true;
        Object.keys(PASSWORD_RULES).forEach(function (key) {
            var met = PASSWORD_RULES[key].test(value);
            var el = ruleElements?.[key];
            if (el) { el.classList.toggle("met", met); }
            if (!met) { allMet = false; }
        });
        return allMet;
    }

    return {
        isValidEmail: isValidEmail,
        isValidZip: isValidZip,
        isValidCountryCode: isValidCountryCode,
        isValidBoatYear: isValidBoatYear,
        isValidRegNumber: isValidRegNumber,
        isValidHIN: isValidHIN,
        extractPhoneDigits: extractPhoneDigits,
        formatPhoneDisplay: formatPhoneDisplay,
        PASSWORD_RULES: PASSWORD_RULES,
        checkPasswordRules: checkPasswordRules
    };
})();
