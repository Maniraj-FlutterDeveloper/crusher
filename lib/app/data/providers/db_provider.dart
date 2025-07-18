import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import '../services/db_service.dart';

class DbProvider extends GetxService {
  late final DbService _dbService;
  
  // Initialize database provider
  Future<DbProvider> init() async {
    _dbService = Get.find<DbService>();
    return this;
  }
  
  // Get database instance
  Future<Database> get database async => await _dbService.database;
  
  // Get all records from a table
  Future<List<Map<String, dynamic>>> getAll(String table) async {
    final db = await database;
    return await db.query(table);
  }
  
  // Get record by id
  Future<Map<String, dynamic>?> getById(String table, int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      table,
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isNotEmpty) {
      return maps.first;
    }
    
    return null;
  }
  
  // Insert record
  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(table, data);
  }
  
  // Update record
  Future<int> update(String table, Map<String, dynamic> data, int id) async {
    final db = await database;
    return await db.update(
      table,
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  // Delete record
  Future<int> delete(String table, int id) async {
    final db = await database;
    return await db.delete(
      table,
      where: 'id = ?',
      whereArgs: [id],
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
    final db = await database;
    return await db.query(
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
    final db = await database;
    return await db.rawQuery(sql, arguments);
  }
  
  // Raw insert
  Future<int> rawInsert(String sql, [List<dynamic>? arguments]) async {
    final db = await database;
    return await db.rawInsert(sql, arguments);
  }
  
  // Raw update
  Future<int> rawUpdate(String sql, [List<dynamic>? arguments]) async {
    final db = await database;
    return await db.rawUpdate(sql, arguments);
  }
  
  // Raw delete
  Future<int> rawDelete(String sql, [List<dynamic>? arguments]) async {
    final db = await database;
    return await db.rawDelete(sql, arguments);
  }
  
  // Transaction
  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) async {
    final db = await database;
    return await db.transaction(action);
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

