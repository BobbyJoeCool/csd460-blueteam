package com.moffatbaymarina.marinawebsite.servlet;

import java.io.IOException;
import java.sql.SQLException;

import com.moffatbaymarina.marinawebsite.dao.CustomerDAO;
import com.moffatbaymarina.marinawebsite.model.Customer;
import com.moffatbaymarina.marinawebsite.util.Utils;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * Implements the flow documented in the Login contract
 * (marinawebsite/documentation/Page Contracts/Login.md): "Locking an
 * Account After Repeated Failures", "What the Session Remembers",
 * "What the Front End Sees on Failure", "Where the User Lands After
 * Login".
 *
 * <p>Deviates from the contract's literal "simple error page with a
 * link back to the homepage" on one point (team decision, not yet
 * reflected in the contract doc): there is no separate error page.
 * Login is a modal that can be opened from any page, so on failure
 * this servlet sends the visitor back to whatever page the modal was
 * opened on - the same {@code redirectTo} field used for a success
 * redirect - with the message waiting for it. That page re-opens the
 * modal with the error shown inline.
 *
 * <p><strong>Failure redirects; it does not forward.</strong> It used to
 * forward, and that worked only because {@code redirectTo} happened to
 * name a raw {@code .jsp}. Once that value was corrected to the servlet
 * path - so a <em>successful</em> login runs the target's {@code doGet}
 * instead of rendering its JSP with none of its data - forwarding began
 * re-invoking the target servlet with this login POST, so signing in
 * from the Reservation page called {@code ReservationServlet.doPost}
 * and answered with the booking endpoint's "Please sign in to reserve a
 * slip" JSON. One value cannot be both a JSP to forward to and a
 * servlet path to redirect to, so the failure path redirects as well
 * and the message rides in the session for exactly one read - the same
 * approach {@code EditProfileServlet} takes with its before/after diff,
 * and for the same reason: a redirect drops request attributes.
 *
 * <p>Every invalid-credentials failure also sets
 * {@code lockoutThreshold}, so the modal can tell the user that accounts
 * lock after that many tries. It is the same fixed number on every
 * failure, whether or not the email belongs to a real account. An
 * earlier version sent a per-account countdown ("2 more attempts...")
 * instead, which was a mistake: a countdown only ever appears for an
 * address that exists, so it confirmed valid accounts and undid the
 * whole point of the single generic error message.
 *
 * @author Robert Breutzmann
 * Blue Team - Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
 * Primary Author/Owner - Robert Breutzmann
 * @implNote JavaDoc comments in this file were added with the assistance of Claude.
 */
@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    private static final String PARAM_IDENTIFIER = "email";
    private static final String PARAM_PASSWORD = "password";

    /* Fixed by the Login contract's "Where the User Lands After Login" - Front End sets this hidden field's value, not its name. */
    private static final String PARAM_REDIRECT_TO = "redirectTo";

    private static final String DEFAULT_REDIRECT = "/";
    private static final int MAX_FAILED_ATTEMPTS = 3;

    /*
     * Session keys for the one-read failure message. Prefixed rather than
     * named "loginError" outright, so they can't collide with the
     * page-scoped variables includes/loginModal.jsp reads them into, and so
     * it is obvious in a session dump where they came from. The modal
     * clears all four with <c:remove> as it renders; nothing else reads
     * them.
     */
    private static final String FLASH_ERROR = "loginFlashError";
    private static final String FLASH_LOCKED = "loginFlashAccountLocked";
    private static final String FLASH_THRESHOLD = "loginFlashLockoutThreshold";
    private static final String FLASH_EMAIL = "loginFlashEmail";

    private final CustomerDAO customerDAO = new CustomerDAO();

    /**
     * Entry point for every POST to /login. Runs the full login check
     * (lookup, lockout, password compare, attempt counting) and either
     * logs the user in or sends them back with one of the two failure
     * messages. Every outcome ends in a redirect.
     *
     * <p>Used to also route a demo "Unlock Account" reset click
     * ({@code action=reset}) - retired as part of the Edit User Info
     * build. A locked account now unlocks itself only by completing the
     * forgot-password reset ({@code ForgotPasswordServlet}), which
     * verifies a (simulated) code and requires choosing a new password,
     * rather than a plain no-verification reset.
     *
     * @param request the incoming login request
     * @param response the response to redirect
     * @throws ServletException if the login lookup/update fails
     * @throws IOException if the redirect fails
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String identifier = request.getParameter(PARAM_IDENTIFIER);
        String password = request.getParameter(PARAM_PASSWORD);

        if (identifier == null || identifier.isBlank() || password == null || password.isBlank()) {
            showInvalidCredentials(request, response);
            return;
        }

        try {
            Customer customer = customerDAO.findByEmail(identifier);

            if (customer == null) {
                // No account with this email - no attempt to record, there's nothing to attach it to.
                showInvalidCredentials(request, response);
                return;
            }

            if (customer.isAccountLocked()) {
                // Already locked - don't even check the password.
                showAccountLocked(request, response);
                return;
            }

            String submittedHash = Utils.hashPassword(password);
            // By customerId, not identifier (email): findByEmail above
            // already resolved which account this is, so there's no
            // reason to go back to the mutable email string for the
            // actual credential check when the stable ID is already in
            // hand - see CustomerDAO.verifyPassword(int, String).
            if (customerDAO.verifyPassword(customer.getCustomerId(), submittedHash)) {
                customerDAO.resetFailedAttempts(customer.getCustomerId());
                logInAndRedirect(request, response, customer);
                return;
            }

            int attempts = customerDAO.recordFailedAttempt(customer.getCustomerId());
            if (attempts >= MAX_FAILED_ATTEMPTS) {
                customerDAO.lockAccount(customer.getCustomerId());
                showAccountLocked(request, response);
            } else {
                showInvalidCredentials(request, response);
            }
        } catch (SQLException e) {
            throw new ServletException("Login lookup/update failed", e);
        }
    }

    /**
     * Stores the four session attributes from the Login contract's
     * "What the Session Remembers" (loggedIn, customer, customerId,
     * displayName), then redirects to wherever
     * {@link Utils#safeRedirectTarget(String, String)} says is safe.
     *
     * <p>Invalidates any pre-existing session and starts a fresh one first,
     * per OWASP's Session Management Cheat Sheet guidance to regenerate the
     * session ID on authentication - otherwise a session ID an attacker
     * fixed before login (session fixation) would carry straight through
     * into an authenticated session.
     *
     * @param request the login request, used to obtain the session and redirect target
     * @param response the response to redirect
     * @param customer the customer who just logged in
     * @throws IOException if the redirect fails
     */
    private void logInAndRedirect(HttpServletRequest request, HttpServletResponse response, Customer customer)
            throws IOException {
        HttpSession oldSession = request.getSession(false);
        if (oldSession != null) {
            oldSession.invalidate();
        }
        HttpSession session = request.getSession(true);
        session.setAttribute("loggedIn", Boolean.TRUE);
        session.setAttribute("customer", customer);
        session.setAttribute("customerId", customer.getCustomerId());
        session.setAttribute("displayName", customer.getDisplayName());

        /*
         * Tell the shared status popup to say "Logged in successfully" on
         * whatever page they land on. A keyword, not the wording - the
         * wording lives in js/statusPopup.js, because anything travelling
         * in a URL is whatever was in the link somebody clicked.
         *
         * Appended defensively in case safeRedirectTarget ever returns a
         * path that already carries a query string of its own.
         *
         * Deliberately only on this path - a successful login, and only
         * a successful login.
         */
        String target = Utils.safeRedirectTarget(
                request.getParameter(PARAM_REDIRECT_TO), DEFAULT_REDIRECT);
        target += (target.contains("?") ? "&" : "?") + "notice=loggedIn";

        response.sendRedirect(request.getContextPath() + target);
    }

    /**
     * Sets the generic "username or password" loginError message (the
     * one that never reveals which field was wrong) plus the fixed
     * {@code lockoutThreshold} the modal uses to mention the lockout
     * rule, then forwards back to the page the modal was opened on.
     *
     * <p>The threshold is set on every failure, including ones for an
     * email that isn't registered. That is the point: a message that only
     * appeared for real accounts would identify them.
     *
     * @param request the request to attach the error message to
     * @param response the response to redirect
     * @throws IOException if the redirect fails
     */
    private void showInvalidCredentials(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession(true);
        session.setAttribute(FLASH_ERROR, "The username or password you entered is incorrect.");
        session.setAttribute(FLASH_THRESHOLD, MAX_FAILED_ATTEMPTS);
        redirectToOriginPage(request, response);
    }

    /**
     * Sets the account-locked loginError message plus the
     * accountLocked flag the modal checks to show the forgot-password
     * reset entry point, then forwards back to the page the modal was
     * opened on.
     *
     * @param request the request to attach the error message and flag to
     * @param response the response to redirect
     * @throws IOException if the redirect fails
     */
    private void showAccountLocked(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession(true);
        session.setAttribute(FLASH_ERROR, "This account has been locked after multiple failed login attempts.");
        session.setAttribute(FLASH_LOCKED, Boolean.TRUE);
        redirectToOriginPage(request, response);
    }

    /**
     * Shared last step for both failure cases: redirects to
     * {@link Utils#safeRedirectTarget(String, String)} - the same page the
     * login modal was submitted from - where the modal re-opens with the
     * message the caller just put in the session.
     *
     * <p>The submitted email travels with it so the field refills. It used
     * to survive on its own as a request parameter through the forward; a
     * redirect starts a clean request, so it goes in the session with the
     * rest. It is also what the locked-out state hands the reset modal, and
     * it is deliberately not put in the URL, where it would end up in
     * browser history and server logs.
     *
     * @param request the login request
     * @param response the response to redirect
     * @throws IOException if the redirect fails
     */
    private void redirectToOriginPage(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        String submittedEmail = request.getParameter(PARAM_IDENTIFIER);
        if (submittedEmail != null && !submittedEmail.isBlank()) {
            request.getSession(true).setAttribute(FLASH_EMAIL, submittedEmail.trim());
        }

        response.sendRedirect(request.getContextPath() + Utils.safeRedirectTarget(
                request.getParameter(PARAM_REDIRECT_TO), DEFAULT_REDIRECT));
    }
}
