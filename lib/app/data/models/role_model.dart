import 'permission_model.dart';

class RoleModel {
  final int? id;
  final String name;
  final String? description;
  final bool isSystem;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<PermissionModel>? permissions;
  
  RoleModel({
    this.id,
    required this.name,
    this.description,
    this.isSystem = false,
    this.createdAt,
    this.updatedAt,
    this.permissions,
  });
  
  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      isSystem: json['is_system'] == 1,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      permissions: json['permissions'] != null
          ? (json['permissions'] as List)
              .map((permission) => PermissionModel.fromJson(permission))
              .toList()
          : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'is_system': isSystem ? 1 : 0,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'permissions': permissions?.map((permission) => permission.toJson()).toList(),
    };
  }
  
  // Create a copy of this RoleModel with the given fields replaced
  RoleModel copyWith({
    int? id,
    String? name,
    String? description,
    bool? isSystem,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<PermissionModel>? permissions,
  }) {
    return RoleModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isSystem: isSystem ?? this.isSystem,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      permissions: permissions ?? this.permissions,
    );
  }
  
  // Check if this role has a specific permission
  bool hasPermission(String permissionCode) {
    if (permissions == null) {
      return false;
    }
    
    return permissions!.any((permission) => permission.code == permissionCode);
  }
}

