import 'dart:io';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/gate_entry_model.dart';
import '../models/weighbridge_record_model.dart';
import '../models/invoice_model.dart';
import '../../core/values/app_constants.dart';

class PdfService extends GetxService {
  static PdfService get to => Get.find<PdfService>();
  
  // Initialize PDF service
  Future<PdfService> init() async {
    print('PDF service initialized');
    return this;
  }
  
  // Generate gate pass
  Future<void> generateGatePass(GateEntryModel gateEntry) async {
    final pdf = pw.Document();
    
    // Load font
    final font = await PdfGoogleFonts.nunitoRegular();
    final fontBold = await PdfGoogleFonts.nunitoBold();
    
    // Add page
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5,
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(16),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildHeader(title: 'GATE PASS', font: fontBold),
                pw.SizedBox(height: 16),
                _buildCompanyInfo(font: font, fontBold: fontBold),
                pw.SizedBox(height: 16),
                _buildDivider(),
                pw.SizedBox(height: 16),
                _buildGatePassDetails(gateEntry, font: font, fontBold: fontBold),
                pw.SizedBox(height: 16),
                _buildDivider(),
                pw.SizedBox(height: 16),
                _buildFooter(font: font),
              ],
            ),
          );
        },
      ),
    );
    
    // Save PDF
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/gate_pass_${gateEntry.sessionId}.pdf');
    await file.writeAsBytes(await pdf.save());
    
    // Print PDF
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Gate Pass - ${gateEntry.sessionId}',
    );
  }
  
  // Generate weigh slip
  Future<void> generateWeighSlip(WeighbridgeRecordModel record) async {
    final pdf = pw.Document();
    
    // Load font
    final font = await PdfGoogleFonts.nunitoRegular();
    final fontBold = await PdfGoogleFonts.nunitoBold();
    
    // Add page
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5,
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(16),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildHeader(title: 'WEIGH SLIP', font: fontBold),
                pw.SizedBox(height: 16),
                _buildCompanyInfo(font: font, fontBold: fontBold),
                pw.SizedBox(height: 16),
                _buildDivider(),
                pw.SizedBox(height: 16),
                _buildWeighSlipDetails(record, font: font, fontBold: fontBold),
                pw.SizedBox(height: 16),
                _buildDivider(),
                pw.SizedBox(height: 16),
                _buildFooter(font: font),
              ],
            ),
          );
        },
      ),
    );
    
    // Save PDF
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/weigh_slip_${record.gateEntry?.sessionId ?? "unknown"}.pdf');
    await file.writeAsBytes(await pdf.save());
    
    // Print PDF
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Weigh Slip - ${record.gateEntry?.sessionId ?? "unknown"}',
    );
  }
  
  // Generate invoice
  Future<void> generateInvoice(InvoiceModel invoice) async {
    final pdf = pw.Document();
    
    // Load font
    final font = await PdfGoogleFonts.nunitoRegular();
    final fontBold = await PdfGoogleFonts.nunitoBold();
    
    // Add page
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(16),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildHeader(title: 'TAX INVOICE', font: fontBold),
                pw.SizedBox(height: 16),
                _buildCompanyInfo(font: font, fontBold: fontBold),
                pw.SizedBox(height: 16),
                _buildDivider(),
                pw.SizedBox(height: 16),
                _buildInvoiceDetails(invoice, font: font, fontBold: fontBold),
                pw.SizedBox(height: 16),
                _buildInvoiceItems(invoice, font: font, fontBold: fontBold),
                pw.SizedBox(height: 16),
                _buildInvoiceSummary(invoice, font: font, fontBold: fontBold),
                pw.SizedBox(height: 16),
                _buildDivider(),
                pw.SizedBox(height: 16),
                _buildFooter(font: font),
              ],
            ),
          );
        },
      ),
    );
    
    // Save PDF
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/invoice_${invoice.invoiceNumber}.pdf');
    await file.writeAsBytes(await pdf.save());
    
    // Print PDF
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Invoice - ${invoice.invoiceNumber}',
    );
  }
  
  // Build header
  pw.Widget _buildHeader({required String title, required pw.Font font}) {
    return pw.Center(
      child: pw.Text(
        title,
        style: pw.TextStyle(
          font: font,
          fontSize: 20,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }
  
  // Build company info
  pw.Widget _buildCompanyInfo({required pw.Font font, required pw.Font fontBold}) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(
          'CRUSHER MANAGEMENT SYSTEM',
          style: pw.TextStyle(
            font: fontBold,
            fontSize: 16,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'Address: 123 Crusher Road, Stone City, 123456',
          style: pw.TextStyle(
            font: font,
            fontSize: 10,
          ),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          'Phone: +91 9876543210 | Email: info@crushermanagement.com',
          style: pw.TextStyle(
            font: font,
            fontSize: 10,
          ),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          'GSTIN: 12ABCDE1234F1Z5',
          style: pw.TextStyle(
            font: font,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
  
  // Build divider
  pw.Widget _buildDivider() {
    return pw.Divider(
      thickness: 1,
      color: PdfColors.grey,
    );
  }
  
  // Build gate pass details
  pw.Widget _buildGatePassDetails(GateEntryModel gateEntry, {required pw.Font font, required pw.Font fontBold}) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildDetailRow('Gate Pass No', gateEntry.gatePassNumber, font: font, fontBold: fontBold),
        _buildDetailRow('Session ID', gateEntry.sessionId, font: font, fontBold: fontBold),
        _buildDetailRow('Date & Time', DateFormat(AppConstants.dateTimeFormat).format(gateEntry.entryTime), font: font, fontBold: fontBold),
        _buildDetailRow('Vehicle No', gateEntry.vehicle?.vehicleNumber ?? 'N/A', font: font, fontBold: fontBold),
        _buildDetailRow('Vehicle Type', gateEntry.vehicle?.vehicleType ?? 'N/A', font: font, fontBold: fontBold),
        _buildDetailRow('Driver Name', gateEntry.driverName ?? 'N/A', font: font, fontBold: fontBold),
        _buildDetailRow('Driver Mobile', gateEntry.driverMobile ?? 'N/A', font: font, fontBold: fontBold),
        _buildDetailRow('Status', gateEntry.status, font: font, fontBold: fontBold),
        if (gateEntry.tareWeight != null)
          _buildDetailRow('Tare Weight', '${gateEntry.tareWeight} kg', font: font, fontBold: fontBold),
        if (gateEntry.grossWeight != null)
          _buildDetailRow('Gross Weight', '${gateEntry.grossWeight} kg', font: font, fontBold: fontBold),
        if (gateEntry.netWeight != null)
          _buildDetailRow('Net Weight', '${gateEntry.netWeight} kg', font: font, fontBold: fontBold),
        if (gateEntry.exitTime != null)
          _buildDetailRow('Exit Time', DateFormat(AppConstants.dateTimeFormat).format(gateEntry.exitTime!), font: font, fontBold: fontBold),
        if (gateEntry.remarks != null && gateEntry.remarks!.isNotEmpty)
          _buildDetailRow('Remarks', gateEntry.remarks!, font: font, fontBold: fontBold),
      ],
    );
  }
  
  // Build weigh slip details
  pw.Widget _buildWeighSlipDetails(WeighbridgeRecordModel record, {required pw.Font font, required pw.Font fontBold}) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildDetailRow('Session ID', record.gateEntry?.sessionId ?? 'N/A', font: font, fontBold: fontBold),
        _buildDetailRow('Vehicle No', record.gateEntry?.vehicle?.vehicleNumber ?? 'N/A', font: font, fontBold: fontBold),
        _buildDetailRow('Driver Name', record.gateEntry?.driverName ?? 'N/A', font: font, fontBold: fontBold),
        if (record.tareWeight != null) {
          _buildDetailRow(
            'Tare Weight',
            '${record.tareWeight} ${record.weightUnit?.symbol ?? 'kg'}',
            font: font,
            fontBold: fontBold,
          ),
          _buildDetailRow(
            'Tare Weight Time',
            record.tareWeightTime != null ? DateFormat(AppConstants.dateTimeFormat).format(record.tareWeightTime!) : 'N/A',
            font: font,
            fontBold: fontBold,
          ),
        },
        if (record.grossWeight != null) {
          _buildDetailRow(
            'Gross Weight',
            '${record.grossWeight} ${record.weightUnit?.symbol ?? 'kg'}',
            font: font,
            fontBold: fontBold,
          ),
          _buildDetailRow(
            'Gross Weight Time',
            record.grossWeightTime != null ? DateFormat(AppConstants.dateTimeFormat).format(record.grossWeightTime!) : 'N/A',
            font: font,
            fontBold: fontBold,
          ),
        },
        if (record.netWeight != null) {
          _buildDetailRow(
            'Net Weight',
            '${record.netWeight} ${record.weightUnit?.symbol ?? 'kg'}',
            font: font,
            fontBold: fontBold,
          ),
        },
        if (record.remarks != null && record.remarks!.isNotEmpty) {
          _buildDetailRow('Remarks', record.remarks!, font: font, fontBold: fontBold),
        },
      ],
    );
  }
  
  // Build invoice details
  pw.Widget _buildInvoiceDetails(InvoiceModel invoice, {required pw.Font font, required pw.Font fontBold}) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildDetailRow('Invoice No', invoice.invoiceNumber, font: font, fontBold: fontBold),
        _buildDetailRow('Invoice Date', DateFormat(AppConstants.dateFormat).format(invoice.invoiceDate), font: font, fontBold: fontBold),
        _buildDetailRow('Session ID', invoice.gateEntry?.sessionId ?? 'N/A', font: font, fontBold: fontBold),
        _buildDetailRow('Vehicle No', invoice.gateEntry?.vehicle?.vehicleNumber ?? 'N/A', font: font, fontBold: fontBold),
        _buildDetailRow('Buyer Name', invoice.buyer?.name ?? 'N/A', font: font, fontBold: fontBold),
        _buildDetailRow('Buyer GSTIN', invoice.buyer?.gstin ?? 'N/A', font: font, fontBold: fontBold),
        _buildDetailRow('Buyer Address', invoice.buyer?.address ?? 'N/A', font: font, fontBold: fontBold),
      ],
    );
  }
  
  // Build invoice items
  pw.Widget _buildInvoiceItems(InvoiceModel invoice, {required pw.Font font, required pw.Font fontBold}) {
    final headers = ['S.No', 'Description', 'HSN Code', 'Quantity', 'Rate', 'Amount'];
    
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey),
      children: [
        // Header row
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: headers.map((header) => pw.Container(
            padding: const pw.EdgeInsets.all(4),
            alignment: header == 'S.No' || header == 'Quantity' || header == 'Rate' || header == 'Amount'
                ? pw.Alignment.centerRight
                : pw.Alignment.centerLeft,
            child: pw.Text(
              header,
              style: pw.TextStyle(
                font: fontBold,
                fontSize: 10,
              ),
            ),
          )).toList(),
        ),
        // Item rows
        ...invoice.items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          
          return pw.TableRow(
            children: [
              // S.No
              pw.Container(
                padding: const pw.EdgeInsets.all(4),
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  '${index + 1}',
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 10,
                  ),
                ),
              ),
              // Description
              pw.Container(
                padding: const pw.EdgeInsets.all(4),
                alignment: pw.Alignment.centerLeft,
                child: pw.Text(
                  item.material?.name ?? 'N/A',
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 10,
                  ),
                ),
              ),
              // HSN Code
              pw.Container(
                padding: const pw.EdgeInsets.all(4),
                alignment: pw.Alignment.centerLeft,
                child: pw.Text(
                  item.material?.taxConfiguration?.hsnCode ?? 'N/A',
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 10,
                  ),
                ),
              ),
              // Quantity
              pw.Container(
                padding: const pw.EdgeInsets.all(4),
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  '${item.quantity} ${item.weightUnit?.symbol ?? 'kg'}',
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 10,
                  ),
                ),
              ),
              // Rate
              pw.Container(
                padding: const pw.EdgeInsets.all(4),
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  '₹${item.rate.toStringAsFixed(2)}',
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 10,
                  ),
                ),
              ),
              // Amount
              pw.Container(
                padding: const pw.EdgeInsets.all(4),
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  '₹${item.amount.toStringAsFixed(2)}',
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ],
    );
  }
  
  // Build invoice summary
  pw.Widget _buildInvoiceSummary(InvoiceModel invoice, {required pw.Font font, required pw.Font fontBold}) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildDetailRow('Base Amount', '₹${invoice.baseAmount.toStringAsFixed(2)}', font: font, fontBold: fontBold),
        _buildDetailRow('CGST Amount', '₹${invoice.cgstAmount.toStringAsFixed(2)}', font: font, fontBold: fontBold),
        _buildDetailRow('SGST Amount', '₹${invoice.sgstAmount.toStringAsFixed(2)}', font: font, fontBold: fontBold),
        _buildDetailRow('IGST Amount', '₹${invoice.igstAmount.toStringAsFixed(2)}', font: font, fontBold: fontBold),
        _buildDetailRow('Total Amount', '₹${invoice.totalAmount.toStringAsFixed(2)}', font: font, fontBold: fontBold),
      ],
    );
  }
  
  // Build detail row
  pw.Widget _buildDetailRow(String label, String value, {required pw.Font font, required pw.Font fontBold}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 100,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                font: fontBold,
                fontSize: 10,
              ),
            ),
          ),
          pw.Text(
            ': ',
            style: pw.TextStyle(
              font: font,
              fontSize: 10,
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(
                font: font,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Build footer
  pw.Widget _buildFooter({required pw.Font font}) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(
          'This is a computer-generated document. No signature is required.',
          style: pw.TextStyle(
            font: font,
            fontSize: 8,
            color: PdfColors.grey,
          ),
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'Powered by Crusher Management System',
          style: pw.TextStyle(
            font: font,
            fontSize: 8,
            color: PdfColors.grey,
          ),
          textAlign: pw.TextAlign.center,
        ),
      ],
    );
  }
}

