import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/error/app_error.dart';
import '../core/values/app_colors.dart';

// Helper function to get error title based on error type
String getErrorTitle(AppError error) {
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

class ErrorDisplay extends StatelessWidget {
  final AppError error;
  final VoidCallback? onRetry;
  final bool showRetry;
  final bool showDetails;
  
  const ErrorDisplay({
    Key? key,
    required this.error,
    this.onRetry,
    this.showRetry = true,
    this.showDetails = false,
  }) : super(key: key);
  
  String _getTitle() {
    return getErrorTitle(error);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.errorColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.errorColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.error_outline,
                color: AppColors.errorColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _getTitle(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.errorColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            error.message,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (error is ValidationError) ...[
            const SizedBox(height: 8),
            Text(
                'Field: ${(error as ValidationError).field}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          if (showDetails && error.stackTrace != null) ...[
            const SizedBox(height: 16),
            ExpansionTile(
                title: const Text(
                  'Technical Details',
                  style: TextStyle(fontSize: 12),
                ),
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    error.stackTrace.toString(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (showRetry && onRetry != null) ...[
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: AppColors.primaryColor,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class ErrorSnackbar {
  static void show(AppError error, {VoidCallback? onRetry}) {
    Get.snackbar(
      getErrorTitle(error),
      error.message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.errorColor.withValues(alpha: 0.9),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 5),
      icon: const Icon(
        Icons.error_outline,
        color: Colors.white,
      ),
      mainButton: onRetry != null
          ? TextButton(
              onPressed: onRetry,
              child: const Text(
                'RETRY',
                style: TextStyle(color: Colors.white),
              ),
            )
          : null,
    );
  }
}

class ErrorDialog {
  static void show(AppError error, {VoidCallback? onRetry}) {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            const Icon(
              Icons.error_outline,
              color: AppColors.errorColor,
            ),
            const SizedBox(width: 8),
            Text(getErrorTitle(error)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(error.message),
            if (error is ValidationError) ...[
              const SizedBox(height: 8),
              Text(
                'Field: ${error.field}',
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('CLOSE'),
          ),
          if (onRetry != null)
            ElevatedButton(
              onPressed: () {
                Get.back();
                onRetry();
              },
              child: const Text('RETRY'),
            ),
        ],
      ),
    );
  }
}

