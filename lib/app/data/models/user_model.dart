import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final int? id;
  final String username;
  final String password;
  final String name;
  final String? email;
  final String? mobile;
  final bool isActive;
  final DateTime? lastLogin;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<RoleModel>? roles;
  
  const UserModel({
    this.id,
    required this.username,
    required this.password,
    required this.name,
    this.email,
    this.mobile,
    this.isActive = true,
    this.lastLogin,
    required this.createdAt,
    required this.updatedAt,
    this.roles,
  });
  
  // Create a copy of this model with given fields replaced with new values
  UserModel copyWith({
    int? id,
    String? username,
    String? password,
    String? name,
    String? email,
    String? mobile,
    bool? isActive,
    DateTime? lastLogin,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<RoleModel>? roles,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
      name: name ?? this.name,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      isActive: isActive ?? this.isActive,
      lastLogin: lastLogin ?? this.lastLogin,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      roles: roles ?? this.roles,
    );
  }
  
  // Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'name': name,
      'email': email,
      'mobile': mobile,
      'is_active': isActive ? 1 : 0,
      'last_login': lastLogin?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'roles': roles?.map((role) => role.toJson()).toList(),
    };
  }
  
  // Create model from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int?,
      username: json['username'] as String,
      password: '', // Password is not included in JSON for security
      name: json['name'] as String,
      email: json['email'] as String?,
      mobile: json['mobile'] as String?,
      isActive: (json['is_active'] as int) == 1,
      lastLogin: json['last_login'] != null ? DateTime.parse(json['last_login'] as String) : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      roles: json['roles'] != null
          ? (json['roles'] as List).map((roleJson) => RoleModel.fromJson(roleJson)).toList()
          : null,
    );
  }
  
  // Convert model to map for database operations
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'username': username,
      'password': password,
      'name': name,
      'email': email,
      'mobile': mobile,
      'is_active': isActive ? 1 : 0,
      'last_login': lastLogin?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  // Create model from database map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int?,
      username: map['username'] as String,
      password: map['password'] as String,
      name: map['name'] as String,
      email: map['email'] as String?,
      mobile: map['mobile'] as String?,
      isActive: (map['is_active'] as int) == 1,
      lastLogin: map['last_login'] != null ? DateTime.parse(map['last_login'] as String) : null,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
  
  @override
  List<Object?> get props => [
    id,
    username,
    password,
    name,
    email,
    mobile,
    isActive,
    lastLogin,
    createdAt,
    updatedAt,
    roles,
  ];
  
  @override
  String toString() {
    return 'UserModel(id: $id, username: $username, name: $name)';
  }
}

class RoleModel extends Equatable {
  final int? id;
  final String name;
  final String? description;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<PermissionModel>? permissions;
  
  const RoleModel({
    this.id,
    required this.name,
    this.description,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.permissions,
  });
  
  // Create a copy of this model with given fields replaced with new values
  RoleModel copyWith({
    int? id,
    String? name,
    String? description,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<PermissionModel>? permissions,
  }) {
    return RoleModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      permissions: permissions ?? this.permissions,
    );
  }
  
  // Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'permissions': permissions?.map((permission) => permission.toJson()).toList(),
    };
  }
  
  // Create model from JSON
  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      id: json['id'] as int?,
      name: json['name'] as String,
      description: json['description'] as String?,
      isActive: (json['is_active'] as int) == 1,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      permissions: json['permissions'] != null
          ? (json['permissions'] as List).map((permissionJson) => PermissionModel.fromJson(permissionJson)).toList()
          : null,
    );
  }
  
  // Convert model to map for database operations
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'description': description,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  // Create model from database map
  factory RoleModel.fromMap(Map<String, dynamic> map) {
    return RoleModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String?,
      isActive: (map['is_active'] as int) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
  
  @override
  List<Object?> get props => [
    id,
    name,
    description,
    isActive,
    createdAt,
    updatedAt,
    permissions,
  ];
  
  @override
  String toString() {
    return 'RoleModel(id: $id, name: $name)';
  }
}

class PermissionModel extends Equatable {
  final int? id;
  final String name;
  final String? description;
  final String module;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  const PermissionModel({
    this.id,
    required this.name,
    this.description,
    required this.module,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });
  
  // Create a copy of this model with given fields replaced with new values
  PermissionModel copyWith({
    int? id,
    String? name,
    String? description,
    String? module,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PermissionModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      module: module ?? this.module,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  // Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'module': module,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  // Create model from JSON
  factory PermissionModel.fromJson(Map<String, dynamic> json) {
    return PermissionModel(
      id: json['id'] as int?,
      name: json['name'] as String,
      description: json['description'] as String?,
      module: json['module'] as String,
      isActive: (json['is_active'] as int) == 1,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
  
  // Convert model to map for database operations
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'description': description,
      'module': module,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  // Create model from database map
  factory PermissionModel.fromMap(Map<String, dynamic> map) {
    return PermissionModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String?,
      module: map['module'] as String,
      isActive: (map['is_active'] as int) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
  
  @override
  List<Object?> get props => [
    id,
    name,
    description,
    module,
    isActive,
    createdAt,
    updatedAt,
  ];
  
  @override
  String toString() {
    return 'PermissionModel(id: $id, name: $name, module: $module)';
  }
}

