# Guide de Déploiement - Vision Week Virtual Exploration

## Table des Matières

1. [Prérequis](#prérequis)
2. [Configuration de l'Environnement](#configuration-de-lenvironnement)
3. [Déploiement Local avec Docker](#déploiement-local-avec-docker)
4. [Déploiement Kubernetes](#déploiement-kubernetes)
5. [Déploiement Railway](#déploiement-railway)
6. [Configuration de la Sécurité](#configuration-de-la-sécurité)
7. [Monitoring et Maintenance](#monitoring-et-maintenance)
8. [Procédures de Rollback](#procédures-de-rollback)
9. [Troubleshooting](#troubleshooting)

## Prérequis

### Outils Requis

- **Docker** >= 20.10.0
- **Docker Compose** >= 2.0.0
- **Kubernetes** >= 1.24.0 (pour déploiement K8s)
- **kubectl** >= 1.24.0
- **Helm** >= 3.8.0 (optionnel)
- **Flutter** >= 3.10.0
- **PHP** >= 8.1
- **MySQL** >= 8.0
- **Redis** >= 7.0

### Comptes et Services

- Compte Railway (pour déploiement cloud)
- Compte Firebase (pour authentification)
- Compte Google Cloud ou AWS (pour stockage)
- Certificats SSL/TLS

## Configuration de l'Environnement

### 1. Variables d'Environnement

Créez les fichiers de configuration suivants :

#### `.env.production`
```bash
# Application
APP_ENV=production
APP_DEBUG=false
APP_TIMEZONE=Europe/Paris
APP_URL=https://visionweek.example.com

# Base de données
DB_HOST=vision-week-mysql
DB_PORT=3306
DB_NAME=vision_week_db
DB_USER=vision_week_user
DB_PASSWORD=your_secure_password_here
DB_CHARSET=utf8mb4

# Redis
REDIS_HOST=vision-week-redis
REDIS_PORT=6379
REDIS_PASSWORD=your_redis_password_here
REDIS_DATABASE=0

# JWT
JWT_SECRET=your_jwt_secret_key_here
JWT_ALGORITHM=HS256
JWT_EXPIRATION=3600

# Firebase
FIREBASE_PROJECT_ID=your_firebase_project_id
FIREBASE_PRIVATE_KEY=your_firebase_private_key
FIREBASE_CLIENT_EMAIL=your_firebase_client_email

# Sécurité
BCRYPT_ROUNDS=12
CORS_ALLOWED_ORIGINS=https://visionweek.example.com
RATE_LIMIT_REQUESTS=100
RATE_LIMIT_WINDOW=3600

# Stockage
UPLOAD_MAX_SIZE=10485760
UPLOAD_PATH=/app/uploads
STORAGE_DRIVER=local

# Email
MAIL_DRIVER=smtp
MAIL_HOST=smtp.example.com
MAIL_PORT=587
MAIL_USERNAME=noreply@visionweek.example.com
MAIL_PASSWORD=your_email_password
MAIL_ENCRYPTION=tls

# Monitoring
SENTRY_DSN=your_sentry_dsn_here
LOG_LEVEL=warning
```

#### `.env.staging`
```bash
# Copier .env.production et modifier les valeurs pour staging
APP_ENV=staging
APP_DEBUG=true
LOG_LEVEL=debug
# ... autres variables adaptées pour staging
```

### 2. Secrets Kubernetes

Créez les secrets nécessaires :

```bash
# Créer le namespace
kubectl apply -f k8s/manifests/namespace.yaml

# Créer les secrets
kubectl create secret generic vision-week-secrets \
  --namespace=vision-week \
  --from-literal=mysql-root-password='your_mysql_root_password' \
  --from-literal=mysql-password='your_mysql_password' \
  --from-literal=redis-password='your_redis_password' \
  --from-literal=jwt-secret='your_jwt_secret' \
  --from-file=firebase-config=./secrets/firebase-config.json

# Créer les secrets TLS
kubectl create secret tls vision-week-tls \
  --namespace=vision-week \
  --cert=./certs/tls.crt \
  --key=./certs/tls.key
```

## Déploiement Local avec Docker

### 1. Préparation

```bash
# Cloner le repository
git clone https://github.com/kvnbbg/vision-week-virtual-exploration.git
cd vision-week-virtual-exploration

# Créer les dossiers nécessaires
mkdir -p data/{mysql,redis,uploads,prometheus,grafana}
mkdir -p logs/{nginx,php,mysql}
mkdir -p secrets
mkdir -p backups

# Générer les secrets
echo "$(openssl rand -base64 32)" > secrets/mysql_root_password.txt
echo "$(openssl rand -base64 32)" > secrets/mysql_password.txt
echo "$(openssl rand -base64 64)" > secrets/jwt_secret.txt
```

### 2. Construction des Images

```bash
# Construire l'image frontend
docker build -f Dockerfile.secure -t vision-week/frontend:1.1.0 .

# Construire l'image backend
docker build -f Dockerfile.backend.secure -t vision-week/backend:1.1.0 .

# Construire l'image WebSocket
docker build -f Dockerfile.websocket.secure -t vision-week/websocket:1.1.0 .
```

### 3. Démarrage des Services

```bash
# Démarrer tous les services
docker-compose -f docker-compose.secure.yml up -d

# Vérifier le statut
docker-compose -f docker-compose.secure.yml ps

# Voir les logs
docker-compose -f docker-compose.secure.yml logs -f
```

### 4. Initialisation de la Base de Données

```bash
# Attendre que MySQL soit prêt
docker-compose -f docker-compose.secure.yml exec mysql mysqladmin ping -h localhost -u root -p

# Importer le schéma
docker-compose -f docker-compose.secure.yml exec mysql mysql -u root -p vision_week_db < lib/database/create_tables_secure.sql

# Créer un utilisateur admin (optionnel)
docker-compose -f docker-compose.secure.yml exec backend php scripts/create_admin_user.php
```

## Déploiement Kubernetes

### 1. Préparation du Cluster

```bash
# Vérifier la connexion au cluster
kubectl cluster-info

# Installer un ingress controller (si nécessaire)
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.1/deploy/static/provider/cloud/deploy.yaml

# Installer cert-manager pour les certificats SSL
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.12.0/cert-manager.yaml
```

### 2. Déploiement des Manifests

```bash
# Appliquer les manifests dans l'ordre
kubectl apply -f k8s/manifests/namespace.yaml
kubectl apply -f k8s/manifests/configmaps.yaml
kubectl apply -f k8s/manifests/secrets.yaml
kubectl apply -f k8s/manifests/persistent-volumes.yaml
kubectl apply -f k8s/manifests/deployments.yaml
kubectl apply -f k8s/manifests/services.yaml
kubectl apply -f k8s/manifests/ingress.yaml

# Vérifier le déploiement
kubectl get all -n vision-week
kubectl get ingress -n vision-week
```

### 3. Configuration du Monitoring

```bash
# Installer Prometheus et Grafana
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace vision-week \
  --values k8s/monitoring/prometheus-values.yaml

# Configurer les dashboards Grafana
kubectl apply -f k8s/monitoring/grafana-dashboards.yaml
```

## Déploiement Railway

### 1. Préparation

```bash
# Installer Railway CLI
npm install -g @railway/cli

# Se connecter à Railway
railway login

# Créer un nouveau projet
railway init
```

### 2. Configuration des Services

```bash
# Déployer la base de données MySQL
railway add mysql

# Déployer Redis
railway add redis

# Configurer les variables d'environnement
railway variables set NODE_ENV=production
railway variables set APP_ENV=production
railway variables set JWT_SECRET=$(openssl rand -base64 64)

# Déployer l'application
railway up
```

### 3. Configuration du Domaine

```bash
# Ajouter un domaine personnalisé
railway domain add visionweek.example.com

# Configurer les certificats SSL (automatique avec Railway)
```

## Configuration de la Sécurité

### 1. Certificats SSL/TLS

#### Pour Kubernetes avec cert-manager :

```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: admin@visionweek.example.com
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: nginx
```

#### Pour Docker avec Traefik :

```yaml
# Dans docker-compose.secure.yml
labels:
  - "traefik.http.routers.frontend.tls.certresolver=letsencrypt"
```

### 2. Configuration du Firewall

```bash
# Règles UFW pour serveur Ubuntu
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable
```

### 3. Hardening du Système

```bash
# Mise à jour du système
sudo apt update && sudo apt upgrade -y

# Installation de fail2ban
sudo apt install fail2ban -y
sudo systemctl enable fail2ban

# Configuration de fail2ban
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
# Éditer /etc/fail2ban/jail.local selon vos besoins
```

## Monitoring et Maintenance

### 1. Monitoring des Services

#### Prometheus Queries Utiles :

```promql
# CPU usage
rate(container_cpu_usage_seconds_total[5m]) * 100

# Memory usage
container_memory_usage_bytes / container_spec_memory_limit_bytes * 100

# HTTP request rate
rate(http_requests_total[5m])

# Error rate
rate(http_requests_total{status=~"5.."}[5m]) / rate(http_requests_total[5m])
```

#### Alertes Importantes :

```yaml
groups:
- name: vision-week-alerts
  rules:
  - alert: HighCPUUsage
    expr: rate(container_cpu_usage_seconds_total[5m]) * 100 > 80
    for: 5m
    labels:
      severity: warning
    annotations:
      summary: "High CPU usage detected"
      
  - alert: HighMemoryUsage
    expr: container_memory_usage_bytes / container_spec_memory_limit_bytes * 100 > 90
    for: 5m
    labels:
      severity: critical
    annotations:
      summary: "High memory usage detected"
      
  - alert: ServiceDown
    expr: up == 0
    for: 1m
    labels:
      severity: critical
    annotations:
      summary: "Service is down"
```

### 2. Sauvegarde Automatisée

#### Script de Sauvegarde MySQL :

```bash
#!/bin/bash
# backup.sh

DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/backups"
DB_NAME="vision_week_db"
DB_USER="vision_week_user"
DB_PASSWORD="your_password"

# Créer la sauvegarde
mysqldump -u $DB_USER -p$DB_PASSWORD $DB_NAME > $BACKUP_DIR/backup_$DATE.sql

# Compresser
gzip $BACKUP_DIR/backup_$DATE.sql

# Nettoyer les anciennes sauvegardes (garder 30 jours)
find $BACKUP_DIR -name "backup_*.sql.gz" -mtime +30 -delete

echo "Backup completed: backup_$DATE.sql.gz"
```

#### Cron Job :

```bash
# Ajouter au crontab
0 2 * * * /path/to/backup.sh >> /var/log/backup.log 2>&1
```

### 3. Maintenance Préventive

#### Script de Maintenance :

```bash
#!/bin/bash
# maintenance.sh

echo "Starting maintenance tasks..."

# Nettoyer les logs anciens
find /var/log -name "*.log" -mtime +7 -delete

# Nettoyer les sessions expirées
docker-compose exec backend php scripts/cleanup_sessions.php

# Optimiser la base de données
docker-compose exec mysql mysql -u root -p -e "OPTIMIZE TABLE vision_week_db.*;"

# Redémarrer les services si nécessaire
docker-compose restart redis

echo "Maintenance completed."
```

## Procédures de Rollback

### 1. Rollback Docker

```bash
# Revenir à la version précédente
docker-compose -f docker-compose.secure.yml down
docker tag vision-week/frontend:1.0.0 vision-week/frontend:latest
docker tag vision-week/backend:1.0.0 vision-week/backend:latest
docker-compose -f docker-compose.secure.yml up -d
```

### 2. Rollback Kubernetes

```bash
# Voir l'historique des déploiements
kubectl rollout history deployment/vision-week-frontend -n vision-week

# Rollback vers la version précédente
kubectl rollout undo deployment/vision-week-frontend -n vision-week
kubectl rollout undo deployment/vision-week-backend -n vision-week

# Rollback vers une version spécifique
kubectl rollout undo deployment/vision-week-frontend --to-revision=2 -n vision-week
```

### 3. Rollback Railway

```bash
# Voir les déploiements
railway status

# Rollback via l'interface web ou redéployer une version précédente
git checkout v1.0.0
railway up
```

## Troubleshooting

### Problèmes Courants

#### 1. Service ne démarre pas

```bash
# Vérifier les logs
docker-compose logs service-name
kubectl logs deployment/service-name -n vision-week

# Vérifier la configuration
docker-compose config
kubectl describe deployment/service-name -n vision-week
```

#### 2. Problèmes de base de données

```bash
# Vérifier la connectivité
docker-compose exec backend php -r "echo 'DB connection test';"
kubectl exec -it deployment/vision-week-backend -n vision-week -- php -r "echo 'test';"

# Vérifier les permissions
docker-compose exec mysql mysql -u root -p -e "SHOW GRANTS FOR 'vision_week_user'@'%';"
```

#### 3. Problèmes de certificats SSL

```bash
# Vérifier les certificats
openssl x509 -in /path/to/cert.pem -text -noout
kubectl describe certificate vision-week-tls -n vision-week

# Renouveler les certificats
kubectl delete certificate vision-week-tls -n vision-week
kubectl apply -f k8s/manifests/certificates.yaml
```

#### 4. Problèmes de performance

```bash
# Vérifier l'utilisation des ressources
docker stats
kubectl top pods -n vision-week
kubectl top nodes

# Analyser les métriques
# Accéder à Grafana et vérifier les dashboards
```

### Contacts d'Urgence

- **Développeur Principal** : Kevin Marville (kevin@kvnbbg.fr)
- **Support Infrastructure** : support@visionweek.example.com
- **Monitoring** : alerts@visionweek.example.com

### Liens Utiles

- **Documentation API** : https://api.visionweek.example.com/docs
- **Monitoring** : https://grafana.visionweek.example.com
- **Status Page** : https://status.visionweek.example.com
- **Repository** : https://github.com/kvnbbg/vision-week-virtual-exploration

---

**Version du Guide** : 1.1.0  
**Dernière Mise à Jour** : 24 juillet 2025  
**Maintenu par** : Kevin Marville

