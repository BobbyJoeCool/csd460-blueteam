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

            request.setAttribute(
                    "fleet",
                    boatDAO.findFleetByCustomerId(
                            conn,
                            customerId
                    )
            );

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