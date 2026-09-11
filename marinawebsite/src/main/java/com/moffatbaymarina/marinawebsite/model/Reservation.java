package com.moffatbaymarina.marinawebsite.model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDate;

/**
 * Matches the {@code Reservation} table one column to one field, including
 * {@code reservationStatus} (added in V1-4-0) and {@code electricalHookup}
 * (added in V1-6-0).
 *
 * <p>This is the write-side bean: what {@code ReservationDAO.insert} takes
 * when a booking is made. The Reservation Summary page needs the boat name,
 * dock letter and slip number as well, none of which live on this table, so
 * it reads {@link ReservationDetails} instead rather than making a JSP walk
 * three more beans to render one line.
 *
 * <p>Shared file, by agreement - the Reservation page (Sara, back end) writes
 * these rows and the Reservation Summary page (Miguel, back end) reads them,
 * and one bean means one idea of what a reservation is.
 *
 * @author Miguel Fernandez
 * @implNote JavaDoc comments in this file were added with the assistance of Claude.
 */
public class Reservation implements Serializable {

    private int reservationId;
    private String confirmationNumber;
    private int customerId;
    private int boatId;
    private int slipId;
    private LocalDate startDate;
    private BigDecimal monthlyRate;
    private String reservationStatus;
    private boolean electricalHookup;

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
     * @return the ID of the customer who made the reservation
     */
    public int getCustomerId() {
        return customerId;
    }

    /**
     * @param customerId the ID of the customer who made the reservation
     */
    public void setCustomerId(int customerId) {
        this.customerId = customerId;
    }

    /**
     * @return the ID of the boat the reservation is for
     */
    public int getBoatId() {
        return boatId;
    }

    /**
     * @param boatId the ID of the boat the reservation is for
     */
    public void setBoatId(int boatId) {
        this.boatId = boatId;
    }

    /**
     * @return the ID of the assigned slip
     */
    public int getSlipId() {
        return slipId;
    }

    /**
     * @param slipId the ID of the assigned slip
     */
    public void setSlipId(int slipId) {
        this.slipId = slipId;
    }

    /**
     * @return the date the lease starts
     */
    public LocalDate getStartDate() {
        return startDate;
    }

    /**
     * @param startDate the date the lease starts
     */
    public void setStartDate(LocalDate startDate) {
        this.startDate = startDate;
    }

    /**
     * The blended monthly total the customer was quoted, electric included
     * if they took it. Stored per reservation rather than recalculated, so a
     * later rate change never rewrites what an existing booking was sold at.
     *
     * @return the monthly rate in dollars
     */
    public BigDecimal getMonthlyRate() {
        return monthlyRate;
    }

    /**
     * @param monthlyRate the monthly rate in dollars
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
     * @return {@code true} if the reservation includes the electric hookup
     */
    public boolean isElectricalHookup() {
        return electricalHookup;
    }

    /**
     * @param electricalHookup whether the reservation includes electric
     */
    public void setElectricalHookup(boolean electricalHookup) {
        this.electricalHookup = electricalHookup;
    }
}
