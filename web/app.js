const translations = {
  en: {
    brand: "Vision Week",
    heroTitle: "Consultation hub for the Vision Week family",
    heroSubtitle:
      "A secure, bilingual space to book consultations, explore experiences, and stay connected with the community.",
    ctaPrimary: "Enter the consultation hub",
    ctaSecondary: "See the landing page",
    indexTitle: "Quick access",
    indexSubtitle:
      "Choose an experience or learn more about what the family is building together.",
    exploreTitle: "Virtual exploration",
    exploreDesc: "Explore curated virtual journeys and vision week highlights.",
    mobilityTitle: "Mobility stories",
    mobilityDesc: "Discover adaptive cars and mobility showcases.",
    wellnessTitle: "Wellness studio",
    wellnessDesc: "Join wellness and gym sessions tailored to the community.",
    nbaTitle: "Athlete spotlight",
    nbaDesc: "Follow inspiring athlete collaborations and events.",
    authTitle: "Join the family",
    authSubtitle:
      "Create your secure account to participate in consultations and member-only content.",
    statusGuest: "Not connected yet",
    statusMember: "Connected as",
    registerTitle: "Register",
    loginTitle: "Sign in",
    fullName: "Full name",
    email: "Email",
    password: "Password",
    registerButton: "Create account",
    loginButton: "Sign in",
    logoutButton: "Sign out",
    landingTitle: "A welcoming space for consultation and community",
    landingSubtitle:
      "Switch languages instantly, sign up securely, and navigate every experience with ease.",
    landingCta: "View the consultation index",
    landingHighlight: "Bilingual • Secure • Family-first"
  },
  fr: {
    brand: "Semaine de la Vision",
    heroTitle: "Le hub de consultation pour la famille Vision Week",
    heroSubtitle:
      "Un espace sécurisé et bilingue pour réserver des consultations, explorer des expériences et rester connecté à la communauté.",
    ctaPrimary: "Accéder au hub de consultation",
    ctaSecondary: "Voir la page d'accueil",
    indexTitle: "Accès rapide",
    indexSubtitle:
      "Choisissez une expérience ou découvrez ce que la famille construit ensemble.",
    exploreTitle: "Exploration virtuelle",
    exploreDesc: "Explorez des parcours virtuels et les moments forts de Vision Week.",
    mobilityTitle: "Histoires de mobilité",
    mobilityDesc: "Découvrez les voitures adaptées et les initiatives mobilité.",
    wellnessTitle: "Studio bien-être",
    wellnessDesc: "Rejoignez des sessions gym et bien-être dédiées à la communauté.",
    nbaTitle: "Focus athlète",
    nbaDesc: "Suivez des collaborations et événements inspirants.",
    authTitle: "Rejoindre la famille",
    authSubtitle:
      "Créez votre compte sécurisé pour participer aux consultations et aux contenus réservés.",
    statusGuest: "Pas encore connecté",
    statusMember: "Connecté en tant que",
    registerTitle: "Inscription",
    loginTitle: "Connexion",
    fullName: "Nom complet",
    email: "Email",
    password: "Mot de passe",
    registerButton: "Créer un compte",
    loginButton: "Se connecter",
    logoutButton: "Se déconnecter",
    landingTitle: "Un espace accueillant pour la consultation et la communauté",
    landingSubtitle:
      "Changez de langue instantanément, inscrivez-vous en toute sécurité et naviguez facilement.",
    landingCta: "Voir l'index des consultations",
    landingHighlight: "Bilingue • Sécurisé • Famille d'abord"
  }
};

const languageButtons = document.querySelectorAll('[data-language]');
const themeToggle = document.querySelector('[data-theme-toggle]');

function applyLanguage(lang) {
  const dictionary = translations[lang] || translations.en;
  document.documentElement.lang = lang;
  document.querySelectorAll('[data-i18n]').forEach((el) => {
    const key = el.getAttribute('data-i18n');
    if (dictionary[key]) {
      el.textContent = dictionary[key];
    }
  });
  languageButtons.forEach((button) => {
    button.setAttribute('aria-pressed', button.dataset.language === lang ? 'true' : 'false');
  });
  localStorage.setItem('preferredLanguage', lang);
  document.dispatchEvent(new CustomEvent('languagechange', { detail: { lang } }));
}

function applyTheme(theme) {
  if (theme === 'dark') {
    document.body.classList.add('dark-mode');
  } else {
    document.body.classList.remove('dark-mode');
  }
  if (themeToggle) {
    themeToggle.setAttribute('aria-pressed', theme === 'dark');
  }
  localStorage.setItem('preferredTheme', theme);
}

function toggleTheme() {
  const current = document.body.classList.contains('dark-mode') ? 'dark' : 'light';
  applyTheme(current === 'dark' ? 'light' : 'dark');
}

languageButtons.forEach((button) => {
  button.addEventListener('click', () => applyLanguage(button.dataset.language));
});

if (themeToggle) {
  themeToggle.addEventListener('click', toggleTheme);
}

const savedLanguage = localStorage.getItem('preferredLanguage') || 'en';
const savedTheme = localStorage.getItem('preferredTheme') || 'light';
applyLanguage(savedLanguage);
applyTheme(savedTheme);
