import 'dart:convert';

import 'package:latlong2/latlong.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'ai_data_service.dart';
import 'package:verdi/features/geospatial/models/geospatial_models.dart';

/// SQLite-backed implementation of [AiDataAccessService].
class SqliteAiDataService implements AiDataAccessService {
  static const _dbName = 'verdi_ai_data.db';
  static const _farmsTable = 'farms';
  static const _fieldsTable = 'fields';

  Database? _db;

  Future<Database> get _database async {
    if (_db != null) return _db!;
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _dbName);
    _db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return _db!;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_farmsTable (
        id TEXT PRIMARY KEY,
        name TEXT,
        owner TEXT,
        region TEXT,
        center_lat REAL,
        center_lng REAL
      )
    ''');

    await db.execute('''
      CREATE TABLE $_fieldsTable (
        id TEXT PRIMARY KEY,
        farmId TEXT,
        name TEXT,
        hectares REAL,
        crop TEXT,
        healthScore REAL,
        status TEXT,
        lastScoutDate TEXT,
        boundary TEXT,
        FOREIGN KEY(farmId) REFERENCES $_farmsTable(id) ON DELETE CASCADE
      )
    ''');
  }

  Map<String, Object?> _farmToRow(GeoFarm f) => {
        'id': f.id,
        'name': f.name,
        'owner': f.owner,
        'region': f.region,
        'center_lat': f.center.latitude,
        'center_lng': f.center.longitude,
      };

  GeoFarm _farmFromRow(Map<String, Object?> m) => GeoFarm(
        id: m['id'] as String,
        name: m['name'] as String,
        center: LatLng((m['center_lat'] as num).toDouble(), (m['center_lng'] as num).toDouble()),
        owner: m['owner'] as String,
        region: m['region'] as String,
      );

  Map<String, Object?> _fieldToRow(GeoField f) => {
        'id': f.id,
        'farmId': f.farmId,
        'name': f.name,
        'hectares': f.hectares,
        'crop': f.crop,
        'healthScore': f.healthScore,
        'status': f.status,
        'lastScoutDate': f.lastScoutDate,
        'boundary': jsonEncode(f.boundary.map((p) => {'lat': p.latitude, 'lng': p.longitude}).toList()),
      };

  GeoField _fieldFromRow(Map<String, Object?> m) => GeoField(
        id: m['id'] as String,
        farmId: m['farmId'] as String,
        name: m['name'] as String,
        boundary: (jsonDecode(m['boundary'] as String) as List<dynamic>)
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
    final db = await _database;
    await db.delete(_fieldsTable, where: 'id = ?', whereArgs: [fieldId]);
  }

  @override
  Future<void> deleteFarm(String id) async {
    final db = await _database;
    await db.delete(_fieldsTable, where: 'farmId = ?', whereArgs: [id]);
    await db.delete(_farmsTable, where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List<GeoFarm>> getAllFarms() async {
    final db = await _database;
    final rows = await db.query(_farmsTable);
    return rows.map((r) => _farmFromRow(r)).toList();
  }

  @override
  Future<GeoFarm?> getFarmById(String id) async {
    final db = await _database;
    final rows = await db.query(_farmsTable, where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return _farmFromRow(rows.first);
  }

  @override
  Future<List<GeoField>> getFieldsForFarm(String farmId) async {
    final db = await _database;
    final rows = await db.query(_fieldsTable, where: 'farmId = ?', whereArgs: [farmId]);
    return rows.map((r) => _fieldFromRow(r)).toList();
  }

  @override
  Future<void> saveFarm(GeoFarm farm) async {
    final db = await _database;
    await db.insert(_farmsTable, _farmToRow(farm), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> saveField(GeoField field) async {
    final db = await _database;
    await db.insert(_fieldsTable, _fieldToRow(field), conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
