/** 
 * Blue Team - Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
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
import java.math.RoundingMode;
import java.sql.Connection;
import java.sql.SQLException;
import java.time.Year;
import java.util.Locale;
import java.util.regex.Pattern;

import com.moffatbaymarina.marinawebsite.dao.BoatDAO;
import com.moffatbaymarina.marinawebsite.dao.ReservationDAO;
import com.moffatbaymarina.marinawebsite.model.Boat;
import com.moffatbaymarina.marinawebsite.model.Customer;
import com.moffatbaymarina.marinawebsite.util.DBConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/** Saves a boat from the Reservation page's background panel. */
@WebServlet("/reservation/boat")
public class ReservationBoatServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final Pattern HIN_PATTERN =
            Pattern.compile("^[A-Za-z]{3}[A-Za-z0-9]{9}$");
    private static final Pattern REG_NUMBER_PATTERN =
            Pattern.compile("^[A-Za-z]{2}[- ]?\\d{4,7}[- ]?[A-Za-z]{2}$");
    private static final Pattern CA_REG_NUMBER_PATTERN =
            Pattern.compile("^C\\d{4,8}[- ]?[A-Za-z]{2}$");

    private final BoatDAO boatDAO = new BoatDAO();
    private final ReservationDAO reservationDAO = new ReservationDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/json");

        HttpSession session = request.getSession(false);
        Object idValue = session == null ? null : session.getAttribute("customerId");
        if (!(idValue instanceof Integer customerId)) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            writeError(response, "Please sign in before registering a boat.");
            return;
        }

        Customer customer = session.getAttribute("customer") instanceof Customer c ? c : null;
        String country = customer == null || customer.getCountry() == null
                ? "US"
                : customer.getCountry().toUpperCase(Locale.ROOT);

        String boatName = clean(request.getParameter("boatName"));
        String regNumber = clean(request.getParameter("regNumber")).toUpperCase(Locale.ROOT);
        String boatLengthText = clean(request.getParameter("boatLength"));
        String hin = clean(request.getParameter("hin")).toUpperCase(Locale.ROOT);
        String boatType = clean(request.getParameter("boatType"));
        String boatBeamText = clean(request.getParameter("boatBeam"));
        String boatYearText = clean(request.getParameter("boatYear"));

        BigDecimal boatLength = parseDecimal(boatLengthText);
        BigDecimal boatBeam = parseDecimal(boatBeamText);
        Integer boatYear = parseInteger(boatYearText);

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
        boat.setRegNumber(emptyToNull(regNumber));
        boat.setBoatLength(boatLength);
        boat.setHIN(emptyToNull(hin));
        boat.setBoatType(emptyToNull(boatType));
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

                int slipSizeFt = slipSizeFor(boatLength);
                int monthlyCents = toCents(boatLength.multiply(perFootRate));

                response.getWriter().write(
                        "{\"ok\":true,"
                        + "\"boatId\":" + boatId + ","
                        + "\"boatName\":\"" + jsonEscape(boatName) + "\","
                        + "\"boatLength\":\"" + boatLength.toPlainString() + "\","
                        + "\"slipSizeFt\":" + slipSizeFt + ","
                        + "\"monthlyCents\":" + monthlyCents
                        + "}");

            } catch (SQLException e) {
                conn.rollback();
                if (isDuplicateKey(e)) {
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
        if (boatName.length() > 50 || boatLength == null
                || boatLength.compareTo(BigDecimal.ZERO) <= 0
                || boatLength.compareTo(new BigDecimal("999.9")) > 0) {
            return "Enter a boat length between 1 and 999.9 feet.";
        }
        if (boatType.length() > 30) {
            return "Boat Type cannot exceed 30 characters.";
        }
        if (!hin.isBlank() && !HIN_PATTERN.matcher(hin).matches()) {
            return "HIN should be 12 characters: 3 letters, then 9 more letters or numbers.";
        }
        if (!regNumber.isBlank()) {
            if ("CA".equals(country) && !CA_REG_NUMBER_PATTERN.matcher(regNumber).matches()) {
                return "Enter a valid Canadian Registration Number, e.g. C1234 AB.";
            }
            if ("US".equals(country) && !REG_NUMBER_PATTERN.matcher(regNumber).matches()) {
                return "Enter a valid Registration Number, including the state prefix, e.g. WN1234 AB.";
            }
        }
        if (!boatBeamText.isBlank()
                && (boatBeam == null
                || boatBeam.compareTo(BigDecimal.ZERO) <= 0
                || boatBeam.compareTo(new BigDecimal("999.9")) > 0)) {
            return "Boat Beam must be a valid number.";
        }
        if (!boatYearText.isBlank()
                && (boatYear == null || boatYear < 1800 || boatYear > Year.now().getValue())) {
            return "Enter a valid four-digit boat year.";
        }
        return null;
    }

    private int slipSizeFor(BigDecimal length) {
        if (length.compareTo(new BigDecimal("26")) <= 0) return 26;
        if (length.compareTo(new BigDecimal("40")) <= 0) return 40;
        if (length.compareTo(new BigDecimal("50")) <= 0) return 50;
        return 0;
    }

    private int toCents(BigDecimal dollars) {
        return dollars.movePointRight(2)
                .setScale(0, RoundingMode.HALF_UP)
                .intValueExact();
    }

    private BigDecimal parseDecimal(String value) {
        if (value == null || value.isBlank()) return null;
        try { return new BigDecimal(value); }
        catch (NumberFormatException e) { return null; }
    }

    private Integer parseInteger(String value) {
        if (value == null || value.isBlank()) return null;
        try { return Integer.valueOf(value); }
        catch (NumberFormatException e) { return null; }
    }

    private boolean isDuplicateKey(SQLException e) {
        return e.getErrorCode() == 1062
                || (e.getSQLState() != null && e.getSQLState().startsWith("23"));
    }

    private String clean(String value) {
        return value == null ? "" : value.trim();
    }

    private String emptyToNull(String value) {
        return value == null || value.isBlank() ? null : value;
    }

    private void writeError(HttpServletResponse response, String message) throws IOException {
        response.getWriter().write("{\"ok\":false,\"error\":\""
                + jsonEscape(message) + "\"}");
    }

    private String jsonEscape(String value) {
        return value.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\r", "\\r")
                .replace("\n", "\\n");
    }
}
