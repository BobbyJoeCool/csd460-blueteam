/*
 * Blue Team - Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
 * Primary Author/Owner - Robert Breutzmann
 * src/main/webapp/js/editTracker.js
 *
 * The "only send what changed" machinery shared by Edit User Info
 * (editUserInfo.js) and My Fleet's Edit (myFleet.js), issue #285. Both pages
 * follow the same rule: on an edit, only the fields the customer actually
 * changed are submitted. The servlets read a key's absence as "untouched"
 * and a key present-but-empty as "clear this column", so what is and isn't
 * in the POST body is load-bearing - see the Edit User Profile and My Fleet
 * contracts.
 *
 * A tracker records what each field held when editing began, says which
 * fields now differ, fills the old -> new rows of the confirmation, and
 * posts just those fields. Where the two pages differ, they say so when
 * creating one:
 *
 *   same(field, before, after)  Edit User Info compares email, state and
 *                               country ignoring case, the way the servlet
 *                               normalizes them.
 *   ignores(field)              My Fleet never counts a locked (disabled)
 *                               field as changed. Edit User Info must not
 *                               skip disabled fields: State is disabled for
 *                               country OTHER and still has to travel.
 *   describe(field)             How a value reads to a person ("Washington",
 *                               not "WA"); defaults to the value itself.
 *
 * How each page shows its confirmation (a popup, a panel swapped in for the
 * form) stays with the page; only the list inside it is built here.
 *
 * Requires formValidation.js (MoffatBay.form.addCsrfField), loaded on every
 * page through the header. Load this before the page's own script.
 */
var MoffatBay = window.MoffatBay || {};

MoffatBay.editTracker = (function () {
    "use strict";

    /**
     * The control carrying a field's submitted value. Field names are the
     * element ids on both pages.
     * @param {string} field - a field name
     * @returns {Element|null} the input or select, or null if absent
     */
    function control(field) {
        return document.getElementById(field);
    }

    /**
     * A field's current value, trimmed.
     * @param {string} field - a field name
     * @returns {string} the value, or "" if the field isn't on the page
     */
    function valueOf(field) {
        var el = control(field);
        return el ? el.value.trim() : "";
    }

    /**
     * Puts a value into a confirmation cell. A blank value reads as "empty"
     * rather than as nothing at all.
     * @param {Element} el - the cell
     * @param {string} text - the value as it reads
     */
    function setValueText(el, text) {
        if (!text) {
            var em = document.createElement("em");
            em.textContent = "empty";
            el.appendChild(em);
        } else {
            el.textContent = text;
        }
    }

    /**
     * Makes a tracker for one form.
     * @param {Object} options
     * @param {string[]} options.fields - every field the page can write, in
     *        the order the confirmation should list them
     * @param {function(string, string, string): boolean} [options.same] -
     *        whether two values of a field count as the same; strict equality
     *        when left out
     * @param {function(string): boolean} [options.ignores] - true for a field
     *        that can't count as changed right now
     * @param {function(string): string} [options.describe] - how a field's
     *        current value reads to a person
     * @returns {Object} the tracker
     */
    function create(options) {
        var fields = options.fields;
        var describe = options.describe || valueOf;

        /* What each field held, and how it read, when editing began. The
           reading is captured rather than worked out later because a select
           can't always be asked afterwards: switching country rebuilds the
           state list, and the old state stops being one of its options. */
        var originals = {};
        var originalReadings = {};

        /**
         * Records what every field holds now, so "changed" means changed
         * from what is on file rather than from a keystroke ago.
         */
        function snapshot() {
            originals = {};
            originalReadings = {};
            fields.forEach(function (field) {
                originals[field] = valueOf(field);
                originalReadings[field] = describe(field);
            });
        }

        /**
         * @param {string} field - a field name
         * @returns {string} what the field held at the last snapshot
         */
        function original(field) {
            return originals[field] || "";
        }

        /**
         * @param {string} field - a field name
         * @returns {boolean} true if the field differs from what is on file
         */
        function hasChanged(field) {
            if (options.ignores && options.ignores(field)) { return false; }
            var before = original(field);
            var after = valueOf(field);
            return options.same ? !options.same(field, before, after) : before !== after;
        }

        /**
         * @returns {string[]} every changed field, in the tracker's order
         */
        function changedFields() {
            return fields.filter(hasChanged);
        }

        /**
         * Fills a confirmation list with one row per changed field, old on
         * the left and new on the right. Built from the form as it stands
         * right now, so what is listed and what gets submitted cannot drift
         * apart.
         * @param {Element} list - the <dl> to fill; emptied first
         * @param {string[]} changed - the fields about to be saved
         * @param {Object.<string, string>} labels - what each field is
         *        called to a person
         */
        function fillConfirmation(list, changed, labels) {
            list.textContent = "";

            changed.forEach(function (field) {
                var row = document.createElement("div");
                row.className = "change-summary__row";

                var term = document.createElement("dt");
                term.textContent = labels[field] || field;

                var detail = document.createElement("dd");

                var before = document.createElement("span");
                before.className = "change-summary__old";
                setValueText(before, originalReadings[field]);

                var arrow = document.createElement("span");
                arrow.className = "change-summary__arrow";
                arrow.textContent = "→";
                arrow.setAttribute("aria-label", "changing to");

                var after = document.createElement("span");
                after.className = "change-summary__new";
                setValueText(after, describe(field));

                detail.appendChild(before);
                detail.appendChild(arrow);
                detail.appendChild(after);
                row.appendChild(term);
                row.appendChild(detail);
                list.appendChild(row);
            });
        }

        /**
         * Builds the POST body by hand from the changed fields and submits
         * it through a throwaway form, instead of letting the browser
         * serialize the page's form.
         *
         * The page's form can't be trusted for this: an untouched field has
         * to be absent rather than empty, and a disabled control isn't sent
         * at all - a problem the moment State has to travel after a country
         * switch. Stripping names or disabling controls just before
         * submitting depends on exactly when the browser reads the form
         * back, and is one mistake away from a field that silently never
         * saves. Here every changed field goes by name, with its value read
         * straight off the control, disabled or not. A field the customer
         * blanked goes as an explicit empty value - that is what tells the
         * servlet to clear the column.
         *
         * @param {string} action - where to post
         * @param {string[]} changed - the fields to send
         * @param {Object.<string, string>} [extra] - other fields to send
         *        with them, e.g. the record's id
         */
        function submitOnlyChanged(action, changed, extra) {
            var carrier = document.createElement("form");
            carrier.method = "post";
            carrier.action = action;
            carrier.style.display = "none";
            MoffatBay.form.addCsrfField(carrier);

            function add(name, value) {
                var input = document.createElement("input");
                input.type = "hidden";
                input.name = name;
                input.value = value;
                carrier.appendChild(input);
            }

            Object.keys(extra || {}).forEach(function (name) { add(name, extra[name]); });
            changed.forEach(function (field) { add(field, valueOf(field)); });

            document.body.appendChild(carrier);
            carrier.submit();
        }

        return {
            snapshot: snapshot,
            original: original,
            hasChanged: hasChanged,
            changedFields: changedFields,
            fillConfirmation: fillConfirmation,
            submitOnlyChanged: submitOnlyChanged
        };
    }

    return {
        control: control,
        valueOf: valueOf,
        create: create
    };
})();
