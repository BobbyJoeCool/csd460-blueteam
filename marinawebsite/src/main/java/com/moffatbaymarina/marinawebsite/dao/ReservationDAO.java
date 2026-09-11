package com.moffatbaymarina.marinawebsite.dao;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

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
