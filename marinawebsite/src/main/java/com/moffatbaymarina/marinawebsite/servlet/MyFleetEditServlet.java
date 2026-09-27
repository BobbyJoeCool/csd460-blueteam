package com.moffatbaymarina.marinawebsite.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.LinkedHashMap;
import java.util.Locale;
import java.util.Map;

import com.moffatbaymarina.marinawebsite.dao.BoatDAO;
import com.moffatbaymarina.marinawebsite.model.Boat;
import com.moffatbaymarina.marinawebsite.model.Customer;
import com.moffatbaymarina.marinawebsite.util.BoatValidator;
import com.moffatbaymarina.marinawebsite.util.DBConnection;
import com.moffatbaymarina.marinawebsite.util.Utils;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * @author Carolina R.
 * Blue Team - Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
 * Primary Author/Owner - Carolina R.
 *
 * Handles updates to a boat that belongs to the signed-in customer. The servlet
 * verifies ownership, validates the submitted changes, and updates only the
 * editable boat fields.
 */


@WebServlet("/myFleet/edit")
public class MyFleetEditServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private final BoatDAO boatDAO = new BoatDAO();

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);

        // Only signed-in customers should be able to edit boats.
        if (session == null || !(session.getAttribute("customerId") instanceof Number)) {
            response.sendRedirect(request.getContextPath() + "/");
            return;
        }

        int customerId =
                ((Number) session.getAttribute("customerId")).intValue();

        Customer customer =
                (Customer) session.getAttribute("customer");

        String country = "US";

        if (customer != null && customer.getCountry() != null) {
            country = customer.getCountry().toUpperCase(Locale.ROOT);
        }

        Integer boatId =
                Utils.parseInt(request.getParameter("boatId"));

        // Stop the request if the boat ID is missing or invalid.
        if (boatId == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {

            Boat current =
                    boatDAO.findOwnedBoat(
                            conn,
                            customerId,
                            boatId
                    );

        // If the customer does not own this boat, return to My Fleet
            // and show an error instead of allowing the edit.
            if (current == null) {
                request.setAttribute(
                        "formError",
                        "That boat couldn't be found in your fleet."
                );

                request.setAttribute(
                        "fleet",
                        boatDAO.findFleetByCustomerId(conn, customerId)
                );

                request.getRequestDispatcher("/myFleet.jsp")
                        .forward(request, response);

                return;
            }

        // Boat length is locked after the boat is created.
            // Reject the request if someone tries to submit it during Edit.
            if (request.getParameter("boatLength") != null) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST);
                return;
            }

            // HIN can only be entered if the current boat does not already have one.
            // Once a HIN exists, it is treated as locked.
            if (current.getHIN() != null
                    && !current.getHIN().isBlank()
                    && request.getParameter("hin") != null) {

                response.sendError(HttpServletResponse.SC_BAD_REQUEST);
                return;
            }

            // Stores only the fields that were actually submitted by the Edit form.
            // LinkedHashMap keeps the submitted field order.
            Map<String, String> changed =
                    new LinkedHashMap<>();

            addIfPresent(request, changed, "boatName");
            addIfPresent(request, changed, "boatType");
            addIfPresent(request, changed, "boatBeam");
            addIfPresent(request, changed, "boatYear");
            addIfPresent(request, changed, "hin");
            addIfPresent(request, changed, "regNumber");

            //boat name required and can't be blank
            if (changed.containsKey("boatName")
                    && changed.get("boatName").isBlank()) {

                response.sendError(HttpServletResponse.SC_BAD_REQUEST);
                return;
            }

            if (changed.containsKey("hin")) {
                changed.put(
                        "hin",
                        changed.get("hin").toUpperCase(Locale.ROOT)
                );
            }

            // Standardizes registration numbers to uppercase.
            if (changed.containsKey("regNumber")) {
                changed.put(
                        "regNumber",
                        changed.get("regNumber").toUpperCase(Locale.ROOT)
                );
            }

        // If the customer did not change anything, return to My Fleet
            // without sending an unnecessary database update.
            if (changed.isEmpty()) {
                response.sendRedirect(
                        request.getContextPath() + "/myFleet"
                );
                return;
            }

            Map<String, String> errors =
                    BoatValidator.validateEdit(
                            conn,
                            boatDAO,
                            current,
                            changed,
                            country
                    );

            if (!errors.isEmpty()) {
                request.setAttribute("fieldErrors", errors);
                request.setAttribute(
                        "formError",
                        "Please fix the highlighted boat fields."
                );
                request.setAttribute("openForm", "edit");
                request.setAttribute("editBoatId", boatId);

                // Which fields this edit actually sent. An edit only posts
                // the fields that changed, so the rest aren't in the
                // request - the page must refill those from the boat on
                // file, not from the (absent) submitted values.
                request.setAttribute("postedFields", String.join(",", changed.keySet()));

                request.setAttribute(
                        "fleet",
                        boatDAO.findFleetByCustomerId(conn, customerId)
                );

                request.getRequestDispatcher("/myFleet.jsp")
                        .forward(request, response);

                return;
            }

            conn.setAutoCommit(false);

            try {
                boatDAO.updateBoat(conn, boatId, changed);
                conn.commit();

            } catch (SQLException e) {
                conn.rollback();
                throw e;

            } finally {
                conn.setAutoCommit(true);
            }

        } catch (SQLException e) {
            throw new ServletException(
                    "Boat could not be updated.",
                    e
            );
        }

        response.sendRedirect(
                request.getContextPath() + "/myFleet?notice=boatUpdated"
        );
    }

    private void addIfPresent(
            HttpServletRequest request,
            Map<String, String> changed,
            String field) {

        if (request.getParameterMap().containsKey(field)) {
            changed.put(
                    field,
                    Utils.clean(request.getParameter(field))
            );
        }
    }
}