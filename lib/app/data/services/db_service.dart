import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../core/values/app_constants.dart';

class DbService extends GetxService {
  static DbService get to => Get.find<DbService>();
  
  Database? _database;
  
  // Get database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  
  // Initialize database
  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, AppConstants.dbName);
    
    return await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }
  
  // Create database tables
  Future<void> _onCreate(Database db, int version) async {
    // Create material_type_master table
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
    
    // Create material_master table
    await db.execute('''
      CREATE TABLE material_master (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        material_type_id INTEGER NOT NULL,
        rate REAL,
        gst_percentage REAL,
        hsn_code TEXT,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (material_type_id) REFERENCES material_type_master (id)
      )
    ''');
    
    // Create stone_size_master table
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
    
    // Create weight_unit_type table
    await db.execute('''
      CREATE TABLE weight_unit_type (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        symbol TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
    
    // Create supplier_master table
    await db.execute('''
      CREATE TABLE supplier_master (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        contact_person TEXT,
        mobile TEXT,
        email TEXT,
        address TEXT,
        gstin TEXT,
        state_code TEXT,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
    
    // Create buyer_master table
    await db.execute('''
      CREATE TABLE buyer_master (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        contact_person TEXT,
        mobile TEXT,
        email TEXT,
        address TEXT,
        gstin TEXT,
        state_code TEXT,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
    
    // Create vehicle_master table
    await db.execute('''
      CREATE TABLE vehicle_master (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        vehicle_number TEXT NOT NULL,
        vehicle_type TEXT,
        capacity REAL,
        owner_name TEXT,
        owner_mobile TEXT,
        owner_address TEXT,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
    
    // Create tax_configuration table
    await db.execute('''
      CREATE TABLE tax_configuration (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        material_id INTEGER NOT NULL,
        cgst_percentage REAL NOT NULL DEFAULT 0,
        sgst_percentage REAL NOT NULL DEFAULT 0,
        igst_percentage REAL NOT NULL DEFAULT 0,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (material_id) REFERENCES material_master (id)
      )
    ''');
    
    // Create user table
    await db.execute('''
      CREATE TABLE user (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        name TEXT,
        email TEXT,
        mobile TEXT,
        last_login TEXT,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
    
    // Create role table
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
    
    // Create permission table
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
    
    // Create user_role table
    await db.execute('''
      CREATE TABLE user_role (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        role_id INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES user (id),
        FOREIGN KEY (role_id) REFERENCES role (id),
        UNIQUE (user_id, role_id)
      )
    ''');
    
    // Create role_permission table
    await db.execute('''
      CREATE TABLE role_permission (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        role_id INTEGER NOT NULL,
        permission_id INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (role_id) REFERENCES role (id),
        FOREIGN KEY (permission_id) REFERENCES permission (id),
        UNIQUE (role_id, permission_id)
      )
    ''');
    
    // Create gate_entry table
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
        FOREIGN KEY (vehicle_id) REFERENCES vehicle_master (id),
        FOREIGN KEY (supplier_id) REFERENCES supplier_master (id),
        FOREIGN KEY (buyer_id) REFERENCES buyer_master (id),
        FOREIGN KEY (operator_id) REFERENCES user (id)
      )
    ''');
    
    // Create weighbridge_record table
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
        FOREIGN KEY (gate_entry_id) REFERENCES gate_entry (id),
        FOREIGN KEY (weight_unit_id) REFERENCES weight_unit_type (id),
        FOREIGN KEY (operator_id) REFERENCES user (id)
      )
    ''');
    
    // Create material_loading table
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
        remarks TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (gate_entry_id) REFERENCES gate_entry (id),
        FOREIGN KEY (material_id) REFERENCES material_master (id),
        FOREIGN KEY (stone_size_id) REFERENCES stone_size_master (id),
        FOREIGN KEY (weight_unit_id) REFERENCES weight_unit_type (id),
        FOREIGN KEY (operator_id) REFERENCES user (id)
      )
    ''');
    
    // Create invoice table
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
        FOREIGN KEY (gate_entry_id) REFERENCES gate_entry (id),
        FOREIGN KEY (buyer_id) REFERENCES buyer_master (id),
        FOREIGN KEY (operator_id) REFERENCES user (id)
      )
    ''');
    
    // Create invoice_item table
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
        FOREIGN KEY (invoice_id) REFERENCES invoice (id),
        FOREIGN KEY (material_id) REFERENCES material_master (id),
        FOREIGN KEY (stone_size_id) REFERENCES stone_size_master (id),
        FOREIGN KEY (weight_unit_id) REFERENCES weight_unit_type (id)
      )
    ''');
    
    // Create audit_log table
    await db.execute('''
      CREATE TABLE audit_log (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        module TEXT NOT NULL,
        action TEXT NOT NULL,
        record_id INTEGER,
        old_value TEXT,
        new_value TEXT,
        ip_address TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES user (id)
      )
    ''');
    
    // Insert default data
    await _insertDefaultData(db);
  }
  
  // Insert default data
  Future<void> _insertDefaultData(Database db) async {
    final now = DateTime.now().toIso8601String();
    
    // Insert default material types
    await db.insert('material_type_master', {
      'name': AppConstants.materialTypeRaw,
      'description': 'Raw materials',
      'is_active': 1,
      'created_at': now,
      'updated_at': now,
    });
    
    await db.insert('material_type_master', {
      'name': AppConstants.materialTypeCrushed,
      'description': 'Crushed materials',
      'is_active': 1,
      'created_at': now,
      'updated_at': now,
    });
    
    await db.insert('material_type_master', {
      'name': AppConstants.materialTypeWaste,
      'description': 'Waste materials',
      'is_active': 1,
      'created_at': now,
      'updated_at': now,
    });
    
    // Insert default weight units
    await db.insert('weight_unit_type', {
      'name': AppConstants.weightUnitKg,
      'symbol': 'kg',
      'is_active': 1,
      'created_at': now,
      'updated_at': now,
    });
    
    await db.insert('weight_unit_type', {
      'name': AppConstants.weightUnitTon,
      'symbol': 'ton',
      'is_active': 1,
      'created_at': now,
      'updated_at': now,
    });
    
    // Insert default roles
    final adminRoleId = await db.insert('role', {
      'name': AppConstants.roleAdmin,
      'description': 'Administrator',
      'is_active': 1,
      'created_at': now,
      'updated_at': now,
    });
    
    await db.insert('role', {
      'name': AppConstants.roleSupervisor,
      'description': 'Supervisor',
      'is_active': 1,
      'created_at': now,
      'updated_at': now,
    });
    
    await db.insert('role', {
      'name': AppConstants.roleBilling,
      'description': 'Billing Operator',
      'is_active': 1,
      'created_at': now,
      'updated_at': now,
    });
    
    await db.insert('role', {
      'name': AppConstants.roleOperator,
      'description': 'General Operator',
      'is_active': 1,
      'created_at': now,
      'updated_at': now,
    });
    
    // Insert default admin user
    final adminUserId = await db.insert('user', {
      'username': 'admin',
      'password': 'admin123',
      'name': 'Administrator',
      'is_active': 1,
      'created_at': now,
      'updated_at': now,
    });
    
    // Assign admin role to admin user
    await db.insert('user_role', {
      'user_id': adminUserId,
      'role_id': adminRoleId,
      'created_at': now,
      'updated_at': now,
    });
  }
  
  // Upgrade database
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here
    if (oldVersion < 2) {
      // Add new tables or columns for version 2
    }
  }
  
  // Close database
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
  
  // Database operations
  
  // Insert
  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(table, data);
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
  
  // Update
  Future<int> update(
    String table,
    Map<String, dynamic> data,
    String where,
    List<dynamic> whereArgs,
  ) async {
    final db = await database;
    return await db.update(table, data, where: where, whereArgs: whereArgs);
  }
  
  // Delete
  Future<int> delete(
    String table,
    String where,
    List<dynamic> whereArgs,
  ) async {
    final db = await database;
    return await db.delete(table, where: where, whereArgs: whereArgs);
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
  
  // Batch
  Future<void> batch(Function(Batch batch) action) async {
    final db = await database;
    final batch = db.batch();
    action(batch);
    await batch.commit();
  }
}

