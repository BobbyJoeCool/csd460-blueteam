package com.moffatbaymarina.marinawebsite.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;

import com.moffatbaymarina.marinawebsite.dao.BoatDAO;
import com.moffatbaymarina.marinawebsite.dao.CustomerDAO;
import com.moffatbaymarina.marinawebsite.dao.ReservationDAO;
import com.moffatbaymarina.marinawebsite.dao.WaitListDAO;
import com.moffatbaymarina.marinawebsite.util.CustomerSession;
import com.moffatbaymarina.marinawebsite.util.DBConnection;
import com.moffatbaymarina.marinawebsite.util.Utils;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * "Delete my account" on Your Account (issue #337).
 *
 * <p>Not a real delete: the Customer row stays, emptied of everything that
 * identifies the customer ({@link CustomerDAO#anonymise}), so the
 * reservation history that points at it is kept for the books, as the
 * Privacy Policy says. In one transaction it also takes the customer off
 * every wait list they're in line on and ends every boat ownership, so
 * nothing is left looking like a live customer.
 *
 * <p>Asks for the current password, since this can't be undone and a
 * signed-in browser left open shouldn't be enough. Refused while the
 * customer has a lease that isn't over ({@link ReservationDAO#hasLeaseNotOver}):
 * the marina still needs to know who is in that slip.
 *
 * <p>A real form POST that navigates, not a fetch: success signs the
 * customer out, so there's no page left to update. A refusal forwards back
 * to editUserInfo.jsp with {@code deleteError}, which reopens the popup
 * with the message in it.
 *
 * @author Miguel Fernandez
 * Blue Team - Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
 * Primary Author/Owner - Miguel Fernandez
 */
@WebServlet("/editProfile/delete")
public class AccountDeleteServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final CustomerDAO customerDAO = new CustomerDAO();
    private final ReservationDAO reservationDAO = new ReservationDAO();
    private final WaitListDAO waitListDAO = new WaitListDAO();
    private final BoatDAO boatDAO = new BoatDAO();

    /**
     * A refusal leaves /editProfile/delete in the address bar, so reloading
     * or revisiting that address lands here. Nothing to show at this
     * address, so back to Your Account.
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        response.sendRedirect(request.getContextPath() + "/editProfile");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        Integer customerId = Utils.signedInCustomerId(request);
        if (customerId == null) {
            CustomerSession.sendToSignIn(request, response, "/editProfile");
            return;
        }

        String password = Utils.orEmpty(request.getParameter("currentPassword"));
        if (password.isEmpty()) {
            refuse(request, response, "Enter your password to delete your account.");
            return;
        }

        try {
            if (!customerDAO.verifyPassword(customerId, Utils.hashPassword(password))) {
                refuse(request, response, "That password is incorrect.");
                return;
            }

            try (Connection conn = DBConnection.getConnection()) {
                conn.setAutoCommit(false);
                try {
                    // Checked inside the transaction, so it's the same
                    // database state the deletion acts on.
                    if (reservationDAO.hasLeaseNotOver(conn, customerId)) {
                        conn.rollback();
                        refuse(request, response,
                                "You have a current or upcoming reservation. Cancel it, or give "
                                + "30 days' notice, before deleting your account.");
                        return;
                    }

                    waitListDAO.cancelOpenEntriesForCustomer(conn, customerId);
                    boatDAO.endAllOwnerships(conn, customerId);
                    customerDAO.anonymise(conn, customerId);
                    conn.commit();
                } catch (SQLException e) {
                    conn.rollback();
                    throw e;
                } finally {
                    conn.setAutoCommit(true);
                }
            }
        } catch (SQLException e) {
            throw new ServletException("Account deletion failed.", e);
        }

        // Signed out everywhere: other browsers first, then this one.
        CustomerSession.endOtherSessions(customerId, null);
        HttpSession session = request.getSession(false);
        if (session != null) {
            try {
                session.invalidate();
            } catch (IllegalStateException alreadyEnded) {
                // endOtherSessions with no session to keep already ended it.
            }
        }

        response.sendRedirect(request.getContextPath() + "/?notice=accountDeleted");
    }

    /**
     * Back to Your Account with the popup reopened and the reason in it.
     */
    private void refuse(HttpServletRequest request, HttpServletResponse response, String message)
            throws ServletException, IOException {
        request.setAttribute("deleteError", message);
        request.getRequestDispatcher("/WEB-INF/views/editUserInfo.jsp").forward(request, response);
    }
}
