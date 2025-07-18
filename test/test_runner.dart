import 'package:flutter_test/flutter_test.dart';

// Import all test files
import 'unit/core/services/logger_service_test.dart' as logger_service_test;
import 'unit/core/error/error_handler_test.dart' as error_handler_test;
import 'unit/data/models/sync_item_model_test.dart' as sync_item_model_test;
import 'unit/core/utils/form_validator_test.dart' as form_validator_test;

void main() {
  group('All Tests', () {
    // Core Services Tests
    group('Core Services Tests', () {
      logger_service_test.main();
    });

    // Error Handling Tests
    group('Error Handling Tests', () {
      error_handler_test.main();
    });

    // Model Tests
    group('Model Tests', () {
      sync_item_model_test.main();
    });

    // Utility Tests
    group('Utility Tests', () {
      form_validator_test.main();
    });
  });
}

