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

            if (request.getParameter("boatLength") != null) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST);
                return;
            }

            if (current.getHIN() != null
                    && !current.getHIN().isBlank()
                    && request.getParameter("hin") != null) {

                response.sendError(HttpServletResponse.SC_BAD_REQUEST);
                return;
            }

            Map<String, String> changed =
                    new LinkedHashMap<>();

            addIfPresent(request, changed, "boatName");
            addIfPresent(request, changed, "boatType");
            addIfPresent(request, changed, "boatBeam");
            addIfPresent(request, changed, "boatYear");
            addIfPresent(request, changed, "hin");
            addIfPresent(request, changed, "regNumber");

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

            if (changed.containsKey("regNumber")) {
                changed.put(
                        "regNumber",
                        changed.get("regNumber").toUpperCase(Locale.ROOT)
                );
            }

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