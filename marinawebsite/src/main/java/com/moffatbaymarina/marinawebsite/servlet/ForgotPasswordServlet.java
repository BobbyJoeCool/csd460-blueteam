package com.moffatbaymarina.marinawebsite.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.Locale;

import com.moffatbaymarina.marinawebsite.dao.CustomerDAO;
import com.moffatbaymarina.marinawebsite.model.Customer;
import com.moffatbaymarina.marinawebsite.util.DBConnection;
import com.moffatbaymarina.marinawebsite.util.Utils;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * The forgot-password reset flow from the Edit User Profile contract's
 * "Password Change and the Lockout Model" - simulates the standard
 * email-a-verification-code reset with a fixed fake code ({@code 12345},
 * since this project's emails aren't real), and on success both changes
 * the password and clears the account's lockout state
 * ({@link CustomerDAO#resetPasswordAndUnlock(Connection, int, String)}).
 *
 * <p>This <strong>replaces</strong> the Login page's old "Unlock Account"
 * demo button entirely (retired along with
 * {@code CustomerDAO.unlockAccount()}) - a locked-out customer now unlocks
 * their account by successfully completing this reset, not through a
 * separate no-verification action.
 *
 * <p>Identifies the account by {@code email}, exactly like {@code LoginServlet}
 * does, since a locked-out visitor has no logged-in session to identify
 * them any other way - the whole point of this flow is that it has to work
 * for someone who can't sign in, on any device, at any later time, not
 * just in the same browser tab where the lockout happened. An unrecognized
 * email and a correct-email-wrong-code submission produce the identical
 * message ({@link #showError}), the same anti-enumeration handling
 * {@code LoginServlet} already uses for its own generic "username or
 * password is incorrect" message - a submission here can never be used to
 * check which emails are registered.
 *
 * <p>This endpoint is complete and independently testable (POST
 * {@code email}, {@code verificationCode}, {@code newPassword}, and
 * {@code redirectTo}) - see {@code DevNotes/Scripts/test-edit-user-profile.sh}
 * for one example of driving a servlet this same way from the command
 * line. The actual front-end trigger and modal (opened from the Login
 * modal's locked-out state, and/or from Edit User Info as a "forgot your
 * current password?" escape hatch) are Front End's to build - not
 * included here. Whatever UI ends up calling this only needs to submit
 * those four fields; nothing about the account is identified from a
 * session, so it works the same regardless of where it's called from.
 *
 * <p>Modeled on {@code LoginServlet}'s forward-on-error / redirect-on-success
 * shape (not the JSON pattern {@link EditProfilePasswordServlet} uses),
 * since it has to interoperate with the Login modal's existing
 * forward-back-to-the-origin-page mechanism when opened from there.
 *
 * @author Robert Breutzmann
 * Blue Team - Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
 * Primary Author/Owner - Robert Breutzmann
 * @implNote JavaDoc comments in this file were added with the assistance of Claude.
 */
@WebServlet("/forgotPassword")
public class ForgotPasswordServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    /* The only "verification code" this simulated flow ever accepts. */
    private static final String FAKE_VERIFICATION_CODE = "12345";

    private static final String PARAM_REDIRECT_TO = "redirectTo";
    private static final String DEFAULT_REDIRECT = "/";

    private final CustomerDAO customerDAO = new CustomerDAO();

    /**
     * Runs the reset. See the class comment for why an unknown email and a
     * wrong code are deliberately indistinguishable to the caller.
     *
     * @param request the incoming POST (email, verificationCode, newPassword, redirectTo)
     * @param response the response to redirect or forward
     * @throws ServletException if the reset fails
     * @throws IOException if the redirect or forward fails
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String email = clean(request.getParameter("email")).toLowerCase(Locale.ROOT);
        String code = clean(request.getParameter("verificationCode"));
        String newPassword = value(request.getParameter("newPassword"));

        if (email.isEmpty() || code.isEmpty() || newPassword.isEmpty()) {
            showError(request, response, "That code doesn't match - check your email and try again.");
            return;
        }

        try {
            Customer customer = customerDAO.findByEmail(email);

            // Same message either way - see the class-level anti-enumeration note.
            if (customer == null || !FAKE_VERIFICATION_CODE.equals(code)) {
                showError(request, response, "That code doesn't match - check your email and try again.");
                return;
            }

            if (!Utils.PASSWORD_PATTERN.matcher(newPassword).matches()) {
                showError(request, response, "New password does not meet the required rules.");
                return;
            }

            String newHash = Utils.hashPassword(newPassword);
            try (Connection conn = DBConnection.getConnection()) {
                conn.setAutoCommit(false);
                try {
                    customerDAO.resetPasswordAndUnlock(conn, customer.getCustomerId(), newHash);
                    conn.commit();
                } catch (SQLException e) {
                    conn.rollback();
                    throw e;
                } finally {
                    conn.setAutoCommit(true);
                }
            }

            // No auto-login - the customer signs in with the new password
            // from here, same as any other password change. Auto-login
            // would turn the fixed demo code into a way to take over any
            // locked account, not just a UX shortcut.
            String target = safeRedirectTarget(request);
            target += (target.contains("?") ? "&" : "?") + "notice=passwordReset";
            response.sendRedirect(request.getContextPath() + target);

        } catch (SQLException e) {
            throw new ServletException("Password reset failed.", e);
        }
    }

    /**
     * Sets the error message and forwards back to the page the modal was
     * opened on, so it can re-render already open with the message shown -
     * the same mechanism {@code LoginServlet} uses for its own failures.
     */
    private void showError(HttpServletRequest request, HttpServletResponse response, String message)
            throws ServletException, IOException {
        request.setAttribute("forgotPasswordError", message);
        RequestDispatcher dispatcher = request.getRequestDispatcher(safeRedirectTarget(request));
        dispatcher.forward(request, response);
    }

    private String safeRedirectTarget(HttpServletRequest request) {
        String redirectTo = request.getParameter(PARAM_REDIRECT_TO);
        boolean looksSafe = redirectTo != null && !redirectTo.isBlank()
                && redirectTo.startsWith("/") && !redirectTo.startsWith("//")
                && !redirectTo.contains("://");
        return looksSafe ? redirectTo : DEFAULT_REDIRECT;
    }

    private String clean(String value) {
        return value == null ? "" : value.trim();
    }

    private String value(String value) {
        return value == null ? "" : value;
    }
}
