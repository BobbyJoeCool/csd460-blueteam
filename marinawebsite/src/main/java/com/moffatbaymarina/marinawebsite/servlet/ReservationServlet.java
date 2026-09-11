package com.moffatbaymarina.marinawebsite.servlet;

import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.Connection;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.List;

import com.moffatbaymarina.marinawebsite.dao.BoatDAO;
import com.moffatbaymarina.marinawebsite.dao.ReservationDAO;
import com.moffatbaymarina.marinawebsite.model.Boat;
import com.moffatbaymarina.marinawebsite.model.DockAvailability;
import com.moffatbaymarina.marinawebsite.model.Reservation;
import com.moffatbaymarina.marinawebsite.util.DBConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * Loads the Reservation page and creates reservations.
 *
 * <p>{@code @MultipartConfig} is required here - {@code reservation.js}
 * posts the reservation form as a {@code FormData} body, which browsers
 * always send as {@code multipart/form-data}. Without this annotation,
 * {@code request.getParameter()} can't see any of that body, so every
 * submitted field would look blank.
 *
 * @author White, S.
 * Blue Team - Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
 * Primary Author/Owner - Sara White
 */
@WebServlet("/reservation")
@MultipartConfig
public class ReservationServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final String VIEW = "/reservation.jsp";
    private static final String SLIP_RATE = "SLIP_PER_FOOT_MONTHLY";
    private static final String ELECTRIC_RATE = "ELECTRIC_MONTHLY";

    private final BoatDAO boatDAO = new BoatDAO();
    private final ReservationDAO reservationDAO = new ReservationDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Integer customerId = signedInCustomerId(request);
        if (customerId == null) {
            request.getRequestDispatcher(VIEW).forward(request, response);
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            BigDecimal perFootRate = reservationDAO.getRate(conn, SLIP_RATE);
            BigDecimal electricRate = reservationDAO.getRate(conn, ELECTRIC_RATE);

            List<Boat> ownedBoats = boatDAO.findByCustomerId(conn, customerId);
            for (Boat boat : ownedBoats) {
                fillReservationValues(boat, perFootRate);
            }

            List<DockAvailability> docks = reservationDAO.findDockAvailability(conn);

            request.setAttribute("ownedBoats", ownedBoats);
            request.setAttribute("docks", docks);
            request.setAttribute("perFootCents", toCents(perFootRate));
            request.setAttribute("electricCents", toCents(electricRate));
            request.getRequestDispatcher(VIEW).forward(request, response);

        } catch (SQLException e) {
            throw new ServletException("Unable to load reservation data.", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/json");

        Integer customerId = signedInCustomerId(request);
        if (customerId == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            writeJson(response, "{\"ok\":false,\"error\":\"Please sign in to reserve a slip.\"}");
            return;
        }

        //Read the submitted form
         
        Integer boatId = parseInt(request.getParameter("boatId"));
        Integer dockId = parseInt(request.getParameter("dockId"));
        LocalDate startDate = parseDate(request.getParameter("checkInDate"));
        boolean electricalHookup = request.getParameter("wantsElectric") != null;

        /*
        * Retrieve logged-in customer's boats
        * then search that list for submitted boatId
        */
        if (boatId == null) {
            writeJson(response, "{\"ok\":false,\"boatError\":\"Select a boat for this reservation.\"}");
            return;
        }
        if (dockId == null) {
            writeJson(response, "{\"ok\":false,\"dockError\":\"Choose which dock you'd like to be on.\"}");
            return;
        }
        if (startDate == null || startDate.isBefore(LocalDate.now())) {
            writeJson(response, "{\"ok\":false,\"dateError\":\"Choose a check-in date of today or later.\"}");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);

            try {
                List<Boat> ownedBoats =
                        boatDAO.findByCustomerId(conn, customerId);

                Boat boat = null;

                for (Boat currentBoat : ownedBoats) {
                    if (currentBoat.getBoatId() == boatId) {
                        boat = currentBoat;
                        break;
                    }
                }

                if (boat == null) {
                    conn.rollback();
                    writeJson(response, "{\"ok\":false,\"boatError\":\"Select a boat for this reservation.\"}");
                    return;
                }

                if (boat.getHasActiveReservation()) {
                    conn.rollback();
                    writeJson(response, "{\"ok\":false,\"boatError\":\""
                            + jsonEscape(boat.getBoatName())
                            + " already has an active reservation.\"}");
                    return;
                }

                int slipSizeFt = slipSizeFor(boat.getBoatLength());

                if (slipSizeFt == 0) {
                    conn.rollback();
                    writeJson(response,
                            "{\"ok\":false,\"boatError\":\"We don't have a slip that fits a boat over 50 feet. Please call the marina at (360) 555-0142.\"}");
                    return;
                }

                Integer slipId = reservationDAO.findAvailableSlip(
                        conn, dockId, slipSizeFt);

                if (slipId == null) {
                    int marinaWide =
                            reservationDAO.countAvailableForSize(conn, slipSizeFt);

                    conn.rollback();

                    if (marinaWide == 0) {
                        writeJson(response,
                                "{\"ok\":false,\"sizeFull\":true,\"slipSizeFt\":"
                                        + slipSizeFt + "}");
                    } else {
                        writeJson(response,
                                "{\"ok\":false,\"sizeFull\":true,\"slipSizeFt\":"
                                        + slipSizeFt + ",\"dockId\":" + dockId + "}");
                    }

                    return;
                }

                BigDecimal perFootRate =
                        reservationDAO.getRate(conn, SLIP_RATE);

                BigDecimal electricRate =
                        reservationDAO.getRate(conn, ELECTRIC_RATE);

                BigDecimal monthlyRate =
                        boat.getBoatLength().multiply(perFootRate);

                if (electricalHookup) {
                    monthlyRate = monthlyRate.add(electricRate);
                }

                monthlyRate =
                        monthlyRate.setScale(2, RoundingMode.HALF_UP);

                Reservation reservation = new Reservation();

                reservation.setCustomerId(customerId);
                reservation.setBoatId(boatId);
                reservation.setSlipId(slipId);
                reservation.setStartDate(startDate);
                reservation.setMonthlyRate(monthlyRate);
                reservation.setReservationStatus("Active");
                reservation.setElectricalHookup(electricalHookup);

                String confirmation =
                        reservationDAO.insert(conn, reservation);

                conn.commit();

                writeJson(response,
                        "{\"ok\":true,\"confirmationNumber\":\""
                                + jsonEscape(confirmation) + "\"}");

            } catch (SQLException e) {
                conn.rollback();
                throw e;

            } finally {
                conn.setAutoCommit(true);
            }

        } catch (SQLException e) {
            throw new ServletException(
                    "Reservation could not be completed.", e);
        }
    }
    /**
     * Helper method determines if a login session exists.
     * If yes, checks for customerId and returns that ID.
     * If no session or customerId exists, returns null.
     */
    private Integer signedInCustomerId(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) {
            return null;
        }
        Object value = session.getAttribute("customerId");
        return value instanceof Integer id ? id : null;
    }

    private void fillReservationValues(Boat boat, BigDecimal perFootRate) {
        boat.setSlipSizeFt(slipSizeFor(boat.getBoatLength()));
        boat.setMonthlyCents(toCents(boat.getBoatLength().multiply(perFootRate)));
    }

    private int slipSizeFor(BigDecimal boatLength) {
        if (boatLength == null) {
            return 0;
        }
        if (boatLength.compareTo(new BigDecimal("26")) <= 0) {
            return 26;
        }
        if (boatLength.compareTo(new BigDecimal("40")) <= 0) {
            return 40;
        }
        if (boatLength.compareTo(new BigDecimal("50")) <= 0) {
            return 50;
        }
        return 0;
    }

    private int toCents(BigDecimal dollars) {
        return dollars.movePointRight(2)
                .setScale(0, RoundingMode.HALF_UP)
                .intValueExact();
    }

    private Integer parseInt(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        try {
            return Integer.valueOf(value);
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private LocalDate parseDate(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        try {
            return LocalDate.parse(value);
        } catch (DateTimeParseException e) {
            return null;
        }
    }

    private void writeJson(HttpServletResponse response, String json) throws IOException {
        response.getWriter().write(json);
    }

    private String jsonEscape(String value) {
        if (value == null) {
            return "";
        }
        return value.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\r", "\\r")
                .replace("\n", "\\n");
    }
}
