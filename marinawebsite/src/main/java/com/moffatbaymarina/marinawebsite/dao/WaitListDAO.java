package com.moffatbaymarina.marinawebsite.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import com.moffatbaymarina.marinawebsite.model.WaitListEntry;

/**
 * Data access for the {@code WaitList} table.
 *
 * <p>Two pages read this table. The Reservation page's "all slips full"
 * prompt joins the wait list ({@link #lockForCustomer}, {@link #isWaiting}
 * and {@link #insert}); the Wait List Lookup page reads it back
 * ({@link #countInLineBySize} and {@link #findOpenEntriesForCustomer}) and
 * lets a customer leave ({@link #cancelEntryForCustomer}).
 *
 * <p><strong>In line</strong> means {@code Waiting} or {@code Offered}
 * throughout. An offered customer hasn't answered yet and is still ahead of
 * everyone behind them, so they are counted; {@code Fulfilled} and
 * {@code Cancelled} are closed and never are.
 *
 * <p>Position in the queue isn't stored - see the ERD's design decisions.
 * It is worked out from {@code timeJoined} (BR-20), which is why
 * {@link #findOpenEntriesForCustomer} counts rather than reads it.
 *
 * @author Robert Breutzmann
 * Blue Team - Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
 * Primary Author/Owner - Robert Breutzmann
 * @implNote The two Wait List Lookup methods were added by Miguel Fernandez
 *           for Module 9, per the Wait List contract's Database Returns.
 */
public class WaitListDAO {

    /**
     * Locks the customer's row until the caller's transaction ends, so two
     * joins from the same customer at once (a double-click, two tabs) run
     * one after the other. Without it both could pass {@link #isWaiting}
     * before either inserted, and the customer would stand in line twice.
     *
     * <p>Call it before {@link #isWaiting}, with auto-commit off. MySQL
     * takes a transaction's snapshot at its first plain read, so a check
     * made after this lock is released to it sees whatever the other join
     * committed.
     *
     * @param conn an open connection with auto-commit off
     * @param customerId the customer joining
     * @throws SQLException if the lock fails
     */
    public void lockForCustomer(Connection conn, int customerId) throws SQLException {
        String sql = "SELECT customerID FROM Customer WHERE customerID = ? FOR UPDATE";

        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, customerId);
            try (ResultSet rs = stmt.executeQuery()) {
                rs.next();
            }
        }
    }

    /**
     * Whether the customer is already in line for the given slip size: one
     * entry per size per customer.
     *
     * <p>In line means {@code Waiting} or {@code Offered}, the same as
     * everywhere else in this class. Checking {@code Waiting} alone let a
     * customer who had been offered a slip join the same list again and be
     * counted twice.
     *
     * @param conn an open connection
     * @param customerId the customer to check
     * @param slipSizeFt the slip size category in feet, e.g. {@code 40}
     * @return {@code true} if a {@code Waiting} or {@code Offered} entry
     *         already exists
     * @throws SQLException if the lookup fails
     */
    public boolean isWaiting(Connection conn, int customerId, int slipSizeFt) throws SQLException {
        String sql = """
                SELECT 1
                FROM WaitList w
                JOIN SlipSize sz ON sz.slipSizeID = w.slipSizeID
                WHERE w.customerID = ?
                  AND sz.sizeFt = ?
                  AND w.status IN ('Waiting', 'Offered')
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

    /**
     * How many customers are in line for each slip size.
     *
     * <p>Driven from {@code SlipSize} with a LEFT JOIN, so every size the
     * marina has comes back whether or not anyone is waiting on it - the
     * page's grid shows a card per size, and a missing key would silently
     * drop one.
     *
     * @param conn an open connection
     * @return slip size in feet to the number in line, smallest size first;
     *         {@code 0} for a size nobody is waiting on
     * @throws SQLException if the lookup fails
     */
    public Map<Integer, Integer> countInLineBySize(Connection conn) throws SQLException {
        String sql = """
                SELECT sz.sizeFt AS sizeFt,
                       COUNT(w.waitListID) AS inLineCount
                FROM SlipSize sz
                LEFT JOIN WaitList w
                       ON w.slipSizeID = sz.slipSizeID
                      AND w.status IN ('Waiting', 'Offered')
                GROUP BY sz.sizeFt
                ORDER BY sz.sizeFt
                """;

        Map<Integer, Integer> counts = new LinkedHashMap<>();

        try (PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                counts.put(rs.getInt("sizeFt"), rs.getInt("inLineCount"));
            }
        }

        return counts;
    }

    /**
     * One customer's open wait list entries, each already knowing how many
     * people are ahead of it.
     *
     * <p>{@code peopleAhead} is counted in SQL rather than by walking the
     * whole line in Java: the subquery counts in-line entries for the same
     * slip size that joined earlier, with a lower {@code waitListID}
     * breaking a tie on {@code timeJoined}. Two customers can never be
     * handed the same position, and no other customer's row is ever read
     * into memory.
     *
     * @param conn an open connection
     * @param customerId the signed-in customer, taken from the session and
     *        never from the request
     * @return the customer's {@code Waiting} and {@code Offered} entries,
     *         smallest slip size first; empty, never {@code null}, if they
     *         are not on any list
     * @throws SQLException if the lookup fails
     */
    public List<WaitListEntry> findOpenEntriesForCustomer(Connection conn, int customerId)
            throws SQLException {

        String sql = """
                SELECT w.waitListID  AS waitListID,
                       sz.sizeFt     AS sizeFt,
                       w.status      AS status,
                       w.timeJoined  AS timeJoined,
                       (SELECT COUNT(*)
                          FROM WaitList ahead
                         WHERE ahead.slipSizeID = w.slipSizeID
                           AND ahead.status IN ('Waiting', 'Offered')
                           AND (ahead.timeJoined < w.timeJoined
                                OR (ahead.timeJoined = w.timeJoined
                                    AND ahead.waitListID < w.waitListID))
                       ) AS peopleAhead
                FROM WaitList w
                JOIN SlipSize sz ON sz.slipSizeID = w.slipSizeID
                WHERE w.customerID = ?
                  AND w.status IN ('Waiting', 'Offered')
                ORDER BY sz.sizeFt
                """;

        List<WaitListEntry> entries = new ArrayList<>();

        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, customerId);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    WaitListEntry entry = new WaitListEntry();
                    entry.setWaitListId(rs.getInt("waitListID"));
                    entry.setSizeFt(rs.getInt("sizeFt"));
                    entry.setStatus(rs.getString("status"));
                    entry.setPeopleAhead(rs.getInt("peopleAhead"));

                    Timestamp joined = rs.getTimestamp("timeJoined");
                    entry.setTimeJoined(joined == null ? null : joined.toLocalDateTime());

                    entries.add(entry);
                }
            }
        }

        return entries;
    }

    /**
     * Takes one entry off the list when the customer leaves it from the
     * Wait List page (issue #346). The entry becomes {@code Cancelled}
     * rather than being deleted, the same as on account deletion, so the
     * order the list was in can still be checked.
     *
     * <p>The {@code customerID} condition is the ownership check: an ID
     * edited in the form that belongs to someone else matches no row.
     *
     * @param conn an open connection
     * @param waitListId the entry to close, as posted by the page
     * @param customerId the signed-in customer, taken from the session and
     *        never from the request
     * @return {@code true} if the entry was theirs and still in line
     * @throws SQLException if the update fails
     */
    public boolean cancelEntryForCustomer(Connection conn, int waitListId, int customerId)
            throws SQLException {
        String sql = """
                UPDATE WaitList
                SET status = 'Cancelled', timeClosed = CURRENT_TIMESTAMP
                WHERE waitListID = ?
                  AND customerID = ?
                  AND status IN ('Waiting', 'Offered')
                """;

        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, waitListId);
            stmt.setInt(2, customerId);
            return stmt.executeUpdate() == 1;
        }
    }

    /**
     * Takes a customer off every list they're still in line on, for account
     * deletion (issue #337). Entries become {@code Cancelled} rather than
     * being deleted, so the order the list was in can still be checked.
     *
     * @param conn an open connection, in the deletion's transaction
     * @param customerId the customer whose account is being deleted
     * @return how many entries were closed
     * @throws SQLException if the update fails
     */
    public int cancelOpenEntriesForCustomer(Connection conn, int customerId) throws SQLException {
        String sql = """
                UPDATE WaitList
                SET status = 'Cancelled', timeClosed = CURRENT_TIMESTAMP
                WHERE customerID = ?
                  AND status IN ('Waiting', 'Offered')
                """;

        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, customerId);
            return stmt.executeUpdate();
        }
    }
}
