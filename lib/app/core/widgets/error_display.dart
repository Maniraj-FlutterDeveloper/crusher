import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../error/app_error.dart';

class ErrorDisplay extends StatelessWidget {
  final AppError error;
  final VoidCallback? onRetry;
  final bool showDetails;
  final bool showStackTrace;

  const ErrorDisplay({
    Key? key,
    required this.error,
    this.onRetry,
    this.showDetails = kDebugMode,
    this.showStackTrace = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildMessage(),
            if (showDetails && error.details != null) ...[
              const SizedBox(height: 16),
              _buildDetails(),
            ],
            if (showStackTrace && error.stackTrace != null) ...[
              const SizedBox(height: 16),
              _buildStackTrace(),
            ],
            const SizedBox(height: 16),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        _buildIcon(),
        const SizedBox(width: 8),
        Text(
          _getErrorTitle(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildIcon() {
    IconData iconData;
    Color iconColor;

    if (error is NetworkError) {
      iconData = Icons.signal_wifi_off;
      iconColor = Colors.orange;
    } else if (error is DatabaseError) {
      iconData = Icons.storage;
      iconColor = Colors.red;
    } else if (error is AuthError) {
      iconData = Icons.security;
      iconColor = Colors.red;
    } else if (error is ValidationError) {
      iconData = Icons.warning;
      iconColor = Colors.orange;
    } else if (error is BusinessError) {
      iconData = Icons.business;
      iconColor = Colors.orange;
    } else if (error is FileSystemError) {
      iconData = Icons.folder;
      iconColor = Colors.red;
    } else {
      iconData = Icons.error;
      iconColor = Colors.red;
    }

    return Icon(
      iconData,
      color: iconColor,
      size: 24,
    );
  }

  Widget _buildMessage() {
    return Text(
      error.message,
      style: const TextStyle(fontSize: 16),
    );
  }

  Widget _buildDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Details:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            error.details.toString(),
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStackTrace() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Stack Trace:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            error.stackTrace.toString(),
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (onRetry != null)
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        const SizedBox(width: 8),
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  String _getErrorTitle() {
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
}

class ErrorPage extends StatelessWidget {
  final AppError error;
  final VoidCallback? onRetry;
  final bool showDetails;
  final bool showStackTrace;

  const ErrorPage({
    Key? key,
    required this.error,
    this.onRetry,
    this.showDetails = kDebugMode,
    this.showStackTrace = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ErrorDisplay(
            error: error,
            onRetry: onRetry,
            showDetails: showDetails,
            showStackTrace: showStackTrace,
          ),
        ),
      ),
    );
  }
}

class ErrorSnackbar {
  static void show(AppError error, {VoidCallback? onRetry}) {
    Get.snackbar(
      _getErrorTitle(error),
      error.message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: _getBackgroundColor(error),
      colorText: Colors.white,
      duration: const Duration(seconds: 5),
      isDismissible: true,
      icon: Icon(
        _getIconData(error),
        color: Colors.white,
      ),
      mainButton: onRetry != null
          ? TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(
                Icons.refresh,
                color: Colors.white,
              ),
              label: const Text(
                'Retry',
                style: TextStyle(color: Colors.white),
              ),
            )
          : null,
    );
  }

  static String _getErrorTitle(AppError error) {
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

  static IconData _getIconData(AppError error) {
    if (error is NetworkError) {
      return Icons.signal_wifi_off;
    } else if (error is DatabaseError) {
      return Icons.storage;
    } else if (error is AuthError) {
      return Icons.security;
    } else if (error is ValidationError) {
      return Icons.warning;
    } else if (error is BusinessError) {
      return Icons.business;
    } else if (error is FileSystemError) {
      return Icons.folder;
    } else {
      return Icons.error;
    }
  }

  static Color _getBackgroundColor(AppError error) {
    if (error is ValidationError) {
      return Colors.orange;
    } else if (error is NetworkError && error.isConnectionError) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}

