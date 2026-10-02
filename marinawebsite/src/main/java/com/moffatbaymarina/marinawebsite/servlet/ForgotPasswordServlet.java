package com.moffatbaymarina.marinawebsite.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.Locale;

import com.moffatbaymarina.marinawebsite.dao.CustomerDAO;
import com.moffatbaymarina.marinawebsite.model.Customer;
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
 * check which emails are registered. That guarantee depends on the order
 * the checks run in as much as on the wording; see {@link #doPost}.
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
 * <p>Modeled on {@code LoginServlet}'s redirect-back-to-the-origin-page
 * shape (not the JSON pattern {@link EditProfilePasswordServlet} uses):
 * success and failure both redirect, and a failure's message rides in the
 * session for exactly one read - see {@link #showError}.
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

    /*
     * Session keys for the one-read failure message, read and cleared by
     * WEB-INF/includes/forgotPasswordModal.jsp. Prefixed the same way as
     * LoginServlet's, so the two can't collide.
     */
    private static final String FLASH_ERROR = "forgotFlashError";
    private static final String FLASH_EMAIL = "forgotFlashEmail";

    private final CustomerDAO customerDAO = new CustomerDAO();

    /**
     * Runs the reset. See the class comment for why an unknown email and a
     * wrong code are deliberately indistinguishable to the caller.
     *
     * @param request the incoming POST (email, verificationCode, newPassword, redirectTo)
     * @param response the response to redirect
     * @throws ServletException if the reset fails
     * @throws IOException if the redirect fails
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String email = Utils.clean(request.getParameter("email")).toLowerCase(Locale.ROOT);
        String code = Utils.clean(request.getParameter("verificationCode"));
        String newPassword = Utils.orEmpty(request.getParameter("newPassword"));

        if (email.isEmpty() || code.isEmpty() || newPassword.isEmpty()) {
            showError(request, response, "That code doesn't match - check your email and try again.");
            return;
        }

        /*
         * Checked before the account lookup on purpose. This is the only
         * message this endpoint can return that differs from the generic
         * one below, so running it after the lookup would mean it could
         * only ever appear for an email that actually exists: submitting
         * the (public) code 12345 with a deliberately weak password would
         * then answer "password does not meet the required rules" for a
         * registered address and "that code doesn't match" for an
         * unregistered one, which is exactly the account-enumeration the
         * shared generic message exists to prevent - the same mistake the
         * Login contract records for its old per-account attempts
         * countdown. Answering the format question first gives nothing
         * away, since the password rules are printed next to the field.
         */
        if (!Utils.PASSWORD_PATTERN.matcher(newPassword).matches()) {
            showError(request, response, "New password does not meet the required rules.");
            return;
        }

        try {
            Customer customer = customerDAO.findByEmail(email);

            // Same message either way - see the class-level anti-enumeration note.
            // A deleted account counts as no account (see CustomerDAO.isDeleted).
            if (customer == null || CustomerDAO.isDeleted(customer)
                    || !FAKE_VERIFICATION_CODE.equals(code)) {
                showError(request, response, "That code doesn't match - check your email and try again.");
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

            // Whoever is signed in with the old password is out. The
            // session making this reset stays as it was: from Edit User
            // Info that's this customer, still signed in; from the sign-in
            // popup it isn't signed in to begin with.
            CustomerSession.endOtherSessions(customer.getCustomerId(), request.getSession(false));

            // No auto-login - the customer signs in with the new password
            // from here, same as any other password change. Auto-login
            // would turn the fixed demo code into a way to take over any
            // locked account, not just a UX shortcut.
            String target = Utils.safeRedirectTarget(
                    request.getParameter(PARAM_REDIRECT_TO), DEFAULT_REDIRECT);
            target += (target.contains("?") ? "&" : "?") + "notice=passwordReset";
            response.sendRedirect(request.getContextPath() + target);

        } catch (SQLException e) {
            throw new ServletException("Password reset failed.", e);
        }
    }

    /**
     * Puts the error message in the session and redirects back to the page
     * the modal was opened on, where WEB-INF/includes/forgotPasswordModal.jsp reads
     * it once, clears it, and renders already open with the message shown.
     *
     * <p><strong>Redirects; it does not forward.</strong> {@code redirectTo}
     * is a servlet path such as {@code /reservation}, so forwarding this POST
     * to it ran that servlet's {@code doPost} (or hit a 405 where there is
     * none): a wrong code on About Us or Wait List showed an error page, and
     * on Book a Slip it showed the booking endpoint's "Please sign in" JSON.
     * {@code LoginServlet} had the same bug and fixed it the same way.
     *
     * <p>The typed email rides along so the field refills. It goes in the
     * session, not the URL, where it would end up in history and logs.
     */
    private void showError(HttpServletRequest request, HttpServletResponse response, String message)
            throws IOException {
        HttpSession session = request.getSession(true);
        session.setAttribute(FLASH_ERROR, message);

        String submittedEmail = Utils.clean(request.getParameter("email"));
        if (!submittedEmail.isEmpty()) {
            session.setAttribute(FLASH_EMAIL, submittedEmail);
        }

        response.sendRedirect(request.getContextPath() + Utils.safeRedirectTarget(
                request.getParameter(PARAM_REDIRECT_TO), DEFAULT_REDIRECT));
    }
}
