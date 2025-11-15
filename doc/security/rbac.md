# RBAC – Vision Week Roles & Permissions

| Rôle             | Description                                                   | Permissions clés |
|------------------|---------------------------------------------------------------|-------------------|
| `ROLE_EXPLORER`  | Utilisateur final consommant des expériences VR et commandes  | Parcourir le catalogue, créer des commandes, consulter son historique |
| `ROLE_SELLER`    | Commerçant ou partenaire fournissant des expériences/menus    | Gérer le catalogue, consulter les statistiques de ventes, répondre aux avis |
| `ROLE_COURIER`   | Livreurs/guides réalisant la logistique et l’accompagnement   | Recevoir les missions, partager la localisation temps réel, clôturer une livraison |
| `ROLE_ADMIN`     | Administrateur Vision Week                                    | Accéder à l’ensemble des modules, gérer les utilisateurs et les configurations |
| `ROLE_OPERATOR`  | Support client / supervision                                  | Accéder aux dashboards, consulter les commandes, gérer les remboursements (lecture/écriture limitée) |
| `ROLE_SUPER_ADMIN` | Rôle exceptionnel réservé à l’équipe plateforme             | Gestion des secrets, configuration infrastructure, audit complet |

## Principes
- Chaque utilisateur doit avoir un rôle principal. Les rôles multiples sont limités aux comptes de test et au support avancé.
- Les actions critiques (payouts, suppression de contenu, gestion des secrets) nécessitent `ROLE_ADMIN` + MFA.
- Les JWT/Firebase tokens contiennent une liste de rôles vérifiée côté API Slim via middleware.
- Les WebSockets utilisent les mêmes rôles et appliquent la vérification à la connexion.

## Points d’intégration
1. **API Slim PHP** : middleware `RoleMiddleware` qui compare les rôles requis par route.
2. **Flutter clients** : navigation conditionnelle (GoRouter) selon la liste des rôles renvoyée après login.
3. **Admin portal** : garde double (front + API) afin d’éviter l’élévation de privilèges via manipulation client.
4. **Logs** : chaque action critique journalisée avec `user_id`, `roles`, `request_id` pour audit.

## Procédures
- Attribution initiale via la console admin sécurisée ou script d’onboarding.
- Modification de rôle nécessite validation manuelle et journalisation (ticket support).
- Audit trimestriel des rôles inactifs ou surdimensionnés.
