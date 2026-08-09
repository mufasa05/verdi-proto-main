import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:verdi/core/services/verdi_api_service.dart';
import '../features/logistics/data/logistics_data.dart';
import '../state/platform_data_state.dart';

class NearbyTransportPanel extends ConsumerWidget {
  const NearbyTransportPanel({super.key});

  static const _green = Color(0xFF16A34A);
  static const _dark = Color(0xFF0F172A);
  static const _muted = Color(0xFF64748B);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trucks = ref.watch(trucksListProvider);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.local_shipping_outlined, color: _green, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nearby Logistics Hub',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: _dark,
                      ),
                    ),
                    Text(
                      'Flexible transport for bulk goods and cash-on-site orders',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: _muted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (trucks.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: Text("No transport options available")),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: trucks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final t = trucks[index];
                final isReady = t.status.toLowerCase().contains('ready') || t.status.toLowerCase().contains('idle');

                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFEDF2F7)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      t.driver,
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: _dark,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.star, color: Colors.amber, size: 14),
                                    const SizedBox(width: 2),
                                    Text(
                                      t.rating.toStringAsFixed(1),
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                        color: _dark,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  t.vehicle,
                                  style: const TextStyle(fontSize: 12, color: _muted),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Plate: ${t.plateNumber}',
                                  style: const TextStyle(fontSize: 11, color: _muted),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '\$${t.costPerKm.toStringAsFixed(2)}/km',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                  color: _green,
                                ),
                              ),
                              Text(
                                'ETA: ${t.eta}',
                                style: const TextStyle(fontSize: 11, color: _muted),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isReady ? _green : Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            t.status,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isReady ? _green : Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: const [
                          _PaymentChip(label: 'EcoCash'),
                          _PaymentChip(label: 'OneMoney'),
                          _PaymentChip(label: 'Telecash'),
                          _PaymentChip(label: 'Card'),
                          _PaymentChip(label: 'Bank Transfer'),
                          _PaymentChip(label: 'Cash On Site'),
                        ],
                      ),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => _BookTransportModal(truck: t),
                              );
                            },
                            icon: const Icon(Icons.airport_shuttle_outlined, size: 14),
                            label: const Text('Book Transport', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
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
}

class _PaymentChip extends StatelessWidget {
  final String label;
  const _PaymentChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(fontSize: 9.5, fontWeight: FontWeight.w500, color: const Color(0xFF64748B)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Rich Interactive Transport Booking Modal
// ─────────────────────────────────────────────────────────────────────────────

class _BookTransportModal extends ConsumerStatefulWidget {
  final TruckItem truck;
  const _BookTransportModal({required this.truck});

  @override
  ConsumerState<_BookTransportModal> createState() => _BookTransportModalState();
}

class _BookTransportModalState extends ConsumerState<_BookTransportModal> {
  static const _green = Color(0xFF16A34A);
  static const _dark = Color(0xFF0F172A);
  static const _muted = Color(0xFF64748B);

  String _selectedCommodity = '🌽 Fresh Maize & Grains';
  double _tonnage = 12.0;
  String _tempRequirement = 'Ambient';
  final _pickupController = TextEditingController(text: 'Mazowe Valley Sector 4 Packhouse');
  String _destination = '🛒 Mbare Musika Wholesale Market (Harare)';
  String _pickupSlot = 'Today 14:00 PM';
  String _paymentMethod = 'EcoCash 📱';
  bool _includeInsurance = true;
  final _notesController = TextEditingController();

  final Map<String, int> _destDistances = {
    '🛒 Mbare Musika Wholesale Market (Harare)': 125,
    '🏭 GMB Grain Silos (Concession Depot)': 45,
    '⚓ Beira Export Port Terminal (Mozambique)': 290,
    '🚢 Beitbridge Border Freight Corridor': 580,
    '✈️ Harare Airport Cold Storage Hub': 95,
  };

  final List<String> _commodities = [
    '🌽 Fresh Maize & Grains',
    '🥑 Cold-Chain Fruit (Avocados / Citrus / Blueberries)',
    '🍅 Fresh Horticulture & Vegetables',
    '🍵 Raw Tobacco & Export Commodities',
    '🧪 Fertilizer & Soil Additives',
    '🚜 Heavy Farm Machinery / Spares',
  ];

  final List<String> _destinations = [
    '🛒 Mbare Musika Wholesale Market (Harare)',
    '🏭 GMB Grain Silos (Concession Depot)',
    '⚓ Beira Export Port Terminal (Mozambique)',
    '🚢 Beitbridge Border Freight Corridor',
    '✈️ Harare Airport Cold Storage Hub',
  ];

  final List<String> _timeSlots = [
    'Today 14:00 PM',
    'Tomorrow 07:00 AM',
    'Tomorrow 14:00 PM',
    'Custom Date Schedule',
  ];

  final List<String> _paymentMethods = [
    'EcoCash 📱',
    'OneMoney 📱',
    'Bank ZIPIT 🏦',
    'Card Settlement 💳',
    'Cash on Delivery 💵',
  ];

  double get _calculateTotalCost {
    final dist = _destDistances[_destination] ?? 100;
    final baseCost = widget.truck.costPerKm * dist;
    final insurance = _includeInsurance ? 15.0 : 0.0;
    return baseCost + insurance;
  }

  void _confirmAndIssueWaybill() {
    final dist = _destDistances[_destination] ?? 100;
    final waybillId = 'WAYBILL-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}';
    final total = _calculateTotalCost;

    final newDelivery = DeliveryItem(
      id: waybillId,
      customer: 'Verdi Operator',
      product: '$_selectedCommodity (${_tonnage.toStringAsFixed(1)} Tons)',
      quantity: '${_tonnage.toStringAsFixed(1)} Tons',
      from: _pickupController.text.trim().isEmpty ? 'Mazowe Packhouse' : _pickupController.text.trim(),
      to: _destination.split(' ')[1],
      status: 'Driver Dispatched',
      driver: widget.truck.driver,
      vehicle: '${widget.truck.vehicle} (${widget.truck.plateNumber})',
      eta: '2.5 Hours',
      progress: 0.15,
      hub: 'Central Hub',
      priority: _tempRequirement != 'Ambient' ? 'High' : 'Normal',
      riskLevel: 'Low',
      exceptionType: 'None',
      proofStatus: 'Pending Pickup',
      temperature: _tempRequirement == 'Ambient' ? 'Ambient' : (_tempRequirement.contains('Chilled') ? '3.2°C' : '-18.0°C'),
      distanceRemaining: '$dist km',
      timeline: ['Dispatched from ${_pickupController.text.trim()}'],
    );

    // Save to Riverpod State & Persist to Backend API
    ref.read(deliveriesListProvider.notifier).addDelivery(newDelivery);
    try {
      VerdiApiService.instance.updateDispatchStatus(waybillId, 'Dispatched & En Route');
    } catch (_) {}

    Navigator.pop(context);

    // Show Digital Consignment Waybill Modal
    showDialog(
      context: context,
      builder: (context) => _DigitalWaybillDialog(
        waybillId: waybillId,
        truck: widget.truck,
        commodity: _selectedCommodity,
        tonnage: _tonnage,
        tempRequirement: _tempRequirement,
        pickup: _pickupController.text.trim(),
        destination: _destination,
        distanceKm: dist,
        totalCost: total,
        paymentMethod: _paymentMethod,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dist = _destDistances[_destination] ?? 100;
    final total = _calculateTotalCost;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 580, maxHeight: 720),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _green.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.local_shipping_rounded, color: _green, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Book Dispatch Transport',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: _dark,
                          ),
                        ),
                        Text(
                          'Driver: ${widget.truck.driver} • ${widget.truck.vehicle} (${widget.truck.plateNumber})',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: _muted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: _muted),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),

              // SECTION 1: Cargo Specifications
              const SizedBox(height: 12),
              Text(
                '1. CARGO SPECIFICATIONS',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: _green,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedCommodity,
                decoration: InputDecoration(
                  labelText: 'Cargo Commodity Category',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                items: _commodities.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 13)))).toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _selectedCommodity = v);
                },
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Payload Weight: ${_tonnage.toStringAsFixed(1)} Tons',
                          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: _dark),
                        ),
                        Slider(
                          value: _tonnage,
                          min: 1.0,
                          max: 30.0,
                          divisions: 29,
                          activeColor: _green,
                          label: '${_tonnage.toStringAsFixed(1)} Tons',
                          onChanged: (val) => setState(() => _tonnage = val),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Temperature Control Requirement',
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: _dark),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: ['Ambient', 'Chilled (+2°C to +4°C)', 'Deep Freeze (-18°C)'].map((mode) {
                  final isSelected = _tempRequirement == mode;
                  return ChoiceChip(
                    label: Text(mode, style: TextStyle(fontSize: 11.5, color: isSelected ? Colors.white : _dark)),
                    selected: isSelected,
                    selectedColor: _green,
                    onSelected: (selected) {
                      if (selected) setState(() => _tempRequirement = mode);
                    },
                  );
                }).toList(),
              ),

              // SECTION 2: Pickup & Route
              const SizedBox(height: 20),
              Text(
                '2. ROUTE & PICKUP SCHEDULE',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: _green,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _pickupController,
                decoration: InputDecoration(
                  labelText: 'Pickup Location / Packhouse',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  prefixIcon: const Icon(Icons.location_on_outlined, color: _green, size: 20),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _destination,
                decoration: InputDecoration(
                  labelText: 'Delivery Destination Terminal',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  prefixIcon: const Icon(Icons.flag_outlined, color: Colors.blue, size: 20),
                ),
                items: _destinations.map((d) => DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(fontSize: 12.5)))).toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _destination = v);
                },
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: _timeSlots.map((slot) {
                  final isSelected = _pickupSlot == slot;
                  return ChoiceChip(
                    label: Text(slot, style: TextStyle(fontSize: 11, color: isSelected ? Colors.white : _dark)),
                    selected: isSelected,
                    selectedColor: _green,
                    onSelected: (selected) {
                      if (selected) setState(() => _pickupSlot = slot);
                    },
                  );
                }).toList(),
              ),

              // SECTION 3: Payment & Settlement
              const SizedBox(height: 20),
              Text(
                '3. SETTLEMENT & TRANSIT PROTECTION',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: _green,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _paymentMethods.map((pay) {
                  final isSelected = _paymentMethod == pay;
                  return ChoiceChip(
                    label: Text(pay, style: TextStyle(fontSize: 11.5, color: isSelected ? Colors.white : _dark)),
                    selected: isSelected,
                    selectedColor: _green,
                    onSelected: (selected) {
                      if (selected) setState(() => _paymentMethod = pay);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('SADC Cargo Transit Insurance (+\$15.00)', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                subtitle: const Text('Covers payload against transit loss, delay, or thermal spoilage.', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                value: _includeInsurance,
                activeColor: _green,
                onChanged: (val) => setState(() => _includeInsurance = val ?? true),
              ),

              const SizedBox(height: 8),
              TextField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: 'Special Driver Instructions (Optional)',
                  hintText: 'e.g. Tarpaulin rain cover required, call gate manager on arrival',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
              ),
              const SizedBox(height: 18),

              // Live Cost Card & Action
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Est. Distance: $dist km @ \$${widget.truck.costPerKm.toStringAsFixed(2)}/km',
                          style: GoogleFonts.inter(fontSize: 11.5, color: _muted),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Total Fare: \$${total.toStringAsFixed(2)}',
                          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w900, color: _green),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: _confirmAndIssueWaybill,
                      icon: const Icon(Icons.assignment_turned_in_rounded, size: 18),
                      label: const Text('Confirm & Issue Waybill', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Digital Consignment Waybill Dialog
// ─────────────────────────────────────────────────────────────────────────────

class _DigitalWaybillDialog extends StatelessWidget {
  final String waybillId;
  final TruckItem truck;
  final String commodity;
  final double tonnage;
  final String tempRequirement;
  final String pickup;
  final String destination;
  final int distanceKm;
  final double totalCost;
  final String paymentMethod;

  const _DigitalWaybillDialog({
    required this.waybillId,
    required this.truck,
    required this.commodity,
    required this.tonnage,
    required this.tempRequirement,
    required this.pickup,
    required this.destination,
    required this.distanceKm,
    required this.totalCost,
    required this.paymentMethod,
  });

  static const _green = Color(0xFF16A34A);
  static const _dark = Color(0xFF0F172A);
  static const _muted = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFDCFCE7)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: _green, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Transport Dispatch Confirmed!',
                            style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: const Color(0xFF166534)),
                          ),
                          Text(
                            'Waybill #$waybillId issued to carrier.',
                            style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF15803D)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Waybill Document Box
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('VERDI CONSIGNMENT WAYBILL', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w900, color: _muted, letterSpacing: 1.2)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: _green, borderRadius: BorderRadius.circular(6)),
                          child: const Text('DISPATCHED', style: TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Divider(),
                    const SizedBox(height: 8),

                    _waybillRow('Waybill ID:', waybillId),
                    _waybillRow('Carrier Driver:', '${truck.driver} (${truck.vehicle})'),
                    _waybillRow('Vehicle Registration:', truck.plateNumber),
                    _waybillRow('Commodity:', commodity),
                    _waybillRow('Payload Tonnage:', '${tonnage.toStringAsFixed(1)} Tons'),
                    _waybillRow('Thermal Requirement:', tempRequirement),
                    _waybillRow('Pickup Origin:', pickup),
                    _waybillRow('Delivery Terminal:', destination),
                    _waybillRow('Est. Distance:', '$distanceKm km'),
                    _waybillRow('Settlement Total:', '\$${totalCost.toStringAsFixed(2)} ($paymentMethod)'),

                    const SizedBox(height: 12),
                    // Barcode & QR Code simulation
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.qr_code_2_rounded, size: 32, color: _dark),
                              SizedBox(width: 8),
                              Text('Scan e-Waybill QR at Terminal Gate', style: TextStyle(fontSize: 10.5, color: _muted, fontWeight: FontWeight.w600)),
                            ],
                          ),
                          const Icon(Icons.verified, color: _green, size: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.print_outlined, size: 16),
                    label: const Text('Print Waybill', style: TextStyle(fontSize: 12)),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(backgroundColor: _green, foregroundColor: Colors.white),
                    child: const Text('Done', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _waybillRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 140, child: Text(label, style: const TextStyle(fontSize: 11.5, color: _muted, fontWeight: FontWeight.w500))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 11.5, color: _dark, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}
