import 'package:get/get.dart';
import '../models/weighbridge_record_model.dart';
import '../models/gate_entry_model.dart';
import '../providers/db_provider.dart';

class WeighbridgeRepository {
  final DbProvider _dbProvider = Get.find<DbProvider>();
  
  // Get all weighbridge records
  Future<List<WeighbridgeRecordModel>> getAllWeighbridgeRecords() async {
    final List<Map<String, dynamic>> maps = await _dbProvider.getAll(
      'weighbridge_record',
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) {
      return WeighbridgeRecordModel.fromMap(maps[i]);
    });
  }
  
  // Get weighbridge record by id
  Future<WeighbridgeRecordModel?> getWeighbridgeRecordById(int id) async {
    final Map<String, dynamic>? map = await _dbProvider.getById('weighbridge_record', id);
    if (map != null) {
      return WeighbridgeRecordModel.fromMap(map);
    }
    return null;
  }
  
  // Get weighbridge record by gate entry id
  Future<WeighbridgeRecordModel?> getWeighbridgeRecordByGateEntry(int gateEntryId) async {
    final Map<String, dynamic>? map = await _dbProvider.getWeighbridgeRecordByGateEntry(gateEntryId);
    if (map != null) {
      return WeighbridgeRecordModel.fromMap(map);
    }
    return null;
  }
  
  // Get weighbridge record with gate entry
  Future<WeighbridgeRecordModel?> getWeighbridgeRecordWithGateEntry(int id) async {
    final WeighbridgeRecordModel? weighbridgeRecord = await getWeighbridgeRecordById(id);
    if (weighbridgeRecord != null) {
      final Map<String, dynamic>? gateEntryMap = await _dbProvider.getById('gate_entry', weighbridgeRecord.gateEntryId);
      if (gateEntryMap != null) {
        final GateEntryModel gateEntry = GateEntryModel.fromMap(gateEntryMap);
        return weighbridgeRecord.copyWith(gateEntry: gateEntry);
      }
      return weighbridgeRecord;
    }
    return null;
  }
  
  // Insert weighbridge record
  Future<int> insertWeighbridgeRecord(WeighbridgeRecordModel weighbridgeRecord) async {
    return await _dbProvider.insert('weighbridge_record', weighbridgeRecord.toMap());
  }
  
  // Update weighbridge record
  Future<int> updateWeighbridgeRecord(WeighbridgeRecordModel weighbridgeRecord) async {
    return await _dbProvider.update('weighbridge_record', weighbridgeRecord.toMap(), weighbridgeRecord.id!);
  }
  
  // Delete weighbridge record
  Future<int> deleteWeighbridgeRecord(int id) async {
    return await _dbProvider.delete('weighbridge_record', id);
  }
  
  // Update tare weight
  Future<int> updateTareWeight(int id, double tareWeight, DateTime tareWeightTime) async {
    return await _dbProvider.update(
      'weighbridge_record',
      {
        'tare_weight': tareWeight,
        'tare_weight_time': tareWeightTime.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      id,
    );
  }
  
  // Update gross weight
  Future<int> updateGrossWeight(int id, double grossWeight, DateTime grossWeightTime) async {
    final WeighbridgeRecordModel? weighbridgeRecord = await getWeighbridgeRecordById(id);
    if (weighbridgeRecord != null && weighbridgeRecord.tareWeight != null) {
      final double netWeight = grossWeight - weighbridgeRecord.tareWeight!;
      return await _dbProvider.update(
        'weighbridge_record',
        {
          'gross_weight': grossWeight,
          'gross_weight_time': grossWeightTime.toIso8601String(),
          'net_weight': netWeight,
          'updated_at': DateTime.now().toIso8601String(),
        },
        id,
      );
    }
    return 0;
  }
  
  // Calculate net weight
  Future<int> calculateNetWeight(int id) async {
    final WeighbridgeRecordModel? weighbridgeRecord = await getWeighbridgeRecordById(id);
    if (weighbridgeRecord != null && weighbridgeRecord.tareWeight != null && weighbridgeRecord.grossWeight != null) {
      final double netWeight = weighbridgeRecord.grossWeight! - weighbridgeRecord.tareWeight!;
      return await _dbProvider.update(
        'weighbridge_record',
        {
          'net_weight': netWeight,
          'updated_at': DateTime.now().toIso8601String(),
        },
        id,
      );
    }
    return 0;
  }
  
  // Get daily weighbridge records
  Future<List<WeighbridgeRecordModel>> getDailyWeighbridgeRecords(DateTime date) async {
    final String dateString = date.toString().split(' ')[0];
    
    final List<Map<String, dynamic>> maps = await _dbProvider.rawQuery(
      'SELECT * FROM weighbridge_record WHERE date(created_at) = ? ORDER BY created_at DESC',
      [dateString],
    );
    
    return List.generate(maps.length, (i) {
      return WeighbridgeRecordModel.fromMap(maps[i]);
    });
  }
  
  // Get total weight for a day
  Future<double> getTotalWeightForDay(DateTime date) async {
    final String dateString = date.toString().split(' ')[0];
    
    final List<Map<String, dynamic>> result = await _dbProvider.rawQuery(
      'SELECT SUM(net_weight) as total FROM weighbridge_record WHERE date(created_at) = ? AND net_weight IS NOT NULL',
      [dateString],
    );
    
    if (result.first['total'] != null) {
      return result.first['total'] as double;
    }
    
    return 0.0;
  }
  
  // Get weighbridge records by vehicle
  Future<List<WeighbridgeRecordModel>> getWeighbridgeRecordsByVehicle(int vehicleId) async {
    final List<Map<String, dynamic>> maps = await _dbProvider.rawQuery(
      '''
      SELECT wr.* FROM weighbridge_record wr
      JOIN gate_entry ge ON wr.gate_entry_id = ge.id
      WHERE ge.vehicle_id = ?
      ORDER BY wr.created_at DESC
      ''',
      [vehicleId],
    );
    
    return List.generate(maps.length, (i) {
      return WeighbridgeRecordModel.fromMap(maps[i]);
    });
  }
}

