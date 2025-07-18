import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

enum LogLevel {
  debug,
  info,
  warning,
  error,
  fatal,
}

class LoggerService {
  final bool enableConsoleLogs;
  final bool enableFileLogs;
  final int maxLogFiles;
  final int maxFileSizeBytes;
  final LogLevel minLogLevel;

  File? _currentLogFile;
  int _currentLogFileSize = 0;
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss.SSS');
  final DateFormat _fileNameFormat = DateFormat('yyyy-MM-dd');

  LoggerService({
    this.enableConsoleLogs = kDebugMode,
    this.enableFileLogs = true,
    this.maxLogFiles = 5,
    this.maxFileSizeBytes = 5 * 1024 * 1024, // 5 MB
    this.minLogLevel = kDebugMode ? LogLevel.debug : LogLevel.info,
  });

  /// Initialize the logger
  Future<void> init() async {
    if (enableFileLogs) {
      await _initLogFile();
      await _cleanupOldLogFiles();
    }
  }

  /// Log a debug message
  void debug(String message, [dynamic data, StackTrace? stackTrace]) {
    _log(LogLevel.debug, message, data, stackTrace);
  }

  /// Log an info message
  void info(String message, [dynamic data, StackTrace? stackTrace]) {
    _log(LogLevel.info, message, data, stackTrace);
  }

  /// Log a warning message
  void warning(String message, [dynamic data, StackTrace? stackTrace]) {
    _log(LogLevel.warning, message, data, stackTrace);
  }

  /// Log an error message
  void error(String message, [dynamic data, StackTrace? stackTrace]) {
    _log(LogLevel.error, message, data, stackTrace);
  }

  /// Log a fatal error message
  void fatal(String message, [dynamic data, StackTrace? stackTrace]) {
    _log(LogLevel.fatal, message, data, stackTrace);
  }

  /// Internal logging method
  void _log(LogLevel level, String message, [dynamic data, StackTrace? stackTrace]) {
    if (level.index < minLogLevel.index) {
      return;
    }

    final timestamp = _dateFormat.format(DateTime.now());
    final levelString = level.toString().split('.').last.toUpperCase();
    
    String logMessage = '[$timestamp] $levelString: $message';
    
    if (data != null) {
      String dataString;
      if (data is Map || data is List) {
        try {
          dataString = const JsonEncoder.withIndent('  ').convert(data);
        } catch (e) {
          dataString = data.toString();
        }
      } else {
        dataString = data.toString();
      }
      logMessage += '\nData: $dataString';
    }
    
    if (stackTrace != null) {
      logMessage += '\nStackTrace: $stackTrace';
    }

    // Console logging
    if (enableConsoleLogs) {
      switch (level) {
        case LogLevel.debug:
          debugPrint(logMessage);
          break;
        case LogLevel.info:
          debugPrint(logMessage);
          break;
        case LogLevel.warning:
          debugPrint('\x1B[33m$logMessage\x1B[0m'); // Yellow
          break;
        case LogLevel.error:
          debugPrint('\x1B[31m$logMessage\x1B[0m'); // Red
          break;
        case LogLevel.fatal:
          debugPrint('\x1B[41m\x1B[37m$logMessage\x1B[0m'); // White on red
          break;
      }
    }

    // File logging
    if (enableFileLogs) {
      _writeToLogFile('$logMessage\n');
    }
  }

  /// Initialize the log file
  Future<void> _initLogFile() async {
    try {
      final directory = await _getLogDirectory();
      final today = _fileNameFormat.format(DateTime.now());
      final logFilePath = '${directory.path}/log_$today.txt';
      
      _currentLogFile = File(logFilePath);
      
      if (await _currentLogFile!.exists()) {
        _currentLogFileSize = await _currentLogFile!.length();
      } else {
        await _currentLogFile!.create(recursive: true);
        _currentLogFileSize = 0;
      }
    } catch (e) {
      debugPrint('Failed to initialize log file: $e');
    }
  }

  /// Write to the log file
  Future<void> _writeToLogFile(String message) async {
    if (_currentLogFile == null) {
      await _initLogFile();
    }

    try {
      // Check if we need to rotate the log file
      if (_currentLogFileSize >= maxFileSizeBytes) {
        await _rotateLogFile();
      }

      // Write to the log file
      await _currentLogFile!.writeAsString(message, mode: FileMode.append);
      _currentLogFileSize += message.length;
    } catch (e) {
      debugPrint('Failed to write to log file: $e');
    }
  }

  /// Rotate the log file
  Future<void> _rotateLogFile() async {
    try {
      final directory = await _getLogDirectory();
      final today = _fileNameFormat.format(DateTime.now());
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final newLogFilePath = '${directory.path}/log_${today}_$timestamp.txt';
      
      // Create a new log file
      _currentLogFile = File(newLogFilePath);
      await _currentLogFile!.create(recursive: true);
      _currentLogFileSize = 0;
      
      // Clean up old log files
      await _cleanupOldLogFiles();
    } catch (e) {
      debugPrint('Failed to rotate log file: $e');
    }
  }

  /// Clean up old log files
  Future<void> _cleanupOldLogFiles() async {
    try {
      final directory = await _getLogDirectory();
      final files = directory.listSync()
          .whereType<File>()
          .where((file) => file.path.contains('log_'))
          .toList();
      
      // Sort files by modification time (newest first)
      files.sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
      
      // Delete old files
      if (files.length > maxLogFiles) {
        for (var i = maxLogFiles; i < files.length; i++) {
          await files[i].delete();
        }
      }
    } catch (e) {
      debugPrint('Failed to clean up old log files: $e');
    }
  }

  /// Get the log directory
  Future<Directory> _getLogDirectory() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final logDir = Directory('${appDocDir.path}/logs');
    
    if (!await logDir.exists()) {
      await logDir.create(recursive: true);
    }
    
    return logDir;
  }

  /// Get all log files
  Future<List<File>> getLogFiles() async {
    try {
      final directory = await _getLogDirectory();
      final files = directory.listSync()
          .whereType<File>()
          .where((file) => file.path.contains('log_'))
          .toList();
      
      // Sort files by modification time (newest first)
      files.sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
      
      return files;
    } catch (e) {
      debugPrint('Failed to get log files: $e');
      return [];
    }
  }

  /// Get the content of a log file
  Future<String> getLogFileContent(File file) async {
    try {
      return await file.readAsString();
    } catch (e) {
      debugPrint('Failed to read log file: $e');
      return 'Failed to read log file: $e';
    }
  }

  /// Delete all log files
  Future<void> deleteAllLogFiles() async {
    try {
      final directory = await _getLogDirectory();
      final files = directory.listSync()
          .whereType<File>()
          .where((file) => file.path.contains('log_'));
      
      for (final file in files) {
        await file.delete();
      }
      
      // Reinitialize the log file
      await _initLogFile();
    } catch (e) {
      debugPrint('Failed to delete log files: $e');
    }
  }
}

