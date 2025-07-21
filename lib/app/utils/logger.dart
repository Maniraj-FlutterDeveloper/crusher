import 'package:flutter/foundation.dart';

class Logger {
  static void info(String message) {
    if (kDebugMode) {
      debugPrint('INFO: $message');
    }
  }

  static void error(String message, [dynamic error]) {
    if (kDebugMode) {
      debugPrint('ERROR: $message');
      if (error != null) {
        debugPrint('Error details: $error');
      }
    }
  }

  static void warning(String message) {
    if (kDebugMode) {
      debugPrint('WARNING: $message');
    }
  }

  static void debug(String message) {
    if (kDebugMode) {
      debugPrint('DEBUG: $message');
    }
  }
}