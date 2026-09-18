# Meeting Notes with the Client

## Logo & Visual Assets

- Avoid sailboat imagery in the logo, as it may alienate powerboat users (the anchor logo is preferred).
- Replace the placeholder image that looks like the Caribbean with imagery fitting the Pacific Northwest/island location. (On the "How to get here" page)

## Landing Page & Dock Info

- Remove any mention of vehicle parking in the "What is on the dock" section, as the marina is located on an island where guests arrive via boat or airstrip.  There are no motor vehicles.
- Standard harbormaster channels are typically VHF Channel 16 (though leaving 68 is acceptable).

## Reservations & Slip Rules

- Remove "nights" and fixed "departure" dates from reservation summaries; slip rentals are month-to-month (like a lease) requiring 30 days' notice to vacate.
- Ensure the wait-list flow is clear _***before***_ users attempt full checkout/booking.

## Form & Authentication Requirements

- Display explicit password criteria on the registration/login views to prevent user error. (eg: Must have 1 upper and lower case letter and 1 number and 1 special character)
- Decide on a backend password hashing technique (SHA-1 is good for Java, but there are plenty to choose from)
- Use regular expressions (regex) to validate email address formatting upon registration. (has an `x@x` and a `.xxx`)
- Store "Contact Us" form submissions directly into the database for admin review in addition to emailing them.
- Include clear visual login states (e.g., changing "Login" to user account info or "Welcome, `Name`").

## Code Documentation & Testing

- Include file headers in all source code files containing team member names, team name, and the finalization date (using GenAI to assist with code documentation/commenting is permitted, avoid when writing actual code for document).
- Build structured test plans mapping back to the original user stories. (this is a later module)
