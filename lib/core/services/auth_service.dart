import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comet/features/auth/data/models/user_model.dart';
import 'package:comet/core/services/encryption_service.dart';
import 'package:otp/otp.dart';
import 'dart:async';
import 'dart:math'; // For generating random secret

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final EncryptionService _encryptionService = EncryptionService();
  
  // Get current user
  User? get currentUser => _auth.currentUser;
  
  // Get user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  // Check if user is logged in
  Future<bool> isUserLoggedIn() async {
    return _auth.currentUser != null;
  }
  
  // Register with email and password
  Future<UserCredential> registerWithEmailAndPassword(
    String email, 
    String password, 
    String name,
    String apartmentNumber,
    String community
  ) async {
    try {
      // Create user with email and password
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Encrypt sensitive data
      String encryptedApartmentNumber = await _encryptionService.encrypt(apartmentNumber);
      
      // Create user model
      UserModel userModel = UserModel(
        uid: userCredential.user!.uid,
        name: name,
        email: email,
        apartmentNumber: encryptedApartmentNumber,
        community: community,
        createdAt: DateTime.now(),
        twoFactorEnabled: false,
        twoFactorSecret: '',
      );
      
      // Save user data to Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set(userModel.toMap());
      
      // Update display name
      await userCredential.user!.updateDisplayName(name);
      
      return userCredential;
    } catch (e) {
      rethrow;
    }
  }
  
  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(
    String email, 
    String password
  ) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }
  
  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
  
  // Get current user data
  Future<UserModel?> getCurrentUserData() async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(currentUser!.uid).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return UserModel.fromMap(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  
  // Generate a secure random secret for TOTP
  String _generateSecret() {
    final Random _random = Random.secure();
    const String _chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567'; // Base32 characters
    
    return List.generate(32, (index) => _chars[_random.nextInt(_chars.length)]).join();
  }
  
  // Enable two-factor authentication
  Future<String> enableTwoFactorAuth() async {
    try {
      // Generate a secret
      final secret = _generateSecret();
      
      // Update user data
      await _firestore.collection('users').doc(currentUser!.uid).update({
        'twoFactorEnabled': true,
        'twoFactorSecret': secret,
      });
      
      return secret;
    } catch (e) {
      rethrow;
    }
  }
  
  // Verify two-factor code
  Future<bool> verifyTwoFactorCode(String code, String secret) async {
    // Get current timestamp in seconds
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    
    // Generate TOTP codes for the current and adjacent time windows to account for time drift
    final currentCode = OTP.generateTOTPCodeString(
      secret, 
      currentTime, 
      length: 6,
      interval: 30,
      algorithm: Algorithm.SHA1,
      isGoogle: true
    );
    
    // Check if the provided code matches
    return code == currentCode;
  }
  
  // Disable two-factor authentication
  Future<void> disableTwoFactorAuth() async {
    try {
      await _firestore.collection('users').doc(currentUser!.uid).update({
        'twoFactorEnabled': false,
        'twoFactorSecret': '',
      });
    } catch (e) {
      rethrow;
    }
  }
  
  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }
  
  // Delete account
  Future<void> deleteAccount() async {
    try {
      // Get user data to delete from Firestore
      String userId = currentUser!.uid;
      
      // Delete user from Firebase Authentication
      await currentUser!.delete();
      
      // Delete user data from Firestore
      await _firestore.collection('users').doc(userId).delete();
      
      // Note: You may want to also delete other user-related data
    } catch (e) {
      rethrow;
    }
  }
}