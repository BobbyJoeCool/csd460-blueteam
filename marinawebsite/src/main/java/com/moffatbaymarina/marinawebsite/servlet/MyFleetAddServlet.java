package com.moffatbaymarina.marinawebsite.servlet;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.SQLException;
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
 * Handles adding a new boat to the signed-in customer's fleet. The servlet
 * validates the boat information, creates the Boat record, and creates the
 * matching BoatOwnership record for the customer.
 */

@WebServlet("/myFleet/add")
public class MyFleetAddServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private final BoatDAO boatDAO = new BoatDAO();

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);

        // Only signed-in customers should be able to add boats.
        // If there is no valid customerId in the session, return to the home page.
        if (session == null
                || !(session.getAttribute("customerId") instanceof Number)) {

            response.sendRedirect(request.getContextPath() + "/");
            return;
        }

        // Customer ID comes from the session instead of from the submitted form.
        int customerId =
                ((Number) session.getAttribute("customerId")).intValue();

        Customer customer =
                (Customer) session.getAttribute("customer");

        String country = "US";

        if (customer != null && customer.getCountry() != null) {
            country = customer.getCountry().toUpperCase(Locale.ROOT);
        }

        Map<String, String> values =
                BoatValidator.cleanBoatValues(request);

        try (Connection conn = DBConnection.getConnection()) {

            Map<String, String> errors =
                    BoatValidator.validateAdd(
                            conn,
                            boatDAO,
                            values,
                            country
                    );

        // If validation fails, send the user back to My Fleet
            // with the field errors and reopen the Add Boat form.
            if (!errors.isEmpty()) {
                request.setAttribute("fieldErrors", errors);
                request.setAttribute(
                        "formError",
                        "Please fix the highlighted boat fields."
                );
                request.setAttribute("openForm", "add");

                // Reloads the customer's fleet so the page still has
                // the data it needs when the request is forwarded.
                request.setAttribute(
                        "fleet",
                        boatDAO.findFleetByCustomerId(
                                conn,
                                customerId
                        )
                );

                request.getRequestDispatcher("/WEB-INF/views/myFleet.jsp")
                        .forward(request, response);

                return;
            }

            // Creates the Boat object after all submitted values pass validation.
            Boat boat = new Boat();

            boat.setBoatName(
                    values.get("boatName")
            );

            boat.setBoatType(
                    Utils.emptyToNull(
                            values.get("boatType")
                    )
            );

            boat.setBoatLength(
                    new BigDecimal(
                            values.get("boatLength")
                    )
            );

            boat.setBoatBeam(
                    Utils.parseDecimal(
                            values.get("boatBeam")
                    )
            );

            boat.setHIN(
                    Utils.emptyToNull(
                            values.get("hin")
                    )
            );

            boat.setRegNumber(
                    Utils.emptyToNull(
                            values.get("regNumber")
                    )
            );

            boat.setBoatYear(
                    Utils.parseInt(
                            values.get("boatYear")
                    )
            );

        // Both the Boat and BoatOwnership records must succeed together.
        // Auto-commit is turned off so these operations run as one transaction.
            conn.setAutoCommit(false);

            try {
                int boatId =
                        boatDAO.insertBoat(
                                conn,
                                boat
                        );

                boatDAO.insertOwnership(
                        conn,
                        boatId,
                        customerId
                );

                // Saves both database changes after both operations succeed.
                conn.commit();

            } catch (SQLException e) {
                conn.rollback();
                throw e;

            } finally {
                conn.setAutoCommit(true);
            }

        // Converts database errors into a servlet exception.
        } catch (SQLException e) {
            throw new ServletException(
                    "Boat could not be added.",
                    e
            );
        }

        // Redirects back to My Fleet and triggers the success notification
        response.sendRedirect(
                request.getContextPath()
                        + "/myFleet?notice=boatAdded"
        );
    }
}