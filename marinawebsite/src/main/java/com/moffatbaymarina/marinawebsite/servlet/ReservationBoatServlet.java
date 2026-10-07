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
import java.util.Map;

import com.moffatbaymarina.marinawebsite.dao.BoatDAO;
import com.moffatbaymarina.marinawebsite.dao.ReservationDAO;
import com.moffatbaymarina.marinawebsite.model.Boat;
import com.moffatbaymarina.marinawebsite.model.Customer;
import com.moffatbaymarina.marinawebsite.util.BoatValidator;
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

        Integer customerId = Utils.signedInCustomerId(request);
        if (customerId == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            Utils.writeJson(response, false, "error", "Please sign in before registering a boat.");
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

        // The shared rules every add-a-boat path uses. Book a Slip requires a
        // HIN or Registration Number, since this boat is about to be booked.
        Map<String, String> errors;
        try (Connection conn = DBConnection.getConnection()) {
            errors = BoatValidator.validateAdd(
                    conn, boatDAO, BoatValidator.cleanBoatValues(request), country, true, customerId);
        } catch (SQLException e) {
            throw new ServletException("Boat could not be checked.", e);
        }
        if (!errors.isEmpty()) {
            // The panel shows one message, so send the first, in form order.
            Utils.writeJson(response, false, "error", errors.values().iterator().next());
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
                // Reuses the boat's old row if it's on file and nobody owns it now.
                int boatId = boatDAO.addOrReclaim(conn, boat, customerId);
                BigDecimal perFootRate = reservationDAO.getRate(
                        conn, "SLIP_PER_FOOT_MONTHLY");
                conn.commit();

                int slipSizeFt = Utils.slipSizeFor(boatLength);
                int monthlyCents = Utils.toCents(boatLength.multiply(perFootRate));

                // boatLength travels as text ("30.50"), as reservation.js
                // has always read it.
                Utils.writeJson(response, true,
                        "boatId", boatId,
                        "boatName", boatName,
                        "boatLength", boatLength.toPlainString(),
                        "slipSizeFt", slipSizeFt,
                        "monthlyCents", monthlyCents);

            } catch (SQLException e) {
                conn.rollback();
                if (Utils.isDuplicateKey(e)) {
                    Utils.writeJson(response, false, "error", "That HIN or boat registration is already in use.");
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
}
