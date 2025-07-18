import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/sync_controller.dart';
import '../../../core/utils/responsive_builder.dart';

class SyncView extends GetView<SyncController> {
  const SyncView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Synchronization'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: controller.loadSyncStats,
          ),
        ],
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
      floatingActionButton: Obx(() {
        if (controller.isSyncing.value) {
          return FloatingActionButton(
            onPressed: null,
            backgroundColor: Colors.grey,
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          );
        }
        return FloatingActionButton(
          onPressed: controller.syncData,
          child: const Icon(Icons.sync),
        );
      }),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSyncStatus(),
          const SizedBox(height: 16),
          _buildSyncStats(),
          const SizedBox(height: 16),
          _buildSyncActions(),
          const SizedBox(height: 16),
          _buildSyncItems(),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSyncStatus(),
                const SizedBox(height: 16),
                _buildSyncStats(),
                const SizedBox(height: 16),
                _buildSyncActions(),
              ],
            ),
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          flex: 3,
          child: _buildSyncItems(),
        ),
      ],
    );
  }

  Widget _buildSyncStatus() {
    return Obx(() {
      final isOnline = controller.isOnline.value;
      final isSyncing = controller.isSyncing.value;
      final syncProgress = controller.syncProgress.value;
      final syncStatus = controller.syncStatus.value;

      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isOnline ? Icons.cloud_done : Icons.cloud_off,
                    color: isOnline ? Colors.green : Colors.red,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isOnline ? 'Online' : 'Offline',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (isSyncing)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Syncing',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              if (isSyncing) ...[
                LinearProgressIndicator(value: syncProgress),
                const SizedBox(height: 8),
                Text(syncStatus),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Last Sync:'),
                  const SizedBox(width: 8),
                  Text(
                    controller.lastSyncTime.value != null
                        ? DateFormat('dd MMM yyyy, HH:mm').format(controller.lastSyncTime.value!)
                        : 'Never',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildSyncStats() {
    return Obx(() {
      final pendingCount = controller.pendingCount.value;
      final syncedCount = controller.syncedCount.value;
      final failedCount = controller.failedCount.value;
      final totalCount = controller.totalCount.value;

      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sync Statistics',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    'Pending',
                    pendingCount,
                    Colors.orange,
                    Icons.hourglass_empty,
                  ),
                  _buildStatItem(
                    'Synced',
                    syncedCount,
                    Colors.green,
                    Icons.check_circle,
                  ),
                  _buildStatItem(
                    'Failed',
                    failedCount,
                    Colors.red,
                    Icons.error,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: totalCount > 0 ? syncedCount / totalCount : 0,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
              ),
              const SizedBox(height: 8),
              Text(
                'Total: $totalCount items',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildStatItem(String label, int count, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label),
      ],
    );
  }

  Widget _buildSyncActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sync Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: controller.syncData,
                  icon: const Icon(Icons.sync),
                  label: const Text('Sync Now'),
                ),
                ElevatedButton.icon(
                  onPressed: controller.resetFailedItems,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry Failed'),
                ),
                ElevatedButton.icon(
                  onPressed: controller.exportSyncData,
                  icon: const Icon(Icons.file_download),
                  label: const Text('Export'),
                ),
                ElevatedButton.icon(
                  onPressed: controller.importSyncData,
                  icon: const Icon(Icons.file_upload),
                  label: const Text('Import'),
                ),
                ElevatedButton.icon(
                  onPressed: controller.clearSyncedItems,
                  icon: const Icon(Icons.cleaning_services),
                  label: const Text('Clear Synced'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncItems() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.syncItems.isEmpty) {
        return const Center(
          child: Text('No sync items found'),
        );
      }

      return Card(
        margin: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text(
                    'Sync Items',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  DropdownButton<String>(
                    value: controller.selectedFilter.value,
                    onChanged: controller.changeFilter,
                    items: [
                      const DropdownMenuItem(
                        value: 'all',
                        child: Text('All'),
                      ),
                      const DropdownMenuItem(
                        value: 'pending',
                        child: Text('Pending'),
                      ),
                      const DropdownMenuItem(
                        value: 'synced',
                        child: Text('Synced'),
                      ),
                      const DropdownMenuItem(
                        value: 'failed',
                        child: Text('Failed'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: controller.syncItems.length,
                itemBuilder: (context, index) {
                  final item = controller.syncItems[index];
                  return ListTile(
                    leading: _getSyncStatusIcon(item.status),
                    title: Text('${item.entityType} - ${item.action}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ID: ${item.entityId}'),
                        Text(
                          'Created: ${DateFormat('dd MMM yyyy, HH:mm').format(item.createdAt)}',
                        ),
                        if (item.syncedAt != null)
                          Text(
                            'Synced: ${DateFormat('dd MMM yyyy, HH:mm').format(item.syncedAt!)}',
                          ),
                      ],
                    ),
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'view',
                          child: Text('View Details'),
                        ),
                        if (item.status == SyncStatus.failed)
                          const PopupMenuItem(
                            value: 'retry',
                            child: Text('Retry'),
                          ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ],
                      onSelected: (value) {
                        switch (value) {
                          case 'view':
                            controller.viewSyncItemDetails(item);
                            break;
                          case 'retry':
                            controller.retrySyncItem(item);
                            break;
                          case 'delete':
                            controller.deleteSyncItem(item);
                            break;
                        }
                      },
                    ),
                    isThreeLine: true,
                    onTap: () => controller.viewSyncItemDetails(item),
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _getSyncStatusIcon(SyncStatus status) {
    switch (status) {
      case SyncStatus.pending:
        return const CircleAvatar(
          backgroundColor: Colors.orange,
          child: Icon(Icons.hourglass_empty, color: Colors.white),
        );
      case SyncStatus.syncing:
        return const CircleAvatar(
          backgroundColor: Colors.blue,
          child: Icon(Icons.sync, color: Colors.white),
        );
      case SyncStatus.synced:
        return const CircleAvatar(
          backgroundColor: Colors.green,
          child: Icon(Icons.check, color: Colors.white),
        );
      case SyncStatus.failed:
        return const CircleAvatar(
          backgroundColor: Colors.red,
          child: Icon(Icons.error, color: Colors.white),
        );
    }
  }
}

