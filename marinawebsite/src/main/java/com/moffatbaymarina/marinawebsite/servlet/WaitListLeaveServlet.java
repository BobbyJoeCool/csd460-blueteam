package com.moffatbaymarina.marinawebsite.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;

import com.moffatbaymarina.marinawebsite.dao.WaitListDAO;
import com.moffatbaymarina.marinawebsite.util.CustomerSession;
import com.moffatbaymarina.marinawebsite.util.DBConnection;
import com.moffatbaymarina.marinawebsite.util.Utils;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Takes the signed-in customer off one wait list, from the Leave Wait List
 * button on a Your Place in Line card (issue #346). POST only, behind the
 * page's confirmation popup.
 *
 * <p>The entry is cancelled, not deleted - see
 * {@link WaitListDAO#cancelEntryForCustomer}. The customer comes from the
 * session; only the entry's ID comes from the form, and the DAO refuses an
 * ID that isn't theirs.
 *
 * <p>An entry that wasn't theirs, or had already left the line, gets the
 * page back with no message, so the response doesn't say whether that ID
 * exists.
 *
 * Blue Team - Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
 * Primary Author/Owner - Robert Breutzmann
 */
@WebServlet("/waitList/leave")
public class WaitListLeaveServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final WaitListDAO waitListDAO = new WaitListDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        Integer customerId = Utils.signedInCustomerId(request);
        if (customerId == null) {
            CustomerSession.sendToSignIn(request, response, "/waitList");
            return;
        }

        Integer waitListId = Utils.parseInt(request.getParameter("waitListId"));
        if (waitListId == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        boolean left;
        try (Connection conn = DBConnection.getConnection()) {
            left = waitListDAO.cancelEntryForCustomer(conn, waitListId, customerId);
        } catch (SQLException e) {
            throw new ServletException("Could not leave the wait list.", e);
        }

        // Redirect, not forward, so a refresh doesn't post it again.
        response.sendRedirect(request.getContextPath() + "/waitList"
                + (left ? "?notice=leftWaitList" : ""));
    }
}
