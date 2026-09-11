package com.moffatbaymarina.marinawebsite.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;

import com.moffatbaymarina.marinawebsite.dao.WaitListDAO;
import com.moffatbaymarina.marinawebsite.util.DBConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * Joins the signed-in customer to the wait list for a slip size.
 *
 * <p>Mapped separately from {@code /reservation} because an exact-path
 * servlet mapping doesn't cover sub-paths - {@code reservation.js} posts to
 * {@code /reservation/waitlist}, which needs its own {@code @WebServlet}.
 *
 * @author Robert Breutzmann
 */
@WebServlet("/reservation/waitlist")
public class ReservationWaitlistServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final WaitListDAO waitListDAO = new WaitListDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/json");

        Integer customerId = signedInCustomerId(request);
        if (customerId == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            writeJson(response, "{\"ok\":false,\"error\":\"Please sign in to join the wait list.\"}");
            return;
        }

        Integer slipSizeFt = parseInt(request.getParameter("slipSizeFt"));
        if (slipSizeFt == null || (slipSizeFt != 26 && slipSizeFt != 40 && slipSizeFt != 50)) {
            writeJson(response, "{\"ok\":false,\"error\":\"Choose a valid slip size.\"}");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            if (waitListDAO.isWaiting(conn, customerId, slipSizeFt)) {
                writeJson(response, "{\"ok\":false,\"alreadyWaiting\":true}");
                return;
            }

            waitListDAO.insert(conn, customerId, slipSizeFt);
            writeJson(response, "{\"ok\":true}");

        } catch (SQLException e) {
            throw new ServletException("Could not join the wait list.", e);
        }
    }

    private Integer signedInCustomerId(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) {
            return null;
        }
        Object value = session.getAttribute("customerId");
        return value instanceof Integer id ? id : null;
    }

    private Integer parseInt(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        try {
            return Integer.valueOf(value);
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private void writeJson(HttpServletResponse response, String json) throws IOException {
        response.getWriter().write(json);
    }
}
