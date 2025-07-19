import 'package:equatable/equatable.dart';

class WeightUnitModel extends Equatable {
  final int? id;
  final String name;
  final String symbol;
  final double conversionFactor; // Conversion factor to base unit
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  const WeightUnitModel({
    this.id,
    required this.name,
    required this.symbol,
    required this.conversionFactor,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });
  
  factory WeightUnitModel.fromJson(Map<String, dynamic> json) {
    return WeightUnitModel(
      id: json['id'],
      name: json['name'],
      symbol: json['symbol'],
      conversionFactor: json['conversionFactor'] is String 
          ? double.parse(json['conversionFactor']) 
          : json['conversionFactor']?.toDouble() ?? 1.0,
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
      'symbol': symbol,
      'conversionFactor': conversionFactor,
      'isActive': isActive,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }
  
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'symbol': symbol,
      'conversion_factor': conversionFactor,
      'is_active': isActive ? 1 : 0,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }
  
  factory WeightUnitModel.fromMap(Map<String, dynamic> map) {
    return WeightUnitModel(
      id: map['id'],
      name: map['name'],
      symbol: map['symbol'],
      conversionFactor: map['conversion_factor']?.toDouble() ?? 1.0,
      isActive: map['is_active'] == 1,
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at']) 
          : null,
      updatedAt: map['updated_at'] != null 
          ? DateTime.parse(map['updated_at']) 
          : null,
    );
  }
  
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
    return 'WeightUnitModel(id: $id, name: $name, symbol: $symbol, conversionFactor: $conversionFactor)';
  }
}