document.addEventListener("DOMContentLoaded", function () {
  const navLinks = document.querySelectorAll("nav ul li a");
  const contentScreens = document.querySelectorAll(".content-screen");

  // Navigation functionality with smooth transitions
  navLinks.forEach((link) => {
    link.addEventListener("click", function (e) {
      e.preventDefault();
      const targetId = this.id.replace("Link", "Screen");

      contentScreens.forEach((screen) => {
        screen.classList.toggle("active", screen.id === targetId);
      });
    });
  });

  // Login pop-up with fade-in animation
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
        console.error("Error:", error);
        alert("An error occurred. Please try again.");
      });
  });

  // Registration pop-up
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
        console.error("Error:", error);
        alert("An error occurred. Please try again.");
      });
  });

  document.getElementById("showRegister").addEventListener("click", function (e) {
    e.preventDefault();
    loginPopup.style.display = "none";
    registerPopup.style.display = "block";
  });

  document.getElementById("showLogin").addEventListener("click", function (e) {
    e.preventDefault();
    registerPopup.style.display = "none";
    loginPopup.style.display = "block";
  });

  // Welcome pop-up with fade-out animation
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

  welcomePopup.addEventListener("click", function () {
    welcomePopup.style.transition = "opacity 0.5s ease";
    welcomePopup.style.opacity = "0";
    setTimeout(() => {
      welcomePopup.style.display = "none";
    }, 500);
  });

  // Show suggestions for favorite place
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
});
