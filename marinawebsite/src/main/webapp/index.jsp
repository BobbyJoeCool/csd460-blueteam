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

	<jsp:include page="/includes/styles.jsp" />

	<link rel="stylesheet" href="${pageContext.request.contextPath}/css/index.css">
</head>
<body>

	<jsp:include page="/includes/header.jsp">
    <jsp:param name="activePage" value="home" />
</jsp:include>

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

	<jsp:include page="/includes/footer.jsp" />

	<!-- Reusable login modal -->
	<jsp:include page="/includes/loginModal.jsp" />

	<script src="${pageContext.request.contextPath}/js/loginModal.js"></script>

</body>
</html>