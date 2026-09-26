package com.moffatbaymarina.marinawebsite.model;

import java.io.Serializable;
import java.time.LocalDateTime;

import com.moffatbaymarina.marinawebsite.util.Utils;

/**
 * One of the signed-in customer's own open wait list entries - their place
 * in line for a slip size, and when they joined.
 *
 * <p>Only ever built for the customer in session. Nothing on this bean is
 * shown about anybody else: {@link #getPeopleAhead()} is a count, not a
 * list, so the page can say where someone stands without naming who is
 * ahead of them.
 *
 * @author Miguel Fernandez
 * Blue Team - Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
 * Primary Author/Owner - Miguel Fernandez
 */
public class WaitListEntry implements Serializable {

    private int waitListId;
    private int sizeFt;
    private String status;
    private LocalDateTime timeJoined;
    private int peopleAhead;
    private String estimateLabel;

    /**
     * @return this entry's ID
     */
    public int getWaitListId() {
        return waitListId;
    }

    /**
     * @param waitListId this entry's ID
     */
    public void setWaitListId(int waitListId) {
        this.waitListId = waitListId;
    }

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
     * @return {@code Waiting} or {@code Offered} - a closed entry is never
     *         loaded onto this page
     */
    public String getStatus() {
        return status;
    }

    /**
     * @param status the entry's status
     */
    public void setStatus(String status) {
        this.status = status;
    }

    /**
     * @return {@code true} if a slip has been offered and not yet answered
     */
    public boolean isOffered() {
        return "Offered".equalsIgnoreCase(status);
    }

    /**
     * @return when the customer joined the wait list
     */
    public LocalDateTime getTimeJoined() {
        return timeJoined;
    }

    /**
     * @param timeJoined when the customer joined the wait list
     */
    public void setTimeJoined(LocalDateTime timeJoined) {
        this.timeJoined = timeJoined;
    }

    /**
     * The join date in the site-wide display format, e.g. "Jun 20, 2026".
     * JSTL's {@code <fmt:formatDate>} only reads a {@code java.util.Date}
     * and printing the {@code LocalDateTime} directly gives
     * "2026-06-20T11:30", so the page reads this instead - the same reason
     * {@link Customer#getDateJoinedDisplay()} and
     * {@link Boat#getActiveStartDateDisplay()} exist.
     *
     * @return the formatted join date, or "" if there isn't one
     */
    public String getTimeJoinedDisplay() {
        return timeJoined == null ? "" : Utils.formatDisplayDate(timeJoined.toLocalDate());
    }

    /**
     * How many in-line entries for this same slip size joined before this
     * one. Ties on {@code timeJoined} are broken by the lower
     * {@code waitListID}, so two customers can never be given the same
     * position.
     *
     * @return the number of customers ahead in the line
     */
    public int getPeopleAhead() {
        return peopleAhead;
    }

    /**
     * @param peopleAhead the number of customers ahead in the line
     */
    public void setPeopleAhead(int peopleAhead) {
        this.peopleAhead = peopleAhead;
    }

    /**
     * @return this customer's place in the line, counting from 1
     */
    public int getPosition() {
        return peopleAhead + 1;
    }

    /**
     * This customer's own estimated wait, worded for the page.
     *
     * @return the wait estimate, ready to print
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
}
