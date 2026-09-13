package com.moffatbaymarina.marinawebsite.util;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

/**
 * Connection settings (host, port, database name, user, password) come from
 * the {@code .env} file at the marinawebsite module root - read off the
 * classpath (see {@link #loadEnv()}), not the working directory, so it
 * resolves the same way regardless of how Tomcat gets launched - falling
 * back to real environment variables of the same name if neither is
 * present. The file is committed on purpose (see its own {@code .gitignore}
 * entry) - this is a class project with one shared MySQL name/user/password
 * for the whole team, so committing it means the site runs right after a
 * clone with no separate credential hand-off. Database name matches
 * databasescripts/MoffatBayMarinaDB_V1-0-0.sql.
 *
 * @author Robert Breutzmann
 * Blue Team - Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
 * Primary Author/Owner - Robert Breutzmann
 * @implNote JavaDoc comments in this file were added with the assistance of Claude.
 */
public final class DBConnection {

    /*
     * The JDBC spec says a driver on the classpath registers itself, but under
     * Tomcat that doesn't reliably happen for a driver sitting in the webapp's
     * WEB-INF/lib - DriverManager runs from the system classloader, which can't
     * see the webapp's jars, and the result is a confusing
     * "No suitable driver found for jdbc:mysql://..." at the first getConnection
     * call even though the jar is right there. Loading the class explicitly
     * forces registration in the webapp's own classloader.
     */
    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new IllegalStateException("MySQL driver not on the classpath", e);
        }
    }

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
     * Reads {@code .env} into a {@link Properties} instance, preferring the
     * copy on the classpath (see the {@code maven-resources-plugin} config
     * in {@code pom.xml}, which copies the module-root {@code .env} to
     * {@code WEB-INF/classes/.env}) and falling back to a plain file at
     * {@code .env} relative to the current working directory, for a Maven
     * run that hasn't rebuilt {@code target/classes} yet. Blank lines and
     * lines starting with {@code #} are skipped; finding neither yields an
     * empty (not null) set of properties, since {@link #env(String, String)}
     * falls back to real environment variables in that case.
     * <p>
     * The classpath copy exists because "current working directory" isn't
     * reliable: it's the module root when running via Maven, Tomcat's bin
     * directory in a typical deploy, and has been observed as the
     * filesystem root ({@code /}) when Tomcat is launched by the VS Code
     * Java extension - silently breaking every DB-touching feature at once
     * since {@link #env(String, String)} falls through to the placeholder
     * credentials below rather than failing loudly.
     *
     * @return the key/value pairs parsed from the {@code .env} file
     */
    private static Properties loadEnv() {
        Properties props = new Properties();

        try (InputStream stream = DBConnection.class.getClassLoader().getResourceAsStream(".env")) {
            if (stream != null) {
                parseEnv(new InputStreamReader(stream, StandardCharsets.UTF_8), props);
                return props;
            }
        } catch (IOException e) {
            throw new IllegalStateException("Failed to read .env from the classpath", e);
        }

        Path envPath = Path.of(".env");
        if (Files.isRegularFile(envPath)) {
            try (BufferedReader reader = Files.newBufferedReader(envPath)) {
                parseEnv(reader, props);
            } catch (IOException e) {
                throw new IllegalStateException("Failed to read .env file", e);
            }
        }
        return props;
    }

    /**
     * Parses {@code .env}-format lines ({@code KEY=value}, blank lines and
     * {@code #} comments skipped) from {@code reader} into {@code props}.
     *
     * @param reader source of {@code .env}-format lines; not closed here -
     *   the caller owns it, since it may be either a classpath stream or a
     *   file, opened in different try-with-resources blocks
     * @param props destination for each parsed {@code KEY=value} entry
     * @throws IOException if reading fails
     */
    private static void parseEnv(java.io.Reader reader, Properties props) throws IOException {
        try (BufferedReader buffered = new BufferedReader(reader)) {
            String rawLine;
            while ((rawLine = buffered.readLine()) != null) {
                String line = rawLine.strip();
                int separator = line.indexOf('=');
                boolean isEntry = !line.isEmpty() && !line.startsWith("#") && separator >= 0;
                if (isEntry) {
                    String key = line.substring(0, separator).strip();
                    String value = line.substring(separator + 1).strip();
                    props.setProperty(key, value);
                }
            }
        }
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