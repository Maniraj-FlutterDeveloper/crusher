import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';

import '../../core/values/app_constants.dart';

class DbService extends GetxService {
  static DbService get to => Get.find<DbService>();
  
  late Database _database;
  Database get database => _database;
  
  Future<DbService> init() async {
    try {
      // Initialize FFI for Windows
      if (Platform.isWindows || Platform.isLinux) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }
      
      // Get database path
      String path = await _getDatabasePath();
      
      // Open database
      _database = await openDatabase(
        path,
        version: AppConstants.dbVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
      
      print('Database initialized successfully');
      return this;
    } catch (e) {
      print('Error initializing database: $e');
      rethrow;
    }
  }
  
  Future<String> _getDatabasePath() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, AppConstants.dbName);
    
    // Make sure the directory exists
    try {
      await Directory(dirname(path)).create(recursive: true);
    } catch (_) {}
    
    return path;
  }
  
  Future<void> _onCreate(Database db, int version) async {
    // Create all tables
    await _createMaterialMasterTable(db);
    await _createStoneSizeMasterTable(db);
    await _createMaterialTypeMasterTable(db);
    await _createWeightUnitTypeTable(db);
    await _createSupplierMasterTable(db);
    await _createBuyerMasterTable(db);
    await _createVehicleMasterTable(db);
    await _createTaxConfigurationTable(db);
    await _createUserTable(db);
    await _createRoleTable(db);
    await _createPermissionTable(db);
    await _createUserRoleTable(db);
    await _createRolePermissionTable(db);
    await _createGateEntryTable(db);
    await _createWeighbridgeRecordTable(db);
    await _createMaterialLoadingTable(db);
    await _createInvoiceTable(db);
    await _createInvoiceItemTable(db);
    await _createAuditLogTable(db);
    
    // Insert default data
    await _insertDefaultData(db);
  }
  
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database migrations
    if (oldVersion < 2) {
      // Migration for version 2
    }
  }
  
  // Create table methods
  Future<void> _createMaterialMasterTable(Database db) async {
    await db.execute('''
      CREATE TABLE material_master (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        material_type_id INTEGER NOT NULL,
        hsn_code TEXT,
        rate REAL NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (material_type_id) REFERENCES material_type_master (id) ON DELETE RESTRICT
      )
    ''');
  }
  
  Future<void> _createStoneSizeMasterTable(Database db) async {
    await db.execute('''
      CREATE TABLE stone_size_master (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        size TEXT NOT NULL,
        description TEXT,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }
  
  Future<void> _createMaterialTypeMasterTable(Database db) async {
    await db.execute('''
      CREATE TABLE material_type_master (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }
  
  Future<void> _createWeightUnitTypeTable(Database db) async {
    await db.execute('''
      CREATE TABLE weight_unit_type (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        symbol TEXT NOT NULL,
        conversion_factor REAL NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }
  
  Future<void> _createSupplierMasterTable(Database db) async {
    await db.execute('''
      CREATE TABLE supplier_master (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        contact_person TEXT,
        mobile TEXT,
        email TEXT,
        address TEXT,
        city TEXT,
        state TEXT,
        pincode TEXT,
        gstin TEXT,
        pan TEXT,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }
  
  Future<void> _createBuyerMasterTable(Database db) async {
    await db.execute('''
      CREATE TABLE buyer_master (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        contact_person TEXT,
        mobile TEXT,
        email TEXT,
        address TEXT,
        city TEXT,
        state TEXT,
        pincode TEXT,
        gstin TEXT,
        pan TEXT,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }
  
  Future<void> _createVehicleMasterTable(Database db) async {
    await db.execute('''
      CREATE TABLE vehicle_master (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        vehicle_number TEXT NOT NULL,
        vehicle_type TEXT,
        capacity REAL,
        owner_name TEXT,
        owner_mobile TEXT,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }
  
  Future<void> _createTaxConfigurationTable(Database db) async {
    await db.execute('''
      CREATE TABLE tax_configuration (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        material_id INTEGER NOT NULL,
        gst_percentage REAL NOT NULL,
        cgst_percentage REAL NOT NULL,
        sgst_percentage REAL NOT NULL,
        igst_percentage REAL NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (material_id) REFERENCES material_master (id) ON DELETE RESTRICT
      )
    ''');
  }
  
  Future<void> _createUserTable(Database db) async {
    await db.execute('''
      CREATE TABLE user (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        name TEXT NOT NULL,
        email TEXT,
        mobile TEXT,
        is_active INTEGER NOT NULL DEFAULT 1,
        last_login TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }
  
  Future<void> _createRoleTable(Database db) async {
    await db.execute('''
      CREATE TABLE role (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        description TEXT,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }
  
  Future<void> _createPermissionTable(Database db) async {
    await db.execute('''
      CREATE TABLE permission (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        description TEXT,
        module TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }
  
  Future<void> _createUserRoleTable(Database db) async {
    await db.execute('''
      CREATE TABLE user_role (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        role_id INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES user (id) ON DELETE CASCADE,
        FOREIGN KEY (role_id) REFERENCES role (id) ON DELETE CASCADE
      )
    ''');
  }
  
  Future<void> _createRolePermissionTable(Database db) async {
    await db.execute('''
      CREATE TABLE role_permission (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        role_id INTEGER NOT NULL,
        permission_id INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (role_id) REFERENCES role (id) ON DELETE CASCADE,
        FOREIGN KEY (permission_id) REFERENCES permission (id) ON DELETE CASCADE
      )
    ''');
  }
  
  Future<void> _createGateEntryTable(Database db) async {
    await db.execute('''
      CREATE TABLE gate_entry (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id TEXT NOT NULL UNIQUE,
        vehicle_id INTEGER NOT NULL,
        driver_name TEXT,
        driver_mobile TEXT,
        entry_time TEXT NOT NULL,
        exit_time TEXT,
        tare_weight REAL,
        gross_weight REAL,
        net_weight REAL,
        supplier_id INTEGER,
        buyer_id INTEGER,
        remarks TEXT,
        status TEXT NOT NULL,
        gate_pass_number TEXT,
        operator_id INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (vehicle_id) REFERENCES vehicle_master (id) ON DELETE RESTRICT,
        FOREIGN KEY (supplier_id) REFERENCES supplier_master (id) ON DELETE RESTRICT,
        FOREIGN KEY (buyer_id) REFERENCES buyer_master (id) ON DELETE RESTRICT,
        FOREIGN KEY (operator_id) REFERENCES user (id) ON DELETE RESTRICT
      )
    ''');
  }
  
  Future<void> _createWeighbridgeRecordTable(Database db) async {
    await db.execute('''
      CREATE TABLE weighbridge_record (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        gate_entry_id INTEGER NOT NULL,
        tare_weight REAL,
        gross_weight REAL,
        net_weight REAL,
        weight_unit_id INTEGER NOT NULL,
        tare_weight_time TEXT,
        gross_weight_time TEXT,
        operator_id INTEGER NOT NULL,
        remarks TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (gate_entry_id) REFERENCES gate_entry (id) ON DELETE RESTRICT,
        FOREIGN KEY (weight_unit_id) REFERENCES weight_unit_type (id) ON DELETE RESTRICT,
        FOREIGN KEY (operator_id) REFERENCES user (id) ON DELETE RESTRICT
      )
    ''');
  }
  
  Future<void> _createMaterialLoadingTable(Database db) async {
    await db.execute('''
      CREATE TABLE material_loading (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        gate_entry_id INTEGER NOT NULL,
        material_id INTEGER NOT NULL,
        stone_size_id INTEGER,
        quantity REAL NOT NULL,
        weight_unit_id INTEGER NOT NULL,
        purpose TEXT NOT NULL,
        operator_id INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (gate_entry_id) REFERENCES gate_entry (id) ON DELETE RESTRICT,
        FOREIGN KEY (material_id) REFERENCES material_master (id) ON DELETE RESTRICT,
        FOREIGN KEY (stone_size_id) REFERENCES stone_size_master (id) ON DELETE RESTRICT,
        FOREIGN KEY (weight_unit_id) REFERENCES weight_unit_type (id) ON DELETE RESTRICT,
        FOREIGN KEY (operator_id) REFERENCES user (id) ON DELETE RESTRICT
      )
    ''');
  }
  
  Future<void> _createInvoiceTable(Database db) async {
    await db.execute('''
      CREATE TABLE invoice (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        invoice_number TEXT NOT NULL UNIQUE,
        gate_entry_id INTEGER NOT NULL,
        buyer_id INTEGER NOT NULL,
        invoice_date TEXT NOT NULL,
        base_amount REAL NOT NULL,
        cgst_amount REAL NOT NULL,
        sgst_amount REAL NOT NULL,
        igst_amount REAL NOT NULL,
        total_amount REAL NOT NULL,
        status TEXT NOT NULL,
        remarks TEXT,
        operator_id INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (gate_entry_id) REFERENCES gate_entry (id) ON DELETE RESTRICT,
        FOREIGN KEY (buyer_id) REFERENCES buyer_master (id) ON DELETE RESTRICT,
        FOREIGN KEY (operator_id) REFERENCES user (id) ON DELETE RESTRICT
      )
    ''');
  }
  
  Future<void> _createInvoiceItemTable(Database db) async {
    await db.execute('''
      CREATE TABLE invoice_item (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        invoice_id INTEGER NOT NULL,
        material_id INTEGER NOT NULL,
        stone_size_id INTEGER,
        quantity REAL NOT NULL,
        weight_unit_id INTEGER NOT NULL,
        rate REAL NOT NULL,
        amount REAL NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (invoice_id) REFERENCES invoice (id) ON DELETE CASCADE,
        FOREIGN KEY (material_id) REFERENCES material_master (id) ON DELETE RESTRICT,
        FOREIGN KEY (stone_size_id) REFERENCES stone_size_master (id) ON DELETE RESTRICT,
        FOREIGN KEY (weight_unit_id) REFERENCES weight_unit_type (id) ON DELETE RESTRICT
      )
    ''');
  }
  
  Future<void> _createAuditLogTable(Database db) async {
    await db.execute('''
      CREATE TABLE audit_log (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        action TEXT NOT NULL,
        module TEXT NOT NULL,
        record_id INTEGER,
        details TEXT,
        ip_address TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES user (id) ON DELETE SET NULL
      )
    ''');
  }
  
  // Insert default data
  Future<void> _insertDefaultData(Database db) async {
    // Insert default material types
    await db.insert('material_type_master', {
      'name': AppConstants.materialTypeRaw,
      'description': 'Raw materials',
      'is_active': 1,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });
    
    await db.insert('material_type_master', {
      'name': AppConstants.materialTypeCrushed,
      'description': 'Crushed materials',
      'is_active': 1,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });
    
    await db.insert('material_type_master', {
      'name': AppConstants.materialTypeWaste,
      'description': 'Waste materials',
      'is_active': 1,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });
    
    // Insert default weight units
    await db.insert('weight_unit_type', {
      'name': 'Kilogram',
      'symbol': AppConstants.weightUnitKg,
      'conversion_factor': 1.0,
      'is_active': 1,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });
    
    await db.insert('weight_unit_type', {
      'name': 'Ton',
      'symbol': AppConstants.weightUnitTon,
      'conversion_factor': 1000.0,
      'is_active': 1,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });
    
    // Insert default roles
    await db.insert('role', {
      'name': AppConstants.roleAdmin,
      'description': 'Administrator with full access',
      'is_active': 1,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });
    
    await db.insert('role', {
      'name': AppConstants.roleSupervisor,
      'description': 'Supervisor with limited access',
      'is_active': 1,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });
    
    await db.insert('role', {
      'name': AppConstants.roleBilling,
      'description': 'Billing operator with access to billing module',
      'is_active': 1,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });
    
    await db.insert('role', {
      'name': AppConstants.roleOperator,
      'description': 'Operator with access to gate entry and weighbridge modules',
      'is_active': 1,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });
    
    // Insert default admin user
    await db.insert('user', {
      'username': 'admin',
      'password': 'admin123', // In production, this should be hashed
      'name': 'Administrator',
      'email': 'admin@example.com',
      'mobile': '9876543210',
      'is_active': 1,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });
    
    // Assign admin role to admin user
    int adminUserId = 1; // Assuming the first user is admin
    int adminRoleId = 1; // Assuming the first role is admin
    
    await db.insert('user_role', {
      'user_id': adminUserId,
      'role_id': adminRoleId,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }
  
  // Helper methods for database operations
  Future<int> insert(String table, Map<String, dynamic> data) async {
    return await _database.insert(table, data);
  }
  
  Future<int> update(String table, Map<String, dynamic> data, String where, List<dynamic> whereArgs) async {
    return await _database.update(table, data, where: where, whereArgs: whereArgs);
  }
  
  Future<int> delete(String table, String where, List<dynamic> whereArgs) async {
    return await _database.delete(table, where: where, whereArgs: whereArgs);
  }
  
  Future<List<Map<String, dynamic>>> query(String table, {
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
    return await _database.query(
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
  
  Future<List<Map<String, dynamic>>> rawQuery(String sql, [List<dynamic>? arguments]) async {
    return await _database.rawQuery(sql, arguments);
  }
  
  Future<int> rawInsert(String sql, [List<dynamic>? arguments]) async {
    return await _database.rawInsert(sql, arguments);
  }
  
  Future<int> rawUpdate(String sql, [List<dynamic>? arguments]) async {
    return await _database.rawUpdate(sql, arguments);
  }
  
  Future<int> rawDelete(String sql, [List<dynamic>? arguments]) async {
    return await _database.rawDelete(sql, arguments);
  }
  
  Future<void> batch(Function(Batch batch) action) async {
    final batch = _database.batch();
    action(batch);
    await batch.commit();
  }
  
  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) async {
    return await _database.transaction(action);
  }
}

