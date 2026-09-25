package com.moffatbaymarina.marinawebsite.model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.ZoneId;
import java.util.Date;
import java.util.Set;

import com.moffatbaymarina.marinawebsite.util.Utils;

/**
 * Everything the Reservation Summary page shows, in one flat object.
 *
 * <p>A reservation row on its own is mostly IDs - boatID, slipID - and the
 * page needs the names behind them: the boat's name and length, which dock,
 * which slip number, what size. Those live across four tables. Rather than
 * hand the JSP four beans and have it write
 * {@code ${reservation.slip.dock.dockNumber}}, the DAO joins them once and
 * fills in this.
 *
 * <p>Flat on purpose: every value is one property, so each line on the page
 * is one EL expression and nothing can be null two levels down.
 *
 * <p>The money is worth reading twice. {@link #getMonthlyRate()} is the
 * blended total the customer pays, which is what the reservation row stores.
 * {@link #getElectricRate()} and {@link #getSlipRent()} split that back out
 * so the page can itemise it, and they are worked out here rather than in
 * the JSP - the page should never do arithmetic it could get wrong.
 *
 * @author Miguel Fernandez
 * Blue Team - Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
 * Primary Author/Owner - Miguel Fernandez
 * @implNote JavaDoc comments in this file were added with the assistance of Claude.
 */
public class ReservationDetails implements Serializable {

    /* From Reservation */
    private int reservationId;
    private String confirmationNumber;
    private int customerId;
    private String guestName;
    /*
     * java.util.Date, not LocalDate. This bean exists only to be read by a
     * JSP, and JSTL's <fmt:formatDate> - which is what formats every date on
     * the page - only accepts java.util.Date. The DAO's rs.getDate() already
     * returns a java.sql.Date, which is one, so nothing is converted either
     * way. Reservation.java keeps LocalDate, since that one is read by code.
     */
    private Date startDate;
    private BigDecimal monthlyRate;
    private String reservationStatus;
    private boolean electricalHookup;

    /* From Boat */
    private String boatName;
    private String boatType;
    private BigDecimal boatLength;
    private String regNumber;

    /* From Slip, Dock and SlipSize */
    private String dockNumber;
    private String dockDescription;
    private int slipNumber;
    private int slipSizeFt;

    /* From Rate, only so the total can be itemised */
    private BigDecimal electricMonthlyRate;

    /* From TerminationNotice - all null when no notice was ever given */
    private String noticeStatus;
    private Date noticeDate;
    private Date terminationDate;

    /** Notice statuses that still count: the lease is on its way out. */
    private static final Set<String> OPEN_NOTICE_STATUSES =
            Set.of("Submitted", "Pending", "Approved");

    /**
     * The slip rent on its own, with the electric fee taken back off the
     * total, so the page can show an itemised receipt. Zero-safe: with no
     * hookup this is simply the whole monthly rate.
     *
     * @return the monthly slip rent, excluding electric
     */
    public BigDecimal getBaseMonthlyRate() {
        if (monthlyRate == null) {
            return null;
        }
        return electricalHookup && electricMonthlyRate != null
                ? monthlyRate.subtract(electricMonthlyRate)
                : monthlyRate;
    }

    /**
     * Convenience for the page, which shows a cancelled reservation
     * differently and hides the Cancel button on one.
     *
     * @return {@code true} if this reservation has been cancelled
     */
    public boolean isCancelled() {
        return "Cancelled".equalsIgnoreCase(reservationStatus);
    }

    /**
     * @return {@code true} if this reservation is still active
     */
    public boolean isActive() {
        return "Active".equalsIgnoreCase(reservationStatus);
    }

    /**
     * Whether the lease has begun: its start date is today or earlier. Once
     * it has, the reservation can't simply be cancelled - the customer gives
     * 30 days' notice instead (BR-21).
     *
     * @return {@code true} if the start date is on or before today
     */
    public boolean isStarted() {
        LocalDate start = toLocalDate(startDate);
        return start != null && !start.isAfter(LocalDate.now());
    }

    /**
     * Whether the customer may withdraw their termination notice and keep
     * the lease (BR-23): Active, a notice open, and today no later than
     * {@link Utils#NOTICE_WITHDRAWAL_CUTOFF_DAYS} days before its last day.
     * ReservationDAO.withdrawTerminationNotice() enforces the same thing in
     * its WHERE clause.
     *
     * @return {@code true} if the notice can be withdrawn
     */
    public boolean isNoticeWithdrawable() {
        return isActive() && isNoticeOpen()
                && Utils.isNoticeWithdrawable(toLocalDate(terminationDate), LocalDate.now());
    }

    /**
     * {@link Utils#NOTICE_WITHDRAWAL_CUTOFF_DAYS}, for pages that word the
     * rule ("until 14 days before your lease end date") so the number is
     * never typed into a JSP.
     *
     * @return how many days before the lease end date a notice can be withdrawn
     */
    public int getNoticeWithdrawalCutoffDays() {
        return Utils.NOTICE_WITHDRAWAL_CUTOFF_DAYS;
    }

    /**
     * The last day the open notice can be withdrawn, formatted for the page,
     * e.g. "Oct 16, 2026" - or "" when there is no notice or no last day.
     *
     * @return the formatted withdrawal deadline
     */
    public String getWithdrawDeadlineDisplay() {
        LocalDate lastDay = toLocalDate(terminationDate);
        return lastDay == null ? "" : Utils.formatDisplayDate(Utils.lastDayToWithdraw(lastDay));
    }

    /**
     * The fields are java.util.Date for JSTL's sake (see startDate), but the
     * rules compare LocalDates. The DAO fills them with java.sql.Date, which
     * converts directly.
     */
    private static LocalDate toLocalDate(Date date) {
        if (date == null) {
            return null;
        }
        return date instanceof java.sql.Date sqlDate
                ? sqlDate.toLocalDate()
                : date.toInstant().atZone(ZoneId.systemDefault()).toLocalDate();
    }

    /**
     * Whether a termination notice is in progress - submitted, under review
     * or approved. A withdrawn or completed one doesn't count.
     *
     * @return {@code true} if a notice is open on this reservation
     */
    public boolean isNoticeOpen() {
        return noticeStatus != null && OPEN_NOTICE_STATUSES.contains(noticeStatus);
    }

    /**
     * Whether the customer may cancel outright: Active, and not started yet.
     * My Reservations shows Cancel Reservation only when this is true, and
     * ReservationDAO.cancel() enforces the same thing in its WHERE clause.
     *
     * @return {@code true} if this reservation can be cancelled
     */
    public boolean isCancellable() {
        return isActive() && !isStarted();
    }

    /**
     * Whether the customer may give 30 days' notice: Active, started, and no
     * notice already open. ReservationDAO.submitTerminationNotice() enforces
     * the same thing inside its transaction.
     *
     * @return {@code true} if a termination notice can be submitted
     */
    public boolean isNoticeAllowed() {
        return isActive() && isStarted() && !isNoticeOpen();
    }

    /**
     * @return the termination notice's status, e.g. {@code Submitted}, or
     *         {@code null} if none was ever given
     */
    public String getNoticeStatus() {
        return noticeStatus;
    }

    /**
     * @param noticeStatus the termination notice's status
     */
    public void setNoticeStatus(String noticeStatus) {
        this.noticeStatus = noticeStatus;
    }

    /**
     * @return the day the termination notice was given, or {@code null}
     */
    public Date getNoticeDate() {
        return noticeDate;
    }

    /**
     * @param noticeDate the day the termination notice was given
     */
    public void setNoticeDate(Date noticeDate) {
        this.noticeDate = noticeDate;
    }

    /**
     * @return the lease's last day as given in the notice, or {@code null}
     */
    public Date getTerminationDate() {
        return terminationDate;
    }

    /**
     * @param terminationDate the lease's last day as given in the notice
     */
    public void setTerminationDate(Date terminationDate) {
        this.terminationDate = terminationDate;
    }

    /**
     * @return the reservation's ID
     */
    public int getReservationId() {
        return reservationId;
    }

    /**
     * @param reservationId the reservation's ID
     */
    public void setReservationId(int reservationId) {
        this.reservationId = reservationId;
    }

    /**
     * @return the customer-facing confirmation number, e.g. {@code MB-00061}
     */
    public String getConfirmationNumber() {
        return confirmationNumber;
    }

    /**
     * @param confirmationNumber the customer-facing confirmation number
     */
    public void setConfirmationNumber(String confirmationNumber) {
        this.confirmationNumber = confirmationNumber;
    }

    /**
     * Whose reservation this is. Read by the servlet's ownership check and
     * never displayed - confirmation numbers run in sequence, so the page
     * has to prove the reservation belongs to whoever is signed in.
     *
     * @return the owning customer's ID
     */
    public int getCustomerId() {
        return customerId;
    }

    /**
     * @param customerId the owning customer's ID
     */
    public void setCustomerId(int customerId) {
        this.customerId = customerId;
    }
    /**
     * @return the name of the customer who owns the reservation
     */
    public String getGuestName() {
        return guestName;
    }

    /**
     * @param guestName the customer's display name for the reservation
     */
    public void setGuestName(String guestName) {
        this.guestName = guestName;
    }

    /**
     * @return the date the lease starts
     */
    public Date getStartDate() {
        return startDate;
    }

    /**
     * @param startDate the date the lease starts
     */
    public void setStartDate(Date startDate) {
        this.startDate = startDate;
    }

    /**
     * @return the blended monthly total, electric included if taken
     */
    public BigDecimal getMonthlyRate() {
        return monthlyRate;
    }

    /**
     * @param monthlyRate the blended monthly total
     */
    public void setMonthlyRate(BigDecimal monthlyRate) {
        this.monthlyRate = monthlyRate;
    }

    /**
     * @return one of {@code Active}, {@code Cancelled} or {@code Completed}
     */
    public String getReservationStatus() {
        return reservationStatus;
    }

    /**
     * @param reservationStatus the reservation's status
     */
    public void setReservationStatus(String reservationStatus) {
        this.reservationStatus = reservationStatus;
    }

    /**
     * @return {@code true} if this reservation includes the electric hookup
     */
    public boolean isElectricalHookup() {
        return electricalHookup;
    }

    /**
     * @param electricalHookup whether this reservation includes electric
     */
    public void setElectricalHookup(boolean electricalHookup) {
        this.electricalHookup = electricalHookup;
    }

    /**
     * @return the boat's name
     */
    public String getBoatName() {
        return boatName;
    }

    /**
     * @param boatName the boat's name
     */
    public void setBoatName(String boatName) {
        this.boatName = boatName;
    }

    /**
     * @return the kind of boat - sailboat, powerboat and so on. May be
     *         {@code null}; it is optional at registration
     */
    public String getBoatType() {
        return boatType;
    }

    /**
     * @param boatType the kind of boat
     */
    public void setBoatType(String boatType) {
        this.boatType = boatType;
    }

    /**
     * @return the boat's length in feet
     */
    public BigDecimal getBoatLength() {
        return boatLength;
    }

    /**
     * @param boatLength the boat's length in feet
     */
    public void setBoatLength(BigDecimal boatLength) {
        this.boatLength = boatLength;
    }

    /**
     * @return the boat's registration number, or {@code null} if it has none
     */
    public String getRegNumber() {
        return regNumber;
    }

    /**
     * @param regNumber the boat's registration number
     */
    public void setRegNumber(String regNumber) {
        this.regNumber = regNumber;
    }

    /**
     * @return the dock letter, A to C
     */
    public String getDockNumber() {
        return dockNumber;
    }

    /**
     * @param dockNumber the dock letter
     */
    public void setDockNumber(String dockNumber) {
        this.dockNumber = dockNumber;
    }

    /**
     * @return where the dock sits in the marina, in customer-facing words
     */
    public String getDockDescription() {
        return dockDescription;
    }

    /**
     * @param dockDescription the dock's description
     */
    public void setDockDescription(String dockDescription) {
        this.dockDescription = dockDescription;
    }

    /**
     * @return the slip number within its dock
     */
    public int getSlipNumber() {
        return slipNumber;
    }

    /**
     * @param slipNumber the slip number within its dock
     */
    public void setSlipNumber(int slipNumber) {
        this.slipNumber = slipNumber;
    }

    /**
     * @return the slip's size category in feet - 26, 40 or 50
     */
    public int getSlipSizeFt() {
        return slipSizeFt;
    }

    /**
     * @param slipSizeFt the slip's size category in feet
     */
    public void setSlipSizeFt(int slipSizeFt) {
        this.slipSizeFt = slipSizeFt;
    }

    /**
     * The electric fee from the {@code Rate} table, used only to itemise the
     * total. Set whether or not this reservation took electric; whether it
     * counts is {@link #isElectricalHookup()}.
     *
     * @return the monthly electric fee
     */
    public BigDecimal getElectricMonthlyRate() {
        return electricMonthlyRate;
    }

    /**
     * @param electricMonthlyRate the monthly electric fee
     */
    public void setElectricMonthlyRate(BigDecimal electricMonthlyRate) {
        this.electricMonthlyRate = electricMonthlyRate;
    }
}
