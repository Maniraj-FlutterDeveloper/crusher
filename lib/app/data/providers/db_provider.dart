import 'package:get/get.dart';
import '../services/db_service.dart';

class DbProvider {
  final DbService _dbService = Get.find<DbService>();
  
  // Generic CRUD operations
  
  // Create
  Future<int> insert(String table, Map<String, dynamic> data) async {
    return await _dbService.insert(table, data);
  }
  
  // Read
  Future<List<Map<String, dynamic>>> getAll(String table, {
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
  
  Future<Map<String, dynamic>?> getById(String table, int id) async {
    final List<Map<String, dynamic>> result = await _dbService.query(
      table,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    
    if (result.isNotEmpty) {
      return result.first;
    }
    
    return null;
  }
  
  // Update
  Future<int> update(String table, Map<String, dynamic> data, int id) async {
    return await _dbService.update(
      table,
      data,
      'id = ?',
      [id],
    );
  }
  
  // Delete
  Future<int> delete(String table, int id) async {
    return await _dbService.delete(
      table,
      'id = ?',
      [id],
    );
  }
  
  // Custom queries
  Future<List<Map<String, dynamic>>> rawQuery(String sql, [List<dynamic>? arguments]) async {
    return await _dbService.rawQuery(sql, arguments);
  }
  
  // Transaction
  Future<T> transaction<T>(Future<T> Function(dynamic txn) action) async {
    return await _dbService.transaction(action);
  }
  
  // Batch operations
  Future<void> batch(Function(dynamic batch) action) async {
    await _dbService.batch(action);
  }
  
  // Specific queries for related data
  
  // Get user with roles
  Future<Map<String, dynamic>?> getUserWithRoles(int userId) async {
    final user = await getById('user', userId);
    
    if (user != null) {
      final roles = await _dbService.rawQuery('''
        SELECT r.*
        FROM role r
        JOIN user_role ur ON r.id = ur.role_id
        WHERE ur.user_id = ?
      ''', [userId]);
      
      user['roles'] = roles;
    }
    
    return user;
  }
  
  // Get role with permissions
  Future<Map<String, dynamic>?> getRoleWithPermissions(int roleId) async {
    final role = await getById('role', roleId);
    
    if (role != null) {
      final permissions = await _dbService.rawQuery('''
        SELECT p.*
        FROM permission p
        JOIN role_permission rp ON p.id = rp.permission_id
        WHERE rp.role_id = ?
      ''', [roleId]);
      
      role['permissions'] = permissions;
    }
    
    return role;
  }
  
  // Get gate entry with vehicle
  Future<Map<String, dynamic>?> getGateEntryWithVehicle(int gateEntryId) async {
    final gateEntry = await getById('gate_entry', gateEntryId);
    
    if (gateEntry != null) {
      final vehicle = await getById('vehicle_master', gateEntry['vehicle_id']);
      gateEntry['vehicle'] = vehicle;
    }
    
    return gateEntry;
  }
  
  // Get invoice with items
  Future<Map<String, dynamic>?> getInvoiceWithItems(int invoiceId) async {
    final invoice = await getById('invoice', invoiceId);
    
    if (invoice != null) {
      final items = await _dbService.query(
        'invoice_item',
        where: 'invoice_id = ?',
        whereArgs: [invoiceId],
      );
      
      invoice['items'] = items;
    }
    
    return invoice;
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
  
  // Get active materials
  Future<List<Map<String, dynamic>>> getActiveMaterials() async {
    return await _dbService.query(
      'material_master',
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'name ASC',
    );
  }
  
  // Get active stone sizes
  Future<List<Map<String, dynamic>>> getActiveStoneSizes() async {
    return await _dbService.query(
      'stone_size_master',
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'size ASC',
    );
  }
  
  // Get active suppliers
  Future<List<Map<String, dynamic>>> getActiveSuppliers() async {
    return await _dbService.query(
      'supplier_master',
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'name ASC',
    );
  }
  
  // Get active buyers
  Future<List<Map<String, dynamic>>> getActiveBuyers() async {
    return await _dbService.query(
      'buyer_master',
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'name ASC',
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
  
  // Get material loading by gate entry
  Future<List<Map<String, dynamic>>> getMaterialLoadingByGateEntry(int gateEntryId) async {
    return await _dbService.query(
      'material_loading',
      where: 'gate_entry_id = ?',
      whereArgs: [gateEntryId],
      orderBy: 'created_at DESC',
    );
  }
  
  // Get weighbridge record by gate entry
  Future<Map<String, dynamic>?> getWeighbridgeRecordByGateEntry(int gateEntryId) async {
    final List<Map<String, dynamic>> result = await _dbService.query(
      'weighbridge_record',
      where: 'gate_entry_id = ?',
      whereArgs: [gateEntryId],
      limit: 1,
    );
    
    if (result.isNotEmpty) {
      return result.first;
    }
    
    return null;
  }
  
  // Get audit logs by module
  Future<List<Map<String, dynamic>>> getAuditLogsByModule(String module, {int? limit, int? offset}) async {
    return await _dbService.query(
      'audit_log',
      where: 'module = ?',
      whereArgs: [module],
      orderBy: 'created_at DESC',
      limit: limit,
      offset: offset,
    );
  }
  
  // Get audit logs by user
  Future<List<Map<String, dynamic>>> getAuditLogsByUser(int userId, {int? limit, int? offset}) async {
    return await _dbService.query(
      'audit_log',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
      limit: limit,
      offset: offset,
    );
  }
  
  // Insert audit log
  Future<int> insertAuditLog(Map<String, dynamic> data) async {
    return await _dbService.insert('audit_log', data);
  }
}

