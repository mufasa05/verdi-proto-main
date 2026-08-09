import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:verdi/features/geospatial/models/geospatial_models.dart';

/// Simple AI data access interface for global farm data.
abstract class AiDataAccessService {
  Future<List<GeoFarm>> getAllFarms();
  Future<GeoFarm?> getFarmById(String id);
  Future<void> saveFarm(GeoFarm farm);
  Future<void> deleteFarm(String id);

  Future<List<GeoField>> getFieldsForFarm(String farmId);
  Future<void> saveField(GeoField field);
  Future<void> deleteField(String fieldId);
}

/// Local JSON-backed implementation. Stores a single `ai_data.json` file
/// in the app documents directory. This is intentionally simple and
/// intended as a development/testing stub before adding a remote API
/// or a full SQLite adapter.
class LocalJsonAiDataService implements AiDataAccessService {
  final String _fileName;

  LocalJsonAiDataService({String fileName = 'ai_data.json'}) : _fileName = fileName;

  Future<File> get _file async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  Future<Map<String, dynamic>> _readStore() async {
    try {
      final f = await _file;
      if (!await f.exists()) return {'farms': [], 'fields': []};
      final text = await f.readAsString();
      return jsonDecode(text) as Map<String, dynamic>;
    } catch (e) {
      return {'farms': [], 'fields': []};
    }
  }

  Future<void> _writeStore(Map<String, dynamic> data) async {
    final f = await _file;
    await f.writeAsString(jsonEncode(data));
  }

  Map<String, dynamic> _farmToMap(GeoFarm f) => {
        'id': f.id,
        'name': f.name,
        'owner': f.owner,
        'region': f.region,
        'center': {'lat': f.center.latitude, 'lng': f.center.longitude},
      };

  GeoFarm _farmFromMap(Map<String, dynamic> m) => GeoFarm(
        id: m['id'] as String,
        name: m['name'] as String,
        owner: m['owner'] as String,
        region: m['region'] as String,
        center: LatLng((m['center']['lat'] as num).toDouble(), (m['center']['lng'] as num).toDouble()),
      );

  Map<String, dynamic> _fieldToMap(GeoField f) => {
        'id': f.id,
        'farmId': f.farmId,
        'name': f.name,
        'hectares': f.hectares,
        'crop': f.crop,
        'healthScore': f.healthScore,
        'status': f.status,
        'lastScoutDate': f.lastScoutDate,
        'boundary': f.boundary.map((p) => {'lat': p.latitude, 'lng': p.longitude}).toList(),
      };

  GeoField _fieldFromMap(Map<String, dynamic> m) => GeoField(
        id: m['id'] as String,
        farmId: m['farmId'] as String,
        name: m['name'] as String,
        boundary: (m['boundary'] as List<dynamic>)
            .map((b) => LatLng((b['lat'] as num).toDouble(), (b['lng'] as num).toDouble()))
            .toList(),
        hectares: (m['hectares'] as num).toDouble(),
        crop: m['crop'] as String,
        healthScore: (m['healthScore'] as num).toDouble(),
        status: m['status'] as String,
        lastScoutDate: m['lastScoutDate'] as String,
      );

  @override
  Future<void> deleteField(String fieldId) async {
    final store = await _readStore();
    final fields = (store['fields'] as List<dynamic>).where((f) => (f['id'] as String) != fieldId).toList();
    store['fields'] = fields;
    await _writeStore(store);
  }

  @override
  Future<void> deleteFarm(String id) async {
    final store = await _readStore();
    store['farms'] = (store['farms'] as List<dynamic>).where((f) => (f['id'] as String) != id).toList();
    store['fields'] = (store['fields'] as List<dynamic>).where((fld) => (fld['farmId'] as String) != id).toList();
    await _writeStore(store);
  }

  @override
  Future<List<GeoFarm>> getAllFarms() async {
    final store = await _readStore();
    final farms = (store['farms'] as List<dynamic>).map((f) => _farmFromMap(f as Map<String, dynamic>)).toList();
    return farms;
  }

  @override
  Future<GeoFarm?> getFarmById(String id) async {
    final store = await _readStore();
    final found = (store['farms'] as List<dynamic>).firstWhere((f) => (f['id'] as String) == id, orElse: () => null);
    return found == null ? null : _farmFromMap(found as Map<String, dynamic>);
  }

  @override
  Future<List<GeoField>> getFieldsForFarm(String farmId) async {
    final store = await _readStore();
    final fs = (store['fields'] as List<dynamic>)
        .where((f) => (f['farmId'] as String) == farmId)
        .map((f) => _fieldFromMap(f as Map<String, dynamic>))
        .toList();
    return fs;
  }

  Future<void> _ensureFarmExists(String farmId, Map<String, dynamic> store) async {
    final exists = (store['farms'] as List<dynamic>).any((f) => (f['id'] as String) == farmId);
    if (!exists) {
      // create a minimal placeholder farm
      store['farms'].add({
        'id': farmId,
        'name': 'Unknown Farm $farmId',
        'owner': 'Unknown',
        'region': 'Unknown',
        'center': {'lat': 0.0, 'lng': 0.0}
      });
    }
  }

  @override
  Future<void> saveFarm(GeoFarm farm) async {
    final store = await _readStore();
    final farms = (store['farms'] as List<dynamic>);
    farms.removeWhere((f) => (f['id'] as String) == farm.id);
    farms.add(_farmToMap(farm));
    store['farms'] = farms;
    await _writeStore(store);
  }

  @override
  Future<void> saveField(GeoField field) async {
    final store = await _readStore();
    await _ensureFarmExists(field.farmId, store);
    final fields = (store['fields'] as List<dynamic>);
    fields.removeWhere((f) => (f['id'] as String) == field.id);
    fields.add(_fieldToMap(field));
    store['fields'] = fields;
    await _writeStore(store);
  }
}

/// Web-safe in-memory implementation of [AiDataAccessService].
class InMemoryAiDataService implements AiDataAccessService {
  final Map<String, GeoFarm> _farms = {};
  final Map<String, GeoField> _fields = {};

  @override
  Future<List<GeoFarm>> getAllFarms() async => _farms.values.toList();

  @override
  Future<GeoFarm?> getFarmById(String id) async => _farms[id];

  @override
  Future<void> saveFarm(GeoFarm farm) async {
    _farms[farm.id] = farm;
  }

  @override
  Future<void> deleteFarm(String id) async {
    _farms.remove(id);
    _fields.removeWhere((_, field) => field.farmId == id);
  }

  @override
  Future<List<GeoField>> getFieldsForFarm(String farmId) async =>
      _fields.values.where((f) => f.farmId == farmId).toList();

  @override
  Future<void> saveField(GeoField field) async {
    _fields[field.id] = field;
  }

  @override
  Future<void> deleteField(String fieldId) async {
    _fields.remove(fieldId);
  }
}

