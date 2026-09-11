package com.moffatbaymarina.marinawebsite.model;

import java.math.BigDecimal;

/**
 * Contact form submission stored in the Contact table.
 *
 * @author White, S.
 * Blue Team - Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
 * Primary Author/Owner - Sara White
 
 * Represents contact form information submitted from the About Us page.
 *
 * This model stores the information entered by the customer so it can be
 * passed from the servlet to the DAO and saved in the Contact table.
 */
public class Contact {

    private int contactId;
    private String firstName;
    private String lastName;
    private String email;
    private String boatName;
    private BigDecimal boatLength;
    private String reasonForContact;
    private String message;

    public int getContactId() {
        return contactId;
    }

    public void setContactId(int contactId) {
        this.contactId = contactId;
    }

    public String getFirstName() {
        return firstName;
    }

    public void setFirstName(String firstName) {
        this.firstName = firstName;
    }

    public String getLastName() {
        return lastName;
    }

    public void setLastName(String lastName) {
        this.lastName = lastName;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getBoatName() {
        return boatName;
    }

    public void setBoatName(String boatName) {
        this.boatName = boatName;
    }

    public BigDecimal getBoatLength() {
        return boatLength;
    }

    public void setBoatLength(BigDecimal boatLength) {
        this.boatLength = boatLength;
    }

    public String getReasonForContact() {
        return reasonForContact;
    }

    public void setReasonForContact(String reasonForContact) {
        this.reasonForContact = reasonForContact;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }
}
