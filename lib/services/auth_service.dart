import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './shared_prefs_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign up with email and password
  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
  }) async {
    try {
      // Create user with email and password
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save additional user data to Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Save user session locally
      await SharedPrefsService.saveUserSession(
        email: email,
        userId: userCredential.user!.uid,
        name: fullName,
        phone: phoneNumber,
      );

      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  // Sign in with email and password
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get user data from Firestore
      final userData =
          await _firestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .get();

      // Save user session locally
      await SharedPrefsService.saveUserSession(
        email: email,
        userId: userCredential.user!.uid,
        name: userData.data()?['fullName'] ?? '',
        phone: userData.data()?['phoneNumber'] ?? '',
      );

      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    await SharedPrefsService.clearSession();
  }

  // Check if user is already logged in
  Future<bool> isUserLoggedIn() async {
    return SharedPrefsService.isUserLoggedIn();
  }

  // Get current user data
  Future<Map<String, dynamic>?> getCurrentUserData() async {
    final userId = await SharedPrefsService.getUserId();
    if (userId == null) return null;

    final doc = await _firestore.collection('users').doc(userId).get();
    return doc.data();
  }

  // Fetch all users (for admin)
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final querySnapshot = await _firestore.collection('users').get();
    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  // Delete a user (from Firestore only)
  Future<void> deleteUser(String userId) async {
    await _firestore.collection('users').doc(userId).delete();
    // Optionally, also delete from Firebase Auth if needed (requires admin privileges)
  }
}
