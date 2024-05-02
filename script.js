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
    window.location.href = 'https://www.google.com/search?q=' + searchTerm;
  }

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
