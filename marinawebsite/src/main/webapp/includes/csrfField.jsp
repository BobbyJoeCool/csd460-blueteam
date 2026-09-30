<%--
  Blue Team - Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
  Primary Author/Owner - Robert Breutzmann

  The anti-forgery token every POST form carries, checked by CsrfFilter
  before the form reaches its servlet. Goes just inside each
  <form method="post">:

      <jsp:include page="/includes/csrfField.jsp" />

  Scripts that POST with fetch() send the same token in an X-CSRF-Token
  header instead - see MoffatBay.form.csrfToken() in formValidation.js.
--%>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<input type="hidden" name="csrfToken" value="${fn:escapeXml(sessionScope.csrfToken)}">
