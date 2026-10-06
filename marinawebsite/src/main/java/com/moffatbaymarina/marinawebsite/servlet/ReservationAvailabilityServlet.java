package com.moffatbaymarina.marinawebsite.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;

import com.moffatbaymarina.marinawebsite.dao.ReservationDAO;
import com.moffatbaymarina.marinawebsite.model.DockAvailability;
import com.moffatbaymarina.marinawebsite.util.DBConnection;
import com.moffatbaymarina.marinawebsite.util.Utils;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * The Book a Slip page's free-slip counts for one lease start date (issue
 * #324). {@code reservation.js} calls it when the customer picks a start
 * date, so a size that is full today but opens before that date shows as
 * bookable rather than sending them to the wait list.
 *
 * <p>{@code GET /reservation/availability?start=yyyy-MM-dd} returns the
 * same JSON the page is rendered with ({@link #docksJson}). Counts only, the
 * same figures the public Wait List page shows, so no sign-in is needed.
 * The counts are a courtesy: {@code ReservationServlet} checks the slip
 * again when the booking is sent.
 *
 * <p>A start date outside the bookable window (today to BR-26's 12 months)
 * gets a 400, the same window {@code ReservationServlet} enforces.
 *
 * Blue Team - Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
 * Primary Author/Owner - Robert Breutzmann
 */
@WebServlet("/reservation/availability")
public class ReservationAvailabilityServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final ReservationDAO reservationDAO = new ReservationDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        LocalDate today = LocalDate.now();
        LocalDate start = Utils.parseDate(request.getParameter("start"));

        if (start == null || start.isBefore(today)
                || start.isAfter(Utils.latestLeaseStartDate(today))) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        List<DockAvailability> docks;
        try (Connection conn = DBConnection.getConnection()) {
            docks = reservationDAO.findDockAvailability(conn, start);
        } catch (SQLException e) {
            throw new ServletException("Unable to load slip availability.", e);
        }

        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/json");
        response.getWriter().write(docksJson(docks));
    }

    /**
     * The docks as the JSON array {@code reservation.js} reads:
     * {@code [{"dockId":1,"dockNumber":"A","available":{"26":2,"40":0,"50":1}}, ...]}.
     *
     * @param docks every dock, with its counts
     * @return the JSON text
     */
    public static String docksJson(List<DockAvailability> docks) {
        StringBuilder json = new StringBuilder("[");

        for (int i = 0; i < docks.size(); i++) {
            DockAvailability dock = docks.get(i);
            if (i > 0) {
                json.append(',');
            }
            json.append("{\"dockId\":").append(dock.getDockId())
                .append(",\"dockNumber\":\"").append(Utils.jsonEscape(dock.getDockNumber()))
                .append("\",\"available\":{");

            boolean first = true;
            for (Map.Entry<String, Integer> size : dock.getAvailable().entrySet()) {
                if (!first) {
                    json.append(',');
                }
                first = false;
                json.append('"').append(size.getKey()).append("\":").append(size.getValue());
            }
            json.append("}}");
        }

        return json.append(']').toString();
    }
}
