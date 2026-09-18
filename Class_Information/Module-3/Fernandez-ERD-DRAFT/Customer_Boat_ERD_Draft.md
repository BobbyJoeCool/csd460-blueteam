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
| email | VARCHAR(100) | UNIQUE | Login username and contact email |
| passwordHash | VARCHAR(255) | | Hashed password, validation happens in Java before hashing |
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
| regState | CHAR(2) | UNIQUE (regState, regNumber) | State the boat is registered in |
| regNumber | VARCHAR(20) | UNIQUE (regState, regNumber) | State registration number |
| boatType | VARCHAR(30) | | Sailboat, powerboat, catamaran, etc |
| boatLength | DECIMAL(4,1) | | Length in feet, used to check slip fit |
| boatBeam | DECIMAL(4,1) | | Width in feet, used to check slip fit |
| boatYear | INT | | Model year |

---

## Relationships

- `customer` 1 to many `boat` — one customer can own more than one boat
- `boat` is referenced by the reservation table

---

## Notes

- `email` is the username per the project requirements, so it carries a UNIQUE constraint at the database level.
- The password rule (8+ characters, one uppercase, one lowercase) is enforced in Java with a regex before hashing. It cannot be a database constraint since the column only ever holds the hash.
- Registration numbers are unique within a state, not nationally, so `regState` and `regNumber` form a composite unique constraint rather than a unique on the number alone.
- `boatYear` is INT rather than MySQL's YEAR type for portability and easier mapping through JDBC.
- Mermaid has no syntax for composite keys, so in the .mmd diagram `regState` and `regNumber` each show a UK marker. That is a display limitation only. It is one constraint across the pair, not two separate unique keys.
