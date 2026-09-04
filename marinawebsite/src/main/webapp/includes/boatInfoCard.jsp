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

<div class="form-column" id="boatInfoColumn">

    <h2 class="column-heading">Boat Information</h2>

    <div class="column-intro">
        <p class="optional-mark">Optional</p>
        <p class="column-note">(you may add a boat later, or do it now)</p>
    </div>

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

    <div class="form-group" id="hinGroup">
        <label for="hin">HIN</label>
        <input type="text" id="hin" name="hin" maxlength="12"
               placeholder="e.g. BPL123456789"
               value="${fn:escapeXml(hinValue)}">
        <div class="field-error" id="hinError"></div>
    </div>

    <div class="form-row-split">
        <div class="form-group" id="regStateGroup">
            <label for="regState">Registration State <span class="required-mark">*</span></label>
            <select id="regState" name="regState">
                <jsp:include page="/includes/stateOptions.jsp">
                    <jsp:param name="fieldName" value="regState" />
                    <jsp:param name="regState" value="${regStateValue}" />
                </jsp:include>
            </select>
        </div>
        <div class="form-group" id="regNumberGroup">
            <label for="regNumber">Registration Number <span class="required-mark">*</span></label>
            <input type="text" id="regNumber" name="regNumber" maxlength="20"
                   placeholder="e.g. 0007 JS"
                   value="${fn:escapeXml(regNumberValue)}">
            <div class="field-error" id="regNumberError"></div>
        </div>
    </div>

    <div class="year-with-note" id="boatYearGroup">
        <div class="form-group field-narrow">
            <label for="boatYear">Boat Year</label>
            <input type="text" id="boatYear" name="boatYear"
                   inputmode="numeric" maxlength="4"
                   placeholder="2003"
                   value="${fn:escapeXml(boatYearValue)}">
            <div class="field-error" id="boatYearError"></div>
        </div>
        <p class="boat-id-note" id="boatIdNote" aria-live="polite">
            Enter a Boat Year above to see whether you need the HIN or Registration State &amp; Number.
        </p>
    </div>

    <div class="field-error" id="boatSectionError"></div>

</div>
