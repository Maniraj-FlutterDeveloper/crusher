import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/user_management_controller.dart';
import '../../../core/utils/responsive_builder.dart';
import '../../../core/values/app_colors.dart';
import '../../../global_widgets/custom_app_bar.dart';
import '../../../global_widgets/custom_drawer.dart';
import '../../../global_widgets/master_data_table.dart';
import '../../../global_widgets/responsive_layout.dart';

class UserManagementView extends GetView<UserManagementController> {
  const UserManagementView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialize controller if not already initialized
    if (!Get.isRegistered<UserManagementController>()) {
      Get.put(UserManagementController());
    }
    
    return Scaffold(
      appBar: CustomAppBar(
        title: 'User Management',
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showUserForm(context),
            tooltip: 'Add New User',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.refreshUsers,
            tooltip: 'Refresh',
          ),
        ],
      ),
      drawer: const CustomDrawer(),
      body: ResponsiveBuilder(
        builder: (context, deviceType, size) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 16),
                _buildSearchAndFilter(context),
                const SizedBox(height: 16),
                Expanded(
                  child: _buildUsersTable(context),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showUserForm(context),
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'User Management',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Manage users and their access permissions',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textLightColor,
              ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            onChanged: controller.filterUsers,
            decoration: InputDecoration(
              hintText: 'Search users...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 16),
        DropdownButton<String>(
          value: controller.filterRole.value,
          onChanged: (value) {
            if (value != null) {
              controller.filterRole.value = value;
              controller.filterUsers(controller.searchQuery.value);
            }
          },
          items: const [
            DropdownMenuItem(
              value: 'All',
              child: Text('All Roles'),
            ),
            DropdownMenuItem(
              value: 'Admin',
              child: Text('Admin'),
            ),
            DropdownMenuItem(
              value: 'Supervisor',
              child: Text('Supervisor'),
            ),
            DropdownMenuItem(
              value: 'Operator',
              child: Text('Operator'),
            ),
            DropdownMenuItem(
              value: 'Billing',
              child: Text('Billing'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUsersTable(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }
      
      if (controller.users.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.people,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No users found',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () => _showUserForm(context),
                icon: const Icon(Icons.add),
                label: const Text('Add User'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: AppColors.primaryColor,
                ),
              ),
            ],
          ),
        );
      }
      
      return MasterDataTable(
        columns: const [
          DataColumn(label: Text('Name')),
          DataColumn(label: Text('Username')),
          DataColumn(label: Text('Email')),
          DataColumn(label: Text('Role')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Last Login')),
          DataColumn(label: Text('Actions')),
        ],
        rows: controller.filteredUsers.map((user) {
          return DataRow(
            cells: [
              DataCell(Text('${user.firstName} ${user.lastName}')),
              DataCell(Text(user.username)),
              DataCell(Text(user.email)),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getRoleColor(user.role).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    user.role,
                    style: TextStyle(
                      color: _getRoleColor(user.role),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: user.isActive
                        ? AppColors.successColor.withOpacity(0.2)
                        : AppColors.errorColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    user.isActive ? 'Active' : 'Inactive',
                    style: TextStyle(
                      color: user.isActive
                          ? AppColors.successColor
                          : AppColors.errorColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              DataCell(Text(
                user.lastLoginAt != null
                    ? '${user.lastLoginAt!.day}/${user.lastLoginAt!.month}/${user.lastLoginAt!.year}'
                    : 'Never',
              )),
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: () => _showUserForm(context, user),
                      tooltip: 'Edit',
                      color: AppColors.primaryColor,
                    ),
                    IconButton(
                      icon: const Icon(Icons.lock, size: 20),
                      onPressed: () => _showResetPasswordDialog(context, user),
                      tooltip: 'Reset Password',
                      color: Colors.orange,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 20),
                      onPressed: () => _confirmDelete(context, user),
                      tooltip: 'Delete',
                      color: AppColors.errorColor,
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
        onSort: (columnIndex, ascending) {
          controller.sortUsers(columnIndex, ascending);
        },
      );
    });
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'Admin':
        return Colors.purple;
      case 'Supervisor':
        return Colors.blue;
      case 'Operator':
        return Colors.green;
      case 'Billing':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _showUserForm(BuildContext context, [dynamic user]) {
    final isEditing = user != null;
    
    final firstNameController = TextEditingController(
      text: isEditing ? user.firstName : '',
    );
    final lastNameController = TextEditingController(
      text: isEditing ? user.lastName : '',
    );
    final usernameController = TextEditingController(
      text: isEditing ? user.username : '',
    );
    final emailController = TextEditingController(
      text: isEditing ? user.email : '',
    );
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    
    final roleController = isEditing ? user.role.obs : 'Operator'.obs;
    final isActiveController = isEditing ? user.isActive.obs : true.obs;
    
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: 600,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEditing ? 'Edit User' : 'Add New User',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: firstNameController,
                      decoration: const InputDecoration(
                        labelText: 'First Name',
                        hintText: 'Enter first name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: lastNameController,
                      decoration: const InputDecoration(
                        labelText: 'Last Name',
                        hintText: 'Enter last name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  hintText: 'Enter username',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter email address',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              if (!isEditing) ...[
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter password',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirm Password',
                    hintText: 'Confirm password',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Row(
                children: [
                  Expanded(
                    child: Obx(() => DropdownButtonFormField<String>(
                      value: roleController.value,
                      decoration: const InputDecoration(
                        labelText: 'Role',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Admin',
                          child: Text('Admin'),
                        ),
                        DropdownMenuItem(
                          value: 'Supervisor',
                          child: Text('Supervisor'),
                        ),
                        DropdownMenuItem(
                          value: 'Operator',
                          child: Text('Operator'),
                        ),
                        DropdownMenuItem(
                          value: 'Billing',
                          child: Text('Billing'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          roleController.value = value;
                        }
                      },
                    )),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Obx(() => SwitchListTile(
                      title: const Text('Status'),
                      subtitle: Text(
                        isActiveController.value ? 'Active' : 'Inactive',
                      ),
                      value: isActiveController.value,
                      onChanged: (value) {
                        isActiveController.value = value;
                      },
                      activeColor: AppColors.primaryColor,
                    )),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (!isEditing && passwordController.text != confirmPasswordController.text) {
                        Get.snackbar(
                          'Error',
                          'Passwords do not match',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: AppColors.errorColor,
                          colorText: Colors.white,
                        );
                        return;
                      }
                      
                      final userData = {
                        'firstName': firstNameController.text,
                        'lastName': lastNameController.text,
                        'username': usernameController.text,
                        'email': emailController.text,
                        'role': roleController.value,
                        'isActive': isActiveController.value,
                      };
                      
                      if (!isEditing) {
                        userData['password'] = passwordController.text;
                      }
                      
                      if (isEditing) {
                        controller.updateUser(user.id, userData);
                      } else {
                        controller.addUser(userData);
                      }
                      
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: AppColors.primaryColor,
                    ),
                    child: Text(isEditing ? 'Update' : 'Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showResetPasswordDialog(BuildContext context, dynamic user) {
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reset Password',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                'Reset password for ${user.firstName} ${user.lastName}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  hintText: 'Enter new password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                  hintText: 'Confirm new password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (passwordController.text != confirmPasswordController.text) {
                        Get.snackbar(
                          'Error',
                          'Passwords do not match',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: AppColors.errorColor,
                          colorText: Colors.white,
                        );
                        return;
                      }
                      
                      controller.resetPassword(
                        user.id,
                        passwordController.text,
                      );
                      
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: AppColors.primaryColor,
                    ),
                    child: const Text('Reset Password'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, dynamic user) {
    Get.dialog(
      AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text(
          'Are you sure you want to delete the user "${user.firstName} ${user.lastName}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.deleteUser(user.id);
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: AppColors.errorColor,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

