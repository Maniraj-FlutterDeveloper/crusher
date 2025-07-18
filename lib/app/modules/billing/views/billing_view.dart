import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/billing_controller.dart';
import 'components/invoice_list_view.dart';
import 'components/invoice_form_view.dart';
import 'components/invoice_details_view.dart';

class BillingView extends GetView<BillingController> {
  const BillingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the route parameters
    final params = Get.parameters;
    final action = params['action'];
    final id = params['id'];

    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle(action, id)),
      ),
      body: _buildBody(action, id),
    );
  }

  String _getTitle(String? action, String? id) {
    if (action == 'create') {
      return 'Create Invoice';
    } else if (action == 'edit' && id != null) {
      return 'Edit Invoice';
    } else if (action == 'view' && id != null) {
      return 'View Invoice';
    } else {
      return 'Billing';
    }
  }

  Widget _buildBody(String? action, String? id) {
    if (action == 'create') {
      return const InvoiceFormView();
    } else if (action == 'edit' && id != null) {
      // Find the invoice by ID
      final invoiceId = int.tryParse(id);
      if (invoiceId != null) {
        final invoice = controller.invoices.firstWhereOrNull((inv) => inv.id == invoiceId);
        if (invoice != null) {
          controller.currentInvoice.value = invoice;
          return const InvoiceFormView(isEditing: true);
        }
      }
      
      // Invoice not found
      return const Center(
        child: Text('Invoice not found'),
      );
    } else if (action == 'view' && id != null) {
      // Find the invoice by ID
      final invoiceId = int.tryParse(id);
      if (invoiceId != null) {
        final invoice = controller.invoices.firstWhereOrNull((inv) => inv.id == invoiceId);
        if (invoice != null) {
          return InvoiceDetailsView(invoice: invoice);
        }
      }
      
      // Invoice not found
      return const Center(
        child: Text('Invoice not found'),
      );
    } else {
      // Default view - list of invoices
      return const InvoiceListView();
    }
  }
}

