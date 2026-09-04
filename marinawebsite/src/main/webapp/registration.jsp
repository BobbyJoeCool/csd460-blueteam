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

	<jsp:include page="/includes/styles.jsp" /> <!-- Adds site.css, header.css, footer.css, loginModal.css -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/passwordRules.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/registration.css">
</head>
<body>

<jsp:include page="/includes/header.jsp">
    <jsp:param name="activePage" value="register" />
</jsp:include>

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
        <jsp:include page="/includes/personalInfoCard.jsp" />

        <!-- Middle column: boat info, entirely optional -->
        <jsp:include page="/includes/boatInfoCard.jsp" />

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

            <jsp:include page="/includes/passwordRules.jsp" />

            <div class="submit-row">
                <button type="submit" class="btn-primary" id="submitBtn" disabled>Create Account</button>
                <p class="login-link">Already have an account? <a href="#" id="loginLinkTrigger">Log in</a></p>
            </div>

        </div>

    </form>
</main>

<jsp:include page="/includes/footer.jsp" />

<script src="${pageContext.request.contextPath}/js/passwordRules.js"></script>
<script src="${pageContext.request.contextPath}/js/registration.js"></script>

</body>
</html>
