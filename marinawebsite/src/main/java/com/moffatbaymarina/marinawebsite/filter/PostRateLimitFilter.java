package com.moffatbaymarina.marinawebsite.filter;

import java.io.IOException;
import java.util.ArrayDeque;
import java.util.Deque;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Slows down a script hammering the forms anyone can submit without
 * signing in: guessing passwords across many accounts, mass-registering,
 * flooding the Contact table, or trying reset codes.
 *
 * <p>Each address gets {@value #MAX_POSTS} posts to each of these forms per
 * minute; past that the post is refused with 429 Too Many Requests, which
 * error.jsp words as "slow down, try again in a minute". No person filling
 * in a form gets near that.
 *
 * <p>Counted by IP address, not by session: a script can simply not send
 * its session cookie, and every post would look like a new visitor. Only
 * the posts that got through are counted, so a refused one doesn't push the
 * wait further out. Behind a proxy every visitor would share the proxy's
 * address, so Tomcat's RemoteIpValve would need setting up first.
 *
 * <p>Kept in memory: a restart clears the counts, which is fine for a
 * limit measured in a minute.
 *
 * Blue Team - Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
 * Primary Author/Owner - Miguel Fernandez
 */
@WebFilter({"/login", "/register", "/contact", "/forgotPassword"})
public class PostRateLimitFilter extends HttpFilter {

    static final int MAX_POSTS = 10;
    static final long WINDOW_MILLIS = 60_000;

    /** Accepted post times for each address and form, oldest first. */
    private final Map<String, Deque<Long>> recentPosts = new ConcurrentHashMap<>();

    private volatile long lastSweep;

    @Override
    protected void doFilter(HttpServletRequest request, HttpServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        if ("POST".equals(request.getMethod())) {
            String key = request.getRemoteAddr() + " " + request.getServletPath();
            if (!allow(key, System.currentTimeMillis())) {
                response.setHeader("Retry-After", String.valueOf(WINDOW_MILLIS / 1000));
                response.sendError(429);
                return;
            }
        }

        chain.doFilter(request, response);
    }

    /**
     * Records a post for {@code key} if it's under the limit.
     *
     * @param key who is posting, and to which form
     * @param now the current time, in milliseconds
     * @return {@code true} if the post may go ahead
     */
    boolean allow(String key, long now) {
        sweep(now);

        boolean[] allowed = {false};
        recentPosts.compute(key, (k, times) -> {
            Deque<Long> recent = times == null ? new ArrayDeque<>() : times;
            dropExpired(recent, now);
            if (recent.size() < MAX_POSTS) {
                recent.addLast(now);
                allowed[0] = true;
            }
            return recent;
        });
        return allowed[0];
    }

    /**
     * At most once a minute, forgets addresses that haven't posted in the
     * last minute, so the map doesn't grow with every visitor ever seen.
     */
    private void sweep(long now) {
        if (now - lastSweep < WINDOW_MILLIS) {
            return;
        }
        lastSweep = now;
        recentPosts.keySet().forEach(key -> recentPosts.computeIfPresent(key, (k, times) -> {
            dropExpired(times, now);
            return times.isEmpty() ? null : times;
        }));
    }

    private static void dropExpired(Deque<Long> times, long now) {
        while (!times.isEmpty() && now - times.peekFirst() >= WINDOW_MILLIS) {
            times.pollFirst();
        }
    }
}
