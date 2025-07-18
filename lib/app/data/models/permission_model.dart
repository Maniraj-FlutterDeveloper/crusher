class PermissionModel {
  final int? id;
  final String name;
  final String code;
  final String? description;
  final String module;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  PermissionModel({
    this.id,
    required this.name,
    required this.code,
    this.description,
    required this.module,
    this.createdAt,
    this.updatedAt,
  });
  
  factory PermissionModel.fromJson(Map<String, dynamic> json) {
    return PermissionModel(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      description: json['description'],
      module: json['module'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'description': description,
      'module': module,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
  
  // Create a copy of this PermissionModel with the given fields replaced
  PermissionModel copyWith({
    int? id,
    String? name,
    String? code,
    String? description,
    String? module,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PermissionModel(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      description: description ?? this.description,
      module: module ?? this.module,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

