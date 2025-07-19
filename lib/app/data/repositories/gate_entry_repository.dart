import 'package:crusher_management/app/data/models/vehicle_model.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/gate_entry_model.dart';
import '../providers/db_provider.dart';

class GateEntryRepository {
  final DbProvider _dbProvider = Get.find<DbProvider>();
  
  // Get all gate entries
  Future<List<GateEntryModel>> getAllGateEntries() async {
    final List<Map<String, dynamic>> maps = await _dbProvider.rawQuery('''
      SELECT ge.*, vm.* FROM gate_entry ge
      LEFT JOIN vehicle_master vm ON ge.vehicle_id = vm.id
      ORDER BY ge.entry_time DESC
    ''');
    
    return maps.map((map) {
      final gateEntry = GateEntryModel.fromMap({
        'id': map['id'],
        'session_id': map['session_id'],
        'vehicle_id': map['vehicle_id'],
        'driver_name': map['driver_name'],
        'driver_mobile': map['driver_mobile'],
        'entry_time': map['entry_time'],
        'exit_time': map['exit_time'],
        'tare_weight': map['tare_weight'],
        'gross_weight': map['gross_weight'],
        'net_weight': map['net_weight'],
        'status': map['status'],
        'gate_pass_number': map['gate_pass_number'],
        'remarks': map['remarks'],
        'operator_id': map['operator_id'],
        'created_at': map['created_at'],
        'updated_at': map['updated_at'],
      });
      
      // Extract vehicle data
      if (map['vehicle_id'] != null) {
        final vehicle = {
          'id': map['vehicle_id'],
          'vehicle_number': map['vehicle_number'],
          'vehicle_type': map['vehicle_type'],
          'capacity': map['capacity'],
          'owner_name': map['owner_name'],
          'owner_mobile': map['owner_mobile'],
          'owner_address': map['owner_address'],
          'is_active': map['is_active'],
          'created_at': map['created_at'],
          'updated_at': map['updated_at'],
        };
        
        return gateEntry.copyWith(
          vehicle: vehicle != null ? VehicleModel.fromMap(vehicle) : null,
        );
      }
      
      return gateEntry;
    }).toList();
  }
  
  // Get gate entries by status
  Future<List<GateEntryModel>> getGateEntriesByStatus(String status) async {
    final List<Map<String, dynamic>> maps = await _dbProvider.getGateEntriesByStatus(status);
    return maps.map((map) => GateEntryModel.fromMap(map)).toList();
  }
  
  // Get gate entries by vehicle
  Future<List<GateEntryModel>> getGateEntriesByVehicle(int vehicleId) async {
    final List<Map<String, dynamic>> maps = await _dbProvider.getGateEntriesByVehicle(vehicleId);
    return maps.map((map) => GateEntryModel.fromMap(map)).toList();
  }
  
  // Get gate entry by id
  Future<GateEntryModel?> getGateEntryById(int id) async {
    final Map<String, dynamic>? map = await _dbProvider.getGateEntryWithVehicle(id);
    if (map != null) {
      return GateEntryModel.fromMap(map);
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
  
  // Generate session ID
  Future<String> generateSessionId() async {
    final DateTime now = DateTime.now();
    final String date = DateFormat('yyyyMMdd').format(now);
    
    // Get the count of entries for today
    final List<Map<String, dynamic>> maps = await _dbProvider.rawQuery(
      '''
      SELECT COUNT(*) as count FROM gate_entry
      WHERE session_id LIKE ?
      ''',
      ['$date%'],
    );
    
    final int count = maps.first['count'] as int;
    final String sequenceNumber = (count + 1).toString().padLeft(4, '0');
    
    return '$date-$sequenceNumber';
  }
  
  // Generate gate pass number
  Future<String> generateGatePassNumber() async {
    final DateTime now = DateTime.now();
    final String date = DateFormat('yyyyMMdd').format(now);
    
    // Get the count of entries for today
    final List<Map<String, dynamic>> maps = await _dbProvider.rawQuery(
      '''
      SELECT COUNT(*) as count FROM gate_entry
      WHERE gate_pass_number LIKE ?
      ''',
      ['GP-$date%'],
    );
    
    final int count = maps.first['count'] as int;
    final String sequenceNumber = (count + 1).toString().padLeft(4, '0');
    
    return 'GP-$date-$sequenceNumber';
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
  
  // Search gate entries
  Future<List<GateEntryModel>> searchGateEntries(String query) async {
    final List<Map<String, dynamic>> maps = await _dbProvider.rawQuery(
      '''
      SELECT ge.*, vm.* FROM gate_entry ge
      LEFT JOIN vehicle_master vm ON ge.vehicle_id = vm.id
      WHERE ge.session_id LIKE ? OR vm.vehicle_number LIKE ? OR ge.driver_name LIKE ?
      ORDER BY ge.entry_time DESC
      ''',
      ['%$query%', '%$query%', '%$query%'],
    );
    
    return maps.map((map) {
      final gateEntry = GateEntryModel.fromMap({
        'id': map['id'],
        'session_id': map['session_id'],
        'vehicle_id': map['vehicle_id'],
        'driver_name': map['driver_name'],
        'driver_mobile': map['driver_mobile'],
        'entry_time': map['entry_time'],
        'exit_time': map['exit_time'],
        'tare_weight': map['tare_weight'],
        'gross_weight': map['gross_weight'],
        'net_weight': map['net_weight'],
        'status': map['status'],
        'gate_pass_number': map['gate_pass_number'],
        'remarks': map['remarks'],
        'operator_id': map['operator_id'],
        'created_at': map['created_at'],
        'updated_at': map['updated_at'],
      });
      
      // Extract vehicle data
      if (map['vehicle_id'] != null) {
        final vehicle = {
          'id': map['vehicle_id'],
          'vehicle_number': map['vehicle_number'],
          'vehicle_type': map['vehicle_type'],
          'capacity': map['capacity'],
          'owner_name': map['owner_name'],
          'owner_mobile': map['owner_mobile'],
          'owner_address': map['owner_address'],
          'is_active': map['is_active'],
          'created_at': map['created_at'],
          'updated_at': map['updated_at'],
        };
        
        return gateEntry.copyWith(
          vehicle: vehicle != null ? VehicleModel.fromMap(vehicle) : null,
        );
      }
      
      return gateEntry;
    }).toList();
  }
}

