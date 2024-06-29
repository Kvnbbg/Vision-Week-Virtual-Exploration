/**
 * Initializes event listeners and dynamic content for the webpage once the DOM is fully loaded.
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

  function setupWelcomePopup(popup) {
    popup.addEventListener("click", () => {
      hidePopup(popup);
    });
  }

  function setupThemeToggle() {
    const toggleThemeButton = document.getElementById('toggleTheme');
    toggleThemeButton.addEventListener('click', () => {
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
