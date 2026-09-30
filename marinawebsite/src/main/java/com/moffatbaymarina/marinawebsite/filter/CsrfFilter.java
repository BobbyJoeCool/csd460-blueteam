package com.moffatbaymarina.marinawebsite.filter;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.util.Base64;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * Stops another website from submitting our forms for a signed-in
 * customer (cross-site request forgery): cancelling their reservations,
 * filing a 30-day notice or removing a boat without them clicking
 * anything on our site.
 *
 * <p>Two layers. {@code META-INF/context.xml} marks the session cookie
 * {@code SameSite=Lax}, so browsers don't send it on a POST that starts
 * on another site. This filter is the second layer, for browsers that
 * ignore SameSite: every session gets a random token, every POST form
 * carries it back ({@code includes/csrfField.jsp} for a form on the page,
 * the {@code X-CSRF-Token} header for a {@code fetch}), and a POST whose
 * token is missing or doesn't match is refused with a 403 before it
 * reaches any servlet. Another site can make a browser send a POST, but
 * it can't read our pages, so it can't know the token.
 *
 * <p>The token lives in the session as {@code csrfToken}. Pages read it
 * as {@code ${sessionScope.csrfToken}}; {@code includes/styles.jsp} also
 * puts it in a {@code <meta name="csrf-token">} tag for the scripts, via
 * {@code MoffatBay.form.csrfToken()}. Logging in starts a new session
 * (see {@code LoginServlet}), so it gets a fresh token on the next page.
 *
 * <p>A stale page is refused too: if the session timed out while the page
 * sat open, the new session's token won't match the old page's. error.jsp
 * words the 403 as "reload the page and try again".
 *
 * Blue Team - Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
 * Primary Author/Owner - Robert Breutzmann
 */
@WebFilter("/*")
public class CsrfFilter extends HttpFilter {

    /** Session attribute holding the token; also the form field's name. */
    public static final String TOKEN = "csrfToken";

    /** Header a script sends the token in, for fetch() POSTs. */
    private static final String HEADER = "X-CSRF-Token";

    private static final SecureRandom RANDOM = new SecureRandom();

    @Override
    protected void doFilter(HttpServletRequest request, HttpServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        if ("POST".equals(request.getMethod())) {
            if (!tokenMatches(request)) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }
        } else if (!isStaticFile(request)) {
            ensureToken(request.getSession());
        }

        chain.doFilter(request, response);
    }

    /**
     * Whether the POST carries the session's token. The header is checked
     * first: reservation.js posts multipart FormData, which a filter can't
     * read as parameters, so scripts always send the header.
     */
    private boolean tokenMatches(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        String expected = session == null ? null : (String) session.getAttribute(TOKEN);
        if (expected == null) {
            return false;
        }

        String sent = request.getHeader(HEADER);
        if (sent == null) {
            sent = request.getParameter(TOKEN);
        }
        if (sent == null) {
            return false;
        }

        return MessageDigest.isEqual(
                expected.getBytes(StandardCharsets.UTF_8),
                sent.getBytes(StandardCharsets.UTF_8));
    }

    private void ensureToken(HttpSession session) {
        if (session.getAttribute(TOKEN) == null) {
            byte[] bytes = new byte[32];
            RANDOM.nextBytes(bytes);
            session.setAttribute(TOKEN, Base64.getUrlEncoder().withoutPadding().encodeToString(bytes));
        }
    }

    /** CSS, JS and images never render a form, so they don't need a session. */
    private boolean isStaticFile(HttpServletRequest request) {
        String path = request.getServletPath();
        return path.startsWith("/css/") || path.startsWith("/js/") || path.startsWith("/images/");
    }
}
