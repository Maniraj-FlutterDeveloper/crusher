import 'dart:convert';
import 'user_model.dart';

class AuditLogModel {
  final int? id;
  final int? userId;
  final String action;
  final String module;
  final String? details;
  final String? ipAddress;
  final String? userAgent;
  final DateTime timestamp;
  final UserModel? user;
  
  AuditLogModel({
    this.id,
    this.userId,
    required this.action,
    required this.module,
    this.details,
    this.ipAddress,
    this.userAgent,
    required this.timestamp,
    this.user,
  });
  
  factory AuditLogModel.fromJson(Map<String, dynamic> json) {
    return AuditLogModel(
      id: json['id'],
      userId: json['user_id'],
      action: json['action'],
      module: json['module'],
      details: json['details'],
      ipAddress: json['ip_address'],
      userAgent: json['user_agent'],
      timestamp: DateTime.parse(json['timestamp']),
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'action': action,
      'module': module,
      'details': details,
      'ip_address': ipAddress,
      'user_agent': userAgent,
      'timestamp': timestamp.toIso8601String(),
      'user': user?.toJson(),
    };
  }
  
  // Create a copy of this AuditLogModel with the given fields replaced
  AuditLogModel copyWith({
    int? id,
    int? userId,
    String? action,
    String? module,
    String? details,
    String? ipAddress,
    String? userAgent,
    DateTime? timestamp,
    UserModel? user,
  }) {
    return AuditLogModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      action: action ?? this.action,
      module: module ?? this.module,
      details: details ?? this.details,
      ipAddress: ipAddress ?? this.ipAddress,
      userAgent: userAgent ?? this.userAgent,
      timestamp: timestamp ?? this.timestamp,
      user: user ?? this.user,
    );
  }
  
  // Convert details to a Map if it's a JSON string
  Map<String, dynamic>? get detailsMap {
    if (details == null || details!.isEmpty) {
      return null;
    }
    
    try {
      return json.decode(details!) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }
  
  // Get a formatted timestamp string
  String get formattedTimestamp {
    return '${timestamp.day.toString().padLeft(2, '0')}/${timestamp.month.toString().padLeft(2, '0')}/${timestamp.year} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}';
  }
  
  // Get a short description of the action
  String get actionDescription {
    switch (action) {
      case 'login':
        return 'User Login';
      case 'logout':
        return 'User Logout';
      case 'create':
        return 'Create Record';
      case 'update':
        return 'Update Record';
      case 'delete':
        return 'Delete Record';
      case 'view':
        return 'View Record';
      case 'export':
        return 'Export Data';
      case 'import':
        return 'Import Data';
      case 'password_change':
        return 'Password Change';
      case 'permission_change':
        return 'Permission Change';
      case 'role_change':
        return 'Role Change';
      default:
        return action;
    }
  }
  
  // Get a color for the action (for UI purposes)
  String get actionColor {
    switch (action) {
      case 'login':
      case 'logout':
        return 'blue';
      case 'create':
        return 'green';
      case 'update':
        return 'orange';
      case 'delete':
        return 'red';
      case 'view':
        return 'purple';
      case 'export':
      case 'import':
        return 'teal';
      case 'password_change':
      case 'permission_change':
      case 'role_change':
        return 'amber';
      default:
        return 'grey';
    }
  }
}

