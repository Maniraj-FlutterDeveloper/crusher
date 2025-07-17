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
import '../../core/values/app_constants.dart';

class PdfService extends GetxService {
  static PdfService get to => Get.find<PdfService>();
  
  // Initialize PDF service
  Future<PdfService> init() async {
    print('PDF service initialized');
    return this;
  }
  
  // Generate gate pass PDF
  Future<File> generateGatePass(GateEntryModel gateEntry) async {
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader('GATE PASS'),
              pw.SizedBox(height: 20),
              _buildGatePassDetails(gateEntry),
              pw.SizedBox(height: 20),
              _buildFooter(),
            ],
          );
        },
      ),
    );
    
    return await _savePdf('gate_pass_${gateEntry.gatePassNumber}.pdf', pdf);
  }
  
  // Generate weigh slip PDF
  Future<File> generateWeighSlip(WeighbridgeRecordModel weighbridgeRecord, GateEntryModel gateEntry) async {
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader('WEIGH SLIP'),
              pw.SizedBox(height: 20),
              _buildWeighSlipDetails(weighbridgeRecord, gateEntry),
              pw.SizedBox(height: 20),
              _buildFooter(),
            ],
          );
        },
      ),
    );
    
    return await _savePdf('weigh_slip_${gateEntry.sessionId}.pdf', pdf);
  }
  
  // Generate invoice PDF
  Future<File> generateInvoice(InvoiceModel invoice, GateEntryModel gateEntry) async {
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader('TAX INVOICE'),
              pw.SizedBox(height: 20),
              _buildInvoiceDetails(invoice, gateEntry),
              pw.SizedBox(height: 20),
              _buildInvoiceItems(invoice),
              pw.SizedBox(height: 20),
              _buildInvoiceSummary(invoice),
              pw.SizedBox(height: 20),
              _buildFooter(),
            ],
          );
        },
      ),
    );
    
    return await _savePdf('invoice_${invoice.invoiceNumber}.pdf', pdf);
  }
  
  // Build header
  pw.Widget _buildHeader(String title) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(
          'CRUSHER MANAGEMENT SYSTEM',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 5),
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 5),
        pw.Divider(),
      ],
    );
  }
  
  // Build gate pass details
  pw.Widget _buildGatePassDetails(GateEntryModel gateEntry) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Gate Pass No: ${gateEntry.gatePassNumber}'),
            pw.Text('Date: ${DateFormat(AppConstants.dateFormat).format(gateEntry.entryTime)}'),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Session ID: ${gateEntry.sessionId}'),
            pw.Text('Time: ${DateFormat(AppConstants.timeFormat).format(gateEntry.entryTime)}'),
          ],
        ),
        pw.SizedBox(height: 20),
        pw.Text('Vehicle Details:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 5),
        pw.Text('Vehicle No: ${gateEntry.vehicle?.vehicleNumber ?? "N/A"}'),
        pw.Text('Driver Name: ${gateEntry.driverName ?? "N/A"}'),
        pw.Text('Driver Mobile: ${gateEntry.driverMobile ?? "N/A"}'),
        pw.SizedBox(height: 20),
        pw.Text('Entry Details:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 5),
        pw.Text('Tare Weight: ${gateEntry.tareWeight != null ? "${gateEntry.tareWeight} kg" : "N/A"}'),
        pw.Text('Status: ${gateEntry.status}'),
        pw.Text('Remarks: ${gateEntry.remarks ?? "N/A"}'),
      ],
    );
  }
  
  // Build weigh slip details
  pw.Widget _buildWeighSlipDetails(WeighbridgeRecordModel weighbridgeRecord, GateEntryModel gateEntry) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Session ID: ${gateEntry.sessionId}'),
            pw.Text('Date: ${DateFormat(AppConstants.dateFormat).format(gateEntry.entryTime)}'),
          ],
        ),
        pw.SizedBox(height: 20),
        pw.Text('Vehicle Details:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 5),
        pw.Text('Vehicle No: ${gateEntry.vehicle?.vehicleNumber ?? "N/A"}'),
        pw.Text('Driver Name: ${gateEntry.driverName ?? "N/A"}'),
        pw.SizedBox(height: 20),
        pw.Text('Weight Details:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 5),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Tare Weight:'),
            pw.Text('${weighbridgeRecord.tareWeight != null ? "${weighbridgeRecord.tareWeight} kg" : "N/A"}'),
          ],
        ),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Gross Weight:'),
            pw.Text('${weighbridgeRecord.grossWeight != null ? "${weighbridgeRecord.grossWeight} kg" : "N/A"}'),
          ],
        ),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Net Weight:'),
            pw.Text('${weighbridgeRecord.netWeight != null ? "${weighbridgeRecord.netWeight} kg" : "N/A"}'),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Tare Time:'),
            pw.Text('${weighbridgeRecord.tareWeightTime != null ? DateFormat(AppConstants.timeFormat).format(weighbridgeRecord.tareWeightTime!) : "N/A"}'),
          ],
        ),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Gross Time:'),
            pw.Text('${weighbridgeRecord.grossWeightTime != null ? DateFormat(AppConstants.timeFormat).format(weighbridgeRecord.grossWeightTime!) : "N/A"}'),
          ],
        ),
      ],
    );
  }
  
  // Build invoice details
  pw.Widget _buildInvoiceDetails(InvoiceModel invoice, GateEntryModel gateEntry) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Invoice No: ${invoice.invoiceNumber}'),
            pw.Text('Date: ${DateFormat(AppConstants.dateFormat).format(invoice.invoiceDate)}'),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Session ID: ${gateEntry.sessionId}'),
            pw.Text('Status: ${invoice.status}'),
          ],
        ),
        pw.SizedBox(height: 20),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Buyer Details:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 5),
                  pw.Text('Name: ${invoice.buyerName ?? "N/A"}'),
                  pw.Text('GSTIN: ${invoice.buyerGstin ?? "N/A"}'),
                  pw.Text('Address: ${invoice.buyerAddress ?? "N/A"}'),
                ],
              ),
            ),
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Vehicle Details:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 5),
                  pw.Text('Vehicle No: ${gateEntry.vehicle?.vehicleNumber ?? "N/A"}'),
                  pw.Text('Driver Name: ${gateEntry.driverName ?? "N/A"}'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  // Build invoice items
  pw.Widget _buildInvoiceItems(InvoiceModel invoice) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Invoice Items:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 5),
        pw.Table(
          border: pw.TableBorder.all(),
          columnWidths: {
            0: const pw.FlexColumnWidth(1),
            1: const pw.FlexColumnWidth(3),
            2: const pw.FlexColumnWidth(1),
            3: const pw.FlexColumnWidth(1),
            4: const pw.FlexColumnWidth(1),
            5: const pw.FlexColumnWidth(1),
          },
          children: [
            pw.TableRow(
              decoration: pw.BoxDecoration(color: PdfColors.grey300),
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text('S.No.', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text('Description', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text('HSN Code', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text('Quantity', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text('Rate', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text('Amount', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ),
              ],
            ),
            if (invoice.items != null)
              ...List.generate(invoice.items!.length, (index) {
                final item = invoice.items![index];
                return pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text('${index + 1}'),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(item.materialName ?? 'N/A'),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(item.hsnCode ?? 'N/A'),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text('${item.quantity} ${item.weightUnitSymbol ?? ""}'),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text('${item.rate}'),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text('${item.amount}'),
                    ),
                  ],
                );
              }),
          ],
        ),
      ],
    );
  }
  
  // Build invoice summary
  pw.Widget _buildInvoiceSummary(InvoiceModel invoice) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.end,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Row(
                  children: [
                    pw.Text('Base Amount: '),
                    pw.SizedBox(width: 10),
                    pw.Text('${invoice.baseAmount}'),
                  ],
                ),
                pw.SizedBox(height: 5),
                pw.Row(
                  children: [
                    pw.Text('CGST (${invoice.cgstPercentage}%): '),
                    pw.SizedBox(width: 10),
                    pw.Text('${invoice.cgstAmount}'),
                  ],
                ),
                pw.Row(
                  children: [
                    pw.Text('SGST (${invoice.sgstPercentage}%): '),
                    pw.SizedBox(width: 10),
                    pw.Text('${invoice.sgstAmount}'),
                  ],
                ),
                pw.Row(
                  children: [
                    pw.Text('IGST (${invoice.igstPercentage}%): '),
                    pw.SizedBox(width: 10),
                    pw.Text('${invoice.igstAmount}'),
                  ],
                ),
                pw.SizedBox(height: 5),
                pw.Divider(),
                pw.Row(
                  children: [
                    pw.Text('Total Amount: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(width: 10),
                    pw.Text('${invoice.totalAmount}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 20),
        pw.Text('Amount in words: ${_convertNumberToWords(invoice.totalAmount)} only', style: pw.TextStyle(fontStyle: pw.FontStyle.italic)),
        pw.SizedBox(height: 20),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Terms & Conditions:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 5),
                pw.Text('1. Goods once sold will not be taken back.'),
                pw.Text('2. Interest @18% p.a. will be charged if payment is not made within due date.'),
                pw.Text('3. Subject to local jurisdiction.'),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text('For Crusher Management System', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 40),
                pw.Text('Authorized Signatory'),
              ],
            ),
          ],
        ),
      ],
    );
  }
  
  // Build footer
  pw.Widget _buildFooter() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Divider(),
        pw.SizedBox(height: 5),
        pw.Text('This is a computer generated document. No signature required.'),
        pw.SizedBox(height: 5),
        pw.Text('Crusher Management System - ${AppConstants.appVersion}'),
      ],
    );
  }
  
  // Save PDF to file
  Future<File> _savePdf(String fileName, pw.Document pdf) async {
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/$fileName');
    await file.writeAsBytes(await pdf.save());
    return file;
  }
  
  // Print PDF
  Future<void> printPdf(File pdfFile) async {
    await Printing.layoutPdf(
      onLayout: (_) async => pdfFile.readAsBytes(),
    );
  }
  
  // Convert number to words
  String _convertNumberToWords(double number) {
    // This is a simplified implementation
    // For a production app, use a more comprehensive library
    
    final units = ['', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine', 'Ten', 'Eleven', 'Twelve', 'Thirteen', 'Fourteen', 'Fifteen', 'Sixteen', 'Seventeen', 'Eighteen', 'Nineteen'];
    final tens = ['', '', 'Twenty', 'Thirty', 'Forty', 'Fifty', 'Sixty', 'Seventy', 'Eighty', 'Ninety'];
    
    if (number == 0) {
      return 'Zero';
    }
    
    // Split the number into integer and decimal parts
    final int intPart = number.toInt();
    final int decimalPart = ((number - intPart) * 100).round();
    
    String words = '';
    
    if (intPart > 0) {
      if (intPart >= 10000000) {
        words += '${_convertNumberToWords(intPart / 10000000)} Crore ';
        number %= 10000000;
      }
      
      if (intPart >= 100000) {
        words += '${_convertNumberToWords(intPart / 100000)} Lakh ';
        number %= 100000;
      }
      
      if (intPart >= 1000) {
        words += '${_convertNumberToWords(intPart / 1000)} Thousand ';
        number %= 1000;
      }
      
      if (intPart >= 100) {
        words += '${units[intPart ~/ 100]} Hundred ';
        number %= 100;
      }
      
      if (intPart > 0) {
        if (words.isNotEmpty) {
          words += 'and ';
        }
        
        if (intPart < 20) {
          words += units[intPart];
        } else {
          words += '${tens[intPart ~/ 10]} ${units[intPart % 10]}';
        }
      }
    }
    
    if (decimalPart > 0) {
      words += ' Rupees and ';
      if (decimalPart < 20) {
        words += '${units[decimalPart]} Paise';
      } else {
        words += '${tens[decimalPart ~/ 10]} ${units[decimalPart % 10]} Paise';
      }
    } else {
      words += ' Rupees';
    }
    
    return words.trim();
  }
}

