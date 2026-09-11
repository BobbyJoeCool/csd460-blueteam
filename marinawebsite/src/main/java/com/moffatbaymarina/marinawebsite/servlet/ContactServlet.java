package com.moffatbaymarina.marinawebsite.servlet;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.Set;

import com.moffatbaymarina.marinawebsite.dao.ContactDAO;
import com.moffatbaymarina.marinawebsite.model.Contact;
import com.moffatbaymarina.marinawebsite.util.DBConnection;
import com.moffatbaymarina.marinawebsite.util.Utils;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 *
 * @author White, S. 
 * Blue Team: Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
 * 
 * Handles contact form submissions from the About Us page.
 *
 * This servlet reads and validates the submitted form information, creates
 * a Contact object, and sends it to ContactDAO to be saved. It then forwards
 * the customer back to the About Us page with either a success or error message.
 */
 
@WebServlet("/contact")
public class ContactServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final String VIEW = "/aboutUs.jsp";
    private static final Set<String> VALID_REASONS = Set.of(
            "Reservation Question",
            "Waitlist Question",
            "Billing",
            "Maintenance Issue",
            "General Inquiry",
            "Other");

    private final ContactDAO contactDAO = new ContactDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.getRequestDispatcher(VIEW).forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String firstName = clean(request.getParameter("firstName"));
        String lastName = clean(request.getParameter("lastName"));
        String email = clean(request.getParameter("email"));
        String boatName = clean(request.getParameter("boatName"));
        String boatLengthText = clean(request.getParameter("boatLength"));
        String reasonForContact = clean(request.getParameter("reasonForContact"));
        String message = clean(request.getParameter("message"));

        BigDecimal boatLength = parseDecimal(boatLengthText);
        String validationError = validate(
                firstName,
                lastName,
                email,
                boatName,
                boatLengthText,
                boatLength,
                reasonForContact,
                message);

        if (validationError != null) {
            request.setAttribute("contactError", validationError);
            request.getRequestDispatcher(VIEW).forward(request, response);
            return;
        }

        Contact contact = new Contact();
        contact.setFirstName(firstName);
        contact.setLastName(lastName);
        contact.setEmail(email);
        contact.setBoatName(emptyToNull(boatName));
        contact.setBoatLength(boatLength);
        contact.setReasonForContact(reasonForContact);
        contact.setMessage(message);

        try (Connection conn = DBConnection.getConnection()) {
            contactDAO.insert(conn, contact);
            response.sendRedirect(request.getContextPath() + "/aboutUs.jsp?notice=contactSent");
        } catch (SQLException e) {
            throw new ServletException("Contact submission failed.", e);
        }
    }

    private String validate(
            String firstName,
            String lastName,
            String email,
            String boatName,
            String boatLengthText,
            BigDecimal boatLength,
            String reasonForContact,
            String message) {

        if (firstName.isBlank()) {
            return "Enter your first name.";
        }
        if (lastName.isBlank()) {
            return "Enter your last name.";
        }
        if (email.isBlank()) {
            return "Enter your email address.";
        }
        if (reasonForContact.isBlank()) {
            return "Choose a reason so we can route your message.";
        }
        if (message.isBlank()) {
            return "Enter your message.";
        }

        if (firstName.length() > 50 || lastName.length() > 50) {
            return "First and last names cannot exceed 50 characters.";
        }
        if (email.length() > 255 || !Utils.isValidEmail(email)) {
            return "Enter a valid email address.";
        }
        if (boatName.length() > 100) {
            return "Boat name cannot exceed 100 characters.";
        }
        if (!boatLengthText.isBlank()) {
            if (boatLength == null || boatLength.compareTo(BigDecimal.ZERO) <= 0) {
                return "Enter a length in feet, or leave this blank.";
            }
            if (boatLength.compareTo(new BigDecimal("9999.9")) > 0) {
                return "That length is longer than any boat we can moor.";
            }
        }
        if (!VALID_REASONS.contains(reasonForContact)) {
            return "Choose a valid reason for contacting us.";
        }
        if (message.length() > 2000) {
            return "Please keep your message under 2000 characters.";
        }

        return null;
    }

    private BigDecimal parseDecimal(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        try {
            return new BigDecimal(value);
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private String clean(String value) {
        return value == null ? "" : value.trim();
    }

    private String emptyToNull(String value) {
        return value == null || value.isBlank() ? null : value;
    }
}
