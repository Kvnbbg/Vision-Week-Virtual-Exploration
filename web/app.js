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
    landingHighlight: "Bilingual • Secure • Family-first",
    whiteoutBadge: "Whiteout braking display",
    whiteoutTitle: "Adaptive braking for every journey",
    whiteoutSubtitle:
      "Simulate braking readiness, calibrate the system, and preview safer stopping distances for families on the move.",
    whiteoutModeLabel: "Braking mode",
    whiteoutModeDesc:
      "Switch between presets to understand how the braking system behaves in changing conditions.",
    whiteoutModes: {
      urban: {
        name: "Urban calm",
        detail: "Slow speed optimization with extra pedestrian awareness and smooth deceleration."
      },
      highway: {
        name: "Highway control",
        detail: "Long-range scanning with dynamic pressure to keep confidence at higher speeds."
      },
      night: {
        name: "Night clarity",
        detail: "Enhanced light sensing with added stopping buffer for low-visibility routes."
      }
    },
    whiteoutRangeLabel: "Estimated travel speed",
    whiteoutRangeHint: "Adjust the slider to estimate the braking distance.",
    whiteoutDistanceLabel: "Estimated stopping distance",
    whiteoutSpeedLabel: "Speed",
    whiteoutReadyTitle: "Daily readiness check",
    whiteoutReadyDesc:
      "Keep the consultation fleet prepared with a live check-in and a gentle safety pulse.",
    whiteoutModeUrban: "Urban",
    whiteoutModeHighway: "Highway",
    whiteoutModeNight: "Night",
    whiteoutCalibrate: "Calibrate now",
    whiteoutCalibrated: "Calibration in progress…",
    whiteoutCalibratedDone: "Calibration complete"
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
    landingHighlight: "Bilingue • Sécurisé • Famille d'abord",
    whiteoutBadge: "Affichage du freinage Whiteout",
    whiteoutTitle: "Freinage adaptatif pour chaque trajet",
    whiteoutSubtitle:
      "Simulez la préparation du freinage, calibrez le système et anticipez des distances d'arrêt plus sûres.",
    whiteoutModeLabel: "Mode de freinage",
    whiteoutModeDesc:
      "Basculez entre les préréglages pour comprendre le comportement du freinage selon les conditions.",
    whiteoutModes: {
      urban: {
        name: "Calme urbain",
        detail: "Optimisation à basse vitesse avec attention piétonne et décélération douce."
      },
      highway: {
        name: "Contrôle autoroute",
        detail: "Analyse longue portée et pression dynamique pour les vitesses élevées."
      },
      night: {
        name: "Clarté nocturne",
        detail: "Capteurs renforcés et marge d'arrêt pour faible visibilité."
      }
    },
    whiteoutRangeLabel: "Vitesse estimée",
    whiteoutRangeHint: "Ajustez le curseur pour estimer la distance d'arrêt.",
    whiteoutDistanceLabel: "Distance d'arrêt estimée",
    whiteoutSpeedLabel: "Vitesse",
    whiteoutReadyTitle: "Vérification quotidienne",
    whiteoutReadyDesc:
      "Gardez la flotte prête avec un check-in en direct et une impulsion de sécurité.",
    whiteoutModeUrban: "Urbain",
    whiteoutModeHighway: "Autoroute",
    whiteoutModeNight: "Nuit",
    whiteoutCalibrate: "Calibrer maintenant",
    whiteoutCalibrated: "Calibration en cours…",
    whiteoutCalibratedDone: "Calibration terminée"
  }
};

const $ = (selector, scope = document) => scope.querySelector(selector);
const $$ = (selector, scope = document) => Array.from(scope.querySelectorAll(selector));

const languageButtons = $$('[data-language]');
const themeToggle = $('[data-theme-toggle]');
const animatedItems = $$('[data-animate]');
const whiteoutModeButtons = $$('[data-whiteout-mode]');
const whiteoutModeDetails = $('[data-whiteout-details]');
const brakingRange = $('[data-braking-range]');
const brakingSpeed = $('[data-braking-speed]');
const brakingDistance = $('[data-braking-distance]');
const calibrateButton = $('[data-whiteout-calibrate]');
const calibrateStatus = $('[data-whiteout-status]');
let currentLanguage = 'en';

function applyLanguage(lang) {
  const dictionary = translations[lang] || translations.en;
  currentLanguage = lang;
  document.documentElement.lang = lang;
  $$('[data-i18n]').forEach((el) => {
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

const intersectionObserver =
  animatedItems.length > 0
    ? new IntersectionObserver(
        (entries) => {
          entries.forEach((entry) => {
            if (entry.isIntersecting) {
              entry.target.classList.add('is-visible');
              intersectionObserver.unobserve(entry.target);
            }
          });
        },
        { threshold: 0.2 }
      )
    : null;

animatedItems.forEach((item) => intersectionObserver?.observe(item));

const updateWhiteoutMode = (mode) => {
  const dictionary = translations[currentLanguage] || translations.en;
  const modeData = dictionary.whiteoutModes?.[mode];
  if (!modeData || !whiteoutModeDetails) return;
  whiteoutModeDetails.querySelector('[data-whiteout-mode-name]').textContent = modeData.name;
  whiteoutModeDetails.querySelector('[data-whiteout-mode-detail]').textContent = modeData.detail;
  whiteoutModeButtons.forEach((button) => {
    button.setAttribute('aria-pressed', button.dataset.whiteoutMode === mode ? 'true' : 'false');
  });
};

const updateBrakingDistance = () => {
  if (!brakingRange || !brakingSpeed || !brakingDistance) return;
  const speed = Number(brakingRange.value);
  const distance = Math.round(speed * 0.75);
  brakingSpeed.textContent = `${speed} km/h`;
  brakingDistance.textContent = `${distance} m`;
};

whiteoutModeButtons.forEach((button) => {
  button.addEventListener('click', () => updateWhiteoutMode(button.dataset.whiteoutMode));
});

if (brakingRange) {
  brakingRange.addEventListener('input', updateBrakingDistance);
  updateBrakingDistance();
}

if (calibrateButton && calibrateStatus) {
  calibrateButton.addEventListener('click', () => {
    const dictionary = translations[currentLanguage] || translations.en;
    calibrateStatus.textContent = dictionary.whiteoutCalibrated;
    calibrateStatus.classList.add('is-active');
    calibrateButton.disabled = true;
    setTimeout(() => {
      calibrateStatus.textContent = dictionary.whiteoutCalibratedDone;
      calibrateButton.disabled = false;
    }, 1800);
  });
}

document.addEventListener('languagechange', () => {
  updateWhiteoutMode(whiteoutModeButtons[0]?.dataset.whiteoutMode || 'urban');
  updateBrakingDistance();
  if (calibrateStatus) {
    const dictionary = translations[currentLanguage] || translations.en;
    calibrateStatus.textContent = dictionary.whiteoutCalibrate;
  }
});

updateWhiteoutMode(whiteoutModeButtons[0]?.dataset.whiteoutMode || 'urban');
