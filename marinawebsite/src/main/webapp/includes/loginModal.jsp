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
    loginError        - the message to show. Its presence is what opens the modal.
    accountLocked     - TRUE only on the lockout case; swaps the Sign in form
                        for a locked-out message.
    lockoutThreshold  - how many failed attempts lock an account. Set on every
                        failed sign-in, the same value regardless of whether
                        the email is registered, so the message can't be used
                        to identify real accounts.
    loginFlashEmail   - what they typed, so the field refills. In the
                        session rather than a request parameter, because the
                        failure path redirects rather than forwarding.

  Author: Miguel Fernandez
  Blue Team - Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
  Primary Author/Owner - Miguel Fernandez
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<%--
  The failure message from LoginServlet, read once and cleared.

  It arrives in the session rather than as request attributes because the
  failure path redirects now instead of forwarding - see that servlet's
  class comment for why it had to change. A redirect drops request
  attributes, so the four values ride in the session and this is the one
  place that reads them. <c:remove> immediately afterwards is what makes it
  a flash: the error shows on the page the customer lands on and does not
  follow them around the site.
--%>
<c:set var="loginError" value="${sessionScope.loginFlashError}"/>
<c:set var="accountLocked" value="${sessionScope.loginFlashAccountLocked}"/>
<c:set var="lockoutThreshold" value="${sessionScope.loginFlashLockoutThreshold}"/>
<c:set var="loginEmail" value="${sessionScope.loginFlashEmail}"/>
<c:remove var="loginFlashError" scope="session"/>
<c:remove var="loginFlashAccountLocked" scope="session"/>
<c:remove var="loginFlashLockoutThreshold" scope="session"/>
<c:remove var="loginFlashEmail" scope="session"/>

<%--
  redirectTo has to be context-relative, because LoginServlet prepends
  getContextPath() before redirecting. So "/reservation", never
  "/marinawebsite/reservation".

  On a failed attempt the request URI is /login, not the page the user
  started on, so the submitted redirectTo is reused when it's there and
  only falls back to the current path on a first, clean render.

  The ORIGINAL URI, not the forwarded one. A servlet that forwards to its
  own JSP - ReservationServlet does exactly that for a signed-out visitor -
  leaves getRequestURI() reporting the forward's target, so this used to
  capture "/reservation.jsp" while the browser still showed "/reservation".
  Signing in then sent the customer to the raw JSP, which skips the
  servlet's doGet, so the page rendered with none of its data: "No boats
  registered" in the dropdown and reservation.js opening the Register a Boat
  panel over a customer who already owns two. Same class of bug as the
  .jsp links fixed in Module 7, arriving by a different route.

  The container stashes the real URI in jakarta.servlet.forward.request_uri
  whenever a forward has happened, so prefer that and fall back to
  getRequestURI() when it hasn't.
--%>
<c:set var="originalUri"
       value="${not empty requestScope['jakarta.servlet.forward.request_uri']
                ? requestScope['jakarta.servlet.forward.request_uri']
                : pageContext.request.requestURI}"/>
<c:set var="currentPath"
       value="${fn:substring(originalUri,
                             fn:length(pageContext.request.contextPath),
                             fn:length(originalUri))}"/>
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

        <%-- Set by LoginServlet on every failed sign-in, whether or not the
             email belongs to a real account. It has to be the same message
             either way: one that only showed for real accounts would tell an
             attacker which addresses are registered, which is the exact thing
             the generic error above is there to prevent. --%>
        <c:if test="${not empty lockoutThreshold}">
            <p class="login-modal__warning" role="status">
                Accounts are locked after <c:out value="${lockoutThreshold}"/>
                unsuccessful attempts.
            </p>
        </c:if>

        <c:choose>

            <%-- Locked out: no point offering the form, the servlet rejects
                 it before checking the password. The old demo "Unlock
                 Account" button (plain reset, no verification) is retired -
                 a locked account now unlocks itself only by completing a
                 password reset through ForgotPasswordServlet (/forgotPassword,
                 already built and working - see its class comment and the
                 Edit User Profile contract's "Password Change and the
                 Lockout Model"). The reset UI is
                 includes/forgotPasswordModal.jsp, included at the foot of
                 this file so it travels with the login modal to every page -
                 a locked-out visitor has no session, so a reset reachable
                 only from an account page would be behind the very sign-in
                 they can't complete. --%>
            <c:when test="${accountLocked}">

                <p class="login-modal__note">
                    Unlocking an account means setting a new password. We'll
                    send a verification code to the email on the account.
                </p>

                <button type="button"
                        class="login-modal__submit"
                        id="lockedResetTrigger"
                        data-email="${fn:escapeXml(loginEmail)}">
                    Reset your password
                </button>

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
                               value="${fn:escapeXml(loginEmail)}"
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

<jsp:include page="/includes/forgotPasswordModal.jsp" />

<script src="${pageContext.request.contextPath}/js/formValidation.js"></script>
<script src="${pageContext.request.contextPath}/js/loginModal.js" defer></script>
<script src="${pageContext.request.contextPath}/js/accountModals.js" defer></script>
<script>
    /* The locked-out state's only control. Wired here rather than in
       accountModals.js because the button only exists on the render where
       LoginServlet set accountLocked, and the email it carries is the one
       just typed - so the reset opens with the address already in it. */
    document.addEventListener("DOMContentLoaded", function () {
        var trigger = document.getElementById("lockedResetTrigger");
        if (!trigger) { return; }
        trigger.addEventListener("click", function () {
            MoffatBay.loginModal.close();
            MoffatBay.accountModals.openForgot(trigger.dataset.email);
        });
    });
</script>
