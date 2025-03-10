import 'package:comet/core/constants/app_constants.dart';

class Validators {
  // Email validator
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    final emailRegExp = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    if (!emailRegExp.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    
    return null;
  }
  
  // Password validator
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < AppConstants.passwordMinLength) {
      return 'Password must be at least ${AppConstants.passwordMinLength} characters long';
    }
    
    // Check for at least one uppercase letter
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    
    // Check for at least one number
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    
    return null;
  }
  
  // Confirm password validator
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    
    if (value != password) {
      return 'Passwords do not match';
    }
    
    return null;
  }
  
  // Name validator
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    
    if (value.length < AppConstants.nameMinLength) {
      return 'Name must be at least ${AppConstants.nameMinLength} characters long';
    }
    
    return null;
  }
  
  // Apartment number validator
  static String? validateApartmentNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Apartment number is required';
    }
    
    return null;
  }
  
  // Community validator
  static String? validateCommunity(String? value) {
    if (value == null || value.isEmpty) {
      return 'Community is required';
    }
    
    return null;
  }
  
  // Item title validator
  static String? validateItemTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Title is required';
    }
    
    if (value.length < 3) {
      return 'Title must be at least 3 characters long';
    }
    
    if (value.length > 100) {
      return 'Title must be less than 100 characters';
    }
    
    return null;
  }
  
  // Item description validator
  static String? validateItemDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'Description is required';
    }
    
    if (value.length < 10) {
      return 'Description must be at least 10 characters long';
    }
    
    if (value.length > 500) {
      return 'Description must be less than 500 characters';
    }
    
    return null;
  }
  
  // Chat message validator
  static String? validateChatMessage(String? value) {
    if (value == null || value.isEmpty) {
      return 'Message cannot be empty';
    }
    
    if (value.length > AppConstants.chatMessageMaxLength) {
      return 'Message must be less than ${AppConstants.chatMessageMaxLength} characters';
    }
    
    return null;
  }
  
  // 2FA code validator
  static String? validateTwoFactorCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Code is required';
    }
    
    if (value.length != 6) {
      return 'Code must be 6 digits';
    }
    
    if (!RegExp(r'^[0-9]{6}$').hasMatch(value)) {
      return 'Code must only contain numbers';
    }
    
    return null;
  }
  
  // Phone number validator
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    
    if (!RegExp(r'^[0-9]{10}$').hasMatch(value.replaceAll(RegExp(r'[^0-9]'), ''))) {
      return 'Please enter a valid 10-digit phone number';
    }
    
    return null;
  }
}