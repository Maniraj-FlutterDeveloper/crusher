import 'package:crusher_management/app/data/models/material_size_model.dart';
import 'package:crusher_management/app/data/models/user_model.dart';
import 'package:crusher_management/app/data/models/weighbridge_record_model.dart';
import 'package:get/get.dart';
import '../models/invoice_model.dart';
import '../models/material_model.dart';
import '../models/material_loading_model.dart';
import '../models/gate_entry_model.dart';
import '../providers/db_provider.dart';

class InvoiceRepository {
  final DbProvider _dbProvider = Get.find<DbProvider>();
  
  // Get all invoices
  Future<List<InvoiceModel>> getAllInvoices() async {
    final List<Map<String, dynamic>> maps = await _dbProvider.rawQuery('''
      SELECT i.*, ge.*, b.*, u.* FROM invoice i
      LEFT JOIN gate_entry ge ON i.gate_entry_id = ge.id
      LEFT JOIN buyer b ON i.buyer_id = b.id
      LEFT JOIN user u ON i.operator_id = u.id
      ORDER BY i.created_at DESC
    ''');
    
    return maps.map((map) {
      final invoice = InvoiceModel.fromMap({
        'id': map['id'],
        'invoice_number': map['invoice_number'],
        'invoice_date': map['invoice_date'],
        'gate_entry_id': map['gate_entry_id'],
        'buyer_id': map['buyer_id'],
        'base_amount': map['base_amount'],
        'cgst_amount': map['cgst_amount'],
        'sgst_amount': map['sgst_amount'],
        'igst_amount': map['igst_amount'],
        'total_amount': map['total_amount'],
        'status': map['status'],
        'operator_id': map['operator_id'],
        'remarks': map['remarks'],
        'created_at': map['created_at'],
        'updated_at': map['updated_at'],
      });
      
      // Extract gate entry data
      if (map['gate_entry_id'] != null) {
        final gateEntry = {
          'id': map['gate_entry_id'],
          'session_id': map['session_id'],
          'vehicle_id': map['vehicle_id'],
          'driver_name': map['driver_name'],
          'driver_mobile': map['driver_mobile'],
          'entry_time': map['entry_time'],
          'exit_time': map['exit_time'],
          'tare_weight': map['tare_weight'],
          'gross_weight': map['gross_weight'],
          'net_weight': map['net_weight'],
          'status': map['status'],
          'gate_pass_number': map['gate_pass_number'],
          'remarks': map['remarks'],
          'operator_id': map['operator_id'],
          'created_at': map['created_at'],
          'updated_at': map['updated_at'],
        };
        
        // Extract buyer data
        final buyer = map['buyer_id'] != null ? {
          'id': map['buyer_id'],
          'name': map['buyer_name'],
          'gstin': map['gstin'],
          'address': map['address'],
          'city': map['city'],
          'state': map['state'],
          'pincode': map['pincode'],
          'contact_person': map['contact_person'],
          'contact_mobile': map['contact_mobile'],
          'contact_email': map['contact_email'],
          'is_active': map['buyer_is_active'],
          'created_at': map['buyer_created_at'],
          'updated_at': map['buyer_updated_at'],
        } : null;
        
        // Extract operator data
        final operator = {
          'id': map['operator_id'],
          'username': map['username'],
          'name': map['user_name'],
          'email': map['email'],
          'mobile': map['mobile'],
          'is_active': map['user_is_active'],
          'last_login': map['last_login'],
          'created_at': map['user_created_at'],
          'updated_at': map['user_updated_at'],
        };
        
        return invoice.copyWith(
          gateEntry: gateEntry != null ? GateEntryModel.fromMap(gateEntry) : null,
          buyer: buyer != null ? BuyerModel.fromMap(buyer) : null,
          operator: operator != null ? UserModel.fromMap(operator) : null,
        );
      }
      
      return invoice;
    }).toList();
  }
  
  // Get invoice by id with items
  Future<InvoiceModel?> getInvoiceById(int id) async {
    final Map<String, dynamic>? map = await _dbProvider.getById('invoice', id);
    
    if (map != null) {
      final invoice = InvoiceModel.fromMap(map);
      
      // Get invoice items
      final List<Map<String, dynamic>> itemMaps = await _dbProvider.rawQuery('''
        SELECT ii.*, m.*, ms.*, wu.* FROM invoice_item ii
        LEFT JOIN material m ON ii.material_id = m.id
        LEFT JOIN material_size ms ON ii.material_size_id = ms.id
        LEFT JOIN weight_unit_type wu ON ii.weight_unit_id = wu.id
        WHERE ii.invoice_id = ?
      ''', [id]);
      
      final List<InvoiceItemModel> items = itemMaps.map((itemMap) {
        final invoiceItem = InvoiceItemModel.fromMap({
          'id': itemMap['id'],
          'invoice_id': itemMap['invoice_id'],
          'material_id': itemMap['material_id'],
          'material_size_id': itemMap['material_size_id'],
          'quantity': itemMap['quantity'],
          'weight_unit_id': itemMap['weight_unit_id'],
          'rate': itemMap['rate'],
          'amount': itemMap['amount'],
          'cgst_percentage': itemMap['cgst_percentage'],
          'sgst_percentage': itemMap['sgst_percentage'],
          'igst_percentage': itemMap['igst_percentage'],
          'cgst_amount': itemMap['cgst_amount'],
          'sgst_amount': itemMap['sgst_amount'],
          'igst_amount': itemMap['igst_amount'],
          'total_amount': itemMap['total_amount'],
          'created_at': itemMap['created_at'],
          'updated_at': itemMap['updated_at'],
        });
        
        // Extract material data
        final material = {
          'id': itemMap['material_id'],
          'name': itemMap['name'],
          'code': itemMap['code'],
          'material_type_id': itemMap['material_type_id'],
          'rate': itemMap['material_rate'],
          'tax_configuration_id': itemMap['tax_configuration_id'],
          'is_active': itemMap['is_active'],
          'created_at': itemMap['material_created_at'],
          'updated_at': itemMap['material_updated_at'],
        };
        
        // Extract material size data
        final materialSize = itemMap['material_size_id'] != null ? {
          'id': itemMap['material_size_id'],
          'name': itemMap['size_name'],
          'code': itemMap['size_code'],
          'is_active': itemMap['size_is_active'],
          'created_at': itemMap['size_created_at'],
          'updated_at': itemMap['size_updated_at'],
        } : null;
        
        // Extract weight unit data
        final weightUnit = {
          'id': itemMap['weight_unit_id'],
          'name': itemMap['unit_name'],
          'symbol': itemMap['unit_symbol'],
          'conversion_factor': itemMap['conversion_factor'],
          'is_active': itemMap['unit_is_active'],
          'created_at': itemMap['unit_created_at'],
          'updated_at': itemMap['unit_updated_at'],
        };
        
        return invoiceItem.copyWith(
          material: material != null ? MaterialModel.fromMap(material) : null,
          materialSize: materialSize != null ? MaterialSizeModel.fromMap(materialSize) : null,
          weightUnit: weightUnit != null ? WeightUnitModel.fromMap(weightUnit) : null,
        );
      }).toList();
      
      // Get gate entry
      if (invoice.gateEntryId != null) {
        final gateEntryMap = await _dbProvider.getById('gate_entry', invoice.gateEntryId!);
        
        if (gateEntryMap != null) {
          final gateEntry = GateEntryModel.fromMap(gateEntryMap);
          
          // Get buyer
          if (invoice.buyerId != null) {
            final buyerMap = await _dbProvider.getById('buyer', invoice.buyerId!);
            
            if (buyerMap != null) {
              final buyer = BuyerModel.fromMap(buyerMap);
              
              // Get operator
              final operatorMap = await _dbProvider.getById('user', invoice.operatorId);
              
              if (operatorMap != null) {
                final operator = UserModel.fromMap(operatorMap);
                
                return invoice.copyWith(
                  gateEntry: gateEntry,
                  buyer: buyer,
                  operator: operator,
                  items: items,
                );
              }
            }
          }
          
          return invoice.copyWith(
            gateEntry: gateEntry,
            items: items,
          );
        }
      }
      
      return invoice.copyWith(
        items: items,
      );
    }
    
    return null;
  }
  
  // Get invoice by invoice number
  Future<InvoiceModel?> getInvoiceByInvoiceNumber(String invoiceNumber) async {
    final List<Map<String, dynamic>> maps = await _dbProvider.query(
      'invoice',
      where: 'invoice_number = ?',
      whereArgs: [invoiceNumber],
    );
    
    if (maps.isNotEmpty) {
      return getInvoiceById(maps.first['id'] as int);
    }
    
    return null;
  }
  
  // Get invoices by gate entry
  Future<List<InvoiceModel>> getInvoicesByGateEntry(int gateEntryId) async {
    final List<Map<String, dynamic>> maps = await _dbProvider.query(
      'invoice',
      where: 'gate_entry_id = ?',
      whereArgs: [gateEntryId],
      orderBy: 'created_at DESC',
    );
    
    return Future.wait(maps.map((map) async {
      return (await getInvoiceById(map['id'] as int))!;
    }).toList());
  }
  
  // Get invoices by buyer
  Future<List<InvoiceModel>> getInvoicesByBuyer(int buyerId) async {
    final List<Map<String, dynamic>> maps = await _dbProvider.query(
      'invoice',
      where: 'buyer_id = ?',
      whereArgs: [buyerId],
      orderBy: 'created_at DESC',
    );
    
    return Future.wait(maps.map((map) async {
      return (await getInvoiceById(map['id'] as int))!;
    }).toList());
  }
  
  // Get invoices by status
  Future<List<InvoiceModel>> getInvoicesByStatus(String status) async {
    final List<Map<String, dynamic>> maps = await _dbProvider.query(
      'invoice',
      where: 'status = ?',
      whereArgs: [status],
      orderBy: 'created_at DESC',
    );
    
    return Future.wait(maps.map((map) async {
      return (await getInvoiceById(map['id'] as int))!;
    }).toList());
  }
  
  // Get invoices by date range
  Future<List<InvoiceModel>> getInvoicesByDateRange(DateTime startDate, DateTime endDate) async {
    final List<Map<String, dynamic>> maps = await _dbProvider.query(
      'invoice',
      where: 'invoice_date BETWEEN ? AND ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
      orderBy: 'created_at DESC',
    );
    
    return Future.wait(maps.map((map) async {
      return (await getInvoiceById(map['id'] as int))!;
    }).toList());
  }
  
  // Insert invoice
  Future<int> insertInvoice(InvoiceModel invoice) async {
    return await _dbProvider.transaction((txn) async {
      // Insert invoice
      final invoiceId = await txn.insert('invoice', invoice.toMap());
      
      // Insert invoice items
      if (invoice.items != null) {
        for (final item in invoice.items!) {
          await txn.insert('invoice_item', item.copyWith(invoiceId: invoiceId).toMap());
        }
      }
      
      return invoiceId;
    });
  }
  
  // Update invoice
  Future<int> updateInvoice(InvoiceModel invoice) async {
    return await _dbProvider.transaction((txn) async {
      // Update invoice
      await txn.update('invoice', invoice.toMap(), invoice.id!);
      
      // Delete existing invoice items
      await txn.delete('invoice_item', invoice.id!, columnName: 'invoice_id');
      
      // Insert new invoice items
      if (invoice.items != null) {
        for (final item in invoice.items!) {
          await txn.insert('invoice_item', item.copyWith(invoiceId: invoice.id!).toMap());
        }
      }
      
      return invoice.id!;
    });
  }
  
  // Delete invoice
  Future<int> deleteInvoice(int id) async {
    return await _dbProvider.transaction((txn) async {
      // Delete invoice items
      await txn.delete('invoice_item', id, columnName: 'invoice_id');
      
      // Delete invoice
      return await txn.delete('invoice', id);
    });
  }
  
  // Update invoice status
  Future<int> updateInvoiceStatus(int id, String status) async {
    return await _dbProvider.update(
      'invoice',
      {
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      },
      id,
    );
  }
  
  // Generate invoice number
  Future<String> generateInvoiceNumber() async {
    final DateTime now = DateTime.now();
    final String prefix = 'INV-${now.year}${now.month.toString().padLeft(2, '0')}';
    
    // Get the last invoice number with the same prefix
    final List<Map<String, dynamic>> maps = await _dbProvider.rawQuery(
      'SELECT invoice_number FROM invoice WHERE invoice_number LIKE ? ORDER BY id DESC LIMIT 1',
      ['$prefix%'],
    );
    
    if (maps.isNotEmpty) {
      final String lastInvoiceNumber = maps.first['invoice_number'] as String;
      final int lastNumber = int.parse(lastInvoiceNumber.split('-').last);
      return '$prefix-${(lastNumber + 1).toString().padLeft(4, '0')}';
    }
    
    return '$prefix-0001';
  }
  
  // Get all buyers
  Future<List<BuyerModel>> getAllBuyers() async {
    final List<Map<String, dynamic>> maps = await _dbProvider.query(
      'buyer',
      orderBy: 'name ASC',
    );
    return maps.map((map) => BuyerModel.fromMap(map)).toList();
  }
  
  // Get active buyers
  Future<List<BuyerModel>> getActiveBuyers() async {
    final List<Map<String, dynamic>> maps = await _dbProvider.query(
      'buyer',
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'name ASC',
    );
    return maps.map((map) => BuyerModel.fromMap(map)).toList();
  }
  
  // Get buyer by id
  Future<BuyerModel?> getBuyerById(int id) async {
    final Map<String, dynamic>? map = await _dbProvider.getById('buyer', id);
    if (map != null) {
      return BuyerModel.fromMap(map);
    }
    return null;
  }
  
  // Insert buyer
  Future<int> insertBuyer(BuyerModel buyer) async {
    return await _dbProvider.insert('buyer', buyer.toMap());
  }
  
  // Update buyer
  Future<int> updateBuyer(BuyerModel buyer) async {
    return await _dbProvider.update('buyer', buyer.toMap(), buyer.id!);
  }
  
  // Delete buyer
  Future<int> deleteBuyer(int id) async {
    return await _dbProvider.delete('buyer', id);
  }
  
  // Calculate invoice amounts
  InvoiceItemModel calculateInvoiceItemAmounts(
    InvoiceItemModel item,
    bool isSameState,
  ) {
    // Calculate base amount
    final amount = item.quantity * item.rate;
    
    // Calculate tax amounts
    double cgstAmount = 0;
    double sgstAmount = 0;
    double igstAmount = 0;
    
    if (isSameState) {
      // CGST and SGST for same state
      cgstAmount = amount * (item.cgstPercentage / 100);
      sgstAmount = amount * (item.sgstPercentage / 100);
    } else {
      // IGST for different state
      igstAmount = amount * (item.igstPercentage / 100);
    }
    
    // Calculate total amount
    final totalAmount = amount + cgstAmount + sgstAmount + igstAmount;
    
    return item.copyWith(
      amount: amount,
      cgstAmount: cgstAmount,
      sgstAmount: sgstAmount,
      igstAmount: igstAmount,
      totalAmount: totalAmount,
    );
  }
  
  // Calculate invoice total amounts
  InvoiceModel calculateInvoiceTotalAmounts(InvoiceModel invoice) {
    if (invoice.items == null || invoice.items!.isEmpty) {
      return invoice;
    }
    
    double baseAmount = 0;
    double cgstAmount = 0;
    double sgstAmount = 0;
    double igstAmount = 0;
    double totalAmount = 0;
    
    for (final item in invoice.items!) {
      baseAmount += item.amount;
      cgstAmount += item.cgstAmount;
      sgstAmount += item.sgstAmount;
      igstAmount += item.igstAmount;
      totalAmount += item.totalAmount;
    }
    
    return invoice.copyWith(
      baseAmount: baseAmount,
      cgstAmount: cgstAmount,
      sgstAmount: sgstAmount,
      igstAmount: igstAmount,
      totalAmount: totalAmount,
    );
  }
}

