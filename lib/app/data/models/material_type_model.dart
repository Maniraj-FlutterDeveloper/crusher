import 'package:equatable/equatable.dart';

class MaterialTypeModel extends Equatable {
  final int? id;
  final String name;
  final String code;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  const MaterialTypeModel({
    this.id,
    required this.name,
    required this.code,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });
  
  factory MaterialTypeModel.fromJson(Map<String, dynamic> json) {
    return MaterialTypeModel(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'code': code,
      'isActive': isActive,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }
  
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'code': code,
      'is_active': isActive ? 1 : 0,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }
  
  factory MaterialTypeModel.fromMap(Map<String, dynamic> map) {
    return MaterialTypeModel(
      id: map['id'],
      name: map['name'],
      code: map['code'],
      isActive: map['is_active'] == 1,
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at']) 
          : null,
      updatedAt: map['updated_at'] != null 
          ? DateTime.parse(map['updated_at']) 
          : null,
    );
  }
  
  MaterialTypeModel copyWith({
    int? id,
    String? name,
    String? code,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MaterialTypeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  @override
  List<Object?> get props => [
    id,
    name,
    code,
    isActive,
    createdAt,
    updatedAt,
  ];
  
  @override
  String toString() {
    return 'MaterialTypeModel(id: $id, name: $name, code: $code)';
  }
}