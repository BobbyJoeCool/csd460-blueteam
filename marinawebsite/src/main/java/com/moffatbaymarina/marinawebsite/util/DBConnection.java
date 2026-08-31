package com.moffatbaymarina.marinawebsite.util;

import java.io.BufferedReader;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

/**
 * Connection settings (host, port, database name, user, password) come from
 * the {@code .env} file at the marinawebsite module root (working directory
 * when running via Maven), falling back to real environment variables of the
 * same name if the file isn't present. The file is gitignored on purpose -
 * each teammate keeps their own local copy pointed at their own MySQL
 * instance rather than committing real credentials. Database name matches
 * databasescripts/MoffatBayMarinaDB_V1-0-0.sql.
 *
 * @author Robert Breutzmann
 * @implNote JavaDoc comments in this file were added with the assistance of Claude.
 */
public final class DBConnection {

    private static final Properties ENV = loadEnv();

    private static final String HOST = env("DB_HOST", "localhost");
    private static final String PORT = env("DB_PORT", "3306");
    private static final String NAME = env("DB_NAME", "MoffatBayMarinaDB");
    private static final String USER = env("DB_USER", "PLACEHOLDER_DB_USER");
    private static final String PASSWORD = env("DB_PASSWORD", "PLACEHOLDER_DB_PASSWORD");
    private static final String URL = "jdbc:mysql://" + HOST + ":" + PORT + "/" + NAME;

    private DBConnection() {
    }

    /**
     * Reads the {@code .env} file at {@code .env} (relative to the current
     * working directory) into a {@link Properties} instance. Blank lines and
     * lines starting with {@code #} are skipped; a missing file yields an
     * empty (not null) set of properties, since {@link #env(String, String)}
     * falls back to real environment variables in that case.
     *
     * @return the key/value pairs parsed from the {@code .env} file
     */
    private static Properties loadEnv() {
        Properties props = new Properties();
        Path envPath = Path.of(".env");
        if (Files.isRegularFile(envPath)) {
            try (BufferedReader reader = Files.newBufferedReader(envPath)) {
                String rawLine;
                while ((rawLine = reader.readLine()) != null) {
                    String line = rawLine.strip();
                    int separator = line.indexOf('=');
                    boolean isEntry = !line.isEmpty() && !line.startsWith("#") && separator >= 0;
                    if (isEntry) {
                        String key = line.substring(0, separator).strip();
                        String value = line.substring(separator + 1).strip();
                        props.setProperty(key, value);
                    }
                }
            } catch (IOException e) {
                throw new IllegalStateException("Failed to read .env file", e);
            }
        }
        return props;
    }

    /**
     * Resolves a connection setting, preferring the {@code .env} file, then
     * falling back to an actual environment variable of the same name, then
     * to {@code fallback}.
     *
     * @param key the {@code .env} / environment variable key
     * @param fallback the value to use if neither source defines {@code key}
     * @return the resolved value
     */
    private static String env(String key, String fallback) {
        String fromFile = ENV.getProperty(key);
        if (fromFile != null) {
            return fromFile;
        }
        String fromEnvironment = System.getenv(key);
        return fromEnvironment != null ? fromEnvironment : fallback;
    }

    /**
     * Opens a new connection to the marina database using the
     * configured {@link #URL}, {@link #USER}, and {@link #PASSWORD}.
     *
     * @return a new database connection
     * @throws SQLException if the connection can't be established
     */
    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }
}
