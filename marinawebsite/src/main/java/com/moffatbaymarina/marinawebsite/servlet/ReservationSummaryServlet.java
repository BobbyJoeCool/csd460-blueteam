package com.moffatbaymarina.marinawebsite.servlet;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.SQLException;

import com.moffatbaymarina.marinawebsite.dao.ReservationDAO;
import com.moffatbaymarina.marinawebsite.model.ReservationDetails;
import com.moffatbaymarina.marinawebsite.util.Utils;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Backs the Reservation Summary page - see
 * {@code documentation/Page Contracts/Reservation Summary.md}.
 *
 * <p><strong>A confirmation screen, not a page to browse to.</strong> It is
 * shown right after a reservation changes - booked on the Reservation page,
 * or cancelled or given 30 days' notice on My Reservations - and nowhere
 * else. Those three actions call {@link #grantAccess} before redirecting
 * here, which remembers that one confirmation number in the session. Asking
 * for any other confirmation number sends the customer to My Reservations,
 * filtered to it, which is where reservations are looked at and managed.
 * The grant isn't used up on the first view, so a refresh still works; the
 * next change replaces it, and signing in again starts a fresh session
 * without one.
 *
 * <p><strong>GET</strong> {@code /reservationSummary?confirmation=MB-00061}
 * looks the reservation up fresh from the database and forwards to the JSP.
 * Every action redirects here rather than forwarding, so a refresh re-reads
 * the reservation instead of repeating the change.
 *
 * <p>Two things this servlet exists to enforce:
 *
 * <ul>
 *   <li><strong>Signed in.</strong> A reservation is somebody's private
 *       business. No session, no page.</li>
 *   <li><strong>Theirs.</strong> Confirmation numbers run in sequence from
 *       MB-00001, so anyone could put a neighbour's in the address bar and
 *       read their booking. Every request checks the reservation's customer
 *       against the session before anything is shown or changed.</li>
 * </ul>
 *
 * <p>A reservation that exists but belongs to someone else gets exactly the
 * same message as one that does not exist. Telling the two apart would let
 * someone map which confirmation numbers are real, which is the same reasoning
 * the Login contract uses for its single generic failure message.
 *
 * @author Miguel Fernandez
 * Blue Team - Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
 * Primary Author/Owner - Miguel Fernandez
 * @implNote JavaDoc comments in this file were added with the assistance of Claude.
 */
@WebServlet("/reservationSummary")
public class ReservationSummaryServlet extends HttpServlet {

    private static final String VIEW = "/reservationSummary.jsp";

    private static final String PARAM_CONFIRMATION = "confirmation";

    /** Session attribute holding the one confirmation number this page may show. */
    private static final String SUMMARY_ACCESS = "reservationSummaryAccess";

    /** Same wording whether the reservation is missing or someone else's. */
    private static final String NOT_FOUND_MESSAGE =
            "We couldn't find that reservation. Check the confirmation number, "
            + "or contact the marina office at (360) 555-0142.";

    private final ReservationDAO reservationDAO = new ReservationDAO();

    /**
     * Shows one reservation. Requires a signed-in session and a
     * {@code confirmation} parameter, and only displays the reservation if it
     * belongs to the signed-in customer.
     *
     * @param request the incoming request
     * @param response the response to forward or redirect
     * @throws ServletException if the lookup or forward fails
     * @throws IOException if the forward or redirect fails
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Integer customerId = Utils.signedInCustomerId(request);
        if (customerId == null) {
            showSignInRequired(request, response);
            return;
        }

        String confirmation = Utils.clean(request.getParameter(PARAM_CONFIRMATION));
        if (confirmation.isEmpty()) {
            showNotFound(request, response);
            return;
        }

        // Only the reservation that was just booked or changed. Anything
        // else is looked at on My Reservations.
        if (!confirmation.equals(request.getSession().getAttribute(SUMMARY_ACCESS))) {
            response.sendRedirect(request.getContextPath()
                    + "/reservations?reservationNumber="
                    + URLEncoder.encode(confirmation, StandardCharsets.UTF_8));
            return;
        }

        try {
            ReservationDetails details =
                    reservationDAO.findDetailsByConfirmation(confirmation);

            // Missing and not-yours are deliberately the same outcome here.
            if (details == null || details.getCustomerId() != customerId) {
                showNotFound(request, response);
                return;
            }

            request.setAttribute("reservation", details);
            request.getRequestDispatcher(VIEW).forward(request, response);

        } catch (SQLException e) {
            throw new ServletException("Reservation lookup failed", e);
        }
    }

    /**
     * Lets this session see the Summary page for one reservation - called by
     * whatever just booked or changed it, right before redirecting here.
     * Replaces any earlier grant, so only the latest change can be shown.
     *
     * @param request the request that made the change
     * @param confirmationNumber the reservation's confirmation number
     */
    public static void grantAccess(HttpServletRequest request, String confirmationNumber) {
        request.getSession().setAttribute(SUMMARY_ACCESS, confirmationNumber);
    }

    /**
     * Grants access to one reservation's summary and redirects there, with a
     * {@code notice} keyword for statusPopup.js. The one way an action that
     * already sends a real redirect (rather than JSON) lands on this page.
     *
     * @param request the request that made the change
     * @param response the response to redirect
     * @param confirmationNumber the reservation's confirmation number
     * @param notice the statusPopup.js keyword, e.g. {@code reservationCancelled}
     * @throws IOException if the redirect fails
     */
    public static void redirectTo(HttpServletRequest request, HttpServletResponse response,
            String confirmationNumber, String notice) throws IOException {
        grantAccess(request, confirmationNumber);
        response.sendRedirect(request.getContextPath()
                + "/reservationSummary?confirmation="
                + URLEncoder.encode(confirmationNumber, StandardCharsets.UTF_8)
                + "&notice=" + notice);
    }

    /**
     * Shows the page's own signed-out state rather than bouncing the visitor
     * to the landing page.
     *
     * <p>The JSP already handles this: it checks for
     * {@code sessionScope.customerId} itself and renders a "Sign in to view
     * your reservation" panel with a button that opens the login modal,
     * which then sends them to My Reservations.
     *
     * @param request the incoming request
     * @param response the response to forward
     * @throws ServletException if the forward fails
     * @throws IOException if the forward fails
     */
    private void showSignInRequired(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        /*
         * Back to My Reservations, not to this page: signing in starts a fresh
         * session, which has no grant to show any summary, so this page would
         * only bounce them there anyway.
         */
        String returnTo = "/reservations";

        request.setAttribute("signInRedirectTo", returnTo);
        response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        request.getRequestDispatcher(VIEW).forward(request, response);
    }

    /**
     * Forwards to the JSP with no reservation and a message explaining it,
     * used for a missing confirmation number, one that matches nothing, and
     * one that belongs to someone else - all three look the same on purpose.
     *
     * @param request the request to attach the message to
     * @param response the response to forward
     * @throws ServletException if the forward fails
     * @throws IOException if the forward fails
     */
    private void showNotFound(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setAttribute("reservationSummaryError", NOT_FOUND_MESSAGE);
        response.setStatus(HttpServletResponse.SC_NOT_FOUND);
        request.getRequestDispatcher(VIEW).forward(request, response);
    }
}
