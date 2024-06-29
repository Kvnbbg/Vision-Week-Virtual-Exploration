/**
 * Initializes event listeners and dynamic content for the webpage once the DOM is fully loaded.
 */
document.addEventListener("DOMContentLoaded", function () {
  /**
   * Navigation links and content screens.
   */
  const navLinks = document.querySelectorAll("nav ul li a");
  const contentScreens = document.querySelectorAll(".content-screen");

  /**
   * Adds click event listeners to navigation links to toggle active content screens.
   */
  navLinks.forEach((link) => {
    link.addEventListener("click", function (e) {
      e.preventDefault();
      const targetId = this.id.replace("Link", "Screen");

      contentScreens.forEach((screen) => {
        screen.classList.toggle("active", screen.id === targetId);
      });
    });
  });

  /**
   * Creates and appends the login popup to the document body.
   */
  const loginPopup = document.createElement("div");
  loginPopup.className = "login-popup";
  loginPopup.innerHTML = `
    <div class="login-content">
      <img src="https://images.pexels.com/photos/20763355/pexels-photo-20763355/free-photo-of-femme-au-lac-baikal-gele.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2" alt="Login Image" />
      <div class="login-text">
        <h2>Welcome to Vision Week!</h2>
        <p>Please login to continue.</p>
        <input type="email" id="email" placeholder="Email" required />
        <input type="password" id="password" placeholder="Password" required />
        <button id="loginButton">Login</button>
        <p>Don't have an account? <a href="#" id="showRegister">Register</a></p>
      </div>
    </div>
  `;
  document.body.appendChild(loginPopup);

  loginPopup.style.transition = "opacity 0.5s ease";
  loginPopup.style.opacity = "1";

  /**
   * Adds click event listener to the login button to handle user login.
   */
  document.getElementById("loginButton").addEventListener("click", function () {
    const email = document.querySelector("#email").value;
    const password = document.querySelector("#password").value;

    fetch("signin.php", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ email, password }),
    })
      .then((response) => response.json())
      .then((data) => {
        if (data.success) {
          alert("Login successful!");
          loginPopup.style.opacity = "0";
          setTimeout(() => {
            loginPopup.style.display = "none";
          }, 500);
        } else {
          alert("Login failed: " + data.message);
        }
      })
      .catch((error) => {
        console.error("Network Error:", error);
        alert("An error occurred. Please try again.");
      });
  });

  /**
   * Creates and appends the registration popup to the document body.
   */
  const registerPopup = document.createElement("div");
  registerPopup.className = "register-popup";
  registerPopup.innerHTML = `
    <div class="register-content">
      <h2>Create an Account</h2>
      <input type="text" id="regName" placeholder="Name" required />
      <input type="email" id="regEmail" placeholder="Email" required />
      <input type="password" id="regPassword" placeholder="Password" required />
      <button id="registerButton">Register</button>
      <p>Already have an account? <a href="#" id="showLogin">Login</a></p>
    </div>
  `;
  registerPopup.style.display = "none";
  document.body.appendChild(registerPopup);

  /**
   * Adds click event listener to the register button to handle user registration.
   */
  document.getElementById("registerButton").addEventListener("click", function () {
    const name = document.querySelector("#regName").value;
    const email = document.querySelector("#regEmail").value;
    const password = document.querySelector("#regPassword").value;

    fetch("register.php", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ name, email, password }),
    })
      .then((response) => response.json())
      .then((data) => {
        if (data.success) {
          alert("Registration successful!");
          registerPopup.style.display = "none";
          loginPopup.style.display = "block";
        } else {
          alert("Registration failed: " + data.message);
        }
      })
      .catch((error) => {
        console.error("Network Error:", error);
        alert("An error occurred. Please try again.");
      });
  });

  /**
   * Adds click event listener to show the registration popup.
   */
  document.getElementById("showRegister").addEventListener("click", function (e) {
    e.preventDefault();
    loginPopup.style.display = "none";
    registerPopup.style.display = "block";
  });

  /**
   * Adds click event listener to show the login popup.
   */
  document.getElementById("showLogin").addEventListener("click", function (e) {
    e.preventDefault();
    registerPopup.style.display = "none";
    loginPopup.style.display = "block";
  });

  /**
   * Creates and appends the welcome popup to the document body.
   */
  const welcomePopup = document.createElement("div");
  welcomePopup.className = "welcome-popup";
  welcomePopup.innerHTML = `
    <div class="welcome-content">
      <img src="https://images.pexels.com/photos/20763355/pexels-photo-20763355/free-photo-of-femme-au-lac-baikal-gele.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2" alt="Welcome Image" />
      <div class="welcome-text">
        <h2>Welcome to Vision Week!</h2>
        <p>Click anywhere to continue.</p>
        <p><small>Developed by Kvnbbg (Kevin Marville) <a href="https://x.com/techandstream">@techandstream</a> on X.com.</small></p>
      </div>
    </div>
  `;
  document.body.appendChild(welcomePopup);

  /**
   * Adds click event listener to hide the welcome popup.
   */
  welcomePopup.addEventListener("click", function () {
    welcomePopup.style.transition = "opacity 0.5s ease";
    welcomePopup.style.opacity = "0";
    setTimeout(() => {
      welcomePopup.style.display = "none";
    }, 500);
  });

  /**
   * Elements for favorite place suggestions.
   */
  const showSuggestionsBtn = document.getElementById("showSuggestionsBtn");
  const favoritePlaceSuggestions = document.getElementById("favoritePlaceSuggestions");
  const selectedSuggestion = document.getElementById("selectedSuggestion");
  const selectedSuggestionName = document.getElementById("selectedSuggestionName");

  /**
   * Adds click event listener to toggle the visibility of favorite place suggestions.
   */
  showSuggestionsBtn?.addEventListener("click", () => {
    favoritePlaceSuggestions.hidden = !favoritePlaceSuggestions.hidden;
    if (favoritePlaceSuggestions.hidden) {
      selectedSuggestionName.textContent = "";
      selectedSuggestion.style.display = "none";
    }
  });

  /**
   * Adds change event listener to update the selected suggestion display.
   */
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
});
