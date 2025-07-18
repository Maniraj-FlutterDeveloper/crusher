import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/values/app_constants.dart';
import '../../controllers/security_controller.dart';

class AuditLogsView extends GetView<SecurityController> {
  const AuditLogsView({Key? key}) : super(key: key);

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
            _buildFilters(context),
            const SizedBox(height: 16),
            Expanded(
              child: _buildAuditLogsList(),
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
          'Audit Logs',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: controller.loadAuditLogs,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
            const SizedBox(width: 8),
            Obx(() {
              if (controller.canAccessSecuritySettings) {
                return ElevatedButton.icon(
                  onPressed: controller.isProcessing.value
                      ? null
                      : () => _confirmDeleteOldLogs(Get.context!),
                  icon: const Icon(Icons.delete),
                  label: const Text('Delete Old Logs'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                );
              } else {
                return const SizedBox.shrink();
              }
            }),
          ],
        ),
      ],
    );
  }
  
  Widget _buildFilters(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          decoration: const InputDecoration(
            labelText: 'Search',
            hintText: 'Search by action, module, details, or user',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            controller.auditLogFilter.value = value;
            controller.loadAuditLogs();
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Filter by Module',
                  border: OutlineInputBorder(),
                ),
                value: controller.auditLogModule.value.isEmpty
                    ? null
                    : controller.auditLogModule.value,
                onChanged: (value) {
                  if (value != null) {
                    controller.filterAuditLogsByModule(value);
                  }
                },
                items: [
                  const DropdownMenuItem<String>(
                    value: '',
                    child: Text('All Modules'),
                  ),
                  ...controller.permissions
                      .map((p) => p.module)
                      .toSet()
                      .toList()
                      .map((module) => DropdownMenuItem<String>(
                            value: module,
                            child: Text(module),
                          )),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Filter by Action',
                  border: OutlineInputBorder(),
                ),
                value: controller.auditLogAction.value.isEmpty
                    ? null
                    : controller.auditLogAction.value,
                onChanged: (value) {
                  if (value != null) {
                    controller.filterAuditLogsByAction(value);
                  }
                },
                items: [
                  const DropdownMenuItem<String>(
                    value: '',
                    child: Text('All Actions'),
                  ),
                  const DropdownMenuItem<String>(
                    value: 'login',
                    child: Text('Login'),
                  ),
                  const DropdownMenuItem<String>(
                    value: 'logout',
                    child: Text('Logout'),
                  ),
                  const DropdownMenuItem<String>(
                    value: 'create',
                    child: Text('Create'),
                  ),
                  const DropdownMenuItem<String>(
                    value: 'update',
                    child: Text('Update'),
                  ),
                  const DropdownMenuItem<String>(
                    value: 'delete',
                    child: Text('Delete'),
                  ),
                  const DropdownMenuItem<String>(
                    value: 'view',
                    child: Text('View'),
                  ),
                  const DropdownMenuItem<String>(
                    value: 'export',
                    child: Text('Export'),
                  ),
                  const DropdownMenuItem<String>(
                    value: 'import',
                    child: Text('Import'),
                  ),
                  const DropdownMenuItem<String>(
                    value: 'password_change',
                    child: Text('Password Change'),
                  ),
                  const DropdownMenuItem<String>(
                    value: 'permission_change',
                    child: Text('Permission Change'),
                  ),
                  const DropdownMenuItem<String>(
                    value: 'role_change',
                    child: Text('Role Change'),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controller.auditLogStartDateController,
                decoration: InputDecoration(
                  labelText: 'Start Date',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => controller.selectAuditLogStartDate(context),
                  ),
                ),
                readOnly: true,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: controller.auditLogEndDateController,
                decoration: InputDecoration(
                  labelText: 'End Date',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => controller.selectAuditLogEndDate(context),
                  ),
                ),
                readOnly: true,
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: controller.clearAuditLogFilters,
              icon: const Icon(Icons.clear),
              label: const Text('Clear Filters'),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildAuditLogsList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }
      
      if (controller.auditLogs.isEmpty) {
        return const Center(
          child: Text('No audit logs found'),
        );
      }
      
      return ListView.builder(
        itemCount: controller.auditLogs.length,
        itemBuilder: (context, index) {
          final log = controller.auditLogs[index];
          
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ExpansionTile(
              title: Text(
                log.actionDescription,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                '${log.module} - ${log.formattedTimestamp}',
              ),
              leading: _getActionIcon(log.action),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.person),
                          const SizedBox(width: 8),
                          Text('User: ${log.user?.name ?? 'Unknown'}'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.access_time),
                          const SizedBox(width: 8),
                          Text('Timestamp: ${log.formattedTimestamp}'),
                        ],
                      ),
                      if (log.ipAddress != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.computer),
                            const SizedBox(width: 8),
                            Text('IP Address: ${log.ipAddress}'),
                          ],
                        ),
                      ],
                      if (log.userAgent != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.devices),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text('User Agent: ${log.userAgent}'),
                            ),
                          ],
                        ),
                      ],
                      if (log.details != null) ...[
                        const SizedBox(height: 8),
                        const Text(
                          'Details:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(log.details!),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }
  
  Widget _getActionIcon(String action) {
    IconData iconData;
    Color color;
    
    switch (action) {
      case 'login':
        iconData = Icons.login;
        color = Colors.blue;
        break;
      case 'logout':
        iconData = Icons.logout;
        color = Colors.blue;
        break;
      case 'create':
        iconData = Icons.add_circle;
        color = Colors.green;
        break;
      case 'update':
        iconData = Icons.edit;
        color = Colors.orange;
        break;
      case 'delete':
        iconData = Icons.delete;
        color = Colors.red;
        break;
      case 'view':
        iconData = Icons.visibility;
        color = Colors.purple;
        break;
      case 'export':
        iconData = Icons.download;
        color = Colors.teal;
        break;
      case 'import':
        iconData = Icons.upload;
        color = Colors.teal;
        break;
      case 'password_change':
        iconData = Icons.password;
        color = Colors.amber;
        break;
      case 'permission_change':
        iconData = Icons.security;
        color = Colors.amber;
        break;
      case 'role_change':
        iconData = Icons.people;
        color = Colors.amber;
        break;
      default:
        iconData = Icons.info;
        color = Colors.grey;
    }
    
    return CircleAvatar(
      backgroundColor: color.withOpacity(0.2),
      child: Icon(
        iconData,
        color: color,
      ),
    );
  }
  
  void _confirmDeleteOldLogs(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Old Audit Logs'),
        content: Text(
          'Are you sure you want to delete audit logs older than ${controller.auditLogRetentionDays.value} days? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              controller.deleteOldAuditLogs();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

