package com.moffatbaymarina.marinawebsite.util;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

import com.moffatbaymarina.marinawebsite.model.Customer;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * The one place a customer's signed-in session is started, and the one way
 * a members-only page sends a signed-out visitor to sign in.
 *
 * <p>Signing in used to live only in {@code LoginServlet}. Registration now
 * signs the new customer in too, so both call {@link #start} rather than
 * keeping two copies of the session-fixation protection that could drift.
 *
 * @author Breutzmann, R. (Blue Team)
 * Blue Team - Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
 * Primary Author/Owner - Robert Breutzmann
 */
public final class CustomerSession {

    private CustomerSession() {
    }

    /**
     * Signs a customer in: stores the four session attributes from the
     * Login contract's "What the Session Remembers" ({@code loggedIn},
     * {@code customer}, {@code customerId}, {@code displayName}).
     *
     * <p>Invalidates any pre-existing session and starts a fresh one first,
     * per OWASP's Session Management Cheat Sheet guidance to regenerate the
     * session ID on authentication - otherwise a session ID an attacker
     * fixed before login (session fixation) would carry straight through
     * into an authenticated session. The fresh session also gets a fresh
     * CSRF token from {@code CsrfFilter} on the next page.
     *
     * @param request the request that signed the customer in
     * @param customer the customer, as loaded by {@code CustomerDAO.findByEmail}
     */
    public static void start(HttpServletRequest request, Customer customer) {
        HttpSession oldSession = request.getSession(false);
        if (oldSession != null) {
            oldSession.invalidate();
        }
        HttpSession session = request.getSession(true);
        session.setAttribute("loggedIn", Boolean.TRUE);
        session.setAttribute("customer", customer);
        session.setAttribute("customerId", customer.getCustomerId());
        session.setAttribute("displayName", customer.getDisplayName());
    }

    /**
     * Sends a signed-out visitor to the home page with the sign-in box
     * already open, remembering the page they wanted. Signing in - or
     * registering through the box's Register here link - then lands them
     * on {@code returnTo} (includes/loginModal.jsp reads {@code signIn}).
     *
     * <p>Used by pages with no signed-out view of their own (My Fleet and
     * User Profile, and their form actions, whose usual cause is a session
     * that timed out mid-edit). Before this they redirected home silently,
     * and the page the visitor wanted was forgotten.
     *
     * @param request the request that needed a signed-in customer
     * @param response the response to redirect
     * @param returnTo the page to come back to, as a fixed context-relative
     *        path chosen by the caller (e.g. {@code "/myFleet"}) - never
     *        something taken from the request
     * @throws IOException if the redirect fails
     */
    public static void sendToSignIn(
            HttpServletRequest request,
            HttpServletResponse response,
            String returnTo)
            throws IOException {
        response.sendRedirect(request.getContextPath() + "/?signIn="
                + URLEncoder.encode(returnTo, StandardCharsets.UTF_8));
    }
}
