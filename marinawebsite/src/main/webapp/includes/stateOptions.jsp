<%--
  Shared <option> list for a US state <select>. Include this inside a
  <select>, passing the form field name to check against via a
  <jsp:param> named "fieldName" so the right option gets marked
  selected on a validation round-trip:

    <select id="state" name="state" required>
        <jsp:include page="/includes/stateOptions.jsp">
            <jsp:param name="fieldName" value="state" />
        </jsp:include>
    </select>
--%>
<%@ page isELIgnored="false" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<c:set var="selectedState" value="${param[param.fieldName]}" />
<option value="" disabled ${empty selectedState ? 'selected' : ''}>Select&hellip;</option>
<option value="AL" ${selectedState == 'AL' ? 'selected' : ''}>Alabama</option>
<option value="AK" ${selectedState == 'AK' ? 'selected' : ''}>Alaska</option>
<option value="AZ" ${selectedState == 'AZ' ? 'selected' : ''}>Arizona</option>
<option value="AR" ${selectedState == 'AR' ? 'selected' : ''}>Arkansas</option>
<option value="CA" ${selectedState == 'CA' ? 'selected' : ''}>California</option>
<option value="CO" ${selectedState == 'CO' ? 'selected' : ''}>Colorado</option>
<option value="CT" ${selectedState == 'CT' ? 'selected' : ''}>Connecticut</option>
<option value="DE" ${selectedState == 'DE' ? 'selected' : ''}>Delaware</option>
<option value="DC" ${selectedState == 'DC' ? 'selected' : ''}>District of Columbia</option>
<option value="FL" ${selectedState == 'FL' ? 'selected' : ''}>Florida</option>
<option value="GA" ${selectedState == 'GA' ? 'selected' : ''}>Georgia</option>
<option value="HI" ${selectedState == 'HI' ? 'selected' : ''}>Hawaii</option>
<option value="ID" ${selectedState == 'ID' ? 'selected' : ''}>Idaho</option>
<option value="IL" ${selectedState == 'IL' ? 'selected' : ''}>Illinois</option>
<option value="IN" ${selectedState == 'IN' ? 'selected' : ''}>Indiana</option>
<option value="IA" ${selectedState == 'IA' ? 'selected' : ''}>Iowa</option>
<option value="KS" ${selectedState == 'KS' ? 'selected' : ''}>Kansas</option>
<option value="KY" ${selectedState == 'KY' ? 'selected' : ''}>Kentucky</option>
<option value="LA" ${selectedState == 'LA' ? 'selected' : ''}>Louisiana</option>
<option value="ME" ${selectedState == 'ME' ? 'selected' : ''}>Maine</option>
<option value="MD" ${selectedState == 'MD' ? 'selected' : ''}>Maryland</option>
<option value="MA" ${selectedState == 'MA' ? 'selected' : ''}>Massachusetts</option>
<option value="MI" ${selectedState == 'MI' ? 'selected' : ''}>Michigan</option>
<option value="MN" ${selectedState == 'MN' ? 'selected' : ''}>Minnesota</option>
<option value="MS" ${selectedState == 'MS' ? 'selected' : ''}>Mississippi</option>
<option value="MO" ${selectedState == 'MO' ? 'selected' : ''}>Missouri</option>
<option value="MT" ${selectedState == 'MT' ? 'selected' : ''}>Montana</option>
<option value="NE" ${selectedState == 'NE' ? 'selected' : ''}>Nebraska</option>
<option value="NV" ${selectedState == 'NV' ? 'selected' : ''}>Nevada</option>
<option value="NH" ${selectedState == 'NH' ? 'selected' : ''}>New Hampshire</option>
<option value="NJ" ${selectedState == 'NJ' ? 'selected' : ''}>New Jersey</option>
<option value="NM" ${selectedState == 'NM' ? 'selected' : ''}>New Mexico</option>
<option value="NY" ${selectedState == 'NY' ? 'selected' : ''}>New York</option>
<option value="NC" ${selectedState == 'NC' ? 'selected' : ''}>North Carolina</option>
<option value="ND" ${selectedState == 'ND' ? 'selected' : ''}>North Dakota</option>
<option value="OH" ${selectedState == 'OH' ? 'selected' : ''}>Ohio</option>
<option value="OK" ${selectedState == 'OK' ? 'selected' : ''}>Oklahoma</option>
<option value="OR" ${selectedState == 'OR' ? 'selected' : ''}>Oregon</option>
<option value="PA" ${selectedState == 'PA' ? 'selected' : ''}>Pennsylvania</option>
<option value="RI" ${selectedState == 'RI' ? 'selected' : ''}>Rhode Island</option>
<option value="SC" ${selectedState == 'SC' ? 'selected' : ''}>South Carolina</option>
<option value="SD" ${selectedState == 'SD' ? 'selected' : ''}>South Dakota</option>
<option value="TN" ${selectedState == 'TN' ? 'selected' : ''}>Tennessee</option>
<option value="TX" ${selectedState == 'TX' ? 'selected' : ''}>Texas</option>
<option value="UT" ${selectedState == 'UT' ? 'selected' : ''}>Utah</option>
<option value="VT" ${selectedState == 'VT' ? 'selected' : ''}>Vermont</option>
<option value="VA" ${selectedState == 'VA' ? 'selected' : ''}>Virginia</option>
<option value="WA" ${selectedState == 'WA' ? 'selected' : ''}>Washington</option>
<option value="WV" ${selectedState == 'WV' ? 'selected' : ''}>West Virginia</option>
<option value="WI" ${selectedState == 'WI' ? 'selected' : ''}>Wisconsin</option>
<option value="WY" ${selectedState == 'WY' ? 'selected' : ''}>Wyoming</option>
