# Secure Deployment & "Try It Now" Playbook

This guide explains how to go from source code to a running Vision Week experience in minutes, while keeping production rollouts modern and secure. It covers:

1. **Instant local preview** of the Flutter front-end + PHP backend.
2. **One-command Android builds** for devices and stores.
3. **Web hosting options** for production-ready deployments.
4. **Container/Kubernetes delivery** using the hardened tooling in this repo.
5. **Security guardrails** you should keep enabled in every environment.

---

## 1. Instant Local Preview (Web + Backend)

### Requirements
- Docker Desktop or Docker Engine with Compose v2 (`docker compose`).
- Flutter 3.22+ with web support enabled.
- Optional: Android SDK/adb if you want mobile hot reload while the backend runs.

### Start everything with one command
```bash
./scripts/quickstart.sh web
```
This script:
1. Spins up MySQL, the Slim API, and WebSocket server with `docker compose`.
2. Waits for the database to become healthy.
3. Runs `flutter pub get` and launches the Flutter web server on `http://localhost:5173` (override with `WEB_PORT` and `WEB_HOST`).
4. Tears down the containers automatically when you exit the Flutter process.

#### Useful flags
- `./scripts/quickstart.sh web --skip-backend` — launch the Flutter web preview only (useful if you already have the backend running elsewhere).
- `WEB_PORT=9000 ./scripts/quickstart.sh web` — expose the web preview on an alternate port.

When the command finishes booting you can open the browser and log into the app immediately against the locally provisioned backend.

---

## 2. Android: Build & Install in One Step

```bash
./scripts/quickstart.sh android
```
The helper script runs `flutter pub get`, builds a debug APK, and—if an `adb`-connected device or emulator is detected—installs it automatically.

Options:
- `./scripts/quickstart.sh android --device emulator-5554` — target a specific device id.
- `./scripts/quickstart.sh android --release` — create a Play-ready `app-release.aab` with code obfuscation (`build/app/obfuscation-symbols` stores symbol maps).

For Play Store distribution, sign the release bundle with your keystore and upload the generated `.aab`.

---

## 3. Production Web Deployment (Static Hosting)

1. **Build optimized assets**
   ```bash
   flutter build web --release --base-href /
   ```
2. **Deploy to your host**
   - **Netlify**
     ```bash
     netlify deploy --dir build/web --prod
     ```
   - **Vercel**
     ```bash
     vercel deploy build/web --prod
     ```
   - **Any CDN (S3 + CloudFront, Azure Static Web Apps, etc.)** — upload the contents of `build/web/`.
3. **Lock down environment variables** using the host's secret manager (API endpoint, analytics keys, etc.).

Pair this static front end with the containerized API described below.

---

## 4. Backend Containers & Kubernetes Rollout

### Build & publish images
```bash
./deploy.sh staging build --tag v1.0.0
./deploy.sh staging deploy --tag v1.0.0
```
The script validates Docker/Kubernetes prerequisites, builds the multi-stage Dockerfile, pushes it to `$DOCKER_REGISTRY/$IMAGE_NAME`, and applies the Kustomize overlay for your environment. Supported actions: `deploy`, `rollback`, `status`, `logs`, `cleanup`, and `test`.

### Minimal Docker Compose stack (no Kubernetes)
```bash
docker compose up -d slim_api websocket_server mysql_db
```
Use this when you only need a throwaway environment without Traefik or Redis.

---

## 5. Security Guardrails (Do Not Skip)

| Layer | Guardrail | Why it matters |
| --- | --- | --- |
| Secrets | Populate `secrets/*.txt` (secure compose) or Kubernetes secrets before deploying. | Prevents accidental secret leakage in images or source. |
| TLS & Proxy | The secure Traefik stack in `docker-compose.secure.yml` terminates TLS, injects security headers, and rate limits the API. | Enforces HTTPS/HSTS and mitigates abuse. |
| Supply Chain | Always run `npm audit`, `composer audit`, and `flutter pub outdated --mode=null-safety` in CI. | Detects vulnerable dependencies early. |
| Static Analysis | Enable `dart analyze`, `flutter test`, and `composer test` in CI (see `ci-cd.yml`). | Blocks regressions before deployment. |
| Observability | Keep the OpenTelemetry + Prometheus instrumentation enabled in staging/production. | Gives you the Quantum Feedback Loop for anomaly detection. |
| Rollback | `./deploy.sh <env> rollback` preserves service continuity when incidents occur. | Reduces mean time to recovery. |

---

## 6. Smoke Testing Checklist

Before exposing any environment to users, run:

```bash
# Flutter unit & widget tests
flutter test

# Dart analyzer (static checks)
dart analyze

# PHP backend tests
composer install
composer test

# Web performance checks (optional Lighthouse)
npx lhci autorun --config=lighthouse-config.js
```

Confirm the following once deployed:
- `/health` endpoint returns HTTP 200.
- WebSocket handshake succeeds (`wss://.../ws`).
- Database migrations executed successfully.
- Telemetry dashboards receive traces and metrics.

This playbook positions the project for rapid experimentation today while keeping a clear, secure path to production-scale deployments.
