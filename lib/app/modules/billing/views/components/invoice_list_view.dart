import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/values/app_constants.dart';
import '../../../../data/models/invoice_model.dart';
import '../../controllers/billing_controller.dart';

class InvoiceListView extends GetView<BillingController> {
  const InvoiceListView({Key? key}) : super(key: key);

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
            _buildSearchBar(),
            _buildFilterBar(),
            const SizedBox(height: 16),
            Expanded(
              child: _buildInvoiceTable(),
            ),
            _buildPagination(),
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
          'Invoices',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (controller.canAddInvoices)
          ElevatedButton.icon(
            onPressed: () => Get.toNamed('/billing/create'),
            icon: const Icon(Icons.add),
            label: const Text('Create Invoice'),
          ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search by invoice number, vehicle number, or buyer name',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: controller.clearSearch,
                )
              : const SizedBox.shrink()),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          ),
        ),
        onChanged: controller.searchInvoices,
      ),
    );
  }

  Widget _buildFilterBar() {
    return Row(
      children: [
        DropdownButton<String>(
          hint: const Text('Filter by Status'),
          value: controller.statusFilter.value.isEmpty ? null : controller.statusFilter.value,
          onChanged: (value) {
            if (value != null) {
              controller.filterByStatus(value);
            }
          },
          items: [
            DropdownMenuItem<String>(
              value: AppConstants.invoiceStatusDraft,
              child: const Text('Draft'),
            ),
            DropdownMenuItem<String>(
              value: AppConstants.invoiceStatusFinal,
              child: const Text('Final'),
            ),
            DropdownMenuItem<String>(
              value: AppConstants.invoiceStatusCancelled,
              child: const Text('Cancelled'),
            ),
          ],
        ),
        const SizedBox(width: 16),
        Obx(() => controller.statusFilter.value.isNotEmpty
            ? TextButton.icon(
                icon: const Icon(Icons.clear),
                label: const Text('Clear Status Filter'),
                onPressed: controller.clearStatusFilter,
              )
            : const SizedBox.shrink()),
        const Spacer(),
        TextButton.icon(
          icon: const Icon(Icons.date_range),
          label: const Text('Date Range'),
          onPressed: () => _showDateRangePicker(context),
        ),
        Obx(() => controller.startDate.value != null && controller.endDate.value != null
            ? TextButton.icon(
                icon: const Icon(Icons.clear),
                label: const Text('Clear Date Filter'),
                onPressed: controller.clearDateRangeFilter,
              )
            : const SizedBox.shrink()),
      ],
    );
  }

  Widget _buildInvoiceTable() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final invoices = controller.getPaginatedInvoices();

      if (invoices.isEmpty) {
        return const Center(
          child: Text(
            'No invoices found',
            style: TextStyle(fontSize: 16),
          ),
        );
      }

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: DataTable(
            columns: [
              DataColumn(
                label: const Text('Invoice Number'),
                onSort: (_, __) => controller.changeSortColumn('invoice_number'),
              ),
              DataColumn(
                label: const Text('Date'),
                onSort: (_, __) => controller.changeSortColumn('invoice_date'),
              ),
              DataColumn(
                label: const Text('Buyer'),
                onSort: (_, __) => controller.changeSortColumn('buyer_name'),
              ),
              DataColumn(
                label: const Text('Vehicle Number'),
                onSort: (_, __) => controller.changeSortColumn('vehicle_number'),
              ),
              DataColumn(
                label: const Text('Amount'),
                onSort: (_, __) => controller.changeSortColumn('total_amount'),
              ),
              DataColumn(
                label: const Text('Status'),
                onSort: (_, __) => controller.changeSortColumn('status'),
              ),
              const DataColumn(
                label: Text('Actions'),
              ),
            ],
            rows: invoices.map((invoice) => _buildInvoiceRow(invoice)).toList(),
          ),
        ),
      );
    });
  }

  DataRow _buildInvoiceRow(InvoiceModel invoice) {
    return DataRow(
      cells: [
        DataCell(Text(invoice.invoiceNumber)),
        DataCell(Text(DateFormat(AppConstants.dateFormat).format(invoice.invoiceDate))),
        DataCell(Text(invoice.buyer?.name ?? 'N/A')),
        DataCell(Text(invoice.gateEntry?.vehicle?.vehicleNumber ?? 'N/A')),
        DataCell(Text('₹${invoice.totalAmount.toStringAsFixed(2)}')),
        DataCell(_buildStatusChip(invoice.status)),
        DataCell(Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.visibility),
              tooltip: 'View Invoice',
              onPressed: () => _viewInvoice(invoice),
            ),
            if (controller.canEditInvoices && invoice.status == AppConstants.invoiceStatusDraft)
              IconButton(
                icon: const Icon(Icons.edit),
                tooltip: 'Edit Invoice',
                onPressed: () => _editInvoice(invoice),
              ),
            IconButton(
              icon: const Icon(Icons.print),
              tooltip: 'Print Invoice',
              onPressed: () => _printInvoice(invoice),
            ),
            if (controller.canEditInvoices && invoice.status == AppConstants.invoiceStatusDraft)
              IconButton(
                icon: const Icon(Icons.check_circle),
                tooltip: 'Finalize Invoice',
                onPressed: () => _finalizeInvoice(invoice),
              ),
            if (controller.canEditInvoices && invoice.status == AppConstants.invoiceStatusDraft)
              IconButton(
                icon: const Icon(Icons.cancel),
                tooltip: 'Cancel Invoice',
                onPressed: () => _cancelInvoice(invoice),
              ),
          ],
        )),
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

  Widget _buildPagination() {
    return Obx(() => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Showing ${controller.getPaginatedInvoices().length} of ${controller.filteredInvoices.length} invoices'),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: controller.currentPage.value > 0
                      ? () => controller.changePage(controller.currentPage.value - 1)
                      : null,
                ),
                Text('${controller.currentPage.value + 1} of ${controller.totalPages.value}'),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: controller.currentPage.value < controller.totalPages.value - 1
                      ? () => controller.changePage(controller.currentPage.value + 1)
                      : null,
                ),
                const SizedBox(width: 16),
                DropdownButton<int>(
                  value: controller.rowsPerPage.value,
                  onChanged: controller.changeRowsPerPage,
                  items: AppConstants.availablePageSizes
                      .map((pageSize) => DropdownMenuItem<int>(
                            value: pageSize,
                            child: Text('$pageSize per page'),
                          ))
                      .toList(),
                ),
              ],
            ),
          ],
        ));
  }

  void _showDateRangePicker(BuildContext context) async {
    final initialDateRange = DateTimeRange(
      start: controller.startDate.value ?? DateTime.now().subtract(const Duration(days: 30)),
      end: controller.endDate.value ?? DateTime.now(),
    );

    final pickedDateRange = await showDateRangePicker(
      context: context,
      initialDateRange: initialDateRange,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDateRange != null) {
      controller.filterByDateRange(pickedDateRange.start, pickedDateRange.end);
    }
  }

  void _viewInvoice(InvoiceModel invoice) {
    // Navigate to invoice details view
    Get.toNamed('/billing/view/${invoice.id}');
  }

  void _editInvoice(InvoiceModel invoice) {
    // Navigate to invoice edit view
    Get.toNamed('/billing/edit/${invoice.id}');
  }

  void _printInvoice(InvoiceModel invoice) async {
    final pdfPath = await controller.generateInvoicePdf(invoice);
    
    if (pdfPath != null) {
      // Navigate to PDF viewer
      Get.toNamed('/pdf-viewer', arguments: {'path': pdfPath, 'title': 'Invoice ${invoice.invoiceNumber}'});
    }
  }

  void _finalizeInvoice(InvoiceModel invoice) {
    Get.dialog(
      AlertDialog(
        title: const Text('Finalize Invoice'),
        content: const Text(
          'Are you sure you want to finalize this invoice? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.updateInvoiceStatus(invoice.id!, AppConstants.invoiceStatusFinal);
            },
            child: const Text('Finalize'),
          ),
        ],
      ),
    );
  }

  void _cancelInvoice(InvoiceModel invoice) {
    Get.dialog(
      AlertDialog(
        title: const Text('Cancel Invoice'),
        content: const Text(
          'Are you sure you want to cancel this invoice? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.updateInvoiceStatus(invoice.id!, AppConstants.invoiceStatusCancelled);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Yes, Cancel Invoice'),
          ),
        ],
      ),
    );
  }
}

