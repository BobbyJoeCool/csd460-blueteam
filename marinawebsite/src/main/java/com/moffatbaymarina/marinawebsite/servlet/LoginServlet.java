package com.moffatbaymarina.marinawebsite.servlet;

import java.io.IOException;
import java.sql.SQLException;

import com.moffatbaymarina.marinawebsite.dao.CustomerDAO;
import com.moffatbaymarina.marinawebsite.model.Customer;
import com.moffatbaymarina.marinawebsite.util.Utils;

import jakarta.servlet.RequestDispatcher;
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
 * this servlet forwards back to whatever page the modal was opened
 * on - the same {@code redirectTo} field used for a success redirect
 * - with {@code loginError} (and {@code accountLocked}) set as
 * request attributes. Whatever page that is needs to check for those
 * attributes and re-open the modal with the error shown inline; that
 * part is Front End's to build.
 *
 * <p>On a failed attempt against a real account that hasn't locked yet,
 * {@code attemptsRemaining} is also set, so the modal can warn the user
 * how many tries are left. It is deliberately never set for an unknown
 * email - no account, no count, and no way to use the warning to work
 * out which addresses are registered.
 *
 * @author Robert Breutzmann
 * @implNote JavaDoc comments in this file were added with the assistance of Claude.
 */
@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    private static final String PARAM_IDENTIFIER = "email";
    private static final String PARAM_PASSWORD = "password";

    /* Fixed by the Login contract's "Where the User Lands After Login" - Front End sets this hidden field's value, not its name. */
    private static final String PARAM_REDIRECT_TO = "redirectTo";

    /* Fixed by the Login contract's demo reset flow: /login?action=reset. */
    private static final String PARAM_ACTION = "action";
    private static final String ACTION_RESET = "reset";

    private static final String DEFAULT_REDIRECT = "/";
    private static final int MAX_FAILED_ATTEMPTS = 3;

    private final CustomerDAO customerDAO = new CustomerDAO();

    /**
     * Entry point for every POST to /login. Routes a demo reset click
     * to {@link #handleDemoReset(HttpServletRequest, HttpServletResponse)},
     * otherwise runs the full login check (lookup, lockout, password
     * compare, attempt counting) and either logs the user in or shows one
     * of the two failure pages. Every outcome ends in a redirect or a
     * forward to the response.
     *
     * @param request the incoming login request
     * @param response the response to redirect or forward
     * @throws ServletException if the login lookup/update fails
     * @throws IOException if the redirect or forward fails
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (ACTION_RESET.equals(request.getParameter(PARAM_ACTION))) {
            handleDemoReset(request, response);
            return;
        }

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
            if (customerDAO.verifyPassword(identifier, submittedHash)) {
                customerDAO.resetFailedAttempts(customer.getCustomerId());
                logInAndRedirect(request, response, customer);
                return;
            }

            int attempts = customerDAO.recordFailedAttempt(customer.getCustomerId());
            if (attempts >= MAX_FAILED_ATTEMPTS) {
                customerDAO.lockAccount(customer.getCustomerId());
                showAccountLocked(request, response);
            } else {
                /*
                 * Only set on a real account with a real failed attempt, so the
                 * warning can never appear for an email that isn't registered -
                 * that would turn the modal into a way of testing which
                 * addresses exist.
                 */
                request.setAttribute("attemptsRemaining", MAX_FAILED_ATTEMPTS - attempts);
                showInvalidCredentials(request, response);
            }
        } catch (SQLException e) {
            throw new ServletException("Login lookup/update failed", e);
        }
    }

    /**
     * Clears the lockout for the submitted email via
     * {@link CustomerDAO#unlockAccount(String)}, then redirects the browser
     * back to {@link #safeRedirectTarget(HttpServletRequest)} - the same
     * page the modal was opened on, same as a successful login. A
     * blank/missing email is silently ignored rather than treated as an
     * error.
     *
     * @param request the demo-reset request
     * @param response the response to redirect
     * @throws ServletException if the account reset fails
     * @throws IOException if the redirect fails
     */
    private void handleDemoReset(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String identifier = request.getParameter(PARAM_IDENTIFIER);
        try {
            if (identifier != null && !identifier.isBlank()) {
                customerDAO.unlockAccount(identifier);
            }
        } catch (SQLException e) {
            throw new ServletException("Account reset failed", e);
        }
        response.sendRedirect(request.getContextPath() + safeRedirectTarget(request));
    }

    /**
     * Stores the four session attributes from the Login contract's
     * "What the Session Remembers" (loggedIn, customer, customerId,
     * displayName), then redirects to wherever
     * {@link #safeRedirectTarget(HttpServletRequest)} says is safe.
     *
     * @param request the login request, used to obtain the session and redirect target
     * @param response the response to redirect
     * @param customer the customer who just logged in
     * @throws IOException if the redirect fails
     */
    private void logInAndRedirect(HttpServletRequest request, HttpServletResponse response, Customer customer)
            throws IOException {
        HttpSession session = request.getSession();
        session.setAttribute("loggedIn", Boolean.TRUE);
        session.setAttribute("customer", customer);
        session.setAttribute("customerId", customer.getCustomerId());
        session.setAttribute("displayName", customer.getDisplayName());

        response.sendRedirect(request.getContextPath() + safeRedirectTarget(request));
    }

    /**
     * Same-site-only guard from the Login contract's "Where the User
     * Lands After Login".
     *
     * @param request the login request
     * @return the submitted redirectTo value if it looks like a same-site
     *         relative path, otherwise {@link #DEFAULT_REDIRECT}
     */
    private String safeRedirectTarget(HttpServletRequest request) {
        String redirectTo = request.getParameter(PARAM_REDIRECT_TO);
        boolean looksSafe = redirectTo != null && !redirectTo.isBlank()
                && redirectTo.startsWith("/") && !redirectTo.startsWith("//")
                && !redirectTo.contains("://");
        return looksSafe ? redirectTo : DEFAULT_REDIRECT;
    }

    /**
     * Sets the generic "username or password" loginError message (the
     * one that never reveals which field was wrong) and forwards back
     * to the page the modal was opened on.
     *
     * @param request the request to attach the error message to
     * @param response the response to forward
     * @throws ServletException if the forward fails
     * @throws IOException if the forward fails
     */
    private void showInvalidCredentials(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("loginError", "The username or password you entered is incorrect.");
        forwardToOriginPage(request, response);
    }

    /**
     * Sets the account-locked loginError message plus the
     * accountLocked flag the modal checks to show the demo Unlock
     * Account button, then forwards back to the page the modal was
     * opened on.
     *
     * @param request the request to attach the error message and flag to
     * @param response the response to forward
     * @throws ServletException if the forward fails
     * @throws IOException if the forward fails
     */
    private void showAccountLocked(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("loginError", "This account has been locked after multiple failed login attempts.");
        request.setAttribute("accountLocked", Boolean.TRUE);
        forwardToOriginPage(request, response);
    }

    /**
     * Shared last step for both failure cases: forwards the request to
     * {@link #safeRedirectTarget(HttpServletRequest)} - the same page
     * the login modal was submitted from - so whatever attributes were
     * just set are available to it and the modal can re-open with the
     * error shown inline. There is no separate error page.
     *
     * @param request the request carrying the error attributes
     * @param response the response to forward
     * @throws ServletException if the forward fails
     * @throws IOException if the forward fails
     */
    private void forwardToOriginPage(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        RequestDispatcher dispatcher = request.getRequestDispatcher(safeRedirectTarget(request));
        dispatcher.forward(request, response);
    }
}
