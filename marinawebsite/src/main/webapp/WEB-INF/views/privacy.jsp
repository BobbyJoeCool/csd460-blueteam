<%--
  src/main/webapp/WEB-INF/views/privacy.jsp

  Privacy Policy (issue #335). Reached at /privacy (PrivacyServlet).

  Says what the site keeps, why, for how long and who sees it, so it has
  to stay true to the code. If any of these change, change this page too:
    - the Customer, Boat, BoatOwnership, Reservation, TerminationNotice,
      WaitList and Contact columns (what we collect)
    - JSESSIONID being the only cookie, and nothing in browser storage
      (the cookies section; see the #313 audit)
    - what AccountDeleteServlet clears and what it keeps (deleting your
      account)
    - what AccountDataServlet puts in the download (getting a copy)

  Linked from the footer and from under Create Account on Registration.

  Author: Miguel Fernandez
  Blue Team - Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
  Primary Author/Owner - Miguel Fernandez
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Privacy Policy - Moffat Bay Marina</title>

    <jsp:include page="/WEB-INF/includes/styles.jsp" />
    <link rel="stylesheet" href="${ctx}/css/policy.css?v=${applicationScope.assetVersion}">
</head>
<body>

<jsp:include page="/WEB-INF/includes/header.jsp" />

<header class="hero-band" id="privacyHero">
    <div class="hero-band__content">
        <h1>Privacy Policy</h1>
        <p class="hero-band__lede">What we keep about you, why, and how to get it back or have it removed.</p>
    </div>
    <p class="hero-band__credit">Image created with Google Gemini</p>
</header>

<main class="page-column policy-page">

    <p class="policy-updated">Last updated October 2, 2026</p>

    <section aria-labelledby="summaryHeading">
        <h2 id="summaryHeading">The short version</h2>
        <ul>
            <li>We only collect what we need to rent you a slip and keep in touch about it.</li>
            <li>We don't sell your information, show you ads, or track you on other websites.</li>
            <li>The site uses one cookie, and only to keep you signed in.</li>
            <li>You can download a copy of everything in your account, or delete it, from
                <a href="${ctx}/editProfile">Your Account</a>.</li>
        </ul>
    </section>

    <section aria-labelledby="collectHeading">
        <h2 id="collectHeading">What we collect</h2>

        <h3>When you create an account</h3>
        <p>
            Your name, email address, phone number and mailing address. Your
            password is never stored as you typed it. We keep a scrambled
            (hashed) version that can check a password but can't be turned
            back into one.
        </p>

        <h3>When you add a boat</h3>
        <p>
            Its name, type, length, beam and year, plus its Hull
            Identification Number and registration number if you give them.
            We also record when the boat joined your fleet and when it left.
        </p>

        <h3>When you book a slip or join the wait list</h3>
        <p>
            Which boat, which slip, the start date, the monthly rate and
            whether you chose electric hookup. If you give 30 days' notice,
            we record the date you gave it and your last day. For the wait
            list, we record the slip size you asked for and when you joined,
            which is what decides your place in line.
        </p>

        <h3>When you send us a message</h3>
        <p>
            The name, email address and message you type into the contact
            form on <a href="${ctx}/about#formHeading">About Us</a>, plus your
            boat's name and length if you give them. You don't need an
            account to send one.
        </p>

        <h3>When you sign in</h3>
        <p>
            How many times in a row a sign-in has failed, so we can lock the
            account after three wrong passwords. The count goes back to zero
            when you sign in successfully.
        </p>
    </section>

    <section aria-labelledby="useHeading">
        <h2 id="useHeading">Why we use it</h2>
        <ul>
            <li>To hold your reservation, assign your slip and work out what you owe.</li>
            <li>To keep your place on the wait list and contact you when a slip opens.</li>
            <li>To answer your messages.</li>
            <li>To check that a boat fits its slip, and to know whose boat is at the dock.</li>
            <li>To protect your account from someone guessing your password.</li>
        </ul>
        <p>We don't use your information for marketing, and we don't make automated decisions about you with it.</p>
    </section>

    <section aria-labelledby="shareHeading">
        <h2 id="shareHeading">Who sees it</h2>
        <p>
            Marina office staff, and only to do the things listed above. We
            don't sell or rent your information to anyone. We would only
            share it if the law required us to, for example to answer a
            court order, or with emergency services if your boat or someone
            aboard it were in danger.
        </p>
    </section>

    <section aria-labelledby="keepHeading">
        <h2 id="keepHeading">How long we keep it</h2>
        <ul>
            <li><strong>Your account</strong> is kept for as long as it's open.</li>
            <li><strong>Reservations and 30-day notices</strong> are kept for seven
                years after the lease ends, because they're part of the marina's
                financial records. If you delete your account, these records stay
                but no longer carry your name or contact details.</li>
            <li><strong>Wait list entries</strong> are kept after they close, so the
                order of the list can always be checked.</li>
            <li><strong>Messages sent through the contact form</strong> are kept for
                two years after we've answered them.</li>
        </ul>
    </section>

    <section aria-labelledby="cookieHeading">
        <h2 id="cookieHeading">Cookies</h2>
        <p>
            The site sets one cookie, <code>JSESSIONID</code>. It keeps you
            signed in as you move from page to page, and it's strictly
            necessary, which is why we don't ask before setting it. It holds
            a random code, not your name or password. It's deleted when you
            close your browser, and it stops working after 30 minutes without
            a click or when you log out.
        </p>
        <p>
            There are no advertising or analytics cookies. Nothing on this
            site loads from another company's servers, and nothing is saved
            in your browser's storage. Because we don't track you across
            websites, a browser's "Do Not Track" setting doesn't change
            anything here.
        </p>
    </section>

    <section aria-labelledby="rightsHeading">
        <h2 id="rightsHeading">Getting a copy, making changes, or deleting your account</h2>
        <p>Signed in, you can do all of this yourself from <a href="${ctx}/editProfile">Your Account</a>:</p>
        <ul>
            <li><strong>Correct your details.</strong> Change your name, contact details or
                address, and edit your boats on <a href="${ctx}/myFleet">My Fleet</a>.</li>
            <li><strong>Download your data.</strong> Get a file with everything we hold
                in your account: your details, your boats, your reservations and
                notices, your wait list entries, and any messages sent through the
                contact form from your account's email address.</li>
            <li><strong>Delete your account.</strong> We remove your name, email, phone
                number and address straight away, take your boats out of your
                fleet and take you off the wait list. Reservation records are kept
                without your name, as described above. You can't delete your
                account while you have a current or upcoming reservation. Cancel
                it or give 30 days' notice first, and you can delete your account
                once the lease has ended.</li>
        </ul>
        <p>
            If you can't sign in, or you sent us a message from a different
            email address, contact the office using the details below. We'll answer within 30
            days, and we may ask you to confirm who you are first.
        </p>
    </section>

    <section aria-labelledby="securityHeading">
        <h2 id="securityHeading">Keeping it safe</h2>
        <p>
            Passwords are stored only in scrambled form. Pages showing your
            account aren't saved by your browser, so the Back button can't
            bring them up after you log out on a shared computer. Changing
            your password signs you out everywhere else. Even so, no website
            can promise perfect security, so please use a password you don't
            use anywhere else.
        </p>
    </section>

    <section aria-labelledby="childrenHeading">
        <h2 id="childrenHeading">Children</h2>
        <p>
            Slip leases are for adults, and the site isn't meant for anyone
            under 18. We don't knowingly collect information from children.
            If you think a child has created an account, contact us and
            we'll delete it.
        </p>
    </section>

    <section aria-labelledby="changesHeading">
        <h2 id="changesHeading">Changes to this policy</h2>
        <p>
            If we change what we collect or how we use it, we'll update this
            page and the date at the top. If a change affects information
            we already hold about you, we'll tell you by email first.
        </p>
    </section>

    <section aria-labelledby="privacyContactHeading">
        <h2 id="privacyContactHeading">Questions</h2>
        <address class="policy-contact">
            Moffat Bay Marina<br>
            <c:out value="${marina.street}"/><br>
            <c:out value="${marina.cityStateZip}"/><br>
            Phone: <a href="${fn:escapeXml(marina.phoneLink)}"><c:out value="${marina.phone}"/></a><br>
            Email: <a href="mailto:${fn:escapeXml(marina.email)}"><c:out value="${marina.email}"/></a>
        </address>
    </section>

</main>

<jsp:include page="/WEB-INF/includes/footer.jsp" />

</body>
</html>
