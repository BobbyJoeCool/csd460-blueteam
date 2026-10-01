package com.moffatbaymarina.marinawebsite.util;

import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;

/**
 * Puts {@code assetVersion} in application scope when the site starts. Every
 * stylesheet and script link adds it as {@code ?v=${applicationScope.assetVersion}}.
 *
 * Browsers keep their own copy of a .css or .js file and reuse it without
 * asking the server again, so after a deploy a returning visitor could run
 * new pages against old scripts - the sign-in popup stopped opening in a
 * Chrome that had the previous loginModal.js. A different ?v= is a different
 * address to the browser, so it fetches the new file.
 *
 * The value is the time the app started, so every deploy changes it and
 * nobody has to remember to bump a number by hand.
 *
 * @author Fernandez, M. (Blue Team)
 * Blue Team - Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
 * Primary Author/Owner - Miguel Fernandez
 * @implNote Written with the assistance of Claude.
 */
@WebListener
public class AssetVersionListener implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent event) {
        event.getServletContext().setAttribute("assetVersion",
                Long.toString(System.currentTimeMillis(), 36));
    }
}
