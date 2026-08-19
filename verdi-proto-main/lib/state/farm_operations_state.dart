import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Animal species and categories on the farm.
enum LivestockType {
  cattle,
  dairy,
  goats,
  sheep,
  poultry,
  pigs,
  other,
}

/// A digital animal health and productivity record.
class LivestockRecord {
  final String id;
  final String tagNumber;
  final String nameOrBreed;
  final LivestockType type;
  final String gender;
  final String birthOrAcquiredDate;
  final double weightKg;
  final String healthStatus; // Healthy, Under Treatment, Quarantine, Vaccinated
  final String lastVaccinationDate;
  final String lastVaccineName;
  final double dailyYield; // e.g. Litres of milk or eggs/day
  final String yieldUnit; // 'L/day', 'eggs/day', 'kg'
  final String enclosureOrPaddock;
  final String notes;

  const LivestockRecord({
    required this.id,
    required this.tagNumber,
    required this.nameOrBreed,
    required this.type,
    required this.gender,
    required this.birthOrAcquiredDate,
    required this.weightKg,
    required this.healthStatus,
    required this.lastVaccinationDate,
    required this.lastVaccineName,
    this.dailyYield = 0.0,
    this.yieldUnit = '',
    required this.enclosureOrPaddock,
    required this.notes,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'tagNumber': tagNumber,
        'nameOrBreed': nameOrBreed,
        'type': type.name,
        'gender': gender,
        'birthOrAcquiredDate': birthOrAcquiredDate,
        'weightKg': weightKg,
        'healthStatus': healthStatus,
        'lastVaccinationDate': lastVaccinationDate,
        'lastVaccineName': lastVaccineName,
        'dailyYield': dailyYield,
        'yieldUnit': yieldUnit,
        'enclosureOrPaddock': enclosureOrPaddock,
        'notes': notes,
      };

  factory LivestockRecord.fromJson(Map<String, dynamic> json) => LivestockRecord(
        id: json['id']?.toString() ?? 'LST-${DateTime.now().millisecondsSinceEpoch}',
        tagNumber: json['tagNumber']?.toString() ?? 'ZW-001',
        nameOrBreed: json['nameOrBreed']?.toString() ?? 'Brahman Cross',
        type: LivestockType.values.firstWhere(
          (t) => t.name == json['type']?.toString(),
          orElse: () => LivestockType.cattle,
        ),
        gender: json['gender']?.toString() ?? 'Female',
        birthOrAcquiredDate: json['birthOrAcquiredDate']?.toString() ?? '2024-03-15',
        weightKg: (json['weightKg'] as num?)?.toDouble() ?? 420.0,
        healthStatus: json['healthStatus']?.toString() ?? 'Healthy',
        lastVaccinationDate: json['lastVaccinationDate']?.toString() ?? '2026-05-10',
        lastVaccineName: json['lastVaccineName']?.toString() ?? 'Anthrax & Blackquarter',
        dailyYield: (json['dailyYield'] as num?)?.toDouble() ?? 0.0,
        yieldUnit: json['yieldUnit']?.toString() ?? '',
        enclosureOrPaddock: json['enclosureOrPaddock']?.toString() ?? 'Paddock B-North',
        notes: json['notes']?.toString() ?? 'Strong vigor and pasture weight gain.',
      );
}

/// Farm input inventory item record.
class FarmInventoryItem {
  final String id;
  final String itemName;
  final String category; // Seed, Fertilizer, Agrochemical, Feed, Fuel, Tool
  final double currentStock;
  final double minimumThreshold;
  final String unit; // 'kg', 'bags (50kg)', 'Litres', 'units'
  final double unitCostUsd;
  final String storageLocation;
  final String expiryDate;
  final String lastRestockedDate;

  const FarmInventoryItem({
    required this.id,
    required this.itemName,
    required this.category,
    required this.currentStock,
    required this.minimumThreshold,
    required this.unit,
    required this.unitCostUsd,
    required this.storageLocation,
    required this.expiryDate,
    required this.lastRestockedDate,
  });

  bool get isLowStock => currentStock <= minimumThreshold;

  Map<String, dynamic> toJson() => {
        'id': id,
        'itemName': itemName,
        'category': category,
        'currentStock': currentStock,
        'minimumThreshold': minimumThreshold,
        'unit': unit,
        'unitCostUsd': unitCostUsd,
        'storageLocation': storageLocation,
        'expiryDate': expiryDate,
        'lastRestockedDate': lastRestockedDate,
      };

  factory FarmInventoryItem.fromJson(Map<String, dynamic> json) => FarmInventoryItem(
        id: json['id']?.toString() ?? 'INV-${DateTime.now().millisecondsSinceEpoch}',
        itemName: json['itemName']?.toString() ?? 'Compound D Fertilizer',
        category: json['category']?.toString() ?? 'Fertilizer',
        currentStock: (json['currentStock'] as num?)?.toDouble() ?? 45.0,
        minimumThreshold: (json['minimumThreshold'] as num?)?.toDouble() ?? 10.0,
        unit: json['unit']?.toString() ?? 'bags (50kg)',
        unitCostUsd: (json['unitCostUsd'] as num?)?.toDouble() ?? 36.0,
        storageLocation: json['storageLocation']?.toString() ?? 'Main Warehouse Bay 2',
        expiryDate: json['expiryDate']?.toString() ?? '2027-12-31',
        lastRestockedDate: json['lastRestockedDate']?.toString() ?? '2026-06-01',
      );
}

/// Farm activity & field log record.
class FarmActivityRecord {
  final String id;
  final String activityType; // Planting, Spraying, Fertilizer Application, Harvesting, Machinery Service, Scouting
  final String fieldOrPlot;
  final String performedBy;
  final String date;
  final String equipmentUsed;
  final String inputsUsed;
  final String observations;
  final String status; // Completed, In Progress, Scheduled

  const FarmActivityRecord({
    required this.id,
    required this.activityType,
    required this.fieldOrPlot,
    required this.performedBy,
    required this.date,
    required this.equipmentUsed,
    required this.inputsUsed,
    required this.observations,
    required this.status,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'activityType': activityType,
        'fieldOrPlot': fieldOrPlot,
        'performedBy': performedBy,
        'date': date,
        'equipmentUsed': equipmentUsed,
        'inputsUsed': inputsUsed,
        'observations': observations,
        'status': status,
      };

  factory FarmActivityRecord.fromJson(Map<String, dynamic> json) => FarmActivityRecord(
        id: json['id']?.toString() ?? 'ACT-${DateTime.now().millisecondsSinceEpoch}',
        activityType: json['activityType']?.toString() ?? 'Foliar Spraying',
        fieldOrPlot: json['fieldOrPlot']?.toString() ?? 'Plot 3 (Sugar Beans)',
        performedBy: json['performedBy']?.toString() ?? 'Tafadzwa & Team',
        date: json['date']?.toString() ?? '2026-08-18',
        equipmentUsed: json['equipmentUsed']?.toString() ?? 'Boom Sprayer Tractor-02',
        inputsUsed: json['inputsUsed']?.toString() ?? 'Bio-stimulant + Micronutrient Zinc',
        observations: json['observations']?.toString() ?? 'Good leaf coverage, 0% wind drift.',
        status: json['status']?.toString() ?? 'Completed',
      );
}

/// State notifier for Farm Operations: Livestock, Inventory, Field Logs
class FarmOperationsState {
  final List<LivestockRecord> livestock;
  final List<FarmInventoryItem> inventory;
  final List<FarmActivityRecord> activities;
  final bool isLoading;

  const FarmOperationsState({
    required this.livestock,
    required this.inventory,
    required this.activities,
    this.isLoading = false,
  });

  FarmOperationsState copyWith({
    List<LivestockRecord>? livestock,
    List<FarmInventoryItem>? inventory,
    List<FarmActivityRecord>? activities,
    bool? isLoading,
  }) {
    return FarmOperationsState(
      livestock: livestock ?? this.livestock,
      inventory: inventory ?? this.inventory,
      activities: activities ?? this.activities,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class FarmOperationsNotifier extends StateNotifier<FarmOperationsState> {
  static const _livestockPrefKey = 'verdi.farm.livestock_v2';
  static const _inventoryPrefKey = 'verdi.farm.inventory_v2';
  static const _activitiesPrefKey = 'verdi.farm.activities_v2';

  FarmOperationsNotifier()
      : super(const FarmOperationsState(
          livestock: [],
          inventory: [],
          activities: [],
          isLoading: true,
        )) {
    _loadAllRecords();
  }

  Future<void> _loadAllRecords() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 1. Livestock
      List<LivestockRecord> livestock = [];
      final rawLivestock = prefs.getString(_livestockPrefKey);
      if (rawLivestock != null && rawLivestock.isNotEmpty) {
        final List list = jsonDecode(rawLivestock);
        livestock = list.map((item) => LivestockRecord.fromJson(item as Map<String, dynamic>)).toList();
      } else {
        livestock = _defaultLivestock();
      }

      // 2. Inventory
      List<FarmInventoryItem> inventory = [];
      final rawInventory = prefs.getString(_inventoryPrefKey);
      if (rawInventory != null && rawInventory.isNotEmpty) {
        final List list = jsonDecode(rawInventory);
        inventory = list.map((item) => FarmInventoryItem.fromJson(item as Map<String, dynamic>)).toList();
      } else {
        inventory = _defaultInventory();
      }

      // 3. Activities
      List<FarmActivityRecord> activities = [];
      final rawActivities = prefs.getString(_activitiesPrefKey);
      if (rawActivities != null && rawActivities.isNotEmpty) {
        final List list = jsonDecode(rawActivities);
        activities = list.map((item) => FarmActivityRecord.fromJson(item as Map<String, dynamic>)).toList();
      } else {
        activities = _defaultActivities();
      }

      state = FarmOperationsState(
        livestock: livestock,
        inventory: inventory,
        activities: activities,
        isLoading: false,
      );
    } catch (_) {
      state = FarmOperationsState(
        livestock: _defaultLivestock(),
        inventory: _defaultInventory(),
        activities: _defaultActivities(),
        isLoading: false,
      );
    }
  }

  // --- Livestock Actions ---
  Future<void> addLivestock(LivestockRecord record) async {
    final updated = [record, ...state.livestock];
    state = state.copyWith(livestock: updated);
    _saveToPrefs(_livestockPrefKey, updated.map((e) => e.toJson()).toList());
  }

  Future<void> deleteLivestock(String id) async {
    final updated = state.livestock.where((item) => item.id != id).toList();
    state = state.copyWith(livestock: updated);
    _saveToPrefs(_livestockPrefKey, updated.map((e) => e.toJson()).toList());
  }

  // --- Inventory Actions ---
  Future<void> addInventoryItem(FarmInventoryItem item) async {
    final updated = [item, ...state.inventory];
    state = state.copyWith(inventory: updated);
    _saveToPrefs(_inventoryPrefKey, updated.map((e) => e.toJson()).toList());
  }

  Future<void> updateStock(String id, double newStock) async {
    final updated = state.inventory.map((item) {
      if (item.id == id) {
        return FarmInventoryItem(
          id: item.id,
          itemName: item.itemName,
          category: item.category,
          currentStock: newStock,
          minimumThreshold: item.minimumThreshold,
          unit: item.unit,
          unitCostUsd: item.unitCostUsd,
          storageLocation: item.storageLocation,
          expiryDate: item.expiryDate,
          lastRestockedDate: DateTime.now().toIso8601String().split('T').first,
        );
      }
      return item;
    }).toList();
    state = state.copyWith(inventory: updated);
    _saveToPrefs(_inventoryPrefKey, updated.map((e) => e.toJson()).toList());
  }

  Future<void> deleteInventoryItem(String id) async {
    final updated = state.inventory.where((item) => item.id != id).toList();
    state = state.copyWith(inventory: updated);
    _saveToPrefs(_inventoryPrefKey, updated.map((e) => e.toJson()).toList());
  }

  // --- Activity Actions ---
  Future<void> addActivity(FarmActivityRecord record) async {
    final updated = [record, ...state.activities];
    state = state.copyWith(activities: updated);
    _saveToPrefs(_activitiesPrefKey, updated.map((e) => e.toJson()).toList());
  }

  Future<void> _saveToPrefs(String key, List<dynamic> list) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, jsonEncode(list));
    } catch (_) {}
  }

  static List<LivestockRecord> _defaultLivestock() => [
        const LivestockRecord(
          id: 'LST-001',
          tagNumber: 'ZW-BR-8492',
          nameOrBreed: 'Brahman Bull (Stud)',
          type: LivestockType.cattle,
          gender: 'Male',
          birthOrAcquiredDate: '2023-04-12',
          weightKg: 680.0,
          healthStatus: 'Healthy',
          lastVaccinationDate: '2026-04-10',
          lastVaccineName: 'Lumpy Skin Disease & Anthrax',
          dailyYield: 0.0,
          yieldUnit: '',
          enclosureOrPaddock: 'Breeding Paddock 1',
          notes: 'Prime breeding sire. Outstanding body condition score 4.5/5.',
        ),
        const LivestockRecord(
          id: 'LST-002',
          tagNumber: 'ZW-HL-1044',
          nameOrBreed: 'Holstein-Friesian Cow',
          type: LivestockType.dairy,
          gender: 'Female',
          birthOrAcquiredDate: '2023-08-20',
          weightKg: 540.0,
          healthStatus: 'Healthy',
          lastVaccinationDate: '2026-05-18',
          lastVaccineName: 'Bovine Viral Diarrhea (BVD)',
          dailyYield: 24.5,
          yieldUnit: 'L/day',
          enclosureOrPaddock: 'Milking Parlour Shed A',
          notes: '2nd lactation stage. Consistent high morning yield.',
        ),
        const LivestockRecord(
          id: 'LST-003',
          tagNumber: 'ZW-BG-3021',
          nameOrBreed: 'Boer Goat Doe',
          type: LivestockType.goats,
          gender: 'Female',
          birthOrAcquiredDate: '2024-02-10',
          weightKg: 62.0,
          healthStatus: 'Healthy',
          lastVaccinationDate: '2026-06-02',
          lastVaccineName: 'Pulpy Kidney (Clostridial)',
          dailyYield: 1.8,
          yieldUnit: 'L/day',
          enclosureOrPaddock: 'Goat Pen 2',
          notes: 'Expecting twin kids in September. Supplementing with mineral lick.',
        ),
        const LivestockRecord(
          id: 'LST-004',
          tagNumber: 'ZW-PL-BATCH-08',
          nameOrBreed: 'Cobb 500 Broiler Flock (500 birds)',
          type: LivestockType.poultry,
          gender: 'Mixed',
          birthOrAcquiredDate: '2026-07-28',
          weightKg: 1.85,
          healthStatus: 'Healthy',
          lastVaccinationDate: '2026-08-04',
          lastVaccineName: 'Gumboro & Newcastle Lasota',
          dailyYield: 0.0,
          yieldUnit: '',
          enclosureOrPaddock: 'Fowl Run House #3',
          notes: 'Day 22 of 35. FCR tracking at 1.48. Target harvest weight 2.2 kg.',
        ),
      ];

  static List<FarmInventoryItem> _defaultInventory() => [
        const FarmInventoryItem(
          id: 'INV-001',
          itemName: 'Compound D Basal Fertilizer',
          category: 'Fertilizer',
          currentStock: 65.0,
          minimumThreshold: 20.0,
          unit: 'bags (50kg)',
          unitCostUsd: 38.0,
          storageLocation: 'Main Fertilizer Shed A',
          expiryDate: '2028-06-30',
          lastRestockedDate: '2026-07-15',
        ),
        const FarmInventoryItem(
          id: 'INV-002',
          itemName: 'Ammonium Nitrate (AN) Top Dressing',
          category: 'Fertilizer',
          currentStock: 12.0,
          minimumThreshold: 25.0,
          unit: 'bags (50kg)',
          unitCostUsd: 42.0,
          storageLocation: 'Main Fertilizer Shed B',
          expiryDate: '2028-04-30',
          lastRestockedDate: '2026-06-10',
        ),
        const FarmInventoryItem(
          id: 'INV-003',
          itemName: 'SC719 Hybrid Seed Maize',
          category: 'Seed',
          currentStock: 30.0,
          minimumThreshold: 10.0,
          unit: 'packs (25kg)',
          unitCostUsd: 74.0,
          storageLocation: 'Cool Seed Vault #1',
          expiryDate: '2027-10-01',
          lastRestockedDate: '2026-08-01',
        ),
        const FarmInventoryItem(
          id: 'INV-004',
          itemName: 'Broiler Starter Crumbles',
          category: 'Feed',
          currentStock: 48.0,
          minimumThreshold: 15.0,
          unit: 'bags (50kg)',
          unitCostUsd: 26.50,
          storageLocation: 'Poultry Feed Store',
          expiryDate: '2026-11-30',
          lastRestockedDate: '2026-08-10',
        ),
        const FarmInventoryItem(
          id: 'INV-005',
          itemName: 'Emamectin Benzoate (Fall Armyworm control)',
          category: 'Agrochemical',
          currentStock: 8.0,
          minimumThreshold: 5.0,
          unit: 'Litres',
          unitCostUsd: 22.0,
          storageLocation: 'Chemical Safety Locker',
          expiryDate: '2027-05-15',
          lastRestockedDate: '2026-07-20',
        ),
        const FarmInventoryItem(
          id: 'INV-006',
          itemName: 'Low Sulfur Diesel (Tractor & Gen)',
          category: 'Fuel',
          currentStock: 850.0,
          minimumThreshold: 300.0,
          unit: 'Litres',
          unitCostUsd: 1.62,
          storageLocation: 'Fuel Tank Farm Bay',
          expiryDate: '2027-01-01',
          lastRestockedDate: '2026-08-12',
        ),
      ];

  static List<FarmActivityRecord> _defaultActivities() => [
        const FarmActivityRecord(
          id: 'ACT-001',
          activityType: 'Smart Drip Irrigation Cycle',
          fieldOrPlot: 'Zone 1 (Eastern Tomato Block)',
          performedBy: 'Automated Solar Solenoid #4',
          date: 'Today, 06:00 AM',
          equipmentUsed: 'Solar Submersible Pump + Drip Lines',
          inputsUsed: 'Water 14,000 Litres + Soluble Calcium Nitrate',
          observations: 'Soil moisture restored to 78% field capacity.',
          status: 'Completed',
        ),
        const FarmActivityRecord(
          id: 'ACT-002',
          activityType: 'Livestock Dip & Tick Treatment',
          fieldOrPlot: 'Cattle Dip Tank #1',
          performedBy: 'Tendai & Livestock Handlers',
          date: 'Yesterday, 09:30 AM',
          equipmentUsed: 'Plunge Dip Tank',
          inputsUsed: 'Triatix Amitraz Dip Wash 1:500',
          observations: '48 cattle treated. Zero bont ticks observed.',
          status: 'Completed',
        ),
        const FarmActivityRecord(
          id: 'ACT-003',
          activityType: 'Land Prep & Disc Harrowing',
          fieldOrPlot: 'Field 4 (Summer Soya Prep)',
          performedBy: 'Simbarashe (Tractor Operator)',
          date: '2026-08-17',
          equipmentUsed: 'John Deere 75HP + Heavy Disc Harrow',
          inputsUsed: 'Diesel 45 Litres',
          observations: '4.5 hectares completed. Good clod breakdown.',
          status: 'Completed',
        ),
      ];
}

final farmOperationsProvider =
    StateNotifierProvider<FarmOperationsNotifier, FarmOperationsState>((ref) {
  return FarmOperationsNotifier();
});
