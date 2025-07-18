import 'package:get/get.dart';
import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/dashboard/bindings/dashboard_binding.dart';
import '../modules/dashboard/views/dashboard_view.dart';
import '../modules/vehicle_master/bindings/vehicle_master_binding.dart';
import '../modules/vehicle_master/views/vehicle_master_view.dart';
import '../modules/gate_entry/bindings/gate_entry_binding.dart';
import '../modules/gate_entry/views/gate_entry_view.dart';
import '../modules/weighbridge/bindings/weighbridge_binding.dart';
import '../modules/weighbridge/views/weighbridge_view.dart';
import '../modules/material_loading/bindings/material_loading_binding.dart';
import '../modules/material_loading/views/material_loading_view.dart';
import '../modules/billing/bindings/billing_binding.dart';
import '../modules/billing/views/billing_view.dart';
import 'app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: Routes.INITIAL,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.DASHBOARD,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: Routes.VEHICLE_MASTER,
      page: () => const VehicleMasterView(),
      binding: VehicleMasterBinding(),
    ),
    GetPage(
      name: Routes.GATE_ENTRY,
      page: () => const GateEntryView(),
      binding: GateEntryBinding(),
    ),
    GetPage(
      name: Routes.WEIGHBRIDGE,
      page: () => const WeighbridgeView(),
      binding: WeighbridgeBinding(),
    ),
    GetPage(
      name: Routes.MATERIAL_LOADING,
      page: () => const MaterialLoadingView(),
      binding: MaterialLoadingBinding(),
    ),
    GetPage(
      name: Routes.BILLING,
      page: () => const BillingView(),
      binding: BillingBinding(),
      children: [
        GetPage(
          name: '/create',
          page: () => const BillingView(),
        ),
        GetPage(
          name: '/edit/:id',
          page: () => const BillingView(),
        ),
        GetPage(
          name: '/view/:id',
          page: () => const BillingView(),
        ),
      ],
    ),
    // Add more routes here as they are implemented
  ];
}
