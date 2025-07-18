import 'package:get/get.dart';
import '../models/weighbridge_record_model.dart';
import '../providers/db_provider.dart';

class WeighbridgeRepository {
  final DbProvider _dbProvider = Get.find<DbProvider>();
  
  // Get all weighbridge records
  Future<List<WeighbridgeRecordModel>> getAllWeighbridgeRecords() async {
    final List<Map<String, dynamic>> maps = await _dbProvider.rawQuery('''
      SELECT wr.*, ge.*, wu.*, u.* FROM weighbridge_record wr
      LEFT JOIN gate_entry ge ON wr.gate_entry_id = ge.id
      LEFT JOIN weight_unit_type wu ON wr.weight_unit_id = wu.id
      LEFT JOIN user u ON wr.operator_id = u.id
      ORDER BY wr.created_at DESC
    ''');
    
    return maps.map((map) {
      final weighbridgeRecord = WeighbridgeRecordModel.fromMap({
        'id': map['id'],
        'gate_entry_id': map['gate_entry_id'],
        'tare_weight': map['tare_weight'],
        'gross_weight': map['gross_weight'],
        'net_weight': map['net_weight'],
        'weight_unit_id': map['weight_unit_id'],
        'tare_weight_time': map['tare_weight_time'],
        'gross_weight_time': map['gross_weight_time'],
        'operator_id': map['operator_id'],
        'remarks': map['remarks'],
        'created_at': map['created_at'],
        'updated_at': map['updated_at'],
      });
      
      // Extract gate entry data
      if (map['gate_entry_id'] != null) {
        final gateEntry = {
          'id': map['gate_entry_id'],
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
        };
        
        // Extract weight unit data
        final weightUnit = {
          'id': map['weight_unit_id'],
          'name': map['name'],
          'symbol': map['symbol'],
          'conversion_factor': map['conversion_factor'],
          'is_active': map['is_active'],
          'created_at': map['created_at'],
          'updated_at': map['updated_at'],
        };
        
        // Extract operator data
        final operator = {
          'id': map['operator_id'],
          'username': map['username'],
          'name': map['name'],
          'email': map['email'],
          'mobile': map['mobile'],
          'is_active': map['is_active'],
          'last_login': map['last_login'],
          'created_at': map['created_at'],
          'updated_at': map['updated_at'],
        };
        
        return weighbridgeRecord.copyWith(
          gateEntry: gateEntry != null ? GateEntryModel.fromMap(gateEntry) : null,
          weightUnit: weightUnit != null ? WeightUnitModel.fromMap(weightUnit) : null,
          operator: operator != null ? UserModel.fromMap(operator) : null,
        );
      }
      
      return weighbridgeRecord;
    }).toList();
  }
  
  // Get weighbridge records by gate entry
  Future<List<WeighbridgeRecordModel>> getWeighbridgeRecordsByGateEntry(int gateEntryId) async {
    final List<Map<String, dynamic>> maps = await _dbProvider.query(
      'weighbridge_record',
      where: 'gate_entry_id = ?',
      whereArgs: [gateEntryId],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => WeighbridgeRecordModel.fromMap(map)).toList();
  }
  
  // Get weighbridge record by id
  Future<WeighbridgeRecordModel?> getWeighbridgeRecordById(int id) async {
    final Map<String, dynamic>? map = await _dbProvider.getById('weighbridge_record', id);
    if (map != null) {
      return WeighbridgeRecordModel.fromMap(map);
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
  
  // Get weighbridge record by gate entry id
  Future<WeighbridgeRecordModel?> getWeighbridgeRecordByGateEntryId(int gateEntryId) async {
    final List<Map<String, dynamic>> maps = await _dbProvider.query(
      'weighbridge_record',
      where: 'gate_entry_id = ?',
      whereArgs: [gateEntryId],
      orderBy: 'created_at DESC',
      limit: 1,
    );
    
    if (maps.isNotEmpty) {
      return WeighbridgeRecordModel.fromMap(maps.first);
    }
    
    return null;
  }
  
  // Get all weight units
  Future<List<WeightUnitModel>> getAllWeightUnits() async {
    final List<Map<String, dynamic>> maps = await _dbProvider.query(
      'weight_unit_type',
      orderBy: 'name ASC',
    );
    return maps.map((map) => WeightUnitModel.fromMap(map)).toList();
  }
  
  // Get active weight units
  Future<List<WeightUnitModel>> getActiveWeightUnits() async {
    final List<Map<String, dynamic>> maps = await _dbProvider.query(
      'weight_unit_type',
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'name ASC',
    );
    return maps.map((map) => WeightUnitModel.fromMap(map)).toList();
  }
  
  // Get weight unit by id
  Future<WeightUnitModel?> getWeightUnitById(int id) async {
    final Map<String, dynamic>? map = await _dbProvider.getById('weight_unit_type', id);
    if (map != null) {
      return WeightUnitModel.fromMap(map);
    }
    return null;
  }
  
  // Calculate net weight
  double calculateNetWeight(double grossWeight, double tareWeight) {
    return grossWeight - tareWeight;
  }
  
  // Convert weight between units
  double convertWeight(double weight, int fromUnitId, int toUnitId) async {
    final WeightUnitModel? fromUnit = await getWeightUnitById(fromUnitId);
    final WeightUnitModel? toUnit = await getWeightUnitById(toUnitId);
    
    if (fromUnit == null || toUnit == null) {
      throw Exception('Weight unit not found');
    }
    
    // Convert to base unit (kg)
    final double baseWeight = weight * fromUnit.conversionFactor;
    
    // Convert from base unit to target unit
    return baseWeight / toUnit.conversionFactor;
  }
}

