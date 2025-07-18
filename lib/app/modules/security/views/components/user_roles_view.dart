import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/security_controller.dart';

class UserRolesView extends GetView<SecurityController> {
  const UserRolesView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: _buildRolesList(),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: _buildRoleDetails(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'User Roles & Permissions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: controller.loadRoles,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildRolesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          decoration: const InputDecoration(
            labelText: 'Search Roles',
            hintText: 'Search by name or description',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
          onChanged: controller.filterRoles,
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            
            if (controller.roles.isEmpty) {
              return const Center(
                child: Text('No roles found'),
              );
            }
            
            return ListView.builder(
              itemCount: controller.roles.length,
              itemBuilder: (context, index) {
                final role = controller.roles[index];
                final isSelected = controller.selectedRole.value?.id == role.id;
                
                return Card(
                  color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
                  child: ListTile(
                    title: Text(
                      role.name,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(role.description ?? ''),
                    leading: CircleAvatar(
                      backgroundColor: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.grey,
                      child: const Icon(
                        Icons.people,
                        color: Colors.white,
                      ),
                    ),
                    trailing: role.isSystem
                        ? const Tooltip(
                            message: 'System Role',
                            child: Icon(Icons.lock),
                          )
                        : null,
                    onTap: () => controller.selectRole(role),
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }
  
  Widget _buildRoleDetails() {
    return Obx(() {
      final selectedRole = controller.selectedRole.value;
      
      if (selectedRole == null) {
        return const Center(
          child: Text('Select a role to view details'),
        );
      }
      
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            selectedRole.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (selectedRole.description != null) ...[
            const SizedBox(height: 8),
            Text(selectedRole.description!),
          ],
          const SizedBox(height: 16),
          const Text(
            'Permissions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Search Permissions',
              hintText: 'Search by name or code',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: controller.filterPermissions,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _buildPermissionsList(selectedRole),
          ),
        ],
      );
    });
  }
  
  Widget _buildPermissionsList(RoleModel role) {
    if (role.permissions == null || role.permissions!.isEmpty) {
      return const Center(
        child: Text('No permissions assigned to this role'),
      );
    }
    
    // Group permissions by module
    final permissionsByModule = <String, List<PermissionModel>>{};
    
    for (final permission in role.permissions!) {
      if (!permissionsByModule.containsKey(permission.module)) {
        permissionsByModule[permission.module] = [];
      }
      
      permissionsByModule[permission.module]!.add(permission);
    }
    
    return ListView.builder(
      itemCount: permissionsByModule.keys.length,
      itemBuilder: (context, index) {
        final module = permissionsByModule.keys.elementAt(index);
        final modulePermissions = permissionsByModule[module]!;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ExpansionTile(
            title: Text(
              module,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text('${modulePermissions.length} permissions'),
            initiallyExpanded: true,
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: modulePermissions.length,
                itemBuilder: (context, i) {
                  final permission = modulePermissions[i];
                  
                  return ListTile(
                    title: Text(permission.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Code: ${permission.code}'),
                        if (permission.description != null)
                          Text(permission.description!),
                      ],
                    ),
                    leading: const Icon(Icons.security),
                    isThreeLine: permission.description != null,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

