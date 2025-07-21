import 'package:sqflite/sqflite.dart';
import '../models/permission_model.dart';
import 'package:get/get.dart';
import '../services/database_service.dart';

class PermissionRepository {
  final DatabaseService _databaseService = Get.find<DatabaseService>();

  // Table name
  static const String tableName = 'permissions';

  // Create table
  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        code TEXT NOT NULL UNIQUE,
        description TEXT,
        module TEXT NOT NULL,
        created_at TEXT,
        updated_at TEXT
      )
    ''');
  }

  // Get all permissions
  Future<List<PermissionModel>> getAllPermissions() async {
    final List<Map<String, dynamic>> maps = await _databaseService.query(
      tableName,
      orderBy: 'module, name',
    );

    return List.generate(maps.length, (i) {
      return PermissionModel.fromJson(maps[i]);
    });
  }

  // Get permission by ID
  Future<PermissionModel?> getPermissionById(int id) async {
    final Map<String, dynamic>? data = await _databaseService.getById(tableName, id.toString());
    
    if (data != null) {
      return PermissionModel.fromJson(data);
    }

    return null;
  }

  // Get permission by code
  Future<PermissionModel?> getPermissionByCode(String code) async {
    final List<Map<String, dynamic>> maps = await _databaseService.query(
      tableName,
      where: 'code = ?',
      whereArgs: [code],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return PermissionModel.fromJson(maps.first);
    }

    return null;
  }

  // Get permissions by module
  Future<List<PermissionModel>> getPermissionsByModule(String module) async {
    final List<Map<String, dynamic>> maps = await _databaseService.query(
      tableName,
      where: 'module = ?',
      whereArgs: [module],
      orderBy: 'name',
    );

    return List.generate(maps.length, (i) {
      return PermissionModel.fromJson(maps[i]);
    });
  }

  // Insert a new permission
  Future<int> insertPermission(PermissionModel permission) async {
    return await _databaseService.insert(
      tableName,
      permission.toJson(),
    );
  }

  // Update an existing permission
  Future<int> updatePermission(PermissionModel permission) async {
    return await _databaseService.update(
      tableName,
      permission.toJson(),
      'id = ?',
      [permission.id],
    );
  }

  // Delete a permission
  Future<int> deletePermission(int id) async {
    return await _databaseService.delete(
      tableName,
      'id = ?',
      [id],
    );
  }

  // Initialize default permissions
  Future<void> initializeDefaultPermissions() async {
    final defaultPermissions = [
      // Dashboard permissions
      PermissionModel(
        name: 'View Dashboard',
        code: 'dashboard.view',
        description: 'View dashboard statistics and reports',
        module: 'Dashboard',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),

      // User management permissions
      PermissionModel(
        name: 'View Users',
        code: 'users.view',
        description: 'View user list and details',
        module: 'User Management',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      PermissionModel(
        name: 'Create Users',
        code: 'users.create',
        description: 'Create new users',
        module: 'User Management',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      PermissionModel(
        name: 'Edit Users',
        code: 'users.edit',
        description: 'Edit existing users',
        module: 'User Management',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      PermissionModel(
        name: 'Delete Users',
        code: 'users.delete',
        description: 'Delete users',
        module: 'User Management',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),

      // Role management permissions
      PermissionModel(
        name: 'View Roles',
        code: 'roles.view',
        description: 'View role list and details',
        module: 'User Management',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      PermissionModel(
        name: 'Create Roles',
        code: 'roles.create',
        description: 'Create new roles',
        module: 'User Management',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      PermissionModel(
        name: 'Edit Roles',
        code: 'roles.edit',
        description: 'Edit existing roles',
        module: 'User Management',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      PermissionModel(
        name: 'Delete Roles',
        code: 'roles.delete',
        description: 'Delete roles',
        module: 'User Management',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),

      // Master configuration permissions
      PermissionModel(
        name: 'View Master Data',
        code: 'master.view',
        description: 'View master configuration data',
        module: 'Master Configuration',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      PermissionModel(
        name: 'Edit Master Data',
        code: 'master.edit',
        description: 'Edit master configuration data',
        module: 'Master Configuration',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),

      // Gate entry permissions
      PermissionModel(
        name: 'View Gate Entries',
        code: 'gate_entry.view',
        description: 'View gate entries',
        module: 'Gate Entry',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      PermissionModel(
        name: 'Create Gate Entries',
        code: 'gate_entry.create',
        description: 'Create new gate entries',
        module: 'Gate Entry',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      PermissionModel(
        name: 'Edit Gate Entries',
        code: 'gate_entry.edit',
        description: 'Edit existing gate entries',
        module: 'Gate Entry',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      PermissionModel(
        name: 'Delete Gate Entries',
        code: 'gate_entry.delete',
        description: 'Delete gate entries',
        module: 'Gate Entry',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),

      // Weighbridge permissions
      PermissionModel(
        name: 'View Weighbridge',
        code: 'weighbridge.view',
        description: 'View weighbridge records',
        module: 'Weighbridge',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      PermissionModel(
        name: 'Create Weighbridge Records',
        code: 'weighbridge.create',
        description: 'Create new weighbridge records',
        module: 'Weighbridge',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      PermissionModel(
        name: 'Edit Weighbridge Records',
        code: 'weighbridge.edit',
        description: 'Edit existing weighbridge records',
        module: 'Weighbridge',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),

      // Material loading permissions
      PermissionModel(
        name: 'View Material Loading',
        code: 'material_loading.view',
        description: 'View material loading records',
        module: 'Material Loading',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      PermissionModel(
        name: 'Create Material Loading',
        code: 'material_loading.create',
        description: 'Create new material loading records',
        module: 'Material Loading',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      PermissionModel(
        name: 'Edit Material Loading',
        code: 'material_loading.edit',
        description: 'Edit existing material loading records',
        module: 'Material Loading',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),

      // Billing permissions
      PermissionModel(
        name: 'View Invoices',
        code: 'billing.view',
        description: 'View invoices',
        module: 'Billing',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      PermissionModel(
        name: 'Create Invoices',
        code: 'billing.create',
        description: 'Create new invoices',
        module: 'Billing',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      PermissionModel(
        name: 'Edit Invoices',
        code: 'billing.edit',
        description: 'Edit existing invoices',
        module: 'Billing',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      PermissionModel(
        name: 'Delete Invoices',
        code: 'billing.delete',
        description: 'Delete invoices',
        module: 'Billing',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      PermissionModel(
        name: 'Finalize Invoices',
        code: 'billing.finalize',
        description: 'Finalize invoices',
        module: 'Billing',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),

      // Reports permissions
      PermissionModel(
        name: 'View Reports',
        code: 'reports.view',
        description: 'View reports',
        module: 'Reports',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      PermissionModel(
        name: 'Export Reports',
        code: 'reports.export',
        description: 'Export reports to Excel or PDF',
        module: 'Reports',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),

      // Security permissions
      PermissionModel(
        name: 'View Audit Logs',
        code: 'security.audit_logs.view',
        description: 'View audit logs',
        module: 'Security',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      PermissionModel(
        name: 'Manage Security Settings',
        code: 'security.settings.manage',
        description: 'Manage security settings',
        module: 'Security',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    for (final permission in defaultPermissions) {
      final existingPermission = await getPermissionByCode(permission.code);

      if (existingPermission == null) {
        await insertPermission(permission);
      }
    }
  }
}