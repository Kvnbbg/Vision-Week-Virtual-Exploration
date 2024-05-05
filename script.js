// Ask money
  const amountInput = document.getElementById('amount');
  const sendButton = document.getElementById('send-button');
  const message = document.getElementById('message');

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


//////////////////////////////////////////////////////////////////////

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
  } else {
    // Redirect to Google search (more appropriate for external search)
    window.location.href = 'https://www.youtube.com/' + searchTerm;
  }

  // Add Javascript code to handle click event
  document.getElementById("vision-discovery").addEventListener("click", function() {
    const content = document.getElementById("vision-discovery-content");
    content.style.display = content.style.display === "none" ? "block" : "none";
    // Optionally add logic to show/hide loading animation during content toggle
  });
//////////////////////////////////////////////////////////////////////
  
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
