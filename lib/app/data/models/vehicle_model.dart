import 'package:equatable/equatable.dart';

class VehicleModel extends Equatable {
  final int? id;
  final String vehicleNumber;
  final String? vehicleType;
  final double? capacity;
  final String? ownerName;
  final String? ownerMobile;
  final String? ownerAddress;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  const VehicleModel({
    this.id,
    required this.vehicleNumber,
    this.vehicleType,
    this.capacity,
    this.ownerName,
    this.ownerMobile,
    this.ownerAddress,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });
  
  // Create a copy of this model with given fields replaced with new values
  VehicleModel copyWith({
    int? id,
    String? vehicleNumber,
    String? vehicleType,
    double? capacity,
    String? ownerName,
    String? ownerMobile,
    String? ownerAddress,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VehicleModel(
      id: id ?? this.id,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      vehicleType: vehicleType ?? this.vehicleType,
      capacity: capacity ?? this.capacity,
      ownerName: ownerName ?? this.ownerName,
      ownerMobile: ownerMobile ?? this.ownerMobile,
      ownerAddress: ownerAddress ?? this.ownerAddress,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  // Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicle_number': vehicleNumber,
      'vehicle_type': vehicleType,
      'capacity': capacity,
      'owner_name': ownerName,
      'owner_mobile': ownerMobile,
      'owner_address': ownerAddress,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  // Create model from JSON
  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'] as int?,
      vehicleNumber: json['vehicle_number'] as String,
      vehicleType: json['vehicle_type'] as String?,
      capacity: json['capacity'] != null ? json['capacity'] as double : null,
      ownerName: json['owner_name'] as String?,
      ownerMobile: json['owner_mobile'] as String?,
      ownerAddress: json['owner_address'] as String?,
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
  
  // Convert model to map for database operations
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'vehicle_number': vehicleNumber,
      'vehicle_type': vehicleType,
      'capacity': capacity,
      'owner_name': ownerName,
      'owner_mobile': ownerMobile,
      'owner_address': ownerAddress,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  // Create model from database map
  factory VehicleModel.fromMap(Map<String, dynamic> map) {
    return VehicleModel(
      id: map['id'] as int?,
      vehicleNumber: map['vehicle_number'] as String,
      vehicleType: map['vehicle_type'] as String?,
      capacity: map['capacity'] != null ? map['capacity'] as double : null,
      ownerName: map['owner_name'] as String?,
      ownerMobile: map['owner_mobile'] as String?,
      ownerAddress: map['owner_address'] as String?,
      isActive: map['is_active'] == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
  
  @override
  List<Object?> get props => [
    id,
    vehicleNumber,
    vehicleType,
    capacity,
    ownerName,
    ownerMobile,
    ownerAddress,
    isActive,
    createdAt,
    updatedAt,
  ];
  
  @override
  String toString() {
    return 'VehicleModel(id: $id, vehicleNumber: $vehicleNumber, isActive: $isActive)';
  }
}

