import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LogisticsDashboardPage extends StatefulWidget {
  const LogisticsDashboardPage({super.key});

  @override
  State<LogisticsDashboardPage> createState() => _LogisticsDashboardPageState();
}

class _LogisticsDashboardPageState extends State<LogisticsDashboardPage> {
  final TextEditingController _searchController = TextEditingController();

  final List<_Shipment> _shipments = const [
    _Shipment(
      id: 'TRK-1042',
      title: 'Tomatoes Delivery',
      customer: 'Talent Farms',
      origin: 'Chiredzi',
      destination: 'Harare',
      driver: 'Tafara Moyo',
      truck: 'Truck 12',
      status: ShipmentStatus.inTransit,
      eta: '2h 15m',
      progress: 0.62,
      lastUpdate: '15 min ago',
      temperature: '18°C',
      distanceLeft: '84 km',
      events: [
        _ShipmentEvent('Order confirmed', '8:05 AM', true),
        _ShipmentEvent('Picked up from farm', '9:20 AM', true),
        _ShipmentEvent('On the road', '10:05 AM', true),
        _ShipmentEvent('Arrived at checkpoint', 'Pending', false),
      ],
    ),
    _Shipment(
      id: 'TRK-1058',
      title: 'Maize Bulk Transfer',
      customer: 'Green Valley Co-op',
      origin: 'Masvingo',
      destination: 'Bulawayo',
      driver: 'Nyasha Dube',
      truck: 'Truck 08',
      status: ShipmentStatus.pickedUp,
      eta: '4h 40m',
      progress: 0.34,
      lastUpdate: '28 min ago',
      temperature: '21°C',
      distanceLeft: '210 km',
      events: [
        _ShipmentEvent('Order confirmed', '7:30 AM', true),
        _ShipmentEvent('Picked up from warehouse', '9:15 AM', true),
        _ShipmentEvent('Departed depot', '10:10 AM', false),
        _ShipmentEvent('In transit', 'Pending', false),
      ],
    ),
    _Shipment(
      id: 'TRK-1091',
      title: 'Onion Order',
      customer: 'Sunrise Produce',
      origin: 'Harare',
      destination: 'Mutare',
      driver: 'Chipo Ndlovu',
      truck: 'Truck 05',
      status: ShipmentStatus.delivered,
      eta: 'Completed',
      progress: 1.0,
      lastUpdate: '1h ago',
      temperature: '17°C',
      distanceLeft: '0 km',
      events: [
        _ShipmentEvent('Order confirmed', '6:45 AM', true),
        _ShipmentEvent('Picked up from seller', '7:25 AM', true),
        _ShipmentEvent('Delivered to buyer', '11:35 AM', true),
        _ShipmentEvent('Closed', '11:50 AM', true),
      ],
    ),
  ];

  late final Timer _ticker;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 1100;
    final filtered = _filteredShipments();

    if (filtered.isEmpty) {
      _selectedIndex = 0;
    } else if (_selectedIndex >= filtered.length) {
      _selectedIndex = filtered.length - 1;
    }

    final selected = filtered.isEmpty ? null : filtered[_selectedIndex];

    return Scaffold(
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isWide) _LogisticsRail(shipments: filtered, onSelect: (i) => setState(() => _selectedIndex = i)),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Logistics Tracking',
                            style: GoogleFonts.poppins(
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Track trucks, deliveries, ETA, and shipment progress in real time.',
                            style: GoogleFonts.poppins(color: Colors.grey.shade700),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _searchController,
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              hintText: 'Search shipment, customer, driver, or route',
                              prefixIcon: const Icon(Icons.search),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Wrap(
                        spacing: 14,
                        runSpacing: 14,
                        children: [
                          _StatCard(
                            title: 'Active Trucks',
                            value: '${_shipments.where((s) => s.status != ShipmentStatus.delivered).length}',
                            icon: Icons.local_shipping_outlined,
                          ),
                          _StatCard(
                            title: 'On Time',
                            value: '${_onTimeCount()}%',
                            icon: Icons.schedule_outlined,
                          ),
                          _StatCard(
                            title: 'In Transit',
                            value: '${_shipments.where((s) => s.status == ShipmentStatus.inTransit).length}',
                            icon: Icons.route_outlined,
                          ),
                          _StatCard(
                            title: 'Delivered',
                            value: '${_shipments.where((s) => s.status == ShipmentStatus.delivered).length}',
                            icon: Icons.verified_outlined,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                      child: Text(
                        'Shipment Status',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: selected == null
                          ? const SizedBox.shrink()
                          : _SelectedShipmentCard(
                              shipment: selected,
                              onAdvance: () => _advanceShipment(filtered[_selectedIndex].id),
                            ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                      child: Text(
                        'Timeline',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: selected == null
                          ? const SizedBox.shrink()
                          : _ShipmentTimeline(events: selected.events),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 28)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_Shipment> _filteredShipments() {
    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) return _shipments;

    return _shipments.where((s) {
      return s.id.toLowerCase().contains(q) ||
          s.title.toLowerCase().contains(q) ||
          s.customer.toLowerCase().contains(q) ||
          s.origin.toLowerCase().contains(q) ||
          s.destination.toLowerCase().contains(q) ||
          s.driver.toLowerCase().contains(q) ||
          s.truck.toLowerCase().contains(q);
    }).toList();
  }

  int _onTimeCount() {
    final total = _shipments.length;
    if (total == 0) return 0;
    final onTime = _shipments.where((s) => s.status != ShipmentStatus.delayed).length;
    return ((onTime / total) * 100).round();
  }

  void _advanceShipment(String shipmentId) {
    setState(() {
      final idx = _shipments.indexWhere((s) => s.id == shipmentId);
      if (idx == -1) return;
      final s = _shipments[idx];
      final nextStatus = switch (s.status) {
        ShipmentStatus.created => ShipmentStatus.pickedUp,
        ShipmentStatus.pickedUp => ShipmentStatus.inTransit,
        ShipmentStatus.inTransit => ShipmentStatus.delivered,
        ShipmentStatus.delivered => ShipmentStatus.delivered,
        ShipmentStatus.delayed => ShipmentStatus.inTransit,
      };
      _shipments[idx] = s.copyWith(status: nextStatus);
    });
  }
}

enum ShipmentStatus { created, pickedUp, inTransit, delivered, delayed }

class _Shipment {
  final String id;
  final String title;
  final String customer;
  final String origin;
  final String destination;
  final String driver;
  final String truck;
  final ShipmentStatus status;
  final String eta;
  final double progress;
  final String lastUpdate;
  final String temperature;
  final String distanceLeft;
  final List<_ShipmentEvent> events;

  const _Shipment({
    required this.id,
    required this.title,
    required this.customer,
    required this.origin,
    required this.destination,
    required this.driver,
    required this.truck,
    required this.status,
    required this.eta,
    required this.progress,
    required this.lastUpdate,
    required this.temperature,
    required this.distanceLeft,
    required this.events,
  });

  _Shipment copyWith({
    ShipmentStatus? status,
  }) {
    return _Shipment(
      id: id,
      title: title,
      customer: customer,
      origin: origin,
      destination: destination,
      driver: driver,
      truck: truck,
      status: status ?? this.status,
      eta: eta,
      progress: progress,
      lastUpdate: lastUpdate,
      temperature: temperature,
      distanceLeft: distanceLeft,
      events: events,
    );
  }
}

class _ShipmentEvent {
  final String title;
  final String time;
  final bool done;

  const _ShipmentEvent(this.title, this.time, this.done);
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 190,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: Colors.green.shade50,
            child: Icon(icon, color: Colors.green.shade700),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _SelectedShipmentCard extends StatelessWidget {
  final _Shipment shipment;
  final VoidCallback onAdvance;

  const _SelectedShipmentCard({
    required this.shipment,
    required this.onAdvance,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (shipment.status) {
      ShipmentStatus.created => Colors.grey,
      ShipmentStatus.pickedUp => Colors.orange,
      ShipmentStatus.inTransit => Colors.blue,
      ShipmentStatus.delivered => Colors.green,
      ShipmentStatus.delayed => Colors.red,
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
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
                    Text(
                      shipment.id,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      shipment.title,
                      style: GoogleFonts.poppins(
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              Chip(
                label: Text(
                  shipment.status.name.toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: statusColor,
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 700;
              final left = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoRow(label: 'Customer', value: shipment.customer),
                  _InfoRow(label: 'Route', value: '${shipment.origin} → ${shipment.destination}'),
                  _InfoRow(label: 'Driver', value: shipment.driver),
                  _InfoRow(label: 'Truck', value: shipment.truck),
                ],
              );
              final right = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoRow(label: 'ETA', value: shipment.eta),
                  _InfoRow(label: 'Last Update', value: shipment.lastUpdate),
                  _InfoRow(label: 'Temp', value: shipment.temperature),
                  _InfoRow(label: 'Remaining', value: shipment.distanceLeft),
                ],
              );

              return isNarrow
                  ? Column(
                      children: [
                        left,
                        const SizedBox(height: 12),
                        right,
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: left),
                        const SizedBox(width: 20),
                        Expanded(child: right),
                      ],
                    );
            },
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: shipment.progress,
            minHeight: 10,
            borderRadius: BorderRadius.circular(999),
          ),
          const SizedBox(height: 10),
          Text(
            '${(shipment.progress * 100).round()}% complete',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: shipment.status == ShipmentStatus.delivered ? null : onAdvance,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Advance Status'),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShipmentTimeline extends StatelessWidget {
  final List<_ShipmentEvent> events;

  const _ShipmentTimeline({required this.events});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: events.asMap().entries.map((entry) {
          final index = entry.key;
          final event = entry.value;
          final isLast = index == events.length - 1;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: event.done ? Colors.green : Colors.grey.shade300,
                      shape: BoxShape.circle,
                    ),
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 56,
                      color: Colors.grey.shade300,
                    ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        event.time,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _LogisticsRail extends StatelessWidget {
  final List<_Shipment> shipments;
  final ValueChanged<int> onSelect;

  const _LogisticsRail({
    required this.shipments,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      height: double.infinity,
      color: Colors.grey.shade50,
      padding: const EdgeInsets.all(20),
      child: ListView(
        children: [
          Text(
            'Shipments',
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          ...List.generate(shipments.length, (index) {
            final s = shipments[index];
            return Card(
              child: ListTile(
                onTap: () => onSelect(index),
                leading: CircleAvatar(
                  backgroundColor: switch (s.status) {
                    ShipmentStatus.created => Colors.grey.shade200,
                    ShipmentStatus.pickedUp => Colors.orange.shade100,
                    ShipmentStatus.inTransit => Colors.blue.shade100,
                    ShipmentStatus.delivered => Colors.green.shade100,
                    ShipmentStatus.delayed => Colors.red.shade100,
                  },
                  child: const Icon(Icons.local_shipping_outlined),
                ),
                title: Text(s.id),
                subtitle: Text('${s.origin} → ${s.destination}'),
                trailing: Text(
                  s.eta,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}