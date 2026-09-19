package com.moffatbaymarina.marinawebsite.servlet;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

import com.moffatbaymarina.marinawebsite.dao.ReservationDAO;
import com.moffatbaymarina.marinawebsite.model.ReservationDetails;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * Handles reservation lookup requests for signed-in customers.
 *
 * <p>The servlet reads the signed-in customer's ID from the session
 * and returns only reservations that belong to that customer.
 * Optional filters include reservation number, year, month, and
 * newest/oldest sorting.
 *
 * @author Rodriguez, C.
 * Blue Team - Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
 * Primary Author/Owner - Carolina Rodriguez
 */
@WebServlet("/reservations")
public class LookUpReservationServlet extends HttpServlet {

    private static final String VIEW = "/lookUpReservation.jsp";

    private final ReservationDAO reservationDAO = new ReservationDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Require a signed-in customer.
        Integer customerId = signedInCustomerId(request);

        System.out.println("Customer ID being used: " + customerId);

        if (customerId == null) {
        request.setAttribute("signInRequired", true);
        request.setAttribute("signInRedirectTo", "/reservations");

        request.getRequestDispatcher(VIEW)
                .forward(request, response);
        return;
        }

        // Optional search filters from Sara's form.
        String reservationNumber =
                request.getParameter("reservationNumber");

        String year =
                request.getParameter("year");

        String month =
                request.getParameter("month");

        String sort =
                request.getParameter("sort");
                

        // Newest first is the default.
        String order = "DESC";

        if ("oldest".equals(sort)) {
            order = "ASC";
        }

        try {
                List<ReservationDetails> reservations =
                        reservationDAO.findReservationsByCustomer(
                                customerId,
                                reservationNumber,
                                year,
                                month,
                                order
                        );

                System.out.println("Reservations found: " + reservations.size());

                request.setAttribute("reservations", reservations);

                request.setAttribute("lookupPerformed", true);

                request.getRequestDispatcher(VIEW)
                        .forward(request, response);

        } catch (SQLException e) {
            throw new ServletException(
                    "Unable to load reservations.",
                    e
            );
        }
    }

    /**
     * Gets the signed-in customer's ID from the session.
     */
    private Integer signedInCustomerId(HttpServletRequest request) {

        HttpSession session = request.getSession(false);

        if (session == null) {
            return null;
        }

        Object customerId =
                session.getAttribute("customerId");

        if (customerId instanceof Number number) {
                return number.intValue();
        }

        return null;
}

}
