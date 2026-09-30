package com.moffatbaymarina.marinawebsite.util;

import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;

/**
 * Puts {@link MarinaInfo} in application scope as {@code marina} when the
 * site starts, so any JSP can read {@code ${marina.phone}} without its
 * servlet having to pass it along.
 *
 * @author Breutzmann, R. (Blue Team)
 * Blue Team - Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
 * Primary Author/Owner - Robert Breutzmann
 * @implNote Written with the assistance of Claude.
 */
@WebListener
public class MarinaInfoListener implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent event) {
        event.getServletContext().setAttribute("marina", MarinaInfo.forPages());
    }
}
