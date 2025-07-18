import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';

import 'app_error.dart';
import '../services/logger_service.dart';
import '../../data/repositories/audit_log_repository.dart';

class ErrorHandler {
  final LoggerService _logger;
  final AuditLogRepository? _auditLogRepository;

  ErrorHandler({
    required LoggerService logger,
    AuditLogRepository? auditLogRepository,
  })  : _logger = logger,
        _auditLogRepository = auditLogRepository;

  /// Handle any error and convert it to an AppError
  Future<AppError> handleError(dynamic error, [StackTrace? stackTrace]) async {
    // Get the current stack trace if not provided
    stackTrace ??= StackTrace.current;

    // Log the error
    _logger.error('Error occurred', error, stackTrace);

    // Convert to AppError
    final appError = _convertToAppError(error, stackTrace);

    // Log to audit log if available
    await _logToAudit(appError);

    // Return the AppError
    return appError;
  }

  /// Convert any error to an AppError
  AppError _convertToAppError(dynamic error, StackTrace stackTrace) {
    if (error is AppError) {
      return error;
    }

    // Handle common error types
    if (error is SocketException || error is HttpException) {
      return NetworkError.connection(
        message: 'Network connection error: ${error.message}',
        stackTrace: stackTrace,
      );
    }

    if (error is TimeoutException) {
      return NetworkError.timeout(
        message: 'Request timeout: ${error.message}',
        stackTrace: stackTrace,
      );
    }

    if (error is FormatException) {
      return ValidationError(
        message: 'Format error: ${error.message}',
        code: 'FORMAT_ERROR',
        details: error.source,
        stackTrace: stackTrace,
      );
    }

    if (error is DatabaseException) {
      return DatabaseError(
        message: 'Database error: ${error.toString()}',
        code: 'DATABASE_ERROR',
        details: error,
        stackTrace: stackTrace,
      );
    }

    if (error is FileSystemException) {
      return FileSystemError(
        message: 'File system error: ${error.message}',
        code: 'FILE_SYSTEM_ERROR',
        path: error.path,
        details: error,
        stackTrace: stackTrace,
      );
    }

    // If we can't determine the type, return an UnexpectedError
    return UnexpectedError.fromException(error, stackTrace: stackTrace);
  }

  /// Log error to audit log
  Future<void> _logToAudit(AppError error) async {
    if (_auditLogRepository == null) return;

    try {
      await _auditLogRepository!.logAction(
        action: 'error',
        module: 'System',
        details: {
          'message': error.message,
          'code': error.code,
          'type': error.runtimeType.toString(),
        },
        includeDeviceInfo: true,
      );
    } catch (e) {
      // Don't throw errors from error handling
      _logger.error('Failed to log error to audit log', e);
    }
  }

  /// Show error dialog
  void showErrorDialog(BuildContext context, AppError error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_getErrorTitle(error)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(error.message),
              if (kDebugMode && error.details != null) ...[
                const SizedBox(height: 16),
                const Text(
                  'Details:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(error.details.toString()),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Show error snackbar
  void showErrorSnackbar(AppError error) {
    Get.snackbar(
      _getErrorTitle(error),
      error.message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 5),
      isDismissible: true,
      icon: const Icon(
        Icons.error,
        color: Colors.white,
      ),
    );
  }

  /// Get user-friendly error title based on error type
  String _getErrorTitle(AppError error) {
    if (error is NetworkError) {
      return 'Network Error';
    } else if (error is DatabaseError) {
      return 'Database Error';
    } else if (error is AuthError) {
      return 'Authentication Error';
    } else if (error is ValidationError) {
      return 'Validation Error';
    } else if (error is BusinessError) {
      return 'Operation Error';
    } else if (error is FileSystemError) {
      return 'File System Error';
    } else {
      return 'Error';
    }
  }

  /// Get user-friendly error message
  String getUserFriendlyMessage(AppError error) {
    if (error is NetworkError && error.isConnectionError) {
      return 'Please check your internet connection and try again.';
    } else if (error is DatabaseError) {
      return 'There was a problem with the database. Please try again.';
    } else if (error is AuthError) {
      if (error.code == 'AUTH_SESSION_EXPIRED') {
        return 'Your session has expired. Please log in again.';
      }
      return 'Authentication error. Please check your credentials and try again.';
    } else if (error is ValidationError) {
      return error.message;
    } else if (error is BusinessError) {
      return error.message;
    } else if (error is FileSystemError) {
      return 'There was a problem accessing a file. Please try again.';
    } else {
      return 'An unexpected error occurred. Please try again later.';
    }
  }
}

