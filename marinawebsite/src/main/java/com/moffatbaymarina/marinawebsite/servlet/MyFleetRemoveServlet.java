package com.moffatbaymarina.marinawebsite.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;

import com.moffatbaymarina.marinawebsite.dao.BoatDAO;
import com.moffatbaymarina.marinawebsite.model.Boat;
import com.moffatbaymarina.marinawebsite.util.CustomerSession;
import com.moffatbaymarina.marinawebsite.util.DBConnection;
import com.moffatbaymarina.marinawebsite.util.Utils;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * @author Carolina R.
 * Blue Team - Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
 * Primary Author/Owner - Carolina R.
 *
 * Handles removing a boat from the signed-in customer's current fleet. The
 * servlet checks ownership and active reservations, then performs a soft remove
 * by ending the BoatOwnership record instead of deleting the boat.
 */

@WebServlet("/myFleet/remove")
public class MyFleetRemoveServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    // DAO used for My Fleet boat and ownership database operations.
    private final BoatDAO boatDAO = new BoatDAO();

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        // Make sure the customer is signed in.
        Integer customerId = Utils.signedInCustomerId(request);
        if (customerId == null) {
            CustomerSession.sendToSignIn(request, response, "/myFleet");
            return;
        }

        // Get the boat that the customer wants to remove.
        Integer boatId =
                Utils.parseInt(
                        request.getParameter("boatId")
                );

        if (boatId == null) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST
            );
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {

            // Make sure the boat belongs to the signed-in customer.
            Boat boat =
                    boatDAO.findOwnedBoat(
                            conn,
                            customerId,
                            boatId
                    );

            if (boat == null) {

                MyFleetServlet.showFleet(request, response, conn, customerId,
                        "That boat couldn't be found in your fleet.");
                return;
            }

            // A boat with an active reservation cannot be removed.
            String reservationLocation =
                    boatDAO.activeReservationLocation(
                            conn,
                            boatId
                    );

            if (reservationLocation != null) {

                MyFleetServlet.showFleet(request, response, conn, customerId,
                        "This boat can't be removed from your account while it's part of an active reservation ("
                        + reservationLocation
                        + ").");
                return;
            }

            conn.setAutoCommit(false);

            try {

                // Soft remove: end ownership instead of deleting the boat.
                int rows =
                        boatDAO.endOwnership(
                                conn,
                                boatId,
                                customerId
                        );

                if (rows != 1) {

                    conn.rollback();

                    MyFleetServlet.showFleet(request, response, conn, customerId,
                            "That boat couldn't be found in your fleet.");
                    return;
                }

                conn.commit();

            } catch (SQLException e) {

                conn.rollback();
                throw e;

            } finally {

                conn.setAutoCommit(true);
            }

        } catch (SQLException e) {

            throw new ServletException(
                    "Boat could not be removed.",
                    e
            );
        }

        response.sendRedirect(
                request.getContextPath()
                        + "/myFleet?notice=boatRemoved"
        );
    }
}