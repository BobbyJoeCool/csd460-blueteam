<!--Blue Team
Author: Carolina Rodriguez
Blue Team - Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
Primary Author/Owner - Carolina Rodriguez
Description: Provides the public landing page for the Moffat Bay Marina website. 
The page contains the main navigation, marina branding, hero section, slip and amenity highlights, 
registration call to action, contact information, office hours, and footer navigation. 
It also includes the reusable login modal and uses the application context path to ensure that stylesheets, 
scripts, images, and internal links work correctly when deployed to Tomcat.
-->

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1">

	<title>Moffat Bay Marina</title>

	<jsp:include page="/includes/styles.jsp" /> <!-- Adds site.css, header.css, footer.css, loginModal.css -->
	<link rel="stylesheet" href="${pageContext.request.contextPath}/css/index.css">
</head>
<body>

	<jsp:include page="/includes/header.jsp">
    <jsp:param name="activePage" value="home" />
</jsp:include>

	<main class="landing-main">

<!-- Hero section -->
<section class="hero-band" id="landingHero">

	<div class="hero-band__content">
		<h1>Your Harbor Between Horizons</h1>

		<p class="hero-description">
			Premier slip reservations at Moffat Bay.<br>
			Three sizes, one stunning destination.
		</p>

		<p class="hero-tagline">
			Secure your spot in paradise.
		</p>

		<%-- Signed in, the modal would be pointless - send them where the
		     button says it goes. Signed out, sign-in comes first. --%>
		<c:choose>
			<c:when test="${sessionScope.loggedIn}">
				<a
					class="btn-primary hero-cta"
					href="${pageContext.request.contextPath}/reservation">
					Book a Slip
				</a>
			</c:when>
			<c:otherwise>
				<button
					class="btn-primary hero-cta"
					type="button"
					onclick="MoffatBay.loginModal.open('/reservation')">
					Book a Slip
				</button>
			</c:otherwise>
		</c:choose>
	</div>
	<p class="hero-band__credit">Hero image created with Google Gemini</p>
</section>

		<!-- Marina benefits -->
		<section class="benefits-section" aria-labelledby="benefitsHeading">
			<div class="section-container">
				<h2 id="benefitsHeading">Why Moffat Bay?</h2>

				<div class="benefits-grid">

					<article class="benefit-card">
						<div class="benefit-icon" aria-hidden="true">
							&#9875;
						</div>

						<h3>Three Slip Sizes</h3>

						<p>
							Choose from 26 ft, 40 ft, or 50 ft slips.
							Matched automatically to your boat length
							for a perfect fit.
						</p>
					</article>

					<article class="benefit-card">
						<div class="benefit-icon" aria-hidden="true">
							&#9678;
						</div>

						<h3>Prime Location</h3>

						<p>
							Nestled in the heart of Moffat Bay, with
							direct access to open water and minutes
							from the resort.
						</p>
					</article>

					<article class="benefit-card">
						<div class="benefit-icon" aria-hidden="true">
							&#128295;
						</div>

						<h3>Full-Service Amenities</h3>

						<p>
							Fuel, shore power, fresh water, and
							pump-out service. Everything your vessel
							needs in one marina.
						</p>
					</article>

				</div>
			</div>
		</section>

		<!-- Reservation call to action -->
		<section
			class="reservation-section"
			aria-labelledby="reservationHeading">

			<div class="section-container">
				<h2 id="reservationHeading">
					Ready to Reserve Your Slip?
				</h2>

				<%-- Someone already signed in has no use for "create an
				     account" - they have one. Same section, different
				     wording and destination. --%>
				<c:choose>
					<c:when test="${sessionScope.loggedIn}">

						<p>
							Check availability and book your spot today.
						</p>

						<a
							class="btn-secondary"
							href="${pageContext.request.contextPath}/reservation">
							Book a Slip
						</a>

					</c:when>
					<c:otherwise>

						<p>
							Create an account or sign in to check availability
							and book your spot today.
						</p>

						<a
							class="btn-secondary"
							href="${pageContext.request.contextPath}/registration.jsp">
							Create an Account
						</a>

					</c:otherwise>
				</c:choose>
			</div>
		</section>

		<!-- Moffat Bay Lodge -->
		<section class="lodge-section" aria-labelledby="lodgeHeading">
			<div class="section-container">
				<article class="benefit-card lodge-card">
					<figure class="lodge-card__figure">
						<img
							class="lodge-card__image"
							src="${pageContext.request.contextPath}/images/MoffatBayLodge.png"
							alt="Moffat Bay Lodge at dusk: a timber lodge with lit windows and balconies, stone paths and gardens, set against tall evergreens">
						<figcaption class="lodge-card__caption">
							Image generated with Gemini AI.
						</figcaption>
					</figure>

					<div class="lodge-card__body">
						<h2 id="lodgeHeading">Stay Ashore at Moffat Bay Lodge</h2>

						<p>
							Just up from the docks, Moffat Bay Lodge is the
							island's new resort, with rooms from double full
							to king. Spend your days hiking, kayaking, whale
							watching, or scuba diving, then rest ashore. With
							no road to Joviedsa Island, guests arrive by water
							or by air on the island's small airstrip.
						</p>

						<a
							class="btn-secondary"
							href="${pageContext.request.contextPath}/lodge.jsp">
							Visit Moffat Bay Lodge
						</a>
					</div>
				</article>
			</div>
		</section>

	</main>

	<jsp:include page="/includes/footer.jsp" />

</body>
</html>