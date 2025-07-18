/// Base class for all application errors
abstract class AppError implements Exception {
  final String message;
  final String? code;
  final dynamic details;
  final StackTrace? stackTrace;

  const AppError({
    required this.message,
    this.code,
    this.details,
    this.stackTrace,
  });

  @override
  String toString() {
    String result = 'AppError: $message';
    if (code != null) {
      result = '$result (Code: $code)';
    }
    if (details != null) {
      result = '$result\nDetails: $details';
    }
    if (stackTrace != null) {
      result = '$result\n$stackTrace';
    }
    return result;
  }
}

/// Network-related errors
class NetworkError extends AppError {
  final int? statusCode;
  final bool isConnectionError;

  const NetworkError({
    required String message,
    String? code,
    this.statusCode,
    this.isConnectionError = false,
    dynamic details,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          details: details,
          stackTrace: stackTrace,
        );

  factory NetworkError.connection({
    String message = 'No internet connection',
    StackTrace? stackTrace,
  }) {
    return NetworkError(
      message: message,
      code: 'NETWORK_CONNECTION_ERROR',
      isConnectionError: true,
      stackTrace: stackTrace,
    );
  }

  factory NetworkError.timeout({
    String message = 'Request timeout',
    StackTrace? stackTrace,
  }) {
    return NetworkError(
      message: message,
      code: 'NETWORK_TIMEOUT_ERROR',
      isConnectionError: true,
      stackTrace: stackTrace,
    );
  }

  factory NetworkError.server({
    String message = 'Server error',
    int? statusCode,
    dynamic details,
    StackTrace? stackTrace,
  }) {
    return NetworkError(
      message: message,
      code: 'SERVER_ERROR',
      statusCode: statusCode,
      details: details,
      stackTrace: stackTrace,
    );
  }
}

/// Database-related errors
class DatabaseError extends AppError {
  final String? operation;
  final String? table;

  const DatabaseError({
    required String message,
    String? code,
    this.operation,
    this.table,
    dynamic details,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          details: details,
          stackTrace: stackTrace,
        );

  factory DatabaseError.read({
    String message = 'Failed to read from database',
    String? table,
    dynamic details,
    StackTrace? stackTrace,
  }) {
    return DatabaseError(
      message: message,
      code: 'DATABASE_READ_ERROR',
      operation: 'read',
      table: table,
      details: details,
      stackTrace: stackTrace,
    );
  }

  factory DatabaseError.write({
    String message = 'Failed to write to database',
    String? table,
    dynamic details,
    StackTrace? stackTrace,
  }) {
    return DatabaseError(
      message: message,
      code: 'DATABASE_WRITE_ERROR',
      operation: 'write',
      table: table,
      details: details,
      stackTrace: stackTrace,
    );
  }

  factory DatabaseError.delete({
    String message = 'Failed to delete from database',
    String? table,
    dynamic details,
    StackTrace? stackTrace,
  }) {
    return DatabaseError(
      message: message,
      code: 'DATABASE_DELETE_ERROR',
      operation: 'delete',
      table: table,
      details: details,
      stackTrace: stackTrace,
    );
  }

  factory DatabaseError.update({
    String message = 'Failed to update database',
    String? table,
    dynamic details,
    StackTrace? stackTrace,
  }) {
    return DatabaseError(
      message: message,
      code: 'DATABASE_UPDATE_ERROR',
      operation: 'update',
      table: table,
      details: details,
      stackTrace: stackTrace,
    );
  }

  factory DatabaseError.initialization({
    String message = 'Failed to initialize database',
    dynamic details,
    StackTrace? stackTrace,
  }) {
    return DatabaseError(
      message: message,
      code: 'DATABASE_INITIALIZATION_ERROR',
      operation: 'initialization',
      details: details,
      stackTrace: stackTrace,
    );
  }
}

/// Authentication-related errors
class AuthError extends AppError {
  const AuthError({
    required String message,
    String? code,
    dynamic details,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          details: details,
          stackTrace: stackTrace,
        );

  factory AuthError.invalidCredentials({
    String message = 'Invalid username or password',
    StackTrace? stackTrace,
  }) {
    return AuthError(
      message: message,
      code: 'AUTH_INVALID_CREDENTIALS',
      stackTrace: stackTrace,
    );
  }

  factory AuthError.unauthorized({
    String message = 'Unauthorized access',
    StackTrace? stackTrace,
  }) {
    return AuthError(
      message: message,
      code: 'AUTH_UNAUTHORIZED',
      stackTrace: stackTrace,
    );
  }

  factory AuthError.sessionExpired({
    String message = 'Session expired',
    StackTrace? stackTrace,
  }) {
    return AuthError(
      message: message,
      code: 'AUTH_SESSION_EXPIRED',
      stackTrace: stackTrace,
    );
  }

  factory AuthError.accountLocked({
    String message = 'Account locked',
    dynamic details,
    StackTrace? stackTrace,
  }) {
    return AuthError(
      message: message,
      code: 'AUTH_ACCOUNT_LOCKED',
      details: details,
      stackTrace: stackTrace,
    );
  }
}

/// Validation-related errors
class ValidationError extends AppError {
  final String? field;

  const ValidationError({
    required String message,
    String? code,
    this.field,
    dynamic details,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          details: details,
          stackTrace: stackTrace,
        );

  factory ValidationError.requiredField({
    required String field,
    String? message,
    StackTrace? stackTrace,
  }) {
    return ValidationError(
      message: message ?? 'The $field field is required',
      code: 'VALIDATION_REQUIRED_FIELD',
      field: field,
      stackTrace: stackTrace,
    );
  }

  factory ValidationError.invalidFormat({
    required String field,
    String? message,
    dynamic details,
    StackTrace? stackTrace,
  }) {
    return ValidationError(
      message: message ?? 'The $field has an invalid format',
      code: 'VALIDATION_INVALID_FORMAT',
      field: field,
      details: details,
      stackTrace: stackTrace,
    );
  }

  factory ValidationError.invalidValue({
    required String field,
    String? message,
    dynamic details,
    StackTrace? stackTrace,
  }) {
    return ValidationError(
      message: message ?? 'The $field has an invalid value',
      code: 'VALIDATION_INVALID_VALUE',
      field: field,
      details: details,
      stackTrace: stackTrace,
    );
  }

  factory ValidationError.outOfRange({
    required String field,
    dynamic min,
    dynamic max,
    String? message,
    StackTrace? stackTrace,
  }) {
    return ValidationError(
      message: message ?? 'The $field must be between $min and $max',
      code: 'VALIDATION_OUT_OF_RANGE',
      field: field,
      details: {'min': min, 'max': max},
      stackTrace: stackTrace,
    );
  }
}

/// Business logic errors
class BusinessError extends AppError {
  const BusinessError({
    required String message,
    String? code,
    dynamic details,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          details: details,
          stackTrace: stackTrace,
        );

  factory BusinessError.notFound({
    required String entity,
    dynamic id,
    StackTrace? stackTrace,
  }) {
    return BusinessError(
      message: '$entity not found',
      code: 'BUSINESS_NOT_FOUND',
      details: {'entity': entity, 'id': id},
      stackTrace: stackTrace,
    );
  }

  factory BusinessError.alreadyExists({
    required String entity,
    dynamic identifier,
    StackTrace? stackTrace,
  }) {
    return BusinessError(
      message: '$entity already exists',
      code: 'BUSINESS_ALREADY_EXISTS',
      details: {'entity': entity, 'identifier': identifier},
      stackTrace: stackTrace,
    );
  }

  factory BusinessError.invalidOperation({
    required String operation,
    String? reason,
    dynamic details,
    StackTrace? stackTrace,
  }) {
    return BusinessError(
      message: 'Invalid operation: $operation${reason != null ? ' - $reason' : ''}',
      code: 'BUSINESS_INVALID_OPERATION',
      details: details,
      stackTrace: stackTrace,
    );
  }

  factory BusinessError.insufficientPermissions({
    required String operation,
    String? resource,
    StackTrace? stackTrace,
  }) {
    return BusinessError(
      message: 'Insufficient permissions to $operation${resource != null ? ' $resource' : ''}',
      code: 'BUSINESS_INSUFFICIENT_PERMISSIONS',
      details: {'operation': operation, 'resource': resource},
      stackTrace: stackTrace,
    );
  }
}

/// File system errors
class FileSystemError extends AppError {
  final String? path;
  final String? operation;

  const FileSystemError({
    required String message,
    String? code,
    this.path,
    this.operation,
    dynamic details,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          details: details,
          stackTrace: stackTrace,
        );

  factory FileSystemError.notFound({
    required String path,
    StackTrace? stackTrace,
  }) {
    return FileSystemError(
      message: 'File not found: $path',
      code: 'FILE_NOT_FOUND',
      path: path,
      operation: 'read',
      stackTrace: stackTrace,
    );
  }

  factory FileSystemError.accessDenied({
    required String path,
    String? operation,
    StackTrace? stackTrace,
  }) {
    return FileSystemError(
      message: 'Access denied to file: $path',
      code: 'FILE_ACCESS_DENIED',
      path: path,
      operation: operation,
      stackTrace: stackTrace,
    );
  }

  factory FileSystemError.write({
    required String path,
    dynamic details,
    StackTrace? stackTrace,
  }) {
    return FileSystemError(
      message: 'Failed to write to file: $path',
      code: 'FILE_WRITE_ERROR',
      path: path,
      operation: 'write',
      details: details,
      stackTrace: stackTrace,
    );
  }

  factory FileSystemError.read({
    required String path,
    dynamic details,
    StackTrace? stackTrace,
  }) {
    return FileSystemError(
      message: 'Failed to read from file: $path',
      code: 'FILE_READ_ERROR',
      path: path,
      operation: 'read',
      details: details,
      stackTrace: stackTrace,
    );
  }

  factory FileSystemError.delete({
    required String path,
    dynamic details,
    StackTrace? stackTrace,
  }) {
    return FileSystemError(
      message: 'Failed to delete file: $path',
      code: 'FILE_DELETE_ERROR',
      path: path,
      operation: 'delete',
      details: details,
      stackTrace: stackTrace,
    );
  }
}

/// Unexpected errors
class UnexpectedError extends AppError {
  const UnexpectedError({
    String message = 'An unexpected error occurred',
    String? code,
    dynamic details,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code ?? 'UNEXPECTED_ERROR',
          details: details,
          stackTrace: stackTrace,
        );

  factory UnexpectedError.fromException(
    dynamic exception, {
    StackTrace? stackTrace,
  }) {
    return UnexpectedError(
      message: 'Unexpected error: ${exception.toString()}',
      details: exception,
      stackTrace: stackTrace,
    );
  }
}

