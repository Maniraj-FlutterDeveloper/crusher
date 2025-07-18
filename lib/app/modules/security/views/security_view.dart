import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/security_controller.dart';
import 'components/audit_logs_view.dart';
import 'components/security_settings_view.dart';
import 'components/user_roles_view.dart';
import '../../../core/utils/responsive_builder.dart';

class SecurityView extends GetView<SecurityController> {
  const SecurityView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Security & Audit'),
      ),
      body: ResponsiveBuilder(
        builder: (context, deviceType, size) {
          if (deviceType == DeviceScreenType.mobile) {
            return _buildMobileLayout();
          } else {
            return _buildDesktopLayout();
          }
        },
      ),
    );
  }
  
  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildTabBar(),
        Expanded(
          child: Obx(() {
            switch (controller.selectedTab.value) {
              case 'audit_logs':
                return const AuditLogsView();
              case 'security_settings':
                return const SecuritySettingsView();
              case 'user_roles':
                return const UserRolesView();
              default:
                return const AuditLogsView();
            }
          }),
        ),
      ],
    );
  }
  
  Widget _buildDesktopLayout() {
    return Column(
      children: [
        _buildTabBar(),
        Expanded(
          child: Obx(() {
            switch (controller.selectedTab.value) {
              case 'audit_logs':
                return const AuditLogsView();
              case 'security_settings':
                return const SecuritySettingsView();
              case 'user_roles':
                return const UserRolesView();
              default:
                return const AuditLogsView();
            }
          }),
        ),
      ],
    );
  }
  
  Widget _buildTabBar() {
    return Obx(() {
      return Container(
        color: Colors.grey[200],
        child: Row(
          children: [
            _buildTabButton(
              'audit_logs',
              'Audit Logs',
              Icons.history,
              controller.canViewAuditLogs,
            ),
            _buildTabButton(
              'user_roles',
              'User Roles',
              Icons.people,
              controller.canAccessSecuritySettings,
            ),
            _buildTabButton(
              'security_settings',
              'Security Settings',
              Icons.security,
              controller.canAccessSecuritySettings,
            ),
          ],
        ),
      );
    });
  }
  
  Widget _buildTabButton(String tabId, String label, IconData icon, bool hasPermission) {
    if (!hasPermission) {
      return const SizedBox.shrink();
    }
    
    final isSelected = controller.selectedTab.value == tabId;
    
    return Expanded(
      child: InkWell(
        onTap: () => controller.changeTab(tabId),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            border: Border(
              bottom: BorderSide(
                color: isSelected ? Theme.of(Get.context!).primaryColor : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? Theme.of(Get.context!).primaryColor : Colors.grey,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Theme.of(Get.context!).primaryColor : Colors.grey,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

