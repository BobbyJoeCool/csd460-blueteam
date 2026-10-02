<%--
  src/main/webapp/WEB-INF/includes/loginModal.jsp

  The Login modal from the Login contract. Included by any page that offers
  a Log In control; it renders hidden until something opens it.

  Two ways it opens:
    1. A user clicks a Log In control - MoffatBay.loginModal.open() in
       loginModal.js. That includes the Sign In button on a customer-only
       page's signed-out view (WEB-INF/includes/signInPanel.jsp).
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

<%-- The site's shared .modal (site.css), opened and closed through
     js/modal.js like every other popup - the backdrop, the x and Escape all
     close it there. Rendered without `hidden` when the server wants it open
     on arrival (a failed attempt). --%>
<div class="modal login-modal"
     id="loginModal"
     role="dialog"
     aria-modal="true"
     aria-labelledby="loginModalTitle"
     <c:if test="${empty loginError}">hidden</c:if>>

    <button type="button" class="modal__backdrop" data-modal-close
            aria-label="Close sign in" tabindex="-1"></button>

    <div class="modal__box modal__box--narrow">

        <div class="modal__header">
            <h2 class="modal__title" id="loginModalTitle">Sign in</h2>
            <button type="button" class="modal__close" data-modal-close
                    aria-label="Close sign in">&times;</button>
        </div>

        <%-- A banner, not a field message: a failed sign-in is about the
             whole form (see "Telling the customer what happened" in
             Templates/pageTemplate.jsp). --%>
        <c:if test="${not empty loginError}">
            <p class="form-banner login-modal__banner" role="alert">
                <c:out value="${loginError}"/>
            </p>
        </c:if>

        <%-- Set by LoginServlet on every failed sign-in, whether or not the
             email belongs to a real account. It has to be the same message
             either way: one that only showed for real accounts would tell an
             attacker which addresses are registered, which is the exact thing
             the generic error above is there to prevent. --%>
        <c:if test="${not empty lockoutThreshold}">
            <p class="callout-badge login-modal__banner" role="status">
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
                 WEB-INF/includes/forgotPasswordModal.jsp, included at the foot of
                 this file so it travels with the login modal to every page -
                 a locked-out visitor has no session, so a reset reachable
                 only from an account page would be behind the very sign-in
                 they can't complete. --%>
            <c:when test="${accountLocked}">

                <p class="modal__note login-modal__note">
                    Unlocking an account means setting a new password. We'll
                    send a verification code to the email on the account.
                </p>

                <button type="button"
                        class="btn-primary login-modal__submit"
                        id="lockedResetTrigger"
                        data-forgot-trigger
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
                    <jsp:include page="/WEB-INF/includes/csrfField.jsp" />

                    <input type="hidden" name="redirectTo" value="${fn:escapeXml(loginRedirectTo)}">

                    <div class="form-group">
                        <label for="loginEmail">Email address</label>
                        <input type="email"
                               id="loginEmail"
                               name="email"
                               value="${fn:escapeXml(loginEmail)}"
                               maxlength="100"
                               autocomplete="email"
                               required>
                        <p class="field-error" id="loginEmailError"></p>
                    </div>

                    <div class="form-group">
                        <label for="loginPassword">Password</label>
                        <input type="password"
                               id="loginPassword"
                               name="password"
                               autocomplete="current-password"
                               required>
                        <p class="field-error" id="loginPasswordError"></p>
                    </div>

                    <%-- A button, not a link: it opens the reset popup rather
                         than going anywhere. type="button" so it can't submit
                         the sign-in form. Wired by the script at the foot of
                         this file, together with the locked-out button. --%>
                    <p class="login-modal__forgot">
                        <button type="button" class="login-modal__link" data-forgot-trigger>
                            Forgot password?
                        </button>
                    </p>

                    <button type="submit" class="btn-primary login-modal__submit">Sign In</button>
                </form>

                <%-- Carries the same return page as the sign-in form, so
                     registering lands where signing in would have (Book a
                     Slip, My Reservations, ...). <c:url> adds the context
                     path and URL-encodes the value. loginModal.js's open()
                     rewrites it along with the hidden fields when a
                     control opens the modal for somewhere else. --%>
                <c:url var="registerUrl" value="/register">
                    <c:param name="redirectTo" value="${loginRedirectTo}"/>
                </c:url>
                <p class="login-modal__alt">
                    No account yet?
                    <a href="${fn:escapeXml(registerUrl)}" id="loginRegisterLink">Register here</a>
                </p>

            </c:otherwise>
        </c:choose>

    </div>
</div>

<jsp:include page="/WEB-INF/includes/forgotPasswordModal.jsp" />


<script src="${pageContext.request.contextPath}/js/formValidation.js?v=${applicationScope.assetVersion}"></script>
<script src="${pageContext.request.contextPath}/js/loginModal.js?v=${applicationScope.assetVersion}" defer></script>
<script src="${pageContext.request.contextPath}/js/accountModals.js?v=${applicationScope.assetVersion}" defer></script>
