package com.moffatbaymarina.marinawebsite.model;

import java.math.BigDecimal;

/**
 * Represents a boat stored in the Boat database table.
 *
 * This model holds boat information only. Customer ownership is stored
 * separately in the BoatOwnership table.
 *
 * Ai assisted with JavaDoc comments in this file.
 * @author Carolina Rodriguez
 */
public class Boat {

    private int boatId;
    private String boatName;
    private String regState;
    private String regNumber;
    private BigDecimal boatLength;
    private String hin;
    private String boatType;
    private BigDecimal boatBeam;
    private Integer boatYear;

// Constructor-----------------------------------------------------------------------------------------------------
    public Boat() {
    }
 
//Getters and Setters------------------------------------------------------------------------------------------------
    public int getBoatId() {
        return boatId;
    }

    public void setBoatId(int boatId) {
        this.boatId = boatId;
    }

    public String getBoatName() {
        return boatName;
    }

    public void setBoatName(String boatName) {
        this.boatName = boatName;
    }

    public String getRegState() {
        return regState;
    }

    public void setRegState(String regState) {
        this.regState = regState;
    }

    public String getRegNumber() {
        return regNumber;
    }

    public void setRegNumber(String regNumber) {
        this.regNumber = regNumber;
    }

    public BigDecimal getBoatLength() {
        return boatLength;
    }

    public void setBoatLength(BigDecimal boatLength) {
        this.boatLength = boatLength;
    }

    public String getHIN() {
        return hin;
    }

    public void setHIN(String hin) {
        this.hin = hin;
    }

    public String getBoatType() {
        return boatType;
    }

    public void setBoatType(String boatType) {
        this.boatType = boatType;
    }

    public BigDecimal getBoatBeam() {
        return boatBeam;
    }

    public void setBoatBeam(BigDecimal boatBeam) {
        this.boatBeam = boatBeam;
    }

    public Integer getBoatYear() {
        return boatYear;
    }

    public void setBoatYear(Integer boatYear) {
        this.boatYear = boatYear;
    }
}