import 'package:get/get.dart';

import '../error/database_error_handler.dart';
import '../services/logger_service.dart';
import '../services/sync_service.dart';
import '../../data/services/database_service.dart';

abstract class BaseRepository {
  final DatabaseService _databaseService = Get.find<DatabaseService>();
  final LoggerService _logger = Get.find<LoggerService>();
  final DatabaseErrorHandler _dbErrorHandler = Get.find<DatabaseErrorHandler>();
  final SyncService _syncService = Get.find<SyncService>();

  // Abstract properties to be implemented by subclasses
  String get tableName;
  String get entityType;

  // Getters for services
  DatabaseService get databaseService => _databaseService;
  LoggerService get logger => _logger;
  DatabaseErrorHandler get dbErrorHandler => _dbErrorHandler;
  SyncService get syncService => _syncService;

  /// Create a record with offline sync support
  Future<int> createWithSync(
    Map<String, dynamic> data, {
    bool syncEnabled = true,
    int syncPriority = 1,
  }) async {
    final id = await dbErrorHandler.handleWrite(
      () async {
        return await databaseService.insert(
          tableName,
          data,
        );
      },
      tableName: tableName,
      errorMessage: 'Failed to create $entityType',
    );

    // Add to sync queue if sync is enabled
    if (syncEnabled) {
      await syncService.addToSyncQueue(
        entityType: entityType,
        action: 'create',
        data: data,
        entityId: id.toString(),
        priority: syncPriority,
      );
    }

    return id;
  }

  /// Update a record with offline sync support
  Future<int> updateWithSync(
    String id,
    Map<String, dynamic> data, {
    bool syncEnabled = true,
    int syncPriority = 1,
  }) async {
    final result = await dbErrorHandler.handleUpdate(
      () async {
        return await databaseService.update(
          tableName,
          data,
          'id = ?',
          [id],
        );
      },
      tableName: tableName,
      errorMessage: 'Failed to update $entityType',
    );

    // Add to sync queue if sync is enabled
    if (syncEnabled) {
      await syncService.addToSyncQueue(
        entityType: entityType,
        action: 'update',
        data: data,
        entityId: id,
        priority: syncPriority,
      );
    }

    return result;
  }

  /// Delete a record with offline sync support
  Future<int> deleteWithSync(
    String id, {
    bool syncEnabled = true,
    int syncPriority = 1,
  }) async {
    // Get the data before deleting (for sync purposes)
    final data = await dbErrorHandler.handleRead(
      () async {
        return await databaseService.getById(tableName, id);
      },
      tableName: tableName,
      errorMessage: 'Failed to get $entityType data for deletion',
    );

    final result = await dbErrorHandler.handleDelete(
      () async {
        return await databaseService.delete(
          tableName,
          'id = ?',
          [id],
        );
      },
      tableName: tableName,
      errorMessage: 'Failed to delete $entityType',
    );

    // Add to sync queue if sync is enabled
    if (syncEnabled && data != null) {
      await syncService.addToSyncQueue(
        entityType: entityType,
        action: 'delete',
        data: data,
        entityId: id,
        priority: syncPriority,
      );
    }

    return result;
  }

  /// Get a record by ID
  Future<Map<String, dynamic>?> getById(String id) async {
    return await dbErrorHandler.handleRead(
      () async {
        return await databaseService.getById(tableName, id);
      },
      tableName: tableName,
      errorMessage: 'Failed to get $entityType by ID',
    );
  }

  /// Get all records
  Future<List<Map<String, dynamic>>> getAll() async {
    return await dbErrorHandler.handleRead(
      () async {
        return await databaseService.getAll(tableName);
      },
      tableName: tableName,
      errorMessage: 'Failed to get all $entityType records',
    );
  }

  /// Get records with pagination
  Future<List<Map<String, dynamic>>> getPaginated({
    int page = 1,
    int limit = 20,
    String? orderBy,
  }) async {
    return await dbErrorHandler.handleRead(
      () async {
        return await databaseService.getPaginated(
          tableName,
          page: page,
          limit: limit,
          orderBy: orderBy,
        );
      },
      tableName: tableName,
      errorMessage: 'Failed to get paginated $entityType records',
    );
  }

  /// Count all records
  Future<int> count() async {
    return await dbErrorHandler.handleRead(
      () async {
        return await databaseService.count(tableName);
      },
      tableName: tableName,
      errorMessage: 'Failed to count $entityType records',
    );
  }

  /// Check if a record exists
  Future<bool> exists(String id) async {
    return await dbErrorHandler.handleRead(
      () async {
        return await databaseService.exists(tableName, id);
      },
      tableName: tableName,
      errorMessage: 'Failed to check if $entityType exists',
    );
  }

  /// Execute a custom query
  Future<List<Map<String, dynamic>>> query({
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    return await dbErrorHandler.handleRead(
      () async {
        return await databaseService.query(
          tableName,
          where: where,
          whereArgs: whereArgs,
          orderBy: orderBy,
          limit: limit,
          offset: offset,
        );
      },
      tableName: tableName,
      errorMessage: 'Failed to query $entityType records',
    );
  }

  /// Execute a raw SQL query
  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<dynamic>? arguments,
  ]) async {
    return await dbErrorHandler.handleRead(
      () async {
        return await databaseService.rawQuery(sql, arguments);
      },
      tableName: tableName,
      errorMessage: 'Failed to execute raw query on $entityType',
    );
  }
}

