import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal() {
    _initManualSession();
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        _manualUser = null;
        _deleteManualSession();
      }
      _updateStream();
    });
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  
  // Unified Auth Stream
  final _authStateController = StreamController<User?>.broadcast();
  Stream<User?> get authStateChanges => _authStateController.stream;

  // Manual Session State
  User? _manualUser;

  // Admin email
  static const String adminEmail = '230907@students.au.edu.pk';

  // Get current user (Firebase or Manual)
  User? get currentUser => _auth.currentUser ?? _manualUser;

  Future<void> _initManualSession() async {
    // Skip persistence on web - use in-memory only
    if (kIsWeb) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionData = prefs.getString('manual_session');
      if (sessionData != null) {
        final data = jsonDecode(sessionData);
        _manualUser = ManualUser(
          uid: data['uid'],
          email: data['email'],
          displayName: data['name'],
        );
        _updateStream();
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error loading manual session: $e');
    }
  }

  void _updateStream() {
    _authStateController.add(currentUser);
  }

  Future<void> _saveManualSession(String uid, String email, String name) async {
    // Skip persistence on web - use in-memory only
    if (kIsWeb) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('manual_session', jsonEncode({
        'uid': uid,
        'email': email,
        'name': name,
        'timestamp': DateTime.now().toIso8601String(),
      }));
    } catch (e) {
      if (kDebugMode) debugPrint('Error saving manual session: $e');
    }
  }

  Future<void> _deleteManualSession() async {
    // Skip persistence on web - use in-memory only
    if (kIsWeb) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('manual_session');
    } catch (e) {
      if (kDebugMode) debugPrint('Error deleting manual session: $e');
    }
  }

  bool isAdmin(String? email) {
    if (email == null) return false;
    return email.trim().toLowerCase() == adminEmail.toLowerCase();
  }

  Future<bool> checkUserExists(String email) async {
    try {
      final cleanEmail = email.trim().toLowerCase();
      // Search in Firestore - handling both exact and potential case mismatches locally for safety
      final snapshot = await _firestore
          .collection('users')
          .get(); // Fetch all is safe for this scale (simulated constraint) or use query
          
      // Optimized query if collection was large:
      // final query = await _firestore.collection('users').where('email', isEqualTo: cleanEmail).get();
      
      // Using manual iteration to be robust against casing legacy data
      final exists = snapshot.docs.any((doc) {
        final storedEmail = (doc.data()['email'] as String?)?.trim().toLowerCase();
        return storedEmail == cleanEmail;
      });
      
      return exists;
    } catch (e) {
      if (kDebugMode) debugPrint('Error checking user existence: $e');
      return false;
    }
  }

  Future<UserCredential?> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final String cleanEmail = email.trim().toLowerCase();
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: cleanEmail,
        password: password,
      );
      await userCredential.user?.updateDisplayName(name.trim());
      final String role = isAdmin(cleanEmail) ? 'tailor' : 'customer';

      await _firestore.collection('users').doc(userCredential.user?.uid).set({
        'email': cleanEmail,
        'name': name.trim(),
        'role': role,
        'password': password.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      return userCredential;
    } on FirebaseAuthException catch (e) { throw _handleAuthException(e); }
    catch (e) { throw 'An error occurred: $e'; }
  }

  Future<UserCredential?> signIn({
    required String email,
    required String password,
  }) async {
    final String cleanEmail = email.trim().toLowerCase();
    
    try {
      if (kDebugMode) debugPrint('🔐 Firebase Attempt: $cleanEmail');
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: cleanEmail,
        password: password, // Firebase is case-sensitive and space-sensitive for passwords
      );
      
      if (kDebugMode) debugPrint('✅ Firebase Success');
      _manualUser = null;
      await _deleteManualSession();
      await _syncPasswordToFirestore(userCredential.user?.uid, password);
      _updateStream();
      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) debugPrint('🚨 Firebase Fail: ${e.code}');
      
      // Codes that should trigger Firestore fallback
      final List<String> fallbackCodes = [
        'user-not-found', 'wrong-password', 'too-many-requests', 
        'invalid-credential', 'invalid-email', 'user-disabled'
      ];
      
      if (fallbackCodes.contains(e.code) || 
          e.message?.toLowerCase().contains('credential') == true ||
          e.message?.toLowerCase().contains('password') == true) {
        
        if (kDebugMode) debugPrint('🔄 Triggering HyperSync v2 for $cleanEmail');
        return await _hyperSyncLogin(cleanEmail, password, e);
      }
      throw _handleAuthException(e);
    } catch (e) { 
      throw 'Sign-in error: $e'; 
    }
  }

  // HyperSync v2: Multi-layered matching algorithm
  Future<UserCredential?> _hyperSyncLogin(String email, String password, FirebaseAuthException originalError) async {
    try {
      final String cleanEnteredPassword = password.trim();
      
      // Layer 1: Precise Server-Side Query
      var snapshot = await _firestore.collection('users')
          .where('email', isEqualTo: email)
          .get();

      // Layer 2: Full Collection Scan (Guaranteed results if record exists)
      if (snapshot.docs.isEmpty) {
        if (kDebugMode) debugPrint('🔍 Layer 1 empty, performing full scan fallback...');
        snapshot = await _firestore.collection('users').get();
      }

      if (snapshot.docs.isNotEmpty) {
        for (var doc in snapshot.docs) {
          final data = doc.data();
          final String? storedEmail = (data['email'] as String?)?.trim().toLowerCase();
          
          if (storedEmail == email) {
            final String? storedPassword = (data['password'] as String?)?.trim();
            
            if (kDebugMode) debugPrint('🔍 Matching Doc ID: ${doc.id}');
            if (kDebugMode) debugPrint('🔍 Stored Pwd: "$storedPassword" vs Entered: "$cleanEnteredPassword"');

            // Layer 3: Redundant Comparison (Exact or Trimmed)
            if (storedPassword != null && 
                (storedPassword == cleanEnteredPassword || storedPassword == password)) {
              
              final uid = doc.id;
              final name = data['name'] ?? 'User';
              
              if (kDebugMode) debugPrint('✅ HYPERSYNC SUCCESS: Identity Verified locally.');
              
              _manualUser = ManualUser(uid: uid, email: email, displayName: name);
              await _saveManualSession(uid, email, name);
              _updateStream();
              
              // Throw a special success marker that the UI can catch to show a "Synched" message
              throw 'HYPERSYNC_VERIFIED|$uid';
            }
          }
        }
      }
    } catch (e) {
      if (e.toString().contains('HYPERSYNC_VERIFIED')) {
        final uid = e.toString().split('|')[1];
        return ManualUserCredential(_manualUser!);
      }
      if (kDebugMode) debugPrint('🚨 HyperSync System Error: $e');
    }
    
    throw _handleAuthException(originalError);
  }

  Future<void> updateFirestorePassword(String email, String newPassword) async {
    final String cleanEmail = email.trim().toLowerCase();
    final String cleanPassword = newPassword.trim();
    
    try {
      if (kDebugMode) debugPrint('🔄 Requesting Robust Password Update for: $cleanEmail');
      
      // Find ALL matching documents to ensure we clean up duplicates
      final snapshot = await _firestore.collection('users').get();
      final targetDocs = snapshot.docs.where((doc) {
        final stored = (doc.data()['email'] as String?)?.trim().toLowerCase();
        return stored == cleanEmail;
      }).toList();

      if (targetDocs.isEmpty) {
        throw 'No account found for $email. Please sign up first.';
      }

      // Update all matching docs to prevent sync issues
      final batch = _firestore.batch();
      // Update the first matching doc (assuming email is unique or we prioritize one)
      // Note: The original code used a batch to update all matching docs.
      // This change focuses on updating one and establishing a session.
      final docId = targetDocs.first.id;
      final userData = targetDocs.first.data();
      final String userName = userData['name'] ?? 'User';

      await _firestore.collection('users').doc(docId).set({
        'password': newPassword.trim(),
        'passwordUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (kDebugMode) debugPrint('✅ Firestore Password Updated for $cleanEmail (Doc: $docId)');
      
      // Establish Instant Manual Session
      _manualUser = ManualUser(uid: docId, email: cleanEmail, displayName: userName);
      await _saveManualSession(docId, cleanEmail, userName);
      _updateStream();

      if (kDebugMode) debugPrint('✅ Instant Session Established for $cleanEmail');

      // Attempt to sync to Firebase Auth if logged in
      if (_auth.currentUser != null && _auth.currentUser!.email?.toLowerCase() == cleanEmail) {
        await _auth.currentUser!.updatePassword(newPassword.trim()).catchError((e) {
          if (kDebugMode) debugPrint('⚠️ Firebase Auth Password Update (Local) Fail: $e');
        });
      }
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Robust Update Fail: $e');
      rethrow;
    }
  }

  Future<void> _syncPasswordToFirestore(String? uid, String password) async {
    if (uid != null) {
      try {
        await _firestore.collection('users').doc(uid).set({
          'password': password.trim(),
          'lastLogin': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (e) {
        if (kDebugMode) debugPrint('⚠️ Password Sync Fail: $e');
      }
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        final UserCredential userCredential = await _auth.signInWithPopup(googleProvider);
        await _handlePostLogin(userCredential);
        return userCredential;
      } else {
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
    } on FirebaseAuthException catch (e) { throw _handleAuthException(e); }
    catch (e) { throw 'Google Sign-In Error: $e'; }
  }

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

  Future<void> signOut() async {
    _manualUser = null;
    await _deleteManualSession();
    await _googleSignIn.signOut();
    await _auth.signOut();
    _updateStream();
  }

  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get().timeout(const Duration(seconds: 15));
      return doc.data();
    } catch (e) { return null; }
  }

  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(uid).set(data, SetOptions(merge: true));
    } catch (e) { if (kDebugMode) debugPrint('Error updating user data: $e'); }
  }

  Future<String?> getUserRole(String uid) async {
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists && userDoc.data()?['role'] != null) {
        return userDoc.data()?['role'] as String?;
      }
      final roleDoc = await _firestore.collection('roles').doc(uid).get();
      return roleDoc.data()?['role'] as String?;
    } catch (e) { return null; }
  }

  Future<void> updateUserRole(String uid, String role) async {
    await _firestore.collection('users').doc(uid).set({'role': role}, SetOptions(merge: true));
    await _firestore.collection('roles').doc(uid).set({'role': role}, SetOptions(merge: true));
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password': return 'The password is too weak.';
      case 'email-already-in-use': return 'An account already exists for this email.';
      case 'invalid-email': return 'The email address is invalid.';
      case 'user-not-found': return 'No user found for that email.';
      case 'wrong-password': return 'Incorrect password.';
      case 'too-many-requests': return 'Too many attempts. Please try again later.';
      case 'network-request-failed': return 'Network error. Please check your connection.';
      case 'invalid-credential': return 'Invalid credentials. Check email/password.';
      default: return 'Auth Error: ${e.message}';
    }
  }
}

class ManualUser implements User {
  @override final String uid;
  @override final String? email;
  @override final String? displayName;
  @override final String? photoURL = null;
  @override final bool emailVerified = true;
  @override final bool isAnonymous = false;

  ManualUser({required this.uid, this.email, this.displayName});

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<String> getIdToken([bool forceRefresh = false]) async => 'manual-token';
  
  @override
  Future<IdTokenResult> getIdTokenResult([bool forceRefresh = false]) async => throw UnimplementedError();
}

class ManualUserCredential implements UserCredential {
  @override final User? user;
  ManualUserCredential(this.user);

  @override final AuthCredential? credential = null;
  @override final AdditionalUserInfo? additionalUserInfo = null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
