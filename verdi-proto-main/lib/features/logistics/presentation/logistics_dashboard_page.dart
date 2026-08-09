import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

import '../../../state/location_state.dart';
import '../../../state/platform_data_state.dart';

class LogisticsDashboardPage extends ConsumerStatefulWidget {
  const LogisticsDashboardPage({super.key});

  @override
  ConsumerState<LogisticsDashboardPage> createState() => _LogisticsDashboardPageState();
}

class _LogisticsDashboardPageState extends ConsumerState<LogisticsDashboardPage> {
  static const green = Color(0xFF10B981);
  static const dark = Color(0xFF0F172A);
  static const muted = Color(0xFF64748B);
  static const orange = Color(0xFFF97316);
  static const blue = Color(0xFF3B82F6);
  static const purple = Color(0xFF8B5CF6);
  static const teal = Color(0xFF0D9488);
  static const bgLight = Color(0xFFF8FAFC);

  final MapController _mapController = MapController();
  final ImagePicker _picker = ImagePicker();

  LatLng? _selectedHub;
  String _selectedHubName = 'Select a hub';
  String _etaText = '--';
  File? _proofImage;

  final List<_Hub> hubs = [
    _Hub('Harare Hub', const LatLng(-17.82772, 31.05337), green),
    _Hub('Bulawayo Hub', const LatLng(-20.15, 28.58333), orange),
    _Hub('Mutare Hub', const LatLng(-18.9707, 32.67086), blue),
    _Hub('Gweru Hub', const LatLng(-19.45, 29.81667), purple),
    _Hub('Masvingo Hub', const LatLng(-20.06373, 30.82766), teal),
    _Hub('Chitungwiza Hub', const LatLng(-18.01274, 31.07555), Colors.deepOrange),
  ];

  String _formatEta(double distanceMeters, double speedKmh) {
    final km = distanceMeters / 1000.0;
    final hours = km / speedKmh;
    final minutes = (hours * 60).round();
    if (minutes < 60) return '$minutes min';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return '${h}h ${m}m';
  }

  void _selectHub(_Hub hub, LatLng? userLocation) {
    setState(() {
      _selectedHub = hub.point;
      _selectedHubName = hub.name;
      if (userLocation != null) {
        final d = Geolocator.distanceBetween(
          userLocation.latitude,
          userLocation.longitude,
          hub.point.latitude,
          hub.point.longitude,
        );
        _etaText = _formatEta(d, 45);
      }
    });
    _mapController.move(hub.point, 10);
  }

  void _autoSelectNearestHub(LatLng userLocation) {
    _Hub? nearest;
    double best = double.infinity;

    for (final hub in hubs) {
      final d = Geolocator.distanceBetween(
        userLocation.latitude,
        userLocation.longitude,
        hub.point.latitude,
        hub.point.longitude,
      );
      if (d < best) {
        best = d;
        nearest = hub;
      }
    }

    if (nearest != null) {
      setState(() {
        _selectedHub = nearest!.point;
        _selectedHubName = nearest.name;
        _etaText = _formatEta(best, 45);
      });
    }
  }

  Future<void> _pickProofImage() async {
    final image = await _picker.pickImage(source: ImageSource.camera, imageQuality: 75);
    if (image == null) return;
    setState(() => _proofImage = File(image.path));
  }

  void _dispatchNow() {
    final trucks = ref.read(trucksListProvider);
    String selectedTruck = trucks.isNotEmpty ? trucks.first.driver : 'Tafadzwa M.';
    final cargoController = TextEditingController(text: 'Maize & Fresh Produce');

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: green.withValues(alpha: 0.12), shape: BoxShape.circle),
                    child: const Icon(Icons.send_outlined, color: green, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Text('Dispatch Load', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18, color: dark)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Destination Hub: $_selectedHubName', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: green)),
                  Text('Est. Travel Time: $_etaText', style: GoogleFonts.inter(color: muted, fontSize: 13)),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedTruck,
                    decoration: const InputDecoration(labelText: 'Assigned Driver & Vehicle'),
                    items: trucks
                        .map((t) => DropdownMenuItem(
                              value: t.driver,
                              child: Text('${t.driver} (${t.vehicle})'),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setDialogState(() => selectedTruck = v);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: cargoController,
                    decoration: const InputDecoration(labelText: 'Cargo Description', hintText: 'e.g. 500 kg Tomatoes'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    final trackingCode = 'TRK-${1000 + (DateTime.now().millisecondsSinceEpoch % 9000)}';
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Load dispatched to $_selectedHubName! Tracking Code: $trackingCode'),
                        duration: const Duration(seconds: 4),
                      ),
                    );
                  },
                  icon: const Icon(Icons.local_shipping_outlined, size: 18),
                  label: const Text('Confirm Dispatch'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final locationAsync = ref.watch(locationStreamProvider);
    final position = locationAsync.value;
    final userLocation = position == null ? null : LatLng(position.latitude, position.longitude);

    if (userLocation != null && _selectedHub == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _autoSelectNearestHub(userLocation);
      });
    } else if (userLocation != null && _selectedHub != null) {
      final d = Geolocator.distanceBetween(
        userLocation.latitude,
        userLocation.longitude,
        _selectedHub!.latitude,
        _selectedHub!.longitude,
      );
      _etaText = _formatEta(d, 45);
    }

    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: bgLight,
      endDrawer: _ActionDrawer(
        selectedHubName: _selectedHubName,
        etaText: _etaText,
        proofImage: _proofImage,
        onPickProofImage: _pickProofImage,
        onDispatchNow: _dispatchNow,
        onRefreshLocation: () async {
          ref.invalidate(locationStreamProvider);
        },
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1280),
            child: SingleChildScrollView(
              padding: width < 600 ? const EdgeInsets.all(12) : const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Header Banner
                  _LogisticsHeroBanner(
                    selectedHubName: _selectedHubName,
                    etaText: _etaText,
                    onDispatch: _dispatchNow,
                    onRefreshLocation: () async {
                      ref.invalidate(locationStreamProvider);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Refreshing GPS satellite position...')),
                      );
                    },
                    onCaptureProof: _pickProofImage,
                  ),
                  const SizedBox(height: 18),

                  // Hub Quick Switcher Ribbon
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: hubs.map((hub) {
                        final isSelected = _selectedHubName == hub.name;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: InkWell(
                            onTap: () => _selectHub(hub, userLocation),
                            borderRadius: BorderRadius.circular(12),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? hub.color : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: isSelected ? hub.color : Colors.black.withValues(alpha: 0.08)),
                                boxShadow: isSelected
                                    ? [BoxShadow(color: hub.color.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))]
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.place, size: 16, color: isSelected ? Colors.white : hub.color),
                                  const SizedBox(width: 6),
                                  Text(
                                    hub.name,
                                    style: GoogleFonts.inter(
                                      fontSize: 12.5,
                                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                      color: isSelected ? Colors.white : dark,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Layout: Map & Status Panel
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final wide = constraints.maxWidth > 1100;

                      final map = _MapCard(
                        mapController: _mapController,
                        markers: _markers(userLocation),
                        polylines: _polylines(userLocation),
                        onOpenDrawer: () => Scaffold.of(context).openEndDrawer(),
                        loadingLocation: locationAsync.isLoading,
                        selectedHubName: _selectedHubName,
                        etaText: _etaText,
                      );

                      final panel = _StatusPanel(
                        selectedHubName: _selectedHubName,
                        etaText: _etaText,
                        proofImage: _proofImage,
                        hasLocation: userLocation != null,
                        onRefreshLocation: () async {
                          ref.invalidate(locationStreamProvider);
                        },
                        onPickProofImage: _pickProofImage,
                        onDispatchNow: _dispatchNow,
                        onOpenDrawer: () => Scaffold.of(context).openEndDrawer(),
                      );

                      return wide
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(flex: 2, child: map),
                                const SizedBox(width: 18),
                                Expanded(child: panel),
                              ],
                            )
                          : Column(
                              children: [
                                map,
                                const SizedBox(height: 18),
                                panel,
                              ],
                            );
                    },
                  ),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Marker> _markers(LatLng? userLocation) {
    final list = <Marker>[];

    for (final hub in hubs) {
      list.add(
        Marker(
          point: hub.point,
          width: 130,
          height: 60,
          child: GestureDetector(
            onTap: () => _selectHub(hub, userLocation),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: hub.color,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(color: hub.color.withValues(alpha: 0.35), blurRadius: 8, offset: const Offset(0, 3)),
                    ],
                  ),
                  child: Text(
                    hub.name,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Icon(Icons.location_pin, color: hub.color, size: 30),
              ],
            ),
          ),
        ),
      );
    }

    if (userLocation != null) {
      list.add(
        Marker(
          point: userLocation,
          width: 44,
          height: 44,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue.shade600,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(color: Colors.blue.withValues(alpha: 0.4), blurRadius: 10, offset: const Offset(0, 3)),
              ],
            ),
            child: const Icon(Icons.my_location, color: Colors.white, size: 22),
          ),
        ),
      );
    }

    return list;
  }

  List<Polyline> _polylines(LatLng? userLocation) {
    if (userLocation == null || _selectedHub == null) return [];
    return [
      Polyline(
        points: [userLocation, _selectedHub!],
        strokeWidth: 4.5,
        color: green,
      ),
    ];
  }
}

class _LogisticsHeroBanner extends StatelessWidget {
  final String selectedHubName;
  final String etaText;
  final VoidCallback onDispatch;
  final VoidCallback onRefreshLocation;
  final VoidCallback onCaptureProof;

  const _LogisticsHeroBanner({
    required this.selectedHubName,
    required this.etaText,
    required this.onDispatch,
    required this.onRefreshLocation,
    required this.onCaptureProof,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            'Fleet & Logistics Control',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 6),
                              Text('6 HUBS MESH LINKED', style: GoogleFonts.inter(color: const Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.w800)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Real-time GPS routing, ETA calculation, proof of delivery, and cargo dispatch across national corridors.',
                      style: GoogleFonts.inter(fontSize: 13.5, color: const Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onDispatch,
                  icon: const Icon(Icons.send_outlined, size: 18),
                  label: const Text('Dispatch Load'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onRefreshLocation,
                  icon: const Icon(Icons.my_location, size: 18, color: Colors.white),
                  label: Text('Sync GPS', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onCaptureProof,
                  icon: const Icon(Icons.camera_alt_outlined, size: 18, color: Colors.white),
                  label: Text('Proof Photo', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MapCard extends StatelessWidget {
  final MapController mapController;
  final List<Marker> markers;
  final List<Polyline> polylines;
  final VoidCallback onOpenDrawer;
  final bool loadingLocation;
  final String selectedHubName;
  final String etaText;

  const _MapCard({
    required this.mapController,
    required this.markers,
    required this.polylines,
    required this.onOpenDrawer,
    required this.loadingLocation,
    required this.selectedHubName,
    required this.etaText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 540,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            FlutterMap(
              mapController: mapController,
              options: const MapOptions(
                initialCenter: LatLng(-19.0, 30.5),
                initialZoom: 6.5,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.verdi.app',
                ),
                PolylineLayer(polylines: polylines),
                MarkerLayer(markers: markers),
              ],
            ),
            Positioned(
              top: 14,
              left: 14,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.place, color: Color(0xFF10B981), size: 18),
                        const SizedBox(width: 6),
                        Text(selectedHubName, style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.timer_outlined, color: Colors.amber, size: 16),
                        const SizedBox(width: 6),
                        Text('ETA: $etaText', style: GoogleFonts.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 14,
              right: 14,
              child: FloatingActionButton.small(
                onPressed: onOpenDrawer,
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                child: const Icon(Icons.route_outlined),
              ),
            ),
            if (loadingLocation)
              const Positioned.fill(
                child: ColoredBox(
                  color: Color(0x33FFFFFF),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatusPanel extends StatelessWidget {
  final String selectedHubName;
  final String etaText;
  final bool hasLocation;
  final File? proofImage;
  final Future<void> Function() onRefreshLocation;
  final Future<void> Function() onPickProofImage;
  final VoidCallback onDispatchNow;
  final VoidCallback onOpenDrawer;

  const _StatusPanel({
    required this.selectedHubName,
    required this.etaText,
    required this.hasLocation,
    required this.proofImage,
    required this.onRefreshLocation,
    required this.onPickProofImage,
    required this.onDispatchNow,
    required this.onOpenDrawer,
  });

  @override
  Widget build(BuildContext context) {
    final cards = [
      ('Active routes', '12', Icons.alt_route_outlined, const Color(0xFF10B981)),
      ('On-time deliveries', '91%', Icons.timer_outlined, const Color(0xFF3B82F6)),
      ('Pending pickups', '6', Icons.inventory_2_outlined, const Color(0xFFF97316)),
      ('In transit', '18', Icons.local_shipping_outlined, const Color(0xFF8B5CF6)),
    ];

    return Column(
      children: [
        _SectionCard(
          title: 'Selected Hub & Navigation',
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: const Color(0xFF10B981).withValues(alpha: 0.12), shape: BoxShape.circle),
              child: const Icon(Icons.place_outlined, color: Color(0xFF10B981)),
            ),
            title: Text(selectedHubName, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15)),
            subtitle: Text(hasLocation ? 'ETA: $etaText • GPS Route Active' : 'Location stream activating...', style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 13)),
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: cards
              .map(
                (item) => _MetricCard(
                  title: item.$1,
                  value: item.$2,
                  icon: item.$3,
                  color: item.$4,
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: 'Proof of Delivery Photo',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (proofImage != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.file(
                    proofImage!,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                )
              else
                Container(
                  height: 150,
                  width: double.infinity,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.camera_alt_outlined, color: Color(0xFF64748B), size: 36),
                      const SizedBox(height: 6),
                      Text('No proof photo captured yet', style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 13)),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onPickProofImage,
                      icon: const Icon(Icons.camera_alt_outlined, size: 18),
                      label: const Text('Capture'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onDispatchNow,
                      icon: const Icon(Icons.send_outlined, size: 18),
                      label: const Text('Dispatch'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: 'Dispatch Action Queue',
          child: Column(
            children: const [
              _ActionTile('Dispatch harvest load', 'Ready for pickup at farm gate'),
              _ActionTile('Confirm buyer delivery', 'Wholesale order awaiting proof'),
              _ActionTile('Check vehicle fuel status', 'Truck below threshold'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onRefreshLocation,
                icon: const Icon(Icons.my_location, size: 18),
                label: const Text('Refresh GPS'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onOpenDrawer,
                icon: const Icon(Icons.route_outlined, size: 18),
                label: const Text('More Actions'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF10B981),
                  side: const BorderSide(color: Color(0xFF10B981)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionDrawer extends StatelessWidget {
  final String selectedHubName;
  final String etaText;
  final File? proofImage;
  final Future<void> Function() onPickProofImage;
  final VoidCallback onDispatchNow;
  final Future<void> Function() onRefreshLocation;

  const _ActionDrawer({
    required this.selectedHubName,
    required this.etaText,
    required this.proofImage,
    required this.onPickProofImage,
    required this.onDispatchNow,
    required this.onRefreshLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Logistics Actions',
                      style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text('Selected hub: $selectedHubName', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
              Text('ETA: $etaText', style: GoogleFonts.inter(color: const Color(0xFF64748B))),
              const SizedBox(height: 14),
              if (proofImage != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(proofImage!, height: 150, width: double.infinity, fit: BoxFit.cover),
                )
              else
                Container(
                  height: 140,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('Proof photo not captured', style: GoogleFonts.inter(color: Colors.grey)),
                ),
              const SizedBox(height: 14),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.camera_alt_outlined, color: Color(0xFF3B82F6)),
                title: Text('Capture proof photo', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                onTap: () async => onPickProofImage(),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.send_outlined, color: Color(0xFF10B981)),
                title: Text('Dispatch now', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                onTap: onDispatchNow,
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.my_location, color: Color(0xFF8B5CF6)),
                title: Text('Refresh GPS location', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                onTap: () async => onRefreshLocation(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(fontSize: 11.5, color: const Color(0xFF64748B))),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
                ),
              ],
            ),
          ),
        ],
      ),
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final String title;
  final String subtitle;

  const _ActionTile(this.title, this.subtitle);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.check_circle_outline, color: Color(0xFF10B981)),
      title: Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13.5)),
      subtitle: Text(subtitle, style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 12)),
    );
  }
}

class _Hub {
  final String name;
  final LatLng point;
  final Color color;

  _Hub(this.name, this.point, this.color);
}