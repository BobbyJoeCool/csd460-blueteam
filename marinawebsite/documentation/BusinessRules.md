# Moffat Bay Marina Business Rules

### Business Rules Context
### BR-01 – BR-05: Customer Rules
### BR-06 – BR-09: Boat Rules
### BR-10 – BR-15: Dock and Slip Rules
### BR-16 – BR-18: Reservation Rules
### BR-19 – BR-20: Waitlist Rules
### BR-21 – BR-24: Termination Notice Rules
### BR-25: Status Rules
________________________________________


### Customer Rules
________________________________________

#### BR-01 — Customer Email Uniqueness
    Each customer must have a unique email address.

#### BR-02 — Customer Login Identity
    A customer's email address serves as the customer's login username.

#### BR-03 — Multiple Boat Ownership
    A customer may own more than one boat.

#### BR-04 — Boat Ownership History
    The marina must retain ownership history when a boat changes owners.

#### BR-05 — Historical Customer Relationships
    Changes in boat ownership must not alter the customer associated with historical reservations or other past records.


### Boat Rules
________________________________________

#### BR-06 — Boat Registration Identification
    A boat registration number is considered unique only when combined with its registration state.

#### BR-07 — Hull Identification Number
    A boat may have a unique Hull Identification Number (HIN).

#### BR-08 — Boats Without a HIN
    A qualifying older boat may be accepted without a HIN when other acceptable proof of ownership is available.

#### BR-09 — Boat-to-Slip Compatibility
    A boat may only be assigned to a slip that can accommodate the boat's required size.


### Dock and Slip Rules
________________________________________

#### BR-10 — Marina Dock Structure
    The marina has three docks identified as A, B, and C.

#### BR-11 — Slip Inventory
    Each dock contains 24 slips, for a total of 72 slips.

#### BR-12 — Slip Sizes
    Marina slips are available in 26-ft, 40-ft, and 50-ft sizes.

#### BR-13 — Slip Status Required
    Each slip must have a defined status that clearly identifies its current condition. 
    A slip status may not be null or undefined.
    Examples: Operational, Maintenance, OutOfService.

#### BR-14 — Slip Reservation Availability
    A slip's status does not determine whether the slip is reserved. 
    Refer to BR-18 Reservation availability for a specific date or 
    date range must be determined from the Reservation records.

#### BR-15 — Future Slip Availability
    A slip may be considered available for a future date only if there are no 
    conflicting reservations and the current occupant is scheduled to leave 
    before that date.


### Reservation Rules
________________________________________

#### BR-16 — Reservation Customer Association
    Every reservation must remain associated with the customer who originally made it, 
    even if ownership of the associated boat later changes.

#### BR-17 — Boat Reservation Association
    A reservation will be associated with the boat for which the reservation was made.

#### BR-18 — Reservation Availability
    Reservation records are the source used to determine whether a slip is 
    available for a requested date or date range. 
    Java will determine availability. 


### Waitlist Rules
________________________________________

#### BR-19 — Waitlist Eligibility 
    The waitlist keeps track of customers waiting for a slip. 
    Customers can join the waitlist before registering the boat they plan to use.

#### BR-20 — Waitlist Priority 
    Customers are prioritized based on when they joined the waitlist. 
    When a customer gets a slip, the waitlist entry is marked as completed so the marina 
    can track wait times. 
    Cancelled entries are not included when calculating the average wait time.


### Termination Notice Rules
________________________________________

#### BR-21 — Minimum Termination Notice
    A customer must provide at least 30 days' notice before the requested termination date.

#### BR-22 — Termination Notice Status
    Every termination notice must have a defined status that reflects its current state. 
    Example: Submitted, Pending, Withdrawn, Approved, Completed.

#### BR-23 — Termination Notice Withdrawal
    A customer can withdraw a termination notice before the termination process is completed.

#### BR-24 — Termination and Slip Availability
    A valid termination notice must be considered when determining when an occupied slip may become available. 
    A withdrawn termination notice must not cause the slip to be treated as becoming available.
    

### Status Rules
________________________________________

#### BR-25 — Status Values Must Be Defined and Consistent
    Any business record that uses a status must use a predefined set of valid status values. 
    If the same status term is used in multiple areas of the system, 
    it must have the same meaning everywhere it appears.
