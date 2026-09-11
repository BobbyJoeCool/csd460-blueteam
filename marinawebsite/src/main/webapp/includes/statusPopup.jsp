<%--
  src/main/webapp/includes/statusPopup.jsp

  The shared status popup - the small "that worked" message that slides in,
  waits about five seconds, and takes itself away. Included by header.jsp,
  so every page on the site has one without doing anything.

  What it is for: confirmations only. Logged in, logged out, account
  created, boat saved. Errors do NOT go through here - an error has to stay
  on screen until it is dealt with, and sit next to whatever is wrong.

  Two ways a message gets in:
    1. After a page load, from a keyword in the address bar
       (?notice=loggedIn). statusPopup.js maps the keyword to wording.
    2. Straight from a page, with no reload:
           MoffatBay.statusPopup.show("Boat saved");
       Shaped like MoffatBay.loginModal.open(), which is already how a page
       asks the shared header to do something.

  Author: Robert Breutzmann
  Blue Team - Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
  Primary Author/Owner - Robert Breutzmann
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<div id="statusPopupRegion" class="status-popup-region" role="status"></div>

<script src="${pageContext.request.contextPath}/js/statusPopup.js"></script>
