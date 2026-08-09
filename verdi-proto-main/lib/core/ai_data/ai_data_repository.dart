import 'package:verdi/core/ai_data/ai_data_service.dart';
import 'package:verdi/features/geospatial/models/geospatial_models.dart';

class AiDataRepository {
  final AiDataAccessService service;

  AiDataRepository({required this.service});

  Future<List<GeoFarm>> fetchAllFarms() => service.getAllFarms();
  Future<GeoFarm?> fetchFarm(String id) => service.getFarmById(id);
  Future<void> saveFarm(GeoFarm farm) => service.saveFarm(farm);
  Future<void> deleteFarm(String id) => service.deleteFarm(id);

  Future<List<GeoField>> fetchFields(String farmId) => service.getFieldsForFarm(farmId);
  Future<void> saveField(GeoField field) => service.saveField(field);
  Future<void> deleteField(String id) => service.deleteField(id);
}
