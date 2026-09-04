/*
 * src/main/webapp/js/passwordRules.js
 *
 * Behavior for the "password must contain" checklist box
 * (includes/passwordRules.jsp). Requires formValidation.js to be
 * loaded first (uses MoffatBay.form.PASSWORD_RULES / checkPasswordRules).
 *
 * Finds its own rule <li> elements by the ids passwordRules.jsp
 * defines - one per key in MoffatBay.form.PASSWORD_RULES, named
 * "rule" + the capitalized key (length -> ruleLength, upper ->
 * ruleUpper, etc.) - and exposes:
 *
 *     MoffatBay.passwordRules.check(password)
 *
 * which toggles each rule element's "met" class and returns true only
 * if every rule passed, so a caller doesn't have to know the box's
 * element ids just to validate a password field.
 */
var MoffatBay = window.MoffatBay || {};

MoffatBay.passwordRules = (function () {
    "use strict";

    var ruleElements = {};
    Object.keys(MoffatBay.form.PASSWORD_RULES).forEach(function (key) {
        var id = "rule" + key.charAt(0).toUpperCase() + key.slice(1);
        ruleElements[key] = document.getElementById(id);
    });

    /**
     * Checks value against every password rule, toggling each rule
     * element's "met" class as it goes.
     * @param {string} value - the password to check
     * @returns {boolean} true only if every rule passed
     */
    function check(value) {
        return MoffatBay.form.checkPasswordRules(value, ruleElements);
    }

    return {
        check: check
    };
})();
