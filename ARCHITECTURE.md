# Vision Week - Architecture Overview

This document provides a high-level overview of the technical architecture for the Vision Week Virtual Exploration application.

## 1. Core Components

The application consists of the following main components:

*   **Frontend Application (Client):**
    *   Built with **Flutter (Dart)** for cross-platform compatibility (iOS, Android, Web, Desktop).
    *   Manages the user interface, user interactions, and communication with backend services.
    *   **VR Rendering:** The specifics of VR rendering (e.g., using Flutter plugins like a Unity/Unreal view, direct platform VR SDK integration, or WebXR for the web version) are critical. This component must be highly performant and responsive to VR input methods (controllers, hand tracking, gaze).
    *   Handles local data caching using SQLite.

*   **Backend API:**
    *   Built with **PHP using the Slim micro-framework**.
    *   Provides RESTful API endpoints for the Flutter application.
    *   Responsibilities include:
        *   Managing zoo data, animal information, video metadata, etc. (stored in MySQL).
        *   Handling specific business logic not suited for the client or Firebase.
        *   Potentially managing user interactions data (comments, ratings - if not handled by Firebase).
        *   Subscription management (interfacing with payment gateways).

*   **Database (Primary Application Data):**
    *   **MySQL** is the primary relational database for storing core application data like zoo information, animal details, video content metadata, user subscriptions, etc.

*   **Firebase Services:**
    *   **Firebase Authentication:** Used for user sign-up, sign-in (including Google Sign-In), and overall user session management. Acts as the primary authentication provider.
    *   **Firebase Firestore:** Potentially used for user profiles linked to Firebase Auth, real-time features, or specific data structures suited for a NoSQL model (e.g., user-specific VR exploration state). Role to be clearly defined against MySQL.
    *   **Firebase Crashlytics:** For crash reporting and stability monitoring of the Flutter application.
    *   **Firebase Performance Monitoring:** For monitoring performance aspects of the Flutter application.
    *   **Firebase Analytics:** For tracking user behavior and application usage patterns.

## 2. Technology Choices Rationale

*   **Flutter:** Chosen for its ability to build natively compiled applications for mobile, web, and desktop from a single codebase, enabling rapid development and broad reach. Its declarative UI paradigm is modern and efficient.
*   **PHP (Slim Framework):** Slim is a lightweight, fast micro-framework suitable for building REST APIs. PHP is widely supported. This choice allows for a focused backend API.
*   **MySQL:** A robust and widely-used open-source relational database suitable for structured application data.
*   **Firebase Suite:** Provides essential backend-as-a-service (BaaS) features like authentication, analytics, and crash reporting, reducing development overhead for these common needs and offering a good developer experience with Flutter.

## 3. Data Flow (High-Level)

*   **Authentication:**
    1.  User initiates sign-up/sign-in via the Flutter app.
    2.  Flutter app communicates with Firebase Authentication.
    3.  Firebase Auth handles the process and returns an ID token to the Flutter app upon success.
    4.  Flutter app stores this ID token securely.
    5.  For requests to the PHP/Slim API that require authentication, the Flutter app includes the Firebase ID token in the `Authorization` header.
    6.  The PHP/Slim API verifies the Firebase ID token before processing the request.
*   **Data Retrieval (e.g., Zoo Information):**
    1.  Flutter app makes an authenticated (if required) API call to the PHP/Slim backend.
    2.  PHP/Slim API queries the MySQL database.
    3.  API returns data (e.g., in JSON format) to the Flutter app.
    4.  Flutter app displays the data and may cache it locally using SQLite.

## 4. API Documentation

As REST API endpoints are developed for the PHP/Slim backend, they **must be documented using OpenAPI (Swagger) specifications.** This ensures clarity for frontend developers and facilitates API testing and evolution. The OpenAPI specification file should be maintained within the repository.

## 5. Security Strategy Highlights

*   Authentication is handled by Firebase Authentication. API access is protected via Firebase ID token verification.
*   Database credentials on the backend are managed via environment variables, not hardcoded.
*   HTTPS is enforced for all client-server communication.
*   Flutter app release builds use obfuscation.
*   Input validation is performed on the backend for all API requests.

## 6. Observability Strategy Highlights

*   **Flutter App:** Firebase Crashlytics for error/crash reporting, Firebase Performance Monitoring for app performance, and Firebase Analytics for user behavior.
*   **PHP Backend:** Monolog for structured logging of requests, errors, and business events. Logs are written to files and should be managed appropriately in production.

## 7. Future Considerations / Scalability

*   The PHP/Slim API can be scaled by running multiple instances behind a load balancer.
*   MySQL can be scaled using various strategies (read replicas, sharding if necessary).
*   Firebase services are inherently scalable.
*   For more complex backend logic, consider if certain parts of the PHP monolith could evolve into separate microservices if complexity grows significantly.

This document is intended to be a living document and should be updated as the application architecture evolves.
