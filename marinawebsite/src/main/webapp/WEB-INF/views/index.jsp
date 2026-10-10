<!--Blue Team
Author: Carolina Rodriguez
Blue Team - Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
Primary Author/Owner - Carolina Rodriguez
Description: Provides the public landing page for the Moffat Bay Marina website. 
The page contains the main navigation, marina branding, hero section, slip and amenity highlights, 
slip pricing card with the reservation call to action, contact information, office hours, and footer navigation.
It also includes the reusable login modal and uses the application context path to ensure that stylesheets,
scripts, images, and internal links work correctly when deployed to Tomcat.
Served by LandingServlet, which sets perFootRate and electricRate from the Rate table
for the pricing card (issue #349, Miguel Fernandez).
-->

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1">

	<title>Moffat Bay Marina</title>

	<jsp:include page="/WEB-INF/includes/styles.jsp" /> <!-- Adds site.css, header.css, footer.css, loginModal.css -->
	<link rel="stylesheet" href="${pageContext.request.contextPath}/css/index.css?v=${applicationScope.assetVersion}">
</head>
<body>

	<jsp:include page="/WEB-INF/includes/header.jsp">
    <jsp:param name="activePage" value="home" />
</jsp:include>

<%-- Hero. Outside <main>, like every page's hero (see .hero-band in
     site.css), so it spans the window. --%>
<section class="hero-band" id="landingHero" aria-labelledby="landingHeroTitle">

	<div class="hero-band__content">
		<h1 id="landingHeroTitle">Your Harbor Between Horizons</h1>

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
					data-sign-in="/reservation">
					Book a Slip
				</button>
			</c:otherwise>
		</c:choose>
	</div>
	<p class="hero-band__credit">Image created with Google Gemini</p>
</section>

	<main id="main" tabindex="-1" class="landing-main">


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

		<!-- Slip pricing and reservation call to action (issue #349) -->
		<section
			class="reservation-section"
			aria-labelledby="pricingHeading">

			<div class="section-container">
				<article class="benefit-card pricing-card">
					<h2 id="pricingHeading">Slip Pricing</h2>

					<%-- Rent follows the BOAT's length, not the slip's size,
					     so each size shows the most it can cost: a boat that
					     fills the slip. The rates come from the Rate table via
					     LandingServlet; if they couldn't be read, the figures
					     are left out rather than guessed. --%>
					<c:choose>
						<c:when test="${not empty perFootRate and not empty electricRate}">

							<p class="pricing-card__lede">
								<strong><fmt:formatNumber value="${perFootRate}" type="currency" /> per foot</strong>
								of your boat's length, per month. You pay for
								your boat, not the size of the slip it sits in.
							</p>

							<ul class="pricing-grid">
								<li class="pricing-tier">
									<span class="pricing-tier__size">26 ft Slip</span>
									<span class="pricing-tier__name">Standard</span>
									<span class="pricing-tier__fits">Boats up to 26 ft</span>
									<span class="pricing-tier__price">
										Up to <strong><fmt:formatNumber value="${26 * perFootRate}" type="currency" /></strong>/mo
									</span>
								</li>
								<li class="pricing-tier">
									<span class="pricing-tier__size">40 ft Slip</span>
									<span class="pricing-tier__name">Premier</span>
									<span class="pricing-tier__fits">Boats up to 40 ft</span>
									<span class="pricing-tier__price">
										Up to <strong><fmt:formatNumber value="${40 * perFootRate}" type="currency" /></strong>/mo
									</span>
								</li>
								<li class="pricing-tier">
									<span class="pricing-tier__size">50 ft Slip</span>
									<span class="pricing-tier__name">Grand</span>
									<span class="pricing-tier__fits">Boats up to 50 ft</span>
									<span class="pricing-tier__price">
										Up to <strong><fmt:formatNumber value="${50 * perFootRate}" type="currency" /></strong>/mo
									</span>
								</li>
							</ul>

							<p class="pricing-card__extra">
								<span class="pricing-card__extra-label">Electric hookup</span>
								<strong><fmt:formatNumber value="${electricRate}" type="currency" /> a month</strong>,
								the same for any size boat.
							</p>

							<p class="pricing-card__terms">
								Month-to-month leases. 30 days' notice to leave.
							</p>

						</c:when>
						<c:otherwise>

							<p class="pricing-card__lede">
								Slip rent is charged per foot of your boat's
								length, per month. You'll see the exact price
								for your boat when you book.
							</p>

						</c:otherwise>
					</c:choose>

					<div class="pricing-card__cta">
						<h3>Ready to Reserve Your Slip?</h3>

						<%-- Someone already signed in has no use for "create an
						     account" - they have one. Same section, different
						     wording and destination. --%>
						<c:choose>
							<c:when test="${sessionScope.loggedIn}">

								<p>
									Check availability and book your spot today.
								</p>

								<a
									class="btn-action"
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
									class="btn-action"
									href="${pageContext.request.contextPath}/register">
									Create an Account
								</a>

							</c:otherwise>
						</c:choose>
					</div>
				</article>
			</div>
		</section>

		<!-- Moffat Bay Lodge -->
		<section class="lodge-section" aria-labelledby="lodgeHeading">
			<div class="section-container">
				<article class="benefit-card lodge-card">
					<figure class="lodge-card__figure">
						<img
							class="lodge-card__image"
							src="${pageContext.request.contextPath}/images/MoffatBayLodge.jpg"
							alt="Moffat Bay Lodge at dusk: a timber lodge with lit windows and balconies, stone paths and gardens, set against tall evergreens">
						<figcaption class="lodge-card__caption">
							Image created with Google Gemini
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
							class="btn-action"
							href="${pageContext.request.contextPath}/lodge.jsp">
							Visit Moffat Bay Lodge
						</a>
					</div>
				</article>
			</div>
		</section>

	</main>

	<jsp:include page="/WEB-INF/includes/footer.jsp" />

</body>
</html>