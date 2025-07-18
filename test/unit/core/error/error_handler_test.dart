import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:crusher_management/app/core/error/app_error.dart';
import 'package:crusher_management/app/core/error/error_handler.dart';
import 'package:crusher_management/app/core/services/logger_service.dart';
import 'package:crusher_management/app/data/repositories/audit_log_repository.dart';

import 'error_handler_test.mocks.dart';

@GenerateMocks([LoggerService, AuditLogRepository])
void main() {
  late ErrorHandler errorHandler;
  late MockLoggerService mockLogger;
  late MockAuditLogRepository mockAuditLogRepository;

  setUp(() {
    mockLogger = MockLoggerService();
    mockAuditLogRepository = MockAuditLogRepository();
    errorHandler = ErrorHandler(
      logger: mockLogger,
      auditLogRepository: mockAuditLogRepository,
    );
  });

  group('ErrorHandler Tests', () {
    test('handleError should handle Exception', () async {
      // Arrange
      final exception = Exception('Test exception');
      final stackTrace = StackTrace.current;
      
      // Act
      final result = await errorHandler.handleError(exception, stackTrace);
      
      // Assert
      expect(result, isA<UnexpectedError>());
      expect(result.message, contains('Test exception'));
      verify(mockLogger.error(any, exception)).called(1);
    });

    test('handleError should handle Error', () async {
      // Arrange
      final error = ArgumentError('Test error');
      final stackTrace = StackTrace.current;
      
      // Act
      final result = await errorHandler.handleError(error, stackTrace);
      
      // Assert
      expect(result, isA<UnexpectedError>());
      expect(result.message, contains('Test error'));
      verify(mockLogger.error(any, error)).called(1);
    });

    test('handleError should pass through AppError', () async {
      // Arrange
      final appError = ValidationError(
        message: 'Validation failed',
        field: 'test',
        stackTrace: StackTrace.current,
      );
      
      // Act
      final result = await errorHandler.handleError(appError);
      
      // Assert
      expect(result, same(appError));
      verify(mockLogger.error(any, appError)).called(1);
    });

    test('handleError should log to audit log for AuthError', () async {
      // Arrange
      final authError = AuthError(
        message: 'Authentication failed',
        code: 'AUTH_FAILED',
        stackTrace: StackTrace.current,
      );
      
      // Act
      final result = await errorHandler.handleError(authError);
      
      // Assert
      expect(result, same(authError));
      verify(mockLogger.error(any, authError)).called(1);
      verify(mockAuditLogRepository.logSecurityEvent(any, any, any)).called(1);
    });
  });
}

