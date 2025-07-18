import 'package:sqflite/sqflite.dart';
import '../models/role_model.dart';
import '../models/permission_model.dart';
import '../services/database_service.dart';
import 'permission_repository.dart';
import '../../core/values/app_constants.dart';
import 'package:get/get.dart';

class RoleRepository {
  final DatabaseService _databaseService = Get.find<DatabaseService>();
  final PermissionRepository _permissionRepository = Get.find<PermissionRepository>();
  
  // Table names
  static const String tableName = 'roles';
  static const String rolePermissionsTable = 'role_permissions';
  
  // Create tables
  static Future<void> createTables(Database db) async {
    // Create roles table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        description TEXT,
        is_system INTEGER NOT NULL DEFAULT 0,
        created_at TEXT,
        updated_at TEXT
      )
    ''');
    
    // Create role_permissions table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $rolePermissionsTable (
        role_id INTEGER NOT NULL,
        permission_id INTEGER NOT NULL,
        PRIMARY KEY (role_id, permission_id),
        FOREIGN KEY (role_id) REFERENCES $tableName (id) ON DELETE CASCADE,
        FOREIGN KEY (permission_id) REFERENCES ${PermissionRepository.tableName} (id) ON DELETE CASCADE
      )
    ''');
  }
  
  // Get all roles
  Future<List<RoleModel>> getAllRoles() async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      orderBy: 'name',
    );
    
    final roles = List.generate(maps.length, (i) {
      return RoleModel.fromJson(maps[i]);
    });
    
    // Load permissions for each role
    for (int i = 0; i < roles.length; i++) {
      final permissions = await getPermissionsForRole(roles[i].id!);
      roles[i] = roles[i].copyWith(permissions: permissions);
    }
    
    return roles;
  }
  
  // Get role by ID
  Future<RoleModel?> getRoleById(int id) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    
    if (maps.isNotEmpty) {
      final role = RoleModel.fromJson(maps.first);
      final permissions = await getPermissionsForRole(role.id!);
      return role.copyWith(permissions: permissions);
    }
    
    return null;
  }
  
  // Get role by name
  Future<RoleModel?> getRoleByName(String name) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'name = ?',
      whereArgs: [name],
      limit: 1,
    );
    
    if (maps.isNotEmpty) {
      final role = RoleModel.fromJson(maps.first);
      final permissions = await getPermissionsForRole(role.id!);
      return role.copyWith(permissions: permissions);
    }
    
    return null;
  }
  
  // Get permissions for a role
  Future<List<PermissionModel>> getPermissionsForRole(int roleId) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT p.* FROM ${PermissionRepository.tableName} p
      INNER JOIN $rolePermissionsTable rp ON p.id = rp.permission_id
      WHERE rp.role_id = ?
      ORDER BY p.module, p.name
    ''', [roleId]);
    
    return List.generate(maps.length, (i) {
      return PermissionModel.fromJson(maps[i]);
    });
  }
  
  // Insert a new role
  Future<int> insertRole(RoleModel role) async {
    final db = await _databaseService.database;
    final roleJson = role.toJson();
    
    // Remove permissions from JSON
    roleJson.remove('permissions');
    
    // Insert role
    final roleId = await db.insert(
      tableName,
      roleJson,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    
    // Insert role permissions
    if (role.permissions != null && role.permissions!.isNotEmpty) {
      await _updateRolePermissions(roleId, role.permissions!);
    }
    
    return roleId;
  }
  
  // Update an existing role
  Future<int> updateRole(RoleModel role) async {
    final db = await _databaseService.database;
    final roleJson = role.toJson();
    
    // Remove permissions from JSON
    roleJson.remove('permissions');
    
    // Update role
    final result = await db.update(
      tableName,
      roleJson,
      where: 'id = ?',
      whereArgs: [role.id],
    );
    
    // Update role permissions
    if (role.permissions != null) {
      await _updateRolePermissions(role.id!, role.permissions!);
    }
    
    return result;
  }
  
  // Delete a role
  Future<int> deleteRole(int id) async {
    final db = await _databaseService.database;
    
    // Delete role permissions
    await db.delete(
      rolePermissionsTable,
      where: 'role_id = ?',
      whereArgs: [id],
    );
    
    // Delete role
    return await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  // Update role permissions
  Future<void> _updateRolePermissions(int roleId, List<PermissionModel> permissions) async {
    final db = await _databaseService.database;
    
    // Delete existing role permissions
    await db.delete(
      rolePermissionsTable,
      where: 'role_id = ?',
      whereArgs: [roleId],
    );
    
    // Insert new role permissions
    final batch = db.batch();
    
    for (final permission in permissions) {
      if (permission.id != null) {
        batch.insert(
          rolePermissionsTable,
          {
            'role_id': roleId,
            'permission_id': permission.id,
          },
        );
      }
    }
    
    await batch.commit(noResult: true);
  }
  
  // Initialize default roles
  Future<void> initializeDefaultRoles() async {
    // Get all permissions
    final allPermissions = await _permissionRepository.getAllPermissions();
    
    // Create admin role with all permissions
    final adminRole = RoleModel(
      name: AppConstants.roleAdmin,
      description: 'Administrator with full access to all features',
      isSystem: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      permissions: allPermissions,
    );
    
    // Create supervisor role with limited permissions
    final supervisorPermissions = allPermissions.where((permission) {
      // Exclude user management and security permissions
      return !permission.code.startsWith('users.') &&
             !permission.code.startsWith('roles.') &&
             !permission.code.startsWith('security.');
    }).toList();
    
    final supervisorRole = RoleModel(
      name: AppConstants.roleSupervisor,
      description: 'Supervisor with access to operational features',
      isSystem: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      permissions: supervisorPermissions,
    );
    
    // Create operator role with basic permissions
    final operatorPermissions = allPermissions.where((permission) {
      // Include only view and create permissions for operational modules
      return (permission.code.startsWith('gate_entry.view') ||
              permission.code.startsWith('gate_entry.create') ||
              permission.code.startsWith('weighbridge.view') ||
              permission.code.startsWith('weighbridge.create') ||
              permission.code.startsWith('material_loading.view') ||
              permission.code.startsWith('material_loading.create') ||
              permission.code.startsWith('dashboard.view'));
    }).toList();
    
    final operatorRole = RoleModel(
      name: AppConstants.roleOperator,
      description: 'Operator with basic access to operational features',
      isSystem: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      permissions: operatorPermissions,
    );
    
    // Create billing role with billing permissions
    final billingPermissions = allPermissions.where((permission) {
      // Include billing and reports permissions
      return (permission.code.startsWith('billing.') ||
              permission.code.startsWith('reports.') ||
              permission.code.startsWith('dashboard.view'));
    }).toList();
    
    final billingRole = RoleModel(
      name: AppConstants.roleBilling,
      description: 'Billing staff with access to billing and reports',
      isSystem: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      permissions: billingPermissions,
    );
    
    // Insert or update roles
    final roles = [adminRole, supervisorRole, operatorRole, billingRole];
    
    for (final role in roles) {
      final existingRole = await getRoleByName(role.name);
      
      if (existingRole == null) {
        await insertRole(role);
      } else {
        await updateRole(role.copyWith(id: existingRole.id));
      }
    }
  }
}

