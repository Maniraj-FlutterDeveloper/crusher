import 'package:equatable/equatable.dart';

class MaterialModel extends Equatable {
  final int? id;
  final String name;
  final String description;
  final String type;
  final String? size;
  final double unitPrice;
  final int gstPercentage;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  const MaterialModel({
    this.id,
    required this.name,
    required this.description,
    required this.type,
    this.size,
    required this.unitPrice,
    required this.gstPercentage,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });
  
  factory MaterialModel.fromJson(Map<String, dynamic> json) {
    return MaterialModel(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      type: json['type'],
      size: json['size'],
      unitPrice: json['unitPrice'] is String 
          ? double.parse(json['unitPrice']) 
          : json['unitPrice']?.toDouble() ?? 0.0,
      gstPercentage: json['gstPercentage'] is String 
          ? int.parse(json['gstPercentage']) 
          : json['gstPercentage'] ?? 0,
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
      'description': description,
      'type': type,
      'size': size,
      'unitPrice': unitPrice,
      'gstPercentage': gstPercentage,
      'isActive': isActive,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }
  
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'description': description,
      'type': type,
      'size': size,
      'unit_price': unitPrice,
      'gst_percentage': gstPercentage,
      'is_active': isActive ? 1 : 0,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }
  
  factory MaterialModel.fromMap(Map<String, dynamic> map) {
    return MaterialModel(
      id: map['id'],
      name: map['name'],
      description: map['description'] ?? '',
      type: map['type'],
      size: map['size'],
      unitPrice: map['unit_price']?.toDouble() ?? 0.0,
      gstPercentage: map['gst_percentage'] ?? 0,
      isActive: map['is_active'] == 1,
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at']) 
          : null,
      updatedAt: map['updated_at'] != null 
          ? DateTime.parse(map['updated_at']) 
          : null,
    );
  }
  
  MaterialModel copyWith({
    int? id,
    String? name,
    String? description,
    String? type,
    String? size,
    double? unitPrice,
    int? gstPercentage,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MaterialModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      size: size ?? this.size,
      unitPrice: unitPrice ?? this.unitPrice,
      gstPercentage: gstPercentage ?? this.gstPercentage,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  @override
  List<Object?> get props => [
    id,
    name,
    description,
    type,
    size,
    unitPrice,
    gstPercentage,
    isActive,
    createdAt,
    updatedAt,
  ];
}

