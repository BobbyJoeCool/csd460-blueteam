package com.moffatbaymarina.marinawebsite.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import com.moffatbaymarina.marinawebsite.dao.ReservationDAO;
import com.moffatbaymarina.marinawebsite.dao.WaitListDAO;
import com.moffatbaymarina.marinawebsite.model.WaitListEntry;
import com.moffatbaymarina.marinawebsite.model.WaitListSummary;
import com.moffatbaymarina.marinawebsite.util.DBConnection;
import com.moffatbaymarina.marinawebsite.util.Utils;
import com.moffatbaymarina.marinawebsite.util.WaitEstimator;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Backs the Wait List Lookup page - see
 * {@code documentation/Page Contracts/Wait List.md}.
 *
 * <p><strong>Public, unlike every other page that touches customer data.</strong>
 * Anyone can see how many people are in line for each slip size and roughly
 * how long joining today would mean waiting - that is a marina fact, not
 * anybody's private business, and someone deciding whether to keep a boat
 * here should be able to read it before they have an account. So a missing
 * session is not an error here and must not be made into one: it simply
 * means the second half of the page isn't built. Copying the sign-in guard
 * from {@code MyFleetServlet} or {@code LookUpReservationServlet} would
 * break exactly that.
 *
 * <p>What stays private is any detail about a particular person. The public
 * half is counts only - no names, no join dates, no customer IDs. The
 * personal half is filled from {@code sessionScope.customerId} alone, so
 * there is no parameter anyone could edit to read somebody else's place in
 * line.
 *
 * <p>One connection for the whole page. Building a view costs several
 * queries, and each DAO opening its own would mean several connections for
 * one page load.
 *
 * @author Miguel Fernandez
 * Blue Team - Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
 * Primary Author/Owner - Miguel Fernandez
 */
@WebServlet("/waitList")
public class WaitListServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final String VIEW = "/WEB-INF/views/waitListLookup.jsp";

    /**
     * Which average tenancy the estimate rested on, reported to the page so
     * it can footnote where the figure came from. Only {@code default} is
     * reachable today - measured history arrives with
     * {@code ReservationDAO.findTenureStats()}.
     */
    private static final String TENURE_SOURCE_DEFAULT = "default";

    private final WaitListDAO waitListDAO = new WaitListDAO();
    private final ReservationDAO reservationDAO = new ReservationDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // May be null. Signed out is a normal way to read this page.
        Integer customerId = Utils.signedInCustomerId(request);
        LocalDate today = LocalDate.now();

        try (Connection conn = DBConnection.getConnection()) {

            Map<Integer, Integer> inLine = waitListDAO.countInLineBySize(conn);
            Map<Integer, Integer> operationalSlips =
                    reservationDAO.countOperationalSlipsBySize(conn);
            // Slips whose tenants have given notice, by size (BR-24).
            Map<Integer, List<LocalDate>> openings =
                    reservationDAO.findUpcomingOpenings(conn, today);

            List<WaitListSummary> summaries =
                    buildSummaries(conn, inLine, operationalSlips, openings, today);
            request.setAttribute("waitListSummaries", summaries);

            if (customerId != null) {
                List<WaitListEntry> entries =
                        waitListDAO.findOpenEntriesForCustomer(conn, customerId);

                for (WaitListEntry entry : entries) {
                    entry.setEstimateLabel(estimateFor(
                            entry.getPosition(),
                            openings.getOrDefault(entry.getSizeFt(), List.of()),
                            operationalSlips.getOrDefault(entry.getSizeFt(), 0),
                            today));
                }

                /*
                 * Set even when empty - the page tells "you're not on the
                 * wait list" apart from "you're signed out" by whether this
                 * attribute is empty against whether there's a session.
                 */
                request.setAttribute("myWaitListEntries", entries);
            }

            request.getRequestDispatcher(VIEW).forward(request, response);

        } catch (SQLException e) {
            throw new ServletException("Unable to load the wait list.", e);
        }
    }

    /**
     * One summary per slip size, in the order the sizes come back from the
     * database - smallest first, so the page's three cards read 26, 40, 50.
     */
    private List<WaitListSummary> buildSummaries(
            Connection conn,
            Map<Integer, Integer> inLine,
            Map<Integer, Integer> operationalSlips,
            Map<Integer, List<LocalDate>> openings,
            LocalDate today) throws SQLException {

        List<WaitListSummary> summaries = new ArrayList<>();

        for (Map.Entry<Integer, Integer> size : inLine.entrySet()) {
            int sizeFt = size.getKey();
            int inLineCount = size.getValue();

            WaitListSummary summary = new WaitListSummary();
            summary.setSizeFt(sizeFt);
            summary.setInLineCount(inLineCount);

            /*
             * Free right now is a different question from how fast slips
             * turn over: this counts slips no lease holds today, while
             * the estimate's N counts every operational slip, occupied ones
             * included, because those are the ones that come free later.
             */
            boolean availableNow =
                    reservationDAO.countAvailableForSize(conn, sizeFt, today) > 0;
            summary.setAvailableNow(availableNow);

            if (!availableNow) {
                // Someone joining today would stand behind everyone in line.
                summary.setEstimateLabel(estimateFor(
                        inLineCount + 1,
                        openings.getOrDefault(sizeFt, List.of()),
                        operationalSlips.getOrDefault(sizeFt, 0),
                        today));
                summary.setTenureSource(TENURE_SOURCE_DEFAULT);
            }

            summaries.add(summary);
        }

        return summaries;
    }

    /**
     * Runs the estimator for one position.
     *
     * <p>Known openings come first: the P-th person in line gets the P-th
     * slip whose tenant has given notice (BR-24). Anyone past those waits
     * on the average turnover rate from the last known opening.
     */
    private String estimateFor(int position, List<LocalDate> knownOpenings,
            int operationalSlips, LocalDate today) {
        return WaitEstimator.estimate(
                position,
                knownOpenings,
                operationalSlips,
                WaitEstimator.DEFAULT_TENURE_MONTHS,
                today).label();
    }
}
