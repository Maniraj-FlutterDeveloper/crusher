import 'package:get/get.dart';
import 'app_routes.dart';

// Import all view files
import '../modules/auth/views/login_view.dart';
import '../modules/home/views/home_view.dart';
import '../modules/dashboard/views/dashboard_view.dart';

// Import all binding files
import '../modules/auth/bindings/auth_binding.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/dashboard/bindings/dashboard_binding.dart';

class AppPages {
  static const INITIAL = Routes.LOGIN;

  static final routes = [
    // Auth routes
    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    
    // Main routes
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
    
    // Additional routes will be added as we implement each module
  ];
}

