document.addEventListener("DOMContentLoaded", function () {
    const navLinks = document.querySelectorAll("nav ul li a");
    const contentScreens = document.querySelectorAll(".content-screen");
  
    // Navigation functionality
    navLinks.forEach((link) => {
      link.addEventListener("click", function (e) {
        e.preventDefault();
        const targetId = this.id.replace("Link", "Screen");
  
        contentScreens.forEach((screen) => {
          screen.classList.remove("active");
          if (screen.id === targetId) {
            screen.classList.add("active");
          }
        });
      });
    });
  });
  