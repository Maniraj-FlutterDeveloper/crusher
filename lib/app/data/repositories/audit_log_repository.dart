import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../models/audit_log_model.dart';
import '../services/auth_service.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

class AuditLogRepository {
  final DatabaseService _databaseService = Get.find<DatabaseService>();
  final AuthService _authService = Get.find<AuthService>();
  
  // Table name
  static const String tableName = 'audit_logs';
  
  // Create table
  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        action TEXT NOT NULL,
        module TEXT NOT NULL,
        details TEXT,
        ip_address TEXT,
        user_agent TEXT,
        timestamp TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE SET NULL
      )
    ''');
  }
  
  // Get all audit logs
  Future<List<AuditLogModel>> getAllAuditLogs() async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      orderBy: 'timestamp DESC',
    );
    
    return List.generate(maps.length, (i) {
      return AuditLogModel.fromJson(maps[i]);
    });
  }
  
  // Get audit logs by user ID
  Future<List<AuditLogModel>> getAuditLogsByUserId(int userId) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'timestamp DESC',
    );
    
    return List.generate(maps.length, (i) {
      return AuditLogModel.fromJson(maps[i]);
    });
  }
  
  // Get audit logs by module
  Future<List<AuditLogModel>> getAuditLogsByModule(String module) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'module = ?',
      whereArgs: [module],
      orderBy: 'timestamp DESC',
    );
    
    return List.generate(maps.length, (i) {
      return AuditLogModel.fromJson(maps[i]);
    });
  }
  
  // Get audit logs by action
  Future<List<AuditLogModel>> getAuditLogsByAction(String action) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'action = ?',
      whereArgs: [action],
      orderBy: 'timestamp DESC',
    );
    
    return List.generate(maps.length, (i) {
      return AuditLogModel.fromJson(maps[i]);
    });
  }
  
  // Get audit logs by date range
  Future<List<AuditLogModel>> getAuditLogsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'timestamp BETWEEN ? AND ?',
      whereArgs: [
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ],
      orderBy: 'timestamp DESC',
    );
    
    return List.generate(maps.length, (i) {
      return AuditLogModel.fromJson(maps[i]);
    });
  }
  
  // Insert a new audit log
  Future<int> insertAuditLog(AuditLogModel auditLog) async {
    final db = await _databaseService.database;
    return await db.insert(
      tableName,
      auditLog.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  // Delete audit logs older than a certain date
  Future<int> deleteOldAuditLogs(DateTime cutoffDate) async {
    final db = await _databaseService.database;
    return await db.delete(
      tableName,
      where: 'timestamp < ?',
      whereArgs: [cutoffDate.toIso8601String()],
    );
  }
  
  // Log an action
  Future<void> logAction({
    required String action,
    required String module,
    Map<String, dynamic>? details,
    bool includeDeviceInfo = false,
  }) async {
    try {
      // Get current user ID
      final userId = _authService.currentUser?.id;
      
      // Get device info if requested
      String? userAgent;
      String? ipAddress;
      
      if (includeDeviceInfo) {
        userAgent = await _getUserAgent();
        ipAddress = await _getIpAddress();
      }
      
      // Create audit log
      final auditLog = AuditLogModel(
        userId: userId,
        action: action,
        module: module,
        details: details != null ? json.encode(details) : null,
        ipAddress: ipAddress,
        userAgent: userAgent,
        timestamp: DateTime.now(),
      );
      
      // Insert audit log
      await insertAuditLog(auditLog);
    } catch (e) {
      debugPrint('Error logging action: $e');
    }
  }
  
  // Get user agent string
  Future<String?> _getUserAgent() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      final packageInfo = await PackageInfo.fromPlatform();
      
      String deviceInfoStr;
      
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceInfoStr = '${androidInfo.brand} ${androidInfo.model} (Android ${androidInfo.version.release})';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceInfoStr = '${iosInfo.name} (iOS ${iosInfo.systemVersion})';
      } else if (Platform.isWindows) {
        final windowsInfo = await deviceInfo.windowsInfo;
        deviceInfoStr = 'Windows ${windowsInfo.productName} ${windowsInfo.buildNumber}';
      } else if (Platform.isMacOS) {
        final macOsInfo = await deviceInfo.macOsInfo;
        deviceInfoStr = 'macOS ${macOsInfo.osRelease}';
      } else if (Platform.isLinux) {
        final linuxInfo = await deviceInfo.linuxInfo;
        deviceInfoStr = 'Linux ${linuxInfo.prettyName}';
      } else {
        deviceInfoStr = 'Unknown Device';
      }
      
      return 'Crusher App ${packageInfo.version} (${packageInfo.buildNumber}) / $deviceInfoStr';
    } catch (e) {
      debugPrint('Error getting user agent: $e');
      return null;
    }
  }
  
  // Get IP address
  Future<String?> _getIpAddress() async {
    try {
      final interfaces = await NetworkInterface.list(
        includeLoopback: false,
        type: InternetAddressType.IPv4,
      );
      
      if (interfaces.isNotEmpty && interfaces.first.addresses.isNotEmpty) {
        return interfaces.first.addresses.first.address;
      }
      
      return null;
    } catch (e) {
      debugPrint('Error getting IP address: $e');
      return null;
    }
  }
}

