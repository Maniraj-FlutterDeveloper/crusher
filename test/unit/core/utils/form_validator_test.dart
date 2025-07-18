import 'package:flutter_test/flutter_test.dart';
import 'package:crusher_management/app/core/utils/form_validator.dart';

void main() {
  group('FormValidator Tests', () {
    group('required', () {
      test('should return null for non-empty string', () {
        // Act
        final result = FormValidator.required('Test');
        
        // Assert
        expect(result, null);
      });

      test('should return error message for empty string', () {
        // Act
        final result = FormValidator.required('');
        
        // Assert
        expect(result, 'This field is required');
      });

      test('should return error message for null', () {
        // Act
        final result = FormValidator.required(null);
        
        // Assert
        expect(result, 'This field is required');
      });
    });

    group('email', () {
      test('should return null for valid email', () {
        // Act
        final result = FormValidator.email('test@example.com');
        
        // Assert
        expect(result, null);
      });

      test('should return error message for invalid email', () {
        // Act
        final result = FormValidator.email('invalid-email');
        
        // Assert
        expect(result, 'Please enter a valid email address');
      });

      test('should return null for empty string if not required', () {
        // Act
        final result = FormValidator.email('', required: false);
        
        // Assert
        expect(result, null);
      });

      test('should return error message for empty string if required', () {
        // Act
        final result = FormValidator.email('', required: true);
        
        // Assert
        expect(result, 'This field is required');
      });
    });

    group('phone', () {
      test('should return null for valid phone number', () {
        // Act
        final result = FormValidator.phone('1234567890');
        
        // Assert
        expect(result, null);
      });

      test('should return error message for invalid phone number', () {
        // Act
        final result = FormValidator.phone('123');
        
        // Assert
        expect(result, 'Please enter a valid phone number');
      });

      test('should return null for empty string if not required', () {
        // Act
        final result = FormValidator.phone('', required: false);
        
        // Assert
        expect(result, null);
      });
    });

    group('password', () {
      test('should return null for valid password', () {
        // Act
        final result = FormValidator.password('Password123!');
        
        // Assert
        expect(result, null);
      });

      test('should return error message for password without uppercase', () {
        // Act
        final result = FormValidator.password('password123!');
        
        // Assert
        expect(result, contains('uppercase'));
      });

      test('should return error message for password without lowercase', () {
        // Act
        final result = FormValidator.password('PASSWORD123!');
        
        // Assert
        expect(result, contains('lowercase'));
      });

      test('should return error message for password without number', () {
        // Act
        final result = FormValidator.password('Password!');
        
        // Assert
        expect(result, contains('number'));
      });

      test('should return error message for password without special character', () {
        // Act
        final result = FormValidator.password('Password123');
        
        // Assert
        expect(result, contains('special character'));
      });

      test('should return error message for short password', () {
        // Act
        final result = FormValidator.password('Pass1!');
        
        // Assert
        expect(result, contains('at least 8 characters'));
      });
    });

    group('number', () {
      test('should return null for valid number', () {
        // Act
        final result = FormValidator.number('123');
        
        // Assert
        expect(result, null);
      });

      test('should return error message for non-numeric string', () {
        // Act
        final result = FormValidator.number('abc');
        
        // Assert
        expect(result, 'Please enter a valid number');
      });

      test('should validate min value', () {
        // Act
        final result = FormValidator.number('5', min: 10);
        
        // Assert
        expect(result, 'Value must be at least 10');
      });

      test('should validate max value', () {
        // Act
        final result = FormValidator.number('15', max: 10);
        
        // Assert
        expect(result, 'Value must be at most 10');
      });
    });

    group('vehicleNumber', () {
      test('should return null for valid vehicle number', () {
        // Act
        final result = FormValidator.vehicleNumber('KA01AB1234');
        
        // Assert
        expect(result, null);
      });

      test('should return error message for invalid vehicle number', () {
        // Act
        final result = FormValidator.vehicleNumber('INVALID');
        
        // Assert
        expect(result, 'Please enter a valid vehicle number');
      });
    });

    group('gstNumber', () {
      test('should return null for valid GST number', () {
        // Act
        final result = FormValidator.gstNumber('29AABCU9603R1ZU');
        
        // Assert
        expect(result, null);
      });

      test('should return error message for invalid GST number', () {
        // Act
        final result = FormValidator.gstNumber('INVALID');
        
        // Assert
        expect(result, 'Please enter a valid GST number');
      });
    });
  });
}

