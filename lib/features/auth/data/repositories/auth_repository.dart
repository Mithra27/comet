import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comet/core/services/auth_service.dart';
import 'package:comet/features/auth/data/models/user_model.dart';

class AuthRepository {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Register user
  Future<UserCredential> registerUser({
    required String email,
    required String password,
    required String name,
    required String apartmentNumber,
    required String community,
  }) async {
    try {
      return await _authService.registerWithEmailAndPassword(
        email,
        password,
        name,
        apartmentNumber,
        community,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Sign in user
  Future<UserCredential> signInUser({
    required String email,
    required String password,
  }) async {
    try {
      return await _authService.signInWithEmailAndPassword(email, password);
    } catch (e) {
      rethrow;
    }
  }

  // Sign out user
  Future<void> signOutUser() async {
    try {
      await _authService.signOut();
    } catch (e) {
      rethrow;
    }
  }

  // Get current user
  User? getCurrentUser() {
    return _authService.currentUser;
  }

  // Get current user data
  Future<UserModel?> getCurrentUserData() async {
    try {
      return await _authService.getCurrentUserData();
    } catch (e) {
      rethrow;
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    String? name,
    String? phoneNumber,
    String? profileImage,
  }) async {
    try {
      User? user = _authService.currentUser;
      
      if (user != null) {
        Map<String, dynamic> updateData = {};
        
        if (name != null) {
          updateData['name'] = name;
          await user.updateDisplayName(name);
        }
        
        if (phoneNumber != null) {
          updateData['phoneNumber'] = phoneNumber;
        }
        
        if (profileImage != null) {
          updateData['profileImage'] = profileImage;
        }
        
        if (updateData.isNotEmpty) {
          await _firestore.collection('users').doc(user.uid).update(updateData);
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  // Enable two-factor authentication
  Future<String> enableTwoFactorAuth() async {
    try {
      return await _authService.enableTwoFactorAuth();
    } catch (e) {
      rethrow;
    }
  }

  // Verify two-factor code
  Future<bool> verifyTwoFactorCode(String code, String secret) async {
    try {
      return await _authService.verifyTwoFactorCode(code, secret);
    } catch (e) {
      rethrow;
    }
  }

  // Disable two-factor authentication
  Future<void> disableTwoFactorAuth() async {
    try {
      await _authService.disableTwoFactorAuth();
    } catch (e) {
      rethrow;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _authService.resetPassword(email);
    } catch (e) {
      rethrow;
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    try {
      await _authService.deleteAccount();
    } catch (e) {
      rethrow;
    }
  }

  // Update privacy settings
  Future<void> updatePrivacySettings(Map<String, dynamic> privacySettings) async {
    try {
      User? user = _authService.currentUser;
      
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'privacySettings': privacySettings,
        });
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();
      
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      
      return null;
    } catch (e) {
      rethrow;
    }
  }
}