import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../../core/values/app_colors.dart';
import '../../../core/utils/responsive_builder.dart';
import '../../dashboard/views/dashboard_view.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: controller.scaffoldKey,
      appBar: AppBar(
        title: Text('Crusher Management System'),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // Show notifications
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                controller.logout();
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'profile',
                  child: Row(
                    children: [
                      Icon(Icons.person, color: AppColors.primaryColor),
                      SizedBox(width: 8),
                      Text('Profile'),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'settings',
                  child: Row(
                    children: [
                      Icon(Icons.settings, color: AppColors.primaryColor),
                      SizedBox(width: 8),
                      Text('Settings'),
                    ],
                  ),
                ),
                PopupMenuDivider(),
                PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: AppColors.primaryColor),
                      SizedBox(width: 8),
                      Text('Logout'),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      drawer: ResponsiveBuilder(
        builder: (context, deviceType, size) {
          return deviceType == DeviceScreenType.mobile
              ? _buildDrawer(context)
              : SizedBox.shrink();
        },
      ),
      body: ResponsiveBuilder(
        builder: (context, deviceType, size) {
          if (deviceType == DeviceScreenType.mobile) {
            return _buildBody(context);
          } else {
            return Row(
              children: [
                Container(
                  width: deviceType == DeviceScreenType.tablet ? 250 : 300,
                  child: _buildDrawer(context),
                ),
                Expanded(
                  child: _buildBody(context),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Obx(() => Text(controller.userName.value ?? 'User')),
            accountEmail: Obx(() => Text(controller.userRole.value ?? 'Role')),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                Icons.person,
                size: 48,
                color: AppColors.primaryColor,
              ),
            ),
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: controller.navigationItems.length,
              itemBuilder: (context, index) {
                final item = controller.navigationItems[index];
                
                // Check if item has children
                if (item.children != null && item.children!.isNotEmpty) {
                  return Obx(() {
                    final isExpanded = controller.expandedItems.contains(index);
                    
                    return Column(
                      children: [
                        ListTile(
                          leading: Icon(item.icon),
                          title: Text(item.title),
                          trailing: Icon(
                            isExpanded ? Icons.expand_less : Icons.expand_more,
                          ),
                          onTap: () => controller.toggleExpanded(index),
                        ),
                        if (isExpanded)
                          ...item.children!.map((child) {
                            return ListTile(
                              leading: Icon(child.icon),
                              title: Text(child.title),
                              contentPadding: EdgeInsets.only(left: 32, right: 16),
                              onTap: () {
                                if (child.route != null) {
                                  controller.navigateTo(child.route!);
                                }
                              },
                            );
                          }).toList(),
                      ],
                    );
                  });
                } else {
                  return ListTile(
                    leading: Icon(item.icon),
                    title: Text(item.title),
                    onTap: () {
                      if (item.route != null) {
                        controller.navigateTo(item.route!);
                      }
                    },
                  );
                }
              },
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: controller.logout,
          ),
          SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return DashboardView();
  }
}

