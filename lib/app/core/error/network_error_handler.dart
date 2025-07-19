import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app_error.dart';
import 'error_handler.dart';
import '../services/logger_service.dart';

class NetworkErrorHandler {
  final LoggerService _logger;
  final ErrorHandler _errorHandler;
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  bool _isConnected = true;
  bool _isShowingDialog = false;

  NetworkErrorHandler({
    required LoggerService logger,
    required ErrorHandler errorHandler,
  })  : _logger = logger,
        _errorHandler = errorHandler;

  /// Initialize the network error handler
  void initialize() {
    // Check initial connection state
    _checkConnectivity();

    // Listen for connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((result) {
      _handleConnectivityChange(result);
    });
  }

  /// Dispose the network error handler
  void dispose() {
    _connectivitySubscription?.cancel();
  }

  /// Check current connectivity
  Future<void> _checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _handleConnectivityChange(result);
    } catch (e) {
      _logger.error('Failed to check connectivity', e);
    }
  }

  /// Handle connectivity change
  void _handleConnectivityChange(ConnectivityResult result) {
    final wasConnected = _isConnected;
    _isConnected = result != ConnectivityResult.none;

    // Log connectivity change
    _logger.info('Connectivity changed: $result');

    // Show UI if connection was lost
    if (wasConnected && !_isConnected) {
      _showNoConnectionUI();
    }

    // Show UI if connection was restored
    if (!wasConnected && _isConnected) {
      _showConnectionRestoredUI();
    }
  }

  /// Show no connection UI
  void _showNoConnectionUI() {
    if (_isShowingDialog) return;

    _isShowingDialog = true;

    // Show a dialog if we have a context
    if (Get.context != null) {
      showDialog(
        context: Get.context!,
        barrierDismissible: false,
        builder: (context) => WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            title: const Text('No Internet Connection'),
            content: const Text(
              'Please check your internet connection and try again.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _isShowingDialog = false;
                  Navigator.of(context).pop();
                  _checkConnectivity();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    } else {
      // Show a snackbar if we don't have a context
      Get.snackbar(
        'No Internet Connection',
        'Please check your internet connection and try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
        isDismissible: true,
        icon: const Icon(
          Icons.signal_wifi_off,
          color: Colors.white,
        ),
      );
    }
  }

  /// Show connection restored UI
  void _showConnectionRestoredUI() {
    // Close the dialog if it's showing
    if (_isShowingDialog && Get.isDialogOpen == true) {
      Get.back();
      _isShowingDialog = false;
    }

    // Show a snackbar
    Get.snackbar(
      'Connection Restored',
      'Your internet connection has been restored.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      isDismissible: true,
      icon: const Icon(
        Icons.wifi,
        color: Colors.white,
      ),
    );
  }

  /// Check if we have an internet connection
  Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (e) {
      _logger.warning('No internet connection', e);
      return false;
    } catch (e) {
      _logger.error('Failed to check internet connection', e);
      return false;
    }
  }

  /// Handle a network request with error handling
  Future<T> handleNetworkRequest<T>(
    Future<T> Function() request, {
    bool checkConnection = true,
    String? errorMessage,
  }) async {
    try {
      // Check for internet connection if requested
      if (checkConnection) {
        final hasConnection = await hasInternetConnection();
        if (!hasConnection) {
          throw NetworkError.connection();
        }
      }

      // Execute the request
      return await request();
    } on TimeoutException catch (e) {
      final error = NetworkError.timeout(
        message: errorMessage ?? 'Request timed out',
        stackTrace: StackTrace.current,
      );
      throw await _errorHandler.handleError(error);
    } on SocketException catch (e) {
      final error = NetworkError.connection(
        message: errorMessage ?? 'Network connection error',
        stackTrace: StackTrace.current,
      );
      throw await _errorHandler.handleError(error);
    } on HttpException catch (e) {
      final error = NetworkError(
        message: errorMessage ?? 'HTTP error: ${e.message}',
        code: 'HTTP_ERROR',
        details: e,
        stackTrace: StackTrace.current,
      );
      throw await _errorHandler.handleError(error);
    } catch (e, stackTrace) {
      // If it's already an AppError, just rethrow it
      if (e is AppError) {
        throw e;
      }

      // Otherwise, convert it to a NetworkError
      final error = NetworkError(
        message: errorMessage ?? 'Network request failed',
        code: 'NETWORK_ERROR',
        details: e,
        stackTrace: stackTrace,
      );
      throw await _errorHandler.handleError(error);
    }
  }
}

