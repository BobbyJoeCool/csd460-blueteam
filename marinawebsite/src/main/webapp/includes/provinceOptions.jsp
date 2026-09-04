<%--
  Shared <option> list for a Canadian province/territory <select> - the
  Registration State/Province field's option set when Boat Registration's
  country context is Canada. Same fieldName/selected pattern as
  stateOptions.jsp:

    <select id="regState" name="regState">
        <jsp:include page="/includes/provinceOptions.jsp">
            <jsp:param name="fieldName" value="regState" />
        </jsp:include>
    </select>

  registration.js keeps a matching array of these same 13 entries to
  rebuild this <select> client-side when Country changes without a page
  reload - see js/registration.js's regionOptions data and the Registration
  contract's "Boat Fields" section for why the option list has to swap
  with Country instead of being fixed.
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
