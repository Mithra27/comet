import 'package:flutter/material.dart';
import 'package:comet/features/auth/data/repositories/auth_repository.dart';
import 'package:comet/features/auth/data/models/user_model.dart';
import 'package:comet/core/utils/helpers.dart';

class AuthController extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  
  bool _isLoading = false;
  UserModel? _currentUser;
  String? _error;
  
  // Getters
  bool get isLoading => _isLoading;
  UserModel? get currentUser => _currentUser;
  String? get error => _error;
  bool get isLoggedIn => _authRepository.getCurrentUser() != null;
  
  // Constructor
  AuthController() {
    _loadCurrentUser();
  }
  
  // Load current user
  Future<void> _loadCurrentUser() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      if (_authRepository.getCurrentUser() != null) {
        _currentUser = await _authRepository.getCurrentUserData();
      }
      
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Register user
  Future<bool> registerUser({
    required String email,
    required String password,
    required String name,
    required String apartmentNumber,
    required String community,
    required BuildContext context,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      await _authRepository.registerUser(
        email: email,
        password: password,
        name: name,
        apartmentNumber: apartmentNumber,
        community: community,
      );
      
      await _loadCurrentUser();
      
      return true;
    } catch (e) {
      _error = _getFirebaseErrorMessage(e);
      Helpers.showSnackBar(context, _error!, isError: true);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Sign in user
  Future<bool> signInUser({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      await _authRepository.signInUser(
        email: email,
        password: password,
      );
      
      await _loadCurrentUser();
      
      return true;
    } catch (e) {
      _error = _getFirebaseErrorMessage(e);
      Helpers.showSnackBar(context, _error!, isError: true);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Sign out user
  Future<void> signOutUser() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      await _authRepository.signOutUser();
      _currentUser = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Update user profile
  Future<bool> updateUserProfile({
    String? name,
    String? phoneNumber,
    String? profileImage,
    required BuildContext context,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      await _authRepository.updateUserProfile(
        name: name,
        phoneNumber: phoneNumber,
        profileImage: profileImage,
      );
      
      await _loadCurrentUser();
      
      Helpers.showSnackBar(context, 'Profile updated successfully');
      return true;
    } catch (e) {
      _error = e.toString();
      Helpers.showSnackBar(context, _error!, isError: true);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Enable two-factor authentication
  Future<String?> enableTwoFactorAuth({
    required BuildContext context,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      String secret = await _authRepository.enableTwoFactorAuth();
      await _loadCurrentUser();
      
      return secret;
    } catch (e) {
      _error = e.toString();
      Helpers.showSnackBar(context, _error!, isError: true);
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Verify two-factor code
  Future<bool> verifyTwoFactorCode({
    required String code,
    required String secret,
    required BuildContext context,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      bool isValid = await _authRepository.verifyTwoFactorCode(code, secret);
      
      if (!isValid) {
        _error = 'Invalid verification code';
        Helpers.showSnackBar(context, _error!, isError: true);
      }
      
      return isValid;
    } catch (e) {
      _error = e.toString();
      Helpers.showSnackBar(context, _error!, isError: true);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Disable two-factor authentication
  Future<bool> disableTwoFactorAuth({
    required BuildContext context,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      await _authRepository.disableTwoFactorAuth();
      await _loadCurrentUser();
      
      Helpers.showSnackBar(context, 'Two-factor authentication disabled');
      return true;
    } catch (e) {
      _error = e.toString();
      Helpers.showSnackBar(context, _error!, isError: true);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Reset password
  Future<bool> resetPassword({
    required String email,
    required BuildContext context,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      await _authRepository.resetPassword(email);
      
      Helpers.showSnackBar(
        context, 
        'Password reset email sent. Please check your inbox.',
      );
      return true;
    } catch (e) {
      _error = _getFirebaseErrorMessage(e);
      Helpers.showSnackBar(context, _error!, isError: true);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Delete account
  Future<bool> deleteAccount({
    required BuildContext context,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      await _authRepository.deleteAccount();
      _currentUser = null;
      
      Helpers.showSnackBar(context, 'Account deleted successfully');
      return true;
    } catch (e) {
      _error = e.toString();
      Helpers.showSnackBar(context, _error!, isError: true);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Update privacy settings
  Future<bool> updatePrivacySettings({
    required Map<String, dynamic> privacySettings,
    required BuildContext context,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      await _authRepository.updatePrivacySettings(privacySettings);
      await _loadCurrentUser();
      
      Helpers.showSnackBar(context, 'Privacy settings updated');
      return true;
    } catch (e) {
      _error = e.toString();
      Helpers.showSnackBar(context, _error!, isError: true);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Get readable Firebase error message
  String _getFirebaseErrorMessage(dynamic error) {
    String errorMessage = 'An error occurred. Please try again.';
    
    if (error is Exception) {
      String exceptionString = error.toString();
      
      if (exceptionString.contains('user-not-found')) {
        errorMessage = 'No user found with this email.';
      } else if (exceptionString.contains('wrong-password')) {
        errorMessage = 'Wrong password provided.';
      } else if (exceptionString.contains('email-already-in-use')) {
        errorMessage = 'Email already in use. Try signing in instead.';
      } else if (exceptionString.contains('weak-password')) {
        errorMessage = 'Password is too weak.';
      } else if (exceptionString.contains('invalid-email')) {
        errorMessage = 'Invalid email address.';
      } else if (exceptionString.contains('requires-recent-login')) {
        errorMessage = 'Please sign out and sign in again to perform this action.';
      } else if (exceptionString.contains('network-request-failed')) {
        errorMessage = 'Network error. Please check your connection.';
      }
    }
    
    return errorMessage;
  }
}
