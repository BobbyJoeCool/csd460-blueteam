<%--
  src/main/webapp/includes/loginModal.jsp

  The Login modal from the Login contract. Included by any page that offers
  a Log In control; it renders hidden until something opens it.

  Two ways it opens:
    1. A user clicks a Log In control - MoffatBay.loginModal.open() in
       loginModal.js.
    2. LoginServlet forwarded back here after a failed attempt, which sets
       the loginError request attribute. In that case the modal renders
       already open with the message inside, so from the user's side it
       just never closed.

  Reads from the request (all set by LoginServlet):
    loginError     - the message to show. Its presence is what opens the modal.
    accountLocked  - TRUE only on the lockout case; swaps the Sign in form
                     for the demo Reset button.
    param.email    - what they typed. Survives the forward, so the field
                     refills without the servlet having to hand it back.

  Author: Miguel Fernandez
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<%--
  redirectTo has to be context-relative, because LoginServlet prepends
  getContextPath() before redirecting. So "/reservation.jsp", never
  "/marinawebsite/reservation.jsp".

  On a failed attempt the request URI is /login, not the page the user
  started on, so the submitted redirectTo is reused when it's there and
  only falls back to the current path on a first, clean render.
--%>
<c:set var="currentPath"
       value="${fn:substring(pageContext.request.requestURI,
                             fn:length(pageContext.request.contextPath),
                             fn:length(pageContext.request.requestURI))}"/>
<c:set var="loginRedirectTo"
       value="${not empty param.redirectTo ? param.redirectTo : currentPath}"/>

<div class="login-modal <c:if test='${not empty loginError}'>is-open</c:if>"
     id="loginModal"
     role="dialog"
     aria-modal="true"
     aria-labelledby="loginModalTitle">

    <div class="login-modal__backdrop" data-login-close></div>

    <div class="login-modal__panel">

        <button type="button"
                class="login-modal__close"
                data-login-close
                aria-label="Close sign in">&times;</button>

        <h2 class="login-modal__title" id="loginModalTitle">Sign in</h2>

        <c:if test="${not empty loginError}">
            <p class="login-modal__error" role="alert">
                <c:out value="${loginError}"/>
            </p>
        </c:if>

        <c:choose>

            <%-- Locked out: no point offering the form, the servlet rejects
                 it before checking the password. Demo unlock instead. --%>
            <c:when test="${accountLocked}">

                <p class="login-modal__note">
                    Reset the account to unlock it and try again.
                </p>

                <%-- POST, not a link. LoginServlet only implements doPost,
                     so a GET to /login?action=reset would 405. --%>
                <form class="login-modal__form"
                      action="${pageContext.request.contextPath}/login"
                      method="post">
                    <input type="hidden" name="action" value="reset">
                    <input type="hidden" name="email" value="${fn:escapeXml(param.email)}">
                    <button type="submit" class="login-modal__submit">Reset account</button>
                </form>

            </c:when>

            <c:otherwise>

                <form class="login-modal__form"
                      id="loginForm"
                      action="${pageContext.request.contextPath}/login"
                      method="post"
                      novalidate>

                    <input type="hidden" name="redirectTo" value="${fn:escapeXml(loginRedirectTo)}">

                    <div class="login-modal__field">
                        <label for="loginEmail">Email address</label>
                        <input type="email"
                               id="loginEmail"
                               name="email"
                               value="${fn:escapeXml(param.email)}"
                               maxlength="100"
                               autocomplete="email"
                               required>
                        <p class="login-modal__field-error" id="loginEmailError"></p>
                    </div>

                    <div class="login-modal__field">
                        <label for="loginPassword">Password</label>
                        <input type="password"
                               id="loginPassword"
                               name="password"
                               autocomplete="current-password"
                               required>
                        <p class="login-modal__field-error" id="loginPasswordError"></p>
                    </div>

                    <button type="submit" class="login-modal__submit">Sign in</button>
                </form>

                <p class="login-modal__alt">
                    No account yet?
                    <a href="${pageContext.request.contextPath}/registration.jsp">Register here</a>
                </p>

            </c:otherwise>
        </c:choose>

    </div>
</div>

<script src="${pageContext.request.contextPath}/js/formValidation.js"></script>
<script src="${pageContext.request.contextPath}/js/loginModal.js" defer></script>
