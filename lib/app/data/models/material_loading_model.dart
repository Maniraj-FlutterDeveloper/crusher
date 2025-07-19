import 'package:crusher_management/app/data/models/material_size_model.dart';
import 'package:equatable/equatable.dart';
import 'gate_entry_model.dart';
import 'material_model.dart';
import 'user_model.dart';
import 'weighbridge_record_model.dart';

class MaterialLoadingModel extends Equatable {
  final int? id;
  final int gateEntryId;
  final int materialId;
  final int? materialSizeId;
  final double quantity;
  final int weightUnitId;
  final String purpose; // 'SALE' or 'INTERNAL'
  final int operatorId;
  final String? remarks;
  final String status; // 'PENDING', 'LOADING', 'LOADED', 'CANCELLED'
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Related models
  final GateEntryModel? gateEntry;
  final MaterialModel? material;
  final MaterialSizeModel? materialSize;
  final WeightUnitModel? weightUnit;
  final UserModel? operator;
  
  const MaterialLoadingModel({
    this.id,
    required this.gateEntryId,
    required this.materialId,
    this.materialSizeId,
    required this.quantity,
    required this.weightUnitId,
    required this.purpose,
    required this.operatorId,
    this.remarks,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.gateEntry,
    this.material,
    this.materialSize,
    this.weightUnit,
    this.operator,
  });
  
  // Create a copy of this model with given fields replaced with new values
  MaterialLoadingModel copyWith({
    int? id,
    int? gateEntryId,
    int? materialId,
    int? materialSizeId,
    double? quantity,
    int? weightUnitId,
    String? purpose,
    int? operatorId,
    String? remarks,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    GateEntryModel? gateEntry,
    MaterialModel? material,
    MaterialSizeModel? materialSize,
    WeightUnitModel? weightUnit,
    UserModel? operator,
  }) {
    return MaterialLoadingModel(
      id: id ?? this.id,
      gateEntryId: gateEntryId ?? this.gateEntryId,
      materialId: materialId ?? this.materialId,
      materialSizeId: materialSizeId ?? this.materialSizeId,
      quantity: quantity ?? this.quantity,
      weightUnitId: weightUnitId ?? this.weightUnitId,
      purpose: purpose ?? this.purpose,
      operatorId: operatorId ?? this.operatorId,
      remarks: remarks ?? this.remarks,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      gateEntry: gateEntry ?? this.gateEntry,
      material: material ?? this.material,
      materialSize: materialSize ?? this.materialSize,
      weightUnit: weightUnit ?? this.weightUnit,
      operator: operator ?? this.operator,
    );
  }
  
  // Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gate_entry_id': gateEntryId,
      'material_id': materialId,
      'material_size_id': materialSizeId,
      'quantity': quantity,
      'weight_unit_id': weightUnitId,
      'purpose': purpose,
      'operator_id': operatorId,
      'remarks': remarks,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'gate_entry': gateEntry?.toJson(),
      'material': material?.toJson(),
      'material_size': materialSize?.toJson(),
      'weight_unit': weightUnit?.toJson(),
      'operator': operator?.toJson(),
    };
  }
  
  // Create model from JSON
  factory MaterialLoadingModel.fromJson(Map<String, dynamic> json) {
    return MaterialLoadingModel(
      id: json['id'] as int?,
      gateEntryId: json['gate_entry_id'] as int,
      materialId: json['material_id'] as int,
      materialSizeId: json['material_size_id'] as int?,
      quantity: json['quantity'] as double,
      weightUnitId: json['weight_unit_id'] as int,
      purpose: json['purpose'] as String,
      operatorId: json['operator_id'] as int,
      remarks: json['remarks'] as String?,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      gateEntry: json['gate_entry'] != null ? GateEntryModel.fromJson(json['gate_entry'] as Map<String, dynamic>) : null,
      material: json['material'] != null ? MaterialModel.fromJson(json['material'] as Map<String, dynamic>) : null,
      materialSize: json['material_size'] != null ? MaterialSizeModel.fromJson(json['material_size'] as Map<String, dynamic>) : null,
      weightUnit: json['weight_unit'] != null ? WeightUnitModel.fromJson(json['weight_unit'] as Map<String, dynamic>) : null,
      operator: json['operator'] != null ? UserModel.fromJson(json['operator'] as Map<String, dynamic>) : null,
    );
  }
  
  // Convert model to map for database operations
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'gate_entry_id': gateEntryId,
      'material_id': materialId,
      'material_size_id': materialSizeId,
      'quantity': quantity,
      'weight_unit_id': weightUnitId,
      'purpose': purpose,
      'operator_id': operatorId,
      'remarks': remarks,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  // Create model from database map
  factory MaterialLoadingModel.fromMap(Map<String, dynamic> map) {
    return MaterialLoadingModel(
      id: map['id'] as int?,
      gateEntryId: map['gate_entry_id'] as int,
      materialId: map['material_id'] as int,
      materialSizeId: map['material_size_id'] as int?,
      quantity: map['quantity'] as double,
      weightUnitId: map['weight_unit_id'] as int,
      purpose: map['purpose'] as String,
      operatorId: map['operator_id'] as int,
      remarks: map['remarks'] as String?,
      status: map['status'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
  
  @override
  List<Object?> get props => [
    id,
    gateEntryId,
    materialId,
    materialSizeId,
    quantity,
    weightUnitId,
    purpose,
    operatorId,
    remarks,
    status,
    createdAt,
    updatedAt,
    gateEntry,
    material,
    materialSize,
    weightUnit,
    operator,
  ];
  
  @override
  String toString() {
    return 'MaterialLoadingModel(id: $id, materialId: $materialId, quantity: $quantity)';
  }
}

