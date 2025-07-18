import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/error/app_error.dart';
import '../core/values/app_colors.dart';

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
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.errorColor.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.error_outline,
                color: AppColors.errorColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  error.title,
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
          if (error.field != null) ...[
            const SizedBox(height: 8),
            Text(
              'Field: ${error.field}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          if (showDetails && error.stackTrace != null) ...[
            const SizedBox(height: 16),
            ExpansionTile(
              title: Text(
                'Technical Details',
                style: Theme.of(context).textTheme.bodySmall,
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
  static void show(AppError error) {
    Get.snackbar(
      error.title,
      error.message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.errorColor.withOpacity(0.9),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 5),
      icon: const Icon(
        Icons.error_outline,
        color: Colors.white,
      ),
      mainButton: error.canRetry
          ? TextButton(
              onPressed: error.retry,
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
  static void show(AppError error) {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: AppColors.errorColor,
            ),
            const SizedBox(width: 8),
            Text(error.title),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(error.message),
            if (error.field != null) ...[
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
          if (error.canRetry)
            ElevatedButton(
              onPressed: () {
                Get.back();
                error.retry();
              },
              child: const Text('RETRY'),
            ),
        ],
      ),
    );
  }
}

