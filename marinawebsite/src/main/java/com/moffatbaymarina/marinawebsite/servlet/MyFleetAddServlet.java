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

        if (session == null
                || !(session.getAttribute("customerId") instanceof Number)) {

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

            if (!errors.isEmpty()) {
                request.setAttribute("fieldErrors", errors);
                request.setAttribute(
                        "formError",
                        "Please fix the highlighted boat fields."
                );
                request.setAttribute("openForm", "add");

                request.setAttribute(
                        "fleet",
                        boatDAO.findFleetByCustomerId(
                                conn,
                                customerId
                        )
                );

                request.getRequestDispatcher("/myFleet.jsp")
                        .forward(request, response);

                return;
            }

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

                conn.commit();

            } catch (SQLException e) {
                conn.rollback();
                throw e;

            } finally {
                conn.setAutoCommit(true);
            }

        } catch (SQLException e) {
            throw new ServletException(
                    "Boat could not be added.",
                    e
            );
        }

        response.sendRedirect(
                request.getContextPath()
                        + "/myFleet?notice=boatAdded"
        );
    }
}