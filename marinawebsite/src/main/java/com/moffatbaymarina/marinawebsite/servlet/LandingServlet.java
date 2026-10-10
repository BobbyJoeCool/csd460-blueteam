/**
 * Blue Team - Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
 * Primary Author/Owner - Miguel Fernandez
 */

package com.moffatbaymarina.marinawebsite.servlet;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.SQLException;

import com.moffatbaymarina.marinawebsite.dao.ReservationDAO;
import com.moffatbaymarina.marinawebsite.util.DBConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Serves the landing page, with the slip and electric rates for its pricing
 * card (issue #349), so a visitor can see what a slip costs without signing
 * in.
 *
 * <p>The rates come from the {@code Rate} table, the same place
 * {@link ReservationServlet} reads them, so a price change made there shows
 * on both pages at once.
 *
 * <p>{@code ""} is the site root ({@code /marinawebsite/}), which is what the
 * header logo, the footer and the 404 page link to. {@code /index.jsp} keeps
 * the old address working now that the page lives under {@code WEB-INF}.
 */
@WebServlet({"", "/index.jsp"})
public class LandingServlet extends HttpServlet {

    private static final String VIEW = "/WEB-INF/views/index.jsp";
    private static final String SLIP_RATE = "SLIP_PER_FOOT_MONTHLY";
    private static final String ELECTRIC_RATE = "ELECTRIC_MONTHLY";

    private final ReservationDAO reservationDAO = new ReservationDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        /*
         * The home page is the front door, so a rate lookup that fails
         * doesn't take it down. The rates are simply left unset and the
         * page shows the card without figures, pointing to Book a Slip.
         */
        try (Connection conn = DBConnection.getConnection()) {
            BigDecimal perFootRate = reservationDAO.getRate(conn, SLIP_RATE);
            BigDecimal electricRate = reservationDAO.getRate(conn, ELECTRIC_RATE);

            request.setAttribute("perFootRate", perFootRate);
            request.setAttribute("electricRate", electricRate);
        } catch (SQLException e) {
            getServletContext().log("Landing page: couldn't load slip rates", e);
        }

        request.getRequestDispatcher(VIEW).forward(request, response);
    }
}
