package com.moffatbaymarina.marinawebsite.dao;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Types;
import java.util.LinkedHashSet;
import java.util.Map;
import java.util.Set;

import com.moffatbaymarina.marinawebsite.model.Customer;
import com.moffatbaymarina.marinawebsite.util.DBConnection;


/**
 * Data access object for the {@code Customer} table, covering account lookup
 * and the login-attempt / lockout bookkeeping used during authentication.
 *
 * @author Robert Breutzmann & Carolina Rodriguez
 * Blue Team - Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
 * Primary Author/Owner - Robert Breutzmann & Carolina Rodriguez
 * @implNote JavaDoc comments in this file were added with the assistance of Claude.
 */
public class CustomerDAO {

    /**
     * Looks up a customer by email (the login identifier, see the Login
     * contract's "How the Username Works"). Never selects {@code passwordHash}
     * - see {@link #verifyPassword(String, String)} for the credential check.
     *
     * @param email the customer's email address
     * @return the matching {@link Customer}, or {@code null} if no match is found
     * @throws SQLException if the lookup fails
     */
    public Customer findByEmail(String email) throws SQLException {
        String sql = "SELECT customerID, firstName, lastName, email, phone, phoneCountryCode, "
                + "streetAddress, streetAddress2, city, state, zipCode, country, dateJoined, failedLoginAttempts, accountLocked "
                + "FROM Customer WHERE email = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, email);
            try (ResultSet rs = stmt.executeQuery()) {
                return rs.next() ? mapRow(rs) : null;
            }
        }
    }

    /**
     * Credential check for login: fetches the stored hash for the given email,
     * compares it to the already-hashed submission, and returns the result -
     * the hash itself never leaves this method, let alone lands on a
     * {@link Customer} bean.
     *
     * @param email the customer's email address
     * @param submittedHash the already-hashed password submitted by the caller
     * @return {@code true} if the hash matches; {@code false} for a mismatch
     *         or a non-existent email
     * @throws SQLException if the lookup fails
     */
    public boolean verifyPassword(String email, String submittedHash) throws SQLException {
        String sql = "SELECT passwordHash FROM Customer WHERE email = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, email);
            try (ResultSet rs = stmt.executeQuery()) {
                return rs.next() && submittedHash.equals(rs.getString("passwordHash"));
            }
        }
    }

    /**
     * Same credential check as {@link #verifyPassword(String, String)},
     * keyed by {@code customerID} instead of email. Prefer this overload
     * whenever the caller already has a trusted customer ID (from the
     * session, or from a {@link Customer} it just looked up) rather than
     * only an email address - email is no longer a stable identifier now
     * that {@code EditProfileServlet} lets a customer change it, so
     * looking a customer back up by email when an ID is already in hand
     * is both unnecessary and, in principle, one step less safe (a
     * customer's email is mutable state; their ID never changes).
     *
     * @param customerId the customer's ID
     * @param submittedHash the already-hashed password submitted by the caller
     * @return {@code true} if the hash matches; {@code false} for a mismatch
     *         or a non-existent ID
     * @throws SQLException if the lookup fails
     */
    public boolean verifyPassword(int customerId, String submittedHash) throws SQLException {
        String sql = "SELECT passwordHash FROM Customer WHERE customerID = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, customerId);
            try (ResultSet rs = stmt.executeQuery()) {
                return rs.next() && submittedHash.equals(rs.getString("passwordHash"));
            }
        }
    }

    /**
     * Clears the failed-attempt count after a successful login, so scattered
     * typos over time never add up.
     *
     * @param customerId the customer's ID
     * @throws SQLException if the update fails
     */
    public void resetFailedAttempts(int customerId) throws SQLException {
        String sql = "UPDATE Customer SET failedLoginAttempts = 0 WHERE customerID = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, customerId);
            stmt.executeUpdate();
        }
    }

    /**
     * Increments the failed-attempt count and returns the new total, so the
     * caller can tell whether this attempt just crossed the lockout threshold.
     *
     * @param customerId the customer's ID
     * @return the failed-attempt count after this increment
     * @throws SQLException if the update or lookup fails
     */
    public int recordFailedAttempt(int customerId) throws SQLException {
        String updateSql = "UPDATE Customer SET failedLoginAttempts = failedLoginAttempts + 1 WHERE customerID = ?";
        String selectSql = "SELECT failedLoginAttempts FROM Customer WHERE customerID = ?";
        try (Connection conn = DBConnection.getConnection()) {
            try (PreparedStatement update = conn.prepareStatement(updateSql)) {
                update.setInt(1, customerId);
                update.executeUpdate();
            }
            try (PreparedStatement select = conn.prepareStatement(selectSql)) {
                select.setInt(1, customerId);
                try (ResultSet rs = select.executeQuery()) {
                    rs.next();
                    return rs.getInt("failedLoginAttempts");
                }
            }
        }
    }

    /**
     * Locks the account, called once {@link #recordFailedAttempt(int)}'s
     * return value hits 3.
     *
     * @param customerId the customer's ID
     * @throws SQLException if the update fails
     */
    public void lockAccount(int customerId) throws SQLException {
        String sql = "UPDATE Customer SET accountLocked = 1 WHERE customerID = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, customerId);
            stmt.executeUpdate();
        }
    }

    /*
     * unlockAccount(String) used to live here - the Login page's demo
     * "Unlock Account" button (plain reset, no password involved). Retired
     * as part of the Edit User Info build: the Edit User Profile contract
     * ("Password Change and the Lockout Model") replaces it outright with
     * the forgot-password reset flow below (resetPasswordAndUnlock), which
     * a customer completes by proving a (simulated) verification code and
     * choosing a new password, rather than unlocking with no verification
     * at all.
     */

    /**
     * Columns on Customer this page is allowed to write through
     * {@link #updateCustomer(Connection, int, Map)}. Doubles as the
     * enforcement of the Edit User Profile contract's "Which Fields Are
     * Editable" table - customerID, passwordHash, dateJoined,
     * failedLoginAttempts and accountLocked must never be reachable
     * through this method no matter what a caller passes in, so they are
     * simply not in this set.
     */
    private static final Set<String> EDITABLE_COLUMNS = new LinkedHashSet<>(java.util.List.of(
            "firstName", "lastName", "email", "phone", "phoneCountryCode",
            "streetAddress", "streetAddress2", "city", "state", "zipCode", "country"
    ));

    /**
     * Columns that may legally be set to {@code NULL} by an empty-string
     * value in {@code changedFields} - every other column arriving empty
     * is a caller bug (a required field should have been rejected before
     * ever reaching this method), not a valid "clear it" request.
     *
     * <p>{@code state} is here alongside {@code streetAddress2} even
     * though the contract calls it "Required": it's only conditionally
     * required (not when {@code country} is {@code OTHER} - see
     * {@code EditProfileServlet.validate()}), and the schema itself
     * allows {@code NULL} on this column (no {@code NOT NULL} on
     * {@code Customer.state}), so a blank value here is a legitimate
     * "no state/province applies" case, not a caller bug.
     */
    private static final Set<String> NULLABLE_COLUMNS = Set.of("streetAddress2", "state");

    /**
     * Updates only the columns present in {@code changedFields}, per the
     * Edit User Profile contract's partial-update rule - never a single
     * fixed {@code UPDATE ... SET} touching every column. A key mapped to
     * an empty string means "set this column to NULL", and is only
     * honored for a column in {@link #NULLABLE_COLUMNS}; an empty value
     * for any other column is rejected as a caller bug rather than
     * silently written, since the servlet should have refused a blank
     * required field long before calling this.
     *
     * @param conn active transaction connection
     * @param customerId the customer being updated
     * @param changedFields column name -> new value, restricted to {@link #EDITABLE_COLUMNS}
     * @throws SQLException if the update fails, or if a key isn't an editable column,
     *         or if a required column is mapped to an empty value
     */
    public void updateCustomer(Connection conn, int customerId, Map<String, String> changedFields)
            throws SQLException {

        if (changedFields.isEmpty()) {
            return;
        }

        StringBuilder sql = new StringBuilder("UPDATE Customer SET ");
        boolean first = true;

        for (Map.Entry<String, String> field : changedFields.entrySet()) {
            String column = field.getKey();
            if (!EDITABLE_COLUMNS.contains(column)) {
                throw new SQLException("Column is not editable through updateCustomer: " + column);
            }
            String value = field.getValue();
            if ((value == null || value.isEmpty()) && !NULLABLE_COLUMNS.contains(column)) {
                throw new SQLException("Required column cannot be set blank: " + column);
            }
            if (!first) {
                sql.append(", ");
            }
            sql.append(column).append(" = ?");
            first = false;
        }
        sql.append(" WHERE customerID = ?");

        try (PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            int index = 1;
            for (String value : changedFields.values()) {
                if (value == null || value.isEmpty()) {
                    stmt.setNull(index, Types.VARCHAR);
                } else {
                    stmt.setString(index, value);
                }
                index++;
            }
            stmt.setInt(index, customerId);

            if (stmt.executeUpdate() != 1) {
                throw new SQLException("Customer update did not affect exactly one row.");
            }
        }
    }

    /**
     * Verifies and applies a plain password change - the Change Password
     * modal only ever reaches this after {@link #verifyPassword(String, String)}
     * has already confirmed the caller knows the current password. Never
     * touches {@code accountLocked}/{@code failedLoginAttempts}; see
     * {@link #resetPasswordAndUnlock(Connection, int, String)} for the
     * forgot-password path, which does.
     *
     * @param conn active transaction connection
     * @param customerId the customer whose password is changing
     * @param newPasswordHash the new password, already hashed via {@code Utils.hashPassword()}
     * @throws SQLException if the update fails
     */
    public void updatePassword(Connection conn, int customerId, String newPasswordHash) throws SQLException {
        String sql = "UPDATE Customer SET passwordHash = ? WHERE customerID = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, newPasswordHash);
            stmt.setInt(2, customerId);
            if (stmt.executeUpdate() != 1) {
                throw new SQLException("Password update did not affect exactly one row.");
            }
        }
    }

    /**
     * The forgot-password flow's password change: sets a new password hash
     * and, in the same transaction, clears {@code accountLocked} and
     * {@code failedLoginAttempts} - successfully completing this reset is
     * how a locked-out account unlocks itself now, replacing the old plain
     * "Unlock Account" demo button entirely (see the Edit User Profile
     * contract's "Password Change and the Lockout Model"). Never called
     * from the plain Change Password modal, which uses
     * {@link #updatePassword(Connection, int, String)} instead and must
     * never touch lockout state - that caller already proved they know
     * the current password.
     *
     * @param conn active transaction connection
     * @param customerId the customer resetting their password
     * @param newPasswordHash the new password, already hashed via {@code Utils.hashPassword()}
     * @throws SQLException if the update fails
     */
    public void resetPasswordAndUnlock(Connection conn, int customerId, String newPasswordHash) throws SQLException {
        String sql = "UPDATE Customer SET passwordHash = ?, failedLoginAttempts = 0, accountLocked = 0 "
                + "WHERE customerID = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, newPasswordHash);
            stmt.setInt(2, customerId);
            if (stmt.executeUpdate() != 1) {
                throw new SQLException("Password reset did not affect exactly one row.");
            }
        }
    }

    /**
     * Looks up a customer by ID rather than email - used for the session
     * refresh after a profile update, since {@code email} itself may be
     * the field that just changed, which would make a post-update
     * {@link #findByEmail(String)} unreliable. Never selects
     * {@code passwordHash}, same as {@link #findByEmail(String)}.
     *
     * @param conn active transaction connection
     * @param customerId the customer's ID
     * @return the matching {@link Customer}, or {@code null} if no match is found
     * @throws SQLException if the lookup fails
     */
    public Customer findById(Connection conn, int customerId) throws SQLException {
        String sql = "SELECT customerID, firstName, lastName, email, phone, phoneCountryCode, "
                + "streetAddress, streetAddress2, city, state, zipCode, country, dateJoined, failedLoginAttempts, accountLocked "
                + "FROM Customer WHERE customerID = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, customerId);
            try (ResultSet rs = stmt.executeQuery()) {
                return rs.next() ? mapRow(rs) : null;
            }
        }
    }

    /**
     * Duplicate-email check for an UPDATE rather than an INSERT: excludes
     * the customer's own current row, so a customer "changing" their
     * email to the value it already is doesn't get rejected as a
     * duplicate of themselves. {@link #findByEmail(String)} can't do this
     * - there's always exactly one existing row to exempt here, unlike
     * Registration's INSERT case where no such row exists yet.
     *
     * @param conn active transaction connection
     * @param email the email being changed to
     * @param customerId the customer making the change, excluded from the match
     * @return {@code true} if some other customer already has this email
     * @throws SQLException if the lookup fails
     */
    public boolean emailInUseByAnotherCustomer(Connection conn, String email, int customerId) throws SQLException {
        String sql = "SELECT customerID FROM Customer WHERE email = ? AND customerID != ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, email);
            stmt.setInt(2, customerId);
            try (ResultSet rs = stmt.executeQuery()) {
                return rs.next();
            }
        }
    }

    /**
     * Inserts a new customer and returns the generated customer ID.
     *
     * @param conn active transaction connection
     * @param customer customer being registered
     * @param passwordHash hashed customer password
     * @return generated customer ID
     * @throws SQLException if the insert fails
     */
    public int insertCustomer(
            Connection conn,
            Customer customer,
            String passwordHash) throws SQLException {

        String sql = """
                INSERT INTO Customer (
                    firstName,
                    lastName,
                    email,
                    phone,
                    phoneCountryCode,
                    streetAddress,
                    streetAddress2,
                    city,
                    state,
                    zipCode,
                    country,
                    passwordHash,
                    dateJoined,
                    failedLoginAttempts,
                    accountLocked
                )
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, CURRENT_DATE, 0, 0)
                """;

        try (PreparedStatement stmt = conn.prepareStatement(
                sql,
                Statement.RETURN_GENERATED_KEYS)) {

            stmt.setString(1, customer.getFirstName());
            stmt.setString(2, customer.getLastName());
            stmt.setString(3, customer.getEmail());
            stmt.setString(4, customer.getPhone());
            stmt.setString(5, customer.getPhoneCountryCode());
            stmt.setString(6, customer.getStreetAddress());
            stmt.setString(7, customer.getStreetAddress2());
            stmt.setString(8, customer.getCity());
            stmt.setString(9, customer.getState());
            stmt.setString(10, customer.getZipCode());
            stmt.setString(11, customer.getCountry());
            stmt.setString(12, passwordHash);

            if (stmt.executeUpdate() != 1) {
                throw new SQLException(
                        "Customer registration did not insert one row.");
            }

            try (ResultSet keys = stmt.getGeneratedKeys()) {
                if (keys.next()) {
                    return keys.getInt(1);
                }
            }

            throw new SQLException(
                    "Customer registration did not return an ID.");
        }
    }
    /**
     * Maps the current row of the given result set to a {@link Customer}.
     * Never reads {@code passwordHash}.
     *
     * @param rs a result set positioned on a valid Customer row
     * @return the populated {@link Customer}
     * @throws SQLException if a column can't be read
     */
    private Customer mapRow(ResultSet rs) throws SQLException {
        Customer customer = new Customer();
        customer.setCustomerId(rs.getInt("customerID"));
        customer.setFirstName(rs.getString("firstName"));
        customer.setLastName(rs.getString("lastName"));
        customer.setEmail(rs.getString("email"));
        customer.setPhone(rs.getString("phone"));
        customer.setPhoneCountryCode(rs.getString("phoneCountryCode"));
        customer.setStreetAddress(rs.getString("streetAddress"));
        customer.setStreetAddress2(rs.getString("streetAddress2"));
        customer.setCity(rs.getString("city"));
        customer.setState(rs.getString("state"));
        customer.setZipCode(rs.getString("zipCode"));
        customer.setCountry(rs.getString("country"));
        Date dateJoined = rs.getDate("dateJoined");
        customer.setDateJoined(dateJoined != null ? dateJoined.toLocalDate() : null);
        customer.setFailedLoginAttempts(rs.getInt("failedLoginAttempts"));
        customer.setAccountLocked(rs.getBoolean("accountLocked"));
        return customer;
    }
}
