import 'package:get/get.dart';
import '../controllers/billing_controller.dart';
import '../../../data/repositories/invoice_repository.dart';
import '../../../data/repositories/gate_entry_repository.dart';
import '../../../data/repositories/material_loading_repository.dart';
import '../../../data/services/pdf_service.dart';

class BillingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InvoiceRepository>(() => InvoiceRepository());
    Get.lazyPut<GateEntryRepository>(() => GateEntryRepository());
    Get.lazyPut<MaterialLoadingRepository>(() => MaterialLoadingRepository());
    Get.lazyPut<PdfService>(() => PdfService());
    Get.lazyPut<BillingController>(() => BillingController());
  }
}

