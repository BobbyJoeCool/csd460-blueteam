<header class="header">
    <div class="header-brand">
        Moffat Bay Marina
    </div>

    <nav class="header-nav">
    <a href="index.jsp"
       class="${param.activePage == 'home' ? 'nav-active' : ''}">Home</a>
    <a href="#"
       class="${param.activePage == 'about' ? 'nav-active' : ''}">About Us</a>
    <a href="#"
       class="${param.activePage == 'reservation' ? 'nav-active' : ''}">Reservations</a>
    <a href="#"
       class="${param.activePage == 'contact' ? 'nav-active' : ''}">Contact</a>

        <button type="button"
                onclick="MoffatBay.loginModal.open()">
            Log In
        </button>
    </nav>
</header>

<jsp:include page="/includes/loginModal.jsp" />

