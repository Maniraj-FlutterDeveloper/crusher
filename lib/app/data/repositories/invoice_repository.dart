import 'package:get/get.dart';
import '../models/invoice_model.dart';
import '../models/gate_entry_model.dart';
import '../providers/db_provider.dart';
import '../../core/values/app_constants.dart';

class InvoiceRepository {
  final DbProvider _dbProvider = Get.find<DbProvider>();
  
  // Get all invoices
  Future<List<InvoiceModel>> getAllInvoices() async {
    final List<Map<String, dynamic>> maps = await _dbProvider.getAll(
      'invoice',
      orderBy: 'invoice_date DESC',
    );
    return List.generate(maps.length, (i) {
      return InvoiceModel.fromMap(maps[i]);
    });
  }
  
  // Get invoices by status
  Future<List<InvoiceModel>> getInvoicesByStatus(String status) async {
    final List<Map<String, dynamic>> maps = await _dbProvider.getInvoicesByStatus(status);
    return List.generate(maps.length, (i) {
      return InvoiceModel.fromMap(maps[i]);
    });
  }
  
  // Get invoices by buyer
  Future<List<InvoiceModel>> getInvoicesByBuyer(int buyerId) async {
    final List<Map<String, dynamic>> maps = await _dbProvider.getInvoicesByBuyer(buyerId);
    return List.generate(maps.length, (i) {
      return InvoiceModel.fromMap(maps[i]);
    });
  }
  
  // Get invoice by id
  Future<InvoiceModel?> getInvoiceById(int id) async {
    final Map<String, dynamic>? map = await _dbProvider.getById('invoice', id);
    if (map != null) {
      return InvoiceModel.fromMap(map);
    }
    return null;
  }
  
  // Get invoice by invoice number
  Future<InvoiceModel?> getInvoiceByInvoiceNumber(String invoiceNumber) async {
    final List<Map<String, dynamic>> maps = await _dbProvider.getAll(
      'invoice',
      where: 'invoice_number = ?',
      whereArgs: [invoiceNumber],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return InvoiceModel.fromMap(maps.first);
    }
    return null;
  }
  
  // Get invoice with items
  Future<InvoiceModel?> getInvoiceWithItems(int id) async {
    final Map<String, dynamic>? invoiceMap = await _dbProvider.getInvoiceWithItems(id);
    if (invoiceMap != null) {
      final InvoiceModel invoice = InvoiceModel.fromMap(invoiceMap);
      if (invoiceMap['items'] != null) {
        final List<InvoiceItemModel> items = [];
        for (var itemMap in invoiceMap['items']) {
          items.add(InvoiceItemModel.fromMap(itemMap));
        }
        return invoice.copyWith(items: items);
      }
      return invoice;
    }
    return null;
  }
  
  // Get invoice with gate entry
  Future<InvoiceModel?> getInvoiceWithGateEntry(int id) async {
    final InvoiceModel? invoice = await getInvoiceById(id);
    if (invoice != null) {
      final Map<String, dynamic>? gateEntryMap = await _dbProvider.getById('gate_entry', invoice.gateEntryId);
      if (gateEntryMap != null) {
        final GateEntryModel gateEntry = GateEntryModel.fromMap(gateEntryMap);
        return invoice.copyWith(gateEntry: gateEntry);
      }
      return invoice;
    }
    return null;
  }
  
  // Insert invoice
  Future<int> insertInvoice(InvoiceModel invoice) async {
    return await _dbProvider.transaction((txn) async {
      // Insert invoice
      final int invoiceId = await txn.insert('invoice', invoice.toMap());
      
      // Insert invoice items
      if (invoice.items != null) {
        for (var item in invoice.items!) {
          final Map<String, dynamic> itemMap = item.toMap();
          itemMap['invoice_id'] = invoiceId;
          await txn.insert('invoice_item', itemMap);
        }
      }
      
      return invoiceId;
    });
  }
  
  // Update invoice
  Future<int> updateInvoice(InvoiceModel invoice) async {
    return await _dbProvider.transaction((txn) async {
      // Update invoice
      await txn.update('invoice', invoice.toMap(), where: 'id = ?', whereArgs: [invoice.id]);
      
      // Delete existing invoice items
      await txn.delete('invoice_item', where: 'invoice_id = ?', whereArgs: [invoice.id]);
      
      // Insert new invoice items
      if (invoice.items != null) {
        for (var item in invoice.items!) {
          final Map<String, dynamic> itemMap = item.toMap();
          itemMap['invoice_id'] = invoice.id;
          await txn.insert('invoice_item', itemMap);
        }
      }
      
      return invoice.id!;
    });
  }
  
  // Delete invoice
  Future<int> deleteInvoice(int id) async {
    return await _dbProvider.transaction((txn) async {
      // Delete invoice items
      await txn.delete('invoice_item', where: 'invoice_id = ?', whereArgs: [id]);
      
      // Delete invoice
      return await txn.delete('invoice', where: 'id = ?', whereArgs: [id]);
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
    final String datePrefix = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    
    final List<Map<String, dynamic>> result = await _dbProvider.rawQuery(
      'SELECT COUNT(*) as count FROM invoice WHERE invoice_number LIKE ?',
      ['INV$datePrefix%'],
    );
    
    final int count = result.first['count'] as int;
    final String suffix = (count + 1).toString().padLeft(4, '0');
    
    return 'INV$datePrefix$suffix';
  }
  
  // Get daily invoices
  Future<List<InvoiceModel>> getDailyInvoices(DateTime date) async {
    final String dateString = date.toString().split(' ')[0];
    
    final List<Map<String, dynamic>> maps = await _dbProvider.rawQuery(
      'SELECT * FROM invoice WHERE date(invoice_date) = ? ORDER BY invoice_date DESC',
      [dateString],
    );
    
    return List.generate(maps.length, (i) {
      return InvoiceModel.fromMap(maps[i]);
    });
  }
  
  // Get total revenue for a day
  Future<double> getTotalRevenueForDay(DateTime date) async {
    final String dateString = date.toString().split(' ')[0];
    
    final List<Map<String, dynamic>> result = await _dbProvider.rawQuery(
      'SELECT SUM(total_amount) as total FROM invoice WHERE date(invoice_date) = ?',
      [dateString],
    );
    
    if (result.first['total'] != null) {
      return result.first['total'] as double;
    }
    
    return 0.0;
  }
  
  // Get total revenue
  Future<double> getTotalRevenue() async {
    final List<Map<String, dynamic>> result = await _dbProvider.rawQuery(
      'SELECT SUM(total_amount) as total FROM invoice',
    );
    
    if (result.first['total'] != null) {
      return result.first['total'] as double;
    }
    
    return 0.0;
  }
  
  // Get invoice count by status
  Future<int> getInvoiceCountByStatus(String status) async {
    final List<Map<String, dynamic>> result = await _dbProvider.rawQuery(
      'SELECT COUNT(*) as count FROM invoice WHERE status = ?',
      [status],
    );
    
    return result.first['count'] as int;
  }
  
  // Search invoices by invoice number
  Future<List<InvoiceModel>> searchInvoicesByInvoiceNumber(String query) async {
    final List<Map<String, dynamic>> maps = await _dbProvider.getAll(
      'invoice',
      where: 'invoice_number LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'invoice_date DESC',
    );
    
    return List.generate(maps.length, (i) {
      return InvoiceModel.fromMap(maps[i]);
    });
  }
  
  // Search invoices by buyer name
  Future<List<InvoiceModel>> searchInvoicesByBuyerName(String query) async {
    final List<Map<String, dynamic>> maps = await _dbProvider.rawQuery(
      '''
      SELECT i.* FROM invoice i
      JOIN buyer_master bm ON i.buyer_id = bm.id
      WHERE bm.name LIKE ?
      ORDER BY i.invoice_date DESC
      ''',
      ['%$query%'],
    );
    
    return List.generate(maps.length, (i) {
      return InvoiceModel.fromMap(maps[i]);
    });
  }
}

