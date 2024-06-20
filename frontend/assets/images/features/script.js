////////////////////// design thinking.html //////////////////////////////////

////////////////////// nba.html //////////////////////////////////
// Function to generate a random score
function getRandomScore() {
  const minScore = 80; // Adjust minimum score as needed
  const maxScore = 130; // Adjust maximum score as needed
  return Math.floor(Math.random() * (maxScore - minScore + 1)) + minScore;
}

// Function to display random scores
function displayRandomScores() {
  const scoresTable = document.getElementById('scores-table').getElementsByTagName('tbody')[0];

  // Clear existing scores (optional)
  scoresTable.innerHTML = '';

  // Generate and display 5 random scores (adjust as needed)
  for (let i = 0; i < 5; i++) {
    const scoreRow = scoresTable.insertRow();
    const timeCell = scoreRow.insertCell();
    const matchupCell = scoreRow.insertCell();
    const scoreCell = scoreRow.insertCell();
    const highlightsCell = scoreRow.insertCell();

    // Example content (replace with actual data fetching logic)
    timeCell.textContent = '8:00 PM ET';
    matchupCell.textContent = 'Los Angeles Lakers vs. Golden State Warriors';
    scoreCell.textContent = getRandomScore() + ' - ' + getRandomScore();
    highlightsCell.innerHTML = '<a href="#">See Highlights</a>';
  }
}

// Call the display function on page load or when desired
displayRandomScores();


///////////////////////////// index.html & cars.html //////////////////////////////////////////////////
// Ask money & buy the item
  const amountInput = document.getElementById('amount');
  const sendButton = document.getElementById('send-button');
  const message = document.getElementById('message');

// ITEM SEARCH
const adviceList = document.getElementById('adviceList');
const financialGoal = document.getElementById('financialGoal');
const addButton = document.getElementById("addButton");

addButton.addEventListener("click", addGoal);

const advices = [
  "Educate yourself on financial literacy.",
  "Take courses, read books",
  "Watch videos",
  "Gain a strong understanding of personal finance topics such as budgeting, debt management, investing, and retirement planning.",
  "Create a budget and stick to it",
  "Track your income and expenses",
  "See where your money is going",
  "Allocate a certain amount each month for savings and debt repayment.",
  "Save early and consistently",
  "Start saving as soon as possible, even if it's just a small amount to build the habit. ",
  "Automate your savings & transfers from your checking to your savings account.",
  "Pay off high-interest debt first",
  "Prioritize paying off debts with high interest rates, the less interest.",
  "Invest strategically",
  "Consider putting a portion of your savings into investments to grow your wealth over time.",
  "Do your research, diversify your portfolio, and seek professional advice if needed.",
  "Avoid unnecessary expenses",
  "Be mindful of your spending habits about where you allocate your money.",
  "Cut back on non-essential expenses that aren't contributing to your financial goals.",
  "Plan for unexpected circumstances",
  "Build an emergency fund to cover unexpected expenses.",
  "Aim to have 3-6 months' worth of living expenses saved in an emergency fund.",
  "Seek professional help if needed",
  "Don't hesitate to consult a financial advisor for personalized guidance.",
  "They can help you create a financial plan.",
  "Review your financial plan regularly",
  "As your circumstances change, revisit your financial plan and make adjustments as needed.",
  "Maintain an optimistic outlook",
  "While managing your finances can be challenging",
  "It's a marathon, not a sprint, and with consistent effort.",
  "Now so that you can enjoy greater financial freedom and stability in the future."
];

function addGoal() {
   message.textContent = "Waiting...";
  const goal = financialGoal.value;
  if (goal) {
    adviceList.innerHTML = '';
    advices.forEach(advice => {
      const li = document.createElement('li');
      li.textContent = advice;
      adviceList.appendChild(li);
    });
    alert('Items added : ' + goal);
  } else {
    alert('Please enter a financial goal.');
  }
}


// SEND BUTTON
  sendButton.addEventListener('click', function() {
    const amount = parseFloat(amountInput.value);

    if (isNaN(amount) || amount <= 0) {
      message.textContent = "Please enter a valid amount.";
      return;
    }

    message.textContent = "Sending...";

    // Animation logic (replace with your desired animation)
    let currentAmount = 0;
    const animationDuration = 4000; // milliseconds
    const intervalId = setInterval(() => {
      currentAmount += amount / (animationDuration / 10);
      amountInput.value = currentAmount.toFixed(2);

      if (currentAmount >= amount) {
        clearInterval(intervalId);
        message.textContent = " $" + amount.toFixed(2) + " received successfully!";
        message2.textContent = `${Math.random().toFixed(2)} transaction fee`;

      }
    }, 10);
  });

// Description: JavaScript file for the interactive car dashboard
// Link this script to the settings.html file

function createPopup(emojiContent) {
    var popup = document.createElement("div");
    popup.style.position = "fixed";
    popup.style.width = "200px";
    popup.style.height = "200px";
    popup.style.backgroundColor = "#fff";
    popup.style.border = "1px solid #000";
    popup.style.top = "50%";
    popup.style.left = "50%";
    popup.style.transform = "translate(-50%, -50%)";
    popup.style.padding = "20px";
    popup.style.textAlign = "center";
    popup.style.zIndex = "1000";

    var text = document.createTextNode(emojiContent);
    popup.appendChild(text);

    document.body.appendChild(popup);

    // Add attention-seeking animation
    anime({
        targets: popup,
        scale: [0.1, 1.0],
        duration: 1000,
        easing: 'easeInOutQuad',
        complete: function(anim) {
            setTimeout(function() {
                popup.remove();
            }, 1000);
        }
    });
}

// Add event listeners to the navigation buttons
['left', 'right', 'up', 'down'].forEach(function(direction) {
    document.getElementById(direction).addEventListener('click', function(event) {
        createPopup(faker.random.arrayElement(["💰🎟️🎫🛒💸", "🚗🚕🚙🚌🚎", "🚦🚥🚧🛑🚏", "🚓🚔🚒🚑🚐"]));
    });
});

// Description: Fetch car information from API and update #car-info section
// Link this script to the settings.html file
const carInfoSection = document.getElementById('car-info');

// Ask the user for a car model
var userInput = prompt("Please enter a car model, or leave blank to use a public customized car:");

// Simulate loading bar
var loadingBar = document.createElement("div");
loadingBar.style.position = "fixed";
loadingBar.style.top = "0";
loadingBar.style.left = "0";
loadingBar.style.height = "4px";
loadingBar.style.width = "0";
loadingBar.style.backgroundColor = "#007bff";
loadingBar.style.transition = "width 5s ease-in-out";
document.body.appendChild(loadingBar);

setTimeout(function() {
    loadingBar.style.width = "100%";
}, 100);

setTimeout(function() {
    loadingBar.remove();
}, 5000);

// Simulate fetching data from API
setTimeout(function() {
    // Arrays of car models, years, and battery health statuses
    var models = ["CustomCar 1", "CustomCar 2", "CustomCar 3", "CustomCar 4"];
    if (userInput) {
        models.push(userInput);
    }
    var years = ["2018", "2019", "2020", "2021", "2022", "2023", "2024", "2025"];
    var batteryHealths = ["Good", "Fair", "Poor", "Excellent", "New", "Used"];
    var faker = require('faker');

    // Select a random model, year, and battery health
    var model = models[Math.floor(Math.random() * models.length)];
    var year = years[Math.floor(Math.random() * years.length)];
    var batteryHealth = batteryHealths[Math.floor(Math.random() * batteryHealths.length)];

    carInfoSection.innerHTML = `
        <h2>Car ID</h2>
        <p>Carbon Footprint: ${faker.random.number({min: 1, max: 100})} kg CO2</p>
        <p>License Plate: ${faker.random.alphaNumeric(8)}</p>
        <p>Model: ${model}</p>
        <p>Year: ${year}</p>
        <p>Battery Health: ${batteryHealth}</p>
        <p>Carburetor: ${faker.random.arrayElement(["Good", "Fair", "Poor", "Excellent", "New", "Used"])}</p>
        <p>Engine: ${faker.random.arrayElement(["Good", "Fair", "Poor", "Excellent", "New", "Used"])}</p>
        <p>Transmission: ${faker.random.arrayElement(["Good", "Fair", "Poor", "Excellent", "New", "Used"])}</p>
        <p>Brakes: ${faker.random.arrayElement(["Good", "Fair", "Poor", "Excellent", "New", "Used"])}</p>
        <p>Steering: ${faker.random.arrayElement(["Good", "Fair", "Poor", "Excellent", "New", "Used"])}</p>
        <p>Exhaust: ${faker.random.arrayElement(["Good", "Fair", "Poor", "Excellent", "New", "Used"])}</p>
    `;
}, 5000);

document.addEventListener('DOMContentLoaded', (event) => {
    // Get the statistics elements
    const usersElement = document.getElementById('users');
    const carsElement = document.getElementById('cars');
    const themesElement = document.getElementById('themes');

    // Generate random data
    const users = Math.floor(Math.pow(Math.random() * 10, 2));
    const cars = Math.floor(Math.pow(Math.random() * 10, 2));
    const themes = Math.floor(Math.pow(Math.random() * 10, 2));

    // Update the statistics elements
    usersElement.textContent = users;
    carsElement.textContent = cars;
    themesElement.textContent = themes;
});

document.addEventListener('DOMContentLoaded', (event) => {
    const models = ["CustomCar 1", "CustomCar 2", "CustomCar 3", "CustomCar 4"];
    const years = ["2018", "2019", "2020", "2021", "2022", "2023", "2024", "2025"];
    const batteryHealths = ["Good", "Fair", "Poor", "Excellent", "New", "Used"];
    const carInfoSection = document.getElementById('car-info');
    const loadingBar = createLoadingBar();

    // Ask the user for a car model
    var userInput = prompt("Please enter a car model, or leave blank to use a public customized car:");
    if (userInput) {
        models.push(userInput);
    }

    // Simulate loading bar
    loadingBar.style.width = "100%";
    setTimeout(() => {
        loadingBar.remove();
    }, 5000);

    // Simulate fetching data from API
    setTimeout(() => {
        // Select a random model, year, and battery health
        var model = models[Math.floor(Math.random() * models.length)];
        var year = years[Math.floor(Math.random() * years.length)];
        var batteryHealth = batteryHealths[Math.floor(Math.random() * batteryHealths.length)];

        carInfoSection.innerHTML = `
            <h2>Car Information</h2>
            <p>Model: ${model}</p>
            <p>Year: ${year}</p>
            <p>Battery Health: ${batteryHealth}</p>
        `;
    }, 5000);
});

function createLoadingBar() {
    var loadingBar = document.createElement("div");
    loadingBar.style.position = "fixed";
    loadingBar.style.top = "0";
    loadingBar.style.left = "0";
    loadingBar.style.height = "4px";
    loadingBar.style.width = "0";
    loadingBar.style.backgroundColor = "#007bff";
    loadingBar.style.transition = "width 5s ease-in-out";
    document.body.appendChild(loadingBar);
    return loadingBar;
}
// Function to handle click event on myButton
function handleClick() {
    // Get the myDiv element
    var myDiv = document.getElementById('myDiv');

    // Toggle the display of myDiv
    if (myDiv.style.display === 'none') {
        myDiv.style.display = 'block';
    } else {
        myDiv.style.display = 'none';
    }
}

// Add event listener to myButton
document.getElementById('myButton').addEventListener('click', handleClick);

function toggleDropdown(id) {
    var dropdown = document.getElementById(id);
    dropdown.classList.toggle("show");
  }

  // Close the dropdown menu if the user clicks outside of it
  window.onclick = function(event) {
    if (!event.target.matches('.my-element')) {
      var dropdowns = document.getElementsByClassName("dropdown-menu");
      for (var i = 0; i < dropdowns.length; i++) {
        var openDropdown = dropdowns[i];
        if (openDropdown.classList.contains('show')) {
          openDropdown.classList.remove('show');
        }
      }
    }
  }

///////////////////////////////////// index.html ///////////////////////////////////////////////////////:

// This file is currently empty. 
// In the future, you can add Javascript functionality here, 
// such as making the upcoming games clickable or updating scores dynamically.
const searchInput = document.getElementById('search-input');
const searchButton = document.getElementById('search-button');

searchButton.addEventListener('click', () => {
  const searchTerm = searchInput.value.toLowerCase();

  // Handle different search terms
  if (searchTerm === 'nba') {
    // Open nba.html in the same window (not recommended for production)
    window.location.href = 'nba.html'; // Consider using a navigation framework for better UX
  }
  else if (searchTerm === 'sport') {
    window.location.href = 'sport.html';
  }
    else if (searchTerm === 'cars') {
      window.location.href = 'cars.html';
    }
  else {
    // Redirect to Google search (more appropriate for external search)
    window.location.href = 'https://www.youtube.com/' + searchTerm;
  }

  // Add Javascript code to handle click event
  document.getElementById("vision-discovery").addEventListener("click", function() {
    const content = document.getElementById("vision-discovery-content");
    content.style.display = content.style.display === "none" ? "block" : "none";
    // Optionally add logic to show/hide loading animation during content toggle
  });
////////////////////////////////// gym.html /////////////////////////////////////////////////////////////
  
  // Simulate opening app.jpg for 3 seconds (not possible due to security restrictions)
  // **Security Note:** Directly opening local files from a web page is not allowed due to security concerns. It could potentially expose user data or compromise system security.

  // Alternative: Display a temporary image within the webpage
  // This approach is safer and provides a controlled user experience.

  // Create an image element
  const image = document.createElement('img');
  image.src = 'app.jpg'; // Assuming app.jpg is located in the same directory
  image.style.display = 'none'; // Initially hidden

  // Append the image to the body (or a specific container)
  document.body.appendChild(image);

  // Show the image for 3 seconds
  image.style.display = 'block'; // Make the image visible
  setTimeout(() => {
    image.style.display = 'none'; // Hide the image after 3 seconds
    image.remove(); // Remove the image from the DOM to avoid memory leaks
  }, 3000);
});

 // Sample Team Names (Replace with actual team names)
  const teams = ["Milwaukee Bucks", "Golden State Warriors", "Boston Celtics", "Los Angeles Clippers", "Phoenix Suns"];

  function generateRandomScore() {
    return Math.floor(Math.random() * 120) + 80; // Range: 80-199
  }

  function generateTodaysScores() {
    const tableBody = document.getElementById('scores-table').getElementsByTagName('tbody')[0];
    tableBody.innerHTML = ''; // Clear existing data

    for (let i = 0; i < 3; i++) { // Generate scores for 3 games
      const time = '10:00 PM ET'; // Replace with actual time data
      const team1 = teams[Math.floor(Math.random() * teams.length)];
      const team2 = teams.find(team => team !== team1); // Avoid same team playing itself
      const score1 = generateRandomScore();
      const score2 = generateRandomScore();
      const winner = score1 > score2 ? team1 : team2;

      const row = document.createElement('tr');
      row.innerHTML = `
        <td><span class="math-inline">\{time\}</td\>
<td\><img src\="app\.png" alt\="</span>{team1} Logo"> vs. <img src="app.png" alt="<span class="math-inline">\{team2\} Logo"\></td\>
<td\></span>{score1} - <span class="math-inline">\{score2\} \(</span>{winner} W)</td>
        <td><a href="#">Watch Highlights</a></td>
      `;
      tableBody.appendChild(row);
    }
  }

function generateUpcomingMatchups() {
    const matchupsList = document.getElementById('matchups-list');
    matchupsList.innerHTML = ''; // Clear existing data

    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
    const dates = days.map(day => new Date().addDays(days.indexOf(day) + 1).toLocaleDateString()); // Add 1-5 days to current date

    for (let i = 0; i < 5; i++) {
        const dayElement = document.createElement('li');
        dayElement.textContent = dates[i];
        matchupsList.appendChild(dayElement);

        // Generate 2-3 matchups for each day
        for (let j = 0; j < Math.floor(Math.random() * 2) + 2; j++) {
            const matchup = `
                <p>
                    <img src="img2.png" alt="Team 1 Logo">
                    ${faker.random.arrayElement(["Los Angeles Lakers", "Golden State Warriors", "Milwaukee Bucks", "Boston Celtics", "Miami Heat", "Phoenix Suns", "Dallas Mavericks", "Philadelphia 76ers", "Brooklyn Nets", "Utah Jazz"])}
                    vs.
                    <img src="img2.png" alt="Team 2 Logo">
                    ${faker.random.arrayElement(["Los Angeles Lakers", "Golden State Warriors", "Milwaukee Bucks", "Boston Celtics", "Miami Heat", "Phoenix Suns", "Dallas Mavericks", "Philadelphia 76ers", "Brooklyn Nets", "Utah Jazz"])}
                </p>
            `;
            dayElement.innerHTML += matchup;
        }
    }
}

// NBA BALL ANIMATION
const nbaBall = document.querySelector('.nba-ball'); // Select the element with class "nba-ball"

let animationIndex = 0; // Keeps track of the current animation

function animateBall() {
  // Clear any existing animation classes
  nbaBall.classList.remove('animation-1', 'animation-2', 'animation-3');

  // Choose a random animation based on the animationIndex
  switch (animationIndex) {
    case 0:
      nbaBall.classList.add('animation-1'); // Add the first animation class
      break;
    case 1:
      nbaBall.classList.add('animation-2'); // Add the second animation class
      break;
    case 2:
      nbaBall.classList.add('animation-3'); // Add the third animation class
      break;
    default:
      animationIndex = 0; // Reset animationIndex if it reaches the end
  }

  // Increment animationIndex for the next cycle
  animationIndex = (animationIndex + 1) % 3; // Ensures it stays between 0 and 2

  // Schedule the next animation after 3 seconds
  setTimeout(animateBall, 3000);
}

// Start the animation loop
animateBall();
