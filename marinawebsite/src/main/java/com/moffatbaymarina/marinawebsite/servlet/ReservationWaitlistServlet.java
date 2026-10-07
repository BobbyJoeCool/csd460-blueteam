package com.moffatbaymarina.marinawebsite.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;

import com.moffatbaymarina.marinawebsite.dao.WaitListDAO;
import com.moffatbaymarina.marinawebsite.util.DBConnection;
import com.moffatbaymarina.marinawebsite.util.Utils;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Joins the signed-in customer to the wait list for a slip size.
 *
 * <p>Mapped separately from {@code /reservation} because an exact-path
 * servlet mapping doesn't cover sub-paths - {@code reservation.js} posts to
 * {@code /reservation/waitlist}, which needs its own {@code @WebServlet}.
 *
 * @author Robert Breutzmann
 * Blue Team - Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
 * Primary Author/Owner - Robert Breutzmann
 */
@WebServlet("/reservation/waitlist")
public class ReservationWaitlistServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final WaitListDAO waitListDAO = new WaitListDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        Integer customerId = Utils.signedInCustomerId(request);
        if (customerId == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            Utils.writeJson(response, false, "error", "Please sign in to join the wait list.");
            return;
        }

        Integer slipSizeFt = Utils.parseInt(request.getParameter("slipSizeFt"));
        if (!Utils.isSlipSize(slipSizeFt)) {
            Utils.writeJson(response, false, "error", "Choose a valid slip size.");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            // One entry per size per customer. The lock makes a second
            // join from the same customer wait for the first, so the check
            // and the insert can't interleave (a double-click, two tabs).
            conn.setAutoCommit(false);

            try {
                waitListDAO.lockForCustomer(conn, customerId);

                if (waitListDAO.isWaiting(conn, customerId, slipSizeFt)) {
                    conn.rollback();
                    Utils.writeJson(response, false, "alreadyWaiting", true);
                    return;
                }

                waitListDAO.insert(conn, customerId, slipSizeFt);
                conn.commit();
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            }

            Utils.writeJson(response, true);

        } catch (SQLException e) {
            throw new ServletException("Could not join the wait list.", e);
        }
    }
}
