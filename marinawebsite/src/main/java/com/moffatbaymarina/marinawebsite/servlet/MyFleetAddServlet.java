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
import com.moffatbaymarina.marinawebsite.util.CustomerSession;
import com.moffatbaymarina.marinawebsite.util.DBConnection;
import com.moffatbaymarina.marinawebsite.util.Utils;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

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

        // Only signed-in customers should be able to add boats. The
        // customer ID comes from the session, never from the submitted form.
        Integer customerId = Utils.signedInCustomerId(request);
        if (customerId == null) {
            CustomerSession.sendToSignIn(request, response, "/myFleet");
            return;
        }

        Customer customer =
                (Customer) request.getSession(false).getAttribute("customer");

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
                            country,
                            true,
                            customerId
                    );

        // If validation fails, send the user back to My Fleet
            // with the field errors and reopen the Add Boat form.
            if (!errors.isEmpty()) {
                request.setAttribute("fieldErrors", errors);
                request.setAttribute("openForm", "add");

                MyFleetServlet.showFleet(request, response, conn, customerId,
                        "Please fix the highlighted boat fields.");
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
                // Adds the boat and its ownership, reusing the boat's old row
                // if it's on file and nobody owns it now (a boat removed
                // earlier, or one bought from another customer).
                boatDAO.addOrReclaim(
                        conn,
                        boat,
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