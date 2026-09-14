import 'package:flutter_test/flutter_test.dart';
import 'package:verdi/features/traceability/models/batch_model.dart';
import 'package:verdi/features/traceability/models/repositories/in_memory_traceability_repository.dart';
import 'package:verdi/features/traceability/models/repositories/supabase_traceability_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SupabaseTraceabilityRepository Tests', () {
    late SupabaseTraceabilityRepository repo;
    late InMemoryTraceabilityRepository fallback;

    setUp(() {
      fallback = InMemoryTraceabilityRepository();
      repo = SupabaseTraceabilityRepository(fallbackRepository: fallback);
    });

    test('Falls back seamlessly to local cache when Supabase is uninitialized', () async {
      final farms = await repo.getFarms();
      expect(farms, isNotEmpty);
      expect(farms.first.name, isNotEmpty);

      final batches = await repo.getBatches();
      expect(batches, isNotEmpty);
    });

    test('Supports CRUD operations with fallback persistence', () async {
      final newBatch = BatchModel(
        id: 'test-batch-001',
        batchCode: 'BATCH-2026-TST',
        farmId: 'farm-1',
        fieldId: 'field-1',
        cropName: 'Organic Macadamia',
        harvestDate: DateTime.now(),
        quantity: 450,
        unit: 'kg',
        status: 'Active',
        readinessScore: 92.5,
        originVerified: true,
        inspectionPassed: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repo.saveBatch(newBatch);

      final fetched = await repo.getBatchById('test-batch-001');
      expect(fetched, isNotNull);
      expect(fetched?.cropName, 'Organic Macadamia');
      expect(fetched?.quantity, 450);

      await repo.deleteBatch('test-batch-001');
      final afterDelete = await repo.getBatchById('test-batch-001');
      expect(afterDelete, isNull);
    });
  });
}
