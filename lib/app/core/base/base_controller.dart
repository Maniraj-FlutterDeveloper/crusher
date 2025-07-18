import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../error/app_error.dart';
import '../error/error_handler.dart';
import '../services/logger_service.dart';
import '../widgets/error_display.dart';

abstract class BaseController extends GetxController {
  final LoggerService _logger = Get.find<LoggerService>();
  final ErrorHandler _errorHandler = Get.find<ErrorHandler>();

  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final Rx<AppError?> error = Rx<AppError?>(null);

  @override
  void onInit() {
    super.onInit();
    _logger.debug('${runtimeType.toString()} initialized');
  }

  @override
  void onClose() {
    _logger.debug('${runtimeType.toString()} closed');
    super.onClose();
  }

  /// Run an async operation with loading state and error handling
  Future<T?> runAsyncOperation<T>(
    Future<T> Function() operation, {
    bool showLoading = true,
    bool showError = true,
    String? errorMessage,
    bool throwError = false,
  }) async {
    if (showLoading) {
      isLoading.value = true;
    }
    
    hasError.value = false;
    error.value = null;
    
    try {
      final result = await operation();
      return result;
    } catch (e, stackTrace) {
      AppError appError;
      
      if (e is AppError) {
        appError = e;
      } else {
        appError = await _errorHandler.handleError(
          e,
          stackTrace,
        );
      }
      
      hasError.value = true;
      error.value = appError;
      
      if (showError) {
        _showError(appError);
      }
      
      if (throwError) {
        throw appError;
      }
      
      return null;
    } finally {
      if (showLoading) {
        isLoading.value = false;
      }
    }
  }

  /// Show an error to the user
  void _showError(AppError error) {
    ErrorSnackbar.show(
      error,
      onRetry: error is NetworkError ? () => retryLastOperation() : null,
    );
  }

  /// Retry the last operation
  void retryLastOperation() {
    // Override in subclasses to implement retry logic
  }

  /// Show a loading dialog
  void showLoadingDialog({String? message}) {
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: Center(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(message ?? 'Loading...'),
                ],
              ),
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// Hide the loading dialog
  void hideLoadingDialog() {
    if (Get.isDialogOpen == true) {
      Get.back();
    }
  }

  /// Show a success message
  void showSuccessMessage(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      icon: const Icon(
        Icons.check_circle,
        color: Colors.white,
      ),
    );
  }

  /// Show an info message
  void showInfoMessage(String message) {
    Get.snackbar(
      'Information',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      icon: const Icon(
        Icons.info,
        color: Colors.white,
      ),
    );
  }

  /// Show a warning message
  void showWarningMessage(String message) {
    Get.snackbar(
      'Warning',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      icon: const Icon(
        Icons.warning,
        color: Colors.white,
      ),
    );
  }

  /// Show a confirmation dialog
  Future<bool> showConfirmationDialog({
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }
}

