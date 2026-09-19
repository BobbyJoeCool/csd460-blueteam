package com.moffatbaymarina.marinawebsite.servlet;

import com.moffatbaymarina.marinawebsite.model.Boat;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.Locale;

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
 * Blue Team - Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
 * Primary Author/Owner - Carolina Rodriguez
 */
@WebServlet("/register")
public class RegisterServlet extends HttpServlet {

	private static final long serialVersionUID = 1L;

    //Validation patterns for form fields

	/*
	 * Email/phone/country-code/zip/password patterns used to be defined
	 * here too - consolidated onto the single copy in Utils (used by
	 * every page that now touches Customer fields, not just Registration)
	 * as part of the Edit User Info build. See Utils' own comment on
	 * EMAIL_PATTERN for why. The HIN and Registration Number patterns and
	 * the boat length/beam/year limits followed later, for the same reason -
	 * this copy of the Registration Number pattern had drifted from the
	 * Reservation page's and the browser's (see Utils.REG_NUMBER_PATTERN).
	 */

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

		String firstName = Utils.clean(request.getParameter("firstName"));
		String lastName = Utils.clean(request.getParameter("lastName"));
		String email = Utils.clean(request.getParameter("email"))
				.toLowerCase(Locale.ROOT);

		String phoneCountryCode =
				Utils.clean(request.getParameter("phoneCountryCode"));
		String phone = Utils.clean(request.getParameter("phone"));

		String streetAddress =
				Utils.clean(request.getParameter("streetAddress"));
		String streetAddress2 =
				Utils.clean(request.getParameter("streetAddress2"));
		String city = Utils.clean(request.getParameter("city"));
		String state = Utils.clean(request.getParameter("state"))
				.toUpperCase(Locale.ROOT);
		String zipCode = Utils.clean(request.getParameter("zipCode"));
		String country = Utils.clean(request.getParameter("country"))
				.toUpperCase(Locale.ROOT);

		String boatName = Utils.clean(request.getParameter("boatName"));
		String regNumber = Utils.clean(request.getParameter("regNumber"))
				.toUpperCase(Locale.ROOT);
		String boatLengthText =
				Utils.clean(request.getParameter("boatLength"));
		String hin = Utils.clean(request.getParameter("hin"))
				.toUpperCase(Locale.ROOT);
		String boatType = Utils.clean(request.getParameter("boatType"));
		String boatBeamText =
				Utils.clean(request.getParameter("boatBeam"));
		String boatYearText =
				Utils.clean(request.getParameter("boatYear"));

		String password = Utils.orEmpty(request.getParameter("password"));
		String confirmPassword =
				Utils.orEmpty(request.getParameter("confirmPassword"));

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

		BigDecimal boatLength = Utils.parseDecimal(boatLengthText);
		BigDecimal boatBeam = Utils.parseDecimal(boatBeamText);
		Integer boatYear = Utils.parseInt(boatYearText);

		boolean boatEntered = anyPresent(
				boatName,
				regNumber,
				boatLengthText,
				hin,
				boatType,
				boatBeamText,
				boatYearText);

		if (boatEntered) {
			String boatError = validateBoat(
					boatName,
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
			customer.setStreetAddress2(Utils.emptyToNull(streetAddress2));
			customer.setCity(city);
			customer.setState(Utils.emptyToNull(state));
			customer.setZipCode(zipCode);
			customer.setCountry(country);

            saveRegistration(
                customer,
                passwordHash,
                boatEntered,
                boatName,
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

			String message = Utils.isDuplicateKey(exception)
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
                boat.setRegNumber(regNumber);
                boat.setBoatLength(boatLength);
                boat.setHIN(Utils.emptyToNull(hin));
                boat.setBoatType(Utils.emptyToNull(boatType));
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

		if (Utils.isBlank(firstName)
				|| Utils.isBlank(lastName)
				|| Utils.isBlank(email)
				|| Utils.isBlank(phoneCountryCode)
				|| Utils.isBlank(phone)
				|| Utils.isBlank(streetAddress)
				|| Utils.isBlank(city)
				|| Utils.isBlank(zipCode)
				|| Utils.isBlank(country)
				|| Utils.isBlank(password)
				|| Utils.isBlank(confirmPassword)) {

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
		if (!"OTHER".equals(country) && Utils.isBlank(state)) {
			return "Please complete all required fields.";
		}

		if (firstName.length() > 50 || lastName.length() > 50) {
			return "First and last names cannot exceed 50 characters.";
		}

		if (email.length() > 100
				|| !Utils.EMAIL_PATTERN.matcher(email).matches()) {
			return "Enter a valid email address.";
		}

		if (!Utils.COUNTRY_CODE_PATTERN.matcher(phoneCountryCode).matches()) {
			return "Enter a valid country code.";
		}

		if (!Utils.PHONE_PATTERN.matcher(phone).matches()) {
			return "Phone number must contain exactly 10 digits.";
		}

		if (streetAddress.length() > 100
				|| city.length() > 50
				|| (!Utils.isBlank(state) && state.length() != 2)) {
			return "Enter valid address information.";
		}

		if (!Utils.ZIP_PATTERN.matcher(zipCode).matches()) {
			return "Enter a valid ZIP code.";
		}

		if (!Utils.PASSWORD_PATTERN.matcher(password).matches()) {
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
			String regNumber,
			String boatLengthText,
			BigDecimal boatLength,
			String hin,
			String boatBeamText,
			BigDecimal boatBeam,
			String boatYearText,
			Integer boatYear,
			String country) {

        if (Utils.isBlank(boatName) || Utils.isBlank(boatLengthText)) {
            return "Boat Name and Boat Length are required when adding a boat.";
        }

        if (boatLength == null) {
            return "Boat Length must be a valid number.";
        }

        if (boatName.length() > 50 || !Utils.isValidBoatDimension(boatLength)) {
            return "Enter a boat length between 1 and 999.9 feet.";
        }

		if (!Utils.isBlank(boatBeamText) && !Utils.isValidBoatDimension(boatBeam)) {
			return "Boat Beam must be a valid number.";
		}

		if (!Utils.isBlank(boatYearText) && !Utils.isValidBoatYear(boatYear)) {
			return "Enter a valid four-digit boat year.";
		}

		/*
		 * HIN is the primary identifier and Registration Number is the
		 * fallback (Registration contract's "Boat Fields"), but as of
		 * this rework neither is ever required to submit - a boat with
		 * neither is still saved, and the front end shows a note directing
		 * the owner to call the Marina instead of blocking submission.
		 * Each one, if actually provided, still has to be well-formed.
		 */
		if (!Utils.isBlank(hin) && !Utils.isValidHin(hin)) {
			return "HIN should be 12 characters: 3 letters, then 9 more "
					+ "letters or numbers.";
		}

		/*
		 * Registration Number carries its own state/province prefix now -
		 * there's no separate Registration State field to pair it with.
		 */
		if (!Utils.isBlank(regNumber)) {
			if ("CA".equals(country) && !Utils.isValidRegNumber(regNumber, country)) {
				return "Enter a valid Canadian Registration Number, "
						+ "e.g. C1234 AB.";
			}

			if ("US".equals(country) && !Utils.isValidRegNumber(regNumber, country)) {
				return "Enter a valid Registration Number, including the "
						+ "state prefix, e.g. WN1234 AB.";
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
			if (!Utils.isBlank(value)) {
				return true;
			}
		}
		return false;
	}
}
