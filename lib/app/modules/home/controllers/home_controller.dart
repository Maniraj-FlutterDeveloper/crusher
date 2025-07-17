import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/auth_service.dart';
import '../../../routes/app_routes.dart';
import '../../../core/values/app_constants.dart';

class HomeController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  
  final RxInt selectedIndex = 0.obs;
  final RxBool isDrawerOpen = false.obs;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  
  // User info
  final Rx<String?> userName = Rx<String?>(null);
  final Rx<String?> userRole = Rx<String?>(null);
  
  // Navigation items
  final List<NavigationItem> navigationItems = [
    NavigationItem(
      title: 'Dashboard',
      icon: Icons.dashboard,
      route: Routes.DASHBOARD,
    ),
    NavigationItem(
      title: 'Master Configuration',
      icon: Icons.settings,
      children: [
        NavigationItem(
          title: 'Material Master',
          icon: Icons.category,
          route: Routes.MATERIAL_MASTER,
        ),
        NavigationItem(
          title: 'Stone Size Master',
          icon: Icons.straighten,
          route: Routes.STONE_SIZE_MASTER,
        ),
        NavigationItem(
          title: 'Supplier Master',
          icon: Icons.local_shipping,
          route: Routes.SUPPLIER_MASTER,
        ),
        NavigationItem(
          title: 'Buyer Master',
          icon: Icons.people,
          route: Routes.BUYER_MASTER,
        ),
        NavigationItem(
          title: 'Vehicle Master',
          icon: Icons.directions_car,
          route: Routes.VEHICLE_MASTER,
        ),
        NavigationItem(
          title: 'Tax Configuration',
          icon: Icons.receipt,
          route: Routes.TAX_CONFIGURATION,
        ),
      ],
    ),
    NavigationItem(
      title: 'Gate Entry',
      icon: Icons.door_sliding,
      route: Routes.GATE_ENTRY,
    ),
    NavigationItem(
      title: 'Weighbridge',
      icon: Icons.scale,
      route: Routes.WEIGHBRIDGE,
    ),
    NavigationItem(
      title: 'Material Loading',
      icon: Icons.local_shipping,
      route: Routes.MATERIAL_LOADING,
    ),
    NavigationItem(
      title: 'Billing',
      icon: Icons.receipt_long,
      route: Routes.BILLING,
    ),
    NavigationItem(
      title: 'Reports',
      icon: Icons.bar_chart,
      route: Routes.REPORTS,
    ),
    NavigationItem(
      title: 'User Management',
      icon: Icons.people,
      route: Routes.USER_MANAGEMENT,
      requiredRole: AppConstants.roleAdmin,
    ),
    NavigationItem(
      title: 'Security & Audit',
      icon: Icons.security,
      route: Routes.SECURITY_SETTINGS,
      requiredRole: AppConstants.roleAdmin,
    ),
  ];
  
  // Expanded navigation items
  final RxList<int> expandedItems = <int>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    loadUserInfo();
  }
  
  // Load user info
  void loadUserInfo() {
    if (_authService.currentUser != null) {
      userName.value = _authService.currentUser!.name;
      
      if (_authService.currentUser!.roles != null && _authService.currentUser!.roles!.isNotEmpty) {
        userRole.value = _authService.currentUser!.roles!.first.name;
      }
    }
  }
  
  // Toggle drawer
  void toggleDrawer() {
    if (scaffoldKey.currentState!.isDrawerOpen) {
      scaffoldKey.currentState!.closeDrawer();
    } else {
      scaffoldKey.currentState!.openDrawer();
    }
  }
  
  // Toggle expanded item
  void toggleExpanded(int index) {
    if (expandedItems.contains(index)) {
      expandedItems.remove(index);
    } else {
      expandedItems.add(index);
    }
  }
  
  // Navigate to route
  void navigateTo(String route) {
    Get.toNamed(route);
    if (Get.context != null && Scaffold.of(Get.context!).isDrawerOpen) {
      Navigator.pop(Get.context!);
    }
  }
  
  // Logout
  void logout() {
    _authService.logout();
    Get.offAllNamed(Routes.LOGIN);
  }
  
  // Check if user has role
  Future<bool> hasRole(String roleName) async {
    return await _authService.hasRole(roleName);
  }
}

class NavigationItem {
  final String title;
  final IconData icon;
  final String? route;
  final List<NavigationItem>? children;
  final String? requiredRole;
  
  NavigationItem({
    required this.title,
    required this.icon,
    this.route,
    this.children,
    this.requiredRole,
  });
}

