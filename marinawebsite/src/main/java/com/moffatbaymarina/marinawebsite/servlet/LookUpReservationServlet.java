package com.moffatbaymarina.marinawebsite.servlet;

import java.io.IOException;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.Year;
import java.util.List;
import java.util.Set;
import java.util.regex.Pattern;

import com.moffatbaymarina.marinawebsite.dao.ReservationDAO;
import com.moffatbaymarina.marinawebsite.model.ReservationDetails;
import com.moffatbaymarina.marinawebsite.util.Utils;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Backs the My Reservations page: lists the signed-in customer's
 * reservations, newest first, with optional filters.
 *
 * <p>Each reservation also carries what can be done with it: cancelled
 * before its lease starts, given 30 days' notice after, or that notice
 * withdrawn until the cutoff before its last day. Those buttons
 * post to ReservationChangeServlet; a refusal comes back here as a one-time
 * {@code actionError} banner.
 *
 * <p>Results are always limited to the {@code customerId} in the session,
 * so a customer can only ever see their own reservations, whatever is typed
 * into the filters or the URL. Visiting with no filters lists everything.
 *
 * <p>Optional filters (all GET query parameters): {@code reservationNumber}
 * (part or all of a confirmation number), {@code year}, {@code month},
 * {@code status}, and {@code sort} ({@code newest} or {@code oldest}). A
 * filter value that isn't valid is ignored rather than failing the page -
 * the dropdowns can't produce one, so it only happens when a URL is edited
 * by hand. The one exception is the reservation number, which is typed, so
 * an invalid one gets a message.
 *
 * @author Rodriguez, C.
 * Blue Team - Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
 * Primary Author/Owner - Carolina Rodriguez
 */
@WebServlet("/reservations")
public class LookUpReservationServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final String VIEW = "/lookUpReservation.jsp";

    /**
     * Letters, digits and hyphens only - enough for any part of a
     * confirmation number like MB-00061, and it keeps LIKE's % and _
     * wildcards out of the search. Twin of formValidation.js's
     * isValidReservationSearch.
     */
    private static final Pattern RESERVATION_SEARCH = Pattern.compile("^[A-Za-z0-9-]{1,20}$");

    /** The only statuses anything in the app ever sets (see ReservationDAO). */
    private static final Set<String> STATUSES = Set.of("Active", "Cancelled");

    private final ReservationDAO reservationDAO = new ReservationDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Integer customerId = Utils.signedInCustomerId(request);
        if (customerId == null) {
            // Same pattern as ReservationSummaryServlet: stay on this page,
            // show a sign-in panel, and send them back here afterwards.
            request.setAttribute("signInRequired", true);
            request.setAttribute("signInRedirectTo", "/reservations");
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            request.getRequestDispatcher(VIEW).forward(request, response);
            return;
        }

        String reservationNumber = Utils.emptyToNull(
                Utils.clean(request.getParameter("reservationNumber")));
        if (reservationNumber != null && !RESERVATION_SEARCH.matcher(reservationNumber).matches()) {
            request.setAttribute("filterError",
                    "Reservation numbers only contain letters, numbers and dashes, like MB-00001.");
            reservationNumber = null;
        }

        int thisYear = Year.now().getValue();
        Integer year = Utils.parseIntInRange(request.getParameter("year"),
                Utils.MIN_RESERVATION_YEAR, thisYear + Utils.MAX_RESERVATION_YEARS_AHEAD);
        Integer month = Utils.parseIntInRange(request.getParameter("month"), 1, 12);

        String status = Utils.clean(request.getParameter("status"));
        if (!STATUSES.contains(status)) {
            status = null;
        }

        boolean oldestFirst = "oldest".equals(request.getParameter("sort"));

        try {
            List<ReservationDetails> reservations = reservationDAO.findReservationsByCustomer(
                    customerId, reservationNumber, year, month, status, oldestFirst);
            List<Integer> reservationYears = reservationDAO.findReservationYears(customerId);

            request.setAttribute("reservations", reservations);
            request.setAttribute("reservationYears", reservationYears);

            // A cancel or notice that ReservationChangeServlet turned down.
            request.setAttribute("actionError",
                    Utils.takeSessionAttribute(request, ReservationChangeServlet.ERROR_FLASH));

            // The notice popup's date range, so the 30-day rule (BR-21)
            // lives only in Utils and the date picker just reads it.
            LocalDate today = LocalDate.now();
            request.setAttribute("earliestTerminationDate", Utils.earliestTerminationDate(today).toString());
            request.setAttribute("latestTerminationDate", Utils.latestTerminationDate(today).toString());
            request.setAttribute("earliestTerminationDisplay",
                    Utils.formatDisplayDate(Utils.earliestTerminationDate(today)));
            request.setAttribute("minNoticeDays", Utils.MIN_TERMINATION_NOTICE_DAYS);
            request.setAttribute("noticeWithdrawalCutoffDays", Utils.NOTICE_WITHDRAWAL_CUTOFF_DAYS);

            // The filters as actually applied (invalid values already
            // dropped), so the form can show what the results reflect.
            request.setAttribute("searchNumber", reservationNumber);
            request.setAttribute("selectedYear", year);
            request.setAttribute("selectedMonth", month);
            request.setAttribute("selectedStatus", status);
            request.setAttribute("oldestFirst", oldestFirst);

            // Tells the page which empty message to show: "nothing matches
            // these filters" versus "you don't have any reservations yet".
            request.setAttribute("filtersApplied",
                    reservationNumber != null || year != null || month != null || status != null);

            request.getRequestDispatcher(VIEW).forward(request, response);

        } catch (SQLException e) {
            throw new ServletException("Unable to load reservations.", e);
        }
    }

    /**
     * Renders the page exactly as {@link #doGet} does. Nothing is ever
     * submitted to this page by POST - this exists for the login modal: when
     * a sign-in attempt fails, LoginServlet forwards its POST back to the page
     * it came from so the modal can re-open with the error. Without this, a
     * wrong password typed on My Reservations ended on a 405 error page.
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
