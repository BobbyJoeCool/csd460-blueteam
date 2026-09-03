<!--Blue Team
Author: Carolina Rodriguez
Description: Provides the public landing page for the Moffat Bay Marina website. 
The page contains the main navigation, marina branding, hero section, slip and amenity highlights, 
registration call to action, contact information, office hours, and footer navigation. 
It also includes the reusable login modal and uses the application context path to ensure that stylesheets, 
scripts, images, and internal links work correctly when deployed to Tomcat.
-->

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1">

	<title>Moffat Bay Marina</title>

	<link rel="stylesheet" href="${pageContext.request.contextPath}/css/variables.css">
	<link rel="stylesheet" href="${pageContext.request.contextPath}/css/loginModal.css">
	<link rel="stylesheet" href="${pageContext.request.contextPath}/css/landingPage.css">
</head>
<body>

	<!-- Header / navigation -->
	<header class="site-header">
        <a class="logo" href="${pageContext.request.contextPath}/">
            <img
                src="${pageContext.request.contextPath}/images/AnchorLogo.png"
                alt="">
            <span>Moffat Bay Marina</span>
        </a>

		<nav class="site-nav" aria-label="Main navigation">
			<a class="active" href="${pageContext.request.contextPath}/">
				Home
			</a>

			<a href="${pageContext.request.contextPath}/contact">
				Contact Us

			</a>

			<a href="${pageContext.request.contextPath}/lookupReservation">
				Look Up Reservation 
			</a>



			<button
				class="nav-cta"
				type="button"
				onclick="MoffatBay.loginModal.open()">
				Login / Register
			</button>
		</nav>
	</header>

	<main class="landing-main">

<!-- Hero section -->
<section
	class="hero-section"
	style="
		background-image:
			linear-gradient(
				rgba(13, 59, 77, 0.22),
				rgba(13, 59, 77, 0.32)
			),
			url('${pageContext.request.contextPath}/images/Marina.png');
	">

	<div class="hero-content">
		<h1>Your Harbor Between Horizons</h1>

		<p class="hero-description">
			Premier slip reservations at Moffat Bay.<br>
			Three sizes, one stunning destination.
		</p>

		<p class="hero-tagline">
			Secure your spot in paradise.
		</p>

		<button
			class="btn-primary hero-cta"
			type="button"
			onclick="MoffatBay.loginModal.open()">
			Reserve a Slip
		</button>
	</div>
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

				<p>
					Create an account or sign in to check availability
					and book your spot today.
				</p>

				<a
					class="btn-secondary"
					href="${pageContext.request.contextPath}/registration.jsp">
					Create an Account
				</a>
			</div>
		</section>

	</main>

	<!-- Footer -->
	
	<footer class="site-footer">
		<div class="footer-columns">

			<section class="footer-contact">
				<h2>Moffat Bay Marina</h2>

				<address>
					<p>123 Marina Drive</p>
					<p>Moffat Bay, WA 32000</p>
					<p>
						<a href="tel:5551234567">
							(555) 123-4567
						</a>
					</p>
				</address>
			</section>

			<section class="footer-hours">
				<h2>Office Hours</h2>

				<p>Mon&ndash;Fri: 7 am &ndash; 7 pm</p>
				<p>Sat&ndash;Sun: 6 am &ndash; 8 pm</p>

				<h2 class="self-service-heading">
					Self-Service Marina<br>
					Open 24hrs.
				</h2>
			</section>

			<nav class="footer-links" aria-label="Footer navigation">
				<h2>Quick Links</h2>

				<a href="${pageContext.request.contextPath}/">
					Home
				</a>

				<a href="${pageContext.request.contextPath}/">
					Contact Us
				</a>

				<button
					type="button"
					onclick="MoffatBay.loginModal.open()">
					Reserve a Slip
				</button>
			</nav>

		</div>

		<div class="footer-bottom">
			<p>
				&copy; 2026 Moffat Bay Marina. All rights reserved.
			</p>
		</div>
	</footer>

	<!-- Reusable login modal -->
	<jsp:include page="/includes/loginModal.jsp" />

	<script src="${pageContext.request.contextPath}/js/loginModal.js"></script>

</body>
</html>