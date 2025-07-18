import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:crusher_management/app/core/services/logger_service.dart';
import 'package:path_provider/path_provider.dart';

import 'logger_service_test.mocks.dart';

@GenerateMocks([LoggerService])
void main() {
  late MockLoggerService mockLoggerService;

  setUp(() {
    mockLoggerService = MockLoggerService();
  });

  group('LoggerService Tests', () {
    test('debug should log debug message', () {
      // Arrange
      const message = 'Debug message';
      
      // Act
      mockLoggerService.debug(message);
      
      // Assert
      verify(mockLoggerService.debug(message)).called(1);
    });

    test('info should log info message', () {
      // Arrange
      const message = 'Info message';
      
      // Act
      mockLoggerService.info(message);
      
      // Assert
      verify(mockLoggerService.info(message)).called(1);
    });

    test('warning should log warning message', () {
      // Arrange
      const message = 'Warning message';
      
      // Act
      mockLoggerService.warning(message);
      
      // Assert
      verify(mockLoggerService.warning(message)).called(1);
    });

    test('error should log error message', () {
      // Arrange
      const message = 'Error message';
      final error = Exception('Test error');
      
      // Act
      mockLoggerService.error(message, error);
      
      // Assert
      verify(mockLoggerService.error(message, error)).called(1);
    });

    test('fatal should log fatal message', () {
      // Arrange
      const message = 'Fatal message';
      final error = Exception('Test error');
      
      // Act
      mockLoggerService.fatal(message, error);
      
      // Assert
      verify(mockLoggerService.fatal(message, error)).called(1);
    });
  });
}

