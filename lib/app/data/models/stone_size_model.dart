import 'package:equatable/equatable.dart';

class StoneSizeModel extends Equatable {
  final int? id;
  final String size;
  final String? description;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  const StoneSizeModel({
    this.id,
    required this.size,
    this.description,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });
  
  // Create a copy of this model with given fields replaced with new values
  StoneSizeModel copyWith({
    int? id,
    String? size,
    String? description,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StoneSizeModel(
      id: id ?? this.id,
      size: size ?? this.size,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  // Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'size': size,
      'description': description,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  // Create model from JSON
  factory StoneSizeModel.fromJson(Map<String, dynamic> json) {
    return StoneSizeModel(
      id: json['id'] as int?,
      size: json['size'] as String,
      description: json['description'] as String?,
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
  
  // Convert model to map for database operations
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'size': size,
      'description': description,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  // Create model from database map
  factory StoneSizeModel.fromMap(Map<String, dynamic> map) {
    return StoneSizeModel(
      id: map['id'] as int?,
      size: map['size'] as String,
      description: map['description'] as String?,
      isActive: map['is_active'] == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
  
  @override
  List<Object?> get props => [
    id,
    size,
    description,
    isActive,
    createdAt,
    updatedAt,
  ];
  
  @override
  String toString() {
    return 'StoneSizeModel(id: $id, size: $size)';
  }
}

