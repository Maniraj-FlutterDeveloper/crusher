import 'dart:io';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

import '../models/gate_entry_model.dart';
import '../models/weighbridge_record_model.dart';
import '../models/invoice_model.dart';
import '../models/vehicle_model.dart';
import '../../core/values/app_constants.dart';

class PdfService extends GetxService {
  static PdfService get to => Get.find<PdfService>();
  
  // Initialize PDF service
  Future<PdfService> init() async {
    print('PDF service initialized');
    return this;
  }
  
  // Generate gate pass PDF
  Future<File> generateGatePass(GateEntryModel gateEntry, VehicleModel vehicle) async {
    final pdf = pw.Document();
    
    final dateFormat = DateFormat(AppConstants.dateFormat);
    final timeFormat = DateFormat(AppConstants.timeFormat);
    
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  'GATE PASS',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Gate Pass No:'),
                  pw.Text(gateEntry.gatePassNumber ?? 'N/A', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.SizedBox(height: 5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Session ID:'),
                  pw.Text(gateEntry.sessionId, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.SizedBox(height: 5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Date:'),
                  pw.Text(dateFormat.format(gateEntry.entryTime)),
                ],
              ),
              pw.SizedBox(height: 5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Time:'),
                  pw.Text(timeFormat.format(gateEntry.entryTime)),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Text('Vehicle Details', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Vehicle Number:'),
                  pw.Text(vehicle.vehicleNumber, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.SizedBox(height: 5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Vehicle Type:'),
                  pw.Text(vehicle.vehicleType ?? 'N/A'),
                ],
              ),
              pw.SizedBox(height: 5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Driver Name:'),
                  pw.Text(gateEntry.driverName ?? 'N/A'),
                ],
              ),
              pw.SizedBox(height: 5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Driver Mobile:'),
                  pw.Text(gateEntry.driverMobile ?? 'N/A'),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Text('Weight Details', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Tare Weight:'),
                  pw.Text(gateEntry.tareWeight != null ? '${gateEntry.tareWeight} kg' : 'N/A'),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text('___________________'),
                      pw.SizedBox(height: 5),
                      pw.Text('Operator Signature'),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text('___________________'),
                      pw.SizedBox(height: 5),
                      pw.Text('Driver Signature'),
                    ],
                  ),
                ],
              ),
              pw.Spacer(),
              pw.Center(
                child: pw.Text(
                  'Crusher Management System',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontStyle: pw.FontStyle.italic,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
    
    // Save the PDF
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/gate_pass_${gateEntry.sessionId}.pdf');
    await file.writeAsBytes(await pdf.save());
    
    return file;
  }
  
  // Generate weigh slip PDF
  Future<File> generateWeighSlip(WeighbridgeRecordModel weighbridgeRecord, GateEntryModel gateEntry, VehicleModel vehicle) async {
    final pdf = pw.Document();
    
    final dateFormat = DateFormat(AppConstants.dateFormat);
    final timeFormat = DateFormat(AppConstants.timeFormat);
    
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  'WEIGH SLIP',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Session ID:'),
                  pw.Text(gateEntry.sessionId, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.SizedBox(height: 5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Date:'),
                  pw.Text(dateFormat.format(gateEntry.entryTime)),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Text('Vehicle Details', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Vehicle Number:'),
                  pw.Text(vehicle.vehicleNumber, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.SizedBox(height: 5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Driver Name:'),
                  pw.Text(gateEntry.driverName ?? 'N/A'),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Text('Weight Details', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Tare Weight:'),
                  pw.Text(weighbridgeRecord.tareWeight != null ? '${weighbridgeRecord.tareWeight} kg' : 'N/A'),
                ],
              ),
              pw.SizedBox(height: 5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Tare Weight Time:'),
                  pw.Text(weighbridgeRecord.tareWeightTime != null ? timeFormat.format(weighbridgeRecord.tareWeightTime!) : 'N/A'),
                ],
              ),
              pw.SizedBox(height: 5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Gross Weight:'),
                  pw.Text(weighbridgeRecord.grossWeight != null ? '${weighbridgeRecord.grossWeight} kg' : 'N/A'),
                ],
              ),
              pw.SizedBox(height: 5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Gross Weight Time:'),
                  pw.Text(weighbridgeRecord.grossWeightTime != null ? timeFormat.format(weighbridgeRecord.grossWeightTime!) : 'N/A'),
                ],
              ),
              pw.SizedBox(height: 5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Net Weight:'),
                  pw.Text(weighbridgeRecord.netWeight != null ? '${weighbridgeRecord.netWeight} kg' : 'N/A', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text('___________________'),
                      pw.SizedBox(height: 5),
                      pw.Text('Operator Signature'),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text('___________________'),
                      pw.SizedBox(height: 5),
                      pw.Text('Driver Signature'),
                    ],
                  ),
                ],
              ),
              pw.Spacer(),
              pw.Center(
                child: pw.Text(
                  'Crusher Management System',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontStyle: pw.FontStyle.italic,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
    
    // Save the PDF
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/weigh_slip_${gateEntry.sessionId}.pdf');
    await file.writeAsBytes(await pdf.save());
    
    return file;
  }
  
  // Generate invoice PDF
  Future<File> generateInvoice(InvoiceModel invoice, String buyerName, String vehicleNumber) async {
    final pdf = pw.Document();
    
    final dateFormat = DateFormat(AppConstants.dateFormat);
    
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  'TAX INVOICE',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Crusher Management System', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('Address Line 1'),
                      pw.Text('Address Line 2'),
                      pw.Text('Phone: 1234567890'),
                      pw.Text('Email: info@crusher.com'),
                      pw.Text('GSTIN: 12ABCDE1234F1Z5'),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Invoice No: ${invoice.invoiceNumber}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('Date: ${dateFormat.format(invoice.invoiceDate)}'),
                      pw.Text('Status: ${invoice.status}'),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Bill To:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(buyerName),
                      pw.Text('Buyer Address Line 1'),
                      pw.Text('Buyer Address Line 2'),
                      pw.Text('GSTIN: 12ABCDE1234F1Z5'),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Vehicle No: $vehicleNumber', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('Session ID: ${invoice.gateEntryId}'),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Table(
                border: pw.TableBorder.all(),
                columnWidths: {
                  0: pw.FlexColumnWidth(1),
                  1: pw.FlexColumnWidth(3),
                  2: pw.FlexColumnWidth(1),
                  3: pw.FlexColumnWidth(1),
                  4: pw.FlexColumnWidth(1),
                  5: pw.FlexColumnWidth(1.5),
                },
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(5),
                        child: pw.Text('S.No.', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(5),
                        child: pw.Text('Description', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(5),
                        child: pw.Text('Qty', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(5),
                        child: pw.Text('Unit', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(5),
                        child: pw.Text('Rate', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(5),
                        child: pw.Text('Amount', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  ),
                  // Add invoice items here
                  if (invoice.items != null)
                    ...invoice.items!.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      return pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: pw.EdgeInsets.all(5),
                            child: pw.Text('${index + 1}'),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(5),
                            child: pw.Text('Material ${item.materialId}'),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(5),
                            child: pw.Text('${item.quantity}'),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(5),
                            child: pw.Text('kg'),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(5),
                            child: pw.Text('${item.rate}'),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(5),
                            child: pw.Text('${item.amount}'),
                          ),
                        ],
                      );
                    }).toList(),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Row(
                        children: [
                          pw.Container(
                            width: 150,
                            child: pw.Text('Base Amount:'),
                          ),
                          pw.Container(
                            width: 100,
                            child: pw.Text('₹ ${invoice.baseAmount.toStringAsFixed(2)}'),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 5),
                      pw.Row(
                        children: [
                          pw.Container(
                            width: 150,
                            child: pw.Text('CGST (9%):'),
                          ),
                          pw.Container(
                            width: 100,
                            child: pw.Text('₹ ${invoice.cgstAmount.toStringAsFixed(2)}'),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 5),
                      pw.Row(
                        children: [
                          pw.Container(
                            width: 150,
                            child: pw.Text('SGST (9%):'),
                          ),
                          pw.Container(
                            width: 100,
                            child: pw.Text('₹ ${invoice.sgstAmount.toStringAsFixed(2)}'),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 5),
                      pw.Row(
                        children: [
                          pw.Container(
                            width: 150,
                            child: pw.Text('IGST (0%):'),
                          ),
                          pw.Container(
                            width: 100,
                            child: pw.Text('₹ ${invoice.igstAmount.toStringAsFixed(2)}'),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 5),
                      pw.Divider(),
                      pw.SizedBox(height: 5),
                      pw.Row(
                        children: [
                          pw.Container(
                            width: 150,
                            child: pw.Text('Total Amount:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          ),
                          pw.Container(
                            width: 100,
                            child: pw.Text('₹ ${invoice.totalAmount.toStringAsFixed(2)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 30),
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Terms & Conditions:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('1. Payment due within 30 days'),
                      pw.Text('2. Goods once sold will not be taken back'),
                      pw.Text('3. Interest @18% p.a. will be charged on delayed payments'),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text('For Crusher Management System'),
                      pw.SizedBox(height: 40),
                      pw.Text('Authorized Signatory'),
                    ],
                  ),
                ],
              ),
              pw.Spacer(),
              pw.Center(
                child: pw.Text(
                  'This is a computer generated invoice and does not require a signature',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontStyle: pw.FontStyle.italic,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
    
    // Save the PDF
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/invoice_${invoice.invoiceNumber}.pdf');
    await file.writeAsBytes(await pdf.save());
    
    return file;
  }
  
  // Print PDF
  Future<void> printPdf(File pdfFile) async {
    await Printing.layoutPdf(
      onLayout: (_) => pdfFile.readAsBytes(),
    );
  }
  
  // Share PDF
  Future<void> sharePdf(File pdfFile) async {
    await Printing.sharePdf(bytes: await pdfFile.readAsBytes(), filename: pdfFile.path.split('/').last);
  }
}

