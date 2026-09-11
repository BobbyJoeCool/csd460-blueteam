package com.moffatbaymarina.marinawebsite.servlet;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * Ends a signed-in session. The counterpart to {@code LoginServlet} -
 * see the Login contract's "What the Session Remembers", which says
 * logging out clears all four session attributes at once. Invalidating
 * the session does exactly that in one step, rather than removing them
 * one at a time and leaving the session itself (and its ID) alive.
 *
 * <p>POST only, deliberately. Logging out changes state, so it doesn't
 * belong on a link a browser might prefetch or a page might trigger by
 * loading an image; the header submits a small form instead.
 *
 * <p>Always lands on the landing page rather than wherever the user was.
 * "Back where you were" is right for logging in, but wrong here - the
 * page they were on may well be one that requires a session, and
 * returning to it logged out would just bounce them again.
 *
 * @author Miguel Fernandez
 * Blue Team - Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
 * Primary Author/Owner - Miguel Fernandez
 */
@WebServlet("/logout")
public class LogoutServlet extends HttpServlet {

    // The ?notice= keyword is read by js/statusPopup.js, which maps it to
    // wording and shows the shared status popup. Keyword, never the
    // message itself - see includes/statusPopup.jsp.
    private static final String AFTER_LOGOUT_REDIRECT = "/?notice=loggedOut";

    /**
     * Invalidates the current session, if there is one, then redirects to
     * the landing page. A request with no session is not an error - the
     * user ends up logged out either way, which is all they asked for.
     *
     * @param request the logout request
     * @param response the response to redirect
     * @throws ServletException if the request can't be handled
     * @throws IOException if the redirect fails
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate();
        }

        response.sendRedirect(request.getContextPath() + AFTER_LOGOUT_REDIRECT);
    }
}
