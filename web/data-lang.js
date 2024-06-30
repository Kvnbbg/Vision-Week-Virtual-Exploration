/* This JavaScript code snippet is setting up a language translation feature for a webpage. Here's a
breakdown of what it does: */
document.addEventListener("DOMContentLoaded", () => {
    const elements = document.querySelectorAll("[data-lang]");
  
    // Object holding translations for different languages
    const translations = {
      en: {
        "Bienvenue à Vision Week!": "Welcome to Vision Week!",
        "Explorez le monde des animaux.": "Explore the world of animals.",
        "Ours polaires dans l'Arctique": "Polar Bears in the Arctic",
        "Découvrez la vie des ours polaires et leur survie dans l'Arctique.": "Learn about the life of polar bears and their survival in the Arctic.",
        "Statistiques sur la conservation des animaux": "Animal Conservation Stats",
        "Nombre d'animaux sauvés:": "Number of animals saved:",
        "+20% mois après mois": "+20% month after month",
        "Popularité de Vision Week": "Popularity of Vision Week",
        "Animaux populaires: Ours polaires, Manchots, Renards arctiques.": "Popular animals: Polar Bears, Penguins, Arctic Foxes.",
        "Visionneuse VR": "VR Viewer",
        "Découvrez une visite immersive du zoo.": "Experience an immersive tour of the zoo.",
        "Casque Confort": "Comfort Headset",
        "Mettez votre casque VR et explorez l'habitat arctique, abritant des ours polaires, des phoques et plus encore.": "Put on your VR headset and explore the Arctic habitat, home to polar bears, seals, and more.",
        "Casque Moderne": "Modern Headset",
        "Une combinaison de matériaux métalliques et transparents.": "A combination of metallic and transparent materials.",
        "Contrôle de Navigation": "Navigation Control",
        "Utilisez les contrôles de navigation pour vous déplacer librement et profiter pleinement de votre visite virtuelle.": "Use the navigation controls to move freely and enjoy your virtual tour.",
        "Carte Interactive": "Interactive Map",
        "Trouvez votre chemin dans le zoo avec notre carte 3D interactive.": "Find your way around the zoo with our interactive 3D map.",
        "Endroit Préféré": "Favorite Place",
        "Explorez différentes sections du zoo et localisez vos animaux préférés.": "Explore different sections of the zoo and locate your favorite animals.",
        "Parlez-nous de votre endroit préféré:": "Tell us about your favorite place:",
        "Entrez le nom de votre endroit préféré:": "Enter your favorite place name:",
        "Ou choisissez parmi une suggestion:": "Or choose from a suggestion:",
        "Vous avez sélectionné:": "You selected:",
        "Vidéos": "Videos",
        "Liste de lecture vidéo (Dernières nouvelles!)": "Video Playlist (Latest News!)",
        "Vision Week - Exploration Virtuelle": "Vision Week - Virtual Exploration",
        "Profil Utilisateur": "User Profile",
        "Gérez votre profil et vos détails d'abonnement.": "Manage your profile and subscription details.",
        "Modifier l'image du profil": "Edit profile image",
        "Nom": "Name",
        "Nom d'utilisateur": "Username",
        "Email": "Email",
        "Liens": "Links",
        "+ Ajouter un lien": "+ Add link",
        "Bio": "Bio",
        "Démarrez avec la première étape du design thinking : l'empathie. Remplissez le sondage et accédez à l'application maintenant !": "Start with the first step of design thinking: empathy. Fill out the survey and access the app now!",
        "Réalisé par Kvnbbg, l'animateur": "Made by Kvnbbg, the animator"
      },
      fr: {} // Add French translations if needed
    };
  
    // Function to set the language
    const setLanguage = (lang) => {
      elements.forEach((el) => {
        const text = el.textContent.trim();
        if (translations[lang][text]) {
          el.textContent = translations[lang][text];
        }
      });
    };
  
    // Language switch buttons
    document.querySelectorAll("[data-toggle-lang]").forEach((button) => {
      button.addEventListener("click", (e) => {
        e.preventDefault();
        const lang = e.target.dataset.toggleLang;
        setLanguage(lang);
      });
    });
  });
  