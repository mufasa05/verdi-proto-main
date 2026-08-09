import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import '../models/trade_models.dart';
import '../providers/trade_providers.dart';
import '../widgets/trade_widgets.dart';

class TradeLogisticsPage extends ConsumerStatefulWidget {
  const TradeLogisticsPage({super.key});

  @override
  ConsumerState<TradeLogisticsPage> createState() => _TradeLogisticsPageState();
}

class _TradeLogisticsPageState extends ConsumerState<TradeLogisticsPage> {
  String _filter = 'All';
  String? _selectedTripId;

  final _filters = ['All', 'En Route', 'Pending', 'Delivered', 'Delayed'];
  final _mapController = MapController();

  List<LogisticsTrip> _filtered(List<LogisticsTrip> all) {
    if (_filter == 'All') return all;
    return all.where((t) => t.status == _filter).toList();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allTrips = ref.watch(logisticsTripProvider);
    final filtered = _filtered(allTrips);

    final enRouteCount = allTrips.where((t) => t.status == 'En Route').length;
    final deliveredCount = allTrips.where((t) => t.status == 'Delivered').length;
    final pendingCount = allTrips.where((t) => t.status == 'Pending').length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TradePageHeader(
            title: 'Logistics Layer',
            subtitle: 'Vehicle trips, delivery tracking, and proof of delivery.',
            actions: [
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add, size: 18),
                label: const Text('New Trip'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: TradeColors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          // KPI row
          LayoutBuilder(builder: (ctx, c) {
            final cols = c.maxWidth >= 600 ? 4 : 2;
            final ratio = c.maxWidth >= 600 ? 1.8 : 1.35;
            return GridView.count(
              crossAxisCount: cols,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: ratio,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                TradeStatTile(label: 'Total Trips', value: '${allTrips.length}', icon: Icons.local_shipping_outlined),
                TradeStatTile(label: 'En Route', value: '$enRouteCount', icon: Icons.route_outlined, iconColor: TradeColors.blue),
                TradeStatTile(label: 'Delivered', value: '$deliveredCount', icon: Icons.check_circle_outline, iconColor: TradeColors.green, valueColor: TradeColors.green),
                TradeStatTile(label: 'Pending', value: '$pendingCount', icon: Icons.pending_outlined, iconColor: TradeColors.orange),
              ],
            );
          }),
          const SizedBox(height: 16),
          // Map
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              height: 280,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: TradeColors.border),
              ),
              child: FlutterMap(
                mapController: _mapController,
                options: const MapOptions(
                  initialCenter: LatLng(-19.0, 29.8),
                  initialZoom: 6.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.verdi.app',
                  ),
                  MarkerLayer(
                    markers: allTrips
                        .map(
                          (trip) => Marker(
                            point: LatLng(trip.originLat, trip.originLng),
                            width: 36,
                            height: 36,
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedTripId = trip.id),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: switch (trip.status) {
                                    'En Route' => TradeColors.blue,
                                    'Delivered' => TradeColors.green,
                                    'Delayed' => TradeColors.red,
                                    _ => TradeColors.orange,
                                  },
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                                ),
                                child: const Icon(Icons.local_shipping, color: Colors.white, size: 16),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          TradeFilterRow(filters: _filters, selected: _filter, onSelect: (f) => setState(() => _filter = f)),
          const SizedBox(height: 16),
          // Trip list
          if (filtered.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('No trips found.', style: TextStyle(color: TradeColors.muted))))
          else
            for (final trip in filtered) ...[
              _TripCard(
                trip: trip,
                isSelected: trip.id == _selectedTripId,
                onTap: () => setState(() => _selectedTripId = trip.id),
                onConfirmDelivery: () => ref.read(logisticsTripProvider.notifier).confirmDelivery(trip.id),
                onUpdateStatus: (s) => ref.read(logisticsTripProvider.notifier).updateStatus(trip.id, s),
              ),
              const SizedBox(height: 12),
            ],
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
  final LogisticsTrip trip;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onConfirmDelivery;
  final ValueChanged<String> onUpdateStatus;

  const _TripCard({
    required this.trip,
    required this.isSelected,
    required this.onTap,
    required this.onConfirmDelivery,
    required this.onUpdateStatus,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = TradeColors.statusColor(trip.status);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? TradeColors.green.withOpacity(0.04) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: isSelected ? TradeColors.green : TradeColors.border, width: isSelected ? 1.5 : 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.local_shipping_outlined, color: statusColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${trip.id} — ${trip.vehiclePlate}',
                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: TradeColors.dark),
                      ),
                      Text(
                        trip.driverName,
                        style: const TextStyle(fontSize: 12, color: TradeColors.muted),
                      ),
                    ],
                  ),
                ),
                TradeBadge(label: trip.status),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.warehouse_outlined, size: 13, color: TradeColors.muted),
                const SizedBox(width: 4),
                Expanded(child: Text(trip.originWarehouse, style: const TextStyle(fontSize: 11, color: TradeColors.muted))),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.place_outlined, size: 13, color: TradeColors.green),
                const SizedBox(width: 4),
                Expanded(child: Text(trip.destinationName, style: const TextStyle(fontSize: 11, color: TradeColors.muted))),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _TripMeta(icon: Icons.scale_outlined, value: '${trip.loadKg.round()}kg'),
                const SizedBox(width: 14),
                _TripMeta(icon: Icons.schedule_outlined, value: 'ETA ${trip.eta}'),
                const Spacer(),
                if (trip.hasProofOfDelivery)
                  const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified, color: TradeColors.green, size: 14),
                      SizedBox(width: 4),
                      Text('POD', style: TextStyle(fontSize: 11, color: TradeColors.green, fontWeight: FontWeight.w700)),
                    ],
                  ),
              ],
            ),
            if (isSelected && (trip.status == 'En Route' || trip.status == 'Pending')) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  if (trip.status == 'Pending')
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => onUpdateStatus('En Route'),
                        icon: const Icon(Icons.play_arrow, size: 18),
                        label: const Text('Start Trip'),
                        style: ElevatedButton.styleFrom(backgroundColor: TradeColors.blue, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      ),
                    ),
                  if (trip.status == 'En Route') ...[
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onConfirmDelivery,
                        icon: const Icon(Icons.check_circle_outline, size: 18),
                        label: const Text('Confirm Delivery'),
                        style: ElevatedButton.styleFrom(backgroundColor: TradeColors.green, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      ),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.upload_outlined, size: 18),
                      label: const Text('Upload POD'),
                      style: OutlinedButton.styleFrom(foregroundColor: TradeColors.green, side: const BorderSide(color: TradeColors.green), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TripMeta extends StatelessWidget {
  final IconData icon;
  final String value;

  const _TripMeta({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: TradeColors.muted),
        const SizedBox(width: 4),
        Text(value, style: const TextStyle(fontSize: 11, color: TradeColors.muted)),
      ],
    );
  }
}
