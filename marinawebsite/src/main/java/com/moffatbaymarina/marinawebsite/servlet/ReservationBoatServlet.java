/** 
 * Blue Team - Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
 * Primary Author/Owner - Sara White
 * 
 * 
 * Handles adding a new boat from the Reservation page.
 *
 * The customer may need to register a boat before completing a reservation.
 * This servlet processes that boat information separately from the actual
 * reservation submission. After the boat is saved, it returns the new boat
 * information as JSON so the page can add it to the boat dropdown and the
 * customer can continue making the reservation.
 */

package com.moffatbaymarina.marinawebsite.servlet;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.Locale;

import com.moffatbaymarina.marinawebsite.dao.BoatDAO;
import com.moffatbaymarina.marinawebsite.dao.ReservationDAO;
import com.moffatbaymarina.marinawebsite.model.Boat;
import com.moffatbaymarina.marinawebsite.model.Customer;
import com.moffatbaymarina.marinawebsite.util.DBConnection;
import com.moffatbaymarina.marinawebsite.util.Utils;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * Saves a boat from the Reservation page's background panel.
 *
 * <p>{@code @MultipartConfig} is required here - {@code reservation.js}
 * posts this form as a {@code FormData} body, which browsers always send as
 * {@code multipart/form-data} even though nothing here is a file upload.
 * Without this annotation, {@code request.getParameter()} can't see any of
 * that body at all, so every field looks blank no matter what was typed.
 */
@WebServlet("/reservation/boat")
@MultipartConfig
public class ReservationBoatServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final BoatDAO boatDAO = new BoatDAO();
    private final ReservationDAO reservationDAO = new ReservationDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/json");

        Integer customerId = Utils.signedInCustomerId(request);
        if (customerId == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            writeError(response, "Please sign in before registering a boat.");
            return;
        }

        HttpSession session = request.getSession(false);
        Customer customer = session.getAttribute("customer") instanceof Customer c ? c : null;
        String country = customer == null || customer.getCountry() == null
                ? "US"
                : customer.getCountry().toUpperCase(Locale.ROOT);

        String boatName = Utils.clean(request.getParameter("boatName"));
        String regNumber = Utils.clean(request.getParameter("regNumber")).toUpperCase(Locale.ROOT);
        String boatLengthText = Utils.clean(request.getParameter("boatLength"));
        String hin = Utils.clean(request.getParameter("hin")).toUpperCase(Locale.ROOT);
        String boatType = Utils.clean(request.getParameter("boatType"));
        String boatBeamText = Utils.clean(request.getParameter("boatBeam"));
        String boatYearText = Utils.clean(request.getParameter("boatYear"));

        BigDecimal boatLength = Utils.parseDecimal(boatLengthText);
        BigDecimal boatBeam = Utils.parseDecimal(boatBeamText);
        Integer boatYear = Utils.parseInt(boatYearText);

        String error = validate(
                boatName, regNumber, boatLengthText, boatLength,
                hin, boatType, boatBeamText, boatBeam,
                boatYearText, boatYear, country);
        if (error != null) {
            writeError(response, error);
            return;
        }

        Boat boat = new Boat();
        boat.setBoatName(boatName);
        boat.setRegNumber(Utils.emptyToNull(regNumber));
        boat.setBoatLength(boatLength);
        boat.setHIN(Utils.emptyToNull(hin));
        boat.setBoatType(Utils.emptyToNull(boatType));
        boat.setBoatBeam(boatBeam);
        boat.setBoatYear(boatYear);

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                int boatId = boatDAO.insertBoat(conn, boat);
                boatDAO.insertOwnership(conn, boatId, customerId);
                BigDecimal perFootRate = reservationDAO.getRate(
                        conn, "SLIP_PER_FOOT_MONTHLY");
                conn.commit();

                int slipSizeFt = Utils.slipSizeFor(boatLength);
                int monthlyCents = Utils.toCents(boatLength.multiply(perFootRate));

                response.getWriter().write(
                        "{\"ok\":true,"
                        + "\"boatId\":" + boatId + ","
                        + "\"boatName\":\"" + Utils.jsonEscape(boatName) + "\","
                        + "\"boatLength\":\"" + boatLength.toPlainString() + "\","
                        + "\"slipSizeFt\":" + slipSizeFt + ","
                        + "\"monthlyCents\":" + monthlyCents
                        + "}");

            } catch (SQLException e) {
                conn.rollback();
                if (Utils.isDuplicateKey(e)) {
                    writeError(response, "That HIN or boat registration is already in use.");
                    return;
                }
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (SQLException e) {
            throw new ServletException("Boat could not be saved.", e);
        }
    }

    private String validate(
            String boatName,
            String regNumber,
            String boatLengthText,
            BigDecimal boatLength,
            String hin,
            String boatType,
            String boatBeamText,
            BigDecimal boatBeam,
            String boatYearText,
            Integer boatYear,
            String country) {

        if (boatName.isBlank() || boatLengthText.isBlank()) {
            return "Boat Name and Boat Length are required when adding a boat.";
        }
        if (boatName.length() > 50 || !Utils.isValidBoatDimension(boatLength)) {
            return "Enter a boat length between 1 and 999.9 feet.";
        }
        if (boatType.length() > 30) {
            return "Boat Type cannot exceed 30 characters.";
        }
        if (hin.isBlank() && regNumber.isBlank()) {
            return "Enter either a HIN or a Registration Number.";
        }
        if (!hin.isBlank() && !Utils.isValidHin(hin)) {
            return "HIN should be 12 characters: 3 letters, then 9 more letters or numbers.";
        }
        if (!regNumber.isBlank()) {
            if ("CA".equals(country) && !Utils.isValidRegNumber(regNumber, country)) {
                return "Enter a valid Canadian Registration Number, e.g. C1234 AB.";
            }
            if ("US".equals(country) && !Utils.isValidRegNumber(regNumber, country)) {
                return "Enter a valid Registration Number, including the state prefix, e.g. WN1234 AB.";
            }
        }
        if (!boatBeamText.isBlank() && !Utils.isValidBoatDimension(boatBeam)) {
            return "Boat Beam must be a valid number.";
        }
        if (!boatYearText.isBlank() && !Utils.isValidBoatYear(boatYear)) {
            return "Enter a valid four-digit boat year.";
        }
        return null;
    }

    private void writeError(HttpServletResponse response, String message) throws IOException {
        response.getWriter().write("{\"ok\":false,\"error\":\""
                + Utils.jsonEscape(message) + "\"}");
    }

}
