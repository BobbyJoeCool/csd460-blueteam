<%--
  "Password must contain" checklist box. Shows/hides a checkmark per
  rule as the user types, via passwordRules.js (which pairs with this
  markup - the actual rule definitions/regexes stay in
  MoffatBay.form.PASSWORD_RULES, in the shared formValidation.js).

  Include wherever a page collects a new password. In <head>, after
  site.css (passwordRules.css uses its color variables):

    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/passwordRules.css">

  In the body:

    <jsp:include page="/includes/passwordRules.jsp" />

  and load its script after formValidation.js:

    <script src="${pageContext.request.contextPath}/js/formValidation.js"></script>
    <script src="${pageContext.request.contextPath}/js/passwordRules.js"></script>

  Then call MoffatBay.passwordRules.check(passwordValue) wherever the
  page validates the password field - it toggles each rule's checkmark
  and returns true only if every rule passed.

  At most one per page - it binds to the #passwordRules container by id.
--%>
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
