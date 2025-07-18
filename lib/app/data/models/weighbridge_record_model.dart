import 'package:equatable/equatable.dart';
import 'gate_entry_model.dart';
import 'user_model.dart';

class WeighbridgeRecordModel extends Equatable {
  final int? id;
  final int gateEntryId;
  final double? tareWeight;
  final double? grossWeight;
  final double? netWeight;
  final int weightUnitId;
  final DateTime? tareWeightTime;
  final DateTime? grossWeightTime;
  final int operatorId;
  final String? remarks;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Related models
  final GateEntryModel? gateEntry;
  final UserModel? operator;
  final WeightUnitModel? weightUnit;
  
  const WeighbridgeRecordModel({
    this.id,
    required this.gateEntryId,
    this.tareWeight,
    this.grossWeight,
    this.netWeight,
    required this.weightUnitId,
    this.tareWeightTime,
    this.grossWeightTime,
    required this.operatorId,
    this.remarks,
    required this.createdAt,
    required this.updatedAt,
    this.gateEntry,
    this.operator,
    this.weightUnit,
  });
  
  // Create a copy of this model with given fields replaced with new values
  WeighbridgeRecordModel copyWith({
    int? id,
    int? gateEntryId,
    double? tareWeight,
    double? grossWeight,
    double? netWeight,
    int? weightUnitId,
    DateTime? tareWeightTime,
    DateTime? grossWeightTime,
    int? operatorId,
    String? remarks,
    DateTime? createdAt,
    DateTime? updatedAt,
    GateEntryModel? gateEntry,
    UserModel? operator,
    WeightUnitModel? weightUnit,
  }) {
    return WeighbridgeRecordModel(
      id: id ?? this.id,
      gateEntryId: gateEntryId ?? this.gateEntryId,
      tareWeight: tareWeight ?? this.tareWeight,
      grossWeight: grossWeight ?? this.grossWeight,
      netWeight: netWeight ?? this.netWeight,
      weightUnitId: weightUnitId ?? this.weightUnitId,
      tareWeightTime: tareWeightTime ?? this.tareWeightTime,
      grossWeightTime: grossWeightTime ?? this.grossWeightTime,
      operatorId: operatorId ?? this.operatorId,
      remarks: remarks ?? this.remarks,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      gateEntry: gateEntry ?? this.gateEntry,
      operator: operator ?? this.operator,
      weightUnit: weightUnit ?? this.weightUnit,
    );
  }
  
  // Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gate_entry_id': gateEntryId,
      'tare_weight': tareWeight,
      'gross_weight': grossWeight,
      'net_weight': netWeight,
      'weight_unit_id': weightUnitId,
      'tare_weight_time': tareWeightTime?.toIso8601String(),
      'gross_weight_time': grossWeightTime?.toIso8601String(),
      'operator_id': operatorId,
      'remarks': remarks,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'gate_entry': gateEntry?.toJson(),
      'operator': operator?.toJson(),
      'weight_unit': weightUnit?.toJson(),
    };
  }
  
  // Create model from JSON
  factory WeighbridgeRecordModel.fromJson(Map<String, dynamic> json) {
    return WeighbridgeRecordModel(
      id: json['id'] as int?,
      gateEntryId: json['gate_entry_id'] as int,
      tareWeight: json['tare_weight'] != null ? json['tare_weight'] as double : null,
      grossWeight: json['gross_weight'] != null ? json['gross_weight'] as double : null,
      netWeight: json['net_weight'] != null ? json['net_weight'] as double : null,
      weightUnitId: json['weight_unit_id'] as int,
      tareWeightTime: json['tare_weight_time'] != null ? DateTime.parse(json['tare_weight_time'] as String) : null,
      grossWeightTime: json['gross_weight_time'] != null ? DateTime.parse(json['gross_weight_time'] as String) : null,
      operatorId: json['operator_id'] as int,
      remarks: json['remarks'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      gateEntry: json['gate_entry'] != null ? GateEntryModel.fromJson(json['gate_entry'] as Map<String, dynamic>) : null,
      operator: json['operator'] != null ? UserModel.fromJson(json['operator'] as Map<String, dynamic>) : null,
      weightUnit: json['weight_unit'] != null ? WeightUnitModel.fromJson(json['weight_unit'] as Map<String, dynamic>) : null,
    );
  }
  
  // Convert model to map for database operations
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'gate_entry_id': gateEntryId,
      'tare_weight': tareWeight,
      'gross_weight': grossWeight,
      'net_weight': netWeight,
      'weight_unit_id': weightUnitId,
      'tare_weight_time': tareWeightTime?.toIso8601String(),
      'gross_weight_time': grossWeightTime?.toIso8601String(),
      'operator_id': operatorId,
      'remarks': remarks,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  // Create model from database map
  factory WeighbridgeRecordModel.fromMap(Map<String, dynamic> map) {
    return WeighbridgeRecordModel(
      id: map['id'] as int?,
      gateEntryId: map['gate_entry_id'] as int,
      tareWeight: map['tare_weight'] != null ? map['tare_weight'] as double : null,
      grossWeight: map['gross_weight'] != null ? map['gross_weight'] as double : null,
      netWeight: map['net_weight'] != null ? map['net_weight'] as double : null,
      weightUnitId: map['weight_unit_id'] as int,
      tareWeightTime: map['tare_weight_time'] != null ? DateTime.parse(map['tare_weight_time'] as String) : null,
      grossWeightTime: map['gross_weight_time'] != null ? DateTime.parse(map['gross_weight_time'] as String) : null,
      operatorId: map['operator_id'] as int,
      remarks: map['remarks'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
  
  @override
  List<Object?> get props => [
    id,
    gateEntryId,
    tareWeight,
    grossWeight,
    netWeight,
    weightUnitId,
    tareWeightTime,
    grossWeightTime,
    operatorId,
    remarks,
    createdAt,
    updatedAt,
    gateEntry,
    operator,
    weightUnit,
  ];
  
  @override
  String toString() {
    return 'WeighbridgeRecordModel(id: $id, gateEntryId: $gateEntryId, netWeight: $netWeight)';
  }
}

class WeightUnitModel extends Equatable {
  final int? id;
  final String name;
  final String symbol;
  final double conversionFactor;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  const WeightUnitModel({
    this.id,
    required this.name,
    required this.symbol,
    required this.conversionFactor,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });
  
  // Create a copy of this model with given fields replaced with new values
  WeightUnitModel copyWith({
    int? id,
    String? name,
    String? symbol,
    double? conversionFactor,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WeightUnitModel(
      id: id ?? this.id,
      name: name ?? this.name,
      symbol: symbol ?? this.symbol,
      conversionFactor: conversionFactor ?? this.conversionFactor,
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
      'symbol': symbol,
      'conversion_factor': conversionFactor,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  // Create model from JSON
  factory WeightUnitModel.fromJson(Map<String, dynamic> json) {
    return WeightUnitModel(
      id: json['id'] as int?,
      name: json['name'] as String,
      symbol: json['symbol'] as String,
      conversionFactor: json['conversion_factor'] as double,
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
      'symbol': symbol,
      'conversion_factor': conversionFactor,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  // Create model from database map
  factory WeightUnitModel.fromMap(Map<String, dynamic> map) {
    return WeightUnitModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      symbol: map['symbol'] as String,
      conversionFactor: map['conversion_factor'] as double,
      isActive: map['is_active'] == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
  
  @override
  List<Object?> get props => [
    id,
    name,
    symbol,
    conversionFactor,
    isActive,
    createdAt,
    updatedAt,
  ];
  
  @override
  String toString() {
    return 'WeightUnitModel(id: $id, name: $name, symbol: $symbol)';
  }
}

