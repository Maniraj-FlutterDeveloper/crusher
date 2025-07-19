import 'dart:io';

import 'app_error.dart';
import 'error_handler.dart';
import '../services/logger_service.dart';

class FileSystemErrorHandler {
  final LoggerService _logger;
  final ErrorHandler _errorHandler;

  FileSystemErrorHandler({
    required LoggerService logger,
    required ErrorHandler errorHandler,
  })  : _logger = logger,
        _errorHandler = errorHandler;

  /// Handle a file system operation with error handling
  Future<T> handleFileOperation<T>(
    Future<T> Function() operation, {
    String? path,
    String? operationType,
    String? errorMessage,
  }) async {
    try {
      return await operation();
    } on FileSystemException catch (e) {
      _handleFileSystemException(
        e,
        path: path ?? e.path,
        operationType: operationType,
        errorMessage: errorMessage,
      );
      rethrow;
    } catch (e, stackTrace) {
      // If it's already an AppError, just rethrow it
      if (e is AppError) {
        throw e;
      }

      // Otherwise, convert it to a FileSystemError
      final error = FileSystemError(
        message: errorMessage ?? 'File operation failed',
        code: 'FILE_SYSTEM_ERROR',
        path: path,
        operation: operationType,
        details: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Handle a file system exception
  FileSystemError _handleFileSystemException(
    FileSystemException exception, {
    String? path,
    String? operationType,
    String? errorMessage,
  }) {
    final message = exception.message.toLowerCase();
    final osError = exception.osError;

    // Handle specific file system errors
    if (message.contains('no such file') || 
        message.contains('cannot find the file') ||
        (osError != null && osError.errorCode == 2)) {
      return FileSystemError.notFound(
        path: path ?? exception.path ?? '',
        stackTrace: StackTrace.current,
      );
    } else if (message.contains('permission denied') || 
               message.contains('access is denied') ||
               (osError != null && (osError.errorCode == 13 || osError.errorCode == 5))) {
      return FileSystemError.accessDenied(
        path: path ?? exception.path ?? '',
        operation: operationType,
        stackTrace: StackTrace.current,
      );
    } else if (message.contains('is a directory') || 
               (osError != null && osError.errorCode == 21)) {
      return FileSystemError(
        message: errorMessage ?? 'Path is a directory: ${path ?? exception.path}',
        code: 'FILE_IS_DIRECTORY',
        path: path ?? exception.path,
        operation: operationType,
        details: exception,
        stackTrace: StackTrace.current,
      );
    } else if (message.contains('not a directory') || 
               (osError != null && osError.errorCode == 20)) {
      return FileSystemError(
        message: errorMessage ?? 'Path is not a directory: ${path ?? exception.path}',
        code: 'FILE_NOT_DIRECTORY',
        path: path ?? exception.path,
        operation: operationType,
        details: exception,
        stackTrace: StackTrace.current,
      );
    } else if (message.contains('directory not empty') || 
               (osError != null && osError.errorCode == 39)) {
      return FileSystemError(
        message: errorMessage ?? 'Directory not empty: ${path ?? exception.path}',
        code: 'DIRECTORY_NOT_EMPTY',
        path: path ?? exception.path,
        operation: operationType,
        details: exception,
        stackTrace: StackTrace.current,
      );
    } else if (message.contains('file exists') || 
               (osError != null && osError.errorCode == 17)) {
      return FileSystemError(
        message: errorMessage ?? 'File already exists: ${path ?? exception.path}',
        code: 'FILE_EXISTS',
        path: path ?? exception.path,
        operation: operationType,
        details: exception,
        stackTrace: StackTrace.current,
      );
    } else if (message.contains('disk full') || 
               (osError != null && osError.errorCode == 28)) {
      return FileSystemError(
        message: errorMessage ?? 'Disk full',
        code: 'DISK_FULL',
        path: path ?? exception.path,
        operation: operationType,
        details: exception,
        stackTrace: StackTrace.current,
      );
    } else {
      // Generic file system error
      return FileSystemError(
        message: errorMessage ?? 'File system error: ${exception.message}',
        code: 'FILE_SYSTEM_ERROR',
        path: path ?? exception.path,
        operation: operationType,
        details: exception,
        stackTrace: StackTrace.current,
      );
    }
  }

  /// Handle a read operation
  Future<T> handleRead<T>(
    Future<T> Function() operation, {
    String? path,
    String? errorMessage,
  }) {
    return handleFileOperation(
      operation,
      path: path,
      operationType: 'read',
      errorMessage: errorMessage,
    );
  }

  /// Handle a write operation
  Future<T> handleWrite<T>(
    Future<T> Function() operation, {
    String? path,
    String? errorMessage,
  }) {
    return handleFileOperation(
      operation,
      path: path,
      operationType: 'write',
      errorMessage: errorMessage,
    );
  }

  /// Handle a delete operation
  Future<T> handleDelete<T>(
    Future<T> Function() operation, {
    String? path,
    String? errorMessage,
  }) {
    return handleFileOperation(
      operation,
      path: path,
      operationType: 'delete',
      errorMessage: errorMessage,
    );
  }

  /// Check if a file exists
  Future<bool> fileExists(String path) async {
    try {
      return await File(path).exists();
    } catch (e) {
      _logger.warning('Failed to check if file exists: $path', e);
      return false;
    }
  }

  /// Check if a directory exists
  Future<bool> directoryExists(String path) async {
    try {
      return await Directory(path).exists();
    } catch (e) {
      _logger.warning('Failed to check if directory exists: $path', e);
      return false;
    }
  }

  /// Create a directory if it doesn't exist
  Future<Directory> createDirectoryIfNotExists(String path) async {
    return handleFileOperation(
      () async {
        final directory = Directory(path);
        if (await directory.exists()) {
          return directory;
        } else {
          return await directory.create(recursive: true);
        }
      },
      path: path,
      operationType: 'create_directory',
      errorMessage: 'Failed to create directory: $path',
    );
  }
}

