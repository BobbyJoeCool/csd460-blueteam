package com.moffatbaymarina.marinawebsite.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Everything the site holds about one customer, for the "Download my data"
 * file on Your Account (issue #337, see AccountDataServlet).
 *
 * <p>Each method returns plain rows, column alias -&gt; value, so the
 * aliases below are the field names the customer sees in the file. They're
 * worded for a reader rather than copied from the schema, and nothing
 * internal goes in: no passwordHash, no row IDs, no lockout counters.
 *
 * <p>Read-only, and every query is keyed by the customer ID the caller took
 * from the session.
 *
 * @author Miguel Fernandez
 * Blue Team - Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
 * Primary Author/Owner - Miguel Fernandez
 */
public class AccountDataDAO {

    /**
     * The customer's own details, as one row.
     *
     * @param conn an open connection
     * @param customerId the signed-in customer
     * @return the account row, or an empty list if there's no such customer
     * @throws SQLException if the lookup fails
     */
    public List<Map<String, Object>> account(Connection conn, int customerId) throws SQLException {
        return rows(conn, """
                SELECT firstName, lastName, email,
                       phoneCountryCode, phone,
                       streetAddress, streetAddress2, city, state, zipCode, country,
                       dateJoined AS memberSince
                FROM Customer
                WHERE customerID = ?
                """, customerId);
    }

    /**
     * Every boat the customer owns or has owned, with when it joined and
     * left their fleet. A boat bought, sold and bought back shows twice.
     *
     * @param conn an open connection
     * @param customerId the signed-in customer
     * @return the boats, oldest ownership first
     * @throws SQLException if the lookup fails
     */
    public List<Map<String, Object>> boats(Connection conn, int customerId) throws SQLException {
        return rows(conn, """
                SELECT b.boatName, b.boatType,
                       b.boatLength AS lengthFt, b.boatBeam AS beamFt, b.boatYear AS year,
                       b.HIN AS hullIdentificationNumber, b.regNumber AS registrationNumber,
                       bo.startDate AS inFleetFrom, bo.endDate AS inFleetUntil
                FROM BoatOwnership bo
                JOIN Boat b ON b.boatID = bo.boatID
                WHERE bo.customerID = ?
                ORDER BY bo.startDate, bo.ownershipID
                """, customerId);
    }

    /**
     * Every reservation in the customer's name, with its 30-day notice if
     * it has one.
     *
     * @param conn an open connection
     * @param customerId the signed-in customer
     * @return the reservations, oldest start date first
     * @throws SQLException if the lookup fails
     */
    public List<Map<String, Object>> reservations(Connection conn, int customerId) throws SQLException {
        return rows(conn, """
                SELECT r.confirmationNumber,
                       r.reservationStatus AS status,
                       b.boatName,
                       CONCAT(d.dockNumber, '-', LPAD(s.slipNumber, 2, '0')) AS slip,
                       sz.sizeFt AS slipSizeFt,
                       r.startDate,
                       r.monthlyRate,
                       r.electricalHookup AS electricHookup,
                       tn.noticeDate AS noticeGivenOn,
                       tn.terminationDate AS lastDay,
                       tn.noticeStatus
                FROM Reservation r
                JOIN Boat b ON b.boatID = r.boatID
                JOIN Slip s ON s.slipID = r.slipID
                JOIN Dock d ON d.dockID = s.dockID
                JOIN SlipSize sz ON sz.slipSizeID = s.slipSizeID
                LEFT JOIN TerminationNotice tn ON tn.reservationID = r.reservationID
                WHERE r.customerID = ?
                ORDER BY r.startDate, r.reservationID
                """, customerId);
    }

    /**
     * Every wait list entry the customer has had, open or closed.
     *
     * @param conn an open connection
     * @param customerId the signed-in customer
     * @return the entries, oldest first
     * @throws SQLException if the lookup fails
     */
    public List<Map<String, Object>> waitList(Connection conn, int customerId) throws SQLException {
        return rows(conn, """
                SELECT sz.sizeFt AS slipSizeFt, w.status, w.timeJoined AS joined, w.timeClosed AS closed
                FROM WaitList w
                JOIN SlipSize sz ON sz.slipSizeID = w.slipSizeID
                WHERE w.customerID = ?
                ORDER BY w.timeJoined, w.waitListID
                """, customerId);
    }

    /**
     * Contact-form messages sent from the customer's current email address.
     * The Contact table has no link to Customer (anyone can send one
     * without an account), so the email is the only thing to match on.
     *
     * @param conn an open connection
     * @param customerId the signed-in customer
     * @return the messages, oldest first
     * @throws SQLException if the lookup fails
     */
    public List<Map<String, Object>> contactMessages(Connection conn, int customerId) throws SQLException {
        return rows(conn, """
                SELECT ct.reasonForContact AS reason, ct.message,
                       ct.boatName, ct.boatLength AS boatLengthFt,
                       ct.responded, ct.respondedDate, ct.respondedMessage AS reply
                FROM Contact ct
                JOIN Customer c ON c.email = ct.email
                WHERE c.customerID = ?
                ORDER BY ct.contactID
                """, customerId);
    }

    /**
     * Runs a query with one customer ID parameter and returns every row as
     * column label -&gt; value, in column order.
     */
    private List<Map<String, Object>> rows(Connection conn, String sql, int customerId) throws SQLException {
        List<Map<String, Object>> rows = new ArrayList<>();
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, customerId);
            try (ResultSet rs = stmt.executeQuery()) {
                ResultSetMetaData meta = rs.getMetaData();
                while (rs.next()) {
                    Map<String, Object> row = new LinkedHashMap<>();
                    for (int i = 1; i <= meta.getColumnCount(); i++) {
                        row.put(meta.getColumnLabel(i), rs.getObject(i));
                    }
                    rows.add(row);
                }
            }
        }
        return rows;
    }
}
