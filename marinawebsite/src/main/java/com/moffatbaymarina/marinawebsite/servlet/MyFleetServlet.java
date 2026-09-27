package com.moffatbaymarina.marinawebsite.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;

import com.moffatbaymarina.marinawebsite.dao.BoatDAO;
import com.moffatbaymarina.marinawebsite.util.DBConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * @author Carolina R.
 * Blue Team - Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
 * Primary Author/Owner - Carolina R.
 *
 * Loads the signed-in customer's current fleet from the database and sends
 * the boat information to the My Fleet page for display.
 */

@WebServlet("/myFleet")
public class MyFleetServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final BoatDAO boatDAO = new BoatDAO();

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null
                || !(session.getAttribute("customerId") instanceof Number)) {

            response.sendRedirect(request.getContextPath() + "/");
            return;
        }

        int customerId =
                ((Number) session.getAttribute("customerId")).intValue();

        try (Connection conn = DBConnection.getConnection()) {

        //Loads only the boats that are owned by the signed-in customer
        //The fleet is placed in the request attribute for use in the JSP and display it
            request.setAttribute(
                    "fleet",
                    boatDAO.findFleetByCustomerId(
                            conn,
                            customerId
                    )
            );

            // Load the customer's fleet and forward to the JSP.
            request.getRequestDispatcher("/myFleet.jsp")
                    .forward(request, response);

        } catch (SQLException e) {
            throw new ServletException(
                    "Unable to load My Fleet.",
                    e
            );
        }
    }
}