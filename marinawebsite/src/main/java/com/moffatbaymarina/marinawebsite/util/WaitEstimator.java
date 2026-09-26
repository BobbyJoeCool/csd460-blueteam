package com.moffatbaymarina.marinawebsite.util;

import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.List;

/**
 * Works out how long someone in the wait list is likely to wait, and words
 * the answer for the page.
 *
 * <p><strong>No database access on purpose.</strong> The DAOs fetch the
 * inputs, the servlet hands them over, and this class does the arithmetic -
 * so the formula can be tested on its own, without a database, and lives in
 * exactly one place rather than being split between SQL and a JSP.
 *
 * <p>The idea: if there are <strong>N</strong> slips of your size and a
 * tenant keeps one for <strong>T</strong> months on average, roughly
 * <strong>N ÷ T</strong> of them come free each month. Reaching the front
 * from position <strong>P</strong> takes about P openings, so the wait is
 * <strong>P × T ÷ N</strong> months.
 *
 * <p>Some openings aren't guesses, though. A tenant who has filed a
 * termination notice is leaving on a known date, and BR-24 says a valid
 * notice must be counted when working out when a slip frees up. So those
 * dates are used first, and the average only covers whoever is left over:
 *
 * <pre>
 *   P &lt;= K   the wait ends on the P-th known opening date
 *   P &gt;  K   months until the last known opening + (P - K) x T / N
 * </pre>
 *
 * <p>Every label reads as an estimate. The marina is not promising anyone a
 * slip on a date.
 *
 * @author Miguel Fernandez
 * Blue Team - Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
 * Primary Author/Owner - Miguel Fernandez
 */
public final class WaitEstimator {

    /**
     * How long a slip tenancy is assumed to last when the database has no
     * finished ones to measure - which is every tenancy today, since nothing
     * has completed yet.
     *
     * <p>Proposed, not confirmed: the team (or the "marina") should agree
     * this number, since with no history it is what every estimate on the
     * page rests on. It is one constant precisely so that agreeing a
     * different figure is a one-line change.
     */
    public static final double DEFAULT_TENURE_MONTHS = 24.0;

    /** Average days in a month, for turning a gap between dates into months. */
    private static final double DAYS_PER_MONTH = 30.44;

    /** Past this, the page stops naming a figure and says "more than 2 years". */
    private static final double LONG_WAIT_MONTHS = 24.0;

    /** Shown when no slip of a size is in service, so nothing can turn over. */
    private static final String NO_ESTIMATE = "No estimate available right now.";

    private WaitEstimator() {
    }

    /**
     * One estimate: how long, whether it landed on a date the marina already
     * knows about, and the wording for the page.
     *
     * @param months how many months the wait is expected to run
     * @param openingDate the known opening this landed on, or {@code null}
     *        if the estimate came from the average rate instead
     * @param label the estimate worded for the page, ready to print
     */
    public record Estimate(double months, LocalDate openingDate, String label) {

        /**
         * @return {@code true} if this rests on a date the marina already
         *         knows, rather than on the average turnover rate
         */
        public boolean isKnownDate() {
            return openingDate != null;
        }
    }

    /**
     * Estimates the wait for one position in one slip size's line.
     *
     * @param position the place in line, counting from 1. For the public
     *        "if you joined today" figure, that is the number already in
     *        line plus one
     * @param knownOpenings dates slips of this size are already known to
     *        free up, soonest first (BR-24). May be empty; may be
     *        {@code null}, treated as empty
     * @param operationalSlips how many slips of this size are in service.
     *        Slips under maintenance or out of service don't turn over, so
     *        they aren't counted
     * @param avgTenureMonths how long a tenancy of this size lasts on
     *        average, in months
     * @param today the date to measure from
     * @return the estimate, never {@code null}
     */
    public static Estimate estimate(
            int position,
            List<LocalDate> knownOpenings,
            int operationalSlips,
            double avgTenureMonths,
            LocalDate today) {

        List<LocalDate> openings = knownOpenings == null ? List.of() : knownOpenings;
        int knownCount = openings.size();

        // Your wait ends on a date the marina already knows about.
        if (position >= 1 && position <= knownCount) {
            LocalDate opening = notBefore(openings.get(position - 1), today);
            return new Estimate(monthsBetween(today, opening), opening,
                    "around " + Utils.formatDisplayDate(opening));
        }

        /*
         * Past the known openings, so the rest of the line waits on the
         * average rate. With no slips in service nothing turns over and
         * there is no honest figure to give - which is different from a
         * long wait, and says so.
         */
        if (operationalSlips <= 0 || avgTenureMonths <= 0) {
            return new Estimate(0, null, NO_ESTIMATE);
        }

        double monthsToLastKnown = knownCount == 0
                ? 0
                : monthsBetween(today, notBefore(openings.get(knownCount - 1), today));

        double remaining = (double) (position - knownCount) * avgTenureMonths / operationalSlips;
        double months = monthsToLastKnown + remaining;

        return new Estimate(months, null, label(months));
    }

    /**
     * Words a number of months for the page, rounded <em>up</em> to the next
     * half month so the estimate is never rosier than the arithmetic.
     *
     * @param months the estimated wait in months
     * @return the wording, e.g. "about 3½ months"
     */
    private static String label(double months) {
        double rounded = Math.ceil(months * 2) / 2.0;

        if (rounded < 1) {
            return "less than a month";
        }
        if (rounded > LONG_WAIT_MONTHS) {
            return "more than 2 years";
        }

        int whole = (int) rounded;
        boolean half = rounded - whole >= 0.25;

        return "about " + whole + (half ? "\u00BD" : "")
                + (rounded == 1 ? " month" : " months");
    }

    /**
     * A known opening whose date has already passed counts as today - the
     * slip is free now, not in the past.
     */
    private static LocalDate notBefore(LocalDate date, LocalDate today) {
        return date == null || date.isBefore(today) ? today : date;
    }

    /**
     * The gap between two dates in months, as a fraction rather than whole
     * months, so short waits don't collapse to zero before they are worded.
     */
    private static double monthsBetween(LocalDate from, LocalDate to) {
        return ChronoUnit.DAYS.between(from, to) / DAYS_PER_MONTH;
    }
}
