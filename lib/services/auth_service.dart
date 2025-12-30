import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Admin email - change this to your desired admin email
  static const String adminEmail = 'admin@gracetailor.com';

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Check if user is admin
  bool isAdmin(String? email) {
    return email?.toLowerCase() == adminEmail.toLowerCase();
  }

  // Sign up with email and password
  // All new users are automatically assigned 'customer' role
  // Only admin email gets 'tailor' role
  Future<UserCredential?> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // Create user in Firebase Auth
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await userCredential.user?.updateDisplayName(name);

      // Determine role: admin email gets 'tailor', everyone else gets 'customer'
      final String role = isAdmin(email) ? 'tailor' : 'customer';

      // Store user role and additional info in Firestore
      await _firestore.collection('users').doc(userCredential.user?.uid).set({
        'email': email,
        'name': name,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An error occurred: $e';
    }
  }

  // Sign in with email and password
  Future<UserCredential?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An error occurred: $e';
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An error occurred: $e';
    }
  }

  // Get user role from Firestore
  Future<String?> getUserRole(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get().timeout(const Duration(seconds: 15));
      return doc.data()?['role'] as String?;
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Firestore Error getting user role ($uid): $e');
      return null;
    }
  }

  // Get user data from Firestore
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get().timeout(const Duration(seconds: 15));
      return doc.data();
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Firestore Error getting user data ($uid): $e');
      return null;
    }
  }

  // Stream of user role
  Stream<String?> getUserRoleStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map(
      (doc) => doc.data()?['role'] as String?,
    );
  }

  // Update user role in Firestore
  Future<void> updateUserRole(String uid, String role) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'role': role,
      }, SetOptions(merge: true));
    } catch (e) {
      if (kDebugMode) debugPrint('Error updating user role: $e');
    }
  }

  // Update user data in Firestore
  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(uid).set(data, SetOptions(merge: true));
    } catch (e) {
      if (kDebugMode) debugPrint('Error updating user data: $e');
    }
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      default:
        return 'An authentication error occurred: ${e.message}';
    }
  }
}

