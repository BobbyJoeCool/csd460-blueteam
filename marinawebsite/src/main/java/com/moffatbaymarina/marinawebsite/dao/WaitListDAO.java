package com.moffatbaymarina.marinawebsite.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * Data access for the {@code WaitList} table.
 *
 * <p>Only what the reservation page's "all slips full" prompt needs - join
 * the wait list for a slip size, and check whether the customer is already
 * on it. The Wait List Lookup page (position in queue, cancelling an entry)
 * is a separate, not-yet-built page and gets its own DAO methods when that
 * work starts.
 *
 * @author Robert Breutzmann
 */
public class WaitListDAO {

    /**
     * Whether the customer already has an open ({@code Waiting}) entry for
     * the given slip size.
     *
     * @param conn an open connection
     * @param customerId the customer to check
     * @param slipSizeFt the slip size category in feet, e.g. {@code 40}
     * @return {@code true} if a {@code Waiting} entry already exists
     * @throws SQLException if the lookup fails
     */
    public boolean isWaiting(Connection conn, int customerId, int slipSizeFt) throws SQLException {
        String sql = """
                SELECT 1
                FROM WaitList w
                JOIN SlipSize sz ON sz.slipSizeID = w.slipSizeID
                WHERE w.customerID = ?
                  AND sz.sizeFt = ?
                  AND w.status = 'Waiting'
                """;

        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, customerId);
            stmt.setInt(2, slipSizeFt);
            try (ResultSet rs = stmt.executeQuery()) {
                return rs.next();
            }
        }
    }

    /**
     * Adds the customer to the wait list for a slip size.
     *
     * @param conn an open connection
     * @param customerId the customer joining the wait list
     * @param slipSizeFt the slip size category in feet, e.g. {@code 40}
     * @throws SQLException if the insert fails, including if
     *         {@code slipSizeFt} doesn't match a known {@code SlipSize}
     */
    public void insert(Connection conn, int customerId, int slipSizeFt) throws SQLException {
        String sql = """
                INSERT INTO WaitList (customerID, slipSizeID, status)
                VALUES (?, (SELECT slipSizeID FROM SlipSize WHERE sizeFt = ?), 'Waiting')
                """;

        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, customerId);
            stmt.setInt(2, slipSizeFt);
            if (stmt.executeUpdate() != 1) {
                throw new SQLException("Wait list entry did not insert one row.");
            }
        }
    }
}
