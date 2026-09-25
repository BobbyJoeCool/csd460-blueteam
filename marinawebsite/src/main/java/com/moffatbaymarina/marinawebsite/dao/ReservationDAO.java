package com.moffatbaymarina.marinawebsite.dao;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import com.moffatbaymarina.marinawebsite.model.Boat;
import com.moffatbaymarina.marinawebsite.model.DockAvailability;
import com.moffatbaymarina.marinawebsite.model.Reservation;
import com.moffatbaymarina.marinawebsite.model.ReservationDetails;
import com.moffatbaymarina.marinawebsite.util.DBConnection;

/**
 * Data access for the {@code Reservation} table.
 *
 * <p>This file currently holds the read side only - what the Reservation
 * Summary page needs to look a booking up, and what My Reservations needs
 * to cancel one, or record or withdraw a 30-day termination notice. The booking
 * insert, slip assignment and availability queries belong to the Reservation
 * page and are being added separately; both halves live here on purpose so
 * there is one place that knows how a reservation is stored.
 *
 * @author Miguel Fernandez
 * @author Sara White
 * @author Carolina Rodriguez
 * Blue Team - Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
 * Primary Author/Owner - Miguel Fernandez & Sara White
 * @implNote JavaDoc comments in this file were added with the assistance of Claude.
 */
public class ReservationDAO {

    /*
     * One join rather than four lookups. A reservation row is mostly IDs, and
     * every one of them turns into something the page shows: the boat's name,
     * which dock, which slip, what size. The Rate row comes along for the
     * electric fee so the total can be itemised - LEFT JOIN because a missing
     * rate row should blank one line, not lose the whole reservation.
     * TerminationNotice is LEFT JOINed for the same reason - most
     * reservations never have one - and its reservationID is UNIQUE, so the
     * join can't turn one reservation into two rows.
     *
     * No WHERE clause: each method below appends its own. Every column here is
     * read by mapDetails(), so a column added or renamed here has to change
     * there too - which is why there's one copy of this query, not one per
     * method (findReservationsByCustomer used to carry a second copy).
     */
    private static final String SELECT_DETAILS = """
            SELECT  r.reservationID,
                    r.confirmationNumber,
                    r.customerID,
                    CONCAT(c.firstName, ' ', c.lastName) AS guestName,
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
                    e.rateAmount AS electricMonthlyRate,
                    tn.noticeStatus,
                    tn.noticeDate,
                    tn.terminationDate
            FROM Reservation r
            JOIN Customer c ON c.customerID = r.customerID
            JOIN Boat     b  ON b.boatID     = r.boatID
            JOIN Slip     s  ON s.slipID     = r.slipID
            JOIN Dock     d  ON d.dockID     = s.dockID
            JOIN SlipSize sz ON sz.slipSizeID = s.slipSizeID
            LEFT JOIN Rate e ON e.rateCode   = 'ELECTRIC_MONTHLY'
            LEFT JOIN TerminationNotice tn ON tn.reservationID = r.reservationID
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
             PreparedStatement stmt = conn.prepareStatement(
                     SELECT_DETAILS + " WHERE r.confirmationNumber = ?")) {

            stmt.setString(1, confirmationNumber);

            try (ResultSet rs = stmt.executeQuery()) {
                return rs.next() ? mapDetails(rs) : null;
            }
        }
    }

    /**
     * Lists one customer's reservations for the My Reservations page, with
     * optional filters. Every filter is bound as a parameter; the only thing
     * built into the SQL text is the fixed ASC/DESC keyword.
     *
     * <p>Always limited to {@code customerId} - which the caller must take from
     * the session, never from the request - so no combination of filters can
     * return somebody else's reservation.
     *
     * @param customerId the signed-in customer
     * @param reservationNumber part or all of a confirmation number (e.g.
     *        {@code "61"} or {@code "MB-00061"}), or {@code null} for any. The
     *        caller must have already limited it to letters, digits and
     *        hyphens, so it can't carry LIKE wildcards.
     * @param year a start-date year, or {@code null} for any
     * @param month a start-date month, 1-12, or {@code null} for any
     * @param status a reservation status such as {@code "Active"}, or
     *        {@code null} for any
     * @param oldestFirst {@code true} to sort by start date oldest first,
     *        {@code false} for newest first
     * @return the matching reservations; empty, never {@code null}, if none match
     * @throws SQLException if the lookup fails
     */
    public List<ReservationDetails> findReservationsByCustomer(
            int customerId,
            String reservationNumber,
            Integer year,
            Integer month,
            String status,
            boolean oldestFirst) throws SQLException {

        StringBuilder sql = new StringBuilder(SELECT_DETAILS)
                .append(" WHERE r.customerID = ?");
        List<Object> parameters = new ArrayList<>();
        parameters.add(customerId);

        if (reservationNumber != null) {
            sql.append(" AND r.confirmationNumber LIKE ?");
            parameters.add("%" + reservationNumber + "%");
        }
        if (year != null) {
            sql.append(" AND YEAR(r.startDate) = ?");
            parameters.add(year);
        }
        if (month != null) {
            sql.append(" AND MONTH(r.startDate) = ?");
            parameters.add(month);
        }
        if (status != null) {
            sql.append(" AND r.reservationStatus = ?");
            parameters.add(status);
        }

        // reservationID breaks ties, so two leases starting the same day
        // always come back in the same order.
        String direction = oldestFirst ? "ASC" : "DESC";
        sql.append(" ORDER BY r.startDate ").append(direction)
           .append(", r.reservationID ").append(direction);

        List<ReservationDetails> reservations = new ArrayList<>();

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < parameters.size(); i++) {
                Object value = parameters.get(i);
                if (value instanceof Integer number) {
                    stmt.setInt(i + 1, number);
                } else {
                    stmt.setString(i + 1, value.toString());
                }
            }

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    reservations.add(mapDetails(rs));
                }
            }
        }

        return reservations;
    }

    /**
     * The years this customer has reservations starting in, newest first -
     * what the My Reservations Year filter offers, so it never lists a year
     * with nothing in it and never needs editing when a new year starts.
     *
     * @param customerId the signed-in customer
     * @return the distinct start-date years; empty if the customer has none
     * @throws SQLException if the lookup fails
     */
    public List<Integer> findReservationYears(int customerId) throws SQLException {
        String sql = """
                SELECT DISTINCT YEAR(startDate) AS startYear
                FROM Reservation
                WHERE customerID = ?
                ORDER BY startYear DESC
                """;

        List<Integer> years = new ArrayList<>();

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, customerId);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    years.add(rs.getInt("startYear"));
                }
            }
        }

        return years;
    }

    /**
     * Cancels a reservation, setting its status rather than deleting the row -
     * the marina still needs to know the booking happened, and BR-16 keeps a
     * reservation tied to the customer who made it.
     *
     * <p>Only a reservation that hasn't started can be cancelled. Once the
     * start date arrives the lease is running, and ending it takes 30 days'
     * notice instead - see {@link #submitTerminationNotice}.
     *
     * <p>The customer ID is part of the WHERE clause, not checked beforehand.
     * A caller that checked first and then updated would leave a gap between
     * the two where the answer could change; this way the database decides,
     * and a row count of zero means it was not theirs, not there, already
     * cancelled, or already started.
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
                  AND startDate > CURDATE()
                """;

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, reservationId);
            stmt.setInt(2, customerId);
            return stmt.executeUpdate() == 1;
        }
    }

    /**
     * Withdraws a customer's open termination notice (BR-23), so the lease
     * carries on month to month. The row is kept with status
     * {@code Withdrawn} - the history stays, and a later notice reuses it
     * (see {@link #submitTerminationNotice}).
     *
     * <p>One UPDATE whose WHERE clause holds every rule, so there's no gap
     * between checking and changing: the reservation is this customer's and
     * Active, the notice is Submitted, Pending or Approved, and its last day
     * is no earlier than {@code earliestLastDay}. The caller passes today
     * plus {@code Utils.NOTICE_WITHDRAWAL_CUTOFF_DAYS}, so the cutoff lives
     * only in Utils. A notice with no last day recorded can be withdrawn.
     *
     * @param reservationId the reservation whose notice to withdraw
     * @param customerId the customer it must belong to
     * @param earliestLastDay the earliest last day that can still be withdrawn
     * @return {@code true} if a notice was withdrawn, {@code false} if none
     *         qualified (not theirs, none open, or past the cutoff)
     * @throws SQLException if the update fails
     */
    public boolean withdrawTerminationNotice(int reservationId, int customerId,
            LocalDate earliestLastDay) throws SQLException {
        String sql = """
                UPDATE TerminationNotice tn
                JOIN Reservation r ON r.reservationID = tn.reservationID
                SET tn.noticeStatus = 'Withdrawn'
                WHERE tn.reservationID = ?
                  AND r.customerID = ?
                  AND r.reservationStatus = 'Active'
                  AND tn.noticeStatus IN ('Submitted', 'Pending', 'Approved')
                  AND (tn.terminationDate IS NULL OR tn.terminationDate >= ?)
                """;

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, reservationId);
            stmt.setInt(2, customerId);
            stmt.setDate(3, Date.valueOf(earliestLastDay));
            return stmt.executeUpdate() == 1;
        }
    }

    /**
     * Records a customer's 30-day termination notice (BR-21) on a lease that
     * has started, with the last day they chose.
     *
     * <p>The caller has already checked the date against
     * {@code Utils.isValidTerminationDate}. This method checks everything
     * that depends on the database, inside one transaction with the rows
     * locked, so two submits at once can't both get through:
     *
     * <ul>
     *   <li>the reservation is this customer's, Active, and has started;</li>
     *   <li>it has no open notice. {@code TerminationNotice.reservationID} is
     *       UNIQUE, so a reservation only ever has one row: a Withdrawn one
     *       (BR-23) is reused for the new notice rather than added to.</li>
     * </ul>
     *
     * <p>{@code terminationDate} is filled in on submission with the day the
     * customer asked for; {@code noticeStatus} starts at {@code Submitted}.
     *
     * @param reservationId the reservation the notice is for
     * @param customerId the customer it must belong to
     * @param lastDay the lease's requested last day
     * @return {@code true} if the notice was recorded, {@code false} if the
     *         reservation wasn't eligible (not theirs, not Active, not
     *         started, or a notice already open)
     * @throws SQLException if the database work fails
     */
    public boolean submitTerminationNotice(int reservationId, int customerId, LocalDate lastDay)
            throws SQLException {

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                boolean recorded = recordNotice(conn, reservationId, customerId, lastDay);
                if (recorded) {
                    conn.commit();
                } else {
                    conn.rollback();
                }
                return recorded;
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        }
    }

    /**
     * The body of {@link #submitTerminationNotice}, run inside its
     * transaction.
     */
    private boolean recordNotice(Connection conn, int reservationId, int customerId,
            LocalDate lastDay) throws SQLException {

        try (PreparedStatement stmt = conn.prepareStatement("""
                SELECT 1
                FROM Reservation
                WHERE reservationID = ?
                  AND customerID = ?
                  AND reservationStatus = 'Active'
                  AND startDate <= CURDATE()
                FOR UPDATE
                """)) {
            stmt.setInt(1, reservationId);
            stmt.setInt(2, customerId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (!rs.next()) {
                    return false;
                }
            }
        }

        String existingStatus = null;
        try (PreparedStatement stmt = conn.prepareStatement("""
                SELECT noticeStatus
                FROM TerminationNotice
                WHERE reservationID = ?
                FOR UPDATE
                """)) {
            stmt.setInt(1, reservationId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    existingStatus = rs.getString("noticeStatus");
                }
            }
        }

        String sql;
        if (existingStatus == null) {
            sql = """
                    INSERT INTO TerminationNotice
                        (terminationDate, reservationID, noticeDate, noticeStatus)
                    VALUES (?, ?, CURDATE(), 'Submitted')
                    """;
        } else if ("Withdrawn".equals(existingStatus)) {
            sql = """
                    UPDATE TerminationNotice
                    SET terminationDate = ?,
                        noticeDate = CURDATE(),
                        noticeStatus = 'Submitted'
                    WHERE reservationID = ?
                    """;
        } else {
            return false;
        }

        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setDate(1, Date.valueOf(lastDay));
            stmt.setInt(2, reservationId);
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



    /**
     * {@code FOR UPDATE} locks the returned slip row so a second, concurrent
     * call can't also see it as free before this transaction commits or
     * rolls back - without it, two requests racing for the same last-open
     * slip could both pass this check and both book it.
     */
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
            FOR UPDATE
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
        details.setGuestName(rs.getString("guestName"));

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

        details.setNoticeStatus(rs.getString("noticeStatus"));
        details.setNoticeDate(rs.getDate("noticeDate"));
        details.setTerminationDate(rs.getDate("terminationDate"));

        return details;
    }
}
