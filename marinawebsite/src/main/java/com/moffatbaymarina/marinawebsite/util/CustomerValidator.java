package com.moffatbaymarina.marinawebsite.util;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;

/**
 * Shared server-side checks for a customer's own details (name, email,
 * phone, address, country), issue #284. Registration and Edit User Info
 * both use {@link #validate}, so the same value can't be accepted on one
 * page and refused on the other, and the same mistake reads the same on
 * both. Like {@link BoatValidator}, it returns every failing field rather
 * than stopping at the first.
 *
 * <p>Passwords aren't customer fields and stay with each page:
 * Registration checks its two password boxes itself, and Edit User Info
 * changes the password through its own popup and servlet.
 *
 * Blue Team - Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
 * Primary Author/Owner - Robert Breutzmann
 */
public final class CustomerValidator {

    /** The three Country choices. OTHER has no state or province. */
    public static final Set<String> VALID_COUNTRIES = Set.of("US", "CA", "OTHER");

    /**
     * Fields that can't be blank. State is deliberately absent: it is
     * required only when the country has states (see {@link #validate}).
     */
    public static final Set<String> REQUIRED_FIELDS = Set.of(
            "firstName", "lastName", "email", "phoneCountryCode", "phone",
            "streetAddress", "city", "zipCode", "country");

    /** Every field checked here, in form order - the order errors come back in. */
    private static final List<String> FIELDS = List.of(
            "firstName", "lastName", "email", "phoneCountryCode", "phone",
            "streetAddress", "streetAddress2", "city", "state", "zipCode", "country");

    private static final String REQUIRED_MESSAGE = "Please complete all required fields.";

    private CustomerValidator() {
    }

    /**
     * Checks the submitted customer fields.
     *
     * <p>Only fields present in {@code submitted} are checked, and a blank
     * value skips the format checks, so Edit User Info can pass just the
     * fields that changed (a blank optional field there means "clear it").
     * Registration passes every field with {@code requireAll}, which first
     * refuses any blank required field - and stops there, so its banner
     * still says "Please complete all required fields." before anything
     * about format.
     *
     * @param submitted field name to trimmed value
     * @param effectiveCountry the country the customer will have after this
     *        save (US, CA or OTHER), which decides whether State is required
     * @param requireAll {@code true} for a new customer, where every
     *        required field must be filled in
     * @return field name to message, in form order; empty when all is well
     */
    public static Map<String, String> validate(Map<String, String> submitted,
            String effectiveCountry, boolean requireAll) {

        Map<String, String> errors = new LinkedHashMap<>();
        boolean hasStates = !"OTHER".equals(effectiveCountry);

        if (requireAll) {
            for (String field : FIELDS) {
                if (REQUIRED_FIELDS.contains(field) && Utils.isBlank(submitted.get(field))) {
                    errors.put(field, REQUIRED_MESSAGE);
                }
            }
            if (hasStates && Utils.isBlank(submitted.get("state"))) {
                errors.put("state", "State/Province is required.");
            }
            if (!errors.isEmpty()) {
                return errors;
            }
        }

        check(errors, submitted, "firstName", v -> v.length() > 50,
                "First name cannot exceed 50 characters.");
        check(errors, submitted, "lastName", v -> v.length() > 50,
                "Last name cannot exceed 50 characters.");
        check(errors, submitted, "email",
                v -> v.length() > 100 || !Utils.EMAIL_PATTERN.matcher(v).matches(),
                "Enter a valid email address.");
        check(errors, submitted, "phoneCountryCode",
                v -> !Utils.COUNTRY_CODE_PATTERN.matcher(v).matches(),
                "Enter a valid country code.");
        check(errors, submitted, "phone",
                v -> !Utils.PHONE_PATTERN.matcher(v).matches(),
                "Phone number must contain exactly 10 digits.");
        check(errors, submitted, "streetAddress", v -> v.length() > 100,
                "Street address cannot exceed 100 characters.");
        check(errors, submitted, "streetAddress2", v -> v.length() > 100,
                "Address line 2 cannot exceed 100 characters.");
        check(errors, submitted, "city", v -> v.length() > 50,
                "City cannot exceed 50 characters.");
        check(errors, submitted, "state", v -> v.length() != 2,
                "State/Province must be a 2-letter code.");

        // A blank state is fine for OTHER and refused otherwise. Only when
        // state was sent: Edit User Info doesn't send an untouched one.
        if (submitted.containsKey("state") && Utils.isBlank(submitted.get("state")) && hasStates) {
            errors.put("state", "State/Province is required.");
        }

        check(errors, submitted, "zipCode",
                v -> !Utils.ZIP_PATTERN.matcher(v).matches(),
                "Enter a valid ZIP code.");
        check(errors, submitted, "country",
                v -> !VALID_COUNTRIES.contains(v.toUpperCase(Locale.ROOT)),
                "Select a valid country.");

        return errors;
    }

    /** One format rule for one field. */
    private interface Rule {
        boolean fails(String value);
    }

    /**
     * Records {@code message} for {@code field} if it was submitted, isn't
     * blank, and fails the rule. Blank is a question for the required
     * check, not for format.
     */
    private static void check(Map<String, String> errors, Map<String, String> submitted,
            String field, Rule rule, String message) {
        String value = submitted.get(field);
        if (Utils.isBlank(value) || errors.containsKey(field)) {
            return;
        }
        if (rule.fails(value)) {
            errors.put(field, message);
        }
    }
}
