package com.moffatbaymarina.marinawebsite.dao;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import com.moffatbaymarina.marinawebsite.model.DockAvailability;
import com.moffatbaymarina.marinawebsite.model.Reservation;
import com.moffatbaymarina.marinawebsite.model.ReservationDetails;
import com.moffatbaymarina.marinawebsite.util.DBConnection;

/**
 * Data access for the {@code Reservation} table.
 *
 * <p>This file currently holds the read side only - what the Reservation
 * Summary page needs to look a booking up and to cancel it. The booking
 * insert, slip assignment and availability queries belong to the Reservation
 * page and are being added separately; both halves live here on purpose so
 * there is one place that knows how a reservation is stored.
 *
 * @author Miguel Fernandez
 * @author Sara White
 * Blue Team: Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
 * @implNote JavaDoc comments in this file were added with the assistance of Claude.
 */
public class ReservationDAO {

    /*
     * One join rather than four lookups. A reservation row is mostly IDs, and
     * every one of them turns into something the page shows: the boat's name,
     * which dock, which slip, what size. The Rate row comes along for the
     * electric fee so the total can be itemised - LEFT JOIN because a missing
     * rate row should blank one line, not lose the whole reservation.
     */
    private static final String SELECT_DETAILS = """
            SELECT  r.reservationID,
                    r.confirmationNumber,
                    r.customerID,
                    r.startDate,
                    r.monthlyRate,
                    r.reservationStatus,
                    r.electricalHookup,
                    b.boatName,
                    b.boatType,
                    b.boatLength,
                    b.regNumber,
                    d.dockNumber,
                    d.dockDescription,
                    s.slipNumber,
                    sz.sizeFt,
                    e.rateAmount AS electricMonthlyRate
            FROM Reservation r
            JOIN Boat     b  ON b.boatID     = r.boatID
            JOIN Slip     s  ON s.slipID     = r.slipID
            JOIN Dock     d  ON d.dockID     = s.dockID
            JOIN SlipSize sz ON sz.slipSizeID = s.slipSizeID
            LEFT JOIN Rate e ON e.rateCode   = 'ELECTRIC_MONTHLY'
            WHERE r.confirmationNumber = ?
            """;

    /**
     * Looks a reservation up by its customer-facing confirmation number, with
     * the boat, slip, dock and size details the summary page displays.
     *
     * <p>Deliberately does <em>not</em> filter by customer. The caller checks
     * ownership against the session and shows its own message, which keeps
     * "no such reservation" and "not yours" as two separate outcomes here
     * rather than collapsing them into one silent null.
     *
     * @param confirmationNumber the confirmation number, e.g. {@code MB-00061}
     * @return the reservation's details, or {@code null} if no reservation
     *         carries that confirmation number
     * @throws SQLException if the lookup fails
     */
    public ReservationDetails findDetailsByConfirmation(String confirmationNumber)
            throws SQLException {

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(SELECT_DETAILS)) {

            stmt.setString(1, confirmationNumber);

            try (ResultSet rs = stmt.executeQuery()) {
                return rs.next() ? mapDetails(rs) : null;
            }
        }
    }

    /**
     * Cancels a reservation, setting its status rather than deleting the row -
     * the marina still needs to know the booking happened, and BR-16 keeps a
     * reservation tied to the customer who made it.
     *
     * <p>The customer ID is part of the WHERE clause, not checked beforehand.
     * A caller that checked first and then updated would leave a gap between
     * the two where the answer could change; this way the database decides,
     * and a row count of zero means it was not theirs, not there, or already
     * cancelled.
     *
     * @param reservationId the reservation to cancel
     * @param customerId the customer the reservation must belong to
     * @return {@code true} if a row was cancelled, {@code false} if nothing
     *         matched
     * @throws SQLException if the update fails
     */
    public boolean cancel(int reservationId, int customerId) throws SQLException {
        String sql = """
                UPDATE Reservation
                SET reservationStatus = 'Cancelled'
                WHERE reservationID = ?
                  AND customerID = ?
                  AND reservationStatus = 'Active'
                """;

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, reservationId);
            stmt.setInt(2, customerId);
            return stmt.executeUpdate() == 1;
        }
    }

        /**
         * Uses the rateCode to retrieve the current rate amount
         * from the Rate table.
         */
    public BigDecimal getRate(Connection conn, String rateCode) throws SQLException {
        String sql = "SELECT rateAmount FROM Rate WHERE rateCode = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, rateCode);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getBigDecimal("rateAmount");
                }
            }
        }
        throw new SQLException("Required rate not found: " + rateCode);
    }
 /**
     * Returns every dock with a 26/40/50 count, including explicit zeroes.
     */
    public List<DockAvailability> findDockAvailability(Connection conn)
            throws SQLException {
        String sql = """
                SELECT d.dockID,
                       d.dockNumber,
                       d.dockDescription,
                       sz.sizeFt,
                       SUM(CASE
                           WHEN s.slipID IS NOT NULL
                            AND s.slipStatus = 'operational'
                            AND NOT EXISTS (
                                SELECT 1
                                FROM Reservation r
                                WHERE r.slipID = s.slipID
                                  AND r.reservationStatus = 'Active'
                            )
                           THEN 1 ELSE 0
                       END) AS availableCount
                FROM Dock d
                CROSS JOIN SlipSize sz
                LEFT JOIN Slip s
                       ON s.dockID = d.dockID
                      AND s.slipSizeID = sz.slipSizeID
                GROUP BY d.dockID, d.dockNumber, d.dockDescription, sz.sizeFt
                ORDER BY d.dockNumber, sz.sizeFt
                """;

        Map<Integer, DockAvailability> docks = new LinkedHashMap<>();
        try (PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                int dockId = rs.getInt("dockID");
                DockAvailability dock = docks.get(dockId);
                if (dock == null) {
                    dock = new DockAvailability();
                    dock.setDockId(dockId);
                    dock.setDockNumber(rs.getString("dockNumber"));
                    dock.setDockDescription(rs.getString("dockDescription"));
                    docks.put(dockId, dock);
                }
                dock.setAvailableCount(
                        rs.getInt("sizeFt"),
                        rs.getInt("availableCount"));
            }
        }
        return new ArrayList<>(docks.values());
    }



    public Integer findAvailableSlip(
        Connection conn, int dockId,
        int slipSizeFt) throws SQLException {

    String sql = """
            SELECT s.slipID FROM Slip s
            JOIN SlipSize sz
                ON sz.slipSizeID = s.slipSizeID
            WHERE s.dockID = ?
              AND sz.sizeFt = ?
              AND s.slipStatus = 'operational'
              AND NOT EXISTS (
                  SELECT 1
                  FROM Reservation r
                  WHERE r.slipID = s.slipID
                    AND r.reservationStatus = 'Active'
              )
            ORDER BY s.slipNumber
            LIMIT 1
            """;

    try (PreparedStatement stmt = conn.prepareStatement(sql)) {
        stmt.setInt(1, dockId);
        stmt.setInt(2, slipSizeFt);

        try (ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) {
                return rs.getInt("slipID");
            }
        }
    }

    return null;
}

    /** Counts free operational slips of a specific size across the marina */
    public int countAvailableForSize(Connection conn, int slipSizeFt)
            throws SQLException {
        String sql = """
                SELECT COUNT(*) AS availableCount
                FROM Slip s
                JOIN SlipSize sz ON sz.slipSizeID = s.slipSizeID
                WHERE sz.sizeFt = ?
                  AND s.slipStatus = 'operational'
                  AND NOT EXISTS (
                      SELECT 1
                      FROM Reservation r
                      WHERE r.slipID = s.slipID
                        AND r.reservationStatus = 'Active'
                  )
                """;

        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, slipSizeFt);
            try (ResultSet rs = stmt.executeQuery()) {
                rs.next();
                return rs.getInt("availableCount");
            }
        }
    }

    /**
     * The final confirmation number uses the generated 
     * reservation ID, but that ID doesn’t exist until after 
     * the insert. So the row is inserted with a temporary 
     * unique confirmation value, the generated ID is retrieved 
     * and then the confirmation number is updated to the final 
     * MB-xxxxx format.
     */
    public String insert(Connection conn, Reservation reservation) throws SQLException {
        String temporaryConfirmation = "TMP-"
                + UUID.randomUUID().toString().replace("-", "").substring(0, 20);
        String insertSql = """
                INSERT INTO Reservation (
                    confirmationNumber,
                    customerID,
                    boatID,
                    slipID,
                    startDate,
                    monthlyRate,
                    electricalHookup,
                    reservationStatus
                )
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)
                """;

        int reservationId;
        try (PreparedStatement stmt = conn.prepareStatement(
                insertSql, Statement.RETURN_GENERATED_KEYS)) {
            stmt.setString(1, temporaryConfirmation);
            stmt.setInt(2, reservation.getCustomerId());
            stmt.setInt(3, reservation.getBoatId());
            stmt.setInt(4, reservation.getSlipId());
            stmt.setDate(5, Date.valueOf(reservation.getStartDate()));
            stmt.setBigDecimal(6, reservation.getMonthlyRate());
            stmt.setBoolean(7, reservation.isElectricalHookup());
            stmt.setString(8, reservation.getReservationStatus());

            if (stmt.executeUpdate() != 1) {
                throw new SQLException("Reservation did not insert one row.");
            }
            try (ResultSet keys = stmt.getGeneratedKeys()) {
                if (!keys.next()) {
                    throw new SQLException("Reservation did not return a reservationID.");
                }
                reservationId = keys.getInt(1);
            }
        }

        String confirmation = String.format("MB-%05d", reservationId);
        try (PreparedStatement stmt = conn.prepareStatement("""
                UPDATE Reservation
                SET confirmationNumber = ?
                WHERE reservationID = ?
                """)) {
            stmt.setString(1, confirmation);
            stmt.setInt(2, reservationId);
            if (stmt.executeUpdate() != 1) {
                throw new SQLException("Reservation confirmation number was not saved.");
            }
        }

        reservation.setReservationId(reservationId);
        reservation.setConfirmationNumber(confirmation);
        return confirmation;
    }

    /**
     * Maps the current row of a {@link #SELECT_DETAILS} result set.
     *
     * @param rs a result set positioned on a valid joined row
     * @return the populated {@link ReservationDetails}
     * @throws SQLException if a column can't be read
     */
    private ReservationDetails mapDetails(ResultSet rs) throws SQLException {
        ReservationDetails details = new ReservationDetails();

        details.setReservationId(rs.getInt("reservationID"));
        details.setConfirmationNumber(rs.getString("confirmationNumber"));
        details.setCustomerId(rs.getInt("customerID"));

        // java.sql.Date is a java.util.Date, which is what JSTL's
        // <fmt:formatDate> on the page needs. No conversion either way.
        details.setStartDate(rs.getDate("startDate"));

        details.setMonthlyRate(rs.getBigDecimal("monthlyRate"));
        details.setReservationStatus(rs.getString("reservationStatus"));
        details.setElectricalHookup(rs.getBoolean("electricalHookup"));

        details.setBoatName(rs.getString("boatName"));
        details.setBoatType(rs.getString("boatType"));
        details.setBoatLength(rs.getBigDecimal("boatLength"));
        details.setRegNumber(rs.getString("regNumber"));

        details.setDockNumber(rs.getString("dockNumber"));
        details.setDockDescription(rs.getString("dockDescription"));
        details.setSlipNumber(rs.getInt("slipNumber"));
        details.setSlipSizeFt(rs.getInt("sizeFt"));

        details.setElectricMonthlyRate(rs.getBigDecimal("electricMonthlyRate"));

        return details;
    }
}
