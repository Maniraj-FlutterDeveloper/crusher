import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:crusher_management/app/data/models/sync_item_model.dart';

void main() {
  group('SyncItemModel Tests', () {
    final testDateTime = DateTime(2023, 1, 1, 12, 0, 0);
    final testSyncedDateTime = DateTime(2023, 1, 1, 12, 30, 0);
    
    final testData = {
      'name': 'Test Item',
      'value': 123,
      'isActive': true,
    };
    
    final testSyncItem = SyncItemModel(
      id: 1,
      entityType: 'test_entity',
      entityId: '123',
      action: 'create',
      data: testData,
      status: SyncStatus.pending,
      priority: 2,
      createdAt: testDateTime,
      syncedAt: testSyncedDateTime,
      attempts: 0,
      errorMessage: null,
    );

    test('fromJson should correctly parse JSON', () {
      // Arrange
      final json = {
        'id': 1,
        'entity_type': 'test_entity',
        'entity_id': '123',
        'action': 'create',
        'data': jsonEncode(testData),
        'status': 'pending',
        'priority': 2,
        'created_at': testDateTime.toIso8601String(),
        'synced_at': testSyncedDateTime.toIso8601String(),
        'attempts': 0,
        'error_message': null,
      };
      
      // Act
      final result = SyncItemModel.fromJson(json);
      
      // Assert
      expect(result.id, 1);
      expect(result.entityType, 'test_entity');
      expect(result.entityId, '123');
      expect(result.action, 'create');
      expect(result.data, testData);
      expect(result.status, SyncStatus.pending);
      expect(result.priority, 2);
      expect(result.createdAt, testDateTime);
      expect(result.syncedAt, testSyncedDateTime);
      expect(result.attempts, 0);
      expect(result.errorMessage, null);
    });

    test('toJson should correctly convert to JSON', () {
      // Act
      final result = testSyncItem.toJson();
      
      // Assert
      expect(result['id'], 1);
      expect(result['entity_type'], 'test_entity');
      expect(result['entity_id'], '123');
      expect(result['action'], 'create');
      expect(result['data'], testData);
      expect(result['status'], 'pending');
      expect(result['priority'], 2);
      expect(result['created_at'], testDateTime.toIso8601String());
      expect(result['synced_at'], testSyncedDateTime.toIso8601String());
      expect(result['attempts'], 0);
      expect(result['error_message'], null);
    });

    test('toMap should correctly convert to database map', () {
      // Act
      final result = testSyncItem.toMap();
      
      // Assert
      expect(result['entity_type'], 'test_entity');
      expect(result['entity_id'], '123');
      expect(result['action'], 'create');
      expect(result['data'], jsonEncode(testData));
      expect(result['status'], 'pending');
      expect(result['priority'], 2);
      expect(result['created_at'], testDateTime.toIso8601String());
      expect(result['synced_at'], testSyncedDateTime.toIso8601String());
      expect(result['attempts'], 0);
      expect(result['error_message'], null);
    });

    test('copyWith should correctly create a copy with modified values', () {
      // Act
      final result = testSyncItem.copyWith(
        status: SyncStatus.synced,
        attempts: 1,
        errorMessage: 'Test error',
      );
      
      // Assert
      expect(result.id, 1);
      expect(result.entityType, 'test_entity');
      expect(result.entityId, '123');
      expect(result.action, 'create');
      expect(result.data, testData);
      expect(result.status, SyncStatus.synced);
      expect(result.priority, 2);
      expect(result.createdAt, testDateTime);
      expect(result.syncedAt, testSyncedDateTime);
      expect(result.attempts, 1);
      expect(result.errorMessage, 'Test error');
    });

    test('_statusFromString should correctly convert string to SyncStatus', () {
      // Act & Assert
      expect(SyncItemModel._statusFromString('pending'), SyncStatus.pending);
      expect(SyncItemModel._statusFromString('syncing'), SyncStatus.syncing);
      expect(SyncItemModel._statusFromString('synced'), SyncStatus.synced);
      expect(SyncItemModel._statusFromString('failed'), SyncStatus.failed);
      expect(SyncItemModel._statusFromString('unknown'), SyncStatus.pending);
    });

    test('_statusToString should correctly convert SyncStatus to string', () {
      // Act & Assert
      expect(SyncItemModel._statusToString(SyncStatus.pending), 'pending');
      expect(SyncItemModel._statusToString(SyncStatus.syncing), 'syncing');
      expect(SyncItemModel._statusToString(SyncStatus.synced), 'synced');
      expect(SyncItemModel._statusToString(SyncStatus.failed), 'failed');
    });
  });
}

