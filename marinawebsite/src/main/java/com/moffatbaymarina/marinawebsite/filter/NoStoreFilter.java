package com.moffatbaymarina.marinawebsite.filter;

import java.io.IOException;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Tells the browser not to keep a copy of the pages that show a
 * customer's own details (reservations, boats, account, wait list place),
 * so after logging out on a shared computer the Back button can't bring
 * them back from cache.
 *
 * <p>Only these addresses, not the whole site: the shared CSS, JS and
 * images should still be cached. The other security headers
 * (X-Frame-Options, X-Content-Type-Options) come from Tomcat's
 * HttpHeaderSecurityFilter, declared in {@code WEB-INF/web.xml}.
 *
 * Blue Team - Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
 * Primary Author/Owner - Robert Breutzmann
 */
@WebFilter({
        "/reservation", "/reservation/*",
        "/reservations", "/reservations/*",
        "/reservationSummary",
        "/waitList",
        "/myFleet", "/myFleet/*",
        "/editProfile", "/editProfile/*"
})
public class NoStoreFilter extends HttpFilter {

    @Override
    protected void doFilter(HttpServletRequest request, HttpServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        response.setHeader("Cache-Control", "no-store");
        chain.doFilter(request, response);
    }
}
