import 'package:get/get.dart';
import '../models/user_model.dart';
import '../providers/db_provider.dart';

class UserRepository {
  final DbProvider _dbProvider = Get.find<DbProvider>();
  
  // Get all users
  Future<List<UserModel>> getAllUsers() async {
    final List<Map<String, dynamic>> maps = await _dbProvider.getAll('user');
    return maps.map((map) => UserModel.fromMap(map)).toList();
  }
  
  // Get active users
  Future<List<UserModel>> getActiveUsers() async {
    final List<Map<String, dynamic>> maps = await _dbProvider.query(
      'user',
      where: 'is_active = ?',
      whereArgs: [1],
    );
    return maps.map((map) => UserModel.fromMap(map)).toList();
  }
  
  // Get user by id
  Future<UserModel?> getUserById(int id) async {
    final Map<String, dynamic>? map = await _dbProvider.getById('user', id);
    if (map != null) {
      return UserModel.fromMap(map);
    }
    return null;
  }
  
  // Get user by username
  Future<UserModel?> getUserByUsername(String username) async {
    final List<Map<String, dynamic>> maps = await _dbProvider.query(
      'user',
      where: 'username = ?',
      whereArgs: [username],
    );
    
    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    }
    
    return null;
  }
  
  // Get user by credentials
  Future<UserModel?> getUserByCredentials(String username, String password) async {
    final List<Map<String, dynamic>> maps = await _dbProvider.query(
      'user',
      where: 'username = ? AND password = ? AND is_active = ?',
      whereArgs: [username, password, 1],
    );
    
    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    }
    
    return null;
  }
  
  // Get user with roles and permissions
  Future<UserModel?> getUserWithRolesAndPermissions(int userId) async {
    final UserModel? user = await getUserById(userId);
    
    if (user == null) {
      return null;
    }
    
    // Get user roles
    final List<Map<String, dynamic>> roleMaps = await _dbProvider.rawQuery('''
      SELECT r.* FROM role r
      INNER JOIN user_role ur ON r.id = ur.role_id
      WHERE ur.user_id = ?
    ''', [userId]);
    
    final List<RoleModel> roles = roleMaps.map((map) => RoleModel.fromMap(map)).toList();
    
    // Get permissions for each role
    for (int i = 0; i < roles.length; i++) {
      final List<Map<String, dynamic>> permissionMaps = await _dbProvider.rawQuery('''
        SELECT p.* FROM permission p
        INNER JOIN role_permission rp ON p.id = rp.permission_id
        WHERE rp.role_id = ?
      ''', [roles[i].id]);
      
      final List<PermissionModel> permissions = permissionMaps.map((map) => PermissionModel.fromMap(map)).toList();
      
      roles[i] = roles[i].copyWith(permissions: permissions);
    }
    
    return user.copyWith(roles: roles);
  }
  
  // Insert user
  Future<int> insertUser(UserModel user) async {
    return await _dbProvider.insert('user', user.toMap());
  }
  
  // Update user
  Future<int> updateUser(UserModel user) async {
    return await _dbProvider.update('user', user.toMap(), user.id!);
  }
  
  // Delete user
  Future<int> deleteUser(int id) async {
    return await _dbProvider.delete('user', id);
  }
  
  // Toggle user active status
  Future<int> toggleUserActiveStatus(int id, bool isActive) async {
    return await _dbProvider.update(
      'user',
      {
        'is_active': isActive ? 1 : 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
      id,
    );
  }
  
  // Assign role to user
  Future<int> assignRoleToUser(int userId, int roleId) async {
    return await _dbProvider.insert('user_role', {
      'user_id': userId,
      'role_id': roleId,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }
  
  // Remove role from user
  Future<int> removeRoleFromUser(int userId, int roleId) async {
    return await _dbProvider.rawDelete(
      'DELETE FROM user_role WHERE user_id = ? AND role_id = ?',
      [userId, roleId],
    );
  }
  
  // Get all roles
  Future<List<RoleModel>> getAllRoles() async {
    final List<Map<String, dynamic>> maps = await _dbProvider.getAll('role');
    return maps.map((map) => RoleModel.fromMap(map)).toList();
  }
  
  // Get active roles
  Future<List<RoleModel>> getActiveRoles() async {
    final List<Map<String, dynamic>> maps = await _dbProvider.query(
      'role',
      where: 'is_active = ?',
      whereArgs: [1],
    );
    return maps.map((map) => RoleModel.fromMap(map)).toList();
  }
  
  // Get role by id
  Future<RoleModel?> getRoleById(int id) async {
    final Map<String, dynamic>? map = await _dbProvider.getById('role', id);
    if (map != null) {
      return RoleModel.fromMap(map);
    }
    return null;
  }
  
  // Insert role
  Future<int> insertRole(RoleModel role) async {
    return await _dbProvider.insert('role', role.toMap());
  }
  
  // Update role
  Future<int> updateRole(RoleModel role) async {
    return await _dbProvider.update('role', role.toMap(), role.id!);
  }
  
  // Delete role
  Future<int> deleteRole(int id) async {
    return await _dbProvider.delete('role', id);
  }
  
  // Get all permissions
  Future<List<PermissionModel>> getAllPermissions() async {
    final List<Map<String, dynamic>> maps = await _dbProvider.getAll('permission');
    return maps.map((map) => PermissionModel.fromMap(map)).toList();
  }
  
  // Get permissions by module
  Future<List<PermissionModel>> getPermissionsByModule(String module) async {
    final List<Map<String, dynamic>> maps = await _dbProvider.query(
      'permission',
      where: 'module = ?',
      whereArgs: [module],
    );
    return maps.map((map) => PermissionModel.fromMap(map)).toList();
  }
  
  // Get permission by id
  Future<PermissionModel?> getPermissionById(int id) async {
    final Map<String, dynamic>? map = await _dbProvider.getById('permission', id);
    if (map != null) {
      return PermissionModel.fromMap(map);
    }
    return null;
  }
  
  // Insert permission
  Future<int> insertPermission(PermissionModel permission) async {
    return await _dbProvider.insert('permission', permission.toMap());
  }
  
  // Update permission
  Future<int> updatePermission(PermissionModel permission) async {
    return await _dbProvider.update('permission', permission.toMap(), permission.id!);
  }
  
  // Delete permission
  Future<int> deletePermission(int id) async {
    return await _dbProvider.delete('permission', id);
  }
  
  // Assign permission to role
  Future<int> assignPermissionToRole(int roleId, int permissionId) async {
    return await _dbProvider.insert('role_permission', {
      'role_id': roleId,
      'permission_id': permissionId,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }
  
  // Remove permission from role
  Future<int> removePermissionFromRole(int roleId, int permissionId) async {
    return await _dbProvider.rawDelete(
      'DELETE FROM role_permission WHERE role_id = ? AND permission_id = ?',
      [roleId, permissionId],
    );
  }
}

