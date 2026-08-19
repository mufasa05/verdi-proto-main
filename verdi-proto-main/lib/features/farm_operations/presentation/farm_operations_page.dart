import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../state/app_state.dart';
import '../../../state/farm_operations_state.dart';
import '../../crop_health/presentation/crop_health_page.dart';
import '../../irrigation/presentation/farmer_irrigation_view.dart';
import '../../irrigation/presentation/government_irrigation_view.dart';

/// Unified Farm Operations & Agronomy Hub
/// Merges Crop Health, Smart Irrigation, Livestock Logbook, Inventory & Field Records.
class FarmOperationsPage extends ConsumerStatefulWidget {
  const FarmOperationsPage({super.key});

  @override
  ConsumerState<FarmOperationsPage> createState() => _FarmOperationsPageState();
}

class _FarmOperationsPageState extends ConsumerState<FarmOperationsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const _green = Color(0xFF16A34A);
  static const _dark = Color(0xFF0F172A);
  static const _muted = Color(0xFF64748B);
  static const _bg = Color(0xFFF8FAFC);
  static const _cardBorder = Color(0xFFE2E8F0);
  static const _amber = Color(0xFFD97706);
  static const _blue = Color(0xFF2563EB);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddLivestockDialog() {
    final tagCtrl = TextEditingController();
    final breedCtrl = TextEditingController();
    final weightCtrl = TextEditingController(text: '350');
    final enclosureCtrl = TextEditingController(text: 'Paddock 1');
    final vaccineCtrl = TextEditingController(text: 'Anthrax & Blackquarter');
    final yieldCtrl = TextEditingController(text: '0');
    final notesCtrl = TextEditingController();
    LivestockType selectedType = LivestockType.cattle;
    String selectedGender = 'Female';
    String selectedHealth = 'Healthy';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.pets_rounded, color: _green),
              const SizedBox(width: 8),
              Text('Add Digital Livestock Record', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<LivestockType>(
                  value: selectedType,
                  decoration: const InputDecoration(labelText: 'Species / Animal Type', border: OutlineInputBorder()),
                  items: LivestockType.values
                      .map((t) => DropdownMenuItem(
                            value: t,
                            child: Text(t.name.toUpperCase()),
                          ))
                      .toList(),
                  onChanged: (v) => setDlgState(() => selectedType = v!),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: tagCtrl,
                  decoration: const InputDecoration(labelText: 'Tag / ID Number (e.g. ZW-BR-9901)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: breedCtrl,
                  decoration: const InputDecoration(labelText: 'Breed or Flock Name', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedGender,
                        decoration: const InputDecoration(labelText: 'Gender', border: OutlineInputBorder()),
                        items: ['Female', 'Male', 'Mixed / Flock']
                            .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                            .toList(),
                        onChanged: (v) => setDlgState(() => selectedGender = v!),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: weightCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Weight (kg)', border: OutlineInputBorder()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedHealth,
                  decoration: const InputDecoration(labelText: 'Health Status', border: OutlineInputBorder()),
                  items: ['Healthy', 'Under Treatment', 'Quarantine', 'Vaccinated']
                      .map((h) => DropdownMenuItem(value: h, child: Text(h)))
                      .toList(),
                  onChanged: (v) => setDlgState(() => selectedHealth = v!),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: vaccineCtrl,
                  decoration: const InputDecoration(labelText: 'Last Vaccine Administered', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: enclosureCtrl,
                  decoration: const InputDecoration(labelText: 'Paddock / Enclosure / Pen', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: notesCtrl,
                  decoration: const InputDecoration(labelText: 'Veterinary / Growth Notes', border: OutlineInputBorder()),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (tagCtrl.text.trim().isEmpty) return;
                ref.read(farmOperationsProvider.notifier).addLivestock(
                      LivestockRecord(
                        id: 'LST-${DateTime.now().millisecondsSinceEpoch}',
                        tagNumber: tagCtrl.text.trim(),
                        nameOrBreed: breedCtrl.text.trim().isEmpty ? 'General Breed' : breedCtrl.text.trim(),
                        type: selectedType,
                        gender: selectedGender,
                        birthOrAcquiredDate: DateTime.now().toIso8601String().split('T').first,
                        weightKg: double.tryParse(weightCtrl.text.trim()) ?? 0.0,
                        healthStatus: selectedHealth,
                        lastVaccinationDate: DateTime.now().toIso8601String().split('T').first,
                        lastVaccineName: vaccineCtrl.text.trim(),
                        dailyYield: double.tryParse(yieldCtrl.text.trim()) ?? 0.0,
                        yieldUnit: selectedType == LivestockType.dairy ? 'L/day' : '',
                        enclosureOrPaddock: enclosureCtrl.text.trim(),
                        notes: notesCtrl.text.trim(),
                      ),
                    );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Livestock digital record saved.'), backgroundColor: _green),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: _green, foregroundColor: Colors.white),
              child: const Text('Save Record'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddInventoryDialog() {
    final nameCtrl = TextEditingController();
    final stockCtrl = TextEditingController();
    final threshCtrl = TextEditingController(text: '10');
    final unitCtrl = TextEditingController(text: 'bags (50kg)');
    final costCtrl = TextEditingController(text: '35.00');
    final locCtrl = TextEditingController(text: 'Main Store');
    String selectedCat = 'Fertilizer';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.inventory_2_outlined, color: _green),
              const SizedBox(width: 8),
              Text('Log Farm Input / Inventory', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedCat,
                  decoration: const InputDecoration(labelText: 'Input Category', border: OutlineInputBorder()),
                  items: ['Fertilizer', 'Seed', 'Agrochemical', 'Feed', 'Fuel', 'Tool']
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setDlgState(() => selectedCat = v!),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Item / Input Name', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: stockCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Quantity in Stock', border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: unitCtrl,
                        decoration: const InputDecoration(labelText: 'Unit (bags, L, kg)', border: OutlineInputBorder()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: threshCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Reorder Min Threshold', border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: costCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Unit Cost (US\$)', border: OutlineInputBorder()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: locCtrl,
                  decoration: const InputDecoration(labelText: 'Storage Location', border: OutlineInputBorder()),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty) return;
                ref.read(farmOperationsProvider.notifier).addInventoryItem(
                      FarmInventoryItem(
                        id: 'INV-${DateTime.now().millisecondsSinceEpoch}',
                        itemName: nameCtrl.text.trim(),
                        category: selectedCat,
                        currentStock: double.tryParse(stockCtrl.text.trim()) ?? 0.0,
                        minimumThreshold: double.tryParse(threshCtrl.text.trim()) ?? 10.0,
                        unit: unitCtrl.text.trim(),
                        unitCostUsd: double.tryParse(costCtrl.text.trim()) ?? 0.0,
                        storageLocation: locCtrl.text.trim(),
                        expiryDate: '2028-01-01',
                        lastRestockedDate: DateTime.now().toIso8601String().split('T').first,
                      ),
                    );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Farm inventory updated.'), backgroundColor: _green),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: _green, foregroundColor: Colors.white),
              child: const Text('Save Inventory'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddActivityDialog() {
    final activityCtrl = TextEditingController();
    final fieldCtrl = TextEditingController(text: 'Block A');
    final workerCtrl = TextEditingController();
    final equipCtrl = TextEditingController(text: 'Tractor & Implement');
    final inputsCtrl = TextEditingController();
    final obsCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.assignment_outlined, color: _green),
            const SizedBox(width: 8),
            Text('Log Farm Activity / Task', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: activityCtrl,
                decoration: const InputDecoration(labelText: 'Activity Name (e.g. Planting, Spraying, Harvest)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: fieldCtrl,
                decoration: const InputDecoration(labelText: 'Field / Plot / Zone Location', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: workerCtrl,
                decoration: const InputDecoration(labelText: 'Assigned Operator / Team', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: equipCtrl,
                decoration: const InputDecoration(labelText: 'Equipment / Machinery Used', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: inputsCtrl,
                decoration: const InputDecoration(labelText: 'Inputs Consumed (Fertilizer, Diesel, etc.)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: obsCtrl,
                decoration: const InputDecoration(labelText: 'Agronomic Observations', border: OutlineInputBorder()),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (activityCtrl.text.trim().isEmpty) return;
              ref.read(farmOperationsProvider.notifier).addActivity(
                    FarmActivityRecord(
                      id: 'ACT-${DateTime.now().millisecondsSinceEpoch}',
                      activityType: activityCtrl.text.trim(),
                      fieldOrPlot: fieldCtrl.text.trim(),
                      performedBy: workerCtrl.text.trim().isEmpty ? 'Farm Staff' : workerCtrl.text.trim(),
                      date: 'Today, ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                      equipmentUsed: equipCtrl.text.trim(),
                      inputsUsed: inputsCtrl.text.trim(),
                      observations: obsCtrl.text.trim(),
                      status: 'Completed',
                    ),
                  );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Farm field activity logged.'), backgroundColor: _green),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: _green, foregroundColor: Colors.white),
            child: const Text('Save Activity'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final role = ref.watch(appStateProvider).role;
    final farmData = ref.watch(farmOperationsProvider);

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _green.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.agriculture_rounded, color: _green, size: 22),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Farm Operations & Agronomy Hub',
                  style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: _dark),
                ),
                Text(
                  'Crops, Irrigation, Livestock Registry, Inputs & Field Logbooks',
                  style: GoogleFonts.inter(fontSize: 11, color: _muted),
                ),
              ],
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Quick Farm Actions',
            icon: const Icon(Icons.add_circle_outline_rounded, color: _green, size: 24),
            onSelected: (val) {
              if (val == 'livestock') _showAddLivestockDialog();
              if (val == 'inventory') _showAddInventoryDialog();
              if (val == 'activity') _showAddActivityDialog();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'livestock',
                child: Row(children: [Icon(Icons.pets, color: _green, size: 18), SizedBox(width: 8), Text('Log Livestock Animal')]),
              ),
              const PopupMenuItem(
                value: 'inventory',
                child: Row(children: [Icon(Icons.inventory_2, color: _blue, size: 18), SizedBox(width: 8), Text('Add Input / Stock')]),
              ),
              const PopupMenuItem(
                value: 'activity',
                child: Row(children: [Icon(Icons.assignment, color: _amber, size: 18), SizedBox(width: 8), Text('Log Field Activity')]),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: _green,
          unselectedLabelColor: _muted,
          indicatorColor: _green,
          indicatorWeight: 3,
          labelStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(icon: Icon(Icons.dashboard_outlined, size: 18), text: 'Overview'),
            Tab(icon: Icon(Icons.psychology_outlined, size: 18), text: 'Crop Health & AI'),
            Tab(icon: Icon(Icons.water_drop_outlined, size: 18), text: 'Smart Irrigation'),
            Tab(icon: Icon(Icons.pets_outlined, size: 18), text: 'Livestock Logbook'),
            Tab(icon: Icon(Icons.inventory_2_outlined, size: 18), text: 'Inputs & Inventory'),
            Tab(icon: Icon(Icons.assignment_outlined, size: 18), text: 'Field Activities'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(farmData),
          const CropHealthPage(),
          role == UserRole.government
              ? const GovernmentIrrigationView()
              : const FarmerIrrigationView(readOnly: false),
          _buildLivestockLogbookTab(farmData),
          _buildInventoryTab(farmData),
          _buildFieldActivitiesTab(farmData),
        ],
      ),
    );
  }

  // ── 1. Overview Tab ────────────────────────────────────────────────────────
  Widget _buildOverviewTab(FarmOperationsState state) {
    final lowStockItems = state.inventory.where((i) => i.isLowStock).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KPI Grid
          LayoutBuilder(builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 650;
            return GridView.count(
              crossAxisCount: isMobile ? 2 : 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: isMobile ? 1.4 : 1.6,
              children: [
                _buildMetricCard('Live Livestock', '${state.livestock.length} Heads', 'Cattle, Goats, Poultry', Icons.pets, _green, () => _tabController.animateTo(3)),
                _buildMetricCard('Input Inventory', '${state.inventory.length} Items', '${lowStockItems.length} Low-Stock alerts', Icons.inventory_2, _blue, () => _tabController.animateTo(4)),
                _buildMetricCard('Crop Health Status', '94% Optimal', 'NDVI 0.76 (Healthy)', Icons.eco, _green, () => _tabController.animateTo(1)),
                _buildMetricCard('Smart Irrigation', '3 Zones Active', 'Solar Pumps Online', Icons.water_drop, Colors.cyan, () => _tabController.animateTo(2)),
              ],
            );
          }),
          const SizedBox(height: 20),

          // Quick Navigation Hub
          Text('Farm Operations Quick Launch', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: _dark)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  'Crop Health Diagnostics',
                  'Run AI pest scans, NDVI satellite scans and blight analysis',
                  Icons.biotech_rounded,
                  _green,
                  () => _tabController.animateTo(1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionCard(
                  'Smart Irrigation Controls',
                  'Manage automated valves, soil moisture, and pump schedules',
                  Icons.water_drop_rounded,
                  _blue,
                  () => _tabController.animateTo(2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  'Digital Animal Registry',
                  'Track weights, vaccines, dairy yields and tag histories',
                  Icons.pets_rounded,
                  _amber,
                  () => _tabController.animateTo(3),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionCard(
                  'Inputs & Field Logbook',
                  'Fertilizer stocks, seeds, agrochemicals, and labor tasks',
                  Icons.assignment_turned_in_rounded,
                  Colors.purple,
                  () => _tabController.animateTo(5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Recent Field Activities Feed
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Latest Farm Activity Log', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: _dark)),
              TextButton.icon(
                onPressed: _showAddActivityDialog,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Log Task'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...state.activities.take(3).map((act) => _buildActivityTile(act)),
        ],
      ),
    );
  }

  // ── 2. Livestock Logbook Tab ────────────────────────────────────────────────
  Widget _buildLivestockLogbookTab(FarmOperationsState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Digital Livestock Logbook', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: _dark)),
                  Text('Electronic ear tag IDs, vaccinations, yields, weights & health records', style: GoogleFonts.inter(fontSize: 12, color: _muted)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _showAddLivestockDialog,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Animal'),
                style: ElevatedButton.styleFrom(backgroundColor: _green, foregroundColor: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (state.livestock.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Text('No livestock records found. Tap "Add Animal" to start.', style: TextStyle(color: _muted)),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.livestock.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, idx) {
                final l = state.livestock[idx];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _cardBorder),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _green.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.pets, color: _green, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(l.tagNumber, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14, color: _dark)),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: l.healthStatus == 'Healthy' ? _green.withOpacity(0.15) : _amber.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    l.healthStatus,
                                    style: TextStyle(
                                      color: l.healthStatus == 'Healthy' ? _green : _amber,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10.5,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Text('${l.weightKg} kg', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: _dark, fontSize: 13)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text('${l.nameOrBreed} · ${l.gender} · ${l.enclosureOrPaddock}', style: const TextStyle(fontSize: 12, color: _muted)),
                            const SizedBox(height: 4),
                            Text('💉 Last Vaccine: ${l.lastVaccineName} (${l.lastVaccinationDate})', style: const TextStyle(fontSize: 11.5, color: _dark)),
                            if (l.dailyYield > 0)
                              Text('🥛 Daily Yield: ${l.dailyYield} ${l.yieldUnit}', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: _blue)),
                            if (l.notes.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text('📝 ${l.notes}', style: const TextStyle(fontSize: 11, color: _muted, fontStyle: FontStyle.italic)),
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                        onPressed: () => ref.read(farmOperationsProvider.notifier).deleteLivestock(l.id),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // ── 3. Inputs & Inventory Tab ───────────────────────────────────────────────
  Widget _buildInventoryTab(FarmOperationsState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Farm Inputs & Inventory Ledger', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: _dark)),
                  Text('Stock thresholds, fertilizers, agrochemicals, feeds & fuel', style: GoogleFonts.inter(fontSize: 12, color: _muted)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _showAddInventoryDialog,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Stock'),
                style: ElevatedButton.styleFrom(backgroundColor: _blue, foregroundColor: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.inventory.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, idx) {
              final item = state.inventory[idx];
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: item.isLowStock ? Colors.red.withOpacity(0.4) : _cardBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _blue.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.inventory_2, color: _blue, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(item.itemName, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13.5, color: _dark)),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _bg,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: _cardBorder),
                                ),
                                child: Text(item.category, style: const TextStyle(fontSize: 10, color: _muted)),
                              ),
                              if (item.isLowStock) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: Colors.red.withOpacity(0.15), borderRadius: BorderRadius.circular(4)),
                                  child: const Text('LOW STOCK', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Colors.red)),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text('📍 ${item.storageLocation} · Restocked: ${item.lastRestockedDate}', style: const TextStyle(fontSize: 11.5, color: _muted)),
                          Text('💰 Unit Cost: US\$ ${item.unitCostUsd} / ${item.unit}', style: const TextStyle(fontSize: 11.5, color: _dark)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('${item.currentStock} ${item.unit}', style: GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 14, color: _dark)),
                        Text('Min: ${item.minimumThreshold}', style: const TextStyle(fontSize: 11, color: _muted)),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline, size: 18, color: _muted),
                              onPressed: () {
                                if (item.currentStock > 0) {
                                  ref.read(farmOperationsProvider.notifier).updateStock(item.id, item.currentStock - 1);
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline, size: 18, color: _green),
                              onPressed: () {
                                ref.read(farmOperationsProvider.notifier).updateStock(item.id, item.currentStock + 1);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ── 4. Field Activities Tab ─────────────────────────────────────────────────
  Widget _buildFieldActivitiesTab(FarmOperationsState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Field Tasks & Machinery Logbook', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: _dark)),
                  Text('Planting, spraying, tractor machinery service & labour records', style: GoogleFonts.inter(fontSize: 12, color: _muted)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _showAddActivityDialog,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Log Task'),
                style: ElevatedButton.styleFrom(backgroundColor: _amber, foregroundColor: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...state.activities.map((act) => _buildActivityTile(act)),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String mainVal, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: _muted)),
                Icon(icon, color: color, size: 18),
              ],
            ),
            Text(mainVal, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w900, color: _dark)),
            Text(subtitle, style: TextStyle(fontSize: 10.5, color: color, fontWeight: FontWeight.bold), maxLines: 1),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(String title, String desc, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _cardBorder),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13.5, color: _dark)),
                  const SizedBox(height: 2),
                  Text(desc, style: const TextStyle(fontSize: 11, color: _muted), maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: _muted),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityTile(FarmActivityRecord act) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _cardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _amber.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.assignment_turned_in_outlined, color: _amber, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(act.activityType, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13.5, color: _dark)),
                    Text(act.date, style: const TextStyle(fontSize: 11, color: _muted)),
                  ],
                ),
                const SizedBox(height: 4),
                Text('📍 ${act.fieldOrPlot} · Operator: ${act.performedBy}', style: const TextStyle(fontSize: 12, color: _muted)),
                if (act.inputsUsed.isNotEmpty)
                  Text('⚙️ Inputs / Equip: ${act.inputsUsed} · ${act.equipmentUsed}', style: const TextStyle(fontSize: 11.5, color: _dark)),
                if (act.observations.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text('🌾 Observations: ${act.observations}', style: const TextStyle(fontSize: 11, color: _muted, fontStyle: FontStyle.italic)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
