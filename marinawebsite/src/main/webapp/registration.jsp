<%--
    Front End:   Robert Breutzmann
    Back End:    Carolina Rodriguez
    Course:      CSD 460 - Capstone Project
    Module:      Module 5 / Week 4 - Web Development 1
    Page:        Registration Page (registration.jsp)
    Contract:    DevNotes/Contracts/registration-page-contract.md
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page isELIgnored="false" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Create an Account - Moffat Bay Marina</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/variables.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/registration.css">
</head>
<body>

<%--
<jsp:include page="/includes/header.jsp">
    <jsp:param name="activePage" value="register" />
</jsp:include>
--%>

<section class="intro-band">
    <h1>Create Your Moffat Bay Marina Account</h1>
    <p>An account is required to reserve a slip. It only takes a minute.</p>
</section>

<c:if test="${not empty requestScope.formError}">
    <div class="form-banner" role="alert">${fn:escapeXml(requestScope.formError)}</div>
</c:if>

<main>
    <form class="registration-form" method="post"
          action="${pageContext.request.contextPath}/register" id="registrationForm" novalidate>

        <!-- Left column: name & mailing info -->
        <div class="form-column">

            <h2 class="column-heading">Personal Information</h2>

            <div class="form-group">
                <label for="firstName">First Name <span class="required-mark">*</span></label>
                <input type="text" id="firstName" name="firstName" required
                       placeholder="Jack"
                       value="${fn:escapeXml(param.firstName)}">
            </div>

            <div class="form-group">
                <label for="lastName">Last Name <span class="required-mark">*</span></label>
                <input type="text" id="lastName" name="lastName" required
                       placeholder="Sparrow"
                       value="${fn:escapeXml(param.lastName)}">
            </div>

            <div class="form-row-split form-row-split-phone">
                <div class="form-group">
                    <label for="phoneCountryCode" class="visually-hidden">Country Code</label>
                    <input type="text" id="phoneCountryCode" name="phoneCountryCode"
                           value="1" readonly aria-label="Country Code">
                </div>
                <div class="form-group">
                    <label for="phoneDisplay">Phone <span class="required-mark">*</span></label>
                    <input type="text" id="phoneDisplay" required
                           inputmode="numeric" maxlength="14"
                           placeholder="(360)-555-0100" autocomplete="tel-national">
                    <input type="hidden" id="phone" name="phone" value="${fn:escapeXml(param.phone)}">
                    <div class="field-error" id="phoneError"></div>
                </div>
            </div>

            <div class="form-group">
                <label for="streetAddress">Street Address <span class="required-mark">*</span></label>
                <input type="text" id="streetAddress" name="streetAddress" required
                       placeholder="1 Shipwreck Cove"
                       value="${fn:escapeXml(param.streetAddress)}">
            </div>

            <div class="form-group">
                <label for="streetAddress2">Address Line 2</label>
                <input type="text" id="streetAddress2" name="streetAddress2"
                       placeholder="Apt, suite, PO box, etc. (e.g. Cabin 13)"
                       value="${fn:escapeXml(param.streetAddress2)}">
            </div>

            <div class="form-row-split">
                <div class="form-group">
                    <label for="city">City <span class="required-mark">*</span></label>
                    <input type="text" id="city" name="city" required
                           placeholder="Tortuga"
                           value="${fn:escapeXml(param.city)}">
                </div>
                <div class="form-group">
                    <label for="state">State <span class="required-mark">*</span></label>
                    <select id="state" name="state" required>
                        <jsp:include page="/includes/stateOptions.jsp">
                            <jsp:param name="fieldName" value="state" />
                        </jsp:include>
                    </select>
                </div>
            </div>

            <div class="form-group">
                <label for="zipCode">Zip Code <span class="required-mark">*</span></label>
                <input type="text" id="zipCode" name="zipCode" required
                       pattern="^\d{5}(-\d{4})?$" maxlength="10"
                       placeholder="33040"
                       value="${fn:escapeXml(param.zipCode)}">
                <div class="field-error" id="zipError"></div>
            </div>

        </div>

        <!-- Middle column: boat info, entirely optional -->
        <div class="form-column">

            <h2 class="column-heading">Boat Information</h2>

            <div class="column-intro">
                <p class="optional-mark">Optional</p>
                <p class="column-note">(you may add a boat later, or do it now)</p>
            </div>

            <div class="form-group">
                <label for="boatName">Boat Name <span class="required-mark">*</span></label>
                <input type="text" id="boatName" name="boatName" maxlength="50"
                       placeholder="Black Pearl"
                       value="${fn:escapeXml(param.boatName)}">
            </div>

            <div class="form-group">
                <label for="boatType">Boat Type</label>
                <input type="text" id="boatType" name="boatType" maxlength="30"
                       placeholder="Sailboat, powerboat, catamaran, etc. (e.g. Galleon)"
                       value="${fn:escapeXml(param.boatType)}">
            </div>

            <div class="form-row-split">
                <div class="form-group">
                    <label for="boatLength">Boat Length (ft) <span class="required-mark">*</span></label>
                    <input type="number" id="boatLength" name="boatLength"
                           min="1" max="999.9" step="0.1"
                           placeholder="45"
                           value="${fn:escapeXml(param.boatLength)}">
                </div>
                <div class="form-group">
                    <label for="boatBeam">Boat Beam (ft)</label>
                    <input type="number" id="boatBeam" name="boatBeam"
                           min="1" max="999.9" step="0.1"
                           placeholder="12"
                           value="${fn:escapeXml(param.boatBeam)}">
                </div>
            </div>

            <div class="form-group">
                <label for="hin">HIN</label>
                <input type="text" id="hin" name="hin" maxlength="12"
                       placeholder="e.g. BPL123456789"
                       value="${fn:escapeXml(param.hin)}">
                <div class="field-error" id="hinError"></div>
            </div>

            <div class="form-row-split">
                <div class="form-group">
                    <label for="regState">Registration State <span class="required-mark">*</span></label>
                    <select id="regState" name="regState">
                        <jsp:include page="/includes/stateOptions.jsp">
                            <jsp:param name="fieldName" value="regState" />
                        </jsp:include>
                    </select>
                </div>
                <div class="form-group">
                    <label for="regNumber">Registration Number <span class="required-mark">*</span></label>
                    <input type="text" id="regNumber" name="regNumber" maxlength="20"
                           placeholder="e.g. 0007 JS"
                           value="${fn:escapeXml(param.regNumber)}">
                    <div class="field-error" id="regNumberError"></div>
                </div>
            </div>

            <div class="year-with-note">
                <div class="form-group field-narrow">
                    <label for="boatYear">Boat Year</label>
                    <input type="text" id="boatYear" name="boatYear"
                           inputmode="numeric" maxlength="4"
                           placeholder="2003"
                           value="${fn:escapeXml(param.boatYear)}">
                    <div class="field-error" id="boatYearError"></div>
                </div>
                <p class="boat-id-note" id="boatIdNote" aria-live="polite">
                    Enter a Boat Year above to see whether you need the HIN or Registration State &amp; Number.
                </p>
            </div>

            <div class="field-error" id="boatSectionError"></div>

        </div>

        <!-- Right column: email & password -->
        <div class="form-column">

            <h2 class="column-heading">User Information</h2>

            <div class="form-group">
                <label for="email">Email <span class="required-mark">*</span></label>
                <input type="email" id="email" name="email" required
                       placeholder="jack.sparrow@blackpearl.sea"
                       value="${fn:escapeXml(param.email)}">
                <div class="field-error" id="emailError">
                    <c:if test="${not empty requestScope.emailError}">${fn:escapeXml(requestScope.emailError)}</c:if>
                </div>
            </div>

            <div class="password-fields">
                <div class="form-group">
                    <label for="password">Password <span class="required-mark">*</span></label>
                    <input type="password" id="password" name="password" required autocomplete="new-password">
                    <div class="field-error" id="passwordError">
                        <c:if test="${not empty requestScope.passwordError}">${fn:escapeXml(requestScope.passwordError)}</c:if>
                    </div>
                </div>

                <div class="form-group">
                    <label for="confirmPassword">Re-type Password <span class="required-mark">*</span></label>
                    <input type="password" id="confirmPassword" name="confirmPassword" required autocomplete="new-password">
                    <div class="field-error" id="confirmPasswordError"></div>
                </div>
            </div>

            <div class="password-rules" id="passwordRules">
                <p>Your password must contain:</p>
                <ul>
                    <li id="ruleLength" data-rule="length">At least 10 characters</li>
                    <li id="ruleUpper" data-rule="upper">One uppercase letter</li>
                    <li id="ruleLower" data-rule="lower">One lowercase letter</li>
                    <li id="ruleNumber" data-rule="number">One number</li>
                    <li id="ruleSpecial" data-rule="special">One special character (! $ % * #)</li>
                </ul>
            </div>

            <div class="submit-row">
                <button type="submit" class="btn-primary" id="submitBtn" disabled>Create Account</button>
                <p class="login-link">Already have an account? <a href="#" id="loginLinkTrigger">Log in</a></p>
            </div>

        </div>

    </form>
</main>

<%--
    Shared footer scaffold is still under construction, see
    DevNotes/Contracts/shared-scaffold-contract.md (Sara). Swap this in
    once /includes/footer.jsp exists.

<jsp:include page="/includes/footer.jsp" />
--%>

<script src="${pageContext.request.contextPath}/js/formValidation.js"></script>
<script>
    (function () {
        "use strict";

        var form = document.getElementById("registrationForm");
        var email = document.getElementById("email");
        var emailError = document.getElementById("emailError");
        var password = document.getElementById("password");
        var confirmPassword = document.getElementById("confirmPassword");
        var confirmError = document.getElementById("confirmPasswordError");
        var submitBtn = document.getElementById("submitBtn");
        var phoneDisplay = document.getElementById("phoneDisplay");
        var phoneHidden = document.getElementById("phone");
        var phoneError = document.getElementById("phoneError");
        var zipCode = document.getElementById("zipCode");
        var zipError = document.getElementById("zipError");

        var boatCoreIds = ["boatName", "regState", "regNumber", "boatLength"];
        var boatOptionalIds = ["hin", "boatType", "boatBeam", "boatYear"];
        var boatFields = {};
        boatCoreIds.concat(boatOptionalIds).forEach(function (id) {
            boatFields[id] = document.getElementById(id);
        });
        var boatSectionError = document.getElementById("boatSectionError");
        var boatIdNote = document.getElementById("boatIdNote");
        var hinError = document.getElementById("hinError");
        var regNumberError = document.getElementById("regNumberError");
        var boatYearError = document.getElementById("boatYearError");

        var ruleElements = {
            length: document.getElementById("ruleLength"),
            upper: document.getElementById("ruleUpper"),
            lower: document.getElementById("ruleLower"),
            number: document.getElementById("ruleNumber"),
            special: document.getElementById("ruleSpecial")
        };

        function syncPhoneFromDisplay() {
            var digits = MoffatBay.form.extractPhoneDigits(phoneDisplay.value);
            phoneHidden.value = digits;
            phoneDisplay.value = MoffatBay.form.formatPhoneDisplay(digits);

            var complete = digits.length === 10;
            phoneDisplay.setCustomValidity(complete ? "" : "Enter a 10-digit phone number.");
            phoneError.textContent = (digits.length > 0 && !complete)
                ? "Phone number needs all 10 digits."
                : "";
            return complete;
        }

        // Populate the display field from whatever raw digits came back
        // in the hidden field (e.g. a validation round-trip after a
        // failed submit), rather than starting the display blank.
        phoneDisplay.value = MoffatBay.form.formatPhoneDisplay(MoffatBay.form.extractPhoneDigits(phoneHidden.value));

        // Validity check only - deliberately does not touch emailError's
        // text, so a server-rendered error (e.g. "already registered")
        // survives the initial page-load pass below and only gets
        // replaced once the user actually edits the field (see the
        // dedicated "input" listener further down).
        function emailIsValid() {
            var value = email.value.trim();
            var valid = value.length === 0 || MoffatBay.form.isValidEmail(value);
            email.setCustomValidity(valid ? "" : "Enter a valid email address.");
            return value.length > 0 && valid;
        }

        function zipIsValid() {
            var value = zipCode.value.trim();
            var valid = value.length === 0 || MoffatBay.form.isValidZip(value);
            var message = "Enter a 5-digit ZIP, or ZIP+4 like 12345-6789.";
            zipCode.setCustomValidity(valid ? "" : message);
            zipError.textContent = (value.length > 0 && !valid) ? message : "";
            return value.length > 0 && valid;
        }

        function hinIsValid() {
            var value = boatFields.hin.value.trim();
            var valid = MoffatBay.form.isValidHIN(value);
            var message = "HIN should be 12 characters: 3 letters, then 9 more letters or numbers.";
            boatFields.hin.setCustomValidity(valid ? "" : message);
            hinError.textContent = (value.length > 0 && !valid) ? message : "";
            return valid;
        }

        function regNumberIsValid() {
            var value = boatFields.regNumber.value.trim();
            var valid = MoffatBay.form.isValidRegNumber(value);
            var message = "Registration Number should be 4 to 7 digits followed by 2 letters, e.g. 1234 AB.";
            boatFields.regNumber.setCustomValidity(valid ? "" : message);
            regNumberError.textContent = (value.length > 0 && !valid) ? message : "";
            return valid;
        }

        function boatYearIsValid() {
            var value = boatFields.boatYear.value.trim();
            var valid = value.length === 0 || MoffatBay.form.isValidBoatYear(value);
            var message = "Enter a 4-digit year, 1800 through " + new Date().getFullYear() + ".";
            boatFields.boatYear.setCustomValidity(valid ? "" : message);
            boatYearError.textContent = (value.length > 0 && !valid) ? message : "";
            return valid;
        }

        // HIN wasn't required (or in some cases didn't exist) on boats
        // built before 1972, so a pre-1972 boat has to be identified by
        // Registration State + Registration Number instead. A 1972-or-
        // later boat can use either the HIN by itself, or Registration
        // State + Registration Number - whichever the owner has handy.
        var HIN_REQUIRED_STARTING_YEAR = 1972;

        function boatIsPre1972() {
            var yearValue = boatFields.boatYear.value.trim();
            return yearValue !== ""
                && MoffatBay.form.isValidBoatYear(yearValue)
                && Number(yearValue) < HIN_REQUIRED_STARTING_YEAR;
        }

        function boatYearKnown() {
            var yearValue = boatFields.boatYear.value.trim();
            return yearValue !== "" && MoffatBay.form.isValidBoatYear(yearValue);
        }

        function identificationSatisfied() {
            var hinFilled = boatFields.hin.value.trim() !== "";
            var regFilled = boatFields.regState.value.trim() !== "" && boatFields.regNumber.value.trim() !== "";

            // Year unknown or pre-1972: HIN alone doesn't count, fall
            // back to requiring Registration State + Number.
            if (!boatYearKnown() || boatIsPre1972()) {
                return regFilled;
            }
            return hinFilled || regFilled;
        }

        function updateBoatIdNote() {
            if (!boatYearKnown()) {
                boatIdNote.textContent = "Enter a Boat Year above to see whether you need the HIN or Registration State & Number.";
            } else if (boatIsPre1972()) {
                boatIdNote.textContent = "Boats built before " + HIN_REQUIRED_STARTING_YEAR + " need Registration State & Number (HIN not required).";
            } else {
                boatIdNote.textContent = "Boats built in " + HIN_REQUIRED_STARTING_YEAR + " or later can use either the HIN or Registration State & Number.";
            }
        }

        // The boat section is entirely optional - skip every field and
        // there's nothing to register. But the moment any one of them
        // is filled in, Boat Name and Boat Length become required,
        // along with whichever identification the boat's year calls
        // for (see identificationSatisfied above), since the Boat
        // table won't accept a half-filled row.
        function boatSectionValid() {
            var anyFilled = boatCoreIds.concat(boatOptionalIds).some(function (id) {
                return boatFields[id].value.trim() !== "";
            });
            if (!anyFilled) {
                boatSectionError.textContent = "";
                return true;
            }

            var nameAndLengthFilled = boatFields.boatName.value.trim() !== ""
                && boatFields.boatLength.value.trim() !== "";
            var valid = nameAndLengthFilled && identificationSatisfied();
            boatSectionError.textContent = valid
                ? ""
                : "Fill in Boat Name, Boat Length, and either the HIN or Registration State & Number (see the note above) to register a boat, or clear all boat fields to skip it.";
            return valid;
        }

        function updateFormState() {
            var pwValue = password.value;
            var confirmValue = confirmPassword.value;
            var pwValid = MoffatBay.form.checkPasswordRules(pwValue, ruleElements);
            var matches = confirmValue.length > 0 && pwValue === confirmValue;
            var phoneComplete = syncPhoneFromDisplay();
            var emailValid = emailIsValid();
            var zipValid = zipIsValid();
            var hinValid = hinIsValid();
            var regNumberValid = regNumberIsValid();
            var boatYearValid = boatYearIsValid();
            updateBoatIdNote();
            var boatValid = boatSectionValid();

            confirmError.textContent = (confirmValue.length > 0 && !matches)
                ? "Passwords do not match."
                : "";

            var requiredFieldsFilled = true;
            form.querySelectorAll("[required]").forEach(function (field) {
                if (field.id === "confirmPassword") { return; }
                if (!field.value || field.value.trim() === "") { requiredFieldsFilled = false; }
            });

            submitBtn.disabled = !(
                pwValid && matches && phoneComplete && emailValid && zipValid &&
                hinValid && regNumberValid && boatYearValid && boatValid && requiredFieldsFilled
            );
        }

        password.addEventListener("input", updateFormState);
        confirmPassword.addEventListener("input", updateFormState);
        phoneDisplay.addEventListener("input", updateFormState);
        zipCode.addEventListener("input", updateFormState);
        form.addEventListener("input", updateFormState);

        // Only takes over the emailError text once the user actually
        // edits the field - keeps a server-rendered error (e.g.
        // "already registered") visible until then.
        email.addEventListener("input", function () {
            var value = email.value.trim();
            var valid = value.length === 0 || MoffatBay.form.isValidEmail(value);
            emailError.textContent = (value.length > 0 && !valid) ? "Enter a valid email address." : "";
            updateFormState();
        });

        form.addEventListener("submit", function (event) {
            if (!form.checkValidity() || submitBtn.disabled) {
                event.preventDefault();
                form.reportValidity();
            }
        });

        // Placeholder trigger for the Login modal (built separately - see
        // login-page-contract.md). Wired up once the shared header/modal
        // scaffold exists; for now this just prevents a dead link.
        document.getElementById("loginLinkTrigger").addEventListener("click", function (event) {
            event.preventDefault();
        });

        updateFormState();
    })();
</script>

</body>
</html>
