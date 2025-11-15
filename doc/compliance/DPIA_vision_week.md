# DPIA simplifiée – Vision Week

**Date :** 2024-04-18  
**Auteur :** Kevin Marville

## 1. Description du traitement
- **Application :** Vision Week – expériences VR et services associés (livraison food pairing, guides).
- **Personnes concernées :** utilisateurs finaux, commerçants partenaires, livreurs/guides, administrateurs.
- **Données traitées :** identité numérique (email, identifiants), données d’usage (parcours VR, commandes), données de paiement (jetons Stripe), données de localisation en temps réel pour les livreurs, logs techniques.
- **Systèmes :** Clients Flutter, API Slim PHP, WebSocket en temps réel, Firebase, Stripe, hébergement Kubernetes.

## 2. Nécessité et proportionnalité
- Les données collectées sont limitées à la fourniture du service et à son amélioration.
- Les données de localisation sont activées uniquement pour les rôles livreur/guide pendant une mission en cours.
- Les journaux techniques sont pseudonymisés lorsque c’est possible et conservés pour la détection d’incidents.

## 3. Analyse des risques
| Risque | Impact | Probabilité | Mesures existantes |
|--------|--------|-------------|--------------------|
| Compromission de comptes utilisateurs | Élevé | Moyen | MFA administrateur, surveillance d’anomalies, verrouillage après tentatives multiples |
| Fuite de données de localisation en temps réel | Élevé | Faible | Chiffrement TLS, durée de rétention limitée, autorisations strictes |
| Utilisation abusive de l’API publique | Moyen | Moyen | Rate limiting Nginx, WAF en amont, tokens signés, logs d’audit |
| Indisponibilité de la plateforme | Élevé | Moyen | Déploiement Kubernetes redondant, supervision Prometheus/Grafana, plan de reprise |
| Non-conformité RGPD | Élevé | Faible | Politique RGPD, registre des traitements, processus de réponse aux demandes DPO |

## 4. Mesures complémentaires recommandées
- Renforcer la détection d’anomalies (Alerting sur taux d’erreurs, protection anti-bot avancée).
- Finaliser la politique de rotation des secrets via Vault.
- Documenter les procédures d’effacement/anonymisation des données à la demande.
- Réaliser un test d’intrusion annuel et intégrer les conclusions dans le plan d’action sécurité.

## 5. Validation
Les risques résiduels sont jugés acceptables avec la feuille de route de modernisation (CI/CD, Vault, observabilité). Cette DPIA doit être révisée annuellement ou lors d’une évolution majeure du traitement (nouvelle catégorie de données, nouveau pays ciblé, etc.).
