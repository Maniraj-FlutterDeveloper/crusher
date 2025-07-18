import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/values/app_constants.dart';
import '../../../../data/models/gate_entry_model.dart';
import '../../../../data/models/invoice_model.dart';
import '../../../../data/models/material_model.dart';
import '../../controllers/billing_controller.dart';
import 'invoice_item_form.dart';

class InvoiceFormView extends GetView<BillingController> {
  final bool isEditing;

  const InvoiceFormView({
    Key? key,
    this.isEditing = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppConstants.defaultElevation,
      margin: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Form(
          key: controller.invoiceFormKey,
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
                      _buildGateEntrySection(),
                      const SizedBox(height: 16),
                      _buildInvoiceDetailsSection(),
                      const SizedBox(height: 16),
                      _buildBuyerSection(),
                      const SizedBox(height: 16),
                      _buildInvoiceItemsSection(),
                      const SizedBox(height: 16),
                      _buildTotalsSection(),
                      const SizedBox(height: 16),
                      _buildRemarksSection(),
                    ],
                  ),
                ),
              ),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          isEditing ? 'Edit Invoice' : 'Create Invoice',
          style: const TextStyle(
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

  Widget _buildGateEntrySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gate Entry Details',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controller.sessionIdController,
                decoration: const InputDecoration(
                  labelText: 'Session ID',
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: () => _showGateEntrySearchDialog(),
              child: const Text('Search Gate Entry'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controller.vehicleNumberController,
                decoration: const InputDecoration(
                  labelText: 'Vehicle Number',
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: controller.driverNameController,
                decoration: const InputDecoration(
                  labelText: 'Driver Name',
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInvoiceDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Invoice Details',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controller.invoiceNumberController,
                decoration: const InputDecoration(
                  labelText: 'Invoice Number',
                  border: OutlineInputBorder(),
                ),
                validator: controller.validateInvoiceNumber,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: controller.invoiceDateController,
                decoration: InputDecoration(
                  labelText: 'Invoice Date',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  ),
                ),
                validator: controller.validateInvoiceDate,
                readOnly: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBuyerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Buyer Details',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            ElevatedButton(
              onPressed: () => _showAddBuyerDialog(),
              child: const Text('Add New Buyer'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Obx(() {
          if (controller.buyers.isEmpty) {
            return const Center(
              child: Text('No buyers available'),
            );
          }

          return DropdownButtonFormField<BuyerModel>(
            decoration: const InputDecoration(
              labelText: 'Select Buyer',
              border: OutlineInputBorder(),
            ),
            value: controller.selectedBuyer.value,
            onChanged: (value) {
              if (value != null) {
                controller.selectedBuyer.value = value;
              }
            },
            items: controller.buyers
                .map((buyer) => DropdownMenuItem<BuyerModel>(
                      value: buyer,
                      child: Text(buyer.name),
                    ))
                .toList(),
          );
        }),
        const SizedBox(height: 16),
        Obx(() {
          if (controller.selectedBuyer.value == null) {
            return const SizedBox.shrink();
          }

          final buyer = controller.selectedBuyer.value!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('GSTIN: ${buyer.gstin ?? 'N/A'}'),
                            const SizedBox(height: 4),
                            Text('Address: ${buyer.address ?? 'N/A'}'),
                            const SizedBox(height: 4),
                            Text('${buyer.city ?? ''}, ${buyer.state ?? ''} ${buyer.pincode ?? ''}'),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Contact: ${buyer.contactPerson ?? 'N/A'}'),
                            const SizedBox(height: 4),
                            Text('Mobile: ${buyer.contactMobile ?? 'N/A'}'),
                            const SizedBox(height: 4),
                            Text('Email: ${buyer.contactEmail ?? 'N/A'}'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Same State GST:'),
                  const SizedBox(width: 8),
                  Obx(() => Switch(
                        value: controller.isSameState.value,
                        onChanged: (value) {
                          controller.isSameState.value = value;
                          
                          // Recalculate tax amounts for all items
                          for (int i = 0; i < controller.invoiceItems.length; i++) {
                            final item = controller.invoiceItems[i];
                            final updatedItem = controller.calculateInvoiceItemAmounts(item);
                            controller.updateInvoiceItem(i, updatedItem);
                          }
                        },
                      )),
                ],
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildInvoiceItemsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Invoice Items',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            ElevatedButton(
              onPressed: () => _showAddInvoiceItemDialog(),
              child: const Text('Add Item'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Obx(() {
          if (controller.invoiceItems.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No items added to this invoice'),
              ),
            );
          }

          return SingleChildScrollView(
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
                DataColumn(label: Text('Actions')),
              ],
              rows: controller.invoiceItems
                  .asMap()
                  .entries
                  .map((entry) => _buildInvoiceItemRow(entry.key, entry.value))
                  .toList(),
            ),
          );
        }),
      ],
    );
  }

  DataRow _buildInvoiceItemRow(int index, InvoiceItemModel item) {
    return DataRow(
      cells: [
        DataCell(Text(item.material?.name ?? 'N/A')),
        DataCell(Text(item.materialSize?.name ?? 'N/A')),
        DataCell(Text('${item.quantity} ${item.weightUnit?.code ?? ''}')),
        DataCell(Text('₹${item.rate.toStringAsFixed(2)}')),
        DataCell(Text('₹${item.amount.toStringAsFixed(2)}')),
        DataCell(Text(controller.isSameState.value
            ? 'CGST: ₹${item.cgstAmount.toStringAsFixed(2)}\nSGST: ₹${item.sgstAmount.toStringAsFixed(2)}'
            : 'IGST: ₹${item.igstAmount.toStringAsFixed(2)}')),
        DataCell(Text('₹${item.totalAmount.toStringAsFixed(2)}')),
        DataCell(Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showEditInvoiceItemDialog(index, item),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _confirmDeleteInvoiceItem(index),
            ),
          ],
        )),
      ],
    );
  }

  Widget _buildTotalsSection() {
    return Obx(() {
      if (controller.invoiceItems.isEmpty) {
        return const SizedBox.shrink();
      }

      double baseAmount = 0;
      double cgstAmount = 0;
      double sgstAmount = 0;
      double igstAmount = 0;
      double totalAmount = 0;

      for (final item in controller.invoiceItems) {
        baseAmount += item.amount;
        cgstAmount += item.cgstAmount;
        sgstAmount += item.sgstAmount;
        igstAmount += item.igstAmount;
        totalAmount += item.totalAmount;
      }

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
                  Text('₹${baseAmount.toStringAsFixed(2)}'),
                ],
              ),
              if (controller.isSameState.value) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('CGST Amount:'),
                    Text('₹${cgstAmount.toStringAsFixed(2)}'),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('SGST Amount:'),
                    Text('₹${sgstAmount.toStringAsFixed(2)}'),
                  ],
                ),
              ] else
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('IGST Amount:'),
                    Text('₹${igstAmount.toStringAsFixed(2)}'),
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
                    '₹${totalAmount.toStringAsFixed(2)}',
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
    });
  }

  Widget _buildRemarksSection() {
    return Column(
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
        TextFormField(
          controller: controller.remarksController,
          decoration: const InputDecoration(
            hintText: 'Enter any additional remarks',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Obx(() => Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: controller.isProcessing.value ? null : () => Get.back(),
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: controller.isProcessing.value
                  ? null
                  : () => _saveAsDraft(),
              child: controller.isProcessing.value
                  ? const CircularProgressIndicator()
                  : const Text('Save as Draft'),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: controller.isProcessing.value
                  ? null
                  : () => _saveAsFinal(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: controller.isProcessing.value
                  ? const CircularProgressIndicator()
                  : const Text('Save as Final'),
            ),
          ],
        ));
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: controller.invoiceDateController.text.isNotEmpty
          ? DateFormat(AppConstants.dateFormat).parse(controller.invoiceDateController.text)
          : DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      controller.invoiceDateController.text = DateFormat(AppConstants.dateFormat).format(picked);
    }
  }

  void _showGateEntrySearchDialog() {
    final TextEditingController searchController = TextEditingController();
    final RxList<GateEntryModel> searchResults = <GateEntryModel>[].obs;
    final RxBool isSearching = false.obs;

    void performSearch() async {
      if (searchController.text.isEmpty) return;

      isSearching.value = true;
      final results = await controller.searchGateEntries(searchController.text);
      searchResults.assignAll(results);
      isSearching.value = false;
    }

    Get.dialog(
      Dialog(
        child: Container(
          width: 600,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Search Gate Entry',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        hintText: 'Enter Session ID or Vehicle Number',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => performSearch(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: performSearch,
                    child: const Text('Search'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Obx(() {
                if (isSearching.value) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (searchResults.isEmpty) {
                  return const Center(
                    child: Text('No gate entries found'),
                  );
                }

                return SizedBox(
                  height: 300,
                  child: ListView.builder(
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      final gateEntry = searchResults[index];
                      return ListTile(
                        title: Text('Session ID: ${gateEntry.sessionId}'),
                        subtitle: Text(
                          'Vehicle: ${gateEntry.vehicle?.vehicleNumber ?? 'N/A'}\n'
                          'Driver: ${gateEntry.driverName ?? 'N/A'}\n'
                          'Status: ${gateEntry.status}',
                        ),
                        isThreeLine: true,
                        onTap: () {
                          controller.setGateEntryForInvoice(gateEntry);
                          Get.back();
                        },
                      );
                    },
                  ),
                );
              }),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddBuyerDialog() {
    // Reset form
    controller.clearBuyerForm();

    Get.dialog(
      Dialog(
        child: Container(
          width: 600,
          padding: const EdgeInsets.all(16),
          child: Form(
            key: controller.buyerFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Add New Buyer',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: controller.buyerNameController,
                  decoration: const InputDecoration(
                    labelText: 'Buyer Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: controller.validateBuyerName,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: controller.gstinController,
                  decoration: const InputDecoration(
                    labelText: 'GSTIN',
                    border: OutlineInputBorder(),
                  ),
                  validator: controller.validateGstin,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: controller.addressController,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: controller.cityController,
                        decoration: const InputDecoration(
                          labelText: 'City',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: controller.stateController,
                        decoration: const InputDecoration(
                          labelText: 'State',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: controller.pincodeController,
                        decoration: const InputDecoration(
                          labelText: 'Pincode',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: controller.contactPersonController,
                  decoration: const InputDecoration(
                    labelText: 'Contact Person',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: controller.contactMobileController,
                        decoration: const InputDecoration(
                          labelText: 'Contact Mobile',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: controller.contactEmailController,
                        decoration: const InputDecoration(
                          labelText: 'Contact Email',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 16),
                    Obx(() => ElevatedButton(
                          onPressed: controller.isProcessing.value
                              ? null
                              : () async {
                                  final success = await controller.saveBuyer();
                                  if (success) {
                                    Get.back();
                                  }
                                },
                          child: controller.isProcessing.value
                              ? const CircularProgressIndicator()
                              : const Text('Save'),
                        )),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddInvoiceItemDialog() {
    Get.dialog(
      Dialog(
        child: Container(
          width: 600,
          padding: const EdgeInsets.all(16),
          child: InvoiceItemForm(
            onSave: (item) {
              controller.addInvoiceItem(item);
              Get.back();
            },
            onCancel: () => Get.back(),
          ),
        ),
      ),
    );
  }

  void _showEditInvoiceItemDialog(int index, InvoiceItemModel item) {
    Get.dialog(
      Dialog(
        child: Container(
          width: 600,
          padding: const EdgeInsets.all(16),
          child: InvoiceItemForm(
            item: item,
            onSave: (updatedItem) {
              controller.updateInvoiceItem(index, updatedItem);
              Get.back();
            },
            onCancel: () => Get.back(),
          ),
        ),
      ),
    );
  }

  void _confirmDeleteInvoiceItem(int index) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Item'),
        content: const Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.removeInvoiceItem(index);
              Get.back();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _saveAsDraft() async {
    final success = await controller.saveInvoice(AppConstants.invoiceStatusDraft);
    if (success) {
      Get.back();
    }
  }

  void _saveAsFinal() async {
    final success = await controller.saveInvoice(AppConstants.invoiceStatusFinal);
    if (success) {
      Get.back();
    }
  }
}

