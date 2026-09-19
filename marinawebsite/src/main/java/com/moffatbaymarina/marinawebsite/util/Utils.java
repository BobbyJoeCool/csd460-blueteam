package com.moffatbaymarina.marinawebsite.util;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.Year;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.Locale;
import java.util.regex.Pattern;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;

/**
 * Shared validation and hashing helpers used across the marina website.
 *
 * <p>Every rule here that the browser also checks has a twin in
 * {@code js/formValidation.js} ({@code MoffatBay.form}). When a rule or
 * limit changes, change both files in the same commit - the whole point of
 * keeping one copy per side is that the page and the server can never
 * disagree about what's valid.
 *
 * <p>The {@code parse*} helpers all return {@code null} for "missing or not
 * valid" and never throw, so a servlet can parse first and decide what a
 * {@code null} means for that field afterwards.
 *
 * @author Breutzmann, R. (Blue Team)
 * @author White, S. (Blue Team)
 * @author Fernandez, M. (Blue Team)
 * @author Rodriguez, C. (Blue Team)
 * Blue Team - Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
 * Primary Author/Owner - Shared (all four)
 * @implNote JavaDoc comments in this file were added with the assistance of Claude.
 */
public class Utils {

    /*
     * Requires local-part chars, "@", domain chars, a dot, then 2+ letter
     * TLD. Canonical copy - this used to also be duplicated (slightly
     * differently - missing "%") as RegisterServlet.EMAIL_PATTERN. Consolidated
     * here as part of the Edit User Info build, per that page's plan
     * (DevNotes/Plans/edit-user-info-implementation-plan.md, Gap #6/#8):
     * two near-identical copies could in principle accept/reject a
     * different set of addresses from each other, which is exactly the
     * kind of drift this class exists to prevent.
     */
    public static final Pattern EMAIL_PATTERN = Pattern.compile(
        "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
    );

    /** Exactly 10 digits - the shared notion of "a phone number" once the country code is split off. */
    public static final Pattern PHONE_PATTERN = Pattern.compile("^\\d{10}$");

    /** 1 to 3 digits, no leading zero - matches Customer.phoneCountryCode's VARCHAR(3). */
    public static final Pattern COUNTRY_CODE_PATTERN = Pattern.compile("^[1-9]\\d{0,2}$");

    /** A 5-digit ZIP, optionally followed by a hyphen and the ZIP+4 suffix. */
    public static final Pattern ZIP_PATTERN = Pattern.compile("^\\d{5}(-\\d{4})?$");

    /** 10+ characters, at least one uppercase, one lowercase, one digit, one of {@code ! $ % * #}. */
    public static final Pattern PASSWORD_PATTERN = Pattern.compile(
        "^(?=.*[A-Z])(?=.*[a-z])(?=.*\\d)(?=.*[!$%*#]).{10,}$");

    // ------------------------------------------------------------------
    // Boat rules. Twins in formValidation.js - keep both in step.
    // ------------------------------------------------------------------

    /**
     * Hull Identification Number: 3 letters, then 9 letters/digits, per 33 CFR
     * 181.23. Twin of formValidation.js's HIN_PATTERN.
     */
    public static final Pattern HIN_PATTERN = Pattern.compile("^[A-Za-z]{3}[A-Za-z0-9]{9}$");

    /**
     * US state Certificate of Number, per 33 CFR 174.17: a 2-letter state
     * prefix, 4 to 7 digits, then 2 letters, with an optional space or hyphen
     * between groups. Twin of formValidation.js's REG_NUMBER_PATTERN.
     *
     * <p>Consolidated from two servlet copies that had drifted: Registration
     * allowed only a space between groups, the Reservation boat panel (and the
     * browser) allowed a space or a hyphen - so "WN-1234-AB" passed the
     * browser on Registration and was then rejected by the server.
     */
    public static final Pattern REG_NUMBER_PATTERN =
            Pattern.compile("^[A-Za-z]{2}[- ]?\\d{4,7}[- ]?[A-Za-z]{2}$");

    /**
     * Canadian Pleasure Craft Licence: a literal "C", 4 to 8 digits, then 2
     * letters, with an optional space or hyphen before the letters. Twin of
     * formValidation.js's CA_REG_NUMBER_PATTERN.
     */
    public static final Pattern CA_REG_NUMBER_PATTERN =
            Pattern.compile("^C\\d{4,8}[- ]?[A-Za-z]{2}$");

    /** Earliest boat model year accepted. Twin of formValidation.js's MIN_BOAT_YEAR. */
    public static final int MIN_BOAT_YEAR = 1800;

    /**
     * Largest boat length or beam, in feet. Matches Boat.boatLength's
     * DECIMAL(4,1). Twin of formValidation.js's MAX_BOAT_DIMENSION.
     */
    public static final BigDecimal MAX_BOAT_DIMENSION = new BigDecimal("999.9");

    /** The slip sizes the marina has, in feet, smallest first. */
    private static final int[] SLIP_SIZES_FT = { 26, 40, 50 };

    // ------------------------------------------------------------------
    // Dates and reservation filters.
    // ------------------------------------------------------------------

    /** Earliest year a reservation filter accepts. */
    public static final int MIN_RESERVATION_YEAR = 2000;

    /** How many years past the current one a reservation filter accepts. */
    public static final int MAX_RESERVATION_YEARS_AHEAD = 5;

    /**
     * The site-wide display format for a date, e.g. "Jun 1, 2026". Every
     * {@code <fmt:formatDate>} on the site uses this same pattern, and
     * formValidation.js's formatDisplayDate produces the same shape.
     */
    public static final String DISPLAY_DATE_PATTERN = "MMM d, yyyy";

    private static final DateTimeFormatter DISPLAY_DATE_FORMAT =
            DateTimeFormatter.ofPattern(DISPLAY_DATE_PATTERN, Locale.US);

    private Utils() {
    }

    /**
     * Checks whether a string is a plausible email address shape.
     *
     * @param email the address to check; may be {@code null}
     * @return {@code true} if non-null and it matches {@link #EMAIL_PATTERN}, {@code false} otherwise
     */
    public static boolean isValidEmail(String email) {
        return email != null && EMAIL_PATTERN.matcher(email).matches();
    }

    /**
     * Hashes a plaintext password with unsalted SHA-256, per the Login
     * contract's predecided hashing choice. Registration must call this
     * exact same method when a password is created, or a customer's
     * password will never match again on login - do not reimplement
     * this hash anywhere else.
     *
     * @param plainPassword the raw password to hash; never stored or logged
     * @return the SHA-256 digest as lowercase hex, matching MySQL's own
     *         {@code SHA2(x, 256)} output, in case a query ever needs to
     *         compare against it directly
     */
    public static String hashPassword(String plainPassword) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hashBytes = digest.digest(plainPassword.getBytes(StandardCharsets.UTF_8));
            StringBuilder hex = new StringBuilder(hashBytes.length * 2);
            for (byte b : hashBytes) {
                hex.append(String.format("%02x", b));
            }
            return hex.toString();
        } catch (NoSuchAlgorithmException e) {
            // Every JDK ships SHA-256, this is unreachable in practice.
            throw new IllegalStateException("SHA-256 algorithm not available", e);
        }
    }

    // ------------------------------------------------------------------
    // Reading form input
    // ------------------------------------------------------------------

    /**
     * Trims a submitted value, turning {@code null} into "".
     *
     * @param value the raw parameter; may be {@code null}
     * @return the trimmed value, never {@code null}
     */
    public static String clean(String value) {
        return value == null ? "" : value.trim();
    }

    /**
     * Turns {@code null} into "" without trimming - for passwords, where
     * leading and trailing spaces are part of what was typed.
     *
     * @param value the raw parameter; may be {@code null}
     * @return the value as-is, or "" if it was {@code null}
     */
    public static String orEmpty(String value) {
        return value == null ? "" : value;
    }

    /**
     * Whether a value is missing: {@code null}, empty, or only whitespace.
     *
     * @param value the value to check
     * @return {@code true} if there's nothing there
     */
    public static boolean isBlank(String value) {
        return value == null || value.isBlank();
    }

    /**
     * Blank becomes {@code null}, for optional columns that should be stored
     * as NULL rather than an empty string.
     *
     * @param value the value to check
     * @return {@code null} if blank, otherwise the value unchanged
     */
    public static String emptyToNull(String value) {
        return isBlank(value) ? null : value;
    }

    /**
     * Parses a whole number.
     *
     * @param value the text to parse; surrounding whitespace is ignored
     * @return the number, or {@code null} if blank or not a whole number
     */
    public static Integer parseInt(String value) {
        if (isBlank(value)) {
            return null;
        }
        try {
            return Integer.valueOf(value.trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }

    /**
     * Parses a whole number that has to fall within a range.
     *
     * @param value the text to parse
     * @param min the smallest allowed value, inclusive
     * @param max the largest allowed value, inclusive
     * @return the number, or {@code null} if blank, not a number, or out of range
     */
    public static Integer parseIntInRange(String value, int min, int max) {
        Integer number = parseInt(value);
        return number != null && number >= min && number <= max ? number : null;
    }

    /**
     * Parses a decimal number.
     *
     * @param value the text to parse; surrounding whitespace is ignored
     * @return the number, or {@code null} if blank or not a number
     */
    public static BigDecimal parseDecimal(String value) {
        if (isBlank(value)) {
            return null;
        }
        try {
            return new BigDecimal(value.trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }

    /**
     * Parses a {@code yyyy-MM-dd} date - the format every
     * {@code <input type="date">} submits, whatever the browser displays.
     *
     * @param value the text to parse
     * @return the date, or {@code null} if blank or not a real date
     */
    public static LocalDate parseDate(String value) {
        if (isBlank(value)) {
            return null;
        }
        try {
            return LocalDate.parse(value.trim());
        } catch (DateTimeParseException e) {
            return null;
        }
    }

    // ------------------------------------------------------------------
    // Boat rules
    // ------------------------------------------------------------------

    /**
     * Whether a boat length or beam is in range: more than 0, and no more
     * than {@link #MAX_BOAT_DIMENSION}.
     *
     * @param feet the parsed value; may be {@code null}
     * @return {@code true} if present and in range
     */
    public static boolean isValidBoatDimension(BigDecimal feet) {
        return feet != null
                && feet.compareTo(BigDecimal.ZERO) > 0
                && feet.compareTo(MAX_BOAT_DIMENSION) <= 0;
    }

    /**
     * Whether a boat model year is plausible: {@link #MIN_BOAT_YEAR} through
     * the current year (nobody registers a boat that hasn't been built).
     *
     * @param year the parsed year; may be {@code null}
     * @return {@code true} if present and in range
     */
    public static boolean isValidBoatYear(Integer year) {
        return year != null && year >= MIN_BOAT_YEAR && year <= Year.now().getValue();
    }

    /**
     * Whether a HIN is well-formed (see {@link #HIN_PATTERN}).
     *
     * @param hin the HIN to check; may be {@code null}
     * @return {@code true} if it matches
     */
    public static boolean isValidHin(String hin) {
        return hin != null && HIN_PATTERN.matcher(hin).matches();
    }

    /**
     * Whether a Registration Number matches its country's format. OTHER has
     * no defined format, so anything is accepted for it.
     *
     * @param regNumber the number to check; may be {@code null}
     * @param country "US", "CA" or "OTHER"
     * @return {@code true} if it matches (or the country has no format)
     */
    public static boolean isValidRegNumber(String regNumber, String country) {
        if (regNumber == null) {
            return false;
        }
        if ("CA".equals(country)) {
            return CA_REG_NUMBER_PATTERN.matcher(regNumber).matches();
        }
        if ("US".equals(country)) {
            return REG_NUMBER_PATTERN.matcher(regNumber).matches();
        }
        return true;
    }

    /**
     * The smallest slip a boat of this length fits in.
     *
     * @param boatLength the boat's length in feet; may be {@code null}
     * @return 26, 40 or 50, or 0 if the boat is missing or longer than every slip
     */
    public static int slipSizeFor(BigDecimal boatLength) {
        if (boatLength == null) {
            return 0;
        }
        for (int size : SLIP_SIZES_FT) {
            if (boatLength.compareTo(BigDecimal.valueOf(size)) <= 0) {
                return size;
            }
        }
        return 0;
    }

    /**
     * Whether a number is one of the marina's slip sizes.
     *
     * @param sizeFt the size to check; may be {@code null}
     * @return {@code true} for 26, 40 or 50
     */
    public static boolean isSlipSize(Integer sizeFt) {
        if (sizeFt == null) {
            return false;
        }
        for (int size : SLIP_SIZES_FT) {
            if (size == sizeFt) {
                return true;
            }
        }
        return false;
    }

    // ------------------------------------------------------------------
    // Money and dates
    // ------------------------------------------------------------------

    /**
     * Converts dollars to whole cents, rounding half up - the form the
     * Reservation page's JavaScript does its arithmetic in.
     *
     * @param dollars the amount in dollars
     * @return the amount in cents
     */
    public static int toCents(BigDecimal dollars) {
        return dollars.movePointRight(2)
                .setScale(0, RoundingMode.HALF_UP)
                .intValueExact();
    }

    /**
     * Formats a date the site-wide way ({@link #DISPLAY_DATE_PATTERN}), for a
     * {@code LocalDate} - which JSTL's {@code <fmt:formatDate>} can't read.
     *
     * @param date the date; may be {@code null}
     * @return e.g. "Sep 15, 2026", or "" if there's no date
     */
    public static String formatDisplayDate(LocalDate date) {
        return date == null ? "" : DISPLAY_DATE_FORMAT.format(date);
    }

    // ------------------------------------------------------------------
    // Requests, sessions and responses
    // ------------------------------------------------------------------

    /**
     * The signed-in customer's ID, read from the session LoginServlet set up.
     * Never creates a session for an anonymous visitor.
     *
     * @param request the incoming request
     * @return the customer ID, or {@code null} if nobody is signed in
     */
    public static Integer signedInCustomerId(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) {
            return null;
        }
        Object value = session.getAttribute("customerId");
        return value instanceof Integer id ? id : null;
    }

    /**
     * Returns {@code redirectTo} only if it's a path on this site, otherwise
     * {@code fallback} - so a crafted link can't bounce a visitor who just
     * signed in off to somebody else's site.
     *
     * <p>Rejects "//evil.example" and "/\evil.example" (browsers treat both
     * as a different host) and anything carrying a scheme.
     *
     * @param redirectTo the requested target; may be {@code null}
     * @param fallback where to go instead, e.g. "/"
     * @return a safe site-relative path
     */
    public static String safeRedirectTarget(String redirectTo, String fallback) {
        boolean looksSafe = !isBlank(redirectTo)
                && redirectTo.startsWith("/")
                && !redirectTo.startsWith("//")
                && !redirectTo.startsWith("/\\")
                && !redirectTo.contains("://");
        return looksSafe ? redirectTo : fallback;
    }

    /**
     * Whether a database error was a duplicate-key / constraint violation,
     * e.g. an email or boat registration that's already on file.
     *
     * @param e the error
     * @return {@code true} for MySQL error 1062 or any SQLState 23xxx
     */
    public static boolean isDuplicateKey(SQLException e) {
        return e.getErrorCode() == 1062
                || (e.getSQLState() != null && e.getSQLState().startsWith("23"));
    }

    /**
     * Escapes a value for use inside a JSON string literal.
     *
     * @param value the text; may be {@code null}
     * @return the escaped text, or "" for {@code null}
     */
    public static String jsonEscape(String value) {
        if (value == null) {
            return "";
        }
        StringBuilder out = new StringBuilder(value.length() + 8);
        for (char c : value.toCharArray()) {
            switch (c) {
                case '\\' -> out.append("\\\\");
                case '"' -> out.append("\\\"");
                case '\r' -> out.append("\\r");
                case '\n' -> out.append("\\n");
                case '\t' -> out.append("\\t");
                default -> {
                    if (c < 0x20) {
                        out.append(String.format("\\u%04x", (int) c));
                    } else {
                        out.append(c);
                    }
                }
            }
        }
        return out.toString();
    }
}
