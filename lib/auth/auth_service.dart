import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  User? get user => _user;

  // Constructor to listen to auth state changes
  AuthService() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  // Asynchronous auth state change handler
  Future<void> _onAuthStateChanged(User? user) async {
    _user = user;
    notifyListeners();
  }

  // Sign-in method with enhanced error handling
  Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      // Check if email is verified before granting access
      if (_auth.currentUser != null && !_auth.currentUser!.emailVerified) {
        return 'Please verify your email before logging in.';
      }

      return null; // Success
    } on FirebaseAuthException catch (e) {
      return _handleAuthError(e);
    } catch (e) {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  // Sign-up method with email verification
  Future<String?> signUp(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);

      // Send email verification after sign-up
      if (_auth.currentUser != null && !_auth.currentUser!.emailVerified) {
        await _auth.currentUser!.sendEmailVerification();
        return 'A verification email has been sent. Please verify your email.';
      }

      return null; // Success
    } on FirebaseAuthException catch (e) {
      return _handleAuthError(e);
    } catch (e) {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  // Sign-out method with error handling
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _user = null;
      notifyListeners();
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  // Password reset functionality
  Future<String?> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return 'Password reset email sent. Please check your inbox.';
    } on FirebaseAuthException catch (e) {
      return _handleAuthError(e);
    } catch (e) {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  // OAuth sign-in example (Google) [Optional]
  Future<String?> signInWithGoogle() async {
    try {
      // Use Firebase Auth to sign in with Google here.
      // e.g., `GoogleSignInAccount googleUser = await GoogleSignIn().signIn();`
      // This requires configuring Google Sign-In in Firebase.
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return _handleAuthError(e);
    } catch (e) {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  // Token fetching for server-side verification
  Future<String?> getAuthToken() async {
    try {
      return await _user?.getIdToken();
    } catch (e) {
      return 'Error retrieving token.';
    }
  }

  // Helper method for FirebaseAuth error handling
  String _handleAuthError(FirebaseAuthException e) {
    String errorMessage;
    switch (e.code) {
      case 'user-not-found':
        errorMessage = 'No user found for this email.';
        break;
      case 'wrong-password':
        errorMessage = 'Incorrect password.';
        break;
      case 'email-already-in-use':
        errorMessage = 'This email is already associated with another account.';
        break;
      case 'weak-password':
        errorMessage = 'Your password is too weak. Please use a stronger password.';
        break;
      case 'invalid-email':
        errorMessage = 'The email format is invalid.';
        break;
      case 'network-request-failed':
        errorMessage = 'Network error. Please check your connection.';
        break;
      default:
        errorMessage = 'An unknown error occurred. Please try again.';
        break;
    }
    return errorMessage;
  }

  // Method to check if the user is logged in
  bool isUserLoggedIn() {
    return _auth.currentUser != null;
  }

  // Optional: Enforce email verification check
  bool isEmailVerified() {
    return _auth.currentUser?.emailVerified ?? false;
  }
}
