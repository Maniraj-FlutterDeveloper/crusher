import 'package:equatable/equatable.dart';
import 'gate_entry_model.dart';
import 'material_model.dart';
import 'weighbridge_record_model.dart';
import 'user_model.dart';

class InvoiceModel extends Equatable {
  final int? id;
  final String invoiceNumber;
  final DateTime invoiceDate;
  final int? gateEntryId;
  final int? buyerId;
  final double baseAmount;
  final double cgstAmount;
  final double sgstAmount;
  final double igstAmount;
  final double totalAmount;
  final String status; // 'DRAFT', 'FINAL', 'CANCELLED'
  final int operatorId;
  final String? remarks;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Related models
  final GateEntryModel? gateEntry;
  final BuyerModel? buyer;
  final UserModel? operator;
  final List<InvoiceItemModel>? items;
  
  const InvoiceModel({
    this.id,
    required this.invoiceNumber,
    required this.invoiceDate,
    this.gateEntryId,
    this.buyerId,
    required this.baseAmount,
    required this.cgstAmount,
    required this.sgstAmount,
    required this.igstAmount,
    required this.totalAmount,
    required this.status,
    required this.operatorId,
    this.remarks,
    required this.createdAt,
    required this.updatedAt,
    this.gateEntry,
    this.buyer,
    this.operator,
    this.items,
  });
  
  // Create a copy of this model with given fields replaced with new values
  InvoiceModel copyWith({
    int? id,
    String? invoiceNumber,
    DateTime? invoiceDate,
    int? gateEntryId,
    int? buyerId,
    double? baseAmount,
    double? cgstAmount,
    double? sgstAmount,
    double? igstAmount,
    double? totalAmount,
    String? status,
    int? operatorId,
    String? remarks,
    DateTime? createdAt,
    DateTime? updatedAt,
    GateEntryModel? gateEntry,
    BuyerModel? buyer,
    UserModel? operator,
    List<InvoiceItemModel>? items,
  }) {
    return InvoiceModel(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      gateEntryId: gateEntryId ?? this.gateEntryId,
      buyerId: buyerId ?? this.buyerId,
      baseAmount: baseAmount ?? this.baseAmount,
      cgstAmount: cgstAmount ?? this.cgstAmount,
      sgstAmount: sgstAmount ?? this.sgstAmount,
      igstAmount: igstAmount ?? this.igstAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      operatorId: operatorId ?? this.operatorId,
      remarks: remarks ?? this.remarks,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      gateEntry: gateEntry ?? this.gateEntry,
      buyer: buyer ?? this.buyer,
      operator: operator ?? this.operator,
      items: items ?? this.items,
    );
  }
  
  // Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoice_number': invoiceNumber,
      'invoice_date': invoiceDate.toIso8601String(),
      'gate_entry_id': gateEntryId,
      'buyer_id': buyerId,
      'base_amount': baseAmount,
      'cgst_amount': cgstAmount,
      'sgst_amount': sgstAmount,
      'igst_amount': igstAmount,
      'total_amount': totalAmount,
      'status': status,
      'operator_id': operatorId,
      'remarks': remarks,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'gate_entry': gateEntry?.toJson(),
      'buyer': buyer?.toJson(),
      'operator': operator?.toJson(),
      'items': items?.map((item) => item.toJson()).toList(),
    };
  }
  
  // Create model from JSON
  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      id: json['id'] as int?,
      invoiceNumber: json['invoice_number'] as String,
      invoiceDate: DateTime.parse(json['invoice_date'] as String),
      gateEntryId: json['gate_entry_id'] as int?,
      buyerId: json['buyer_id'] as int?,
      baseAmount: json['base_amount'] as double,
      cgstAmount: json['cgst_amount'] as double,
      sgstAmount: json['sgst_amount'] as double,
      igstAmount: json['igst_amount'] as double,
      totalAmount: json['total_amount'] as double,
      status: json['status'] as String,
      operatorId: json['operator_id'] as int,
      remarks: json['remarks'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      gateEntry: json['gate_entry'] != null ? GateEntryModel.fromJson(json['gate_entry'] as Map<String, dynamic>) : null,
      buyer: json['buyer'] != null ? BuyerModel.fromJson(json['buyer'] as Map<String, dynamic>) : null,
      operator: json['operator'] != null ? UserModel.fromJson(json['operator'] as Map<String, dynamic>) : null,
      items: json['items'] != null
          ? (json['items'] as List).map((item) => InvoiceItemModel.fromJson(item as Map<String, dynamic>)).toList()
          : null,
    );
  }
  
  // Convert model to map for database operations
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'invoice_number': invoiceNumber,
      'invoice_date': invoiceDate.toIso8601String(),
      'gate_entry_id': gateEntryId,
      'buyer_id': buyerId,
      'base_amount': baseAmount,
      'cgst_amount': cgstAmount,
      'sgst_amount': sgstAmount,
      'igst_amount': igstAmount,
      'total_amount': totalAmount,
      'status': status,
      'operator_id': operatorId,
      'remarks': remarks,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  // Create model from database map
  factory InvoiceModel.fromMap(Map<String, dynamic> map) {
    return InvoiceModel(
      id: map['id'] as int?,
      invoiceNumber: map['invoice_number'] as String,
      invoiceDate: DateTime.parse(map['invoice_date'] as String),
      gateEntryId: map['gate_entry_id'] as int?,
      buyerId: map['buyer_id'] as int?,
      baseAmount: map['base_amount'] as double,
      cgstAmount: map['cgst_amount'] as double,
      sgstAmount: map['sgst_amount'] as double,
      igstAmount: map['igst_amount'] as double,
      totalAmount: map['total_amount'] as double,
      status: map['status'] as String,
      operatorId: map['operator_id'] as int,
      remarks: map['remarks'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
  
  @override
  List<Object?> get props => [
    id,
    invoiceNumber,
    invoiceDate,
    gateEntryId,
    buyerId,
    baseAmount,
    cgstAmount,
    sgstAmount,
    igstAmount,
    totalAmount,
    status,
    operatorId,
    remarks,
    createdAt,
    updatedAt,
    gateEntry,
    buyer,
    operator,
    items,
  ];
  
  @override
  String toString() {
    return 'InvoiceModel(id: $id, invoiceNumber: $invoiceNumber, totalAmount: $totalAmount)';
  }
}

class InvoiceItemModel extends Equatable {
  final int? id;
  final int invoiceId;
  final int materialId;
  final int? materialSizeId;
  final double quantity;
  final int weightUnitId;
  final double rate;
  final double amount;
  final double cgstPercentage;
  final double sgstPercentage;
  final double igstPercentage;
  final double cgstAmount;
  final double sgstAmount;
  final double igstAmount;
  final double totalAmount;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Related models
  final MaterialModel? material;
  final MaterialSizeModel? materialSize;
  final WeightUnitModel? weightUnit;
  
  const InvoiceItemModel({
    this.id,
    required this.invoiceId,
    required this.materialId,
    this.materialSizeId,
    required this.quantity,
    required this.weightUnitId,
    required this.rate,
    required this.amount,
    required this.cgstPercentage,
    required this.sgstPercentage,
    required this.igstPercentage,
    required this.cgstAmount,
    required this.sgstAmount,
    required this.igstAmount,
    required this.totalAmount,
    required this.createdAt,
    required this.updatedAt,
    this.material,
    this.materialSize,
    this.weightUnit,
  });
  
  // Create a copy of this model with given fields replaced with new values
  InvoiceItemModel copyWith({
    int? id,
    int? invoiceId,
    int? materialId,
    int? materialSizeId,
    double? quantity,
    int? weightUnitId,
    double? rate,
    double? amount,
    double? cgstPercentage,
    double? sgstPercentage,
    double? igstPercentage,
    double? cgstAmount,
    double? sgstAmount,
    double? igstAmount,
    double? totalAmount,
    DateTime? createdAt,
    DateTime? updatedAt,
    MaterialModel? material,
    MaterialSizeModel? materialSize,
    WeightUnitModel? weightUnit,
  }) {
    return InvoiceItemModel(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      materialId: materialId ?? this.materialId,
      materialSizeId: materialSizeId ?? this.materialSizeId,
      quantity: quantity ?? this.quantity,
      weightUnitId: weightUnitId ?? this.weightUnitId,
      rate: rate ?? this.rate,
      amount: amount ?? this.amount,
      cgstPercentage: cgstPercentage ?? this.cgstPercentage,
      sgstPercentage: sgstPercentage ?? this.sgstPercentage,
      igstPercentage: igstPercentage ?? this.igstPercentage,
      cgstAmount: cgstAmount ?? this.cgstAmount,
      sgstAmount: sgstAmount ?? this.sgstAmount,
      igstAmount: igstAmount ?? this.igstAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      material: material ?? this.material,
      materialSize: materialSize ?? this.materialSize,
      weightUnit: weightUnit ?? this.weightUnit,
    );
  }
  
  // Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoice_id': invoiceId,
      'material_id': materialId,
      'material_size_id': materialSizeId,
      'quantity': quantity,
      'weight_unit_id': weightUnitId,
      'rate': rate,
      'amount': amount,
      'cgst_percentage': cgstPercentage,
      'sgst_percentage': sgstPercentage,
      'igst_percentage': igstPercentage,
      'cgst_amount': cgstAmount,
      'sgst_amount': sgstAmount,
      'igst_amount': igstAmount,
      'total_amount': totalAmount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'material': material?.toJson(),
      'material_size': materialSize?.toJson(),
      'weight_unit': weightUnit?.toJson(),
    };
  }
  
  // Create model from JSON
  factory InvoiceItemModel.fromJson(Map<String, dynamic> json) {
    return InvoiceItemModel(
      id: json['id'] as int?,
      invoiceId: json['invoice_id'] as int,
      materialId: json['material_id'] as int,
      materialSizeId: json['material_size_id'] as int?,
      quantity: json['quantity'] as double,
      weightUnitId: json['weight_unit_id'] as int,
      rate: json['rate'] as double,
      amount: json['amount'] as double,
      cgstPercentage: json['cgst_percentage'] as double,
      sgstPercentage: json['sgst_percentage'] as double,
      igstPercentage: json['igst_percentage'] as double,
      cgstAmount: json['cgst_amount'] as double,
      sgstAmount: json['sgst_amount'] as double,
      igstAmount: json['igst_amount'] as double,
      totalAmount: json['total_amount'] as double,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      material: json['material'] != null ? MaterialModel.fromJson(json['material'] as Map<String, dynamic>) : null,
      materialSize: json['material_size'] != null ? MaterialSizeModel.fromJson(json['material_size'] as Map<String, dynamic>) : null,
      weightUnit: json['weight_unit'] != null ? WeightUnitModel.fromJson(json['weight_unit'] as Map<String, dynamic>) : null,
    );
  }
  
  // Convert model to map for database operations
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'invoice_id': invoiceId,
      'material_id': materialId,
      'material_size_id': materialSizeId,
      'quantity': quantity,
      'weight_unit_id': weightUnitId,
      'rate': rate,
      'amount': amount,
      'cgst_percentage': cgstPercentage,
      'sgst_percentage': sgstPercentage,
      'igst_percentage': igstPercentage,
      'cgst_amount': cgstAmount,
      'sgst_amount': sgstAmount,
      'igst_amount': igstAmount,
      'total_amount': totalAmount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  // Create model from database map
  factory InvoiceItemModel.fromMap(Map<String, dynamic> map) {
    return InvoiceItemModel(
      id: map['id'] as int?,
      invoiceId: map['invoice_id'] as int,
      materialId: map['material_id'] as int,
      materialSizeId: map['material_size_id'] as int?,
      quantity: map['quantity'] as double,
      weightUnitId: map['weight_unit_id'] as int,
      rate: map['rate'] as double,
      amount: map['amount'] as double,
      cgstPercentage: map['cgst_percentage'] as double,
      sgstPercentage: map['sgst_percentage'] as double,
      igstPercentage: map['igst_percentage'] as double,
      cgstAmount: map['cgst_amount'] as double,
      sgstAmount: map['sgst_amount'] as double,
      igstAmount: map['igst_amount'] as double,
      totalAmount: map['total_amount'] as double,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
  
  @override
  List<Object?> get props => [
    id,
    invoiceId,
    materialId,
    materialSizeId,
    quantity,
    weightUnitId,
    rate,
    amount,
    cgstPercentage,
    sgstPercentage,
    igstPercentage,
    cgstAmount,
    sgstAmount,
    igstAmount,
    totalAmount,
    createdAt,
    updatedAt,
    material,
    materialSize,
    weightUnit,
  ];
  
  @override
  String toString() {
    return 'InvoiceItemModel(id: $id, materialId: $materialId, amount: $amount)';
  }
}

class BuyerModel extends Equatable {
  final int? id;
  final String name;
  final String? gstin;
  final String? address;
  final String? city;
  final String? state;
  final String? pincode;
  final String? contactPerson;
  final String? contactMobile;
  final String? contactEmail;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  const BuyerModel({
    this.id,
    required this.name,
    this.gstin,
    this.address,
    this.city,
    this.state,
    this.pincode,
    this.contactPerson,
    this.contactMobile,
    this.contactEmail,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });
  
  // Create a copy of this model with given fields replaced with new values
  BuyerModel copyWith({
    int? id,
    String? name,
    String? gstin,
    String? address,
    String? city,
    String? state,
    String? pincode,
    String? contactPerson,
    String? contactMobile,
    String? contactEmail,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BuyerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      gstin: gstin ?? this.gstin,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      contactPerson: contactPerson ?? this.contactPerson,
      contactMobile: contactMobile ?? this.contactMobile,
      contactEmail: contactEmail ?? this.contactEmail,
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
      'gstin': gstin,
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
      'contact_person': contactPerson,
      'contact_mobile': contactMobile,
      'contact_email': contactEmail,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  // Create model from JSON
  factory BuyerModel.fromJson(Map<String, dynamic> json) {
    return BuyerModel(
      id: json['id'] as int?,
      name: json['name'] as String,
      gstin: json['gstin'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      pincode: json['pincode'] as String?,
      contactPerson: json['contact_person'] as String?,
      contactMobile: json['contact_mobile'] as String?,
      contactEmail: json['contact_email'] as String?,
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
      'gstin': gstin,
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
      'contact_person': contactPerson,
      'contact_mobile': contactMobile,
      'contact_email': contactEmail,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  // Create model from database map
  factory BuyerModel.fromMap(Map<String, dynamic> map) {
    return BuyerModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      gstin: map['gstin'] as String?,
      address: map['address'] as String?,
      city: map['city'] as String?,
      state: map['state'] as String?,
      pincode: map['pincode'] as String?,
      contactPerson: map['contact_person'] as String?,
      contactMobile: map['contact_mobile'] as String?,
      contactEmail: map['contact_email'] as String?,
      isActive: map['is_active'] == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
  
  @override
  List<Object?> get props => [
    id,
    name,
    gstin,
    address,
    city,
    state,
    pincode,
    contactPerson,
    contactMobile,
    contactEmail,
    isActive,
    createdAt,
    updatedAt,
  ];
  
  @override
  String toString() {
    return 'BuyerModel(id: $id, name: $name, gstin: $gstin)';
  }
}

