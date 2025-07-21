

import '../error/app_error.dart';

class FormValidator {
  /// Validate required field
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validate email
  static String? validateEmail(String? value, {bool required = true}) {
    if (required && (value == null || value.trim().isEmpty)) {
      return 'Email is required';
    }
    
    if (value != null && value.trim().isNotEmpty) {
      final emailRegex = RegExp(
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
      );
      
      if (!emailRegex.hasMatch(value)) {
        return 'Please enter a valid email address';
      }
    }
    
    return null;
  }

  /// Validate phone number
  static String? validatePhone(String? value, {bool required = true}) {
    if (required && (value == null || value.trim().isEmpty)) {
      return 'Phone number is required';
    }
    
    if (value != null && value.trim().isNotEmpty) {
      final phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');
      
      if (!phoneRegex.hasMatch(value.replaceAll(RegExp(r'[\s-]'), ''))) {
        return 'Please enter a valid phone number';
      }
    }
    
    return null;
  }

  /// Validate password
  static String? validatePassword(
    String? value, {
    bool required = true,
    int minLength = 8,
    bool requireUppercase = true,
    bool requireLowercase = true,
    bool requireNumbers = true,
    bool requireSpecialChars = true,
  }) {
    if (required && (value == null || value.trim().isEmpty)) {
      return 'Password is required';
    }
    
    if (value != null && value.trim().isNotEmpty) {
      if (value.length < minLength) {
        return 'Password must be at least $minLength characters long';
      }
      
      if (requireUppercase && !value.contains(RegExp(r'[A-Z]'))) {
        return 'Password must contain at least one uppercase letter';
      }
      
      if (requireLowercase && !value.contains(RegExp(r'[a-z]'))) {
        return 'Password must contain at least one lowercase letter';
      }
      
      if (requireNumbers && !value.contains(RegExp(r'[0-9]'))) {
        return 'Password must contain at least one number';
      }
      
      if (requireSpecialChars && !value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
        return 'Password must contain at least one special character';
      }
    }
    
    return null;
  }

  /// Validate password confirmation
  static String? validatePasswordConfirmation(
    String? value,
    String? password,
  ) {
    if (value == null || value.trim().isEmpty) {
      return 'Password confirmation is required';
    }
    
    if (value != password) {
      return 'Passwords do not match';
    }
    
    return null;
  }

  /// Validate number
  static String? validateNumber(
    String? value, {
    bool required = true,
    double? min,
    double? max,
    bool allowDecimal = true,
  }) {
    if (required && (value == null || value.trim().isEmpty)) {
      return 'This field is required';
    }
    
    if (value != null && value.trim().isNotEmpty) {
      final numericRegex = allowDecimal
          ? RegExp(r'^-?\d*\.?\d+$')
          : RegExp(r'^-?\d+$');
      
      if (!numericRegex.hasMatch(value)) {
        return allowDecimal
            ? 'Please enter a valid number'
            : 'Please enter a valid integer';
      }
      
      final numValue = double.tryParse(value);
      
      if (numValue == null) {
        return 'Please enter a valid number';
      }
      
      if (min != null && numValue < min) {
        return 'Value must be greater than or equal to $min';
      }
      
      if (max != null && numValue > max) {
        return 'Value must be less than or equal to $max';
      }
    }
    
    return null;
  }

  /// Validate date
  static String? validateDate(
    String? value, {
    bool required = true,
    DateTime? minDate,
    DateTime? maxDate,
  }) {
    if (required && (value == null || value.trim().isEmpty)) {
      return 'Date is required';
    }
    
    if (value != null && value.trim().isNotEmpty) {
      final date = DateTime.tryParse(value);
      
      if (date == null) {
        return 'Please enter a valid date';
      }
      
      if (minDate != null && date.isBefore(minDate)) {
        return 'Date must be after ${minDate.toLocal().toString().split(' ')[0]}';
      }
      
      if (maxDate != null && date.isAfter(maxDate)) {
        return 'Date must be before ${maxDate.toLocal().toString().split(' ')[0]}';
      }
    }
    
    return null;
  }

  /// Validate URL
  static String? validateUrl(String? value, {bool required = true}) {
    if (required && (value == null || value.trim().isEmpty)) {
      return 'URL is required';
    }
    
    if (value != null && value.trim().isNotEmpty) {
      final urlRegex = RegExp(
        r'^(https?:\/\/)?(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
      );
      
      if (!urlRegex.hasMatch(value)) {
        return 'Please enter a valid URL';
      }
    }
    
    return null;
  }

  /// Validate vehicle number
  static String? validateVehicleNumber(String? value, {bool required = true}) {
    if (required && (value == null || value.trim().isEmpty)) {
      return 'Vehicle number is required';
    }
    
    if (value != null && value.trim().isNotEmpty) {
      // Indian vehicle number format: AA00AA0000
      final vehicleRegex = RegExp(
        r'^[A-Z]{2}[0-9]{1,2}[A-Z]{1,2}[0-9]{1,4}$',
      );
      
      if (!vehicleRegex.hasMatch(value.replaceAll(RegExp(r'[\s-]'), ''))) {
        return 'Please enter a valid vehicle number';
      }
    }
    
    return null;
  }

  /// Validate GST number (Indian)
  static String? validateGstNumber(String? value, {bool required = true}) {
    if (required && (value == null || value.trim().isEmpty)) {
      return 'GST number is required';
    }
    
    if (value != null && value.trim().isNotEmpty) {
      // Indian GST number format: 22AAAAA0000A1Z5
      final gstRegex = RegExp(
        r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$',
      );
      
      if (!gstRegex.hasMatch(value.replaceAll(RegExp(r'[\s-]'), ''))) {
        return 'Please enter a valid GST number';
      }
    }
    
    return null;
  }

  /// Validate PAN number (Indian)
  static String? validatePanNumber(String? value, {bool required = true}) {
    if (required && (value == null || value.trim().isEmpty)) {
      return 'PAN number is required';
    }
    
    if (value != null && value.trim().isNotEmpty) {
      // Indian PAN number format: AAAAA0000A
      final panRegex = RegExp(
        r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$',
      );
      
      if (!panRegex.hasMatch(value.replaceAll(RegExp(r'[\s-]'), ''))) {
        return 'Please enter a valid PAN number';
      }
    }
    
    return null;
  }

  /// Validate form fields
  static Map<String, dynamic> validateForm(
    Map<String, dynamic> formData,
    Map<String, Function> validators,
  ) {
    final errors = <String, String>{};
    
    validators.forEach((field, validator) {
      final value = formData[field];
      final error = validator(value);
      
      if (error != null) {
        errors[field] = error;
      }
    });
    
    return {
      'isValid': errors.isEmpty,
      'errors': errors,
    };
  }

  /// Validate form and throw error if invalid
  static void validateFormAndThrow(
    Map<String, dynamic> formData,
    Map<String, Function> validators,
  ) {
    final result = validateForm(formData, validators);
    
    if (!result['isValid']) {
      final errors = result['errors'] as Map<String, String>;
      final firstError = errors.entries.first;
      
      throw ValidationError(
        message: firstError.value,
        field: firstError.key,
        details: errors,
      );
    }
  }
}

