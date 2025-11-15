import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

enum UserRole { explorer, seller, courier, admin }

/// Thin wrapper around [FirebaseAuth] that exposes a listenable authentication
/// state to the rest of the application. By notifying listeners whenever the
/// status changes we can keep navigation, guards and widgets in sync without
/// scattering Firebase specific logic throughout the UI layer.
class AuthService extends ChangeNotifier {
  AuthService() {
    _subscription = _auth.userChanges().listen(_handleUserChanged);
    _handleUserChanged(_auth.currentUser);
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final StreamSubscription<User?> _subscription;

  AuthStatus _status = AuthStatus.unknown;
  User? _user;
  UserRole _role = UserRole.explorer;

  AuthStatus get status => _status;
  User? get user => _user;
  UserRole get role => _role;
  bool get isLoading => _status == AuthStatus.unknown;
  List<UserRole> get supportedRoles => List<UserRole>.unmodifiable(UserRole.values);

  Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      if (_auth.currentUser != null && !_auth.currentUser!.emailVerified) {
        return 'Please verify your email before logging in.';
      }
      return null;
    } on FirebaseAuthException catch (error) {
      return _mapFirebaseError(error);
    } catch (error, stackTrace) {
      debugPrint('Unexpected signIn error: $error\n$stackTrace');
      return 'An unexpected error occurred. Please try again.';
    }
  }

  Future<String?> signUp(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      if (_auth.currentUser != null && !_auth.currentUser!.emailVerified) {
        await _auth.currentUser!.sendEmailVerification();
        return 'A verification email has been sent. Please verify your email.';
      }
      return null;
    } on FirebaseAuthException catch (error) {
      return _mapFirebaseError(error);
    } catch (error, stackTrace) {
      debugPrint('Unexpected signUp error: $error\n$stackTrace');
      return 'An unexpected error occurred. Please try again.';
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> selectRole(UserRole nextRole) async {
    if (_role == nextRole) {
      return;
    }
    _role = nextRole;
    notifyListeners();
  }

  Future<String?> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return 'Password reset email sent. Please check your inbox.';
    } on FirebaseAuthException catch (error) {
      return _mapFirebaseError(error);
    } catch (error, stackTrace) {
      debugPrint('Unexpected password reset error: $error\n$stackTrace');
      return 'An unexpected error occurred. Please try again.';
    }
  }

  Future<String?> getAuthToken() async {
    try {
      return await _user?.getIdToken();
    } catch (error, stackTrace) {
      debugPrint('Unable to fetch auth token: $error\n$stackTrace');
      return 'Error retrieving token.';
    }
  }

  bool isUserLoggedIn() => _status == AuthStatus.authenticated && _user != null;

  bool get isEmailVerified => _user?.emailVerified ?? false;

  void _handleUserChanged(User? user) {
    _user = user;
    _status = user == null ? AuthStatus.unauthenticated : AuthStatus.authenticated;
    if (user == null) {
      _role = UserRole.explorer;
      notifyListeners();
      return;
    }

    notifyListeners();
    unawaited(_hydrateRoleFromClaims(user));
  }

  String _mapFirebaseError(FirebaseAuthException exception) {
    switch (exception.code) {
      case 'user-not-found':
        return 'No user found for this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'This email is already associated with another account.';
      case 'weak-password':
        return 'Your password is too weak. Please use a stronger password.';
      case 'invalid-email':
        return 'The email format is invalid.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return 'An unknown error occurred. Please try again.';
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  Future<void> _hydrateRoleFromClaims(User user) async {
    try {
      final result = await user.getIdTokenResult(true);
      final roleClaim = result.claims?['role'];
      final resolvedRole = _roleFromClaim(roleClaim);
      if (resolvedRole != null && resolvedRole != _role) {
        _role = resolvedRole;
        notifyListeners();
      }
    } catch (error, stackTrace) {
      debugPrint('Unable to hydrate user role from claims: $error\n$stackTrace');
    }
  }

  UserRole? _roleFromClaim(Object? claim) {
    if (claim is String) {
      switch (claim.toLowerCase()) {
        case 'seller':
        case 'merchant':
          return UserRole.seller;
        case 'courier':
        case 'rider':
          return UserRole.courier;
        case 'admin':
        case 'administrator':
          return UserRole.admin;
        case 'explorer':
        case 'customer':
          return UserRole.explorer;
      }
    }
    return null;
  }

  String roleDisplayName(UserRole role) {
    switch (role) {
      case UserRole.explorer:
        return 'Explorer';
      case UserRole.seller:
        return 'Seller';
      case UserRole.courier:
        return 'Courier';
      case UserRole.admin:
        return 'Admin';
    }
  }
}
