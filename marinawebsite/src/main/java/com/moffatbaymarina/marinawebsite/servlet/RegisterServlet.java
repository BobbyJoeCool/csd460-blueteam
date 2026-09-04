package com.moffatbaymarina.marinawebsite.servlet;

import com.moffatbaymarina.marinawebsite.model.Boat;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.Locale;
import java.util.regex.Pattern;

import com.moffatbaymarina.marinawebsite.dao.BoatDAO;
import com.moffatbaymarina.marinawebsite.dao.CustomerDAO;
import com.moffatbaymarina.marinawebsite.model.Customer;
import com.moffatbaymarina.marinawebsite.util.DBConnection;
import com.moffatbaymarina.marinawebsite.util.Utils;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Handles customer and optional boat registration.
 * Ai assisted with JavaDoc comments in this file.
 * @author Carolina Rodriguez
 */
@WebServlet("/register")
public class RegisterServlet extends HttpServlet {

	private static final long serialVersionUID = 1L;

    //Validation patterns for form fields

	private static final Pattern EMAIL_PATTERN = Pattern.compile(
			"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$");

	private static final Pattern PHONE_PATTERN =
			Pattern.compile("^\\d{10}$");

	private static final Pattern COUNTRY_CODE_PATTERN =
			Pattern.compile("^[1-9]\\d{0,2}$");

	private static final Pattern ZIP_PATTERN =
			Pattern.compile("^\\d{5}(-\\d{4})?$");

	private static final Pattern PASSWORD_PATTERN = Pattern.compile(
			"^(?=.*[A-Z])(?=.*[a-z])(?=.*\\d)(?=.*[!$%*#]).{10,}$");

	private static final Pattern HIN_PATTERN =
			Pattern.compile("^[A-Za-z]{3}[A-Za-z0-9]{9}$");

	private static final Pattern REG_NUMBER_PATTERN =
			Pattern.compile("^\\d{4,7}\\s?[A-Za-z]{2}$");

	/*
	 * Canadian Pleasure Craft Licence numbers carry a literal leading "C"
	 * (the country code) that the US format has no equivalent for, plus a
	 * wider digit range - see the Registration contract's "Boat Fields"
	 * section for why US and Canadian registrations use different patterns.
	 */
	private static final Pattern CA_REG_NUMBER_PATTERN =
			Pattern.compile("^C\\d{4,8}\\s?[A-Za-z]{2}$");

	private static final java.util.Set<String> VALID_COUNTRIES =
			java.util.Set.of("US", "CA", "OTHER");

    //Data access objects for customer and boat operations----------------------------------------------------------

	private final CustomerDAO customerDAO = new CustomerDAO();
	private final BoatDAO boatDAO = new BoatDAO();

    //Display the registration page

	@Override
	protected void doGet(
			HttpServletRequest request,
			HttpServletResponse response)
			throws ServletException, IOException {

		request.getRequestDispatcher("/registration.jsp")
				.forward(request, response);
	}

    //Display submitted registration------------------------------------------------------------------------------
	@Override
	protected void doPost(
			HttpServletRequest request,
			HttpServletResponse response)
			throws ServletException, IOException {

		request.setCharacterEncoding("UTF-8");
		response.setCharacterEncoding("UTF-8");

		String firstName = clean(request.getParameter("firstName"));
		String lastName = clean(request.getParameter("lastName"));
		String email = clean(request.getParameter("email"))
				.toLowerCase(Locale.ROOT);

		String phoneCountryCode =
				clean(request.getParameter("phoneCountryCode"));
		String phone = clean(request.getParameter("phone"));

		String streetAddress =
				clean(request.getParameter("streetAddress"));
		String streetAddress2 =
				clean(request.getParameter("streetAddress2"));
		String city = clean(request.getParameter("city"));
		String state = clean(request.getParameter("state"))
				.toUpperCase(Locale.ROOT);
		String zipCode = clean(request.getParameter("zipCode"));
		String country = clean(request.getParameter("country"))
				.toUpperCase(Locale.ROOT);

		String boatName = clean(request.getParameter("boatName"));
		String regState = clean(request.getParameter("regState"))
				.toUpperCase(Locale.ROOT);
		String regNumber = clean(request.getParameter("regNumber"))
				.toUpperCase(Locale.ROOT);
		String boatLengthText =
				clean(request.getParameter("boatLength"));
		String hin = clean(request.getParameter("hin"))
				.toUpperCase(Locale.ROOT);
		String boatType = clean(request.getParameter("boatType"));
		String boatBeamText =
				clean(request.getParameter("boatBeam"));
		String boatYearText =
				clean(request.getParameter("boatYear"));

		String password = value(request.getParameter("password"));
		String confirmPassword =
				value(request.getParameter("confirmPassword"));

		String validationError = validateCustomer(
				firstName,
				lastName,
				email,
				phoneCountryCode,
				phone,
				streetAddress,
				city,
				state,
				zipCode,
				country,
				password,
				confirmPassword);

		if (validationError != null) {
			forwardWithError(
					request,
					response,
					"formError",
					validationError);
			return;
		}

		BigDecimal boatLength = parseDecimal(boatLengthText);
		BigDecimal boatBeam = parseDecimal(boatBeamText);
		Integer boatYear = parseInteger(boatYearText);

		boolean boatEntered = anyPresent(
				boatName,
				regState,
				regNumber,
				boatLengthText,
				hin,
				boatType,
				boatBeamText,
				boatYearText);

		if (boatEntered) {
			String boatError = validateBoat(
					boatName,
					regState,
					regNumber,
					boatLengthText,
					boatLength,
					hin,
					boatBeamText,
					boatBeam,
					boatYearText,
					boatYear,
					country);

			if (boatError != null) {
				forwardWithError(
						request,
						response,
						"formError",
						boatError);
				return;
			}
		}

		try {
			if (customerDAO.findByEmail(email) != null) {
				forwardWithError(
						request,
						response,
						"emailError",
						"An account with this email already exists.");
				return;
			}

			/*
			 * This method name must match the method already used by
			 * LoginServlet.
			 */
			String passwordHash = Utils.hashPassword(password);

			Customer customer = new Customer();
			customer.setFirstName(firstName);
			customer.setLastName(lastName);
			customer.setEmail(email);
			customer.setPhone(phone);
			customer.setPhoneCountryCode(phoneCountryCode);
			customer.setStreetAddress(streetAddress);
			customer.setStreetAddress2(emptyToNull(streetAddress2));
			customer.setCity(city);
			customer.setState(emptyToNull(state));
			customer.setZipCode(zipCode);
			customer.setCountry(country);

            saveRegistration(
                customer,
                passwordHash,
                boatEntered,
                boatName,
                regState,
                regNumber,
                boatLength,
                hin,
                boatType,
                boatBeam,
                boatYear);

            response.sendRedirect(
                    request.getContextPath() + "/?registered=true");

		} catch (SQLException exception) {
			getServletContext().log(
					"Customer registration failed.",
					exception);

			String message = isDuplicateKey(exception)
					? "That email or boat registration is already in use."
					: "Registration could not be completed. Please try again.";

			forwardWithError(
					request,
					response,
					"formError",
					message);

		} catch (RuntimeException exception) {
			getServletContext().log(
					"Password processing failed.",
					exception);

			forwardWithError(
					request,
					response,
					"formError",
					"Registration could not be completed.");
		}
	}

    //Database operation-------------------------------------------------------------------------------------------

	private void saveRegistration(
			Customer customer,
			String passwordHash,
			boolean boatEntered,
			String boatName,
			String regState,
			String regNumber,
			BigDecimal boatLength,
			String hin,
			String boatType,
			BigDecimal boatBeam,
			Integer boatYear) throws SQLException {

		try (Connection conn = DBConnection.getConnection()) {
			conn.setAutoCommit(false);

			try {
				int customerId =
		            customerDAO.insertCustomer(
                        conn, 
                        customer, 
                        passwordHash);

            if (boatEntered) {
                Boat boat = new Boat();
                boat.setBoatName(boatName);
                boat.setRegState(regState);
                boat.setRegNumber(regNumber);
                boat.setBoatLength(boatLength);
                boat.setHIN(emptyToNull(hin));
                boat.setBoatType(emptyToNull(boatType));
                boat.setBoatBeam(boatBeam);
                boat.setBoatYear(boatYear);

                int boatId = boatDAO.insertBoat(conn, boat);

                boatDAO.insertOwnership(
                    conn, 
                    boatId, 
                    customerId);
            }

            conn.commit();

			} catch (SQLException exception) {
				conn.rollback();
				throw exception;

			} finally {
				conn.setAutoCommit(true);
			}
		}
	}

    //Customer Validation-----------------------------------------------------------------------------------------

	private String validateCustomer(
			String firstName,
			String lastName,
			String email,
			String phoneCountryCode,
			String phone,
			String streetAddress,
			String city,
			String state,
			String zipCode,
			String country,
			String password,
			String confirmPassword) {

		if (isBlank(firstName)
				|| isBlank(lastName)
				|| isBlank(email)
				|| isBlank(phoneCountryCode)
				|| isBlank(phone)
				|| isBlank(streetAddress)
				|| isBlank(city)
				|| isBlank(zipCode)
				|| isBlank(country)
				|| isBlank(password)
				|| isBlank(confirmPassword)) {

			return "Please complete all required fields.";
		}

		if (!VALID_COUNTRIES.contains(country)) {
			return "Select a valid Country.";
		}

		// State/Province follows Country, the same way Registration
		// State/Province does for a boat (see validateBoat below): OTHER
		// has no state/province concept, so the field is disabled
		// client-side and not required here - see the Registration
		// contract's "Country" section.
		if (!"OTHER".equals(country) && isBlank(state)) {
			return "Please complete all required fields.";
		}

		if (firstName.length() > 50 || lastName.length() > 50) {
			return "First and last names cannot exceed 50 characters.";
		}

		if (email.length() > 100
				|| !EMAIL_PATTERN.matcher(email).matches()) {
			return "Enter a valid email address.";
		}

		if (!COUNTRY_CODE_PATTERN.matcher(phoneCountryCode).matches()) {
			return "Enter a valid country code.";
		}

		if (!PHONE_PATTERN.matcher(phone).matches()) {
			return "Phone number must contain exactly 10 digits.";
		}

		if (streetAddress.length() > 100
				|| city.length() > 50
				|| (!isBlank(state) && state.length() != 2)) {
			return "Enter valid address information.";
		}

		if (!ZIP_PATTERN.matcher(zipCode).matches()) {
			return "Enter a valid ZIP code.";
		}

		if (!PASSWORD_PATTERN.matcher(password).matches()) {
			return "Password does not meet the required rules.";
		}

		if (!password.equals(confirmPassword)) {
			return "Passwords do not match.";
		}

		return null;
	}

    //Boat Validation------------------------------------------------------------------------------------------------

	private String validateBoat(
			String boatName,
			String regState,
			String regNumber,
			String boatLengthText,
			BigDecimal boatLength,
			String hin,
			String boatBeamText,
			BigDecimal boatBeam,
			String boatYearText,
			Integer boatYear,
			String country) {

        if (isBlank(boatName) || isBlank(boatLengthText)) {
            return "Boat Name and Boat Length are required when adding a boat.";
        }

        if (boatLength == null) {
            return "Boat Length must be a valid number.";
        }

        if (boatName.length() > 50
                || boatLength.compareTo(BigDecimal.ZERO) <= 0
                || boatLength.compareTo(
                        new BigDecimal("999.9")) > 0) {

            return "Enter a boat length between 1 and 999.9 feet.";
        }

		if (!isBlank(boatBeamText)
				&& (boatBeam == null
				|| boatBeam.compareTo(BigDecimal.ZERO) <= 0
				|| boatBeam.compareTo(
						new BigDecimal("999.9")) > 0)) {

			return "Boat Beam must be a valid number.";
		}

		if (!isBlank(boatYearText)
				&& (boatYear == null
				|| boatYear < 1800
				|| boatYear > java.time.Year.now().getValue())) {

			return "Enter a valid four-digit boat year.";
		}

		/*
		 * HIN is the primary identifier and Registration State/Number is
		 * the fallback (Registration contract's "Boat Fields"), but as of
		 * this rework neither is ever required to submit - a boat with
		 * neither is still saved, and the front end shows a note directing
		 * the owner to call the Marina instead of blocking submission.
		 * Each one, if actually provided, still has to be well-formed.
		 */
		if (!isBlank(hin) && !HIN_PATTERN.matcher(hin).matches()) {
			return "HIN should be 12 characters: 3 letters, then 9 more "
					+ "letters or numbers.";
		}

		boolean regStateGiven = !isBlank(regState);
		boolean regNumberGiven = !isBlank(regNumber);

		if (regStateGiven != regNumberGiven) {
			return "Provide both Registration State/Province and Number, "
					+ "or leave both blank.";
		}

		if (regStateGiven) {
			if (regState.length() != 2) {
				return "Enter a valid two-letter Registration "
						+ "State/Province code.";
			}

			if ("CA".equals(country)
					&& !CA_REG_NUMBER_PATTERN.matcher(regNumber).matches()) {
				return "Enter a valid Canadian Registration Number, "
						+ "e.g. C1234 AB.";
			}

			if ("US".equals(country)
					&& !REG_NUMBER_PATTERN.matcher(regNumber).matches()) {
				return "Enter a valid Registration Number, e.g. 1234 AB.";
			}

			// OTHER has no defined Registration Number format - accepted
			// as entered, since the field is province/state-system
			// specific and Registration is disabled client-side for it.
		}

		return null;
	}

    //Error handling and utility methods--------------------------------------------------------------------------------

	private void forwardWithError(
			HttpServletRequest request,
			HttpServletResponse response,
			String attribute,
			String message)
			throws ServletException, IOException {

		request.setAttribute(attribute, message);
		request.getRequestDispatcher("/registration.jsp")
				.forward(request, response);
	}

    //Utility methods for string handling and validation-------------------------------------------------------------

	private boolean anyPresent(String... values) {
		for (String value : values) {
			if (!isBlank(value)) {
				return true;
			}
		}
		return false;
	}

	private BigDecimal parseDecimal(String value) {
		if (isBlank(value)) {
			return null;
		}

		try {
			return new BigDecimal(value);
		} catch (NumberFormatException exception) {
			return null;
		}
	}

	private Integer parseInteger(String value) {
		if (isBlank(value)) {
			return null;
		}

		try {
			return Integer.valueOf(value);
		} catch (NumberFormatException exception) {
			return null;
		}
	}

	private boolean isDuplicateKey(SQLException exception) {
		return exception.getErrorCode() == 1062
				|| (exception.getSQLState() != null
				&& exception.getSQLState().startsWith("23"));
	}

	private String clean(String value) {
		return value == null ? "" : value.trim();
	}

	private String value(String value) {
		return value == null ? "" : value;
	}

	private String emptyToNull(String value) {
		return isBlank(value) ? null : value;
	}

	private boolean isBlank(String value) {
		return value == null || value.isBlank();
	}
}
