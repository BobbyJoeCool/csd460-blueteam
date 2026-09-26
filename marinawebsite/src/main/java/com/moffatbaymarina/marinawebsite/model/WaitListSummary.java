package com.moffatbaymarina.marinawebsite.model;

import java.io.Serializable;

/**
 * One slip size's public wait list figures, as shown to anyone - signed in
 * or not - on the Wait List Lookup page. Counts only: no names, no join
 * dates, nothing that identifies who is in the line.
 *
 * <p>One of these exists for every slip size the marina has, even when
 * nobody is waiting on it, so the page's grid always renders three cards.
 *
 * <p>{@code estimateLabel} arrives ready to print, the same way
 * {@link ReservationDetails} works out its own money split rather than
 * leaving arithmetic to the JSP. It is {@code null} when
 * {@code availableNow} is true, since a size with open slips is offered
 * with a Book a Slip link instead of a wait.
 *
 * @author Miguel Fernandez
 * Blue Team - Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
 * Primary Author/Owner - Miguel Fernandez
 */
public class WaitListSummary implements Serializable {

    private int sizeFt;
    private int inLineCount;
    private boolean availableNow;
    private String estimateLabel;
    private String tenureSource;

    /**
     * @return the slip size category in feet - 26, 40 or 50
     */
    public int getSizeFt() {
        return sizeFt;
    }

    /**
     * @param sizeFt the slip size category in feet
     */
    public void setSizeFt(int sizeFt) {
        this.sizeFt = sizeFt;
    }

    /**
     * Everyone still in the line for this size: {@code Waiting} plus
     * {@code Offered}. An offered customer hasn't answered yet and is still
     * ahead of anyone behind them, so they count. {@code Fulfilled} and
     * {@code Cancelled} are closed and never do.
     *
     * @return how many customers are in line for this size
     */
    public int getInLineCount() {
        return inLineCount;
    }

    /**
     * @param inLineCount how many customers are in line for this size
     */
    public void setInLineCount(int inLineCount) {
        this.inLineCount = inLineCount;
    }

    /**
     * @return {@code true} if a slip of this size is free to book right now
     */
    public boolean isAvailableNow() {
        return availableNow;
    }

    /**
     * @param availableNow whether a slip of this size is free right now
     */
    public void setAvailableNow(boolean availableNow) {
        this.availableNow = availableNow;
    }

    /**
     * How long someone joining today would wait, worded for the page, e.g.
     * "about 3 months". Always reads as an estimate, never a promise.
     *
     * @return the wait estimate, or {@code null} when slips are available now
     */
    public String getEstimateLabel() {
        return estimateLabel;
    }

    /**
     * @param estimateLabel the wait estimate, ready to print
     */
    public void setEstimateLabel(String estimateLabel) {
        this.estimateLabel = estimateLabel;
    }

    /**
     * Which average tenancy the estimate rested on - {@code size} for this
     * slip size's own history, {@code marina} for the whole marina's, or
     * {@code default} for the fixed fallback. Lets the page footnote
     * "based on marina history" against "based on a typical tenancy" if
     * Front End wants to; nothing reads it today.
     *
     * @return the source of the average tenancy used
     */
    public String getTenureSource() {
        return tenureSource;
    }

    /**
     * @param tenureSource which average tenancy the estimate used
     */
    public void setTenureSource(String tenureSource) {
        this.tenureSource = tenureSource;
    }
}
