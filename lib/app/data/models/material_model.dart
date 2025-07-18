import 'package:equatable/equatable.dart';

class MaterialModel extends Equatable {
  final int? id;
  final String name;
  final String code;
  final int materialTypeId;
  final double? rate;
  final int? taxConfigurationId;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Related models
  final MaterialTypeModel? materialType;
  final TaxConfigurationModel? taxConfiguration;
  
  const MaterialModel({
    this.id,
    required this.name,
    required this.code,
    required this.materialTypeId,
    this.rate,
    this.taxConfigurationId,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.materialType,
    this.taxConfiguration,
  });
  
  // Create a copy of this model with given fields replaced with new values
  MaterialModel copyWith({
    int? id,
    String? name,
    String? code,
    int? materialTypeId,
    double? rate,
    int? taxConfigurationId,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    MaterialTypeModel? materialType,
    TaxConfigurationModel? taxConfiguration,
  }) {
    return MaterialModel(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      materialTypeId: materialTypeId ?? this.materialTypeId,
      rate: rate ?? this.rate,
      taxConfigurationId: taxConfigurationId ?? this.taxConfigurationId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      materialType: materialType ?? this.materialType,
      taxConfiguration: taxConfiguration ?? this.taxConfiguration,
    );
  }
  
  // Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'material_type_id': materialTypeId,
      'rate': rate,
      'tax_configuration_id': taxConfigurationId,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'material_type': materialType?.toJson(),
      'tax_configuration': taxConfiguration?.toJson(),
    };
  }
  
  // Create model from JSON
  factory MaterialModel.fromJson(Map<String, dynamic> json) {
    return MaterialModel(
      id: json['id'] as int?,
      name: json['name'] as String,
      code: json['code'] as String,
      materialTypeId: json['material_type_id'] as int,
      rate: json['rate'] != null ? json['rate'] as double : null,
      taxConfigurationId: json['tax_configuration_id'] as int?,
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      materialType: json['material_type'] != null ? MaterialTypeModel.fromJson(json['material_type'] as Map<String, dynamic>) : null,
      taxConfiguration: json['tax_configuration'] != null ? TaxConfigurationModel.fromJson(json['tax_configuration'] as Map<String, dynamic>) : null,
    );
  }
  
  // Convert model to map for database operations
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'code': code,
      'material_type_id': materialTypeId,
      'rate': rate,
      'tax_configuration_id': taxConfigurationId,
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
      code: map['code'] as String,
      materialTypeId: map['material_type_id'] as int,
      rate: map['rate'] != null ? map['rate'] as double : null,
      taxConfigurationId: map['tax_configuration_id'] as int?,
      isActive: map['is_active'] == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
  
  @override
  List<Object?> get props => [
    id,
    name,
    code,
    materialTypeId,
    rate,
    taxConfigurationId,
    isActive,
    createdAt,
    updatedAt,
    materialType,
    taxConfiguration,
  ];
  
  @override
  String toString() {
    return 'MaterialModel(id: $id, name: $name, code: $code)';
  }
}

class MaterialTypeModel extends Equatable {
  final int? id;
  final String name;
  final String code;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  const MaterialTypeModel({
    this.id,
    required this.name,
    required this.code,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });
  
  // Create a copy of this model with given fields replaced with new values
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
  
  // Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  // Create model from JSON
  factory MaterialTypeModel.fromJson(Map<String, dynamic> json) {
    return MaterialTypeModel(
      id: json['id'] as int?,
      name: json['name'] as String,
      code: json['code'] as String,
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
      'code': code,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  // Create model from database map
  factory MaterialTypeModel.fromMap(Map<String, dynamic> map) {
    return MaterialTypeModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      code: map['code'] as String,
      isActive: map['is_active'] == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
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

class MaterialSizeModel extends Equatable {
  final int? id;
  final String name;
  final String code;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  const MaterialSizeModel({
    this.id,
    required this.name,
    required this.code,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });
  
  // Create a copy of this model with given fields replaced with new values
  MaterialSizeModel copyWith({
    int? id,
    String? name,
    String? code,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MaterialSizeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
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
      'code': code,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  // Create model from JSON
  factory MaterialSizeModel.fromJson(Map<String, dynamic> json) {
    return MaterialSizeModel(
      id: json['id'] as int?,
      name: json['name'] as String,
      code: json['code'] as String,
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
      'code': code,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  // Create model from database map
  factory MaterialSizeModel.fromMap(Map<String, dynamic> map) {
    return MaterialSizeModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      code: map['code'] as String,
      isActive: map['is_active'] == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
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
    return 'MaterialSizeModel(id: $id, name: $name, code: $code)';
  }
}

class TaxConfigurationModel extends Equatable {
  final int? id;
  final String name;
  final String hsnCode;
  final double cgstPercentage;
  final double sgstPercentage;
  final double igstPercentage;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  const TaxConfigurationModel({
    this.id,
    required this.name,
    required this.hsnCode,
    required this.cgstPercentage,
    required this.sgstPercentage,
    required this.igstPercentage,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });
  
  // Create a copy of this model with given fields replaced with new values
  TaxConfigurationModel copyWith({
    int? id,
    String? name,
    String? hsnCode,
    double? cgstPercentage,
    double? sgstPercentage,
    double? igstPercentage,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaxConfigurationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      hsnCode: hsnCode ?? this.hsnCode,
      cgstPercentage: cgstPercentage ?? this.cgstPercentage,
      sgstPercentage: sgstPercentage ?? this.sgstPercentage,
      igstPercentage: igstPercentage ?? this.igstPercentage,
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
      'hsn_code': hsnCode,
      'cgst_percentage': cgstPercentage,
      'sgst_percentage': sgstPercentage,
      'igst_percentage': igstPercentage,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  // Create model from JSON
  factory TaxConfigurationModel.fromJson(Map<String, dynamic> json) {
    return TaxConfigurationModel(
      id: json['id'] as int?,
      name: json['name'] as String,
      hsnCode: json['hsn_code'] as String,
      cgstPercentage: json['cgst_percentage'] as double,
      sgstPercentage: json['sgst_percentage'] as double,
      igstPercentage: json['igst_percentage'] as double,
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
      'hsn_code': hsnCode,
      'cgst_percentage': cgstPercentage,
      'sgst_percentage': sgstPercentage,
      'igst_percentage': igstPercentage,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  // Create model from database map
  factory TaxConfigurationModel.fromMap(Map<String, dynamic> map) {
    return TaxConfigurationModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      hsnCode: map['hsn_code'] as String,
      cgstPercentage: map['cgst_percentage'] as double,
      sgstPercentage: map['sgst_percentage'] as double,
      igstPercentage: map['igst_percentage'] as double,
      isActive: map['is_active'] == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
  
  @override
  List<Object?> get props => [
    id,
    name,
    hsnCode,
    cgstPercentage,
    sgstPercentage,
    igstPercentage,
    isActive,
    createdAt,
    updatedAt,
  ];
  
  @override
  String toString() {
    return 'TaxConfigurationModel(id: $id, name: $name, hsnCode: $hsnCode)';
  }
}

