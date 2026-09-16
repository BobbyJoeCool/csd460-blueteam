<%--
  Blue Team - Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
  Primary Author/Owner - Robert Breutzmann

  Personal Information card (name, phone, mailing address) - the left
  column of the Registration form.

  Each field reads its own request parameter first (a resubmitted value
  after a failed validation on the page that includes this), and falls
  back to an optional "default*" param only when that parameter was never
  submitted at all. That's how a page like Edit Account can pre-populate
  the card from an existing Customer record instead of a blank form:

    <jsp:include page="/includes/personalInfoCard.jsp">
        <jsp:param name="defaultFirstName" value="${customer.firstName}" />
        <jsp:param name="defaultLastName" value="${customer.lastName}" />
        <jsp:param name="defaultPhoneCountryCode" value="${customer.phoneCountryCode}" />
        <jsp:param name="defaultPhone" value="${customer.phone}" />
        <jsp:param name="defaultStreetAddress" value="${customer.streetAddress}" />
        <jsp:param name="defaultStreetAddress2" value="${customer.streetAddress2}" />
        <jsp:param name="defaultCity" value="${customer.city}" />
        <jsp:param name="defaultState" value="${customer.state}" />
        <jsp:param name="defaultZipCode" value="${customer.zipCode}" />
        <jsp:param name="defaultCountry" value="${customer.country}" />
    </jsp:include>

  Every default* param is optional (fine to leave unset/null) -
  Registration.jsp includes this with none of them, so every field just
  falls back to empty on first load, same as before this was pulled out.

  Expects to render inside a <form>; doesn't declare its own <form> tag.

  "Touched" is checked with paramValues, not param. param.X collapses a
  submitted-but-blank field and a field that was never in the request at
  all down to the same empty string, so testing "not empty param.X" can't
  tell the two apart. On Edit User Info that mattered: a required field
  resubmitted blank was falling back to defaultX (the value already on
  file) instead of staying blank, so a rejected save redisplayed the
  customer's old value right next to a "this is required" error - looking
  like nothing was wrong, or like their blank was silently discarded.
  paramValues.X is null only when the key is genuinely absent from the
  request, so it's null on a first GET (fall back to the default) and a
  non-null (possibly single-empty-string) array on any resubmission (use
  what was actually submitted, blank or not) - the same touched/untouched
  distinction EditProfileServlet.touched() already makes server-side.
--%>
<%@ page isELIgnored="false" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>

<c:set var="firstNameValue" value="${not empty paramValues.firstName ? param.firstName : param.defaultFirstName}" />
<c:set var="lastNameValue" value="${not empty paramValues.lastName ? param.lastName : param.defaultLastName}" />
<c:set var="phoneCountryCodeValue" value="${not empty paramValues.phoneCountryCode ? param.phoneCountryCode : (not empty param.defaultPhoneCountryCode ? param.defaultPhoneCountryCode : '1')}" />
<c:set var="phoneValue" value="${not empty paramValues.phone ? param.phone : param.defaultPhone}" />
<c:set var="streetAddressValue" value="${not empty paramValues.streetAddress ? param.streetAddress : param.defaultStreetAddress}" />
<c:set var="streetAddress2Value" value="${not empty paramValues.streetAddress2 ? param.streetAddress2 : param.defaultStreetAddress2}" />
<c:set var="cityValue" value="${not empty paramValues.city ? param.city : param.defaultCity}" />
<c:set var="stateValue" value="${not empty paramValues.state ? param.state : param.defaultState}" />
<c:set var="zipCodeValue" value="${not empty paramValues.zipCode ? param.zipCode : param.defaultZipCode}" />
<c:set var="countryValue" value="${not empty paramValues.country ? param.country : (not empty param.defaultCountry ? param.defaultCountry : 'US')}" />

<div class="form-column" id="personalInfoColumn">

    <h2 class="column-heading">Personal Information</h2>

    <div class="form-group" id="firstNameGroup">
        <label for="firstName">First Name <span class="required-mark">*</span></label>
        <input type="text" id="firstName" name="firstName" required
               placeholder="Jack"
               value="${fn:escapeXml(firstNameValue)}">
        <div class="field-error" id="firstNameError"></div>
    </div>

    <div class="form-group" id="lastNameGroup">
        <label for="lastName">Last Name <span class="required-mark">*</span></label>
        <input type="text" id="lastName" name="lastName" required
               placeholder="Sparrow"
               value="${fn:escapeXml(lastNameValue)}">
        <div class="field-error" id="lastNameError"></div>
    </div>

    <div class="form-row-split form-row-split-phone">
        <div class="form-group" id="phoneCountryCodeGroup">
            <label for="phoneCountryCode" class="visually-hidden">Country Code</label>
            <input type="text" id="phoneCountryCode" name="phoneCountryCode" required
                   inputmode="numeric" maxlength="3"
                   value="${fn:escapeXml(phoneCountryCodeValue)}"
                   aria-label="Country Code">
            <div class="field-error" id="phoneCountryCodeError"></div>
        </div>
        <div class="form-group" id="phoneGroup">
            <label for="phoneDisplay">Phone <span class="required-mark">*</span></label>
            <input type="text" id="phoneDisplay" required
                   inputmode="numeric" maxlength="14"
                   placeholder="(360)-555-0100" autocomplete="tel-national">
            <input type="hidden" id="phone" name="phone" value="${fn:escapeXml(phoneValue)}">
            <div class="field-error" id="phoneError"></div>
        </div>
    </div>

    <div class="form-group" id="countryGroup">
        <label for="country">Country <span class="required-mark">*</span></label>
        <select id="country" name="country" required>
            <jsp:include page="/includes/countryOptions.jsp">
                <jsp:param name="fieldName" value="country" />
                <jsp:param name="country" value="${countryValue}" />
            </jsp:include>
        </select>
        <div class="field-error" id="countryError"></div>
    </div>

    <div class="form-group" id="streetAddressGroup">
        <label for="streetAddress">Street Address <span class="required-mark">*</span></label>
        <input type="text" id="streetAddress" name="streetAddress" required
               placeholder="1 Shipwreck Cove"
               value="${fn:escapeXml(streetAddressValue)}">
        <div class="field-error" id="streetAddressError"></div>
    </div>

    <div class="form-group" id="streetAddress2Group">
        <label for="streetAddress2">Address Line 2</label>
        <input type="text" id="streetAddress2" name="streetAddress2"
               placeholder="Apt, suite, PO box, etc. (e.g. Cabin 13)"
               value="${fn:escapeXml(streetAddress2Value)}">
        <div class="field-error" id="streetAddress2Error"></div>
    </div>

    <div class="form-row-split">
        <div class="form-group" id="cityGroup">
            <label for="city">City <span class="required-mark">*</span></label>
            <input type="text" id="city" name="city" required
                   placeholder="Tortuga"
                   value="${fn:escapeXml(cityValue)}">
            <div class="field-error" id="cityError"></div>
        </div>
        <%--
          State/Province follows the Country field above: CA swaps in
          provinceOptions.jsp and the "Province" label, OTHER disables the
          field (no state/province concept applies) - see registration.js's
          applyCountryToAddressSection and the Registration contract's
          "Country" section.
        --%>
        <div class="form-group" id="stateGroup">
            <label for="state" id="stateLabel">${countryValue == 'CA' ? 'Province' : 'State'}</label>
            <select id="state" name="state" ${countryValue == 'OTHER' ? 'disabled' : 'required'}>
                <c:choose>
                    <c:when test="${countryValue == 'CA'}">
                        <jsp:include page="/includes/provinceOptions.jsp">
                            <jsp:param name="fieldName" value="state" />
                            <jsp:param name="state" value="${stateValue}" />
                        </jsp:include>
                    </c:when>
                    <c:when test="${countryValue == 'OTHER'}">
                        <option value="">Not applicable</option>
                    </c:when>
                    <c:otherwise>
                        <jsp:include page="/includes/stateOptions.jsp">
                            <jsp:param name="fieldName" value="state" />
                            <jsp:param name="state" value="${stateValue}" />
                        </jsp:include>
                    </c:otherwise>
                </c:choose>
            </select>
            <div class="field-error" id="stateError"></div>
        </div>
    </div>

    <div class="form-group" id="zipCodeGroup">
        <label for="zipCode">Zip Code <span class="required-mark">*</span></label>
        <input type="text" id="zipCode" name="zipCode" required
               pattern="^\d{5}(-\d{4})?$" maxlength="10"
               placeholder="33040"
               value="${fn:escapeXml(zipCodeValue)}">
        <div class="field-error" id="zipError"></div>
    </div>

    <button type="button" class="btn-clear-section" id="clearPersonalInfo">
        Clear Personal Info
    </button>

</div>
