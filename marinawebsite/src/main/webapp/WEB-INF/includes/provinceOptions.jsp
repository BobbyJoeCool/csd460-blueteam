<%--
  Blue Team - Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
  Primary Author/Owner - Robert Breutzmann

  Shared <option> list for a Canadian province/territory <select> - the
  mailing address's own State/Province field's option set when Country
  is Canada. Same fieldName/selected pattern as stateOptions.jsp:

    <select id="state" name="state">
        <jsp:include page="/WEB-INF/includes/provinceOptions.jsp">
            <jsp:param name="fieldName" value="state" />
        </jsp:include>
    </select>

  This is the list the page is first rendered with. When Country changes,
  formValidation.js rebuilds the options from its own CA_PROVINCES list
  (MoffatBay.form.applyCountryToRegion), so the two lists must match: a
  change here needs the same change there. See the Registration
  contract's "Country" section for why the list swaps with Country.
--%>
<%@ page isELIgnored="false" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<c:set var="selectedProvince" value="${param[param.fieldName]}" />
<option value="" disabled ${empty selectedProvince ? 'selected' : ''}>Select&hellip;</option>
<option value="AB" ${selectedProvince == 'AB' ? 'selected' : ''}>Alberta</option>
<option value="BC" ${selectedProvince == 'BC' ? 'selected' : ''}>British Columbia</option>
<option value="MB" ${selectedProvince == 'MB' ? 'selected' : ''}>Manitoba</option>
<option value="NB" ${selectedProvince == 'NB' ? 'selected' : ''}>New Brunswick</option>
<option value="NL" ${selectedProvince == 'NL' ? 'selected' : ''}>Newfoundland and Labrador</option>
<option value="NS" ${selectedProvince == 'NS' ? 'selected' : ''}>Nova Scotia</option>
<option value="NT" ${selectedProvince == 'NT' ? 'selected' : ''}>Northwest Territories</option>
<option value="NU" ${selectedProvince == 'NU' ? 'selected' : ''}>Nunavut</option>
<option value="ON" ${selectedProvince == 'ON' ? 'selected' : ''}>Ontario</option>
<option value="PE" ${selectedProvince == 'PE' ? 'selected' : ''}>Prince Edward Island</option>
<option value="QC" ${selectedProvince == 'QC' ? 'selected' : ''}>Quebec</option>
<option value="SK" ${selectedProvince == 'SK' ? 'selected' : ''}>Saskatchewan</option>
<option value="YT" ${selectedProvince == 'YT' ? 'selected' : ''}>Yukon</option>
