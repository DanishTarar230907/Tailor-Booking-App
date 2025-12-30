import 'package:flutter_test/flutter_test.dart';
import 'package:grace/utils/app_validators.dart';

void main() {
  group('AppValidators - Email Validation', () {
    test('Valid email with just letters in username should be accepted', () {
      final result = AppValidators.validateEmail('admin@gracetailor.com');
      expect(result, null);
    });

    test('Valid email with alphanumeric username should be accepted', () {
      final result = AppValidators.validateEmail('admin123@gracetailor.com');
      expect(result, null);
    });

    test('Valid email with special characters in username should be accepted', () {
      final result = AppValidators.validateEmail('user.name+tag@example.com');
      expect(result, null);
    });

    test('Empty email should return error', () {
      final result = AppValidators.validateEmail('');
      expect(result, 'Email is required');
    });

    test('Null email should return error', () {
      final result = AppValidators.validateEmail(null);
      expect(result, 'Email is required');
    });

    test('Invalid format (no @) should return error', () {
      final result = AppValidators.validateEmail('plainaddress');
      expect(result, 'Enter a valid email address');
    });

    test('Invalid format (no domain) should return error', () {
      final result = AppValidators.validateEmail('user@');
      expect(result, 'Enter a valid email address');
    });
    
    test('Invalid format (no username) should return error', () {
      final result = AppValidators.validateEmail('@domain.com');
      expect(result, 'Enter a valid email address');
    });
  });
}
