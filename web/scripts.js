document.addEventListener("DOMContentLoaded", () => {
  const navLinks = document.querySelectorAll("nav ul li a");
  const contentScreens = document.querySelectorAll(".content-screen");
  const loginPopup = createPopup('login');
  const registerPopup = createPopup('register');
  const welcomePopup = createPopup('welcome');
  let isAuthenticated = false;

  setupNavLinks(navLinks, contentScreens);
  setupLoginPopup(loginPopup);
  setupRegisterPopup(registerPopup);
  setupWelcomePopup(welcomePopup);
  setupThemeToggle();
  setupFavoritePlaces();

  function setupNavLinks(links, screens) {
    links.forEach(link => {
      link.addEventListener("click", e => {
        e.preventDefault();
        if (!isAuthenticated && !link.id.includes("homeLink")) return;
        const targetId = link.id.replace("Link", "Screen");
        screens.forEach(screen => {
          screen.classList.toggle("active", screen.id === targetId);
        });
      });
    });
  }

  function createPopup(type) {
    const popup = document.createElement("div");
    popup.className = `${type}-popup`;
    if (type === 'login') {
      popup.innerHTML = getLoginContent();
    } else if (type === 'register') {
      popup.innerHTML = getRegisterContent();
      popup.style.display = "none";
    } else if (type === 'welcome') {
      popup.innerHTML = getWelcomeContent();
    }
    document.body.appendChild(popup);
    return popup;
  }

  function getLoginContent() {
    return `
      <div class="login-content">
        <h2>Login</h2>
        <input type="email" placeholder="Email" required />
        <input type="password" placeholder="Password" required />
        <button id="loginButton">Login</button>
        <p>Don't have an account? <a href="#" id="showRegister">Register</a></p>
      </div>`;
  }

  function getRegisterContent() {
    return `
      <div class="register-content">
        <h2>Create an Account</h2>
        <input type="text" placeholder="Name" required />
        <input type="email" placeholder="Email" required />
        <input type="password" placeholder="Password" required />
        <button id="registerButton">Register</button>
        <p>Already have an account? <a href="#" id="showLogin">Login</a></p>
      </div>`;
  }

  function setupLoginPopup(popup) {
    document.getElementById("loginButton").addEventListener("click", async () => {
      // Add authentication logic here
      // If successful, set isAuthenticated to true
      isAuthenticated = true;
      alert("Login successful!");
      hidePopup(popup);
    });

    document.getElementById("showRegister").addEventListener("click", e => {
      e.preventDefault();
      hidePopup(popup);
      showPopup(registerPopup);
    });
  }

  function setupRegisterPopup(popup) {
    document.getElementById("registerButton").addEventListener("click", async () => {
      // Add registration logic here
      alert("Registration successful!");
      hidePopup(popup);
      showPopup(loginPopup);
    });

    document.getElementById("showLogin").addEventListener("click", e => {
      e.preventDefault();
      hidePopup(popup);
      showPopup(loginPopup);
    });
  }

  function setupWelcomePopup(popup) {
    popup.addEventListener("click", () => {
      hidePopup(popup);
    });
  }

  function setupThemeToggle() {
    document.getElementById('toggleTheme').addEventListener('click', () => {
      document.body.dataset.theme = document.body.dataset.theme === 'dark' ? 'light' : 'dark';
    });
  }

  function setupFavoritePlaces() {
    const showSuggestionsBtn = document.getElementById("showSuggestionsBtn");
    const favoritePlaceSuggestions = document.getElementById("favoritePlaceSuggestions");
    const selectedSuggestion = document.getElementById("selectedSuggestion");
    const selectedSuggestionName = document.getElementById("selectedSuggestionName");

    showSuggestionsBtn?.addEventListener("click", () => {
      favoritePlaceSuggestions.hidden = !favoritePlaceSuggestions.hidden;
      if (favoritePlaceSuggestions.hidden) {
        selectedSuggestionName.textContent = "";
        selectedSuggestion.style.display = "none";
      }
    });

    favoritePlaceSuggestions?.addEventListener("change", () => {
      const selectedOption = favoritePlaceSuggestions.value;
      if (selectedOption) {
        selectedSuggestionName.textContent = favoritePlaceSuggestions.options[favoritePlaceSuggestions.selectedIndex].text;
        selectedSuggestion.style.display = "block";
      } else {
        selectedSuggestionName.textContent = "";
        selectedSuggestion.style.display = "none";
      }
    });
  }

  function showPopup(popup) {
    popup.style.display = "block";
    setTimeout(() => {
      popup.style.opacity = "1";
    }, 10);
  }

  function hidePopup(popup) {
    popup.style.opacity = "0";
    setTimeout(() => {
      popup.style.display = "none";
    }, 500);
  }
});
