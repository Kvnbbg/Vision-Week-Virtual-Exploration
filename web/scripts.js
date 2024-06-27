document.addEventListener("DOMContentLoaded", function () {
  const navLinks = document.querySelectorAll("nav ul li a");
  const contentScreens = document.querySelectorAll(".content-screen");

  // Navigation functionality with smooth transitions
  navLinks.forEach((link) => {
    link.addEventListener("click", function (e) {
      e.preventDefault();
      const targetId = this.id.replace("Link", "Screen");

      contentScreens.forEach((screen) => {
        if (screen.id === targetId) {
          screen.classList.add("active");
        } else {
          screen.classList.remove("active");
        }
      });
    });
  });

  // Welcome pop-up feature with fade-out animation
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
    setTimeout(() => (welcomePopup.style.display = "none"), 500);
  });

  // Pop-up feature
  const popUps = document.querySelectorAll(".pop-up");
  popUps.forEach((popUp) => {
    popUp.addEventListener("click", function () {
      alert(
        "You clicked on a pop-up element! Developed by Kvnbbg (Kevin Marville) @techandstream on X.com."
      );
    });
  });

  // Show suggestions for favorite place
  const showSuggestionsBtn = document.getElementById("showSuggestionsBtn");
  const favoritePlaceSuggestions = document.getElementById(
    "favoritePlaceSuggestions"
  );
  const selectedSuggestion = document.getElementById("selectedSuggestion");
  const selectedSuggestionName = document.getElementById(
    "selectedSuggestionName"
  );

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
      selectedSuggestionName.textContent =
        favoritePlaceSuggestions.options[
          favoritePlaceSuggestions.selectedIndex
        ].text;
      selectedSuggestion.style.display = "block";
    } else {
      selectedSuggestionName.textContent = "";
      selectedSuggestion.style.display = "none";
    }
  });

  // Open design thinking quiz
  // document.getElementById("startQuizBtn").addEventListener("click", openDesignThinkingQuiz);
});

function openDesignThinkingQuiz() {
  const content = `
    <h2>Design Thinking Quiz</h2>
    <p>Test your knowledge of design thinking!</p>
    <ol>
      <li>What is the first stage of design thinking that focuses on understanding users?</li>
      <ul>
        <li><input type="radio" name="q1" value="A. Design"> (A) Design</li>
        <li><input type="radio" name="q1" value="B. Empathize"> (B) Empathize</li>
        <li><input type="radio" name="q1" value="C. Prototype"> (C) Prototype</li>
      </ul>
      <li>What does the process of brainstorming ideas involve?</li>
      <ul>
        <li><input type="radio" name="q2" value="A. User testing"> (A) User testing</li>
        <li><input type="radio" name="q2" value="B. Ideate"> (B) Ideate</li>
        <li><input type="radio" name="q2" value="C. Define"> (C) Define</li>
      </ul>
    </ol>
    <button onclick="submitAnswers()">Submit Answers</button>
  `;

  const popup = window.open("", "designThinkingQuiz", "width=400,height=400");
  popup.document.write(content);
  popup.document.close();
}

function submitAnswers() {
  const popup = window.open("", "designThinkingQuiz", "width=400,height=400");
  const answer1 = popup.document.querySelector('input[name="q1"]:checked')
    .value;
  const answer2 = popup.document.querySelector('input[name="q2"]:checked')
    .value;

  let designThinkingData;
  try {
    designThinkingData = JSON.parse(localStorage.getItem("design_thinking"));
  } catch (error) {
    designThinkingData = {};
  }

  designThinkingData.quizResults = {
    question1: answer1,
    question2: answer2
  };

  localStorage.setItem("design_thinking", JSON.stringify(designThinkingData));

  popup.close();
  alert("Thank you for taking the quiz! Your answers have been stored.");
}

// Index page functionality
fetch('./database/animals_saved.php')
    .then(response => response.json())
/**
 * Updates the text content of the HTML element with the ID 'animalsSaved'
 * to display the number of animals saved.
 *
 * @param {Object} data - The data object containing the number of animals saved.
 * @param {number} data.animals_saved - The number of animals saved.
 */
/**
 * Updates the text content of the HTML element with the ID 'animalsSaved'
 * to display the number of animals saved.
 *
 * @param {Object} data - The data object containing the number of animals saved.
 * @param {number} data.animals_saved - The number of animals saved.
 */
.then(data => {
  document.getElementById('animalsSaved').textContent = data.animals_saved;
});
