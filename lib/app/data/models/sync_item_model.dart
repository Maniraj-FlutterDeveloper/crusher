import 'dart:convert';

enum SyncStatus {
  pending,
  syncing,
  synced,
  failed,
}

class SyncItemModel {
  final int? id;
  final String entityType;
  final String entityId;
  final String action;
  final Map<String, dynamic> data;
  final SyncStatus status;
  final int priority;
  final DateTime createdAt;
  final DateTime? syncedAt;
  final int attempts;
  final String? errorMessage;

  SyncItemModel({
    this.id,
    required this.entityType,
    required this.entityId,
    required this.action,
    required this.data,
    required this.status,
    required this.priority,
    required this.createdAt,
    this.syncedAt,
    required this.attempts,
    this.errorMessage,
  });

  factory SyncItemModel.fromJson(Map<String, dynamic> json) {
    return SyncItemModel(
      id: json['id'],
      entityType: json['entity_type'],
      entityId: json['entity_id'],
      action: json['action'],
      data: json['data'] is String
          ? jsonDecode(json['data'])
          : Map<String, dynamic>.from(json['data']),
      status: _statusFromString(json['status']),
      priority: json['priority'],
      createdAt: DateTime.parse(json['created_at']),
      syncedAt: json['synced_at'] != null
          ? DateTime.parse(json['synced_at'])
          : null,
      attempts: json['attempts'],
      errorMessage: json['error_message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'entity_type': entityType,
      'entity_id': entityId,
      'action': action,
      'data': data,
      'status': _statusToString(status),
      'priority': priority,
      'created_at': createdAt.toIso8601String(),
      'synced_at': syncedAt?.toIso8601String(),
      'attempts': attempts,
      'error_message': errorMessage,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'entity_type': entityType,
      'entity_id': entityId,
      'action': action,
      'data': jsonEncode(data),
      'status': _statusToString(status),
      'priority': priority,
      'created_at': createdAt.toIso8601String(),
      'synced_at': syncedAt?.toIso8601String(),
      'attempts': attempts,
      'error_message': errorMessage,
    };
  }

  SyncItemModel copyWith({
    int? id,
    String? entityType,
    String? entityId,
    String? action,
    Map<String, dynamic>? data,
    SyncStatus? status,
    int? priority,
    DateTime? createdAt,
    DateTime? syncedAt,
    int? attempts,
    String? errorMessage,
  }) {
    return SyncItemModel(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      action: action ?? this.action,
      data: data ?? this.data,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      syncedAt: syncedAt ?? this.syncedAt,
      attempts: attempts ?? this.attempts,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  static SyncStatus _statusFromString(String status) {
    switch (status) {
      case 'pending':
        return SyncStatus.pending;
      case 'syncing':
        return SyncStatus.syncing;
      case 'synced':
        return SyncStatus.synced;
      case 'failed':
        return SyncStatus.failed;
      default:
        return SyncStatus.pending;
    }
  }

  static String _statusToString(SyncStatus status) {
    switch (status) {
      case SyncStatus.pending:
        return 'pending';
      case SyncStatus.syncing:
        return 'syncing';
      case SyncStatus.synced:
        return 'synced';
      case SyncStatus.failed:
        return 'failed';
    }
  }
}

