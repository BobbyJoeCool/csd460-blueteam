package com.moffatbaymarina.marinawebsite.filter;

import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;

import org.junit.Test;

/**
 * The counting behind PostRateLimitFilter: ten posts a minute for each
 * address and form, then refused until the oldest is a minute old.
 */
public class PostRateLimitFilterTest {

    private static final long START = 1_000_000L;

    @Test
    public void refusesThePostAfterTheLimit() {
        PostRateLimitFilter filter = new PostRateLimitFilter();
        for (int i = 0; i < PostRateLimitFilter.MAX_POSTS; i++) {
            assertTrue(filter.allow("1.2.3.4 /contact", START + i));
        }
        assertFalse(filter.allow("1.2.3.4 /contact", START + 100));
    }

    @Test
    public void allowsAgainOnceTheOldestPostIsAMinuteOld() {
        PostRateLimitFilter filter = new PostRateLimitFilter();
        for (int i = 0; i < PostRateLimitFilter.MAX_POSTS; i++) {
            filter.allow("1.2.3.4 /contact", START + i);
        }
        assertFalse(filter.allow("1.2.3.4 /contact", START + PostRateLimitFilter.WINDOW_MILLIS - 1));
        assertTrue(filter.allow("1.2.3.4 /contact", START + PostRateLimitFilter.WINDOW_MILLIS));
    }

    @Test
    public void countsEachAddressAndFormSeparately() {
        PostRateLimitFilter filter = new PostRateLimitFilter();
        for (int i = 0; i < PostRateLimitFilter.MAX_POSTS; i++) {
            filter.allow("1.2.3.4 /contact", START);
        }
        assertTrue(filter.allow("1.2.3.4 /login", START));
        assertTrue(filter.allow("5.6.7.8 /contact", START));
    }
}
