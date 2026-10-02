package com.moffatbaymarina.marinawebsite.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;

import com.moffatbaymarina.marinawebsite.dao.BoatDAO;
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
 * Loads the signed-in customer's current fleet from the database and sends
 * the boat information to the My Fleet page for display.
 *
 * <p>Also owns {@link #showFleet}, the one place My Fleet is rendered. The
 * add, edit and remove servlets call it to show the page again with an
 * error, so they can't drift from what this page shows.
 */

@WebServlet("/myFleet")
public class MyFleetServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    /** The My Fleet page. Behind WEB-INF, so only a servlet can show it. */
    static final String VIEW = "/WEB-INF/views/myFleet.jsp";

    // BoatDAO holds no state, so one shared instance is safe.
    private static final BoatDAO FLEET_DAO = new BoatDAO();

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        Integer customerId = Utils.signedInCustomerId(request);
        if (customerId == null) {
            CustomerSession.showSignInPanel(request, response, VIEW, "/myFleet");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            showFleet(request, response, conn, customerId, null);

        } catch (SQLException e) {
            throw new ServletException(
                    "Unable to load My Fleet.",
                    e
            );
        }
    }

    /**
     * Renders My Fleet with the customer's current boats - only the boats
     * they own - optionally with a page-level error.
     *
     * <p>Callers set any form-specific attributes first ({@code fieldErrors},
     * {@code openForm}, {@code editBoatId}, {@code postedFields}); this adds
     * the error and the fleet, and forwards.
     *
     * @param request the request to forward
     * @param response the response to forward
     * @param conn an open connection, used to load the fleet
     * @param customerId the signed-in customer
     * @param formError the page-level error to show, or {@code null} for none
     * @throws SQLException if the fleet can't be loaded
     * @throws ServletException if the forward fails
     * @throws IOException if the forward fails
     */
    static void showFleet(
            HttpServletRequest request,
            HttpServletResponse response,
            Connection conn,
            int customerId,
            String formError)
            throws SQLException, ServletException, IOException {

        if (formError != null) {
            request.setAttribute("formError", formError);
        }

        request.setAttribute(
                "fleet",
                FLEET_DAO.findFleetByCustomerId(conn, customerId)
        );

        request.getRequestDispatcher(VIEW).forward(request, response);
    }
}
