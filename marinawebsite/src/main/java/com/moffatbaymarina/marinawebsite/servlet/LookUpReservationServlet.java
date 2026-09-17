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

/**
 * Handles reservation lookup requests by confirmation number.
 *
 * <p>This servlet receives a confirmation number from the
 * Look Up Reservation page, uses {@code ReservationDAO} to
 * retrieve the matching reservation, and forwards the result
 * or an error message back to the JSP.
 *
 * <p>This handles the basic reservation
 * lookup only. Authentication and customer ownership validation
 * will be added after the final lookup requirements are confirmed.
 *
 * @author Rodriguez, C.
 * Blue Team - Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
 * Primary Author/Owner - Carolina Rodriguez
 */

// Maps this servlet to /lookUpReservation in the application.
@WebServlet("/lookUpReservation")
public class LookUpReservationServlet extends HttpServlet {

    // DAO used to retrieve reservation information from the database.
    private final ReservationDAO reservationDAO = new ReservationDAO();

    /**
     * Handles GET requests.
     *
     * <p>When the user first opens the Look Up Reservation page,
     * this method simply forwards the request to the JSP.
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Load the Look Up Reservation page.
        request.getRequestDispatcher("/lookUpReservation.jsp")
                .forward(request, response);
    }

    /**
     * Handles POST requests from the reservation lookup form.
     *
     * <p>The confirmation number entered by the user is validated,
     * then passed to the ReservationDAO to search for a matching
     * reservation.
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Get the confirmation number submitted from the form.
        String confirmation = request.getParameter("confirmation");

        // Make sure the user entered a confirmation number.
        if (confirmation == null || confirmation.isBlank()) {

            // Store an error message that the JSP can display.
            request.setAttribute(
                    "lookupError",
                    "Please enter a confirmation number."
            );

            // Return to the lookup page so the user can correct the input.
            request.getRequestDispatcher("/lookUpReservation.jsp")
                    .forward(request, response);

            return;
        }

        try {

            // Temporary debug message: shows what confirmation number Tomcat received.
            System.out.println("Looking up confirmation: " + confirmation);

            // Remove extra spaces and search the database for the reservation.
            ReservationDetails reservation =
                    reservationDAO.findDetailsByConfirmation(confirmation.trim());

            // Temporary debug message: shows whether the DAO found a reservation.
            System.out.println("Reservation found: " + reservation);

            // If no matching reservation was found, send an error to the JSP.
            if (reservation == null) {

                request.setAttribute(
                        "lookupError",
                        "No reservation was found."
                );

            } else {

                // Store the reservation so the JSP can display its details.
                request.setAttribute("reservation", reservation);
            }

            request.getRequestDispatcher("/lookUpReservation.jsp")
                    .forward(request, response);

        } catch (SQLException e) {
            throw new ServletException(
                    "Unable to look up reservation.",
                    e
            );
        }
    }
}
