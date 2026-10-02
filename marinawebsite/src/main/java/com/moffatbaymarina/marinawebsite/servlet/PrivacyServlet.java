/**
 * Blue Team - Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
 * Primary Author/Owner - Miguel Fernandez
 */

package com.moffatbaymarina.marinawebsite.servlet;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Handles requests for the Privacy Policy page (issue #335).
 *
 * <p>Forwards to privacy.jsp. The page is static apart from the marina's
 * contact details, which come from the {@code marina} application
 * attribute like everywhere else.
 */
@WebServlet("/privacy")
public class PrivacyServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        request.getRequestDispatcher("/WEB-INF/views/privacy.jsp")
               .forward(request, response);
    }
}
