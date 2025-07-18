import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/values/app_constants.dart';
import '../../../../data/models/invoice_model.dart';
import '../../controllers/billing_controller.dart';

class InvoiceDetailsView extends GetView<BillingController> {
  final InvoiceModel invoice;

  const InvoiceDetailsView({
    Key? key,
    required this.invoice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppConstants.defaultElevation,
      margin: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInvoiceDetails(),
                    const SizedBox(height: 16),
                    _buildBuyerDetails(),
                    const SizedBox(height: 16),
                    _buildGateEntryDetails(),
                    const SizedBox(height: 16),
                    _buildInvoiceItems(),
                    const SizedBox(height: 16),
                    _buildTotals(),
                    if (invoice.remarks != null && invoice.remarks!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _buildRemarks(),
                    ],
                  ],
                ),
              ),
            ),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Invoice Details',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Get.back(),
        ),
      ],
    );
  }

  Widget _buildInvoiceDetails() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Invoice Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Invoice Number:'),
                      Text(
                        invoice.invoiceNumber,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Invoice Date:'),
                      Text(
                        DateFormat(AppConstants.dateFormat).format(invoice.invoiceDate),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Status:'),
                      _buildStatusChip(invoice.status),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBuyerDetails() {
    final buyer = invoice.buyer;
    
    if (buyer == null) {
      return const SizedBox.shrink();
    }
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Buyer Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text('Name: ${buyer.name}'),
            if (buyer.gstin != null && buyer.gstin!.isNotEmpty)
              Text('GSTIN: ${buyer.gstin}'),
            if (buyer.address != null && buyer.address!.isNotEmpty)
              Text('Address: ${buyer.address}'),
            if (buyer.city != null && buyer.city!.isNotEmpty ||
                buyer.state != null && buyer.state!.isNotEmpty ||
                buyer.pincode != null && buyer.pincode!.isNotEmpty)
              Text('${buyer.city ?? ''}, ${buyer.state ?? ''} ${buyer.pincode ?? ''}'),
            if (buyer.contactPerson != null && buyer.contactPerson!.isNotEmpty)
              Text('Contact Person: ${buyer.contactPerson}'),
            if (buyer.contactMobile != null && buyer.contactMobile!.isNotEmpty)
              Text('Mobile: ${buyer.contactMobile}'),
            if (buyer.contactEmail != null && buyer.contactEmail!.isNotEmpty)
              Text('Email: ${buyer.contactEmail}'),
          ],
        ),
      ),
    );
  }

  Widget _buildGateEntryDetails() {
    final gateEntry = invoice.gateEntry;
    
    if (gateEntry == null) {
      return const SizedBox.shrink();
    }
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gate Entry Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text('Session ID: ${gateEntry.sessionId}'),
            if (gateEntry.vehicle != null)
              Text('Vehicle Number: ${gateEntry.vehicle!.vehicleNumber}'),
            if (gateEntry.driverName != null && gateEntry.driverName!.isNotEmpty)
              Text('Driver Name: ${gateEntry.driverName}'),
            if (gateEntry.entryTime != null)
              Text('Entry Time: ${DateFormat(AppConstants.dateTimeFormat).format(gateEntry.entryTime!)}'),
            if (gateEntry.exitTime != null)
              Text('Exit Time: ${DateFormat(AppConstants.dateTimeFormat).format(gateEntry.exitTime!)}'),
            if (gateEntry.tareWeight != null)
              Text('Tare Weight: ${gateEntry.tareWeight} ${gateEntry.weightUnit?.code ?? ''}'),
            if (gateEntry.grossWeight != null)
              Text('Gross Weight: ${gateEntry.grossWeight} ${gateEntry.weightUnit?.code ?? ''}'),
            if (gateEntry.netWeight != null)
              Text('Net Weight: ${gateEntry.netWeight} ${gateEntry.weightUnit?.code ?? ''}'),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceItems() {
    final items = invoice.items;
    
    if (items == null || items.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Invoice Items',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Material')),
                  DataColumn(label: Text('Size')),
                  DataColumn(label: Text('Quantity')),
                  DataColumn(label: Text('Rate')),
                  DataColumn(label: Text('Amount')),
                  DataColumn(label: Text('Tax')),
                  DataColumn(label: Text('Total')),
                ],
                rows: items.map((item) => _buildInvoiceItemRow(item)).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  DataRow _buildInvoiceItemRow(InvoiceItemModel item) {
    final isSameState = invoice.cgstAmount > 0 && invoice.sgstAmount > 0;
    
    return DataRow(
      cells: [
        DataCell(Text(item.material?.name ?? 'N/A')),
        DataCell(Text(item.materialSize?.name ?? 'N/A')),
        DataCell(Text('${item.quantity} ${item.weightUnit?.code ?? ''}')),
        DataCell(Text('₹${item.rate.toStringAsFixed(2)}')),
        DataCell(Text('₹${item.amount.toStringAsFixed(2)}')),
        DataCell(Text(isSameState
            ? 'CGST: ₹${item.cgstAmount.toStringAsFixed(2)}\nSGST: ₹${item.sgstAmount.toStringAsFixed(2)}'
            : 'IGST: ₹${item.igstAmount.toStringAsFixed(2)}')),
        DataCell(Text('₹${item.totalAmount.toStringAsFixed(2)}')),
      ],
    );
  }

  Widget _buildTotals() {
    final isSameState = invoice.cgstAmount > 0 && invoice.sgstAmount > 0;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Invoice Totals',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Base Amount:'),
                Text('₹${invoice.baseAmount.toStringAsFixed(2)}'),
              ],
            ),
            if (isSameState) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('CGST Amount:'),
                  Text('₹${invoice.cgstAmount.toStringAsFixed(2)}'),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('SGST Amount:'),
                  Text('₹${invoice.sgstAmount.toStringAsFixed(2)}'),
                ],
              ),
            ] else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('IGST Amount:'),
                  Text('₹${invoice.igstAmount.toStringAsFixed(2)}'),
                ],
              ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Amount:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '₹${invoice.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemarks() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Remarks',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(invoice.remarks ?? ''),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Close'),
        ),
        const SizedBox(width: 16),
        if (controller.canEditInvoices && invoice.status == AppConstants.invoiceStatusDraft)
          ElevatedButton(
            onPressed: () => Get.toNamed('/billing/edit/${invoice.id}'),
            child: const Text('Edit'),
          ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: () => _printInvoice(),
          child: const Text('Print'),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;

    switch (status) {
      case AppConstants.invoiceStatusDraft:
        color = Colors.blue;
        label = 'Draft';
        break;
      case AppConstants.invoiceStatusFinal:
        color = Colors.green;
        label = 'Final';
        break;
      case AppConstants.invoiceStatusCancelled:
        color = Colors.red;
        label = 'Cancelled';
        break;
      default:
        color = Colors.grey;
        label = status;
    }

    return Chip(
      label: Text(
        label,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: color,
    );
  }

  void _printInvoice() async {
    final pdfPath = await controller.generateInvoicePdf(invoice);
    
    if (pdfPath != null) {
      // Navigate to PDF viewer
      Get.toNamed('/pdf-viewer', arguments: {'path': pdfPath, 'title': 'Invoice ${invoice.invoiceNumber}'});
    }
  }
}

