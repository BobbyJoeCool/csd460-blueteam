package com.moffatbaymarina.marinawebsite.dao;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

import com.moffatbaymarina.marinawebsite.model.Customer;
import com.moffatbaymarina.marinawebsite.util.DBConnection;


/**
 * Data access object for the {@code Customer} table, covering account lookup
 * and the login-attempt / lockout bookkeeping used during authentication.
 *
 * @author Robert Breutzmann & Carolina Rodriguez
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
                + "streetAddress, streetAddress2, city, state, zipCode, dateJoined, failedLoginAttempts, accountLocked "
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

    /**
     * Demo reset: clears both the lock and the failed count for the given
     * email, standing in for "the user reset their password via email". No
     * password change happens here.
     *
     * @param email the customer's email address
     * @throws SQLException if the update fails
     */
    public void unlockAccount(String email) throws SQLException {
        String sql = "UPDATE Customer SET failedLoginAttempts = 0, accountLocked = 0 WHERE email = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, email);
            stmt.executeUpdate();
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
                    passwordHash,
                    dateJoined,
                    failedLoginAttempts,
                    accountLocked
                )
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, CURRENT_DATE, 0, 0)
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
            stmt.setString(11, passwordHash);

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
        Date dateJoined = rs.getDate("dateJoined");
        customer.setDateJoined(dateJoined != null ? dateJoined.toLocalDate() : null);
        customer.setFailedLoginAttempts(rs.getInt("failedLoginAttempts"));
        customer.setAccountLocked(rs.getBoolean("accountLocked"));
        return customer;
    }
}
