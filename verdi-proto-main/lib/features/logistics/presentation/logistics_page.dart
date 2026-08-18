import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

import 'package:verdi/features/logistics/data/logistics_data.dart';
import 'package:verdi/features/logistics/presentation/widgets/tracking_map.dart';
import '../../../state/platform_data_state.dart';
import '../../../state/app_state.dart';
import '../../../features/auth/state/auth_state.dart';
import 'package:verdi/core/services/verdi_api_service.dart';
import '../../analytics/data/analytics_export_service.dart';
import 'logistics_map_page.dart';

class LogisticsPage extends ConsumerStatefulWidget {
  const LogisticsPage({super.key});

  @override
  ConsumerState<LogisticsPage> createState() => _LogisticsPageState();
}

class _LogisticsPageState extends ConsumerState<LogisticsPage> {
  static const green = Color(0xFF16A34A);
  static const dark = Color(0xFF0F172A);
  static const muted = Color(0xFF64748B);
  static const background = Color(0xFFF4F7FB);

  final List<String> _filters = const [
    'All',
    'Pending',
    'Picked up',
    'On the way',
    'Delivered',
  ];

  String _selectedFilter = 'All';
  String? _selectedDeliveryId;

  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  static const Map<String, LatLng> _locationCoordinates = {
    'Chiredzi Farm': LatLng(-21.05, 31.67),
    'Harare Market': LatLng(-17.8638, 31.0285),
    'Mambo Farm': LatLng(-19.45, 29.81),
    'Masvingo Depot': LatLng(-20.0637, 30.8276),
    'Sunrise Poultry': LatLng(-20.15, 28.58),
    'Bulawayo Center': LatLng(-20.17, 28.56),
    'Mufasa Ranch': LatLng(-20.93, 29.01),
    'Gwanda Yard': LatLng(-20.94, 29.02),
  };

  List<DeliveryItem> _getFilteredDeliveries(List<DeliveryItem> allDeliveries) {
    final user = ref.watch(authStateProvider).user;
    final role = ref.watch(appStateProvider).role;
    
    List<DeliveryItem> userDeliveries = allDeliveries;
    if (role != UserRole.admin && user != null) {
      final filtered = allDeliveries.where((d) {
        final isCustomer = d.customer.toLowerCase() == user.fullName.toLowerCase() || 
                           d.customer.toLowerCase().contains(user.fullName.toLowerCase()) ||
                           user.fullName.toLowerCase().contains(d.customer.toLowerCase());
        final isDriver = d.driver.toLowerCase() == user.fullName.toLowerCase() || 
                         d.driver.toLowerCase().contains(user.fullName.toLowerCase()) ||
                         user.fullName.toLowerCase().contains(d.driver.toLowerCase());
        return isCustomer || isDriver;
      }).toList();
      if (filtered.isNotEmpty) {
        userDeliveries = filtered;
      }
    }

    if (_selectedFilter == 'All') return userDeliveries;
    return userDeliveries.where((d) => d.status == _selectedFilter).toList();
  }

  void _showUpdateStatusDialog(DeliveryItem item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Update status for ${item.id}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: ['Pending', 'Picked up', 'On the way', 'Delivered'].map((status) {
              return ListTile(
                title: Text(status),
                trailing: item.status == status ? const Icon(Icons.check, color: green) : null,
                onTap: () {
                  Navigator.pop(context);
                  _updateDeliveryStatus(item.id, status);
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _updateDeliveryStatus(String id, String newStatus) {
    ref.read(deliveriesListProvider.notifier).updateDeliveryStatus(id, newStatus);
    try {
      VerdiApiService.instance.updateDispatchStatus(id, newStatus);
    } catch (_) {}
  }

  void _showBookDispatchDialog() {
    final productController = TextEditingController(text: 'Organic Avocados');
    final quantityController = TextEditingController(text: '350 kg');
    final customerController = TextEditingController(text: 'FreshMart Supermarkets');
    String selectedFrom = 'Chiredzi Farm';
    String selectedTo = 'Harare Market';
    String selectedDriver = 'Tafadzwa';
    String selectedVehicle = 'Truck ZW-21 (10-Ton Refrigerated)';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: const [
                  Icon(Icons.local_shipping_outlined, color: green, size: 24),
                  SizedBox(width: 10),
                  Text('Book Freight Dispatch'),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Assign vehicle, cargo, and route to live fleet grid.', style: TextStyle(fontSize: 12, color: muted)),
                    const SizedBox(height: 14),
                    TextField(
                      controller: productController,
                      decoration: InputDecoration(
                        labelText: 'Cargo / Produce Type',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: quantityController,
                            decoration: InputDecoration(
                              labelText: 'Cargo Weight / Qty',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: customerController,
                            decoration: InputDecoration(
                              labelText: 'Consignee / Client',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text('Origin Location:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: dark)),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<String>(
                      value: selectedFrom,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: ['Chiredzi Farm', 'Mambo Farm', 'Sunrise Poultry', 'Mufasa Ranch', 'Mutare Citrus Outgrowers']
                          .map((l) => DropdownMenuItem(value: l, child: Text(l, style: const TextStyle(fontSize: 12))))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setDialogState(() => selectedFrom = v);
                      },
                    ),
                    const SizedBox(height: 12),
                    const Text('Destination Depot / Market:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: dark)),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<String>(
                      value: selectedTo,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: ['Harare Market', 'Masvingo Depot', 'Bulawayo Center', 'Gwanda Yard', 'Beitbridge Gateway']
                          .map((l) => DropdownMenuItem(value: l, child: Text(l, style: const TextStyle(fontSize: 12))))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setDialogState(() => selectedTo = v);
                      },
                    ),
                    const SizedBox(height: 12),
                    const Text('Assigned Fleet Vehicle & Driver:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: dark)),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<String>(
                      value: selectedVehicle,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: [
                        'Truck ZW-21 (10-Ton Refrigerated)',
                        'Truck ZW-09 (15-Ton Tipper)',
                        'Van ZW-14 (3-Ton Cold Carrier)',
                        'Truck ZW-18 (Heavy Livestock Transport)'
                      ]
                          .map((v) => DropdownMenuItem(value: v, child: Text(v, style: const TextStyle(fontSize: 12))))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setDialogState(() => selectedVehicle = v);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                ElevatedButton.icon(
                  onPressed: () {
                    final id = '#DLV-${105 + ref.read(deliveriesListProvider).length}';
                    final newDelivery = DeliveryItem(
                      id: id,
                      customer: customerController.text.trim(),
                      product: productController.text.trim(),
                      quantity: quantityController.text.trim(),
                      from: selectedFrom,
                      to: selectedTo,
                      status: 'Pending',
                      driver: selectedDriver,
                      vehicle: selectedVehicle.split(' ').first,
                      eta: '2h 45m',
                      progress: 0.1,
                      hub: '${selectedFrom.split(' ').first} Hub',
                      priority: 'High',
                      riskLevel: 'Low',
                      exceptionType: 'None',
                      proofStatus: 'Awaiting Pickup',
                      temperature: '4°C',
                      distanceRemaining: '124 km',
                      timeline: ['Just Now: Dispatch order created & assigned to vehicle.'],
                    );
                    ref.read(deliveriesListProvider.notifier).addDelivery(newDelivery);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('🚚 Freight Dispatch $id successfully booked! Vehicle dispatched to $selectedFrom.'),
                        backgroundColor: green,
                      ),
                    );
                  },
                  icon: const Icon(Icons.check, size: 16),
                  label: const Text('Dispatch Freight'),
                  style: ElevatedButton.styleFrom(backgroundColor: green, foregroundColor: Colors.white),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDriverCallDialog(DeliveryItem item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: const [
              Icon(Icons.phone_in_talk_outlined, color: green, size: 24),
              SizedBox(width: 10),
              Text('Voice Radio Dispatch'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Connecting to ${item.driver} (${item.vehicle})...', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: dark)),
              const SizedBox(height: 8),
              Text('Shipment: ${item.id} • ${item.product} (${item.quantity})', style: const TextStyle(fontSize: 12, color: muted)),
              Text('Current Segment: En route on A4 Highway to ${item.to}', style: const TextStyle(fontSize: 12, color: muted)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: const Row(
                  children: [
                    Icon(Icons.mic, color: green, size: 18),
                    SizedBox(width: 8),
                    Text('Push-to-Talk 2-Way Audio Channel Active', style: TextStyle(color: green, fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('End Call'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('📡 Audio Dispatch sent to ${item.driver}: "Proceed directly to ${item.to} Bay #3"'), backgroundColor: green),
                );
              },
              icon: const Icon(Icons.send, size: 16),
              label: const Text('Send Audio Memo'),
              style: ElevatedButton.styleFrom(backgroundColor: green, foregroundColor: Colors.white),
            ),
          ],
        );
      },
    );
  }

  void _showColdChainDiagModal(DeliveryItem item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: const [
              Icon(Icons.ac_unit_outlined, color: Colors.blueAccent, size: 24),
              SizedBox(width: 10),
              Text('Cold Chain Diagnostic'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Telemetry for ${item.vehicle} (${item.id})', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: dark)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Container Temperature:'),
                  Text(item.temperature, style: const TextStyle(fontWeight: FontWeight.bold, color: green, fontSize: 14)),
                ],
              ),
              const SizedBox(height: 6),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Target Storage Threshold:'),
                  Text('+2.0°C to +8.0°C', style: TextStyle(fontWeight: FontWeight.bold, color: dark, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 6),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Relative Air Humidity:'),
                  Text('88.4%', style: TextStyle(fontWeight: FontWeight.bold, color: dark, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 6),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Compressor Motor RPM:'),
                  Text('2,400 RPM (Optimal)', style: TextStyle(fontWeight: FontWeight.bold, color: dark, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12)),
                child: const Row(
                  children: [
                    Icon(Icons.verified_outlined, color: Colors.blueAccent, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text('EUDR & HACCP Cold-Chain Compliance Verified. 0 Excursions Detected.', style: TextStyle(color: Colors.blueAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: dark, foregroundColor: Colors.white),
              child: const Text('Close Telemetry Sheet'),
            ),
          ],
        );
      },
    );
  }

  void _showElectronicPodModal(DeliveryItem item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: const [
              Icon(Icons.article_outlined, color: green, size: 24),
              SizedBox(width: 10),
              Text('Electronic Proof of Delivery (e-PoD)'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Consignment ID: ${item.id}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: dark)),
              Text('Consignee: ${item.customer}', style: const TextStyle(fontSize: 12, color: muted)),
              Text('Cargo: ${item.product} (${item.quantity})', style: const TextStyle(fontSize: 12, color: muted)),
              Text('Status: ${item.proofStatus}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: green)),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.black12),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.draw_outlined, color: dark, size: 28),
                    SizedBox(height: 4),
                    Text('Digitally Signed by Consignee & Carrier', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: dark)),
                    Text('GPS Verified • Timestamp 12:15 PM', style: TextStyle(fontSize: 10, color: muted)),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Dismiss'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('📄 e-PoD Certificate downloaded for ${item.id}!'), backgroundColor: green),
                );
              },
              icon: const Icon(Icons.download, size: 16),
              label: const Text('Download PDF e-PoD'),
              style: ElevatedButton.styleFrom(backgroundColor: green, foregroundColor: Colors.white),
            ),
          ],
        );
      },
    );
  }

  void _showRegisterVehicleDialog() {
    final modelController = TextEditingController();
    final colorController = TextEditingController();
    final plateController = TextEditingController();
    final regController = TextEditingController();
    final rateController = TextEditingController();
    final etaController = TextEditingController();
    final user = ref.read(authStateProvider).user;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Register New Vehicle'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: modelController, decoration: const InputDecoration(labelText: 'Vehicle Model (e.g. Scania R500)')),
                TextField(controller: colorController, decoration: const InputDecoration(labelText: 'Color')),
                TextField(controller: plateController, decoration: const InputDecoration(labelText: 'Plate Number')),
                TextField(controller: regController, decoration: const InputDecoration(labelText: 'Registration Number')),
                TextField(controller: rateController, decoration: const InputDecoration(labelText: 'Pricing (US\$ per km)'), keyboardType: TextInputType.number),
                TextField(controller: etaController, decoration: const InputDecoration(labelText: 'Estimated Prep/ETA (e.g. 30m)')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final model = modelController.text.trim();
                final color = colorController.text.trim();
                final plate = plateController.text.trim();
                final reg = regController.text.trim();
                final rate = double.tryParse(rateController.text.trim()) ?? 0.15;
                final eta = etaController.text.trim().isEmpty ? '30m' : etaController.text.trim();

                if (model.isNotEmpty && plate.isNotEmpty && reg.isNotEmpty) {
                  ref.read(trucksListProvider.notifier).addTruck(
                    TruckItem(
                      id: 'truck-${DateTime.now().millisecondsSinceEpoch}',
                      driver: user?.fullName ?? 'Operator',
                      vehicle: '$model ($color)',
                      plateNumber: plate,
                      regNumber: reg,
                      color: color,
                      model: model,
                      from: 'Harare Yard',
                      eta: eta,
                      costPerKm: rate,
                      rating: 5.0,
                      status: 'Ready for dispatch',
                    ),
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Register'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _exportDeliveries() async {
    final deliveries = ref.read(deliveriesListProvider);
    final delivered = deliveries.where((d) => d.status == 'Delivered').length;
    final rows = deliveries.map((d) => {
      'id': d.id,
      'customer': d.customer,
      'product': d.product,
      'from': d.from,
      'to': d.to,
      'driver': d.driver,
      'vehicle': d.vehicle,
      'status': d.status,
      'eta': d.eta,
      'progress': d.progress,
    }).toList();
    try {
      final file = await AnalyticsExportService.exportDeliveryPerformance(
        deliveries: rows,
        onTimeRate: 0.92,
        avgEta: '2h 18m',
        deliveredToday: delivered,
        failedCount: deliveries.where((d) => d.status == 'Pending').length,
      );
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Row(children: [
            Icon(Icons.check_circle_outline, color: _LogisticsPageState.green),
            SizedBox(width: 8),
            Text('Export successful'),
          ]),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Delivery performance report saved to:'),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black12),
                ),
                child: SelectableText(file.path, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK', style: TextStyle(color: _LogisticsPageState.green, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final allDeliveries = ref.watch(deliveriesListProvider);
    final deliveries = _getFilteredDeliveries(allDeliveries);

    final defaultFallback = const DeliveryItem(
      id: '#DLV-000',
      customer: 'No active customer',
      product: 'No cargo items',
      quantity: '0 kg',
      from: 'Chiredzi Farm',
      to: 'Harare Market',
      status: 'Pending',
      driver: 'Unassigned',
      vehicle: 'N/A',
      eta: 'N/A',
      progress: 0.0,
      hub: 'Central Hub',
      priority: 'Normal',
      riskLevel: 'Low',
      exceptionType: 'None',
      proofStatus: 'None',
      temperature: 'N/A',
      distanceRemaining: '0 km',
      timeline: [],
    );

    if (_selectedDeliveryId == null && allDeliveries.isNotEmpty) {
      _selectedDeliveryId = allDeliveries.first.id;
    }

    final selectedDelivery = allDeliveries.isNotEmpty
        ? allDeliveries.firstWhere(
            (d) => d.id == _selectedDeliveryId,
            orElse: () => allDeliveries.first,
          )
        : defaultFallback;

    final startPoint = _locationCoordinates[selectedDelivery.from] ?? const LatLng(-17.8292, 31.0522);
    final stopPoint = _locationCoordinates[selectedDelivery.to] ?? const LatLng(-17.8638, 31.0285);

    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1100;
    final isTablet = width >= 700 && width < 1100;

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Padding(
              padding: MediaQuery.of(context).size.width < 600 ? const EdgeInsets.all(12) : const EdgeInsets.all(20),
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const ClampingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Header(
                      isCompact: !isDesktop,
                      selectedFilter: _selectedFilter,
                      filters: _filters,
                      onFilterChanged: (v) => setState(() => _selectedFilter = v),
                      onExport: _exportDeliveries,
                      onBookDispatch: _showBookDispatchDialog,
                      onRegisterVehicle: _showRegisterVehicleDialog,
                    ),
                    const SizedBox(height: 10),
                    _PremiumHeroCard(
                      item: selectedDelivery,
                      onViewRoute: () {
                        setState(() => _selectedDeliveryId = selectedDelivery.id);
                        _scrollToTop();
                        if (!isDesktop) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LogisticsMapPage(
                                title: '${selectedDelivery.product} route',
                                startPoint: startPoint,
                                stopPoint: stopPoint,
                                startLabel: selectedDelivery.from,
                                stopLabel: selectedDelivery.to,
                                eta: selectedDelivery.eta,
                                distance: selectedDelivery.distanceRemaining,
                              ),
                            ),
                          );
                        }
                      },
                      onUpdateStatus: () => _showUpdateStatusDialog(selectedDelivery),
                      onOpenMap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LogisticsMapPage(
                              title: '${selectedDelivery.product} route',
                              startPoint: startPoint,
                              stopPoint: stopPoint,
                              startLabel: selectedDelivery.from,
                              stopLabel: selectedDelivery.to,
                              eta: selectedDelivery.eta,
                              distance: selectedDelivery.distanceRemaining,
                            ),
                          ),
                        );
                      },
                      onCallDriver: () => _showDriverCallDialog(selectedDelivery),
                      onColdChainDiag: () => _showColdChainDiagModal(selectedDelivery),
                      onElectronicPod: () => _showElectronicPodModal(selectedDelivery),
                    ),
                    const SizedBox(height: 10),
                    _StatsRow(
                      isTablet: isTablet,
                      isDesktop: isDesktop,
                      onStatSelected: (v) => setState(() => _selectedFilter = v),
                    ),
                    const SizedBox(height: 14),
                    if (isDesktop)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    children: [
                                      _SectionCard(
                                        title: 'Live shipments',
                                        child: Column(
                                          children: [
                                            for (int i = 0; i < deliveries.length; i++) ...[
                                              _DeliveryCard(
                                                item: deliveries[i],
                                                onViewRoute: () {
                                                  setState(() => _selectedDeliveryId = deliveries[i].id);
                                                  _scrollToTop();
                                                },
                                                onUpdateStatus: () => _showUpdateStatusDialog(deliveries[i]),
                                              ),
                                              if (i != deliveries.length - 1) const SizedBox(height: 12),
                                            ],
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      _SectionCard(
                                        title: 'Proof of delivery',
                                        child: _ProofOfDeliveryCard(item: selectedDelivery),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    children: [
                                      _SectionCard(
                                        title: 'Route command center',
                                        child: SizedBox(
                                          height: 420,
                                          child: TrackingMap(
                                            startPoint: startPoint,
                                            stopPoint: stopPoint,
                                            startLabel: selectedDelivery.from,
                                            stopLabel: selectedDelivery.to,
                                            eta: selectedDelivery.eta,
                                            distance: selectedDelivery.distanceRemaining,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      _SectionCard(
                                        title: 'Shipment detail',
                                        child: _ShipmentDetailCard(item: selectedDelivery),
                                      ),
                                      const SizedBox(height: 16),
                                      _SectionCard(
                                        title: 'Vehicle status',
                                        child: const _VehicleStatusCard(),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          else
                            Column(
                              children: [
                                _SectionCard(
                                  title: 'Route command center',
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        height: 260,
                                        child: TrackingMap(
                                          startPoint: startPoint,
                                          stopPoint: stopPoint,
                                          startLabel: selectedDelivery.from,
                                          stopLabel: selectedDelivery.to,
                                          eta: selectedDelivery.eta,
                                          distance: selectedDelivery.distanceRemaining,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      SizedBox(
                                        width: double.infinity,
                                        child: OutlinedButton.icon(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => LogisticsMapPage(
                                                  title: '${selectedDelivery.product} route',
                                                  startPoint: startPoint,
                                                  stopPoint: stopPoint,
                                                  startLabel: selectedDelivery.from,
                                                  stopLabel: selectedDelivery.to,
                                                  eta: selectedDelivery.eta,
                                                  distance: selectedDelivery.distanceRemaining,
                                                ),
                                              ),
                                            );
                                          },
                                          icon: const Icon(Icons.open_in_full),
                                          label: const Text('Open full map'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _SectionCard(
                                  title: 'Shipment detail',
                                  child: _ShipmentDetailCard(item: selectedDelivery),
                                ),
                                const SizedBox(height: 16),
                                _SectionCard(
                                  title: 'Live shipments',
                                  child: deliveries.isEmpty
                                      ? Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(28),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(color: Colors.black12),
                                          ),
                                          child: Column(
                                            children: [
                                              const Icon(Icons.inbox_outlined, size: 42, color: _LogisticsPageState.muted),
                                              const SizedBox(height: 10),
                                              Text(
                                                'No Active Shipments in Real Mode',
                                                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: _LogisticsPageState.dark),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'You are in Real Profile Mode. Book a freight dispatch load or enable Demo Mode to preview sample telemetry.',
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.inter(fontSize: 12, color: _LogisticsPageState.muted),
                                              ),
                                              const SizedBox(height: 16),
                                              Wrap(
                                                spacing: 10,
                                                runSpacing: 8,
                                                children: [
                                                  ElevatedButton.icon(
                                                    onPressed: _showBookDispatchDialog,
                                                    icon: const Icon(Icons.add, size: 16),
                                                    label: const Text('Book Dispatch'),
                                                    style: ElevatedButton.styleFrom(backgroundColor: _LogisticsPageState.green, foregroundColor: Colors.white),
                                                  ),
                                                  OutlinedButton.icon(
                                                    onPressed: () {
                                                      ref.read(appStateProvider.notifier).setDemoMode(true);
                                                    },
                                                    icon: const Icon(Icons.science, size: 16),
                                                    label: const Text('Enable Demo Mode'),
                                                    style: OutlinedButton.styleFrom(foregroundColor: _LogisticsPageState.dark),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        )
                                      : Column(
                                          children: [
                                            for (int i = 0; i < deliveries.length; i++) ...[
                                              _DeliveryCard(
                                                item: deliveries[i],
                                                onViewRoute: () {
                                                  setState(() => _selectedDeliveryId = deliveries[i].id);
                                                  _scrollToTop();
                                                  final d = deliveries[i];
                                                  final dStart = _locationCoordinates[d.from] ?? const LatLng(-17.8292, 31.0522);
                                                  final dStop = _locationCoordinates[d.to] ?? const LatLng(-17.8638, 31.0285);
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => LogisticsMapPage(
                                                        title: '${d.product} route',
                                                        startPoint: dStart,
                                                        stopPoint: dStop,
                                                        startLabel: d.from,
                                                        stopLabel: d.to,
                                                        eta: d.eta,
                                                        distance: d.distanceRemaining,
                                                      ),
                                                    ),
                                                  );
                                                },
                                                onUpdateStatus: () => _showUpdateStatusDialog(deliveries[i]),
                                              ),
                                              if (i != deliveries.length - 1) const SizedBox(height: 12),
                                            ],
                                          ],
                                        ),
                                ),
                                const SizedBox(height: 16),
                                _SectionCard(
                                  title: 'Proof of delivery',
                                  child: _ProofOfDeliveryCard(item: selectedDelivery),
                                ),
                                const SizedBox(height: 16),
                                _SectionCard(
                                  title: 'Vehicle status',
                                  child: const _VehicleStatusCard(),
                                ),
                              ],
                            ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
  }
}

class _Header extends ConsumerWidget {
  final bool isCompact;
  final String selectedFilter;
  final List<String> filters;
  final ValueChanged<String> onFilterChanged;
  final VoidCallback onExport;
  final VoidCallback onBookDispatch;
  final VoidCallback onRegisterVehicle;

  const _Header({
    required this.isCompact,
    required this.selectedFilter,
    required this.filters,
    required this.onFilterChanged,
    required this.onExport,
    required this.onBookDispatch,
    required this.onRegisterVehicle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDemo = ref.watch(isDemoModeProvider);
    final trucks = ref.watch(trucksListProvider);
    final deliveries = ref.watch(deliveriesListProvider);

    final tickerText = isDemo
        ? '12 Active Heavy Vehicles • Cold Storage Sensors: 100% OK • On-Time SLA: 98.4% • 0 Critical Alerts • SADC Corridor Clearing: ONLINE'
        : '${trucks.length} Registered Transport Units • ${deliveries.length} Live Freight Dispatches • Cold Storage: ONLINE • SADC Corridor: ACTIVE';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Live Fleet Telemetry Ticker Pulse
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _LogisticsPageState.dark,
              borderRadius: BorderRadius.circular(10),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF22C55E),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'FLEET TELEMETRY PULSE: ',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF22C55E),
                      letterSpacing: 1.0,
                    ),
                  ),
                  Text(
                    tickerText,
                    style: GoogleFonts.inter(fontSize: 10.5, color: Colors.white70, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          if (isCompact) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Fleet & Transport Command Center',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: _LogisticsPageState.dark,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _LogisticsPageState.green.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'LIVE TELEMETRY',
                        style: GoogleFonts.inter(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w900,
                          color: _LogisticsPageState.green,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Real-time cold chain monitoring, driver radio dispatch, and SADC freight tracking.',
                  style: GoogleFonts.inter(color: _LogisticsPageState.muted, fontSize: 12, height: 1.3),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton.icon(
                      onPressed: onBookDispatch,
                      icon: const Icon(Icons.local_shipping_outlined, size: 16),
                      label: const Text('Book Dispatch'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _LogisticsPageState.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: onRegisterVehicle,
                      icon: const Icon(Icons.directions_car_outlined, size: 16),
                      label: const Text('Add Vehicle'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _LogisticsPageState.dark,
                        side: const BorderSide(color: Colors.black26),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    IconButton(
                      onPressed: onExport,
                      tooltip: 'Export delivery report',
                      icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFFF8FAFC),
                        side: const BorderSide(color: Colors.black12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Fleet & Transport Command Center',
                            style: GoogleFonts.inter(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: _LogisticsPageState.dark,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: _LogisticsPageState.green.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'LIVE TELEMETRY',
                              style: GoogleFonts.inter(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                                color: _LogisticsPageState.green,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Real-time cold chain monitoring, driver radio dispatch, and SADC freight tracking.',
                        style: GoogleFonts.inter(color: _LogisticsPageState.muted, fontSize: 12, height: 1.3),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton.icon(
                      onPressed: onBookDispatch,
                      icon: const Icon(Icons.local_shipping_outlined, size: 16),
                      label: const Text('Book Dispatch'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _LogisticsPageState.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: onRegisterVehicle,
                      icon: const Icon(Icons.directions_car_outlined, size: 16),
                      label: const Text('Add Vehicle'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _LogisticsPageState.dark,
                        side: const BorderSide(color: Colors.black26),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    IconButton(
                      onPressed: onExport,
                      tooltip: 'Export delivery report',
                      icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFFF8FAFC),
                        side: const BorderSide(color: Colors.black12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: filters
                .map(
                  (f) => ChoiceChip(
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    label: Text(f, style: TextStyle(
                      color: selectedFilter == f ? _LogisticsPageState.green : _LogisticsPageState.muted,
                      fontWeight: FontWeight.w600,
                      fontSize: 11.5,
                    )),
                    selected: selectedFilter == f,
                    selectedColor: _LogisticsPageState.green.withValues(alpha: 0.15),
                    onSelected: (_) => onFilterChanged(f),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _PremiumHeroCard extends StatelessWidget {
  final DeliveryItem item;
  final VoidCallback onViewRoute;
  final VoidCallback onUpdateStatus;
  final VoidCallback onOpenMap;
  final VoidCallback onCallDriver;
  final VoidCallback onColdChainDiag;
  final VoidCallback onElectronicPod;

  const _PremiumHeroCard({
    required this.item,
    required this.onViewRoute,
    required this.onUpdateStatus,
    required this.onOpenMap,
    required this.onCallDriver,
    required this.onColdChainDiag,
    required this.onElectronicPod,
  });

  Color _statusColor() {
    switch (item.status) {
      case 'Pending':
        return Colors.orange;
      case 'Picked up':
        return Colors.blue;
      case 'On the way':
        return _LogisticsPageState.green;
      case 'Delivered':
        return Colors.grey;
      default:
        return _LogisticsPageState.muted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF082F49),
            Color(0xFF0F172A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Responsive route + status header
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 340;
              final routeText = Text(
                '${item.from} ➔ ${item.to}',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: isNarrow ? 15 : 18,
                  fontWeight: FontWeight.w800,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              );
              final badge = Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                ),
                child: Text(
                  item.status,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              );

              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Priority Express Freight • ${item.product}',
                      style: GoogleFonts.inter(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 3),
                    routeText,
                    const SizedBox(height: 6),
                    badge,
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Priority Express Freight • ${item.product}',
                          style: GoogleFonts.inter(color: Colors.white70, fontSize: 11.5, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 3),
                        routeText,
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  badge,
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _SummaryChip(label: item.customer, icon: Icons.account_circle_outlined),
              _SummaryChip(label: '${item.driver} (${item.vehicle})', icon: Icons.person_outline),
              _SummaryChip(label: 'Cold Storage: ${item.temperature}', icon: Icons.ac_unit_outlined),
              _SummaryChip(label: item.hub, icon: Icons.location_on_outlined),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: item.progress,
              minHeight: 6,
              backgroundColor: Colors.white.withValues(alpha: 0.16),
              color: _LogisticsPageState.green,
            ),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 580;
              final txt = Text(
                'ETA ${item.eta} • ${item.distanceRemaining} remaining • ${item.priority} Priority',
                style: GoogleFonts.inter(color: Colors.white70, fontSize: 11.5),
              );
              final btns = Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  OutlinedButton.icon(
                    onPressed: onCallDriver,
                    icon: const Icon(Icons.phone_in_talk_outlined, size: 14),
                    label: const Text('Driver Call', style: TextStyle(fontSize: 11)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white30),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: onColdChainDiag,
                    icon: const Icon(Icons.ac_unit_outlined, size: 14),
                    label: const Text('Cold Diag', style: TextStyle(fontSize: 11)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white30),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: onElectronicPod,
                    icon: const Icon(Icons.article_outlined, size: 14),
                    label: const Text('e-PoD', style: TextStyle(fontSize: 11)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white30),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: onUpdateStatus,
                    icon: const Icon(Icons.sync_alt_outlined, size: 14),
                    label: const Text('Update Status', style: TextStyle(fontSize: 11)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _LogisticsPageState.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    ),
                  ),
                ],
              );

              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    txt,
                    const SizedBox(height: 8),
                    SizedBox(width: double.infinity, child: btns),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: txt),
                  const SizedBox(width: 8),
                  btns,
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends ConsumerWidget {
  final bool isTablet;
  final bool isDesktop;
  final ValueChanged<String> onStatSelected;

  const _StatsRow({
    required this.isTablet,
    required this.isDesktop,
    required this.onStatSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDemo = ref.watch(isDemoModeProvider);
    final deliveries = ref.watch(deliveriesListProvider);

    final labels = ['All', 'Picked up', 'On the way', 'Pending'];
    final accentColors = [
      const Color(0xFF10B981), // Emerald
      const Color(0xFF0284C7), // Blue
      const Color(0xFF6366F1), // Indigo
      const Color(0xFFF59E0B), // Amber
    ];

    Widget buildCard(int index, {bool compact = false}) {
      final stat = LogisticsMockData.stats[index];
      final accent = accentColors[index % accentColors.length];
      final pad = compact ? 12.0 : 16.0;

      String displayVal = stat.value;
      if (!isDemo) {
        if (index == 0) {
          displayVal = '${deliveries.length}';
        } else if (index == 1) {
          displayVal = '${deliveries.where((d) => d.status.toLowerCase().contains('picked')).length}';
        } else if (index == 2) {
          displayVal = '${deliveries.where((d) => d.status.toLowerCase().contains('route') || d.status.toLowerCase().contains('transit')).length}';
        } else {
          displayVal = '${deliveries.where((d) => d.status.toLowerCase().contains('delay') || d.status.toLowerCase().contains('pending')).length}';
        }
      }

      return GestureDetector(
        onTap: () => onStatSelected(labels[index]),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.all(pad),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: accent.withValues(alpha: 0.25), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.08),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: compact ? 38 : 46,
                height: compact ? 38 : 46,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(stat.icon, color: accent, size: compact ? 20 : 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          stat.label,
                          style: GoogleFonts.inter(
                            fontSize: compact ? 11 : 12.5,
                            fontWeight: FontWeight.w600,
                            color: _LogisticsPageState.muted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isDemo ? 'DEMO' : 'LIVE',
                            style: GoogleFonts.inter(fontSize: 8.5, fontWeight: FontWeight.w900, color: accent),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      displayVal,
                      style: GoogleFonts.inter(
                        fontSize: compact ? 18 : 22,
                        fontWeight: FontWeight.w900,
                        color: _LogisticsPageState.dark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 900) {
          return Row(
            children: List.generate(LogisticsMockData.stats.length, (i) => Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: buildCard(i),
              ),
            )),
          );
        }
        final compact = constraints.maxWidth < 420;
        return Column(
          children: [
            Row(
              children: [
                Expanded(child: buildCard(0, compact: compact)),
                const SizedBox(width: 10),
                Expanded(child: buildCard(1, compact: compact)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: buildCard(2, compact: compact)),
                const SizedBox(width: 10),
                Expanded(child: buildCard(3, compact: compact)),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _DeliveryCard extends StatelessWidget {
  final DeliveryItem item;
  final VoidCallback onViewRoute;
  final VoidCallback onUpdateStatus;

  const _DeliveryCard({
    required this.item,
    required this.onViewRoute,
    required this.onUpdateStatus,
  });

  Color _statusColor() {
    switch (item.status) {
      case 'Pending':
        return Colors.amber.shade700;
      case 'Picked up':
        return Colors.blue.shade600;
      case 'On the way':
        return _LogisticsPageState.green;
      case 'Delivered':
        return Colors.grey.shade600;
      default:
        return _LogisticsPageState.muted;
    }
  }

  String _productEmoji(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('tomato')) return '🍅';
    if (lower.contains('maize') || lower.contains('corn')) return '🌽';
    if (lower.contains('egg')) return '🥚';
    if (lower.contains('avocado')) return '🥑';
    if (lower.contains('citrus') || lower.contains('orange')) return '🍊';
    if (lower.contains('beef') || lower.contains('cattle')) return '🥩';
    if (lower.contains('milk') || lower.contains('dairy')) return '🥛';
    return '📦';
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor();
    final emoji = _productEmoji(item.product);
    final percentInt = (item.progress * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Emoji + Title + Qty & Status Badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(emoji, style: const TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${item.product} • ${item.quantity}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: _LogisticsPageState.dark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          '${item.from} ',
                          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: _LogisticsPageState.muted),
                        ),
                        const Icon(Icons.arrow_right_alt, size: 14, color: _LogisticsPageState.green),
                        Text(
                          ' ${item.to}',
                          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: _LogisticsPageState.dark),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      item.status,
                      style: GoogleFonts.inter(color: statusColor, fontSize: 11, fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '❄️ ${item.temperature}',
                      style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.blue.shade700),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Custom Progress Bar with Percent indicator
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: item.progress,
                    minHeight: 7,
                    backgroundColor: const Color(0xFFE2E8F0),
                    color: statusColor,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '$percentInt%',
                style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w800, color: statusColor),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Info Chips Bar
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip(icon: Icons.person_outline, label: item.driver),
              _InfoChip(icon: Icons.local_shipping_outlined, label: item.vehicle),
              _InfoChip(icon: Icons.timer_outlined, label: 'ETA ${item.eta}'),
              _InfoChip(icon: Icons.qr_code_outlined, label: item.id),
            ],
          ),
          const SizedBox(height: 14),

          // Action Buttons: View Route & Update Status
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 360;
              final btnRoute = OutlinedButton.icon(
                onPressed: onViewRoute,
                icon: const Icon(Icons.map_outlined, size: 15),
                label: const Text('View Route'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _LogisticsPageState.green,
                  side: const BorderSide(color: _LogisticsPageState.green, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
              final btnUpdate = ElevatedButton.icon(
                onPressed: onUpdateStatus,
                icon: const Icon(Icons.sync_alt_outlined, size: 15),
                label: const Text('Update Status'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _LogisticsPageState.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              );

              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    btnRoute,
                    const SizedBox(height: 8),
                    btnUpdate,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: btnRoute),
                  const SizedBox(width: 10),
                  Expanded(child: btnUpdate),
                ],
              );
            },
          ),
          const SizedBox(height: 14),

          // Stepper Timeline
          _ShipmentTimeline(currentStatus: item.status),
        ],
      ),
    );
  }
}

class _ShipmentTimeline extends StatelessWidget {
  final String currentStatus;
  const _ShipmentTimeline({required this.currentStatus});

  static const _steps = ['Booked', 'Picked Up', 'On The Way', 'Delivered'];

  int _currentStep() {
    switch (currentStatus) {
      case 'Pending':
        return 0;
      case 'Picked up':
        return 1;
      case 'On the way':
        return 2;
      case 'Delivered':
        return 3;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final step = _currentStep();
    return Row(
      children: List.generate(_steps.length, (i) {
        final isActive = i <= step;
        final isLast = i == _steps.length - 1;
        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive ? _LogisticsPageState.green : Colors.grey.shade200,
                        border: Border.all(color: isActive ? _LogisticsPageState.green : Colors.grey.shade300, width: 2),
                      ),
                      child: isActive ? const Icon(Icons.check, size: 13, color: Colors.white) : null,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _steps[i],
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                        color: isActive ? _LogisticsPageState.green : _LogisticsPageState.muted,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.only(bottom: 18),
                    color: i < step ? _LogisticsPageState.green : Colors.grey.shade200,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}

void _showRegisterVehicleDialog(BuildContext context, WidgetRef ref) {
  final modelController = TextEditingController();
  final colorController = TextEditingController();
  final plateController = TextEditingController();
  final regController = TextEditingController();
  final rateController = TextEditingController();
  final etaController = TextEditingController();
  final user = ref.read(authStateProvider).user;

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Register New Vehicle'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: modelController, decoration: const InputDecoration(labelText: 'Vehicle Model (e.g. Scania R500)')),
              TextField(controller: colorController, decoration: const InputDecoration(labelText: 'Color')),
              TextField(controller: plateController, decoration: const InputDecoration(labelText: 'Plate Number')),
              TextField(controller: regController, decoration: const InputDecoration(labelText: 'Registration Number')),
              TextField(controller: rateController, decoration: const InputDecoration(labelText: 'Pricing (US\$ per km)'), keyboardType: TextInputType.number),
              TextField(controller: etaController, decoration: const InputDecoration(labelText: 'Estimated Prep/ETA (e.g. 30m)')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final model = modelController.text.trim();
              final color = colorController.text.trim();
              final plate = plateController.text.trim();
              final reg = regController.text.trim();
              final rate = double.tryParse(rateController.text.trim()) ?? 0.15;
              final eta = etaController.text.trim().isEmpty ? '30m' : etaController.text.trim();

              if (model.isNotEmpty && plate.isNotEmpty && reg.isNotEmpty) {
                ref.read(trucksListProvider.notifier).addTruck(
                  TruckItem(
                    id: 'truck-${DateTime.now().millisecondsSinceEpoch}',
                    driver: user?.fullName ?? 'Operator',
                    vehicle: '$model ($color)',
                    plateNumber: plate,
                    regNumber: reg,
                    color: color,
                    model: model,
                    from: 'Harare Yard',
                    eta: eta,
                    costPerKm: rate,
                    rating: 5.0,
                    status: 'Ready for dispatch',
                  ),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Register'),
          ),
        ],
      );
    },
  );
}

class _VehicleStatusCard extends ConsumerWidget {
  const _VehicleStatusCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trucks = ref.watch(trucksListProvider);
    final role = ref.watch(appStateProvider).role;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (role == UserRole.transporter || role == UserRole.admin) ...[
          ElevatedButton.icon(
            onPressed: () => _showRegisterVehicleDialog(context, ref),
            icon: const Icon(Icons.add),
            label: const Text('Register Vehicle'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _LogisticsPageState.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 12),
        ],
        ...trucks.map((t) {
          double progress = 1.0;
          if (t.status.contains('route') || t.status.contains('transit')) {
            progress = 0.65;
          } else if (t.status.contains('Load')) {
            progress = 0.35;
          }
          return GestureDetector(
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _LogisticsPageState.green.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.local_shipping_outlined, color: _LogisticsPageState.green),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(t.model, style: const TextStyle(fontWeight: FontWeight.w700)),
                            Text('\$${t.costPerKm.toStringAsFixed(2)}/km', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _LogisticsPageState.green)),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text('Plate: ${t.plateNumber} • ${t.status}', style: const TextStyle(color: _LogisticsPageState.muted, fontSize: 11)),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: progress,
                          minHeight: 7,
                          backgroundColor: Colors.grey.shade200,
                          color: _LogisticsPageState.green,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _ShipmentDetailCard extends StatelessWidget {
  final DeliveryItem item;

  const _ShipmentDetailCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final details = [
      _DetailRow(label: 'Assigned hub', value: item.hub),
      _DetailRow(label: 'Priority', value: item.priority),
      _DetailRow(label: 'Risk', value: item.riskLevel),
      _DetailRow(label: 'Temp', value: item.temperature),
      _DetailRow(label: 'ETA', value: item.eta),
      _DetailRow(label: 'Remaining', value: item.distanceRemaining),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text('${item.product} for ${item.customer}', style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
            _SummaryChip(label: item.priority, icon: Icons.flag_outlined),
          ],
        ),
        const SizedBox(height: 10),
        ...details.map((detail) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: Text(detail.label, style: const TextStyle(color: _LogisticsPageState.muted))),
                  Expanded(flex: 3, child: Text(detail.value, style: const TextStyle(fontWeight: FontWeight.w600))),
                ],
              ),
            )),
        const SizedBox(height: 8),
        _ExceptionBanner(label: item.exceptionType),
      ],
    );
  }
}

class _ProofOfDeliveryCard extends StatelessWidget {
  final DeliveryItem item;

  const _ProofOfDeliveryCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.fact_check_outlined, color: _LogisticsPageState.green),
            const SizedBox(width: 8),
            Expanded(child: Text(item.proofStatus, style: const TextStyle(fontWeight: FontWeight.w700))),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: item.timeline
              .map((entry) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(entry, style: const TextStyle(fontSize: 12)),
                  ))
              .toList(),
        ),
      ],
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _SummaryChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: Colors.white),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _ExceptionBanner extends StatelessWidget {
  final String label;

  const _ExceptionBanner({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_outlined, color: Colors.amber),
          const SizedBox(width: 8),
          Expanded(child: Text('Exception: $label', style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}

class _DetailRow {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: _LogisticsPageState.dark),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}