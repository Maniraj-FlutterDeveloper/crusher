import 'package:get/get.dart';
import '../models/gate_entry_model.dart';
import '../models/vehicle_model.dart';
import '../providers/db_provider.dart';
import '../../core/values/app_constants.dart';

class GateEntryRepository {
  final DbProvider _dbProvider = Get.find<DbProvider>();
  
  // Get all gate entries
  Future<List<GateEntryModel>> getAllGateEntries() async {
    final List<Map<String, dynamic>> maps = await _dbProvider.getAll(
      'gate_entry',
      orderBy: 'entry_time DESC',
    );
    return List.generate(maps.length, (i) {
      return GateEntryModel.fromMap(maps[i]);
    });
  }
  
  // Get gate entries by status
  Future<List<GateEntryModel>> getGateEntriesByStatus(String status) async {
    final List<Map<String, dynamic>> maps = await _dbProvider.getGateEntriesByStatus(status);
    return List.generate(maps.length, (i) {
      return GateEntryModel.fromMap(maps[i]);
    });
  }
  
  // Get gate entries by vehicle
  Future<List<GateEntryModel>> getGateEntriesByVehicle(int vehicleId) async {
    final List<Map<String, dynamic>> maps = await _dbProvider.getGateEntriesByVehicle(vehicleId);
    return List.generate(maps.length, (i) {
      return GateEntryModel.fromMap(maps[i]);
    });
  }
  
  // Get gate entry by id
  Future<GateEntryModel?> getGateEntryById(int id) async {
    final Map<String, dynamic>? map = await _dbProvider.getById('gate_entry', id);
    if (map != null) {
      return GateEntryModel.fromMap(map);
    }
    return null;
  }
  
  // Get gate entry by session id
  Future<GateEntryModel?> getGateEntryBySessionId(String sessionId) async {
    final List<Map<String, dynamic>> maps = await _dbProvider.getAll(
      'gate_entry',
      where: 'session_id = ?',
      whereArgs: [sessionId],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return GateEntryModel.fromMap(maps.first);
    }
    return null;
  }
  
  // Get gate entry with vehicle
  Future<GateEntryModel?> getGateEntryWithVehicle(int id) async {
    final Map<String, dynamic>? gateEntryMap = await _dbProvider.getGateEntryWithVehicle(id);
    if (gateEntryMap != null) {
      final GateEntryModel gateEntry = GateEntryModel.fromMap(gateEntryMap);
      if (gateEntryMap['vehicle'] != null) {
        final VehicleModel vehicle = VehicleModel.fromMap(gateEntryMap['vehicle']);
        return gateEntry.copyWith(vehicle: vehicle);
      }
      return gateEntry;
    }
    return null;
  }
  
  // Insert gate entry
  Future<int> insertGateEntry(GateEntryModel gateEntry) async {
    return await _dbProvider.insert('gate_entry', gateEntry.toMap());
  }
  
  // Update gate entry
  Future<int> updateGateEntry(GateEntryModel gateEntry) async {
    return await _dbProvider.update('gate_entry', gateEntry.toMap(), gateEntry.id!);
  }
  
  // Delete gate entry
  Future<int> deleteGateEntry(int id) async {
    return await _dbProvider.delete('gate_entry', id);
  }
  
  // Update gate entry status
  Future<int> updateGateEntryStatus(int id, String status) async {
    return await _dbProvider.update(
      'gate_entry',
      {
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      },
      id,
    );
  }
  
  // Update gate entry tare weight
  Future<int> updateGateEntryTareWeight(int id, double tareWeight) async {
    return await _dbProvider.update(
      'gate_entry',
      {
        'tare_weight': tareWeight,
        'updated_at': DateTime.now().toIso8601String(),
      },
      id,
    );
  }
  
  // Update gate entry gross weight
  Future<int> updateGateEntryGrossWeight(int id, double grossWeight) async {
    final GateEntryModel? gateEntry = await getGateEntryById(id);
    if (gateEntry != null && gateEntry.tareWeight != null) {
      final double netWeight = grossWeight - gateEntry.tareWeight!;
      return await _dbProvider.update(
        'gate_entry',
        {
          'gross_weight': grossWeight,
          'net_weight': netWeight,
          'exit_time': DateTime.now().toIso8601String(),
          'status': AppConstants.vehicleStatusDispatched,
          'updated_at': DateTime.now().toIso8601String(),
        },
        id,
      );
    }
    return 0;
  }
  
  // Generate gate pass number
  Future<String> generateGatePassNumber() async {
    final DateTime now = DateTime.now();
    final String datePrefix = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    
    final List<Map<String, dynamic>> result = await _dbProvider.rawQuery(
      'SELECT COUNT(*) as count FROM gate_entry WHERE gate_pass_number LIKE ?',
      ['GP$datePrefix%'],
    );
    
    final int count = result.first['count'] as int;
    final String suffix = (count + 1).toString().padLeft(4, '0');
    
    return 'GP$datePrefix$suffix';
  }
  
  // Generate session id
  Future<String> generateSessionId() async {
    final DateTime now = DateTime.now();
    final String datePrefix = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    
    final List<Map<String, dynamic>> result = await _dbProvider.rawQuery(
      'SELECT COUNT(*) as count FROM gate_entry WHERE session_id LIKE ?',
      ['S$datePrefix%'],
    );
    
    final int count = result.first['count'] as int;
    final String suffix = (count + 1).toString().padLeft(4, '0');
    
    return 'S$datePrefix$suffix';
  }
  
  // Get pending vehicles count
  Future<int> getPendingVehiclesCount() async {
    final List<Map<String, dynamic>> result = await _dbProvider.rawQuery(
      'SELECT COUNT(*) as count FROM gate_entry WHERE status != ?',
      [AppConstants.vehicleStatusDispatched],
    );
    
    return result.first['count'] as int;
  }
  
  // Get completed vehicles count
  Future<int> getCompletedVehiclesCount() async {
    final List<Map<String, dynamic>> result = await _dbProvider.rawQuery(
      'SELECT COUNT(*) as count FROM gate_entry WHERE status = ?',
      [AppConstants.vehicleStatusDispatched],
    );
    
    return result.first['count'] as int;
  }
  
  // Get total weight
  Future<double> getTotalWeight() async {
    final List<Map<String, dynamic>> result = await _dbProvider.rawQuery(
      'SELECT SUM(net_weight) as total FROM gate_entry WHERE net_weight IS NOT NULL',
    );
    
    if (result.first['total'] != null) {
      return result.first['total'] as double;
    }
    
    return 0.0;
  }
  
  // Get daily gate entries
  Future<List<GateEntryModel>> getDailyGateEntries(DateTime date) async {
    final String dateString = date.toString().split(' ')[0];
    
    final List<Map<String, dynamic>> maps = await _dbProvider.rawQuery(
      'SELECT * FROM gate_entry WHERE date(entry_time) = ? ORDER BY entry_time DESC',
      [dateString],
    );
    
    return List.generate(maps.length, (i) {
      return GateEntryModel.fromMap(maps[i]);
    });
  }
  
  // Search gate entries by vehicle number
  Future<List<GateEntryModel>> searchGateEntriesByVehicleNumber(String query) async {
    final List<Map<String, dynamic>> maps = await _dbProvider.rawQuery(
      '''
      SELECT ge.* FROM gate_entry ge
      JOIN vehicle_master vm ON ge.vehicle_id = vm.id
      WHERE vm.vehicle_number LIKE ?
      ORDER BY ge.entry_time DESC
      ''',
      ['%$query%'],
    );
    
    return List.generate(maps.length, (i) {
      return GateEntryModel.fromMap(maps[i]);
    });
  }
}

