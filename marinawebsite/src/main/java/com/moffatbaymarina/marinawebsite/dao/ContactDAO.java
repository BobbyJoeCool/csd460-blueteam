package com.moffatbaymarina.marinawebsite.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Types;

import com.moffatbaymarina.marinawebsite.model.Contact;

/**
 * Data access for contact-form submissions.
 *
 * @author White, S.
 * Blue Team - Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
 * Primary Author/Owner - Sara White
 * 
 * Handles database access for contact form submissions.
 *
 * This class receives a Contact object and inserts the submitted contact
 * information into the Contact table.
 */
 
public class ContactDAO {

    /**
     * Inserts one contact submission. Response-tracking columns keep their
     * database defaults until marina staff responds.
     *
     * @param conn active database connection
     * @param contact validated contact submission
     * @return generated contactID
     * @throws SQLException if the insert fails
     */
    public int insert(Connection conn, Contact contact) throws SQLException {
        String sql = """
                INSERT INTO Contact (
                    firstName,
                    lastName,
                    email,
                    boatName,
                    boatLength,
                    reasonForContact,
                    message
                )
                VALUES (?, ?, ?, ?, ?, ?, ?)
                """;

        try (PreparedStatement stmt = conn.prepareStatement(
                sql, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setString(1, contact.getFirstName());
            stmt.setString(2, contact.getLastName());
            stmt.setString(3, contact.getEmail());

            if (contact.getBoatName() == null) {
                stmt.setNull(4, Types.VARCHAR);
            } else {
                stmt.setString(4, contact.getBoatName());
            }

            if (contact.getBoatLength() == null) {
                stmt.setNull(5, Types.DECIMAL);
            } else {
                stmt.setBigDecimal(5, contact.getBoatLength());
            }

            stmt.setString(6, contact.getReasonForContact());
            stmt.setString(7, contact.getMessage());

            if (stmt.executeUpdate() != 1) {
                throw new SQLException("Contact submission did not insert one row.");
            }

            try (ResultSet keys = stmt.getGeneratedKeys()) {
                if (keys.next()) {
                    return keys.getInt(1);
                }
            }
            throw new SQLException("Contact submission did not return a contactID.");
        }
    }
}
