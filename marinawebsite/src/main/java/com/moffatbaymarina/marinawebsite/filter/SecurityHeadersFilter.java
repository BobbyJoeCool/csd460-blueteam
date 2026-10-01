package com.moffatbaymarina.marinawebsite.filter;

import java.io.IOException;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Sends the two security headers Tomcat's HttpHeaderSecurityFilter (in
 * {@code WEB-INF/web.xml}) doesn't cover.
 *
 * <p><b>Content-Security-Policy</b> - the browser's second line of defence
 * if a script injection ever slips past our escaping. Everything the site
 * uses (CSS, JS, images, fetch) comes from this site, so the policy only
 * allows that, and it blocks inline script outright: an injected
 * {@code <script>} or {@code onclick="..."} won't run. That means our own
 * markup can't use them either. Buttons wire up through data attributes
 * instead (e.g. {@code data-sign-in}, see loginModal.js), and page data a
 * script needs goes in a {@code <script type="application/json">} block,
 * which is data, not code, so the policy lets it through.
 * {@code frame-ancestors 'none'} is the modern form of X-Frame-Options:
 * DENY. {@code form-action} and {@code base-uri} aren't covered by
 * {@code default-src}, so they're named too.
 *
 * <p><b>Referrer-Policy</b> - when a visitor follows a link to another
 * site, that site is told only which site they came from, never the full
 * page address, which can carry a confirmation number.
 *
 * Blue Team - Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
 * Primary Author/Owner - Miguel Fernandez
 */
@WebFilter("/*")
public class SecurityHeadersFilter extends HttpFilter {

    private static final String CONTENT_SECURITY_POLICY =
            "default-src 'self'; "
            + "object-src 'none'; "
            + "base-uri 'self'; "
            + "form-action 'self'; "
            + "frame-ancestors 'none'";

    @Override
    protected void doFilter(HttpServletRequest request, HttpServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        response.setHeader("Content-Security-Policy", CONTENT_SECURITY_POLICY);
        response.setHeader("Referrer-Policy", "strict-origin-when-cross-origin");
        chain.doFilter(request, response);
    }
}
