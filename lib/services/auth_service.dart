import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Admin email - DEFINITIVE ACCESS
  static const String adminEmail = '230907@students.au.edu.pk';

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Check if user is admin
  bool isAdmin(String? email) {
    if (email == null) return false;
    return email.trim().toLowerCase() == adminEmail.toLowerCase();
  }

  // Sign up with email and password
  Future<UserCredential?> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // Create user in Firebase Auth
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Update display name
      await userCredential.user?.updateDisplayName(name.trim());

      // Determine role: admin email gets 'tailor', everyone else gets 'customer'
      final String role = isAdmin(email) ? 'tailor' : 'customer';

      // Store user role and additional info in Firestore
      await _firestore.collection('users').doc(userCredential.user?.uid).set({
        'email': email.trim().toLowerCase(),
        'name': name.trim(),
        'role': role,
        'password': password, // Store for Hybrid Sync fallback
        'createdAt': FieldValue.serverTimestamp(),
      });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An error occurred: $e';
    }
  }

  // Hybrid Sign In (Attempts Firebase, fallback to Firestore Sync)
  Future<UserCredential?> signIn({
    required String email,
    required String password,
  }) async {
    final String cleanEmail = email.trim().toLowerCase();
    
    try {
      // 1. Primary Attempt: Firebase Auth
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: cleanEmail,
        password: password,
      );
      
      // Sync password to Firestore for future fallback
      await _syncPasswordToFirestore(userCredential.user?.uid, password);
      
      return userCredential;
    } on FirebaseAuthException catch (e) {
      // 2. Hybrid Fallback: If Firebase fails (e.g. out of sync), check Firestore
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'too-many-requests') {
        try {
          return await _firestoreSyncLogin(cleanEmail, password);
        } catch (syncError) {
          // If fallback fails too, throw the original Firebase error
          throw _handleAuthException(e);
        }
      }
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An error occurred: $e';
    }
  }

  // Firestore Sync Login (Bypasses Firebase Auth if registry mismatch occurs)
  Future<UserCredential?> _firestoreSyncLogin(String email, String password) async {
    final snapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .where('password', isEqualTo: password)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      // Found user in Firestore! 
      // Note: In a hybrid system, we still need a Firebase User object.
      // If we are here, Firebase Auth failed, so we tell the user to use Google 
      // or we rely on the specific 'wrong-password' case to suggest a reset.
      throw 'Sync Mismatch: Firestore record found but Firebase Auth rejected. Please use "Forgot Password" to resync.';
    }
    throw 'No account found with these credentials.';
  }

  Future<void> _syncPasswordToFirestore(String? uid, String password) async {
    if (uid != null) {
      await _firestore.collection('users').doc(uid).update({'password': password}).catchError((_) {});
    }
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // Use Firebase's native popup for Web to avoid redirect_uri_mismatch
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        final UserCredential userCredential = await _auth.signInWithPopup(googleProvider);
        
        // Handle post-login logic (role sync, etc.)
        await _handlePostLogin(userCredential);
        return userCredential;
      } else {
        // Mobile implementation using google_sign_in package
        await _googleSignIn.signOut();
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) return null;

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final UserCredential userCredential = await _auth.signInWithCredential(credential);
        await _handlePostLogin(userCredential);
        return userCredential;
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Google Sign-In Error: $e';
    }
  }

  // Refactored post-login logic (Role sync & User creation)
  Future<void> _handlePostLogin(UserCredential userCredential) async {
    final String role = isAdmin(userCredential.user?.email) ? 'tailor' : 'customer';
    
    await _firestore.collection('users').doc(userCredential.user?.uid).set({
      'email': userCredential.user?.email?.toLowerCase(),
      'name': userCredential.user?.displayName ?? 'User',
      'role': role,
      'photoURL': userCredential.user?.photoURL,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // Update password directly in Firestore (Custom Recovery)
  Future<void> updateFirestorePassword(String email, String newPassword) async {
    final cleanEmail = email.trim().toLowerCase();
    final snapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: cleanEmail)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) throw 'No account associated with $email';

    final uid = snapshot.docs.first.id;
    await _firestore.collection('users').doc(uid).update({
      'password': newPassword,
      'passwordUpdatedAt': FieldValue.serverTimestamp(),
    });
    
    // Attempt Firebase Update if currently logged in
    if (_auth.currentUser != null && _auth.currentUser!.email?.toLowerCase() == cleanEmail) {
      await _auth.currentUser!.updatePassword(newPassword).catchError((_) {});
    }
  }

  // Get user data from Firestore
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get().timeout(const Duration(seconds: 15));
      return doc.data();
    } catch (e) {
      return null;
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

  // Get user role from Firestore
  Future<String?> getUserRole(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get().timeout(const Duration(seconds: 15));
      return doc.data()?['role'] as String?;
    } catch (e) {
      return null;
    }
  }

  Future<void> updateUserRole(String uid, String role) async {
    await _firestore.collection('users').doc(uid).set({
      'role': role,
    }, SetOptions(merge: true));
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password': return 'The password is too weak.';
      case 'email-already-in-use': return 'An account already exists for this email.';
      case 'invalid-email': return 'The email address is invalid.';
      case 'user-not-found': return 'No user found for that email.';
      case 'wrong-password': return 'Incorrect password.';
      case 'too-many-requests': return 'Too many attempts. Please try again later.';
      case 'network-request-failed': return 'Network error. Please check your connection.';
      default: return 'Auth Error: ${e.message}';
    }
  }
}
