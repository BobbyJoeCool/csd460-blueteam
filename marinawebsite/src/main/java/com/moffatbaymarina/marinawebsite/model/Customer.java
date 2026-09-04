package com.moffatbaymarina.marinawebsite.model;

import java.io.Serializable;
import java.time.LocalDate;

/**
 * Represents a customer record from the Customer database table,
 * excluding {@code passwordHash}. This class also includes the
 * login-attempt and account-lock fields used during authentication.
 *
 * Implements {@link Serializable} because customer objects may be stored
 * as session attributes. The password hash is deliberately never loaded
 * into this object, preventing it from being stored in the session or
 * displayed by a JSP. Password verification is handled by
 * {@code CustomerDAO.verifyPassword()}, which returns only a boolean.
 *
 * @author Robert Breutzmann
 * @implNote JavaDoc comments in this file were added with the assistance of Claude..
 */
public class Customer implements Serializable {

    private int customerId;
    private String firstName;
    private String lastName;
    private String email;
    private String phone;
    private String phoneCountryCode;
    private String streetAddress;
    private String streetAddress2;
    private String city;
    private String state;
    private String zipCode;
    private LocalDate dateJoined;
    private int failedLoginAttempts;
    private boolean accountLocked;

    /**
     * @return the customer's ID
     */
    public int getCustomerId() {
        return customerId;
    }

    /**
     * @param customerId the customer's ID
     */
    public void setCustomerId(int customerId) {
        this.customerId = customerId;
    }

    /**
     * @return the customer's first name
     */
    public String getFirstName() {
        return firstName;
    }

    /**
     * @param firstName the customer's first name
     */
    public void setFirstName(String firstName) {
        this.firstName = firstName;
    }

    /**
     * @return the customer's last name
     */
    public String getLastName() {
        return lastName;
    }

    /**
     * @param lastName the customer's last name
     */
    public void setLastName(String lastName) {
        this.lastName = lastName;
    }

    /**
     * @return the customer's email address, also used as the login identifier
     */
    public String getEmail() {
        return email;
    }

    /**
     * @param email the customer's email address
     */
    public void setEmail(String email) {
        this.email = email;
    }

    /**
     * @return the customer's phone number
     */
    public String getPhone() {
        return phone;
    }

    /**
     * @param phone the customer's phone number
     */
    public void setPhone(String phone) {
        this.phone = phone;
    }

    /**
     * @return the customer's phone dialing country code (e.g. "1" for US/Canada)
     */
    public String getPhoneCountryCode() {
        return phoneCountryCode;
    }

    /**
     * @param phoneCountryCode the customer's phone dialing country code
     */
    public void setPhoneCountryCode(String phoneCountryCode) {
        this.phoneCountryCode = phoneCountryCode;
    }

    /**
     * @return the customer's street address
     */
    public String getStreetAddress() {
        return streetAddress;
    }

    /**
     * @param streetAddress the customer's street address
     */
    public void setStreetAddress(String streetAddress) {
        this.streetAddress = streetAddress;
    }

    /**
     * @return the customer's optional second address line (apartment, suite, PO box)
     */
    public String getStreetAddress2() {
        return streetAddress2;
    }

    /**
     * @param streetAddress2 the customer's optional second address line
     */
    public void setStreetAddress2(String streetAddress2) {
        this.streetAddress2 = streetAddress2;
    }

    /**
     * @return the customer's city
     */
    public String getCity() {
        return city;
    }

    /**
     * @param city the customer's city
     */
    public void setCity(String city) {
        this.city = city;
    }

    /**
     * @return the customer's state
     */
    public String getState() {
        return state;
    }

    /**
     * @param state the customer's state
     */
    public void setState(String state) {
        this.state = state;
    }

    /**
     * @return the customer's ZIP code
     */
    public String getZipCode() {
        return zipCode;
    }

    /**
     * @param zipCode the customer's ZIP code
     */
    public void setZipCode(String zipCode) {
        this.zipCode = zipCode;
    }

    /**
     * @return the date the customer joined
     */
    public LocalDate getDateJoined() {
        return dateJoined;
    }

    /**
     * @param dateJoined the date the customer joined
     */
    public void setDateJoined(LocalDate dateJoined) {
        this.dateJoined = dateJoined;
    }

    /**
     * @return the current consecutive failed login attempt count
     */
    public int getFailedLoginAttempts() {
        return failedLoginAttempts;
    }

    /**
     * @param failedLoginAttempts the consecutive failed login attempt count
     */
    public void setFailedLoginAttempts(int failedLoginAttempts) {
        this.failedLoginAttempts = failedLoginAttempts;
    }

    /**
     * @return {@code true} if the account is locked out
     */
    public boolean isAccountLocked() {
        return accountLocked;
    }

    /**
     * @param accountLocked whether the account is locked out
     */
    public void setAccountLocked(boolean accountLocked) {
        this.accountLocked = accountLocked;
    }

    /**
     * First name + last initial, e.g. "Robert B." - see the Login contract's
     * Session Attributes section.
     *
     * @return the customer's display name
     */
    public String getDisplayName() {
        return firstName + " " + lastName.charAt(0) + ".";
    }
}
