/**  
 *  Blue Team: Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
 * @author White, S. 
*/

package com.moffatbaymarina.marinawebsite.servlet;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Handles requests for the About Us page.
 *
 * This servlet forwards the customer to aboutUs.jsp. Contact form submissions
 * are handled separately by ContactServlet.
 */
@WebServlet("/about")
public class AboutServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        request.getRequestDispatcher("/aboutUs.jsp")
               .forward(request, response);
    }
}