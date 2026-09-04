<%--
  Boat Information card - the middle column of the Registration form.
  Entirely optional there: a Customer can register without a boat and
  add one later.

  Same default-value pattern as personalInfoCard.jsp: each field reads
  its own request parameter first (a resubmitted value after a failed
  validation on the page that includes this), and falls back to an
  optional "default*" param if that's empty. That's how a future Edit
  Boat page can pre-populate the card from an existing Boat record:

    <jsp:include page="/includes/boatInfoCard.jsp">
        <jsp:param name="defaultBoatName" value="${boat.boatName}" />
        <jsp:param name="defaultBoatType" value="${boat.boatType}" />
        <jsp:param name="defaultBoatLength" value="${boat.boatLength}" />
        <jsp:param name="defaultBoatBeam" value="${boat.boatBeam}" />
        <jsp:param name="defaultHin" value="${boat.hin}" />
        <jsp:param name="defaultRegState" value="${boat.regState}" />
        <jsp:param name="defaultRegNumber" value="${boat.regNumber}" />
        <jsp:param name="defaultBoatYear" value="${boat.boatYear}" />
    </jsp:include>

  Every default* param is optional (fine to leave unset/null) -
  Registration.jsp includes this with none of them, so every field just
  falls back to empty on first load, same as before this was pulled out.

  Registration State/Number is also driven by the "country" request
  parameter, which this card doesn't own - it belongs to the Country field
  in personalInfoCard.jsp, but both cards render inside the same <form>/
  request, so this card just reads param.country directly. Country=CA
  swaps in provinceOptions.jsp and Canadian-format placeholders;
  Country=OTHER disables the field entirely and shows
  #foreignRegistrationBadge instead. See the Registration contract's
  "Boat Fields" section.

  Expects to render inside a <form>; doesn't declare its own <form> tag.
--%>
<%@ page isELIgnored="false" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>

<c:set var="boatNameValue" value="${not empty param.boatName ? param.boatName : param.defaultBoatName}" />
<c:set var="boatTypeValue" value="${not empty param.boatType ? param.boatType : param.defaultBoatType}" />
<c:set var="boatLengthValue" value="${not empty param.boatLength ? param.boatLength : param.defaultBoatLength}" />
<c:set var="boatBeamValue" value="${not empty param.boatBeam ? param.boatBeam : param.defaultBoatBeam}" />
<c:set var="hinValue" value="${not empty param.hin ? param.hin : param.defaultHin}" />
<c:set var="regStateValue" value="${not empty param.regState ? param.regState : param.defaultRegState}" />
<c:set var="regNumberValue" value="${not empty param.regNumber ? param.regNumber : param.defaultRegNumber}" />
<c:set var="boatYearValue" value="${not empty param.boatYear ? param.boatYear : param.defaultBoatYear}" />

<%--
  Registration State/Province tracks the Country field over in
  personalInfoCard.jsp - both fields read the same request parameter
  ("country"), it's just the other include that owns rendering the
  <select> itself. See the Registration contract's "Boat Fields" section.
--%>
<c:set var="countryValue" value="${not empty param.country ? param.country : 'US'}" />

<div class="form-column" id="boatInfoColumn">

    <h2 class="column-heading">Boat Information</h2>

    <div class="column-intro">
        <p class="optional-mark">Optional</p>
        <p class="column-note">(you may add a boat later, or do it now)</p>
    </div>

    <output class="callout-badge" id="foreignRegistrationBadge" ${countryValue == 'OTHER' ? '' : 'hidden'}>
        If your boat is not registered in the United States or Canada,
        please call the Marina to register your boat after you make an
        account.
    </output>

    <div class="form-group" id="boatNameGroup">
        <label for="boatName">Boat Name <span class="required-mark">*</span></label>
        <input type="text" id="boatName" name="boatName" maxlength="50"
               placeholder="Black Pearl"
               value="${fn:escapeXml(boatNameValue)}">
    </div>

    <div class="form-group" id="boatTypeGroup">
        <label for="boatType">Boat Type</label>
        <input type="text" id="boatType" name="boatType" maxlength="30"
               placeholder="Sailboat, powerboat, etc. (e.g. Galleon)"
               value="${fn:escapeXml(boatTypeValue)}">
    </div>

    <div class="form-row-split">
        <div class="form-group" id="boatLengthGroup">
            <label for="boatLength">Boat Length (ft) <span class="required-mark">*</span></label>
            <input type="number" id="boatLength" name="boatLength"
                   min="1" max="999.9" step="0.1"
                   placeholder="45"
                   value="${fn:escapeXml(boatLengthValue)}">
        </div>
        <div class="form-group" id="boatBeamGroup">
            <label for="boatBeam">Boat Beam (ft)</label>
            <input type="number" id="boatBeam" name="boatBeam"
                   min="1" max="999.9" step="0.1"
                   placeholder="12"
                   value="${fn:escapeXml(boatBeamValue)}">
        </div>
    </div>

    <%--
      HIN is the primary/default way to identify a boat - listed first,
      no longer marked required. Registration State/Number below is the
      fallback for an owner without a HIN handy. Neither is required to
      submit; #identificationNote below covers the "have neither" case.
      See the Registration contract's "Boat Fields" section.
    --%>
    <div class="form-group" id="hinGroup">
        <label for="hin">HIN <span class="field-hint">(recommended)</span></label>
        <input type="text" id="hin" name="hin" maxlength="12"
               placeholder="e.g. BPL123456789"
               value="${fn:escapeXml(hinValue)}">
        <div class="field-error" id="hinError"></div>
    </div>

    <div class="form-row-split">
        <div class="form-group" id="regStateGroup">
            <label for="regState" id="regStateLabel">${countryValue == 'CA' ? 'Registration Province' : 'Registration State'}</label>
            <select id="regState" name="regState" ${countryValue == 'OTHER' ? 'disabled' : ''}>
                <c:choose>
                    <c:when test="${countryValue == 'CA'}">
                        <jsp:include page="/includes/provinceOptions.jsp">
                            <jsp:param name="fieldName" value="regState" />
                            <jsp:param name="regState" value="${regStateValue}" />
                        </jsp:include>
                    </c:when>
                    <c:when test="${countryValue == 'OTHER'}">
                        <option value="">Not applicable</option>
                    </c:when>
                    <c:otherwise>
                        <jsp:include page="/includes/stateOptions.jsp">
                            <jsp:param name="fieldName" value="regState" />
                            <jsp:param name="regState" value="${regStateValue}" />
                        </jsp:include>
                    </c:otherwise>
                </c:choose>
            </select>
        </div>
        <div class="form-group" id="regNumberGroup">
            <label for="regNumber">Registration Number</label>
            <input type="text" id="regNumber" name="regNumber" maxlength="20"
                   placeholder="${countryValue == 'CA' ? 'e.g. C1234 AB' : 'e.g. 0007 JS'}"
                   value="${fn:escapeXml(regNumberValue)}"
                   ${countryValue == 'OTHER' ? 'disabled' : ''}>
            <div class="field-error" id="regNumberError"></div>
        </div>
    </div>

    <output class="callout-badge" id="identificationNote" hidden>
        If you don't have a HIN or Boat Registration, you can call the
        Marina at <a href="tel:+13605550142">(360) 555-0142</a> for other
        options.
    </output>

    <div class="form-group" id="boatYearGroup">
        <label for="boatYear">Boat Year</label>
        <input type="text" id="boatYear" name="boatYear"
               inputmode="numeric" maxlength="4"
               placeholder="2003"
               value="${fn:escapeXml(boatYearValue)}">
        <div class="field-error" id="boatYearError"></div>
    </div>

    <div class="field-error" id="boatSectionError"></div>

    <button type="button" class="btn-clear-section" id="clearBoatInfo">
        Clear Boat Info
    </button>

</div>
