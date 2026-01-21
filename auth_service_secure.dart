// lib/security/auth_service_secure.dart
// Service d'authentification sécurisé avec protection contre les attaques
// Version: 1.1.0
// Maintainer: Kevin Marville

import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'input_validator.dart';

/// Service d'authentification sécurisé
class SecureAuthService {
  static const String _baseUrl = String.fromEnvironment(
    'VISION_WEEK_API_BASE_URL',
    defaultValue: 'https://api.visionweek.example.com',
  );
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _loginAttemptsKey = 'login_attempts';
  static const String _lastAttemptKey = 'last_attempt';
  static const int _maxLoginAttempts = 5;
  static const int _lockoutDurationMinutes = 15;
  static const int _requestTimeoutSeconds = 30;
  static const int _logoutTimeoutSeconds = 10;
  static const int _verifyTimeoutSeconds = 10;
  static const int _csrfTimeoutSeconds = 10;
  static const String _userAgent = 'VisionWeek-Mobile/1.1.0';
  static const String _devicePlatform = 'flutter';
  static const String _appVersion = '1.1.0';
  
  // Configuration du stockage sécurisé
  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      keyCipherAlgorithm: KeyCipherAlgorithm.RSA_ECB_PKCS1Padding,
      storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  /// Authentifie un utilisateur avec email et mot de passe.
  /// Retourne un [AuthResult] en cas de succès ou d'échec.
  static Future<AuthResult> login(String email, String password) async {
    try {
      // Vérifier le verrouillage du compte
      final lockoutResult = await _checkAccountLockout();
      if (!lockoutResult.success) {
        return lockoutResult;
      }

      // Valider les entrées
      final emailValidation = InputValidator.validateEmail(email);
      if (!emailValidation.isValid) {
        await _recordFailedAttempt();
        return AuthResult.failure(emailValidation.message);
      }

      final passwordValidation = InputValidator.validatePassword(password);
      if (!passwordValidation.isValid) {
        await _recordFailedAttempt();
        return AuthResult.failure(passwordValidation.message);
      }

      // Préparer la requête avec protection CSRF
      final csrfToken = await _getCsrfToken();
      final deviceFingerprint = await _generateDeviceFingerprint();
      
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': csrfToken,
          'X-Device-Fingerprint': deviceFingerprint,
          'User-Agent': _userAgent,
        },
        body: jsonEncode({
          'email': emailValidation.sanitizedValue,
          'password': password, // Le mot de passe sera hashé côté serveur
          'device_info': await _getDeviceInfo(),
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        }),
      ).timeout(const Duration(seconds: _requestTimeoutSeconds));

      if (response.statusCode == 200) {
        final responsePayload = _decodeJson(response.body);
        if (responsePayload == null) {
          return AuthResult.failure('Réponse du serveur invalide');
        }
        
        // Vérifier la signature de la réponse
        if (!await _verifyResponseSignature(response)) {
          return AuthResult.failure('Réponse du serveur invalide');
        }

        // Stocker les tokens de manière sécurisée
        final accessToken = responsePayload['access_token'] as String?;
        final refreshToken = responsePayload['refresh_token'] as String?;
        final userId = _parseUserId(responsePayload['user_id']);
        if (accessToken == null || refreshToken == null || userId == null) {
          return AuthResult.failure('Réponse du serveur incomplète');
        }
        await _secureStorage.write(key: _tokenKey, value: accessToken);
        await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
        await _secureStorage.write(key: _userIdKey, value: userId.toString());
        
        // Réinitialiser les tentatives de connexion
        await _resetLoginAttempts();
        
        // Enregistrer la session
        await _recordSuccessfulLogin(userId);
        
        return AuthResult.success(
          userId: userId,
          accessToken: accessToken,
          refreshToken: refreshToken,
          expiresIn: _parseInt(responsePayload['expires_in']),
        );
      } else {
        await _recordFailedAttempt();
        
        switch (response.statusCode) {
          case 401:
            return AuthResult.failure('Email ou mot de passe incorrect');
          case 423:
            return AuthResult.failure('Compte temporairement verrouillé');
          case 429:
            return AuthResult.failure('Trop de tentatives. Réessayez plus tard');
          default:
            return AuthResult.failure('Erreur de connexion');
        }
      }
    } on FormatException {
      await _recordFailedAttempt();
      return AuthResult.failure('Réponse du serveur invalide');
    } on http.ClientException {
      await _recordFailedAttempt();
      return AuthResult.failure('Erreur de connexion réseau');
    } catch (e) {
      await _recordFailedAttempt();
      return AuthResult.failure('Erreur de réseau: ${e.toString()}');
    }
  }

  /// Inscription d'un nouvel utilisateur.
  /// Retourne un [AuthResult] décrivant le résultat.
  static Future<AuthResult> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required DateTime birthDate,
    String? phone,
  }) async {
    try {
      // Valider toutes les entrées
      final formValidator = FormValidator();
      
      formValidator.addValidation('email', InputValidator.validateEmail(email));
      formValidator.addValidation('password', InputValidator.validatePassword(password));
      formValidator.addValidation('firstName', InputValidator.validateName(firstName, 'Prénom'));
      formValidator.addValidation('lastName', InputValidator.validateName(lastName, 'Nom'));
      formValidator.addValidation('birthDate', InputValidator.validateBirthDate(birthDate));
      
      if (phone != null && phone.isNotEmpty) {
        formValidator.addValidation('phone', InputValidator.validatePhone(phone));
      }

      if (!formValidator.isValid) {
        final errors = formValidator.errors.values.join(', ');
        return AuthResult.failure(errors);
      }

      // Générer un salt unique pour l'utilisateur
      final salt = InputValidator.generateSalt();
      final hashedPassword = InputValidator.hashPassword(password, salt);
      
      final csrfToken = await _getCsrfToken();
      final deviceFingerprint = await _generateDeviceFingerprint();

      final response = await http.post(
        Uri.parse('$_baseUrl/auth/register'),
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': csrfToken,
          'X-Device-Fingerprint': deviceFingerprint,
          'User-Agent': _userAgent,
        },
        body: jsonEncode({
          'email': formValidator.sanitizedValues['email'],
          'password_hash': hashedPassword,
          'salt': salt,
          'first_name': formValidator.sanitizedValues['firstName'],
          'last_name': formValidator.sanitizedValues['lastName'],
          'birth_date': birthDate.toIso8601String(),
          'phone': formValidator.sanitizedValues['phone'],
          'device_info': await _getDeviceInfo(),
          'consent_gdpr': true,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        }),
      ).timeout(const Duration(seconds: _requestTimeoutSeconds));

      if (response.statusCode == 201) {
        final responsePayload = _decodeJson(response.body);
        if (responsePayload == null) {
          return AuthResult.failure('Réponse du serveur invalide');
        }
        return AuthResult.success(
          userId: _parseUserId(responsePayload['user_id']),
          message: 'Inscription réussie. Vérifiez votre email.',
        );
      } else {
        final responsePayload = _decodeJson(response.body);
        final errorMessage = responsePayload?['message'] as String? ?? 'Erreur d\'inscription';
        return AuthResult.failure(errorMessage);
      }
    } on FormatException {
      return AuthResult.failure('Réponse du serveur invalide');
    } on http.ClientException {
      return AuthResult.failure('Erreur de connexion réseau');
    } catch (e) {
      return AuthResult.failure('Erreur de réseau: ${e.toString()}');
    }
  }

  /// Rafraîchit le token d'accès.
  /// Retourne un [AuthResult] avec le nouveau token si disponible.
  static Future<AuthResult> refreshToken() async {
    try {
      final refreshToken = await _secureStorage.read(key: _refreshTokenKey);
      if (refreshToken == null) {
        return AuthResult.failure('Token de rafraîchissement manquant');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/auth/refresh'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $refreshToken',
        },
        body: jsonEncode({
          'refresh_token': refreshToken,
          'device_fingerprint': await _generateDeviceFingerprint(),
        }),
      ).timeout(const Duration(seconds: _requestTimeoutSeconds));

      if (response.statusCode == 200) {
        final responsePayload = _decodeJson(response.body);
        final accessToken = responsePayload?['access_token'] as String?;
        if (accessToken == null) {
          return AuthResult.failure('Réponse du serveur invalide');
        }
        await _secureStorage.write(key: _tokenKey, value: accessToken);
        
        return AuthResult.success(
          accessToken: accessToken,
          expiresIn: _parseInt(responsePayload?['expires_in']),
        );
      } else {
        await logout(); // Token invalide, déconnecter l'utilisateur
        return AuthResult.failure('Session expirée');
      }
    } on FormatException {
      return AuthResult.failure('Réponse du serveur invalide');
    } on http.ClientException {
      return AuthResult.failure('Erreur de connexion réseau');
    } catch (e) {
      return AuthResult.failure('Erreur de rafraîchissement: ${e.toString()}');
    }
  }

  /// Déconnecte l'utilisateur et nettoie le stockage local.
  static Future<void> logout() async {
    try {
      final token = await _secureStorage.read(key: _tokenKey);
      if (token != null) {
        // Informer le serveur de la déconnexion
        await http.post(
          Uri.parse('$_baseUrl/auth/logout'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ).timeout(const Duration(seconds: _logoutTimeoutSeconds));
      }
    } catch (e) {
      // Ignorer les erreurs de déconnexion côté serveur
    } finally {
      // Nettoyer le stockage local
      await _secureStorage.deleteAll();
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    }
  }

  /// Vérifie si l'utilisateur est connecté.
  /// Retourne `true` si le token est valide, sinon `false`.
  static Future<bool> isLoggedIn() async {
    final token = await _secureStorage.read(key: _tokenKey);
    if (token == null) return false;
    
    // Vérifier si le token est encore valide
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/auth/verify'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: _verifyTimeoutSeconds));
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Récupère le token d'accès actuel.
  static Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  /// Récupère l'ID de l'utilisateur connecté.
  static Future<String?> getCurrentUserId() async {
    return await _secureStorage.read(key: _userIdKey);
  }

  /// Demande de réinitialisation de mot de passe.
  /// Retourne un [AuthResult] décrivant le résultat.
  static Future<AuthResult> requestPasswordReset(String email) async {
    try {
      final emailValidation = InputValidator.validateEmail(email);
      if (!emailValidation.isValid) {
        return AuthResult.failure(emailValidation.message);
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/auth/password-reset'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': emailValidation.sanitizedValue,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        }),
      ).timeout(const Duration(seconds: _requestTimeoutSeconds));

      if (response.statusCode == 200) {
        return AuthResult.success(
          message: 'Instructions envoyées par email',
        );
      } else {
        return AuthResult.failure('Erreur lors de la demande');
      }
    } on FormatException {
      return AuthResult.failure('Réponse du serveur invalide');
    } on http.ClientException {
      return AuthResult.failure('Erreur de connexion réseau');
    } catch (e) {
      return AuthResult.failure('Erreur de réseau: ${e.toString()}');
    }
  }

  /// Vérifie le verrouillage du compte
  static Future<AuthResult> _checkAccountLockout() async {
    final prefs = await SharedPreferences.getInstance();
    final attempts = prefs.getInt(_loginAttemptsKey) ?? 0;
    final lastAttempt = prefs.getInt(_lastAttemptKey) ?? 0;
    
    if (attempts >= _maxLoginAttempts) {
      final lockoutEnd = lastAttempt + (_lockoutDurationMinutes * 60 * 1000);
      final now = DateTime.now().millisecondsSinceEpoch;
      
      if (now < lockoutEnd) {
        final remainingMinutes = ((lockoutEnd - now) / (60 * 1000)).ceil();
        return AuthResult.failure(
          'Compte verrouillé. Réessayez dans $remainingMinutes minutes.'
        );
      } else {
        // Réinitialiser après expiration du verrouillage
        await _resetLoginAttempts();
      }
    }
    
    return AuthResult.success();
  }

  /// Enregistre une tentative de connexion échouée
  static Future<void> _recordFailedAttempt() async {
    final prefs = await SharedPreferences.getInstance();
    final attempts = (prefs.getInt(_loginAttemptsKey) ?? 0) + 1;
    await prefs.setInt(_loginAttemptsKey, attempts);
    await prefs.setInt(_lastAttemptKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Réinitialise les tentatives de connexion
  static Future<void> _resetLoginAttempts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_loginAttemptsKey);
    await prefs.remove(_lastAttemptKey);
  }

  /// Enregistre une connexion réussie
  static Future<void> _recordSuccessfulLogin(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_login', DateTime.now().millisecondsSinceEpoch);
    await prefs.setInt('user_id', userId);
  }

  /// Génère une empreinte unique de l'appareil.
  static Future<String> _generateDeviceFingerprint() async {
    final deviceInfo = await _getDeviceInfo();
    final fingerprint = sha256.convert(utf8.encode(deviceInfo.toString()));
    return fingerprint.toString();
  }

  /// Récupère les informations de l'appareil.
  static Future<Map<String, dynamic>> _getDeviceInfo() async {
    // Implémentation simplifiée - à compléter avec device_info_plus
    return {
      'platform': _devicePlatform,
      'version': _appVersion,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
  }

  /// Récupère un token CSRF du serveur.
  static Future<String> _getCsrfToken() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/auth/csrf-token'),
      ).timeout(const Duration(seconds: _csrfTimeoutSeconds));
      
      if (response.statusCode == 200) {
        final responsePayload = _decodeJson(response.body);
        final csrfToken = responsePayload?['csrf_token'] as String?;
        if (csrfToken != null && csrfToken.isNotEmpty) {
          return csrfToken;
        }
      }
    } on FormatException {
      return InputValidator.generateSecureToken();
    } catch (e) {
      // Fallback: générer un token côté client
    }
    
    return InputValidator.generateSecureToken();
  }

  /// Vérifie la signature de la réponse du serveur.
  static Future<bool> _verifyResponseSignature(http.Response response) async {
    // Implémentation simplifiée - à compléter avec la vérification HMAC
    final signature = response.headers['x-signature'];
    return signature != null && signature.isNotEmpty;
  }

  /// Active l'authentification à deux facteurs.
  /// Retourne un [AuthResult] indiquant le succès ou l'échec.
  static Future<AuthResult> enableTwoFactor() async {
    try {
      final token = await getAccessToken();
      if (token == null) {
        return AuthResult.failure('Non authentifié');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/auth/2fa/enable'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: _requestTimeoutSeconds));

      if (response.statusCode == 200) {
        final responsePayload = _decodeJson(response.body) ?? {};
        return AuthResult.success(
          message: 'Authentification à deux facteurs activée',
          data: responsePayload,
        );
      } else {
        return AuthResult.failure('Erreur lors de l\'activation');
      }
    } on FormatException {
      return AuthResult.failure('Réponse du serveur invalide');
    } on http.ClientException {
      return AuthResult.failure('Erreur de connexion réseau');
    } catch (e) {
      return AuthResult.failure('Erreur de réseau: ${e.toString()}');
    }
  }

  /// Vérifie un code 2FA.
  /// Retourne un [AuthResult] indiquant le succès ou l'échec.
  static Future<AuthResult> verifyTwoFactor(String code) async {
    try {
      if (code.trim().isEmpty) {
        return AuthResult.failure('Code 2FA manquant');
      }

      final token = await getAccessToken();
      if (token == null) {
        return AuthResult.failure('Non authentifié');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/auth/2fa/verify'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'code': code}),
      ).timeout(const Duration(seconds: _requestTimeoutSeconds));

      if (response.statusCode == 200) {
        return AuthResult.success(message: 'Code vérifié avec succès');
      } else {
        return AuthResult.failure('Code incorrect');
      }
    } on FormatException {
      return AuthResult.failure('Réponse du serveur invalide');
    } on http.ClientException {
      return AuthResult.failure('Erreur de connexion réseau');
    } catch (e) {
      return AuthResult.failure('Erreur de réseau: ${e.toString()}');
    }
  }

  static Map<String, dynamic>? _decodeJson(String body) {
    if (body.trim().isEmpty) {
      return null;
    }
    final decoded = jsonDecode(body);
    return decoded is Map<String, dynamic> ? decoded : null;
  }

  static int? _parseUserId(dynamic value) {
    return _parseInt(value);
  }

  static int? _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }
}

/// Classe pour le résultat d'authentification.
class AuthResult {
  final bool success;
  final String message;
  final int? userId;
  final String? accessToken;
  final String? refreshToken;
  final int? expiresIn;
  final Map<String, dynamic>? data;

  const AuthResult({
    required this.success,
    required this.message,
    this.userId,
    this.accessToken,
    this.refreshToken,
    this.expiresIn,
    this.data,
  });

  /// Construit un résultat de succès.
  factory AuthResult.success({
    String? message,
    int? userId,
    String? accessToken,
    String? refreshToken,
    int? expiresIn,
    Map<String, dynamic>? data,
  }) {
    return AuthResult(
      success: true,
      message: message ?? 'Succès',
      userId: userId,
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresIn: expiresIn,
      data: data,
    );
  }

  /// Construit un résultat d'échec avec un message lisible.
  factory AuthResult.failure(String message) {
    return AuthResult(
      success: false,
      message: message,
    );
  }

  @override
  String toString() {
    return 'AuthResult(success: $success, message: $message, userId: $userId)';
  }
}
