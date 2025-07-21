import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';

import '../../core/error/database_error_handler.dart';
import '../../core/services/logger_service.dart';
import 'db_service.dart';

/// DatabaseService is a wrapper around DbService that provides a more specific interface
/// for database operations with error handling and logging.
class DatabaseService extends GetxService {
  final DbService _dbService = Get.find<DbService>();
  final LoggerService _logger = Get.find<LoggerService>();
  final DatabaseErrorHandler _dbErrorHandler = Get.find<DatabaseErrorHandler>();

  /// Get the database instance
  Future<Database> get database async => await _dbService.database;

  /// Initialize the database service
  Future<DatabaseService> init() async {
    _logger.info('Initializing DatabaseService');
    // Ensure the database is initialized
    await _dbService.database;
    return this;
  }

  /// Query records from a table
  Future<List<Map<String, dynamic>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<dynamic>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    return await _dbErrorHandler.handleDatabaseOperation(
      () async {
        return await _dbService.query(
          table,
          distinct: distinct,
          columns: columns,
          where: where,
          whereArgs: whereArgs,
          groupBy: groupBy,
          having: having,
          orderBy: orderBy,
          limit: limit,
          offset: offset,
        );
      },
      operationType: 'query',
      tableName: table,
      errorMessage: 'Failed to query records from $table',
    );
  }

  /// Insert a record into a table
  Future<int> insert(String table, Map<String, dynamic> data) async {
    return await _dbErrorHandler.handleDatabaseOperation(
      () async {
        return await _dbService.insert(table, data);
      },
      operationType: 'insert',
      tableName: table,
      errorMessage: 'Failed to insert record into $table',
    );
  }

  /// Update records in a table
  Future<int> update(
    String table,
    Map<String, dynamic> data,
    String where,
    List<dynamic> whereArgs,
  ) async {
    return await _dbErrorHandler.handleDatabaseOperation(
      () async {
        return await _dbService.update(table, data, where, whereArgs);
      },
      operationType: 'update',
      tableName: table,
      errorMessage: 'Failed to update records in $table',
    );
  }

  /// Delete records from a table
  Future<int> delete(
    String table,
    String where,
    List<dynamic> whereArgs,
  ) async {
    return await _dbErrorHandler.handleDatabaseOperation(
      () async {
        return await _dbService.delete(table, where, whereArgs);
      },
      operationType: 'delete',
      tableName: table,
      errorMessage: 'Failed to delete records from $table',
    );
  }

  /// Execute a raw SQL query
  Future<List<Map<String, dynamic>>> rawQuery(String sql, [List<dynamic>? arguments]) async {
    return await _dbErrorHandler.handleDatabaseOperation(
      () async {
        return await _dbService.rawQuery(sql, arguments);
      },
      operationType: 'rawQuery',
      errorMessage: 'Failed to execute raw query',
    );
  }

  /// Execute a database transaction
  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) async {
    return await _dbErrorHandler.handleDatabaseOperation(
      () async {
        return await _dbService.transaction(action);
      },
      operationType: 'transaction',
      errorMessage: 'Failed to execute database transaction',
    );
  }

  /// Get a record by ID from a table
  Future<Map<String, dynamic>?> getById(String table, String id) async {
    return await _dbErrorHandler.handleDatabaseOperation(
      () async {
        final result = await _dbService.query(
          table,
          where: 'id = ?',
          whereArgs: [id],
          limit: 1,
        );
        return result.isNotEmpty ? result.first : null;
      },
      operationType: 'getById',
      tableName: table,
      errorMessage: 'Failed to get record by ID from $table',
    );
  }

  /// Get all records from a table
  Future<List<Map<String, dynamic>>> getAll(String table, {String? orderBy}) async {
    return await _dbErrorHandler.handleDatabaseOperation(
      () async {
        return await _dbService.query(table, orderBy: orderBy);
      },
      operationType: 'getAll',
      tableName: table,
      errorMessage: 'Failed to get all records from $table',
    );
  }

  /// Get records with pagination from a table
  Future<List<Map<String, dynamic>>> getPaginated(
    String table, {
    int page = 1,
    int limit = 20,
    String? orderBy,
  }) async {
    return await _dbErrorHandler.handleDatabaseOperation(
      () async {
        return await _dbService.query(
          table,
          limit: limit,
          offset: (page - 1) * limit,
          orderBy: orderBy,
        );
      },
      operationType: 'getPaginated',
      tableName: table,
      errorMessage: 'Failed to get paginated records from $table',
    );
  }

  /// Count all records in a table
  Future<int> count(String table) async {
    return await _dbErrorHandler.handleDatabaseOperation(
      () async {
        final result = await _dbService.rawQuery('SELECT COUNT(*) as count FROM $table');
        return result.first['count'] as int;
      },
      operationType: 'count',
      tableName: table,
      errorMessage: 'Failed to count records in $table',
    );
  }

  /// Check if a record exists in a table
  Future<bool> exists(String table, String id) async {
    return await _dbErrorHandler.handleDatabaseOperation(
      () async {
        final result = await _dbService.query(
          table,
          columns: ['id'],
          where: 'id = ?',
          whereArgs: [id],
          limit: 1,
        );
        return result.isNotEmpty;
      },
      operationType: 'exists',
      tableName: table,
      errorMessage: 'Failed to check if record exists in $table',
    );
  }

  /// Close the database
  Future<void> close() async {
    await _dbService.close();
  }
}