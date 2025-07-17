import 'package:equatable/equatable.dart';
import 'gate_entry_model.dart';

class InvoiceModel extends Equatable {
  final int? id;
  final String invoiceNumber;
  final int gateEntryId;
  final int buyerId;
  final DateTime invoiceDate;
  final double baseAmount;
  final double cgstAmount;
  final double sgstAmount;
  final double igstAmount;
  final double totalAmount;
  final String status;
  final String? remarks;
  final int operatorId;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Related models
  final GateEntryModel? gateEntry;
  final List<InvoiceItemModel>? items;
  
  const InvoiceModel({
    this.id,
    required this.invoiceNumber,
    required this.gateEntryId,
    required this.buyerId,
    required this.invoiceDate,
    required this.baseAmount,
    required this.cgstAmount,
    required this.sgstAmount,
    required this.igstAmount,
    required this.totalAmount,
    required this.status,
    this.remarks,
    required this.operatorId,
    required this.createdAt,
    required this.updatedAt,
    this.gateEntry,
    this.items,
  });
  
  // Create a copy of this model with given fields replaced with new values
  InvoiceModel copyWith({
    int? id,
    String? invoiceNumber,
    int? gateEntryId,
    int? buyerId,
    DateTime? invoiceDate,
    double? baseAmount,
    double? cgstAmount,
    double? sgstAmount,
    double? igstAmount,
    double? totalAmount,
    String? status,
    String? remarks,
    int? operatorId,
    DateTime? createdAt,
    DateTime? updatedAt,
    GateEntryModel? gateEntry,
    List<InvoiceItemModel>? items,
  }) {
    return InvoiceModel(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      gateEntryId: gateEntryId ?? this.gateEntryId,
      buyerId: buyerId ?? this.buyerId,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      baseAmount: baseAmount ?? this.baseAmount,
      cgstAmount: cgstAmount ?? this.cgstAmount,
      sgstAmount: sgstAmount ?? this.sgstAmount,
      igstAmount: igstAmount ?? this.igstAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      remarks: remarks ?? this.remarks,
      operatorId: operatorId ?? this.operatorId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      gateEntry: gateEntry ?? this.gateEntry,
      items: items ?? this.items,
    );
  }
  
  // Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoice_number': invoiceNumber,
      'gate_entry_id': gateEntryId,
      'buyer_id': buyerId,
      'invoice_date': invoiceDate.toIso8601String(),
      'base_amount': baseAmount,
      'cgst_amount': cgstAmount,
      'sgst_amount': sgstAmount,
      'igst_amount': igstAmount,
      'total_amount': totalAmount,
      'status': status,
      'remarks': remarks,
      'operator_id': operatorId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'gate_entry': gateEntry?.toJson(),
      'items': items?.map((item) => item.toJson()).toList(),
    };
  }
  
  // Create model from JSON
  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      id: json['id'] as int?,
      invoiceNumber: json['invoice_number'] as String,
      gateEntryId: json['gate_entry_id'] as int,
      buyerId: json['buyer_id'] as int,
      invoiceDate: DateTime.parse(json['invoice_date'] as String),
      baseAmount: json['base_amount'] as double,
      cgstAmount: json['cgst_amount'] as double,
      sgstAmount: json['sgst_amount'] as double,
      igstAmount: json['igst_amount'] as double,
      totalAmount: json['total_amount'] as double,
      status: json['status'] as String,
      remarks: json['remarks'] as String?,
      operatorId: json['operator_id'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      gateEntry: json['gate_entry'] != null ? GateEntryModel.fromJson(json['gate_entry']) : null,
      items: json['items'] != null
          ? (json['items'] as List).map((itemJson) => InvoiceItemModel.fromJson(itemJson)).toList()
          : null,
    );
  }
  
  // Convert model to map for database operations
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'invoice_number': invoiceNumber,
      'gate_entry_id': gateEntryId,
      'buyer_id': buyerId,
      'invoice_date': invoiceDate.toIso8601String(),
      'base_amount': baseAmount,
      'cgst_amount': cgstAmount,
      'sgst_amount': sgstAmount,
      'igst_amount': igstAmount,
      'total_amount': totalAmount,
      'status': status,
      'remarks': remarks,
      'operator_id': operatorId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  // Create model from database map
  factory InvoiceModel.fromMap(Map<String, dynamic> map) {
    return InvoiceModel(
      id: map['id'] as int?,
      invoiceNumber: map['invoice_number'] as String,
      gateEntryId: map['gate_entry_id'] as int,
      buyerId: map['buyer_id'] as int,
      invoiceDate: DateTime.parse(map['invoice_date'] as String),
      baseAmount: map['base_amount'] as double,
      cgstAmount: map['cgst_amount'] as double,
      sgstAmount: map['sgst_amount'] as double,
      igstAmount: map['igst_amount'] as double,
      totalAmount: map['total_amount'] as double,
      status: map['status'] as String,
      remarks: map['remarks'] as String?,
      operatorId: map['operator_id'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
  
  @override
  List<Object?> get props => [
    id,
    invoiceNumber,
    gateEntryId,
    buyerId,
    invoiceDate,
    baseAmount,
    cgstAmount,
    sgstAmount,
    igstAmount,
    totalAmount,
    status,
    remarks,
    operatorId,
    createdAt,
    updatedAt,
    gateEntry,
    items,
  ];
  
  @override
  String toString() {
    return 'InvoiceModel(id: $id, invoiceNumber: $invoiceNumber, totalAmount: $totalAmount, status: $status)';
  }
}

class InvoiceItemModel extends Equatable {
  final int? id;
  final int invoiceId;
  final int materialId;
  final int? stoneSizeId;
  final double quantity;
  final int weightUnitId;
  final double rate;
  final double amount;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  const InvoiceItemModel({
    this.id,
    required this.invoiceId,
    required this.materialId,
    this.stoneSizeId,
    required this.quantity,
    required this.weightUnitId,
    required this.rate,
    required this.amount,
    required this.createdAt,
    required this.updatedAt,
  });
  
  // Create a copy of this model with given fields replaced with new values
  InvoiceItemModel copyWith({
    int? id,
    int? invoiceId,
    int? materialId,
    int? stoneSizeId,
    double? quantity,
    int? weightUnitId,
    double? rate,
    double? amount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InvoiceItemModel(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      materialId: materialId ?? this.materialId,
      stoneSizeId: stoneSizeId ?? this.stoneSizeId,
      quantity: quantity ?? this.quantity,
      weightUnitId: weightUnitId ?? this.weightUnitId,
      rate: rate ?? this.rate,
      amount: amount ?? this.amount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  // Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoice_id': invoiceId,
      'material_id': materialId,
      'stone_size_id': stoneSizeId,
      'quantity': quantity,
      'weight_unit_id': weightUnitId,
      'rate': rate,
      'amount': amount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  // Create model from JSON
  factory InvoiceItemModel.fromJson(Map<String, dynamic> json) {
    return InvoiceItemModel(
      id: json['id'] as int?,
      invoiceId: json['invoice_id'] as int,
      materialId: json['material_id'] as int,
      stoneSizeId: json['stone_size_id'] as int?,
      quantity: json['quantity'] as double,
      weightUnitId: json['weight_unit_id'] as int,
      rate: json['rate'] as double,
      amount: json['amount'] as double,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
  
  // Convert model to map for database operations
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'invoice_id': invoiceId,
      'material_id': materialId,
      'stone_size_id': stoneSizeId,
      'quantity': quantity,
      'weight_unit_id': weightUnitId,
      'rate': rate,
      'amount': amount,
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
      stoneSizeId: map['stone_size_id'] as int?,
      quantity: map['quantity'] as double,
      weightUnitId: map['weight_unit_id'] as int,
      rate: map['rate'] as double,
      amount: map['amount'] as double,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
  
  @override
  List<Object?> get props => [
    id,
    invoiceId,
    materialId,
    stoneSizeId,
    quantity,
    weightUnitId,
    rate,
    amount,
    createdAt,
    updatedAt,
  ];
  
  @override
  String toString() {
    return 'InvoiceItemModel(id: $id, materialId: $materialId, quantity: $quantity, amount: $amount)';
  }
}

