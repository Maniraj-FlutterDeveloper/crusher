import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import '../services/database_service.dart';

class DbProvider extends GetxService {
  late final DatabaseService _databaseService;
  
  // Initialize database provider
  Future<DbProvider> init() async {
    _databaseService = Get.find<DatabaseService>();
    return this;
  }
  
  // Get database instance
  Future<Database> get database async => await _databaseService.database;
  
  // Get all records from a table
  Future<List<Map<String, dynamic>>> getAll(String table) async {
    return await _databaseService.getAll(table);
  }
  
  // Get record by id
  Future<Map<String, dynamic>?> getById(String table, int id) async {
    return await _databaseService.getById(table, id.toString());
  }
  
  // Insert record
  Future<int> insert(String table, Map<String, dynamic> data) async {
    return await _databaseService.insert(table, data);
  }
  
  // Update record
  Future<int> update(String table, Map<String, dynamic> data, int id) async {
    return await _databaseService.update(
      table,
      data,
      'id = ?',
      [id],
    );
  }
  
  // Delete record
  Future<int> delete(String table, int id) async {
    return await _databaseService.delete(
      table,
      'id = ?',
      [id],
    );
  }
  
  // Query
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
    return await _databaseService.query(
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
  }
  
  // Raw query
  Future<List<Map<String, dynamic>>> rawQuery(String sql, [List<dynamic>? arguments]) async {
    return await _databaseService.rawQuery(sql, arguments);
  }
  
  // Raw insert
  Future<int> rawInsert(String sql, [List<dynamic>? arguments]) async {
    return await _databaseService.rawQuery(sql, arguments).then((result) {
      if (result.isNotEmpty && result.first.containsKey('last_insert_rowid()')) {
        return result.first['last_insert_rowid()'] as int;
      }
      return 0;
    });
  }
  
  // Raw update
  Future<int> rawUpdate(String sql, [List<dynamic>? arguments]) async {
    return await _databaseService.rawQuery(sql, arguments).then((result) {
      if (result.isNotEmpty && result.first.containsKey('changes()')) {
        return result.first['changes()'] as int;
      }
      return 0;
    });
  }
  
  // Raw delete
  Future<int> rawDelete(String sql, [List<dynamic>? arguments]) async {
    return await _databaseService.rawQuery(sql, arguments).then((result) {
      if (result.isNotEmpty && result.first.containsKey('changes()')) {
        return result.first['changes()'] as int;
      }
      return 0;
    });
  }
  
  // Transaction
  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) async {
    return await _databaseService.transaction(action);
  }
  
  // Get active vehicles
  Future<List<Map<String, dynamic>>> getActiveVehicles() async {
    return await query(
      'vehicle_master',
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'vehicle_number ASC',
    );
  }
  
  // Get gate entries by status
  Future<List<Map<String, dynamic>>> getGateEntriesByStatus(String status) async {
    return await query(
      'gate_entry',
      where: 'status = ?',
      whereArgs: [status],
      orderBy: 'entry_time DESC',
    );
  }
  
  // Get gate entries by vehicle
  Future<List<Map<String, dynamic>>> getGateEntriesByVehicle(int vehicleId) async {
    return await query(
      'gate_entry',
      where: 'vehicle_id = ?',
      whereArgs: [vehicleId],
      orderBy: 'entry_time DESC',
    );
  }
  
  // Get gate entry with vehicle
  Future<Map<String, dynamic>?> getGateEntryWithVehicle(int id) async {
    final List<Map<String, dynamic>> maps = await rawQuery('''
      SELECT ge.*, vm.* FROM gate_entry ge
      LEFT JOIN vehicle_master vm ON ge.vehicle_id = vm.id
      WHERE ge.id = ?
    ''', [id]);
    
    if (maps.isNotEmpty) {
      return maps.first;
    }
    
    return null;
  }
}

