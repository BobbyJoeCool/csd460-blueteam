package com.moffatbaymarina.marinawebsite.util;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.regex.Pattern;

/**
 * Shared validation and hashing helpers used across the marina website.
 *
 * @author Breutzmann, R. (Blue Team)
 * @author White, S. (Blue Team)
 * @author Fernandez, M. (Blue Team)
 * @author Rodriguez, C. (Blue Team)
 * @implNote JavaDoc comments in this file were added with the assistance of Claude.
 */
public class Utils {

    // Requires local-part chars, "@", domain chars, a dot, then 2+ letter TLD.
    private static final Pattern EMAIL_PATTERN = Pattern.compile(
        "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
    );

    private Utils() {
    }

    /**
     * Checks whether a string is a plausible email address shape.
     *
     * @param email the address to check; may be {@code null}
     * @return {@code true} if non-null and it matches {@link #EMAIL_PATTERN}, {@code false} otherwise
     */
    public static boolean isValidEmail(String email) {
        return email != null && EMAIL_PATTERN.matcher(email).matches();
    }

    /**
     * Hashes a plaintext password with unsalted SHA-256, per the Login
     * contract's predecided hashing choice. Registration must call this
     * exact same method when a password is created, or a customer's
     * password will never match again on login - do not reimplement
     * this hash anywhere else.
     *
     * @param plainPassword the raw password to hash; never stored or logged
     * @return the SHA-256 digest as lowercase hex, matching MySQL's own
     *         {@code SHA2(x, 256)} output, in case a query ever needs to
     *         compare against it directly
     */
    public static String hashPassword(String plainPassword) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hashBytes = digest.digest(plainPassword.getBytes(StandardCharsets.UTF_8));
            StringBuilder hex = new StringBuilder(hashBytes.length * 2);
            for (byte b : hashBytes) {
                hex.append(String.format("%02x", b));
            }
            return hex.toString();
        } catch (NoSuchAlgorithmException e) {
            // Every JDK ships SHA-256, this is unreachable in practice.
            throw new IllegalStateException("SHA-256 algorithm not available", e);
        }
    }
}
