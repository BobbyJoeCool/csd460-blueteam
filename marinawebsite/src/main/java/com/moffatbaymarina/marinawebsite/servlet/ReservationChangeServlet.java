package com.moffatbaymarina.marinawebsite.servlet;

import java.io.IOException;
import java.sql.SQLException;
import java.time.LocalDate;

import com.moffatbaymarina.marinawebsite.dao.ReservationDAO;
import com.moffatbaymarina.marinawebsite.model.ReservationDetails;
import com.moffatbaymarina.marinawebsite.util.Utils;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * The ways a customer ends a reservation from My Reservations - or takes
 * back a notice to end one. Which applies depends on whether the lease has
 * started:
 *
 * <ul>
 *   <li><strong>{@code POST /reservations/cancel}</strong> - before the start
 *       date, the reservation can simply be cancelled.</li>
 *   <li><strong>{@code POST /reservations/notice}</strong> - once it has
 *       started, the lease is month-to-month and ends on a last day the
 *       customer chooses, at least 30 days out (BR-21). Takes
 *       {@code lastDay} ({@code yyyy-MM-dd}) as well.</li>
 *   <li><strong>{@code POST /reservations/withdraw}</strong> - takes that
 *       notice back, so the lease carries on (BR-23). Allowed up to
 *       {@code Utils.NOTICE_WITHDRAWAL_CUTOFF_DAYS} days before the notice's
 *       last day.</li>
 * </ul>
 *
 * <p>All three take the reservation's {@code confirmation} number. One
 * servlet for all three because everything before the action itself is the same: signed
 * in, a confirmation number, the reservation exists and is this customer's.
 *
 * <p>Success redirects to the Reservation Summary as the confirmation
 * screen. Failure redirects back to My Reservations with a one-time message
 * (flashed in the session, so a refresh doesn't show it again). "Not yours"
 * and "doesn't exist" get the same message, for the reason the Summary page
 * gives: telling them apart would let someone map which confirmation
 * numbers are real.
 *
 * <p>The buttons on My Reservations only appear when the action is allowed,
 * but that's a courtesy. The DAO re-checks every rule inside the database
 * write, so a stale page or a hand-built POST can't get round them.
 *
 * Blue Team - Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
 * Primary Author/Owner - Robert Breutzmann
 * @implNote Written with the assistance of Claude.
 */
@WebServlet({"/reservations/cancel", "/reservations/notice", "/reservations/withdraw"})
public class ReservationChangeServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final String NOTICE_PATH = "/reservations/notice";
    private static final String WITHDRAW_PATH = "/reservations/withdraw";

    /**
     * Session attribute LookUpReservationServlet reads once and shows as a
     * banner above the list.
     */
    public static final String ERROR_FLASH = "reservationsError";

    private static final String NOT_FOUND_MESSAGE =
            "We couldn't find that reservation. Contact the marina office at (360) 555-0142 if this keeps happening.";

    private final ReservationDAO reservationDAO = new ReservationDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        Integer customerId = Utils.signedInCustomerId(request);
        if (customerId == null) {
            response.sendRedirect(request.getContextPath() + "/reservations");
            return;
        }

        String confirmation = Utils.clean(request.getParameter("confirmation"));

        try {
            ReservationDetails details = confirmation.isEmpty()
                    ? null
                    : reservationDAO.findDetailsByConfirmation(confirmation);

            if (details == null || details.getCustomerId() != customerId) {
                backToList(request, response, NOT_FOUND_MESSAGE);
                return;
            }

            String path = request.getServletPath();
            if (NOTICE_PATH.equals(path)) {
                submitNotice(request, response, details, customerId);
            } else if (WITHDRAW_PATH.equals(path)) {
                withdrawNotice(request, response, details, customerId);
            } else {
                cancel(request, response, details, customerId);
            }

        } catch (SQLException e) {
            throw new ServletException("Reservation change failed", e);
        }
    }

    /**
     * Cancels a reservation that hasn't started yet.
     */
    private void cancel(HttpServletRequest request, HttpServletResponse response,
            ReservationDetails details, int customerId) throws SQLException, IOException {

        if (!reservationDAO.cancel(details.getReservationId(), customerId)) {
            backToList(request, response, details.isStarted()
                    ? "Reservation " + details.getConfirmationNumber()
                            + " has already started, so it needs 30 days' notice instead of a cancellation."
                    : "Reservation " + details.getConfirmationNumber()
                            + " is no longer active, so it can't be cancelled.");
            return;
        }

        ReservationSummaryServlet.redirectTo(request, response,
                details.getConfirmationNumber(), "reservationCancelled");
    }

    /**
     * Records a 30-day termination notice on a reservation that has started.
     */
    private void submitNotice(HttpServletRequest request, HttpServletResponse response,
            ReservationDetails details, int customerId) throws SQLException, IOException {

        LocalDate today = LocalDate.now();
        LocalDate lastDay = Utils.parseDate(request.getParameter("lastDay"));

        if (!Utils.isValidTerminationDate(lastDay, today)) {
            backToList(request, response, "Choose a last day between "
                    + Utils.formatDisplayDate(Utils.earliestTerminationDate(today)) + " and "
                    + Utils.formatDisplayDate(Utils.latestTerminationDate(today))
                    + ". A lease needs at least " + Utils.MIN_TERMINATION_NOTICE_DAYS
                    + " days' notice.");
            return;
        }

        if (!reservationDAO.submitTerminationNotice(
                details.getReservationId(), customerId, lastDay)) {
            backToList(request, response, details.isNoticeOpen()
                    ? "Reservation " + details.getConfirmationNumber()
                            + " already has a termination notice in progress."
                    : "Reservation " + details.getConfirmationNumber()
                            + " can't take a termination notice right now.");
            return;
        }

        ReservationSummaryServlet.redirectTo(request, response,
                details.getConfirmationNumber(), "terminationNoticeSubmitted");
    }

    /**
     * Withdraws an open termination notice, up to the cutoff before its last
     * day (BR-23).
     */
    private void withdrawNotice(HttpServletRequest request, HttpServletResponse response,
            ReservationDetails details, int customerId) throws SQLException, IOException {

        LocalDate earliestLastDay = Utils.earliestWithdrawableLastDay(LocalDate.now());

        if (!reservationDAO.withdrawTerminationNotice(
                details.getReservationId(), customerId, earliestLastDay)) {
            backToList(request, response, details.isNoticeOpen()
                    ? "The notice on reservation " + details.getConfirmationNumber()
                            + " can no longer be withdrawn. A notice may be withdrawn until "
                            + Utils.NOTICE_WITHDRAWAL_CUTOFF_DAYS
                            + " days before the lease end date, which was "
                            + details.getWithdrawDeadlineDisplay() + "."
                    : "Reservation " + details.getConfirmationNumber()
                            + " doesn't have a notice in progress to withdraw.");
            return;
        }

        ReservationSummaryServlet.redirectTo(request, response,
                details.getConfirmationNumber(), "terminationNoticeWithdrawn");
    }

    /**
     * Sends the customer back to My Reservations with a message shown once.
     */
    private void backToList(HttpServletRequest request, HttpServletResponse response,
            String message) throws IOException {
        request.getSession().setAttribute(ERROR_FLASH, message);
        response.sendRedirect(request.getContextPath() + "/reservations");
    }
}
