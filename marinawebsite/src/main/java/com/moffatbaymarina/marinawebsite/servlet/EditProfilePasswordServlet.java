package com.moffatbaymarina.marinawebsite.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;

import com.moffatbaymarina.marinawebsite.dao.CustomerDAO;
import com.moffatbaymarina.marinawebsite.util.DBConnection;
import com.moffatbaymarina.marinawebsite.util.Utils;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * The Change Password popup modal's own submission, per the Edit User
 * Profile contract's "Password Change (Popup Modal)" section - a fully
 * separate request/response from the profile-fields form
 * ({@link EditProfileServlet}), so a bad current password never touches
 * (or is affected by) an unrelated field edit submitted separately.
 *
 * <p>Returns JSON rather than forwarding/redirecting, the same way
 * {@link ReservationBoatServlet} does - the contract's "modal closes with
 * a success message... matching how 'Boat saved' already works on the
 * Reservation page" is describing that exact mechanism: the modal closes
 * itself via JavaScript once the fetch resolves, with no full page
 * reload, rather than a server-rendered page swap.
 *
 * <p>Verifies the current password by {@code customerId} (from the
 * session), not by email - this page is precisely what makes email a
 * mutable field now, so identifying the account by its ID rather than by
 * an address that could itself be mid-change is the safer of the two.
 *
 * @author Robert Breutzmann
 * Blue Team - Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
 * Primary Author/Owner - Robert Breutzmann
 * @implNote JavaDoc comments in this file were added with the assistance of Claude.
 */
@WebServlet("/editProfile/password")
public class EditProfilePasswordServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final CustomerDAO customerDAO = new CustomerDAO();

    /**
     * Verifies {@code currentPassword} before looking at {@code newPassword}
     * at all - a wrong current password rejects the change outright,
     * regardless of whether {@code newPassword} would otherwise have been
     * valid (contract: "not evaluated or discarded silently").
     *
     * @param request the incoming POST (current password, new password)
     * @param response the JSON response
     * @throws ServletException if the password update fails
     * @throws IOException if writing the response fails
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/json");

        HttpSession session = request.getSession(false);
        Object idValue = session == null ? null : session.getAttribute("customerId");
        if (!(idValue instanceof Integer customerId)) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            writeError(response, "Please sign in before changing your password.");
            return;
        }

        String currentPassword = value(request.getParameter("currentPassword"));
        String newPassword = value(request.getParameter("newPassword"));

        if (currentPassword.isEmpty() || newPassword.isEmpty()) {
            writeError(response, "Enter your current password and a new password.");
            return;
        }

        try {
            String currentHash = Utils.hashPassword(currentPassword);
            if (!customerDAO.verifyPassword(customerId, currentHash)) {
                writeError(response, "Current password is incorrect.");
                return;
            }

            if (!Utils.PASSWORD_PATTERN.matcher(newPassword).matches()) {
                writeError(response, "New password does not meet the required rules.");
                return;
            }

            String newHash = Utils.hashPassword(newPassword);
            try (Connection conn = DBConnection.getConnection()) {
                conn.setAutoCommit(false);
                try {
                    customerDAO.updatePassword(conn, customerId, newHash);
                    conn.commit();
                } catch (SQLException e) {
                    conn.rollback();
                    throw e;
                } finally {
                    conn.setAutoCommit(true);
                }
            }

            response.getWriter().write("{\"ok\":true}");

        } catch (SQLException e) {
            throw new ServletException("Password change failed.", e);
        }
    }

    private String value(String value) {
        return value == null ? "" : value;
    }

    private void writeError(HttpServletResponse response, String message) throws IOException {
        response.getWriter().write("{\"ok\":false,\"error\":\"" + jsonEscape(message) + "\"}");
    }

    private String jsonEscape(String value) {
        return value.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\r", "\\r")
                .replace("\n", "\\n");
    }
}
