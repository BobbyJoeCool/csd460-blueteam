package com.moffatbaymarina.marinawebsite.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.LinkedHashMap;
import java.util.Locale;
import java.util.Map;

import com.moffatbaymarina.marinawebsite.dao.CustomerDAO;
import com.moffatbaymarina.marinawebsite.model.Customer;
import com.moffatbaymarina.marinawebsite.util.DBConnection;
import com.moffatbaymarina.marinawebsite.util.Utils;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * Implements the Edit User Info page's main profile form, per
 * {@code marinawebsite/documentation/Page Contracts/Edit User Profile.md}.
 *
 * <p>Partial update only: a field is only ever written if the form actually
 * submitted a value for it (see {@link #touched(HttpServletRequest, String)}) -
 * a value simply being absent from the request means "not changing this",
 * never "clear it." An optional field (only {@code streetAddress2} today)
 * submitted present-but-empty means "clear it." A required field submitted
 * present-but-empty is treated as a structural/tampering error and rejects
 * the whole request immediately, before ordinary validation even runs - see
 * the contract's "Partial Update" section.
 *
 * <p>Password changes are a fully separate submission - see
 * {@link EditProfilePasswordServlet}. This servlet never reads or writes
 * {@code passwordHash}.
 *
 * @author Robert Breutzmann
 * Blue Team - Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
 * Primary Author/Owner - Robert Breutzmann
 * @implNote JavaDoc comments in this file were added with the assistance of Claude.
 */
@WebServlet("/editProfile")
public class EditProfileServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    /*
     * The full set of Customer columns this page can write, in the order
     * the "current info" summary box on editUserInfo.jsp renders them.
     * Mirrors CustomerDAO.EDITABLE_COLUMNS - kept as a separate list here
     * since this one also drives display order and required-ness, which
     * the DAO's allow-list doesn't need to know about.
     */
    private static final String[] EDITABLE_FIELDS = {
            "firstName", "lastName", "email", "phoneCountryCode", "phone",
            "streetAddress", "streetAddress2", "city", "state", "zipCode", "country"
    };

    private static final java.util.Set<String> REQUIRED_FIELDS = java.util.Set.of(
            "firstName", "lastName", "email", "phoneCountryCode", "phone",
            "streetAddress", "city", "zipCode", "country"
    );

    private static final java.util.Set<String> VALID_COUNTRIES = java.util.Set.of("US", "CA", "OTHER");

    private final CustomerDAO customerDAO = new CustomerDAO();

    /**
     * Redirect-if-not-logged-in guard, then forward to the real page.
     * Everything the page needs to render is already in the session
     * (see the contract's "Pre-populated data source" decision) - this
     * handler has nothing else to do.
     *
     * @param request the incoming GET
     * @param response the response to redirect or forward
     * @throws ServletException if the forward fails
     * @throws IOException if the redirect or forward fails
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || !Boolean.TRUE.equals(session.getAttribute("loggedIn"))) {
            // Exact target for a logged-out hit isn't specified anywhere in
            // the contract (see the implementation plan's Gaps #7) - the
            // landing page is the same default LoginServlet falls back to.
            response.sendRedirect(request.getContextPath() + "/");
            return;
        }

        // A successful save redirects here with ?notice=profileUpdated
        // (see doPost) rather than forwarding directly, so a page refresh
        // reloads the page instead of re-submitting the save - same
        // problem RegisterServlet already avoids by redirecting on its
        // own success case. The diff can't ride along on a redirect's
        // request attributes (a redirect is a brand new request), so it's
        // stashed in the session for exactly one read: promoted to a
        // request attribute here, then removed immediately, so a later
        // refresh of this same page doesn't keep re-showing an old diff.
        Object diff = session.getAttribute("profileUpdateDiff");
        if (diff != null) {
            request.setAttribute("changes", diff);
            session.removeAttribute("profileUpdateDiff");
        }

        request.getRequestDispatcher("/editUserInfo.jsp").forward(request, response);
    }

    /**
     * Handles a profile-fields submission: figures out which fields were
     * actually touched, validates all of them together (collecting every
     * failure rather than stopping at the first), and only if that whole
     * pass is clean does it write anything - see the contract's "Validate
     * Everything First" and "Partial Update" sections.
     *
     * @param request the incoming POST
     * @param response the response to redirect or forward
     * @throws ServletException if the update fails
     * @throws IOException if the forward fails
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        Object customerIdAttr = session == null ? null : session.getAttribute("customerId");
        Object customerAttr = session == null ? null : session.getAttribute("customer");
        if (!(customerIdAttr instanceof Integer customerId) || !(customerAttr instanceof Customer current)) {
            response.sendRedirect(request.getContextPath() + "/");
            return;
        }

        // ------------------------------------------------------------
        // 1. Figure out which fields were touched, and reject outright
        //    if a required one arrived present-but-blank - a distinct,
        //    structural failure, never a normal per-field message.
        // ------------------------------------------------------------
        Map<String, String> submitted = new LinkedHashMap<>();
        for (String field : EDITABLE_FIELDS) {
            if (!touched(request, field)) {
                continue;
            }
            String value = Utils.clean(request.getParameter(field));
            if (value.isEmpty() && REQUIRED_FIELDS.contains(field)) {
                request.setAttribute("formError",
                        "That request could not be processed. Please reload the page and try again.");
                request.getRequestDispatcher("/editUserInfo.jsp").forward(request, response);
                return;
            }
            submitted.put(field, value);
        }

        if (submitted.isEmpty()) {
            // Nothing touched - not an error, just nothing to do.
            request.getRequestDispatcher("/editUserInfo.jsp").forward(request, response);
            return;
        }

        // ------------------------------------------------------------
        // 2. Validate every touched field, collecting every failure.
        // ------------------------------------------------------------
        String effectiveCountry = submitted.getOrDefault("country", current.getCountry());
        if (effectiveCountry != null) {
            effectiveCountry = effectiveCountry.toUpperCase(Locale.ROOT);
        }

        // A disabled <select> never submits a value, so switching country
        // to OTHER makes state look "untouched" under partial update even
        // though the old state code needs to be cleared - the front end
        // can't submit it blank either (state is normally required, and a
        // blank required field is a structural rejection), so this has to
        // be a server-side rule: country actively becoming OTHER means
        // state becomes NULL, regardless of what the form did or didn't
        // send. Keyed off the raw submitted country value, not
        // effectiveCountry, so this only fires when country is actually
        // being changed in this submission - an OTHER-country customer
        // editing something unrelated shouldn't get a spurious "state
        // changed to blank" on every unrelated save.
        if ("OTHER".equals(submitted.get("country")) && !submitted.containsKey("state")) {
            submitted.put("state", "");
        }

        Map<String, String> fieldErrors = validate(submitted, effectiveCountry);

        if (!fieldErrors.isEmpty()) {
            request.setAttribute("fieldErrors", fieldErrors);
            request.setAttribute("formError", "Please fix the highlighted fields below.");
            request.getRequestDispatcher("/editUserInfo.jsp").forward(request, response);
            return;
        }

        // Normalize the same way RegisterServlet does before anything is compared or saved.
        if (submitted.containsKey("email")) {
            submitted.put("email", submitted.get("email").toLowerCase(Locale.ROOT));
        }
        if (submitted.containsKey("state") && !submitted.get("state").isEmpty()) {
            submitted.put("state", submitted.get("state").toUpperCase(Locale.ROOT));
        }
        if (submitted.containsKey("country")) {
            submitted.put("country", submitted.get("country").toUpperCase(Locale.ROOT));
        }

        // ------------------------------------------------------------
        // 3. Capture old values before writing anything - needed for the
        //    before/after diff summary the contract asks for.
        // ------------------------------------------------------------
        Map<String, String[]> changes = new LinkedHashMap<>();
        for (Map.Entry<String, String> field : submitted.entrySet()) {
            String oldValue = oldValue(current, field.getKey());
            if (!oldValue.equals(field.getValue())) {
                changes.put(field.getKey(), new String[] { oldValue, field.getValue() });
            }
        }

        if (changes.isEmpty()) {
            // Every touched field was resubmitted unchanged - nothing to write.
            request.getRequestDispatcher("/editUserInfo.jsp").forward(request, response);
            return;
        }

        // ------------------------------------------------------------
        // 4. Duplicate-email check + write, one transaction.
        // ------------------------------------------------------------
        Customer refreshed;
        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                if (submitted.containsKey("email")
                        && customerDAO.emailInUseByAnotherCustomer(conn, submitted.get("email"), customerId)) {
                    conn.rollback();
                    request.setAttribute("fieldErrors", Map.of("email", "An account with this email already exists."));
                    request.setAttribute("formError", "Please fix the highlighted fields below.");
                    request.getRequestDispatcher("/editUserInfo.jsp").forward(request, response);
                    return;
                }

                Map<String, String> changedOnly = new LinkedHashMap<>();
                for (String field : changes.keySet()) {
                    changedOnly.put(field, submitted.get(field));
                }
                customerDAO.updateCustomer(conn, customerId, changedOnly);
                conn.commit();
                refreshed = customerDAO.findById(conn, customerId);
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (SQLException e) {
            throw new ServletException("Profile update failed.", e);
        }

        // ------------------------------------------------------------
        // 5. Refresh the session so the header greeting and every other
        //    page reading sessionScope.customer see the new values right
        //    away, not just after the next login.
        // ------------------------------------------------------------
        if (refreshed != null) {
            session.setAttribute("customer", refreshed);
            session.setAttribute("displayName", refreshed.getDisplayName());
        }

        // Redirect, not forward - a refresh of the result page then just
        // reloads it instead of re-submitting the same update. The diff
        // can't travel as a request attribute across a redirect, so it
        // rides in the session for the one read doGet gives it above; the
        // confirmation toast reuses the same ?notice= mechanism statusPopup.js
        // already understands (loggedIn, registered, passwordReset).
        session.setAttribute("profileUpdateDiff", changes);
        response.sendRedirect(request.getContextPath() + "/editProfile?notice=profileUpdated");
    }

    /**
     * Whether {@code field} was present in the submitted form at all -
     * distinct from {@code getParameter} returning null, which can't tell
     * "absent" apart from "present but empty." That distinction is the
     * whole partial-update mechanism (see the contract's "Partial Update"
     * section): absent means untouched, present-but-empty means either
     * "clear it" (optional fields) or a structural error (required ones).
     */
    private boolean touched(HttpServletRequest request, String field) {
        return request.getParameterMap().containsKey(field);
    }

    /**
     * The customer's current value for one of {@link #EDITABLE_FIELDS},
     * normalized to a plain (never-null) {@code String} the same way a
     * submitted value is, so the two are directly comparable when
     * building the before/after diff.
     */
    private String oldValue(Customer customer, String field) {
        String value = switch (field) {
            case "firstName" -> customer.getFirstName();
            case "lastName" -> customer.getLastName();
            case "email" -> customer.getEmail();
            case "phoneCountryCode" -> customer.getPhoneCountryCode();
            case "phone" -> customer.getPhone();
            case "streetAddress" -> customer.getStreetAddress();
            case "streetAddress2" -> customer.getStreetAddress2();
            case "city" -> customer.getCity();
            case "state" -> customer.getState();
            case "zipCode" -> customer.getZipCode();
            case "country" -> customer.getCountry();
            default -> null;
        };
        return value == null ? "" : value;
    }

    /**
     * Per-field format validation for every touched field, collecting
     * every failure rather than stopping at the first (contract's
     * "Validate Everything First, Then Write Nothing or Write Everything").
     * Mirrors the same rules {@code RegisterServlet.validateCustomer()}
     * already enforces for these columns.
     *
     * @param submitted touched field name -> submitted value (already trimmed)
     * @param effectiveCountry the country this submission will end up with -
     *        either the touched value, or the customer's existing one
     * @return field name -> message, empty if every touched field is valid
     */
    private Map<String, String> validate(Map<String, String> submitted, String effectiveCountry) {
        Map<String, String> errors = new LinkedHashMap<>();

        putIf(errors, submitted, "firstName", v -> v.length() > 50, "First name cannot exceed 50 characters.");
        putIf(errors, submitted, "lastName", v -> v.length() > 50, "Last name cannot exceed 50 characters.");

        putIf(errors, submitted, "email",
                v -> v.length() > 100 || !Utils.EMAIL_PATTERN.matcher(v).matches(),
                "Enter a valid email address.");

        putIf(errors, submitted, "phoneCountryCode",
                v -> !Utils.COUNTRY_CODE_PATTERN.matcher(v).matches(),
                "Enter a valid country code.");

        putIf(errors, submitted, "phone",
                v -> !Utils.PHONE_PATTERN.matcher(v).matches(),
                "Phone number must contain exactly 10 digits.");

        putIf(errors, submitted, "streetAddress", v -> v.length() > 100, "Street address cannot exceed 100 characters.");
        putIf(errors, submitted, "streetAddress2", v -> v.length() > 100, "Address line 2 cannot exceed 100 characters.");
        putIf(errors, submitted, "city", v -> v.length() > 50, "City cannot exceed 50 characters.");

        if (submitted.containsKey("state") && !submitted.get("state").isEmpty()
                && submitted.get("state").length() != 2) {
            errors.put("state", "State/Province must be a 2-letter code.");
        }
        if (submitted.containsKey("state") && submitted.get("state").isEmpty()
                && !"OTHER".equals(effectiveCountry)) {
            errors.put("state", "State/Province is required.");
        }

        putIf(errors, submitted, "zipCode",
                v -> !Utils.ZIP_PATTERN.matcher(v).matches(),
                "Enter a valid ZIP code.");

        if (submitted.containsKey("country") && !VALID_COUNTRIES.contains(submitted.get("country").toUpperCase(Locale.ROOT))) {
            errors.put("country", "Select a valid country.");
        }

        return errors;
    }

    private interface FieldCheck {
        boolean fails(String value);
    }

    private void putIf(Map<String, String> errors, Map<String, String> submitted,
                        String field, FieldCheck check, String message) {
        if (!submitted.containsKey(field)) {
            return;
        }
        String value = submitted.get(field);
        // Blank is handled up front as a structural error for required
        // fields, and as "clear it" for optional ones - format checks
        // below only apply once there's an actual value to check.
        if (value.isEmpty()) {
            return;
        }
        if (check.fails(value)) {
            errors.put(field, message);
        }
    }
}
