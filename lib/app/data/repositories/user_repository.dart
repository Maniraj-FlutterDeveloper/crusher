import 'package:get/get.dart';
import '../models/user_model.dart';
import '../providers/db_provider.dart';

class UserRepository {
  final DbProvider _dbProvider = Get.find<DbProvider>();
  
  // Get all users
  Future<List<UserModel>> getAllUsers() async {
    final List<Map<String, dynamic>> maps = await _dbProvider.getAll('user');
    return List.generate(maps.length, (i) {
      return UserModel.fromMap(maps[i]);
    });
  }
  
  // Get active users
  Future<List<UserModel>> getActiveUsers() async {
    final List<Map<String, dynamic>> maps = await _dbProvider.getAll(
      'user',
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) {
      return UserModel.fromMap(maps[i]);
    });
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
    final List<Map<String, dynamic>> maps = await _dbProvider.getAll(
      'user',
      where: 'username = ?',
      whereArgs: [username],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    }
    return null;
  }
  
  // Get user with roles
  Future<UserModel?> getUserWithRoles(int id) async {
    final Map<String, dynamic>? userMap = await _dbProvider.getUserWithRoles(id);
    if (userMap != null) {
      final UserModel user = UserModel.fromMap(userMap);
      final List<RoleModel> roles = [];
      
      if (userMap['roles'] != null) {
        for (var roleMap in userMap['roles']) {
          roles.add(RoleModel.fromMap(roleMap));
        }
      }
      
      return user.copyWith(roles: roles);
    }
    return null;
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
  
  // Update user last login
  Future<int> updateUserLastLogin(int id) async {
    return await _dbProvider.update(
      'user',
      {
        'last_login': DateTime.now().toIso8601String(),
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
    return List.generate(maps.length, (i) {
      return RoleModel.fromMap(maps[i]);
    });
  }
  
  // Get active roles
  Future<List<RoleModel>> getActiveRoles() async {
    final List<Map<String, dynamic>> maps = await _dbProvider.getAll(
      'role',
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) {
      return RoleModel.fromMap(maps[i]);
    });
  }
  
  // Get role by id
  Future<RoleModel?> getRoleById(int id) async {
    final Map<String, dynamic>? map = await _dbProvider.getById('role', id);
    if (map != null) {
      return RoleModel.fromMap(map);
    }
    return null;
  }
  
  // Get role with permissions
  Future<RoleModel?> getRoleWithPermissions(int id) async {
    final Map<String, dynamic>? roleMap = await _dbProvider.getRoleWithPermissions(id);
    if (roleMap != null) {
      final RoleModel role = RoleModel.fromMap(roleMap);
      final List<PermissionModel> permissions = [];
      
      if (roleMap['permissions'] != null) {
        for (var permissionMap in roleMap['permissions']) {
          permissions.add(PermissionModel.fromMap(permissionMap));
        }
      }
      
      return role.copyWith(permissions: permissions);
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
  
  // Toggle role active status
  Future<int> toggleRoleActiveStatus(int id, bool isActive) async {
    return await _dbProvider.update(
      'role',
      {
        'is_active': isActive ? 1 : 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
      id,
    );
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
  
  // Get all permissions
  Future<List<PermissionModel>> getAllPermissions() async {
    final List<Map<String, dynamic>> maps = await _dbProvider.getAll('permission');
    return List.generate(maps.length, (i) {
      return PermissionModel.fromMap(maps[i]);
    });
  }
  
  // Get active permissions
  Future<List<PermissionModel>> getActivePermissions() async {
    final List<Map<String, dynamic>> maps = await _dbProvider.getAll(
      'permission',
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) {
      return PermissionModel.fromMap(maps[i]);
    });
  }
  
  // Get permissions by module
  Future<List<PermissionModel>> getPermissionsByModule(String module) async {
    final List<Map<String, dynamic>> maps = await _dbProvider.getAll(
      'permission',
      where: 'module = ?',
      whereArgs: [module],
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) {
      return PermissionModel.fromMap(maps[i]);
    });
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
  
  // Toggle permission active status
  Future<int> togglePermissionActiveStatus(int id, bool isActive) async {
    return await _dbProvider.update(
      'permission',
      {
        'is_active': isActive ? 1 : 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
      id,
    );
  }
  
  // Check if user has permission
  Future<bool> hasPermission(int userId, String permissionName) async {
    final List<Map<String, dynamic>> result = await _dbProvider.rawQuery('''
      SELECT COUNT(*) as count
      FROM user u
      JOIN user_role ur ON u.id = ur.user_id
      JOIN role r ON ur.role_id = r.id
      JOIN role_permission rp ON r.id = rp.role_id
      JOIN permission p ON rp.permission_id = p.id
      WHERE u.id = ? AND p.name = ? AND u.is_active = 1 AND r.is_active = 1 AND p.is_active = 1
    ''', [userId, permissionName]);
    
    return result.first['count'] > 0;
  }
  
  // Check if user has role
  Future<bool> hasRole(int userId, String roleName) async {
    final List<Map<String, dynamic>> result = await _dbProvider.rawQuery('''
      SELECT COUNT(*) as count
      FROM user u
      JOIN user_role ur ON u.id = ur.user_id
      JOIN role r ON ur.role_id = r.id
      WHERE u.id = ? AND r.name = ? AND u.is_active = 1 AND r.is_active = 1
    ''', [userId, roleName]);
    
    return result.first['count'] > 0;
  }
  
  // Authenticate user
  Future<UserModel?> authenticateUser(String username, String password) async {
    final List<Map<String, dynamic>> maps = await _dbProvider.getAll(
      'user',
      where: 'username = ? AND password = ? AND is_active = ?',
      whereArgs: [username, password, 1],
      limit: 1,
    );
    
    if (maps.isNotEmpty) {
      final UserModel user = UserModel.fromMap(maps.first);
      await updateUserLastLogin(user.id!);
      return await getUserWithRoles(user.id!);
    }
    
    return null;
  }
}

