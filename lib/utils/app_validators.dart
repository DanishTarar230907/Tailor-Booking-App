
import 'package:flutter/foundation.dart';

class AppValidators {
  // Regex Patterns
  // More robust email regex allowing standard special chars but enforcing domain structure
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  
  static final RegExp _phoneRegex = RegExp(
    r'^\+?[\d\s-]{10,15}$', // Allow +, digits, spaces, hyphens. Min 10 chars.
  );

  static final RegExp _nameRegex = RegExp(
    r"^[a-zA-Z\s'-]+$", // Allow alphabets, spaces, hyphens, and apostrophes
  );

  // Email Validator
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return '❌ Email is required. Please enter your email address.';
    }
    
    // Strict Domain Check: Only allow Google emails
    if (!value.toLowerCase().endsWith('@gmail.com') && !value.toLowerCase().endsWith('@googlemail.com')) {
      return '❌ Only Google emails (@gmail.com) are allowed.';
    }
    // 1. Basic format check
    if (!_emailRegex.hasMatch(value)) {
      return '❌ Invalid email format. Please use format: example@domain.com';
    }
    
    // 2. Custom Strict Rule: Removed to allow standard emails
    // The previous rule required both letters and numbers, which blocked valid emails like admin@gracetailor.com
    
    return null;
  }

  // Password Validator (Strict Google-like)
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return '❌ Password is required. Please create a strong password.';
    }
    if (value.length < 8) {
      return '❌ Password must be at least 8 characters long (currently ${value.length} characters)';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return '❌ Password must contain at least one UPPERCASE letter (A-Z)';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return '❌ Password must contain at least one lowercase letter (a-z)';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return '❌ Password must contain at least one number (0-9)';
    }
    if (!value.contains(RegExp(r'[!@#\$&*~]'))) {
      return '❌ Password must contain at least one special character (!@#\$&*~)';
    }
    return null;
  }

  // Name Validator
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return '❌ Name is required. Please enter your full name.';
    }
    if (!_nameRegex.hasMatch(value)) {
      return '❌ Name must contain only alphabets (A-Z, a-z). Numbers and special characters are not allowed.';
    }
    if (value.length < 3) {
      return '❌ Name is too short. Please enter at least 3 characters.';
    }
    return null;
  }

  // Phone Validator
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (!_phoneRegex.hasMatch(value)) {
      return 'Enter a valid phone number';
    }
    return null;
  }
  
  // Optional Phone Validator (can be empty)
  static String? validateOptionalPhone(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    if (!_phoneRegex.hasMatch(value)) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  // General Required Validator
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
}
