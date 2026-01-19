import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Register with email and password
  Future<UserCredential> registerWithEmailPassword({
    required String email,
    required String password,
    required String name,
    required String businessName,
    String? phoneNumber,
  }) async {
    try {
      // Create user in Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user document in Firestore
      if (userCredential.user != null) {
        UserModel userModel = UserModel(
          id: userCredential.user!.uid,
          email: email,
          name: name,
          businessName: businessName,
          phoneNumber: phoneNumber,
          role: 'admin',
          createdAt: DateTime.now(),
        );

        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(userModel.toMap());

        // Update display name
        await userCredential.user!.updateDisplayName(name);
      }

      return userCredential;
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: ${e.toString()}');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Get user data from Firestore
  Future<UserModel?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user data: ${e.toString()}');
    }
  }

  // Update user profile
  Future<void> updateUserProfile(UserModel user) async {
    try {
      await _firestore
          .collection('users')
          .doc(user.id)
          .update(user.copyWith(updatedAt: DateTime.now()).toMap());
    } catch (e) {
      throw Exception('Failed to update profile: ${e.toString()}');
    }
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'weak-password':
          return 'Password terlalu lemah';
        case 'email-already-in-use':
          return 'Email sudah digunakan';
        case 'user-not-found':
          return 'User tidak ditemukan';
        case 'wrong-password':
          return 'Password salah';
        case 'invalid-email':
          return 'Email tidak valid';
        case 'user-disabled':
          return 'User telah dinonaktifkan';
        case 'too-many-requests':
          return 'Terlalu banyak percobaan, coba lagi nanti';
        default:
          return 'Terjadi kesalahan: ${e.message}';
      }
    }
    return 'Terjadi kesalahan: ${e.toString()}';
  }
}
