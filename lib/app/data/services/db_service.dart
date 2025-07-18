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
    _database = await init();
    return _database!;
  }
  
  // Initialize database
  Future<Database> init() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, AppConstants.databaseName);
    
    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }
  
  // Create database tables
  Future<void> _onCreate(Database db, int version) async {
    // Create user table
    await db.execute('''
      CREATE TABLE user (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        name TEXT,
        email TEXT,
        mobile TEXT,
        is_active INTEGER NOT NULL DEFAULT 1,
        last_login TEXT,
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
        FOREIGN KEY (user_id) REFERENCES user (id) ON DELETE CASCADE,
        FOREIGN KEY (role_id) REFERENCES role (id) ON DELETE CASCADE,
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
        FOREIGN KEY (role_id) REFERENCES role (id) ON DELETE CASCADE,
        FOREIGN KEY (permission_id) REFERENCES permission (id) ON DELETE CASCADE,
        UNIQUE (role_id, permission_id)
      )
    ''');
    
    // Create vehicle_master table
    await db.execute('''
      CREATE TABLE vehicle_master (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        vehicle_number TEXT NOT NULL UNIQUE,
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
    
    // Create material_type_master table
    await db.execute('''
      CREATE TABLE material_type_master (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        description TEXT,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
    
    // Create stone_size_master table
    await db.execute('''
      CREATE TABLE stone_size_master (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        size TEXT NOT NULL UNIQUE,
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
        name TEXT NOT NULL UNIQUE,
        symbol TEXT NOT NULL,
        conversion_factor REAL NOT NULL,
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
        gstin TEXT,
        address TEXT,
        city TEXT,
        state TEXT,
        pincode TEXT,
        contact_person TEXT,
        contact_mobile TEXT,
        email TEXT,
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
        gstin TEXT,
        address TEXT,
        city TEXT,
        state TEXT,
        pincode TEXT,
        contact_person TEXT,
        contact_mobile TEXT,
        email TEXT,
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
        hsn_code TEXT,
        cgst_percentage REAL NOT NULL DEFAULT 0,
        sgst_percentage REAL NOT NULL DEFAULT 0,
        igst_percentage REAL NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (material_id) REFERENCES material_master (id) ON DELETE CASCADE
      )
    ''');
    
    // Create material_master table
    await db.execute('''
      CREATE TABLE material_master (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        material_type_id INTEGER NOT NULL,
        stone_size_id INTEGER,
        description TEXT,
        rate REAL,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (material_type_id) REFERENCES material_type_master (id) ON DELETE RESTRICT,
        FOREIGN KEY (stone_size_id) REFERENCES stone_size_master (id) ON DELETE RESTRICT
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
        status TEXT NOT NULL,
        gate_pass_number TEXT NOT NULL UNIQUE,
        remarks TEXT,
        operator_id INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (vehicle_id) REFERENCES vehicle_master (id) ON DELETE RESTRICT,
        FOREIGN KEY (operator_id) REFERENCES user (id) ON DELETE RESTRICT
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
        FOREIGN KEY (gate_entry_id) REFERENCES gate_entry (id) ON DELETE CASCADE,
        FOREIGN KEY (weight_unit_id) REFERENCES weight_unit_type (id) ON DELETE RESTRICT,
        FOREIGN KEY (operator_id) REFERENCES user (id) ON DELETE RESTRICT
      )
    ''');
    
    // Create material_loading table
    await db.execute('''
      CREATE TABLE material_loading (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        gate_entry_id INTEGER NOT NULL,
        material_id INTEGER NOT NULL,
        quantity REAL NOT NULL,
        weight_unit_id INTEGER NOT NULL,
        purpose TEXT NOT NULL,
        operator_id INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (gate_entry_id) REFERENCES gate_entry (id) ON DELETE CASCADE,
        FOREIGN KEY (material_id) REFERENCES material_master (id) ON DELETE RESTRICT,
        FOREIGN KEY (weight_unit_id) REFERENCES weight_unit_type (id) ON DELETE RESTRICT,
        FOREIGN KEY (operator_id) REFERENCES user (id) ON DELETE RESTRICT
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
        FOREIGN KEY (gate_entry_id) REFERENCES gate_entry (id) ON DELETE RESTRICT,
        FOREIGN KEY (buyer_id) REFERENCES buyer_master (id) ON DELETE RESTRICT,
        FOREIGN KEY (operator_id) REFERENCES user (id) ON DELETE RESTRICT
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
        FOREIGN KEY (invoice_id) REFERENCES invoice (id) ON DELETE CASCADE,
        FOREIGN KEY (material_id) REFERENCES material_master (id) ON DELETE RESTRICT,
        FOREIGN KEY (stone_size_id) REFERENCES stone_size_master (id) ON DELETE RESTRICT,
        FOREIGN KEY (weight_unit_id) REFERENCES weight_unit_type (id) ON DELETE RESTRICT
      )
    ''');
    
    // Create user_activity_log table
    await db.execute('''
      CREATE TABLE user_activity_log (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        action TEXT NOT NULL,
        module TEXT NOT NULL,
        details TEXT,
        ip_address TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES user (id) ON DELETE CASCADE
      )
    ''');
    
    // Insert default data
    await _insertDefaultData(db);
  }
  
  // Upgrade database
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here
    if (oldVersion < 2) {
      // Upgrade from version 1 to 2
    }
  }
  
  // Insert default data
  Future<void> _insertDefaultData(Database db) async {
    final now = DateTime.now().toIso8601String();
    
    // Insert default roles
    await db.insert('role', {
      'name': 'ADMIN',
      'description': 'Administrator with full access',
      'is_active': 1,
      'created_at': now,
      'updated_at': now,
    });
    
    await db.insert('role', {
      'name': 'SUPERVISOR',
      'description': 'Supervisor with limited access',
      'is_active': 1,
      'created_at': now,
      'updated_at': now,
    });
    
    await db.insert('role', {
      'name': 'BILLING',
      'description': 'Billing operator with access to billing module',
      'is_active': 1,
      'created_at': now,
      'updated_at': now,
    });
    
    await db.insert('role', {
      'name': 'OPERATOR',
      'description': 'Operator with access to gate entry and weighbridge modules',
      'is_active': 1,
      'created_at': now,
      'updated_at': now,
    });
    
    // Insert default admin user
    final userId = await db.insert('user', {
      'username': 'admin',
      'password': 'admin123',
      'name': 'Administrator',
      'is_active': 1,
      'created_at': now,
      'updated_at': now,
    });
    
    // Assign admin role to admin user
    await db.insert('user_role', {
      'user_id': userId,
      'role_id': 1, // Admin role
      'created_at': now,
      'updated_at': now,
    });
    
    // Insert default material types
    await db.insert('material_type_master', {
      'name': 'RAW',
      'description': 'Raw material',
      'is_active': 1,
      'created_at': now,
      'updated_at': now,
    });
    
    await db.insert('material_type_master', {
      'name': 'CRUSHED',
      'description': 'Crushed material',
      'is_active': 1,
      'created_at': now,
      'updated_at': now,
    });
    
    await db.insert('material_type_master', {
      'name': 'WASTE',
      'description': 'Waste material',
      'is_active': 1,
      'created_at': now,
      'updated_at': now,
    });
    
    // Insert default stone sizes
    await db.insert('stone_size_master', {
      'size': '6mm',
      'description': '6mm stone size',
      'is_active': 1,
      'created_at': now,
      'updated_at': now,
    });
    
    await db.insert('stone_size_master', {
      'size': '12mm',
      'description': '12mm stone size',
      'is_active': 1,
      'created_at': now,
      'updated_at': now,
    });
    
    await db.insert('stone_size_master', {
      'size': '20mm',
      'description': '20mm stone size',
      'is_active': 1,
      'created_at': now,
      'updated_at': now,
    });
    
    await db.insert('stone_size_master', {
      'size': '40mm',
      'description': '40mm stone size',
      'is_active': 1,
      'created_at': now,
      'updated_at': now,
    });
    
    // Insert default weight units
    await db.insert('weight_unit_type', {
      'name': 'Kilogram',
      'symbol': 'kg',
      'conversion_factor': 1.0,
      'is_active': 1,
      'created_at': now,
      'updated_at': now,
    });
    
    await db.insert('weight_unit_type', {
      'name': 'Ton',
      'symbol': 'ton',
      'conversion_factor': 1000.0,
      'is_active': 1,
      'created_at': now,
      'updated_at': now,
    });
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
  
  // Insert
  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(table, data);
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
  
  // Transaction
  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) async {
    final db = await database;
    return await db.transaction(action);
  }
  
  // Close database
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}

