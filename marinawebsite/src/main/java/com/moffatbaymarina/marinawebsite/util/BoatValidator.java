package com.moffatbaymarina.marinawebsite.util;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.LinkedHashMap;
import java.util.Locale;
import java.util.Map;

import com.moffatbaymarina.marinawebsite.dao.BoatDAO;
import com.moffatbaymarina.marinawebsite.model.Boat;

import jakarta.servlet.http.HttpServletRequest;

/**
 * @author Carolina R.
 * Blue Team - Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
 * Primary Author/Owner - Carolina R.
 *
 * Provides shared server-side validation for boat information. Every
 * add-a-boat path uses {@link #validateAdd} - Registration, Book a Slip's
 * Register a Boat panel and My Fleet - and My Fleet's Edit uses
 * {@link #validateEdit}, so the same boat can't be accepted on one page and
 * refused on another. Each returns every failing field before any database
 * changes are made.
 */
public final class BoatValidator {

    private BoatValidator() {
    }

    /**
     * Cleans the values submitted from the Add Boat form.
     */
    public static Map<String, String> cleanBoatValues(
            HttpServletRequest request) {

        Map<String, String> values = new LinkedHashMap<>();

        values.put(
                "boatName",
                Utils.clean(request.getParameter("boatName"))
        );

        values.put(
                "boatType",
                Utils.clean(request.getParameter("boatType"))
        );

        values.put(
                "boatLength",
                Utils.clean(request.getParameter("boatLength"))
        );

        values.put(
                "boatBeam",
                Utils.clean(request.getParameter("boatBeam"))
        );

        values.put(
                "hin",
                Utils.clean(request.getParameter("hin"))
                        .toUpperCase(Locale.ROOT)
        );

        values.put(
                "regNumber",
                Utils.clean(request.getParameter("regNumber"))
                        .toUpperCase(Locale.ROOT)
        );

        values.put(
                "boatYear",
                Utils.clean(request.getParameter("boatYear"))
        );

        return values;
    }

    /**
     * Validates all fields when adding a new boat.
     *
     * <p>{@code requireIdentifier} is the one rule the add paths differ on,
     * on purpose. Registration passes {@code false}: a boat with neither a
     * HIN nor a Registration Number is saved, and the page suggests calling
     * the marina (Registration contract; BR-08, Boats Without a HIN). Book a
     * Slip and My Fleet pass {@code true}, because a boat with no identifier
     * shouldn't be reservable (Reservation contract).
     *
     * @param conn an open connection, for the duplicate checks
     * @param boatDAO the DAO the duplicate checks use
     * @param values the cleaned form values, see {@link #cleanBoatValues}
     * @param country the owner's country, which decides the Registration
     *        Number format
     * @param requireIdentifier whether a HIN or Registration Number is required
     * @param customerId the customer adding the boat, or {@code null} at
     *        Registration, where the account doesn't exist yet
     * @return field name to message, in form order; empty when valid
     * @throws SQLException if a duplicate check fails
     */
    public static Map<String, String> validateAdd(
            Connection conn,
            BoatDAO boatDAO,
            Map<String, String> values,
            String country,
            boolean requireIdentifier,
            Integer customerId)
            throws SQLException {

        Map<String, String> errors = new LinkedHashMap<>();

        String boatName =
                values.getOrDefault("boatName", "");

        String boatType =
                values.getOrDefault("boatType", "");

        String boatLengthText =
                values.getOrDefault("boatLength", "");

        String boatBeamText =
                values.getOrDefault("boatBeam", "");

        String hin =
                values.getOrDefault("hin", "");

        String regNumber =
                values.getOrDefault("regNumber", "");

        String boatYearText =
                values.getOrDefault("boatYear", "");

        // Boat name
        if (boatName.isBlank()) {
            errors.put(
                    "boatName",
                    "Enter a name for the boat."
            );

        } else if (boatName.length() > 50) {
            errors.put(
                    "boatName",
                    "Boat Name cannot exceed 50 characters."
            );
        }

        // Boat type
        if (boatType.length() > 30) {
            errors.put(
                    "boatType",
                    "Boat Type cannot exceed 30 characters."
            );
        }

        // Boat length
        BigDecimal boatLength =
                Utils.parseDecimal(boatLengthText);

        if (!Utils.isValidBoatDimension(boatLength)) {
            errors.put(
                    "boatLength",
                    "Enter a valid boat length."
            );
        }

        // Boat beam is optional
        if (!boatBeamText.isBlank()) {

            BigDecimal boatBeam =
                    Utils.parseDecimal(boatBeamText);

            if (!Utils.isValidBoatDimension(boatBeam)) {
                errors.put(
                        "boatBeam",
                        "Enter a valid boat beam."
                );
            }
        }

        // Boat year is optional
        if (!boatYearText.isBlank()) {

            Integer boatYear =
                    Utils.parseInt(boatYearText);

            if (!Utils.isValidBoatYear(boatYear)) {
                errors.put(
                        "boatYear",
                        "Enter a valid four-digit boat year."
                );
            }
        }

        // Book a Slip and My Fleet need either a HIN or Registration Number
        if (requireIdentifier && hin.isBlank() && regNumber.isBlank()) {
            errors.put(
                    "boatSection",
                    "Enter either a HIN or a Registration Number."
            );
        }

        // HIN
        if (!hin.isBlank()
                && !Utils.isValidHin(hin)) {

            errors.put(
                    "hin",
                    HIN_MESSAGE
            );
        }

        // Registration Number
        if (!regNumber.isBlank()
                && !Utils.isValidRegNumber(
                        regNumber,
                        country
                )) {

            errors.put(
                    "regNumber",
                    registrationMessage(country)
            );
        }

        // Already on file? Only checked once both identifiers are well-formed.
        if (!errors.containsKey("hin") && !errors.containsKey("regNumber")) {
            checkBoatOnFile(conn, boatDAO, hin, regNumber, customerId, errors);
        }

        return errors;
    }

    /**
     * What to do when a boat being added is already on file (#254).
     * Removing a boat ends its ownership but keeps its row, so the same boat
     * can come back - re-added by its owner, or added by whoever bought it.
     * Only a boat someone currently owns is refused; one nobody owns passes
     * here and is reclaimed by {@code BoatDAO.addOrReclaim}, keeping its ID
     * and history.
     */
    private static void checkBoatOnFile(
            Connection conn,
            BoatDAO boatDAO,
            String hin,
            String regNumber,
            Integer customerId,
            Map<String, String> errors)
            throws SQLException {

        BoatDAO.IdentifierMatch hinMatch = null;
        BoatDAO.IdentifierMatch regMatch = null;

        for (BoatDAO.IdentifierMatch match
                : boatDAO.findIdentifierMatches(conn, hin, regNumber)) {

            if (!hin.isBlank() && hin.equals(match.hin())) {
                hinMatch = match;
            }
            if (!regNumber.isBlank() && regNumber.equals(match.regNumber())) {
                regMatch = match;
            }
        }

        if (hinMatch == null && regMatch == null) {
            return;
        }

        // The HIN names one boat and the registration number another.
        if (hinMatch != null && regMatch != null
                && hinMatch.boatId() != regMatch.boatId()) {
            errors.put("boatSection",
                    "That HIN and registration number belong to two different boats. "
                            + "Please contact the marina office.");
            return;
        }

        // Matched on registration number alone, but the boat on file has a
        // different HIN: a HIN is the hull's permanent ID, so it's another boat.
        if (hinMatch == null && !hin.isBlank()
                && regMatch.hin() != null && !regMatch.hin().equals(hin)) {
            errors.put("regNumber",
                    "That registration number belongs to another boat. "
                            + "Please contact the marina office.");
            return;
        }

        BoatDAO.IdentifierMatch match = hinMatch != null ? hinMatch : regMatch;
        String field = hinMatch != null ? "hin" : "regNumber";

        if (match.ownerId() == null) {
            return; // nobody owns it now: reclaimed on save
        }

        if (match.ownerId().equals(customerId)) {
            errors.put(field, "That boat is already in your fleet.");
        } else {
            // Never say whose it is.
            errors.put(field,
                    "This boat is registered to another account. "
                            + "Please contact the marina office.");
        }
    }

    /**
     * Validates only the fields that were changed on Edit.
     */
    public static Map<String, String> validateEdit(
            Connection conn,
            BoatDAO boatDAO,
            Boat current,
            Map<String, String> changed,
            String country)
            throws SQLException {

        Map<String, String> errors = new LinkedHashMap<>();

        // Boat name
        if (changed.containsKey("boatName")) {

            String boatName =
                    changed.get("boatName");

            if (boatName == null || boatName.isBlank()) {
                errors.put(
                        "boatName",
                        "Enter a name for the boat."
                );

            } else if (boatName.length() > 50) {
                errors.put(
                        "boatName",
                        "Boat Name cannot exceed 50 characters."
                );
            }
        }

        // Boat type
        if (changed.containsKey("boatType")) {

            String boatType =
                    changed.get("boatType");

            if (boatType != null
                    && boatType.length() > 30) {

                errors.put(
                        "boatType",
                        "Boat Type cannot exceed 30 characters."
                );
            }
        }

        // Boat beam
        if (changed.containsKey("boatBeam")) {

            String boatBeamText =
                    changed.get("boatBeam");

            if (boatBeamText != null
                    && !boatBeamText.isBlank()) {

                BigDecimal boatBeam =
                        Utils.parseDecimal(boatBeamText);

                if (!Utils.isValidBoatDimension(boatBeam)) {
                    errors.put(
                            "boatBeam",
                            "Enter a valid boat beam."
                    );
                }
            }
        }

        // Boat year
        if (changed.containsKey("boatYear")) {

            String boatYearText =
                    changed.get("boatYear");

            if (boatYearText != null
                    && !boatYearText.isBlank()) {

                Integer boatYear =
                        Utils.parseInt(boatYearText);

                if (!Utils.isValidBoatYear(boatYear)) {
                    errors.put(
                            "boatYear",
                            "Enter a valid four-digit boat year."
                    );
                }
            }
        }

        // HIN
        if (changed.containsKey("hin")) {

            String hin =
                    changed.get("hin");

            if (hin != null
                    && !hin.isBlank()
                    && !Utils.isValidHin(hin)) {

                errors.put(
                        "hin",
                        HIN_MESSAGE
                );

            } else if (hin != null
                    && !hin.isBlank()
                    && boatDAO.hinInUseByAnotherBoat(
                            conn,
                            hin,
                            current.getBoatId()
                    )) {

                errors.put(
                        "hin",
                        "That HIN is already in use."
                );
            }
        }

        // Registration Number
        if (changed.containsKey("regNumber")) {

            String regNumber =
                    changed.get("regNumber");

            if (regNumber != null
                    && !regNumber.isBlank()
                    && !Utils.isValidRegNumber(
                            regNumber,
                            country
                    )) {

                errors.put(
                        "regNumber",
                        registrationMessage(country)
                );

            } else if (regNumber != null
                    && !regNumber.isBlank()
                    && boatDAO.regNumberInUseByAnotherBoat(
                            conn,
                            regNumber,
                            current.getBoatId()
                    )) {

                errors.put(
                        "regNumber",
                        "That boat registration is already in use."
                );
            }
        }

        /*
         * Find out what the final HIN and Registration Number
         * will be after the edit.
         */
        String finalHin =
                changed.containsKey("hin")
                        ? changed.get("hin")
                        : current.getHIN();

        String finalRegNumber =
                changed.containsKey("regNumber")
                        ? changed.get("regNumber")
                        : current.getRegNumber();

        // A boat must still have at least one identifier.
        if ((finalHin == null || finalHin.isBlank())
                && (finalRegNumber == null
                || finalRegNumber.isBlank())) {

            errors.put(
                    "boatSection",
                    "Enter either a HIN or a Registration Number."
            );
        }

        return errors;
    }

    /** Says what a HIN looks like, rather than only that this one is wrong. */
    private static final String HIN_MESSAGE =
            "HIN should be 12 characters: 3 letters, then 9 more letters or numbers.";

    private static String registrationMessage(
            String country) {

        if ("CA".equalsIgnoreCase(country)) {
            return "Enter a valid Canadian Registration Number, e.g. C1234 AB.";
        }

        if ("US".equalsIgnoreCase(country)) {
            return "Enter a valid Registration Number, including the state prefix, e.g. WN1234 AB.";
        }

        return "Enter a valid Registration Number.";
    }
}