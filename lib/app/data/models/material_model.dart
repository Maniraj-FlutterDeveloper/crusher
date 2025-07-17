import 'package:equatable/equatable.dart';

class MaterialModel extends Equatable {
  final int? id;
  final String name;
  final String? description;
  final int materialTypeId;
  final double? rate;
  final double? gstPercentage;
  final String? hsnCode;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  const MaterialModel({
    this.id,
    required this.name,
    this.description,
    required this.materialTypeId,
    this.rate,
    this.gstPercentage,
    this.hsnCode,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });
  
  // Create a copy of this model with given fields replaced with new values
  MaterialModel copyWith({
    int? id,
    String? name,
    String? description,
    int? materialTypeId,
    double? rate,
    double? gstPercentage,
    String? hsnCode,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MaterialModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      materialTypeId: materialTypeId ?? this.materialTypeId,
      rate: rate ?? this.rate,
      gstPercentage: gstPercentage ?? this.gstPercentage,
      hsnCode: hsnCode ?? this.hsnCode,
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
      'material_type_id': materialTypeId,
      'rate': rate,
      'gst_percentage': gstPercentage,
      'hsn_code': hsnCode,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  // Create model from JSON
  factory MaterialModel.fromJson(Map<String, dynamic> json) {
    return MaterialModel(
      id: json['id'] as int?,
      name: json['name'] as String,
      description: json['description'] as String?,
      materialTypeId: json['material_type_id'] as int,
      rate: json['rate'] != null ? json['rate'] as double : null,
      gstPercentage: json['gst_percentage'] != null ? json['gst_percentage'] as double : null,
      hsnCode: json['hsn_code'] as String?,
      isActive: json['is_active'] as bool,
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
      'material_type_id': materialTypeId,
      'rate': rate,
      'gst_percentage': gstPercentage,
      'hsn_code': hsnCode,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  // Create model from database map
  factory MaterialModel.fromMap(Map<String, dynamic> map) {
    return MaterialModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String?,
      materialTypeId: map['material_type_id'] as int,
      rate: map['rate'] != null ? map['rate'] as double : null,
      gstPercentage: map['gst_percentage'] != null ? map['gst_percentage'] as double : null,
      hsnCode: map['hsn_code'] as String?,
      isActive: map['is_active'] == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
  
  @override
  List<Object?> get props => [
    id,
    name,
    description,
    materialTypeId,
    rate,
    gstPercentage,
    hsnCode,
    isActive,
    createdAt,
    updatedAt,
  ];
  
  @override
  String toString() {
    return 'MaterialModel(id: $id, name: $name, materialTypeId: $materialTypeId, rate: $rate)';
  }
}

