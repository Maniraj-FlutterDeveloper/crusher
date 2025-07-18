import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';

import '../models/sync_item_model.dart';
import '../services/db_service.dart';
import '../../core/error/database_error_handler.dart';
import '../../core/services/logger_service.dart';

class SyncRepository {
  final DbService _dbService = Get.find<DbService>();
  final LoggerService _logger = Get.find<LoggerService>();
  final DatabaseErrorHandler _dbErrorHandler = Get.find<DatabaseErrorHandler>();

  static const String tableName = 'sync_items';

  /// Create sync table if it doesn't exist
  Future<void> createTable() async {
    await _dbErrorHandler.handleDatabaseOperation(
      () async {
        final db = await _dbService.database;
        await db.execute('''
          CREATE TABLE IF NOT EXISTS $tableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            entity_type TEXT NOT NULL,
            entity_id TEXT NOT NULL,
            action TEXT NOT NULL,
            data TEXT NOT NULL,
            status TEXT NOT NULL,
            priority INTEGER NOT NULL,
            created_at TEXT NOT NULL,
            synced_at TEXT,
            attempts INTEGER NOT NULL,
            error_message TEXT
          )
        ''');

        // Create indexes for faster queries
        await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_sync_status ON $tableName (status)',
        );
        await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_sync_entity ON $tableName (entity_type, entity_id)',
        );
      },
      operationType: 'create_table',
      tableName: tableName,
      errorMessage: 'Failed to create sync table',
    );
  }

  /// Add a sync item to the queue
  Future<int> addSyncItem(SyncItemModel item) async {
    return await _dbErrorHandler.handleWrite(
      () async {
        final db = await _dbService.database;
        return await db.insert(
          tableName,
          item.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      },
      tableName: tableName,
      errorMessage: 'Failed to add sync item',
    );
  }

  /// Get all pending sync items
  Future<List<SyncItemModel>> getPendingSyncItems() async {
    return await _dbErrorHandler.handleRead(
      () async {
        final db = await _dbService.database;
        final List<Map<String, dynamic>> maps = await db.query(
          tableName,
          where: 'status = ?',
          whereArgs: ['pending'],
          orderBy: 'priority DESC, created_at ASC',
        );

        return List.generate(maps.length, (i) {
          return SyncItemModel.fromJson(maps[i]);
        });
      },
      tableName: tableName,
      errorMessage: 'Failed to get pending sync items',
    );
  }

  /// Get the count of pending sync items
  Future<int> getPendingSyncItemsCount() async {
    return await _dbErrorHandler.handleRead(
      () async {
        final db = await _dbService.database;
        final result = await db.rawQuery(
          'SELECT COUNT(*) as count FROM $tableName WHERE status = ?',
          ['pending'],
        );
        return Sqflite.firstIntValue(result) ?? 0;
      },
      tableName: tableName,
      errorMessage: 'Failed to get pending sync items count',
    );
  }

  /// Get the count of synced items
  Future<int> getSyncedItemsCount() async {
    return await _dbErrorHandler.handleRead(
      () async {
        final db = await _dbService.database;
        final result = await db.rawQuery(
          'SELECT COUNT(*) as count FROM $tableName WHERE status = ?',
          ['synced'],
        );
        return Sqflite.firstIntValue(result) ?? 0;
      },
      tableName: tableName,
      errorMessage: 'Failed to get synced items count',
    );
  }

  /// Get the count of failed items
  Future<int> getFailedItemsCount() async {
    return await _dbErrorHandler.handleRead(
      () async {
        final db = await _dbService.database;
        final result = await db.rawQuery(
          'SELECT COUNT(*) as count FROM $tableName WHERE status = ?',
          ['failed'],
        );
        return Sqflite.firstIntValue(result) ?? 0;
      },
      tableName: tableName,
      errorMessage: 'Failed to get failed items count',
    );
  }

  /// Get all sync items
  Future<List<SyncItemModel>> getAllSyncItems() async {
    return await _dbErrorHandler.handleRead(
      () async {
        final db = await _dbService.database;
        final List<Map<String, dynamic>> maps = await db.query(
          tableName,
          orderBy: 'created_at DESC',
        );

        return List.generate(maps.length, (i) {
          return SyncItemModel.fromJson(maps[i]);
        });
      },
      tableName: tableName,
      errorMessage: 'Failed to get all sync items',
    );
  }

  /// Get sync items by status
  Future<List<SyncItemModel>> getSyncItemsByStatus(SyncStatus status) async {
    return await _dbErrorHandler.handleRead(
      () async {
        final db = await _dbService.database;
        final List<Map<String, dynamic>> maps = await db.query(
          tableName,
          where: 'status = ?',
          whereArgs: [SyncItemModel._statusToString(status)],
          orderBy: 'created_at DESC',
        );

        return List.generate(maps.length, (i) {
          return SyncItemModel.fromJson(maps[i]);
        });
      },
      tableName: tableName,
      errorMessage: 'Failed to get sync items by status',
    );
  }

  /// Get sync items by entity type
  Future<List<SyncItemModel>> getSyncItemsByEntityType(String entityType) async {
    return await _dbErrorHandler.handleRead(
      () async {
        final db = await _dbService.database;
        final List<Map<String, dynamic>> maps = await db.query(
          tableName,
          where: 'entity_type = ?',
          whereArgs: [entityType],
          orderBy: 'created_at DESC',
        );

        return List.generate(maps.length, (i) {
          return SyncItemModel.fromJson(maps[i]);
        });
      },
      tableName: tableName,
      errorMessage: 'Failed to get sync items by entity type',
    );
  }

  /// Get sync item by ID
  Future<SyncItemModel?> getSyncItemById(int id) async {
    return await _dbErrorHandler.handleRead(
      () async {
        final db = await _dbService.database;
        final List<Map<String, dynamic>> maps = await db.query(
          tableName,
          where: 'id = ?',
          whereArgs: [id],
          limit: 1,
        );

        if (maps.isEmpty) {
          return null;
        }

        return SyncItemModel.fromJson(maps.first);
      },
      tableName: tableName,
      errorMessage: 'Failed to get sync item by ID',
    );
  }

  /// Mark a sync item as syncing
  Future<int> markAsSyncing(int id) async {
    return await _dbErrorHandler.handleUpdate(
      () async {
        final db = await _dbService.database;
        return await db.update(
          tableName,
          {
            'status': 'syncing',
          },
          where: 'id = ?',
          whereArgs: [id],
        );
      },
      tableName: tableName,
      errorMessage: 'Failed to mark sync item as syncing',
    );
  }

  /// Mark a sync item as synced
  Future<int> markAsSynced(int id) async {
    return await _dbErrorHandler.handleUpdate(
      () async {
        final db = await _dbService.database;
        return await db.update(
          tableName,
          {
            'status': 'synced',
            'synced_at': DateTime.now().toIso8601String(),
          },
          where: 'id = ?',
          whereArgs: [id],
        );
      },
      tableName: tableName,
      errorMessage: 'Failed to mark sync item as synced',
    );
  }

  /// Mark a sync item as failed
  Future<int> markAsFailed(int id, {String? errorMessage}) async {
    return await _dbErrorHandler.handleUpdate(
      () async {
        final db = await _dbService.database;
        return await db.update(
          tableName,
          {
            'status': 'failed',
            'error_message': errorMessage,
          },
          where: 'id = ?',
          whereArgs: [id],
        );
      },
      tableName: tableName,
      errorMessage: 'Failed to mark sync item as failed',
    );
  }

  /// Increment the attempt count for a sync item
  Future<int> incrementAttemptCount(int id) async {
    return await _dbErrorHandler.handleUpdate(
      () async {
        final db = await _dbService.database;
        return await db.rawUpdate(
          'UPDATE $tableName SET attempts = attempts + 1 WHERE id = ?',
          [id],
        );
      },
      tableName: tableName,
      errorMessage: 'Failed to increment attempt count',
    );
  }

  /// Reset a failed sync item to pending
  Future<int> resetFailedItem(int id) async {
    return await _dbErrorHandler.handleUpdate(
      () async {
        final db = await _dbService.database;
        return await db.update(
          tableName,
          {
            'status': 'pending',
            'error_message': null,
          },
          where: 'id = ? AND status = ?',
          whereArgs: [id, 'failed'],
        );
      },
      tableName: tableName,
      errorMessage: 'Failed to reset failed sync item',
    );
  }

  /// Reset all failed sync items to pending
  Future<int> resetAllFailedItems() async {
    return await _dbErrorHandler.handleUpdate(
      () async {
        final db = await _dbService.database;
        return await db.update(
          tableName,
          {
            'status': 'pending',
            'error_message': null,
          },
          where: 'status = ?',
          whereArgs: ['failed'],
        );
      },
      tableName: tableName,
      errorMessage: 'Failed to reset all failed sync items',
    );
  }

  /// Delete a sync item
  Future<int> deleteSyncItem(int id) async {
    return await _dbErrorHandler.handleDelete(
      () async {
        final db = await _dbService.database;
        return await db.delete(
          tableName,
          where: 'id = ?',
          whereArgs: [id],
        );
      },
      tableName: tableName,
      errorMessage: 'Failed to delete sync item',
    );
  }

  /// Delete all synced items
  Future<int> deleteSyncedItems() async {
    return await _dbErrorHandler.handleDelete(
      () async {
        final db = await _dbService.database;
        return await db.delete(
          tableName,
          where: 'status = ?',
          whereArgs: ['synced'],
        );
      },
      tableName: tableName,
      errorMessage: 'Failed to delete synced items',
    );
  }

  /// Delete all failed items
  Future<int> deleteFailedItems() async {
    return await _dbErrorHandler.handleDelete(
      () async {
        final db = await _dbService.database;
        return await db.delete(
          tableName,
          where: 'status = ?',
          whereArgs: ['failed'],
        );
      },
      tableName: tableName,
      errorMessage: 'Failed to delete failed items',
    );
  }

  /// Clear all sync items
  Future<int> clearAllSyncItems() async {
    return await _dbErrorHandler.handleDelete(
      () async {
        final db = await _dbService.database;
        return await db.delete(tableName);
      },
      tableName: tableName,
      errorMessage: 'Failed to clear all sync items',
    );
  }

  /// Get entity type statistics
  Future<Map<String, int>> getEntityTypeStats() async {
    return await _dbErrorHandler.handleRead(
      () async {
        final db = await _dbService.database;
        final List<Map<String, dynamic>> result = await db.rawQuery('''
          SELECT entity_type, COUNT(*) as count
          FROM $tableName
          GROUP BY entity_type
        ''');

        final Map<String, int> stats = {};
        for (final row in result) {
          stats[row['entity_type'] as String] = row['count'] as int;
        }

        return stats;
      },
      tableName: tableName,
      errorMessage: 'Failed to get entity type statistics',
    );
  }

  /// Get the last sync attempt timestamp
  Future<DateTime?> getLastSyncAttempt() async {
    return await _dbErrorHandler.handleRead(
      () async {
        final db = await _dbService.database;
        final List<Map<String, dynamic>> result = await db.rawQuery('''
          SELECT MAX(synced_at) as last_sync
          FROM $tableName
          WHERE status IN ('synced', 'failed')
        ''');

        if (result.isEmpty || result.first['last_sync'] == null) {
          return null;
        }

        return DateTime.parse(result.first['last_sync'] as String);
      },
      tableName: tableName,
      errorMessage: 'Failed to get last sync attempt',
    );
  }

  /// Get the last successful sync timestamp
  Future<DateTime?> getLastSuccessfulSync() async {
    return await _dbErrorHandler.handleRead(
      () async {
        final db = await _dbService.database;
        final List<Map<String, dynamic>> result = await db.rawQuery('''
          SELECT MAX(synced_at) as last_sync
          FROM $tableName
          WHERE status = 'synced'
        ''');

        if (result.isEmpty || result.first['last_sync'] == null) {
          return null;
        }

        return DateTime.parse(result.first['last_sync'] as String);
      },
      tableName: tableName,
      errorMessage: 'Failed to get last successful sync',
    );
  }
}

