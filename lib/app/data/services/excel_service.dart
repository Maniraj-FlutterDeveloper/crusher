import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../models/gate_entry_model.dart';
import '../models/invoice_model.dart';
import '../models/material_loading_model.dart';
import '../../core/values/app_constants.dart';

class ExcelService {
  // Generate a daily vehicle log report
  Future<String> generateDailyVehicleLogReport(
    List<GateEntryModel> gateEntries,
    DateTime date,
  ) async {
    final excel = Excel.createExcel();
    final sheet = excel['Daily Vehicle Log'];
    
    // Add header
    sheet.appendRow([
      TextCellValue('Daily Vehicle Log Report'),
    ]);
    sheet.appendRow([
      TextCellValue('Date: ${DateFormat(AppConstants.dateFormat).format(date)}'),
    ]);
    sheet.appendRow([]);
    
    // Add column headers
    sheet.appendRow([
      TextCellValue('Session ID'),
      TextCellValue('Vehicle Number'),
      TextCellValue('Driver Name'),
      TextCellValue('Entry Time'),
      TextCellValue('Exit Time'),
      TextCellValue('Tare Weight'),
      TextCellValue('Gross Weight'),
      TextCellValue('Net Weight'),
      TextCellValue('Status'),
    ]);
    
    // Add data rows
    for (final entry in gateEntries) {
      sheet.appendRow([
        TextCellValue(entry.sessionId),
        TextCellValue(entry.vehicle?.vehicleNumber ?? 'N/A'),
        TextCellValue(entry.driverName ?? 'N/A'),
        TextCellValue(entry.entryTime != null 
          ? DateFormat(AppConstants.dateTimeFormat).format(entry.entryTime!) 
          : 'N/A'),
        TextCellValue(entry.exitTime != null 
          ? DateFormat(AppConstants.dateTimeFormat).format(entry.exitTime!) 
          : 'N/A'),
        TextCellValue(entry.tareWeight != null 
          ? '${entry.tareWeight} ${entry.weightUnit?.code ?? ''}' 
          : 'N/A'),
        TextCellValue(entry.grossWeight != null 
          ? '${entry.grossWeight} ${entry.weightUnit?.code ?? ''}' 
          : 'N/A'),
        TextCellValue(entry.netWeight != null 
          ? '${entry.netWeight} ${entry.weightUnit?.code ?? ''}' 
          : 'N/A'),
        TextCellValue(entry.status),
      ]);
    }
    
    // Auto fit columns
    for (int i = 0; i < 9; i++) {
      sheet.setColumnAutoFit(i);
    }
    
    // Save the file
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'daily_vehicle_log_${DateFormat('yyyyMMdd').format(date)}.xlsx';
    final filePath = '${directory.path}/$fileName';
    
    final fileBytes = excel.encode();
    if (fileBytes != null) {
      final file = File(filePath);
      await file.writeAsBytes(fileBytes);
    }
    
    return filePath;
  }
  
  // Generate a buyer-wise sales report
  Future<String> generateBuyerWiseSalesReport(
    List<InvoiceModel> invoices,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final excel = Excel.createExcel();
    final sheet = excel['Buyer-wise Sales'];
    
    // Add header
    sheet.appendRow([
      TextCellValue('Buyer-wise Sales Report'),
    ]);
    sheet.appendRow([
      TextCellValue('Period: ${DateFormat(AppConstants.dateFormat).format(startDate)} to ${DateFormat(AppConstants.dateFormat).format(endDate)}'),
    ]);
    sheet.appendRow([]);
    
    // Add column headers
    sheet.appendRow([
      TextCellValue('Buyer Name'),
      TextCellValue('Invoice Count'),
      TextCellValue('Total Amount'),
      TextCellValue('CGST Amount'),
      TextCellValue('SGST Amount'),
      TextCellValue('IGST Amount'),
      TextCellValue('Net Amount'),
    ]);
    
    // Group invoices by buyer
    final buyerMap = <int, Map<String, dynamic>>{};
    
    for (final invoice in invoices) {
      if (invoice.buyerId != null && invoice.buyer != null) {
        if (!buyerMap.containsKey(invoice.buyerId)) {
          buyerMap[invoice.buyerId!] = {
            'name': invoice.buyer!.name,
            'invoiceCount': 0,
            'totalAmount': 0.0,
            'cgstAmount': 0.0,
            'sgstAmount': 0.0,
            'igstAmount': 0.0,
            'netAmount': 0.0,
          };
        }
        
        buyerMap[invoice.buyerId!]['invoiceCount'] += 1;
        buyerMap[invoice.buyerId!]['totalAmount'] += invoice.baseAmount;
        buyerMap[invoice.buyerId!]['cgstAmount'] += invoice.cgstAmount;
        buyerMap[invoice.buyerId!]['sgstAmount'] += invoice.sgstAmount;
        buyerMap[invoice.buyerId!]['igstAmount'] += invoice.igstAmount;
        buyerMap[invoice.buyerId!]['netAmount'] += invoice.totalAmount;
      }
    }
    
    // Add data rows
    for (final buyerId in buyerMap.keys) {
      final buyer = buyerMap[buyerId]!;
      
      sheet.appendRow([
        TextCellValue(buyer['name']),
        IntCellValue(buyer['invoiceCount']),
        DoubleCellValue(buyer['totalAmount']),
        DoubleCellValue(buyer['cgstAmount']),
        DoubleCellValue(buyer['sgstAmount']),
        DoubleCellValue(buyer['igstAmount']),
        DoubleCellValue(buyer['netAmount']),
      ]);
    }
    
    // Add total row
    int totalInvoiceCount = 0;
    double totalAmount = 0.0;
    double totalCgst = 0.0;
    double totalSgst = 0.0;
    double totalIgst = 0.0;
    double totalNetAmount = 0.0;
    
    for (final buyer in buyerMap.values) {
      totalInvoiceCount += buyer['invoiceCount'] as int;
      totalAmount += buyer['totalAmount'] as double;
      totalCgst += buyer['cgstAmount'] as double;
      totalSgst += buyer['sgstAmount'] as double;
      totalIgst += buyer['igstAmount'] as double;
      totalNetAmount += buyer['netAmount'] as double;
    }
    
    sheet.appendRow([]);
    sheet.appendRow([
      TextCellValue('Total'),
      IntCellValue(totalInvoiceCount),
      DoubleCellValue(totalAmount),
      DoubleCellValue(totalCgst),
      DoubleCellValue(totalSgst),
      DoubleCellValue(totalIgst),
      DoubleCellValue(totalNetAmount),
    ]);
    
    // Auto fit columns
    for (int i = 0; i < 7; i++) {
      sheet.setColumnAutoFit(i);
    }
    
    // Save the file
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'buyer_wise_sales_${DateFormat('yyyyMMdd').format(startDate)}_${DateFormat('yyyyMMdd').format(endDate)}.xlsx';
    final filePath = '${directory.path}/$fileName';
    
    final fileBytes = excel.encode();
    if (fileBytes != null) {
      final file = File(filePath);
      await file.writeAsBytes(fileBytes);
    }
    
    return filePath;
  }
  
  // Generate a supplier-wise purchase report
  Future<String> generateSupplierWisePurchaseReport(
    List<MaterialLoadingModel> loadings,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final excel = Excel.createExcel();
    final sheet = excel['Supplier-wise Purchase'];
    
    // Add header
    sheet.appendRow([
      TextCellValue('Supplier-wise Purchase Report'),
    ]);
    sheet.appendRow([
      TextCellValue('Period: ${DateFormat(AppConstants.dateFormat).format(startDate)} to ${DateFormat(AppConstants.dateFormat).format(endDate)}'),
    ]);
    sheet.appendRow([]);
    
    // Add column headers
    sheet.appendRow([
      TextCellValue('Supplier Name'),
      TextCellValue('Material'),
      TextCellValue('Size'),
      TextCellValue('Quantity'),
      TextCellValue('Unit'),
      TextCellValue('Status'),
    ]);
    
    // Group loadings by supplier
    final supplierMap = <int, Map<String, dynamic>>{};
    
    for (final loading in loadings) {
      if (loading.supplierId != null && loading.supplier != null) {
        final key = '${loading.supplierId}_${loading.materialId}_${loading.materialSizeId ?? 0}';
        
        if (!supplierMap.containsKey(key)) {
          supplierMap[key] = {
            'supplierName': loading.supplier!.name,
            'materialName': loading.material?.name ?? 'N/A',
            'sizeName': loading.materialSize?.name ?? 'N/A',
            'quantity': 0.0,
            'unit': loading.weightUnit?.code ?? '',
            'status': loading.status,
          };
        }
        
        supplierMap[key]['quantity'] += loading.quantity;
      }
    }
    
    // Add data rows
    for (final data in supplierMap.values) {
      sheet.appendRow([
        TextCellValue(data['supplierName']),
        TextCellValue(data['materialName']),
        TextCellValue(data['sizeName']),
        DoubleCellValue(data['quantity']),
        TextCellValue(data['unit']),
        TextCellValue(data['status']),
      ]);
    }
    
    // Auto fit columns
    for (int i = 0; i < 6; i++) {
      sheet.setColumnAutoFit(i);
    }
    
    // Save the file
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'supplier_wise_purchase_${DateFormat('yyyyMMdd').format(startDate)}_${DateFormat('yyyyMMdd').format(endDate)}.xlsx';
    final filePath = '${directory.path}/$fileName';
    
    final fileBytes = excel.encode();
    if (fileBytes != null) {
      final file = File(filePath);
      await file.writeAsBytes(fileBytes);
    }
    
    return filePath;
  }
  
  // Generate a material movement report
  Future<String> generateMaterialMovementReport(
    List<MaterialLoadingModel> loadings,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final excel = Excel.createExcel();
    final sheet = excel['Material Movement'];
    
    // Add header
    sheet.appendRow([
      TextCellValue('Material Movement Report'),
    ]);
    sheet.appendRow([
      TextCellValue('Period: ${DateFormat(AppConstants.dateFormat).format(startDate)} to ${DateFormat(AppConstants.dateFormat).format(endDate)}'),
    ]);
    sheet.appendRow([]);
    
    // Add column headers
    sheet.appendRow([
      TextCellValue('Material'),
      TextCellValue('Size'),
      TextCellValue('Purpose'),
      TextCellValue('Quantity'),
      TextCellValue('Unit'),
      TextCellValue('Status'),
    ]);
    
    // Group loadings by material
    final materialMap = <String, Map<String, dynamic>>{};
    
    for (final loading in loadings) {
      final key = '${loading.materialId}_${loading.materialSizeId ?? 0}_${loading.purpose}';
      
      if (!materialMap.containsKey(key)) {
        materialMap[key] = {
          'materialName': loading.material?.name ?? 'N/A',
          'sizeName': loading.materialSize?.name ?? 'N/A',
          'purpose': loading.purpose,
          'quantity': 0.0,
          'unit': loading.weightUnit?.code ?? '',
          'status': loading.status,
        };
      }
      
      materialMap[key]['quantity'] += loading.quantity;
    }
    
    // Add data rows
    for (final data in materialMap.values) {
      sheet.appendRow([
        TextCellValue(data['materialName']),
        TextCellValue(data['sizeName']),
        TextCellValue(data['purpose']),
        DoubleCellValue(data['quantity']),
        TextCellValue(data['unit']),
        TextCellValue(data['status']),
      ]);
    }
    
    // Auto fit columns
    for (int i = 0; i < 6; i++) {
      sheet.setColumnAutoFit(i);
    }
    
    // Save the file
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'material_movement_${DateFormat('yyyyMMdd').format(startDate)}_${DateFormat('yyyyMMdd').format(endDate)}.xlsx';
    final filePath = '${directory.path}/$fileName';
    
    final fileBytes = excel.encode();
    if (fileBytes != null) {
      final file = File(filePath);
      await file.writeAsBytes(fileBytes);
    }
    
    return filePath;
  }
  
  // Generate a tax report
  Future<String> generateTaxReport(
    List<InvoiceModel> invoices,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final excel = Excel.createExcel();
    final sheet = excel['Tax Report'];
    
    // Add header
    sheet.appendRow([
      TextCellValue('Tax Report'),
    ]);
    sheet.appendRow([
      TextCellValue('Period: ${DateFormat(AppConstants.dateFormat).format(startDate)} to ${DateFormat(AppConstants.dateFormat).format(endDate)}'),
    ]);
    sheet.appendRow([]);
    
    // Add column headers
    sheet.appendRow([
      TextCellValue('Invoice Number'),
      TextCellValue('Invoice Date'),
      TextCellValue('Buyer Name'),
      TextCellValue('GSTIN'),
      TextCellValue('Base Amount'),
      TextCellValue('CGST Amount'),
      TextCellValue('SGST Amount'),
      TextCellValue('IGST Amount'),
      TextCellValue('Total Amount'),
    ]);
    
    // Add data rows
    for (final invoice in invoices) {
      if (invoice.status == AppConstants.invoiceStatusFinal) {
        sheet.appendRow([
          TextCellValue(invoice.invoiceNumber),
          TextCellValue(DateFormat(AppConstants.dateFormat).format(invoice.invoiceDate)),
          TextCellValue(invoice.buyer?.name ?? 'N/A'),
          TextCellValue(invoice.buyer?.gstin ?? 'N/A'),
          DoubleCellValue(invoice.baseAmount),
          DoubleCellValue(invoice.cgstAmount),
          DoubleCellValue(invoice.sgstAmount),
          DoubleCellValue(invoice.igstAmount),
          DoubleCellValue(invoice.totalAmount),
        ]);
      }
    }
    
    // Add total row
    double totalBaseAmount = 0.0;
    double totalCgst = 0.0;
    double totalSgst = 0.0;
    double totalIgst = 0.0;
    double totalAmount = 0.0;
    
    for (final invoice in invoices) {
      if (invoice.status == AppConstants.invoiceStatusFinal) {
        totalBaseAmount += invoice.baseAmount;
        totalCgst += invoice.cgstAmount;
        totalSgst += invoice.sgstAmount;
        totalIgst += invoice.igstAmount;
        totalAmount += invoice.totalAmount;
      }
    }
    
    sheet.appendRow([]);
    sheet.appendRow([
      TextCellValue('Total'),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
      DoubleCellValue(totalBaseAmount),
      DoubleCellValue(totalCgst),
      DoubleCellValue(totalSgst),
      DoubleCellValue(totalIgst),
      DoubleCellValue(totalAmount),
    ]);
    
    // Auto fit columns
    for (int i = 0; i < 9; i++) {
      sheet.setColumnAutoFit(i);
    }
    
    // Save the file
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'tax_report_${DateFormat('yyyyMMdd').format(startDate)}_${DateFormat('yyyyMMdd').format(endDate)}.xlsx';
    final filePath = '${directory.path}/$fileName';
    
    final fileBytes = excel.encode();
    if (fileBytes != null) {
      final file = File(filePath);
      await file.writeAsBytes(fileBytes);
    }
    
    return filePath;
  }
}

