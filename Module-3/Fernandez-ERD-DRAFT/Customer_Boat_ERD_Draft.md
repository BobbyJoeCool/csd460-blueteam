# Blue Team

Author: Miguel Fernandez
Tables owned: `customer`, `boat`
Naming convention: camelCase

---

## customer

| Column | Type | Key | Description |
|---|---|---|---|
| customerId | INT | PK | Unique ID for each customer, auto increment |
| firstName | VARCHAR(50) | | Customer first name |
| lastName | VARCHAR(50) | | Customer last name |
| email | VARCHAR(100) | | Login and contact email, unique |
| passwordHash | VARCHAR(255) | | Hashed password for account login |
| phone | VARCHAR(20) | | Contact phone number |
| streetAddress | VARCHAR(100) | | Mailing street address |
| city | VARCHAR(50) | | Mailing city |
| state | CHAR(2) | | Two letter state code |
| zipCode | VARCHAR(10) | | Zip code, varchar to keep leading zeros and allow +4 |
| dateJoined | DATE | | Date the account was created |

---

## boat

| Column | Type | Key | Description |
|---|---|---|---|
| boatId | INT | PK | Unique ID for each boat |
| customerId | INT | FK -> customer.customerId | Owner of the boat |
| boatName | VARCHAR(50) | | Name of the vessel |
| registrationNumber | VARCHAR(20) | | State registration or documentation number |
| boatType | VARCHAR(30) | | Sailboat, powerboat, catamaran, etc |
| boatLength | DECIMAL(4,1) | | Length in feet, used to check slip fit |
| boatBeam | DECIMAL(4,1) | | Width in feet, used to check slip fit |
| boatYear | YEAR | | Model year |

---

## Relationships

- `customer` 1 to many `boat` — one customer can own more than one boat
- `boat` is referenced by the reservation table 

---


