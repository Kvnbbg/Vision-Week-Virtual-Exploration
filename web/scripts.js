document.addEventListener("DOMContentLoaded", () => {
  const navLinks = document.querySelectorAll("nav ul li a");
  const contentScreens = document.querySelectorAll(".content-screen");
  const loginPopup = document.getElementById("loginPopup");
  const loginForm = document.getElementById("loginForm");
  const loginToggle = document.getElementById("loginToggle");
  const showSuggestionsBtn = document.getElementById("showSuggestionsBtn");
  const favoritePlaceSuggestions = document.getElementById("favoritePlaceSuggestions");
  const selectedSuggestion = document.getElementById("selectedSuggestion");
  const selectedSuggestionName = document.getElementById("selectedSuggestionName");
  const themeToggle = document.getElementById("toggleTheme");
  let isAuthenticated = false;

  setupNavLinks(navLinks, contentScreens);
  setupLoginPopup();
  setupThemeToggle();
  setupFavoritePlaces();

  function setupNavLinks(links, screens) {
    links.forEach(link => {
      link.addEventListener("click", e => {
        e.preventDefault();
        if (!isAuthenticated && link.id !== "homeLink") return;
        const targetId = link.id.replace("Link", "Screen");
        screens.forEach(screen => {
          screen.classList.toggle("active", screen.id === targetId);
        });
      });
    });
  }

  function setupLoginPopup() {
    loginToggle.addEventListener("click", () => {
      loginPopup.classList.toggle("expanded");
      loginForm.classList.toggle("hidden");
    });

    loginForm.addEventListener("submit", e => {
      e.preventDefault();
      // Simulate login process
      isAuthenticated = true;
      alert("Login successful!");
      loginPopup.style.display = "none";
    });
  }

  function setupThemeToggle() {
    themeToggle.addEventListener("click", () => {
      document.body.dataset.theme = document.body.dataset.theme === "dark" ? "light" : "dark";
    });
  }

  function setupFavoritePlaces() {
    showSuggestionsBtn.addEventListener("click", () => {
      favoritePlaceSuggestions.hidden = !favoritePlaceSuggestions.hidden;
      if (favoritePlaceSuggestions.hidden) {
        selectedSuggestionName.textContent = "";
        selectedSuggestion.style.display = "none";
      }
    });

    favoritePlaceSuggestions.addEventListener("change", () => {
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
});
