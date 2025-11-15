# Audit-Ready Pack – Vision Week

Ce dossier regroupe les contrôles techniques et documentaires nécessaires pour préparer un audit (ANSSI, cybersécurité EU, conformité clients B2B).

## Automatisations CI/CD
- **CodeQL** (`.github/workflows/codeql.yml`) : analyse statique du code JavaScript.
- **Dependabot** (`.github/dependabot.yml`) : mises à jour automatisées Composer, npm, Docker, GitHub Actions.
- **Pipeline CI (`ci-cd.yml`)** :
  - Tests unitaires (Flutter, PHP, Node) et linting.
  - Scans Trivy (images) & Snyk (dépendances).
  - Job DAST optionnel avec OWASP ZAP (`dast`).
  - Signature Cosign et déploiement Kubernetes.

## Hardening Infrastructure
- **nginx.conf / default.conf** :
  - En-têtes de sécurité renforcés (CSP, HSTS, Permissions-Policy).
  - Redirection HTTPS forcée via `X-Forwarded-Proto`.
  - Rate limiting API et endpoints sensibles.
- **RBAC** (`doc/security/rbac.md`) : définition des rôles Vision Week et procédures d’attribution.

## Conformité RGPD
- **Politique de Confidentialité** (`PRIVACY_POLICY_FR.md`).
- **Mentions légales** (`MENTIONS_LEGALES_FR.md`).
- **Registre des traitements** (`doc/compliance/registre_traitements.md`).
- **DPIA simplifiée** (`doc/compliance/DPIA_vision_week.md`).
- **Disclaimer de responsabilité** (`DISCLAIMER.md`).

## Prochaines étapes recommandées
1. Déployer HashiCorp Vault et intégrer la rotation automatique des secrets.
2. Documenter les procédures de réponse aux incidents et les SLA contractuels.
3. Planifier un test d’intrusion externe annuel et conserver les rapports.
4. Ajouter des métriques DORA automatisées et publier un tableau de bord d’observabilité partagé.
