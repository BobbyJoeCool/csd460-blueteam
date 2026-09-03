<header class="site-header">
   <div class="header-brand">
    <a class="logo" href="${pageContext.request.contextPath}/">
        <img
            src="${pageContext.request.contextPath}/images/AnchorLogo.png"
            alt="">
        <span>Moffat Bay Marina</span>
    </a>
</div>

    <nav class="header-nav" aria-label="Main navigation">
        <a href="${pageContext.request.contextPath}/index.jsp"
        class="${param.activePage == 'home' ? 'nav-active' : ''}">Home</a>
        <a href="#"
        class="${param.activePage == 'about' ? 'nav-active' : ''}">About Us</a>
        <a href="#"
        class="${param.activePage == 'reservation' ? 'nav-active' : ''}">Reservations</a>
        <a href="#"
        class="${param.activePage == 'contact' ? 'nav-active' : ''}">Contact</a>

        <button type="button"
            class="nav-cta"
            onclick="MoffatBay.loginModal.open()">Log In
        </button>
    </nav>
</header>


