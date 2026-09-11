package com.moffatbaymarina.marinawebsite.servlet;

import java.io.IOException;
import java.sql.SQLException;

import com.moffatbaymarina.marinawebsite.dao.ReservationDAO;
import com.moffatbaymarina.marinawebsite.model.ReservationDetails;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * Backs the Reservation Summary page - see
 * {@code documentation/Page Contracts/Reservation Summary.md}.
 *
 * <p><strong>GET</strong> {@code /reservationSummary?confirmation=MB-00061}
 * looks the reservation up fresh from the database and forwards to the JSP.
 * The Reservation page redirects here after a booking rather than forwarding,
 * so a refresh re-reads a reservation instead of making a second one.
 *
 * <p><strong>POST</strong> with {@code action=cancel} cancels it. The
 * Reservation contract puts cancellation on this page because it is the one
 * place a customer already has a reservation in front of them.
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
    private static final String PARAM_ACTION = "action";
    private static final String ACTION_CANCEL = "cancel";

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

        Integer customerId = signedInCustomerId(request);
        if (customerId == null) {
            showSignInRequired(request, response);
            return;
        }

        String confirmation = request.getParameter(PARAM_CONFIRMATION);
        if (confirmation == null || confirmation.isBlank()) {
            showNotFound(request, response);
            return;
        }

        try {
            ReservationDetails details =
                    reservationDAO.findDetailsByConfirmation(confirmation.trim());

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
     * Cancels a reservation, then redirects back to this page so the customer
     * sees the cancelled state re-read from the database rather than a stale
     * copy of the page they submitted from. Redirect and not forward, so a
     * refresh cannot re-submit the cancellation.
     *
     * @param request the incoming request
     * @param response the response to redirect
     * @throws ServletException if the update fails
     * @throws IOException if the redirect fails
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Integer customerId = signedInCustomerId(request);
        if (customerId == null) {
            showSignInRequired(request, response);
            return;
        }

        String confirmation = request.getParameter(PARAM_CONFIRMATION);
        if (!ACTION_CANCEL.equals(request.getParameter(PARAM_ACTION))
                || confirmation == null || confirmation.isBlank()) {
            showNotFound(request, response);
            return;
        }

        try {
            ReservationDetails details =
                    reservationDAO.findDetailsByConfirmation(confirmation.trim());

            if (details == null || details.getCustomerId() != customerId) {
                showNotFound(request, response);
                return;
            }

            /*
             * customerId goes into the UPDATE's WHERE clause as well, so the
             * database is what actually enforces ownership. The check above is
             * for the message; this is for the guarantee.
             */
            boolean cancelled =
                    reservationDAO.cancel(details.getReservationId(), customerId);

            String notice = cancelled ? "reservationCancelled" : "reservationNotCancelled";
            response.sendRedirect(request.getContextPath()
                    + "/reservationSummary?confirmation="
                    + java.net.URLEncoder.encode(details.getConfirmationNumber(),
                            java.nio.charset.StandardCharsets.UTF_8)
                    + "&notice=" + notice);

        } catch (SQLException e) {
            throw new ServletException("Reservation cancellation failed", e);
        }
    }

    /**
     * Reads the signed-in customer's ID from the session.
     *
     * @param request the incoming request
     * @return the customer ID, or {@code null} if nobody is signed in
     */
    private Integer signedInCustomerId(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) {
            return null;
        }
        Object customerId = session.getAttribute("customerId");
        return customerId instanceof Integer id ? id : null;
    }

    /**
     * Shows the page's own signed-out state rather than bouncing the visitor
     * to the landing page.
     *
     * <p>The JSP already handles this: it checks for
     * {@code sessionScope.customerId} itself and renders a "Sign in to view
     * your reservation" panel with a button that opens the login modal. A
     * redirect elsewhere would throw away the URL they were trying to reach,
     * and the confirmation number with it.
     *
     * @param request the incoming request
     * @param response the response to forward
     * @throws ServletException if the forward fails
     * @throws IOException if the forward fails
     */
    private void showSignInRequired(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        /*
         * Where the login modal should send them once they are signed in.
         * The modal's own redirectTo is built from the request URI, which
         * carries no query string, so the confirmation number would be lost
         * without this.
         */
        String confirmation = request.getParameter(PARAM_CONFIRMATION);
        String returnTo = "/reservationSummary"
                + (confirmation != null && !confirmation.isBlank()
                        ? "?confirmation=" + confirmation.trim()
                        : "");

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
