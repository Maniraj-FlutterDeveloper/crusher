import 'package:equatable/equatable.dart';
import 'vehicle_model.dart';

class GateEntryModel extends Equatable {
  final int? id;
  final String sessionId;
  final int vehicleId;
  final String? driverName;
  final String? driverMobile;
  final DateTime entryTime;
  final DateTime? exitTime;
  final double? tareWeight;
  final double? grossWeight;
  final double? netWeight;
  final String status;
  final String gatePassNumber;
  final String? remarks;
  final int operatorId;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Related models
  final VehicleModel? vehicle;
  
  const GateEntryModel({
    this.id,
    required this.sessionId,
    required this.vehicleId,
    this.driverName,
    this.driverMobile,
    required this.entryTime,
    this.exitTime,
    this.tareWeight,
    this.grossWeight,
    this.netWeight,
    required this.status,
    required this.gatePassNumber,
    this.remarks,
    required this.operatorId,
    required this.createdAt,
    required this.updatedAt,
    this.vehicle,
  });
  
  // Create a copy of this model with given fields replaced with new values
  GateEntryModel copyWith({
    int? id,
    String? sessionId,
    int? vehicleId,
    String? driverName,
    String? driverMobile,
    DateTime? entryTime,
    DateTime? exitTime,
    double? tareWeight,
    double? grossWeight,
    double? netWeight,
    String? status,
    String? gatePassNumber,
    String? remarks,
    int? operatorId,
    DateTime? createdAt,
    DateTime? updatedAt,
    VehicleModel? vehicle,
  }) {
    return GateEntryModel(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      vehicleId: vehicleId ?? this.vehicleId,
      driverName: driverName ?? this.driverName,
      driverMobile: driverMobile ?? this.driverMobile,
      entryTime: entryTime ?? this.entryTime,
      exitTime: exitTime ?? this.exitTime,
      tareWeight: tareWeight ?? this.tareWeight,
      grossWeight: grossWeight ?? this.grossWeight,
      netWeight: netWeight ?? this.netWeight,
      status: status ?? this.status,
      gatePassNumber: gatePassNumber ?? this.gatePassNumber,
      remarks: remarks ?? this.remarks,
      operatorId: operatorId ?? this.operatorId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      vehicle: vehicle ?? this.vehicle,
    );
  }
  
  // Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'session_id': sessionId,
      'vehicle_id': vehicleId,
      'driver_name': driverName,
      'driver_mobile': driverMobile,
      'entry_time': entryTime.toIso8601String(),
      'exit_time': exitTime?.toIso8601String(),
      'tare_weight': tareWeight,
      'gross_weight': grossWeight,
      'net_weight': netWeight,
      'status': status,
      'gate_pass_number': gatePassNumber,
      'remarks': remarks,
      'operator_id': operatorId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'vehicle': vehicle?.toJson(),
    };
  }
  
  // Create model from JSON
  factory GateEntryModel.fromJson(Map<String, dynamic> json) {
    return GateEntryModel(
      id: json['id'] as int?,
      sessionId: json['session_id'] as String,
      vehicleId: json['vehicle_id'] as int,
      driverName: json['driver_name'] as String?,
      driverMobile: json['driver_mobile'] as String?,
      entryTime: DateTime.parse(json['entry_time'] as String),
      exitTime: json['exit_time'] != null ? DateTime.parse(json['exit_time'] as String) : null,
      tareWeight: json['tare_weight'] != null ? json['tare_weight'] as double : null,
      grossWeight: json['gross_weight'] != null ? json['gross_weight'] as double : null,
      netWeight: json['net_weight'] != null ? json['net_weight'] as double : null,
      status: json['status'] as String,
      gatePassNumber: json['gate_pass_number'] as String,
      remarks: json['remarks'] as String?,
      operatorId: json['operator_id'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      vehicle: json['vehicle'] != null ? VehicleModel.fromJson(json['vehicle'] as Map<String, dynamic>) : null,
    );
  }
  
  // Convert model to map for database operations
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'session_id': sessionId,
      'vehicle_id': vehicleId,
      'driver_name': driverName,
      'driver_mobile': driverMobile,
      'entry_time': entryTime.toIso8601String(),
      'exit_time': exitTime?.toIso8601String(),
      'tare_weight': tareWeight,
      'gross_weight': grossWeight,
      'net_weight': netWeight,
      'status': status,
      'gate_pass_number': gatePassNumber,
      'remarks': remarks,
      'operator_id': operatorId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  // Create model from database map
  factory GateEntryModel.fromMap(Map<String, dynamic> map) {
    return GateEntryModel(
      id: map['id'] as int?,
      sessionId: map['session_id'] as String,
      vehicleId: map['vehicle_id'] as int,
      driverName: map['driver_name'] as String?,
      driverMobile: map['driver_mobile'] as String?,
      entryTime: DateTime.parse(map['entry_time'] as String),
      exitTime: map['exit_time'] != null ? DateTime.parse(map['exit_time'] as String) : null,
      tareWeight: map['tare_weight'] != null ? map['tare_weight'] as double : null,
      grossWeight: map['gross_weight'] != null ? map['gross_weight'] as double : null,
      netWeight: map['net_weight'] != null ? map['net_weight'] as double : null,
      status: map['status'] as String,
      gatePassNumber: map['gate_pass_number'] as String,
      remarks: map['remarks'] as String?,
      operatorId: map['operator_id'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
  
  @override
  List<Object?> get props => [
    id,
    sessionId,
    vehicleId,
    driverName,
    driverMobile,
    entryTime,
    exitTime,
    tareWeight,
    grossWeight,
    netWeight,
    status,
    gatePassNumber,
    remarks,
    operatorId,
    createdAt,
    updatedAt,
    vehicle,
  ];
  
  @override
  String toString() {
    return 'GateEntryModel(id: $id, sessionId: $sessionId, status: $status)';
  }
}

