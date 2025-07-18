import 'dart:async';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app_error.dart';
import 'error_handler.dart';
import '../services/logger_service.dart';
import '../../data/repositories/audit_log_repository.dart';

class GlobalErrorHandler {
  final LoggerService _logger;
  final ErrorHandler _errorHandler;
  final bool _showErrorDialogs;

  GlobalErrorHandler({
    required LoggerService logger,
    required ErrorHandler errorHandler,
    bool showErrorDialogs = true,
  })  : _logger = logger,
        _errorHandler = errorHandler,
        _showErrorDialogs = showErrorDialogs;

  /// Initialize the global error handler
  void initialize() {
    // Handle Flutter errors
    FlutterError.onError = _handleFlutterError;

    // Handle Dart errors
    PlatformDispatcher.instance.onError = _handlePlatformDispatcherError;

    // Handle Zone errors
    runZonedGuarded(_runApp, _handleZoneError);
  }

  /// Run the app in a guarded zone
  void _runApp() {
    // This is where the app would be started, but we're just setting up the error handler
    // The actual app is started in main.dart
  }

  /// Handle Flutter framework errors
  void _handleFlutterError(FlutterErrorDetails details) {
    _logger.error(
      'Flutter error',
      details.exception,
      details.stack,
    );

    // Convert to AppError and handle
    final error = _errorHandler.handleError(
      details.exception,
      details.stack,
    );

    // Show error UI if needed
    if (_showErrorDialogs) {
      _showErrorUI(error);
    }
  }

  /// Handle platform dispatcher errors
  bool _handlePlatformDispatcherError(Object error, StackTrace stack) {
    _logger.error(
      'Platform dispatcher error',
      error,
      stack,
    );

    // Convert to AppError and handle
    final appError = _errorHandler.handleError(
      error,
      stack,
    );

    // Show error UI if needed
    if (_showErrorDialogs) {
      _showErrorUI(appError);
    }

    // Return true to indicate the error was handled
    return true;
  }

  /// Handle zone errors
  void _handleZoneError(Object error, StackTrace stack) {
    _logger.error(
      'Uncaught error in zone',
      error,
      stack,
    );

    // Convert to AppError and handle
    final appError = _errorHandler.handleError(
      error,
      stack,
    );

    // Show error UI if needed
    if (_showErrorDialogs) {
      _showErrorUI(appError);
    }
  }

  /// Show error UI
  void _showErrorUI(Future<AppError> errorFuture) {
    errorFuture.then((error) {
      // Only show UI if we're in a context where it's possible
      if (Get.context != null && Get.isDialogOpen != true) {
        _errorHandler.showErrorSnackbar(error);
      }
    }).catchError((e) {
      // If we can't even handle the error, just log it
      _logger.error('Failed to show error UI', e);
    });
  }

  /// Create a global error handler instance
  static GlobalErrorHandler create() {
    final logger = LoggerService();
    final errorHandler = ErrorHandler(
      logger: logger,
      auditLogRepository: Get.isRegistered<AuditLogRepository>()
          ? Get.find<AuditLogRepository>()
          : null,
    );

    return GlobalErrorHandler(
      logger: logger,
      errorHandler: errorHandler,
    );
  }
}

