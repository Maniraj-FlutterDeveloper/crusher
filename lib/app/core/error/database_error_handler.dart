import 'package:sqflite/sqflite.dart';

import 'app_error.dart';
import 'error_handler.dart';

class DatabaseErrorHandler {
  final ErrorHandler _errorHandler;

  DatabaseErrorHandler({
    required ErrorHandler errorHandler,
  }) : _errorHandler = errorHandler;

  /// Handle a database operation with error handling
  Future<T> handleDatabaseOperation<T>(
    Future<T> Function() operation, {
    String? operationType,
    String? tableName,
    String? errorMessage,
  }) async {
    try {
      return await operation();
    } on DatabaseException catch (e) {
      final error = _handleDatabaseException(
        e,
        operationType: operationType,
        tableName: tableName,
        errorMessage: errorMessage,
      );
      throw await _errorHandler.handleError(error);
    } catch (e, stackTrace) {
      // If it's already an AppError, just rethrow it
      if (e is AppError) {
        rethrow;
      }

      // Otherwise, convert it to a DatabaseError
      final error = DatabaseError(
        message: errorMessage ?? 'Database operation failed',
        code: 'DATABASE_ERROR',
        operation: operationType,
        table: tableName,
        details: e,
        stackTrace: stackTrace,
      );
      throw await _errorHandler.handleError(error);
    }
  }

  /// Handle a database exception
  DatabaseError _handleDatabaseException(
    DatabaseException exception, {
    String? operationType,
    String? tableName,
    String? errorMessage,
  }) {
    final message = exception.toString().toLowerCase();

    // Handle specific database errors
    if (message.contains('no such table')) {
      return DatabaseError(
        message: errorMessage ?? 'Table not found: ${tableName ?? 'unknown'}',
        code: 'DATABASE_TABLE_NOT_FOUND',
        operation: operationType,
        table: tableName,
        details: exception,
      );
    } else if (message.contains('unique constraint failed')) {
      return DatabaseError(
        message: errorMessage ?? 'Duplicate entry in ${tableName ?? 'database'}',
        code: 'DATABASE_UNIQUE_CONSTRAINT',
        operation: operationType,
        table: tableName,
        details: exception,
      );
    } else if (message.contains('foreign key constraint failed')) {
      return DatabaseError(
        message:
            errorMessage ?? 'Foreign key constraint failed in ${tableName ?? 'database'}',
        code: 'DATABASE_FOREIGN_KEY_CONSTRAINT',
        operation: operationType,
        table: tableName,
        details: exception,
      );
    } else if (message.contains('not null constraint failed')) {
      return DatabaseError(
        message:
            errorMessage ?? 'Not null constraint failed in ${tableName ?? 'database'}',
        code: 'DATABASE_NOT_NULL_CONSTRAINT',
        operation: operationType,
        table: tableName,
        details: exception,
      );
    } else if (message.contains('database is locked')) {
      return DatabaseError(
        message: errorMessage ?? 'Database is locked',
        code: 'DATABASE_LOCKED',
        operation: operationType,
        table: tableName,
        details: exception,
      );
    } else if (message.contains('database disk image is malformed')) {
      return DatabaseError(
        message: errorMessage ?? 'Database is corrupted',
        code: 'DATABASE_CORRUPTED',
        operation: operationType,
        table: tableName,
        details: exception,
      );
    } else if (message.contains('no such column')) {
      return DatabaseError(
        message: errorMessage ?? 'Column not found in ${tableName ?? 'database'}',
        code: 'DATABASE_COLUMN_NOT_FOUND',
        operation: operationType,
        table: tableName,
        details: exception,
      );
    } else {
      // Generic database error
      return DatabaseError(
        message: errorMessage ?? 'Database error: ${exception.toString()}',
        code: 'DATABASE_ERROR',
        operation: operationType,
        table: tableName,
        details: exception,
      );
    }
  }

  /// Handle a read operation
  Future<T> handleRead<T>(
    Future<T> Function() operation, {
    String? tableName,
    String? errorMessage,
  }) {
    return handleDatabaseOperation(
      operation,
      operationType: 'read',
      tableName: tableName,
      errorMessage: errorMessage,
    );
  }

  /// Handle a write operation
  Future<T> handleWrite<T>(
    Future<T> Function() operation, {
    String? tableName,
    String? errorMessage,
  }) {
    return handleDatabaseOperation(
      operation,
      operationType: 'write',
      tableName: tableName,
      errorMessage: errorMessage,
    );
  }

  /// Handle an update operation
  Future<T> handleUpdate<T>(
    Future<T> Function() operation, {
    String? tableName,
    String? errorMessage,
  }) {
    return handleDatabaseOperation(
      operation,
      operationType: 'update',
      tableName: tableName,
      errorMessage: errorMessage,
    );
  }

  /// Handle a delete operation
  Future<T> handleDelete<T>(
    Future<T> Function() operation, {
    String? tableName,
    String? errorMessage,
  }) {
    return handleDatabaseOperation(
      operation,
      operationType: 'delete',
      tableName: tableName,
      errorMessage: errorMessage,
    );
  }
}