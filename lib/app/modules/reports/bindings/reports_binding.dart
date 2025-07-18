import 'package:get/get.dart';
import '../controllers/reports_controller.dart';
import '../../../data/repositories/gate_entry_repository.dart';
import '../../../data/repositories/material_loading_repository.dart';
import '../../../data/repositories/invoice_repository.dart';
import '../../../data/services/pdf_service.dart';
import '../../../data/services/excel_service.dart';

class ReportsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GateEntryRepository>(() => GateEntryRepository());
    Get.lazyPut<MaterialLoadingRepository>(() => MaterialLoadingRepository());
    Get.lazyPut<InvoiceRepository>(() => InvoiceRepository());
    Get.lazyPut<PdfService>(() => PdfService());
    Get.lazyPut<ExcelService>(() => ExcelService());
    Get.lazyPut<ReportsController>(() => ReportsController());
  }
}

