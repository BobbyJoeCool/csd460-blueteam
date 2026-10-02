package com.moffatbaymarina.marinawebsite.util;

import java.io.IOException;
import java.io.Serializable;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;

import com.moffatbaymarina.marinawebsite.model.Customer;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.HttpSessionActivationListener;
import jakarta.servlet.http.HttpSessionBindingEvent;
import jakarta.servlet.http.HttpSessionBindingListener;
import jakarta.servlet.http.HttpSessionEvent;

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

    /** Session attribute holding the {@link SignInRecord}. */
    private static final String SIGN_IN_RECORD = "signInRecord";

    /**
     * Every signed-in session, by customer, so {@link #endOtherSessions}
     * can find them. Only sessions are held, never passwords, and each
     * one leaves as soon as it ends.
     */
    private static final Map<Integer, Set<HttpSession>> SIGNED_IN = new ConcurrentHashMap<>();

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
        session.setAttribute(SIGN_IN_RECORD, new SignInRecord(customer.getCustomerId()));
    }

    /**
     * Signs the customer out everywhere except {@code keep}: called after a
     * password change or reset, so whoever was already signed in with the
     * old password (another browser, a shared computer) is put out on
     * their next click instead of staying in.
     *
     * @param customerId whose sessions to end
     * @param keep the session to leave signed in - the one that just
     *        changed the password; may be {@code null} (a reset from the
     *        signed-out Forgot Password popup keeps nothing)
     */
    public static void endOtherSessions(int customerId, HttpSession keep) {
        Set<HttpSession> sessions = SIGNED_IN.get(customerId);
        if (sessions == null) {
            return;
        }
        for (HttpSession session : sessions.toArray(new HttpSession[0])) {
            if (session.equals(keep)) {
                continue;
            }
            try {
                session.invalidate();
            } catch (IllegalStateException alreadyEnded) {
                // Timed out or signed out between the copy and here.
                sessions.remove(session);
            }
        }
    }

    /**
     * Keeps {@link #SIGNED_IN} up to date without any other code having to
     * remember to. Tomcat tells an attribute when it's added to or removed
     * from a session, and invalidating a session (sign out, time out,
     * signing in again) removes every attribute - so the record adds its
     * session on sign-in and takes it out when the session ends. Tomcat
     * also saves sessions to disk across a restart and loads them back,
     * which bypasses both; the activation callbacks cover that.
     */
    private static final class SignInRecord
            implements HttpSessionBindingListener, HttpSessionActivationListener, Serializable {

        private static final long serialVersionUID = 1L;

        private final int customerId;

        SignInRecord(int customerId) {
            this.customerId = customerId;
        }

        @Override
        public void valueBound(HttpSessionBindingEvent event) {
            add(event.getSession());
        }

        @Override
        public void valueUnbound(HttpSessionBindingEvent event) {
            remove(event.getSession());
        }

        @Override
        public void sessionDidActivate(HttpSessionEvent event) {
            add(event.getSession());
        }

        @Override
        public void sessionWillPassivate(HttpSessionEvent event) {
            remove(event.getSession());
        }

        private void add(HttpSession session) {
            SIGNED_IN.computeIfAbsent(customerId, id -> ConcurrentHashMap.newKeySet()).add(session);
        }

        private void remove(HttpSession session) {
            SIGNED_IN.computeIfPresent(customerId, (id, sessions) -> {
                sessions.remove(session);
                return sessions.isEmpty() ? null : sessions;
            });
        }
    }

    /**
     * Sends a signed-out visitor to the home page with the sign-in box
     * already open, remembering the page they wanted. Signing in - or
     * registering through the box's Register here link - then lands them
     * on {@code returnTo} (WEB-INF/includes/loginModal.jsp reads {@code signIn}).
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
