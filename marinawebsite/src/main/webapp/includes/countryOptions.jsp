<%--
  Shared <option> list for the Country <select> - United States, Canada,
  or Other. Include this inside a <select>, passing the form field name to
  check against via a <jsp:param> named "fieldName" so the right option
  gets marked selected on a validation round-trip, same pattern as
  stateOptions.jsp:

    <select id="country" name="country">
        <jsp:include page="/includes/countryOptions.jsp">
            <jsp:param name="fieldName" value="country" />
        </jsp:include>
    </select>

  Only three options by design - see the Registration contract's "Country"
  section. "OTHER" doesn't capture which country the customer is actually
  in; it exists only to drive the "call the Marina" badge above Boat
  Registration and to disable the Registration State/Province field.
--%>
<%@ page isELIgnored="false" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<c:set var="selectedCountry" value="${empty param[param.fieldName] ? 'US' : param[param.fieldName]}" />
<option value="US" ${selectedCountry == 'US' ? 'selected' : ''}>United States</option>
<option value="CA" ${selectedCountry == 'CA' ? 'selected' : ''}>Canada</option>
<option value="OTHER" ${selectedCountry == 'OTHER' ? 'selected' : ''}>Other</option>
