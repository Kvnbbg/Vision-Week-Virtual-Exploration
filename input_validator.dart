// lib/security/input_validator.dart
// Système de validation et sanitization des entrées utilisateur
// Version: 1.1.0
// Maintainer: Kevin Marville

import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:validators/validators.dart';
import 'package:email_validator/email_validator.dart';

/// Classe principale pour la validation et sanitization des entrées
class InputValidator {
  // Expressions régulières pour la validation
  static final RegExp _nameRegex = RegExp(r'^[a-zA-ZÀ-ÿ\s\-\']{2,50}$');
  static final RegExp _passwordRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');
  static final RegExp _phoneRegex = RegExp(r'^\+?[1-9]\d{1,14}$');
  static final RegExp _alphanumericRegex = RegExp(r'^[a-zA-Z0-9\s\-_]{1,100}$');
  static final RegExp _sqlInjectionRegex = RegExp(r'(\b(SELECT|INSERT|UPDATE|DELETE|DROP|CREATE|ALTER|EXEC|UNION|SCRIPT)\b)', caseSensitive: false);
  static final RegExp _xssRegex = RegExp(r'<[^>]*>|javascript:|vbscript:|onload|onerror|onclick', caseSensitive: false);
  
  // Listes de mots interdits
  static const List<String> _forbiddenWords = [
    'admin', 'root', 'administrator', 'system', 'test', 'guest',
    'null', 'undefined', 'script', 'eval', 'function'
  ];
  
  static const List<String> _profanityWords = [
    // Liste de mots inappropriés à compléter selon les besoins
    'spam', 'fake', 'scam'
  ];

  /// Valide et sanitise une adresse email
  static ValidationResult validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return ValidationResult(false, 'L\'adresse email est requise');
    }
    
    final sanitized = sanitizeString(email);
    
    if (!EmailValidator.validate(sanitized)) {
      return ValidationResult(false, 'Format d\'email invalide');
    }
    
    if (sanitized.length > 100) {
      return ValidationResult(false, 'L\'adresse email est trop longue (max 100 caractères)');
    }
    
    // Vérifier les domaines suspects
    final suspiciousDomains = ['tempmail.com', '10minutemail.com', 'guerrillamail.com'];
    final domain = sanitized.split('@').last.toLowerCase();
    if (suspiciousDomains.contains(domain)) {
      return ValidationResult(false, 'Domaine email non autorisé');
    }
    
    return ValidationResult(true, 'Email valide', sanitized);
  }

  /// Valide un mot de passe selon les critères de sécurité
  static ValidationResult validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return ValidationResult(false, 'Le mot de passe est requis');
    }
    
    if (password.length < 8) {
      return ValidationResult(false, 'Le mot de passe doit contenir au moins 8 caractères');
    }
    
    if (password.length > 128) {
      return ValidationResult(false, 'Le mot de passe est trop long (max 128 caractères)');
    }
    
    if (!_passwordRegex.hasMatch(password)) {
      return ValidationResult(false, 
        'Le mot de passe doit contenir au moins une minuscule, une majuscule, un chiffre et un caractère spécial');
    }
    
    // Vérifier les mots de passe communs
    final commonPasswords = [
      'password', '123456', 'qwerty', 'abc123', 'password123',
      'admin', 'letmein', 'welcome', 'monkey', 'dragon'
    ];
    
    if (commonPasswords.contains(password.toLowerCase())) {
      return ValidationResult(false, 'Ce mot de passe est trop commun');
    }
    
    return ValidationResult(true, 'Mot de passe valide');
  }

  /// Valide un nom (prénom ou nom de famille)
  static ValidationResult validateName(String? name, String fieldName) {
    if (name == null || name.isEmpty) {
      return ValidationResult(false, '$fieldName est requis');
    }
    
    final sanitized = sanitizeString(name);
    
    if (!_nameRegex.hasMatch(sanitized)) {
      return ValidationResult(false, '$fieldName contient des caractères invalides');
    }
    
    if (sanitized.length < 2) {
      return ValidationResult(false, '$fieldName doit contenir au moins 2 caractères');
    }
    
    if (sanitized.length > 50) {
      return ValidationResult(false, '$fieldName est trop long (max 50 caractères)');
    }
    
    // Vérifier les mots interdits
    if (_containsForbiddenWords(sanitized)) {
      return ValidationResult(false, '$fieldName contient des mots non autorisés');
    }
    
    return ValidationResult(true, '$fieldName valide', sanitized);
  }

  /// Valide un numéro de téléphone
  static ValidationResult validatePhone(String? phone) {
    if (phone == null || phone.isEmpty) {
      return ValidationResult(false, 'Le numéro de téléphone est requis');
    }
    
    final sanitized = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    
    if (!_phoneRegex.hasMatch(sanitized)) {
      return ValidationResult(false, 'Format de téléphone invalide');
    }
    
    return ValidationResult(true, 'Téléphone valide', sanitized);
  }

  /// Valide une date de naissance
  static ValidationResult validateBirthDate(DateTime? birthDate) {
    if (birthDate == null) {
      return ValidationResult(false, 'La date de naissance est requise');
    }
    
    final now = DateTime.now();
    final age = now.year - birthDate.year;
    
    if (birthDate.isAfter(now)) {
      return ValidationResult(false, 'La date de naissance ne peut pas être dans le futur');
    }
    
    if (age < 13) {
      return ValidationResult(false, 'Vous devez avoir au moins 13 ans');
    }
    
    if (age > 120) {
      return ValidationResult(false, 'Date de naissance invalide');
    }
    
    return ValidationResult(true, 'Date de naissance valide');
  }

  /// Valide un commentaire ou contenu textuel
  static ValidationResult validateComment(String? comment) {
    if (comment == null || comment.isEmpty) {
      return ValidationResult(false, 'Le commentaire ne peut pas être vide');
    }
    
    final sanitized = sanitizeHtml(comment);
    
    if (sanitized.length < 5) {
      return ValidationResult(false, 'Le commentaire doit contenir au moins 5 caractères');
    }
    
    if (sanitized.length > 1000) {
      return ValidationResult(false, 'Le commentaire est trop long (max 1000 caractères)');
    }
    
    // Vérifier les injections SQL
    if (_sqlInjectionRegex.hasMatch(sanitized)) {
      return ValidationResult(false, 'Contenu non autorisé détecté');
    }
    
    // Vérifier la profanité
    if (_containsProfanity(sanitized)) {
      return ValidationResult(false, 'Le commentaire contient du contenu inapproprié');
    }
    
    return ValidationResult(true, 'Commentaire valide', sanitized);
  }

  /// Valide une note (1-5)
  static ValidationResult validateRating(int? rating) {
    if (rating == null) {
      return ValidationResult(false, 'La note est requise');
    }
    
    if (rating < 1 || rating > 5) {
      return ValidationResult(false, 'La note doit être entre 1 et 5');
    }
    
    return ValidationResult(true, 'Note valide');
  }

  /// Valide un fichier uploadé
  static ValidationResult validateFile(String fileName, int fileSize, List<int> fileBytes) {
    // Vérifier l'extension
    final allowedExtensions = ['jpg', 'jpeg', 'png', 'gif', 'mp4', 'webm', 'pdf'];
    final extension = fileName.split('.').last.toLowerCase();
    
    if (!allowedExtensions.contains(extension)) {
      return ValidationResult(false, 'Type de fichier non autorisé');
    }
    
    // Vérifier la taille (10MB max)
    if (fileSize > 10 * 1024 * 1024) {
      return ValidationResult(false, 'Fichier trop volumineux (max 10MB)');
    }
    
    // Vérifier la signature du fichier (magic numbers)
    if (!_validateFileSignature(fileBytes, extension)) {
      return ValidationResult(false, 'Fichier corrompu ou type incorrect');
    }
    
    return ValidationResult(true, 'Fichier valide');
  }

  /// Sanitise une chaîne de caractères générique
  static String sanitizeString(String input) {
    return input
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ') // Normaliser les espaces
        .replaceAll(RegExp(r'[^\w\s\-@.àâäéèêëïîôöùûüÿç]', unicode: true), ''); // Garder seulement les caractères autorisés
  }

  /// Sanitise le HTML pour éviter les attaques XSS
  static String sanitizeHtml(String input) {
    return input
        .replaceAll(RegExp(r'<[^>]*>'), '') // Supprimer toutes les balises HTML
        .replaceAll(RegExp(r'javascript:', caseSensitive: false), '')
        .replaceAll(RegExp(r'vbscript:', caseSensitive: false), '')
        .replaceAll(RegExp(r'on\w+\s*=', caseSensitive: false), '')
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;');
  }

  /// Génère un token sécurisé
  static String generateSecureToken([int length = 32]) {
    final bytes = List<int>.generate(length, (i) => 
        DateTime.now().millisecondsSinceEpoch + i);
    return sha256.convert(bytes).toString().substring(0, length);
  }

  /// Hash un mot de passe avec salt
  static String hashPassword(String password, String salt) {
    final bytes = utf8.encode(password + salt);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Génère un salt aléatoire
  static String generateSalt() {
    return generateSecureToken(16);
  }

  /// Vérifie si le texte contient des mots interdits
  static bool _containsForbiddenWords(String text) {
    final lowerText = text.toLowerCase();
    return _forbiddenWords.any((word) => lowerText.contains(word));
  }

  /// Vérifie si le texte contient de la profanité
  static bool _containsProfanity(String text) {
    final lowerText = text.toLowerCase();
    return _profanityWords.any((word) => lowerText.contains(word));
  }

  /// Valide la signature d'un fichier
  static bool _validateFileSignature(List<int> bytes, String extension) {
    if (bytes.isEmpty) return false;
    
    // Signatures de fichiers (magic numbers)
    final signatures = {
      'jpg': [0xFF, 0xD8, 0xFF],
      'jpeg': [0xFF, 0xD8, 0xFF],
      'png': [0x89, 0x50, 0x4E, 0x47],
      'gif': [0x47, 0x49, 0x46],
      'pdf': [0x25, 0x50, 0x44, 0x46],
      'mp4': [0x00, 0x00, 0x00, 0x18, 0x66, 0x74, 0x79, 0x70],
    };
    
    final expectedSignature = signatures[extension];
    if (expectedSignature == null) return false;
    
    if (bytes.length < expectedSignature.length) return false;
    
    for (int i = 0; i < expectedSignature.length; i++) {
      if (bytes[i] != expectedSignature[i]) return false;
    }
    
    return true;
  }

  /// Valide une URL
  static ValidationResult validateUrl(String? url) {
    if (url == null || url.isEmpty) {
      return ValidationResult(false, 'L\'URL est requise');
    }
    
    if (!isURL(url)) {
      return ValidationResult(false, 'Format d\'URL invalide');
    }
    
    // Vérifier les protocoles autorisés
    if (!url.startsWith('https://') && !url.startsWith('http://')) {
      return ValidationResult(false, 'Protocole non autorisé');
    }
    
    return ValidationResult(true, 'URL valide');
  }

  /// Valide des coordonnées GPS
  static ValidationResult validateCoordinates(double? latitude, double? longitude) {
    if (latitude == null || longitude == null) {
      return ValidationResult(false, 'Les coordonnées sont requises');
    }
    
    if (latitude < -90 || latitude > 90) {
      return ValidationResult(false, 'Latitude invalide (-90 à 90)');
    }
    
    if (longitude < -180 || longitude > 180) {
      return ValidationResult(false, 'Longitude invalide (-180 à 180)');
    }
    
    return ValidationResult(true, 'Coordonnées valides');
  }
}

/// Classe pour le résultat de validation
class ValidationResult {
  final bool isValid;
  final String message;
  final String? sanitizedValue;
  
  const ValidationResult(this.isValid, this.message, [this.sanitizedValue]);
  
  @override
  String toString() {
    return 'ValidationResult(isValid: $isValid, message: $message, sanitizedValue: $sanitizedValue)';
  }
}

/// Classe pour la validation de formulaires complets
class FormValidator {
  final Map<String, ValidationResult> _results = {};
  
  /// Ajoute un résultat de validation
  void addValidation(String field, ValidationResult result) {
    _results[field] = result;
  }
  
  /// Vérifie si tous les champs sont valides
  bool get isValid => _results.values.every((result) => result.isValid);
  
  /// Récupère les erreurs
  Map<String, String> get errors {
    final errors = <String, String>{};
    _results.forEach((field, result) {
      if (!result.isValid) {
        errors[field] = result.message;
      }
    });
    return errors;
  }
  
  /// Récupère les valeurs sanitisées
  Map<String, String> get sanitizedValues {
    final values = <String, String>{};
    _results.forEach((field, result) {
      if (result.isValid && result.sanitizedValue != null) {
        values[field] = result.sanitizedValue!;
      }
    });
    return values;
  }
  
  /// Efface tous les résultats
  void clear() {
    _results.clear();
  }
}

