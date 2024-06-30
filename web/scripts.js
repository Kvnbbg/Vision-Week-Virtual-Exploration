/**
 * Initializes event listeners and dynamic content for the webpage once the DOM is fully loaded.
 * Initialise les écouteurs d'événements et le contenu dynamique pour la page web une fois que le DOM est complètement chargé.
 */
document.addEventListener("DOMContentLoaded", () => {
  const navLinks = document.querySelectorAll("nav ul li a");
  const contentScreens = document.querySelectorAll(".content-screen");
  const loginPopup = createPopup('login');
  const registerPopup = createPopup('register');
  const welcomePopup = createPopup('welcome');

  setupNavLinks(navLinks, contentScreens);
  setupLoginPopup(loginPopup);
  setupRegisterPopup(registerPopup);
  setupWelcomePopup(welcomePopup);
  setupThemeToggle();
  setupFavoritePlaces();

  /**
   * Sets up navigation links to switch between content screens.
   * @param {NodeList} links - The navigation links.
   * @param {NodeList} screens - The content screens.
   */
  function setupNavLinks(links, screens) {
    links.forEach(link => {
      link.addEventListener("click", e => {
        e.preventDefault();
        const targetId = link.id.replace("Link", "Screen");
        screens.forEach(screen => {
          screen.classList.toggle("active", screen.id === targetId);
        });
      });
    });
  }

  /**
   * Creates a popup element based on the specified type.
   * @param {string} type - The type of popup to create ('login', 'register', 'welcome').
   * @returns {HTMLElement} The created popup element.
   */
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

  /**
   * Returns the HTML content for the login popup.
   * @returns {string} The HTML content for the login popup.
   */
  function getLoginContent() {
    return `
      <div class="login-content">
        <div class="login-text">
          <h2>Welcome to Vision Week!</h2>
          <p>Please login to continue.</p>
          <input type="email" id="email" placeholder="Email" required />
          <input type="password" id="password" placeholder="Password" required />
          <button id="loginButton">Login</button>
          <p>Don't have an account? <a href="#" id="showRegister">Register</a></p>
        </div>
      </div>`;
  }

  /**
   * Returns the HTML content for the register popup.
   * @returns {string} The HTML content for the register popup.
   */
  function getRegisterContent() {
    return `
      <div class="register-content">
        <h2>Create an Account</h2>
        <input type="text" id="regName" placeholder="Name" required />
        <input type="email" id="regEmail" placeholder="Email" required />
        <input type="password" id="regPassword" placeholder="Password" required />
        <button id="registerButton">Register</button>
        <p>Already have an account? <a href="#" id="showLogin">Login</a></p>
      </div>`;
  }

  /**
   * Returns the HTML content for the welcome popup.
   * @returns {string} The HTML content for the welcome popup.
   */
  function getWelcomeContent() {
    return `
      <div class="welcome-content">
        <img src="https://images.pexels.com/photos/20763355/pexels-photo-20763355/free-photo-of-femme-au-lac-baikal-gele.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2" alt="Welcome Image" />
        <div class="welcome-text">
          <h2>Welcome to Vision Week!</h2>
          <p>Click anywhere to continue.</p>
          <p><small>Developed by Kvnbbg (Kevin Marville) <a href="https://x.com/techandstream">@techandstream</a> on X.com.</small></p>
        </div>
      </div>`;
  }

  /**
   * Sets up the login popup with event listeners for login and navigation to the register popup.
   * @param {HTMLElement} popup - The login popup element.
   */
  function setupLoginPopup(popup) {
    document.getElementById("loginButton").addEventListener("click", async () => {
      const email = document.querySelector("#email").value;
      const password = document.querySelector("#password").value;

      try {
        const response = await fetch("./backend/signin.php", {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ email, password }),
        });
        const data = await response.json();

        if (data.success) {
          alert("Login successful!");
          hidePopup(popup);
        } else {
          alert(`Login failed: ${data.message}`);
        }
      } catch (error) {
        console.error("Network Error:", error);
        alert("An error occurred. Please try again.");
      }
    });

    document.getElementById("showRegister").addEventListener("click", e => {
      e.preventDefault();
      hidePopup(popup);
      showPopup(registerPopup);
    });
  }

  /**
   * Sets up the register popup with event listeners for registration and navigation to the login popup.
   * @param {HTMLElement} popup - The register popup element.
   */
  function setupRegisterPopup(popup) {
    document.getElementById("registerButton").addEventListener("click", async () => {
      const name = document.querySelector("#regName").value;
      const email = document.querySelector("#regEmail").value;
      const password = document.querySelector("#regPassword").value;

      try {
        const response = await fetch("/backend/register.php", {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ name, email, password }),
        });
        const data = await response.json();

        if (data.success) {
          alert("Registration successful!");
          hidePopup(popup);
          showPopup(loginPopup);
        } else {
          alert(`Registration failed: ${data.message}`);
        }
      } catch (error) {
        console.error("Network Error:", error);
        alert("An error occurred. Please try again.");
      }
    });

    document.getElementById("showLogin").addEventListener("click", e => {
      e.preventDefault();
      hidePopup(popup);
      showPopup(loginPopup);
    });
  }

  /**
   * Sets up the welcome popup with an event listener to hide the popup on click.
   * @param {HTMLElement} popup - The welcome popup element.
   */
  function setupWelcomePopup(popup) {
    popup.addEventListener("click", () => {
      hidePopup(popup);
    });
  }

  /**
   * Sets up the theme toggle button to switch between light and dark themes.
   */
  function setupThemeToggle() {
    const toggleThemeButton = document.getElementById('toggleTheme');
    toggleThemeButton.addEventListener('click', () => {
      document.body.dataset.theme = document.body.dataset.theme === 'dark' ? 'light' : 'dark';
    });
  }

  /**
   * Sets up the favorite places functionality with event listeners for showing suggestions and selecting a suggestion.
   */
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

  /**
   * Shows the specified popup by setting its display and opacity styles.
   * @param {HTMLElement} popup - The popup element to show.
   */
  function showPopup(popup) {
    popup.style.display = "block";
    setTimeout(() => {
      popup.style.opacity = "1";
    }, 10);
  }

  /**
   * Hides the specified popup by setting its opacity and display styles.
   * @param {HTMLElement} popup - The popup element to hide.
   */
  function hidePopup(popup) {
    popup.style.opacity = "0";
    setTimeout(() => {
      popup.style.display = "none";
    }, 500)
  
})
/* This JavaScript code is setting up various functionalities for a web page when the DOM content is
fully loaded. Here's a breakdown of what the code is doing: */
document.addEventListener("DOMContentLoaded", () => {
  const navLinks = document.querySelectorAll("nav ul li a");
  const contentScreens = document.querySelectorAll(".content-screen");
  const loginPopup = createPopup('login');
  const registerPopup = createPopup('register');
  const welcomePopup = createPopup('welcome');

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
      // Add login logic here
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
