import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import '../services/db_service.dart';

class DbProvider extends GetxService {
  final DbService _dbService = Get.find<DbService>();
  
  // Get all records from a table
  Future<List<Map<String, dynamic>>> getAll(
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
  }
  
  // Get record by id
  Future<Map<String, dynamic>?> getById(String table, int id) async {
    final List<Map<String, dynamic>> maps = await _dbService.query(
      table,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }
  
  // Insert record
  Future<int> insert(String table, Map<String, dynamic> data) async {
    return await _dbService.insert(table, data);
  }
  
  // Update record
  Future<int> update(String table, Map<String, dynamic> data, int id) async {
    return await _dbService.update(
      table,
      data,
      'id = ?',
      [id],
    );
  }
  
  // Delete record
  Future<int> delete(String table, int id) async {
    return await _dbService.delete(
      table,
      'id = ?',
      [id],
    );
  }
  
  // Transaction
  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) async {
    return await _dbService.transaction(action);
  }
  
  // Raw query
  Future<List<Map<String, dynamic>>> rawQuery(String sql, [List<dynamic>? arguments]) async {
    return await _dbService.rawQuery(sql, arguments);
  }
  
  // Get active vehicles
  Future<List<Map<String, dynamic>>> getActiveVehicles() async {
    return await _dbService.query(
      'vehicle_master',
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'vehicle_number ASC',
    );
  }
  
  // Get gate entries by status
  Future<List<Map<String, dynamic>>> getGateEntriesByStatus(String status) async {
    return await _dbService.query(
      'gate_entry',
      where: 'status = ?',
      whereArgs: [status],
      orderBy: 'entry_time DESC',
    );
  }
  
  // Get gate entries by vehicle
  Future<List<Map<String, dynamic>>> getGateEntriesByVehicle(int vehicleId) async {
    return await _dbService.query(
      'gate_entry',
      where: 'vehicle_id = ?',
      whereArgs: [vehicleId],
      orderBy: 'entry_time DESC',
    );
  }
  
  // Get gate entry with vehicle
  Future<Map<String, dynamic>?> getGateEntryWithVehicle(int id) async {
    final List<Map<String, dynamic>> maps = await _dbService.rawQuery(
      '''
      SELECT ge.*, vm.* FROM gate_entry ge
      LEFT JOIN vehicle_master vm ON ge.vehicle_id = vm.id
      WHERE ge.id = ?
      ''',
      [id],
    );
    
    if (maps.isNotEmpty) {
      final Map<String, dynamic> result = {...maps.first};
      
      // Extract vehicle data
      final Map<String, dynamic> vehicle = {};
      for (var key in maps.first.keys) {
        if (key.startsWith('vehicle_')) {
          vehicle[key] = maps.first[key];
        }
      }
      
      if (vehicle.isNotEmpty) {
        result['vehicle'] = vehicle;
      }
      
      return result;
    }
    
    return null;
  }
  
  // Get weighbridge record by gate entry
  Future<Map<String, dynamic>?> getWeighbridgeRecordByGateEntry(int gateEntryId) async {
    final List<Map<String, dynamic>> maps = await _dbService.query(
      'weighbridge_record',
      where: 'gate_entry_id = ?',
      whereArgs: [gateEntryId],
      limit: 1,
    );
    
    if (maps.isNotEmpty) {
      return maps.first;
    }
    
    return null;
  }
  
  // Get invoices by status
  Future<List<Map<String, dynamic>>> getInvoicesByStatus(String status) async {
    return await _dbService.query(
      'invoice',
      where: 'status = ?',
      whereArgs: [status],
      orderBy: 'invoice_date DESC',
    );
  }
  
  // Get invoices by buyer
  Future<List<Map<String, dynamic>>> getInvoicesByBuyer(int buyerId) async {
    return await _dbService.query(
      'invoice',
      where: 'buyer_id = ?',
      whereArgs: [buyerId],
      orderBy: 'invoice_date DESC',
    );
  }
  
  // Get invoice with items
  Future<Map<String, dynamic>?> getInvoiceWithItems(int id) async {
    final Map<String, dynamic>? invoice = await getById('invoice', id);
    if (invoice != null) {
      final List<Map<String, dynamic>> items = await _dbService.query(
        'invoice_item',
        where: 'invoice_id = ?',
        whereArgs: [id],
      );
      
      invoice['items'] = items;
      return invoice;
    }
    
    return null;
  }
  
  // Get material types
  Future<List<Map<String, dynamic>>> getMaterialTypes() async {
    return await _dbService.query(
      'material_type_master',
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'name ASC',
    );
  }
  
  // Get stone sizes
  Future<List<Map<String, dynamic>>> getStoneSizes() async {
    return await _dbService.query(
      'stone_size_master',
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'size ASC',
    );
  }
  
  // Get weight units
  Future<List<Map<String, dynamic>>> getWeightUnits() async {
    return await _dbService.query(
      'weight_unit_type',
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'name ASC',
    );
  }
  
  // Get suppliers
  Future<List<Map<String, dynamic>>> getSuppliers() async {
    return await _dbService.query(
      'supplier_master',
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'name ASC',
    );
  }
  
  // Get buyers
  Future<List<Map<String, dynamic>>> getBuyers() async {
    return await _dbService.query(
      'buyer_master',
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'name ASC',
    );
  }
  
  // Get user by username
  Future<Map<String, dynamic>?> getUserByUsername(String username) async {
    final List<Map<String, dynamic>> maps = await _dbService.query(
      'user',
      where: 'username = ?',
      whereArgs: [username],
      limit: 1,
    );
    
    if (maps.isNotEmpty) {
      return maps.first;
    }
    
    return null;
  }
  
  // Get user roles
  Future<List<Map<String, dynamic>>> getUserRoles(int userId) async {
    return await _dbService.rawQuery(
      '''
      SELECT r.* FROM role r
      JOIN user_role ur ON r.id = ur.role_id
      WHERE ur.user_id = ?
      ''',
      [userId],
    );
  }
  
  // Get role permissions
  Future<List<Map<String, dynamic>>> getRolePermissions(int roleId) async {
    return await _dbService.rawQuery(
      '''
      SELECT p.* FROM permission p
      JOIN role_permission rp ON p.id = rp.permission_id
      WHERE rp.role_id = ?
      ''',
      [roleId],
    );
  }
  
  // Get user with roles and permissions
  Future<Map<String, dynamic>?> getUserWithRolesAndPermissions(int userId) async {
    final Map<String, dynamic>? user = await getById('user', userId);
    if (user != null) {
      final List<Map<String, dynamic>> roles = await getUserRoles(userId);
      
      final List<Map<String, dynamic>> rolesWithPermissions = [];
      for (var role in roles) {
        final List<Map<String, dynamic>> permissions = await getRolePermissions(role['id']);
        role['permissions'] = permissions;
        rolesWithPermissions.add(role);
      }
      
      user['roles'] = rolesWithPermissions;
      return user;
    }
    
    return null;
  }
  
  // Initialize database service
  Future<DbProvider> init() async {
    await _dbService.init();
    return this;
  }
}

