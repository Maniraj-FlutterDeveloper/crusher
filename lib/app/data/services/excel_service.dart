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
        TextCellValue(DateFormat(AppConstants.dateTimeFormat).format(entry.entryTime)),
        TextCellValue(entry.exitTime != null 
          ? DateFormat(AppConstants.dateTimeFormat).format(entry.exitTime!) 
          : 'N/A'),
        TextCellValue(entry.tareWeight != null 
          ? '${entry.tareWeight}' 
          : 'N/A'),
        TextCellValue(entry.grossWeight != null 
          ? '${entry.grossWeight}' 
          : 'N/A'),
        TextCellValue(entry.netWeight != null 
          ? '${entry.netWeight}' 
          : 'N/A'),
        TextCellValue(entry.status),
      ]);
    }
    
    // Auto fit columns
    for (int i = 0; i < 9; i++) {
      // Find the maximum content length in the column
      var maxLength = 0;
      for (var row in sheet.rows) {
        if (row.length > i && row[i] != null && row[i]?.value != null) {
          var contentLength = row[i]!.value.toString().length;
          if (contentLength > maxLength) {
            maxLength = contentLength;
          }
        }
      }
      // Set column width based on content length
      sheet.setColumnWidth(i, (maxLength + 2) * 1.2); // Adding some padding
    }
    
    // Save the file
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'daily_vehicle_log_${DateFormat('yyyyMMdd').format(date)}.xlsx';
    final filePath = '${directory.path}/$fileName';
    
    final fileBytes = excel.encode();
    if (fileBytes != null) {
      final file = File(filePath);
      await file.writeAsBytes(fileBytes);
    } else {
      throw Exception('Failed to encode Excel file');
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
        
        if (invoice.buyerId != null && buyerMap.containsKey(invoice.buyerId)) {
          buyerMap[invoice.buyerId]?['invoiceCount'] = (buyerMap[invoice.buyerId]?['invoiceCount'] ?? 0) + 1;
          buyerMap[invoice.buyerId]?['totalAmount'] = (buyerMap[invoice.buyerId]?['totalAmount'] ?? 0.0) + invoice.baseAmount;
          buyerMap[invoice.buyerId]?['cgstAmount'] = (buyerMap[invoice.buyerId]?['cgstAmount'] ?? 0.0) + invoice.cgstAmount;
          buyerMap[invoice.buyerId]?['sgstAmount'] = (buyerMap[invoice.buyerId]?['sgstAmount'] ?? 0.0) + invoice.sgstAmount;
          buyerMap[invoice.buyerId]?['igstAmount'] = (buyerMap[invoice.buyerId]?['igstAmount'] ?? 0.0) + invoice.igstAmount;
          buyerMap[invoice.buyerId]?['netAmount'] = (buyerMap[invoice.buyerId]?['netAmount'] ?? 0.0) + invoice.totalAmount;
        }
      }
    }
    
    // Add data rows
    for (final buyerId in buyerMap.keys) {
      final buyer = buyerMap[buyerId]!;
      
      sheet.appendRow([
        TextCellValue(buyer['name']),
        IntCellValue(buyer['invoiceCount']),
        TextCellValue(buyer['totalAmount'].toString()),
              TextCellValue(buyer['cgstAmount'].toString()),
              TextCellValue(buyer['sgstAmount'].toString()),
              TextCellValue(buyer['igstAmount'].toString()),
              TextCellValue(buyer['netAmount'].toString()),
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
      TextCellValue(totalAmount.toString()),
          TextCellValue(totalCgst.toString()),
          TextCellValue(totalSgst.toString()),
          TextCellValue(totalIgst.toString()),
          TextCellValue(totalNetAmount.toString()),
    ]);
    
    // Auto fit columns
    for (int i = 0; i < 7; i++) {
      // Find the maximum content length in the column
      var maxLength = 0;
      for (var row in sheet.rows) {
        if (row.length > i && row[i] != null && row[i]?.value != null) {
          var contentLength = row[i]!.value.toString().length;
          if (contentLength > maxLength) {
            maxLength = contentLength;
          }
        }
      }
      // Set column width based on content length
      sheet.setColumnWidth(i, (maxLength + 2) * 1.2); // Adding some padding
    }
    
    // Save the file
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'buyer_wise_sales_${DateFormat('yyyyMMdd').format(startDate)}_${DateFormat('yyyyMMdd').format(endDate)}.xlsx';
    final filePath = '${directory.path}/$fileName';
    
    final fileBytes = excel.encode();
    if (fileBytes != null) {
      final file = File(filePath);
      await file.writeAsBytes(fileBytes);
    } else {
      throw Exception('Failed to encode Excel file');
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
    
    // Group loadings by material
    final materialMap = <String, Map<String, dynamic>>{};
    
    for (final loading in loadings) {
      // Since GateEntryModel doesn't have supplierId or supplier properties, we'll group by material instead
      final key = '${loading.materialId}_${loading.materialSizeId ?? 0}';
        
      if (!materialMap.containsKey(key)) {
        materialMap[key] = {
          'supplierName': 'N/A', // Since supplier is not available
          'materialName': loading.material?.name ?? 'N/A',
          'sizeName': loading.materialSize?.name ?? 'N/A',
          'quantity': 0.0,
          'unit': loading.weightUnit?.symbol ?? '',
          'status': loading.status,
        };
      }
      
      materialMap[key]?['quantity'] = (materialMap[key]?['quantity'] ?? 0.0) + loading.quantity;
    }
    
    // Add data rows
    for (final data in materialMap.values) {
      sheet.appendRow([
        TextCellValue(data['supplierName']),
        TextCellValue(data['materialName']),
        TextCellValue(data['sizeName']),
        TextCellValue(data['quantity'].toString()),
        TextCellValue(data['unit']),
        TextCellValue(data['status']),
      ]);
    }
    
    // Auto fit columns
    for (int i = 0; i < 6; i++) {
      // Find the maximum content length in the column
      var maxLength = 0;
      for (var row in sheet.rows) {
        if (row.length > i && row[i] != null && row[i]?.value != null) {
          var contentLength = row[i]!.value.toString().length;
          if (contentLength > maxLength) {
            maxLength = contentLength;
          }
        }
      }
      // Set column width based on content length
      sheet.setColumnWidth(i, (maxLength + 2) * 1.2); // Adding some padding
    }
    
    // Save the file
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'supplier_wise_purchase_${DateFormat('yyyyMMdd').format(startDate)}_${DateFormat('yyyyMMdd').format(endDate)}.xlsx';
    final filePath = '${directory.path}/$fileName';
    
    final fileBytes = excel.encode();
    if (fileBytes != null) {
      final file = File(filePath);
      await file.writeAsBytes(fileBytes);
    } else {
      throw Exception('Failed to encode Excel file');
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
          'unit': loading.weightUnit?.symbol ?? '',
          'status': loading.status,
        };
      }
      
      materialMap[key]?['quantity'] = (materialMap[key]?['quantity'] ?? 0.0) + loading.quantity;
    }
    
    // Add data rows
    for (final data in materialMap.values) {
      sheet.appendRow([
        TextCellValue(data['materialName'] ?? 'N/A'),
        TextCellValue(data['sizeName'] ?? 'N/A'),
        TextCellValue(data['purpose'] ?? 'N/A'),
        TextCellValue((data['quantity'] ?? 0.0).toString()),
        TextCellValue(data['unit'] ?? ''),
        TextCellValue(data['status'] ?? 'N/A'),
      ]);
    }
    
    // Auto fit columns
    for (int i = 0; i < 6; i++) {
      // Find the maximum content length in the column
      var maxLength = 0;
      for (var row in sheet.rows) {
        if (row.length > i && row[i] != null && row[i]?.value != null) {
          var contentLength = row[i]!.value.toString().length;
          if (contentLength > maxLength) {
            maxLength = contentLength;
          }
        }
      }
      // Set column width based on content length
      sheet.setColumnWidth(i, (maxLength + 2) * 1.2); // Adding some padding
    }
    
    // Save the file
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'material_movement_${DateFormat('yyyyMMdd').format(startDate)}_${DateFormat('yyyyMMdd').format(endDate)}.xlsx';
    final filePath = '${directory.path}/$fileName';
    
    final fileBytes = excel.encode();
    if (fileBytes != null) {
      final file = File(filePath);
      await file.writeAsBytes(fileBytes);
    } else {
      throw Exception('Failed to encode Excel file');
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
          TextCellValue(invoice.baseAmount.toString()),
          TextCellValue(invoice.cgstAmount.toString()),
          TextCellValue(invoice.sgstAmount.toString()),
          TextCellValue(invoice.igstAmount.toString()),
          TextCellValue(invoice.totalAmount.toString()),
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
      TextCellValue(totalBaseAmount.toString()),
      TextCellValue(totalCgst.toString()),
      TextCellValue(totalSgst.toString()),
      TextCellValue(totalIgst.toString()),
      TextCellValue(totalAmount.toString()),
    ]);
    
    // Auto fit columns
    for (int i = 0; i < 5; i++) {
      // Find the maximum content length in the column
      var maxLength = 0;
      for (var row in sheet.rows) {
        if (row.length > i && row[i] != null && row[i]?.value != null) {
          var contentLength = row[i]!.value.toString().length;
          if (contentLength > maxLength) {
            maxLength = contentLength;
          }
        }
      }
      // Set column width based on content length
      sheet.setColumnWidth(i, (maxLength + 2) * 1.2); // Adding some padding
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

