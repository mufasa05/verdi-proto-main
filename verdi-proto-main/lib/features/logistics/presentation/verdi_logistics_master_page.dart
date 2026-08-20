import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/agri_logistics_models.dart';
import '../state/agri_logistics_state.dart';
import 'transporter_onboarding_page.dart';
import 'transporter_splash_screen.dart';

/// Bespoke Verdi Logistics Carrier Operating System (Carrier OS)
class VerdiLogisticsMasterPage extends ConsumerStatefulWidget {
  const VerdiLogisticsMasterPage({super.key});

  @override
  ConsumerState<VerdiLogisticsMasterPage> createState() => _VerdiLogisticsMasterPageState();
}

class _VerdiLogisticsMasterPageState extends ConsumerState<VerdiLogisticsMasterPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const bgDark = Color(0xFF060B14);
  static const cardDark = Color(0xFF0D1626);
  static const cardBorder = Color(0xFF1E293B);
  static const amber = Color(0xFFFF9F1C);
  static const cyan = Color(0xFF00F0FF);
  static const green = Color(0xFF10B981);
  static const red = Color(0xFFEF4444);
  static const purple = Color(0xFF8B5CF6);
  static const textMuted = Color(0xFF94A3B8);

  bool _hasSeenSplash = false;
  bool _hasCompletedOnboarding = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasSeenSplash) {
      return TransporterSplashScreen(
        onContinue: () => setState(() => _hasSeenSplash = true),
      );
    }

    if (!_hasCompletedOnboarding) {
      return TransporterOnboardingPage(
        onCompleted: () => setState(() => _hasCompletedOnboarding = true),
      );
    }

    final logisticsState = ref.watch(agriLogisticsProvider);
    final profile = logisticsState.carrierProfile;
    final isVerified = profile.qualifiesForVerifiedBadge;

    return Scaffold(
      backgroundColor: bgDark,
      body: SafeArea(
        child: Column(
          children: [
            // Top Carrier OS Command Header
            _buildCarrierHeader(profile, isVerified, logisticsState),

            // 6 Dedicated Module Tabs
            Container(
              decoration: const BoxDecoration(
                color: cardDark,
                border: Border(bottom: BorderSide(color: cardBorder)),
              ),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: amber,
                indicatorWeight: 3,
                labelColor: amber,
                unselectedLabelColor: textMuted,
                labelStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12.5),
                tabs: const [
                  Tab(icon: Icon(Icons.dashboard_outlined, size: 16), text: 'Dispatch Console'),
                  Tab(icon: Icon(Icons.electric_rickshaw_outlined, size: 16), text: 'Short-Trip Pools'),
                  Tab(icon: Icon(Icons.fire_truck_outlined, size: 16), text: 'Bulk Reefer Haulage'),
                  Tab(icon: Icon(Icons.qr_code_scanner_rounded, size: 16), text: 'QR Manifest Builder'),
                  Tab(icon: Icon(Icons.satellite_alt_outlined, size: 16), text: 'In-Cab Telemetry'),
                  Tab(icon: Icon(Icons.fact_check_outlined, size: 16), text: 'e-POD & Escrow Desk'),
                ],
              ),
            ),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDispatchConsoleTab(logisticsState),
                  _buildShortTripPoolsTab(logisticsState),
                  _buildBulkHaulageTab(logisticsState),
                  _buildManifestBuilderTab(logisticsState),
                  _buildInCabTelemetryTab(logisticsState),
                  _buildEpodEscrowDeskTab(logisticsState),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // TOP CARRIER HEADER
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildCarrierHeader(CarrierProfile profile, bool isVerified, AgriLogisticsState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: cardDark,
        border: Border(bottom: BorderSide(color: cardBorder)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Carrier Avatar
              CircleAvatar(
                radius: 20,
                backgroundColor: amber.withOpacity(0.18),
                child: const Icon(Icons.local_shipping_rounded, color: amber, size: 20),
              ),
              const SizedBox(width: 12),

              // Carrier Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            profile.carrierName,
                            style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14.5, color: Colors.white),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (isVerified)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: amber.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: amber),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.verified, size: 12, color: amber),
                                SizedBox(width: 4),
                                Text('VERIFIED CARRIER', style: TextStyle(color: amber, fontSize: 9.5, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${profile.vehicle.registrationNumber} • ${profile.vehicle.model} • ${profile.completedTripsCount} Trips • ⭐ ${profile.rating}',
                      style: const TextStyle(fontSize: 11, color: textMuted),
                    ),
                  ],
                ),
              ),

              // Carrier Escrow Balance Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: bgDark,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: green.withOpacity(0.4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('CARRIER ESCROW WALLET', style: TextStyle(fontSize: 8.5, color: textMuted, fontWeight: FontWeight.bold)),
                    Text(
                      'US\$ ${profile.walletBalance.toStringAsFixed(2)}',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w900, color: green, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // Duty Status Dropdown
              _buildDutyStatusDropdown(profile),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDutyStatusDropdown(CarrierProfile profile) {
    return PopupMenuButton<CarrierDutyStatus>(
      onSelected: (status) => ref.read(agriLogisticsProvider.notifier).setDutyStatus(status),
      color: cardDark,
      itemBuilder: (context) => CarrierDutyStatus.values.map((s) {
        return PopupMenuItem(
          value: s,
          child: Row(
            children: [
              CircleAvatar(backgroundColor: s.color, radius: 4),
              const SizedBox(width: 8),
              Text(s.label, style: const TextStyle(color: Colors.white, fontSize: 12)),
            ],
          ),
        );
      }).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: profile.dutyStatus.color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: profile.dutyStatus.color.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            CircleAvatar(backgroundColor: profile.dutyStatus.color, radius: 4),
            const SizedBox(width: 6),
            Text(profile.dutyStatus.label, style: TextStyle(color: profile.dutyStatus.color, fontSize: 11, fontWeight: FontWeight.bold)),
            const Icon(Icons.arrow_drop_down, size: 16, color: textMuted),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // TAB 1: DISPATCH & OPERATIONS CONSOLE
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildDispatchConsoleTab(AgriLogisticsState state) {
    final activeWaybills = state.activeWaybills;
    final openOrders = state.openMarketplaceOrders;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KPI Metric Bar
          Row(
            children: [
              Expanded(child: _buildMetricCard('Active Freight Runs', '${activeWaybills.length}', Icons.local_shipping_outlined, amber)),
              const SizedBox(width: 10),
              Expanded(child: _buildMetricCard('Live IoT Speed', '${state.liveSpeedKmh.toStringAsFixed(1)} km/h', Icons.speed_outlined, cyan)),
              const SizedBox(width: 10),
              Expanded(child: _buildMetricCard('Reefer Chamber Temp', '+${state.liveReeferTemp.toStringAsFixed(1)} °C', Icons.ac_unit_outlined, green)),
              const SizedBox(width: 10),
              Expanded(child: _buildMetricCard('Marketplace Jobs', '${openOrders.length}', Icons.storefront_outlined, purple)),
            ],
          ),
          const SizedBox(height: 20),

          // Active Waybills Pipeline Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Active Master Waybills (${activeWaybills.length})', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: green.withOpacity(0.12), borderRadius: BorderRadius.circular(12), border: Border.all(color: green.withOpacity(0.3))),
                child: const Text('LIVE DISPATCH PULSE', style: TextStyle(color: green, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activeWaybills.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, idx) => _buildWaybillCard(activeWaybills[idx]),
          ),
          const SizedBox(height: 24),

          // Open Marketplace Freight Dispatch Requests
          Text('Available Marketplace Transport Orders (${openOrders.length})', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 12),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: openOrders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, idx) => _buildMarketplaceOrderCard(openOrders[idx]),
          ),
        ],
      ),
    );
  }

  Widget _buildWaybillCard(MasterWaybill wb) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: amber.withOpacity(0.15), borderRadius: BorderRadius.circular(6), border: Border.all(color: amber.withOpacity(0.4))),
                child: Text(wb.waybillNumber, style: const TextStyle(color: amber, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: wb.status.color.withOpacity(0.15), borderRadius: BorderRadius.circular(6), border: Border.all(color: wb.status.color.withOpacity(0.4))),
                child: Text(wb.status.label, style: TextStyle(color: wb.status.color, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
              const Spacer(),
              Text('US\$ ${wb.totalFreightFee.toStringAsFixed(2)}', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: green)),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              const Icon(Icons.my_location_rounded, color: green, size: 16),
              const SizedBox(width: 6),
              Text(wb.origin, style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600)),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.arrow_forward_rounded, color: textMuted, size: 14),
              ),
              const Icon(Icons.location_on_rounded, color: red, size: 16),
              const SizedBox(width: 6),
              Text(wb.destination, style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 10),

          // Aggregated Lots Chips
          Wrap(
            spacing: 6,
            children: wb.items.map((item) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: const Color(0xFF060B14), borderRadius: BorderRadius.circular(6), border: Border.all(color: cardBorder)),
                child: Text('${item.cropVariety} (${item.loadedWeightKg} kg) • ${item.farmerName}', style: const TextStyle(fontSize: 10.5, color: textMuted)),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),

          // Footer info & actions
          Row(
            children: [
              Text('ETA: ${wb.estimatedDeliveryTime}', style: const TextStyle(fontSize: 11, color: textMuted)),
              if (wb.currentTemp != null) ...[
                const SizedBox(width: 12),
                Text('Chamber: +${wb.currentTemp}°C', style: const TextStyle(fontSize: 11, color: cyan, fontWeight: FontWeight.bold)),
              ],
              const Spacer(),
              if (wb.status == ShipmentStatus.inTransit)
                ElevatedButton.icon(
                  onPressed: () => _tabController.animateTo(5),
                  icon: const Icon(Icons.fact_check_outlined, size: 14),
                  label: const Text('Discharge & Sign e-POD', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(backgroundColor: green, foregroundColor: Colors.white),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMarketplaceOrderCard(TransportOrder o) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cardBorder),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: o.tier == LogisticsTier.shortTrip ? green.withOpacity(0.18) : amber.withOpacity(0.18),
            radius: 18,
            child: Icon(o.tier == LogisticsTier.shortTrip ? Icons.electric_rickshaw_outlined : Icons.fire_truck_outlined, color: o.tier == LogisticsTier.shortTrip ? green : amber, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${o.commodity} (${(o.totalWeightKg / 1000).toStringAsFixed(1)} Tonnes)', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13.5, color: Colors.white)),
                const SizedBox(height: 2),
                Text('${o.originAddress} ➔ ${o.destinationAddress}', style: const TextStyle(fontSize: 11.5, color: textMuted)),
                const SizedBox(height: 2),
                Text('Buyer: ${o.buyerName} • Basis: ${o.agreedPaymentBasis.label}', style: const TextStyle(fontSize: 10.5, color: cyan)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('US\$ ${o.quotedPrice.toStringAsFixed(2)}', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w900, color: green)),
              const SizedBox(height: 6),
              ElevatedButton(
                onPressed: () {
                  ref.read(agriLogisticsProvider.notifier).acceptTransportOrder(o);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Waybill generated for ${o.commodity} dispatch.'), backgroundColor: amber),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: amber, foregroundColor: bgDark, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6)),
                child: const Text('Accept Load', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // TAB 2: HYPER-LOCAL SHORT-TRIP POOLS
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildShortTripPoolsTab(AgriLogisticsState state) {
    final shortTripBatches = state.availableFarmBatches.where((b) => b.initialQuantityKg <= 3000).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: green.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: green.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.electric_rickshaw_outlined, color: green, size: 28),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hyper-Local Farmgate Aggregation Pools', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                      Text('Optimized for smallholder farmgate-to-hub consolidation (< 50 km) using motorcycles, tricycles & light utilities.', style: TextStyle(fontSize: 11.5, color: textMuted)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: green.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                  child: const Text('FIXED & PER-KM FORMULAS', style: TextStyle(color: green, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Text('Available Smallholder Batches at Farmgates (${shortTripBatches.length})', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 10),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: shortTripBatches.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, idx) {
              final b = shortTripBatches[idx];
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(14), border: Border.all(color: cardBorder)),
                child: Row(
                  children: [
                    const Icon(Icons.inventory_2_outlined, color: green, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(b.cropVariety, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13.5, color: Colors.white)),
                          Text('Farmer: ${b.farmerName} • Location: ${b.location}', style: const TextStyle(fontSize: 11, color: textMuted)),
                          Text('Harvested: ${b.harvestDate} • Moisture: ${b.initialMoisturePercentage}% • QR: ${b.qrCodeUid}', style: const TextStyle(fontSize: 10.5, color: cyan)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('${b.initialQuantityKg} kg', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 4),
                        OutlinedButton.icon(
                          onPressed: () => _tabController.animateTo(3),
                          icon: const Icon(Icons.qr_code_scanner, size: 12),
                          label: const Text('Add to Manifest', style: TextStyle(fontSize: 10.5)),
                          style: OutlinedButton.styleFrom(foregroundColor: green, side: const BorderSide(color: green)),
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

  // ───────────────────────────────────────────────────────────────────────────
  // TAB 3: LONG-DISTANCE BULK & REEFER HAULAGE
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildBulkHaulageTab(AgriLogisticsState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cyan.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cyan.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.ac_unit_outlined, color: cyan, size: 28),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Long-Distance Bulk Haulage & Reefer Telemetry', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                      Text('Multi-tonne inter-provincial corridors with live ELD IoT cold-chain temperature stream, fuel index & border clearance.', style: TextStyle(fontSize: 11.5, color: textMuted)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: cyan.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                  child: const Text('PER-TONNE-KM FORMULA', style: TextStyle(color: cyan, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Live Reefer Chamber HUD
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(16), border: Border.all(color: cardBorder)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Reefer Chamber Live Telemetry Telematics', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: green.withOpacity(0.15), borderRadius: BorderRadius.circular(4)),
                      child: const Text('SAFE TEMP RANGE: +2.0°C to +6.0°C', style: TextStyle(color: green, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(child: _buildTelemetryStat('Current Chamber Temp', '+${state.liveReeferTemp.toStringAsFixed(1)} °C', cyan, Icons.thermostat_outlined)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildTelemetryStat('Fleet Telemetry Speed', '${state.liveSpeedKmh.toStringAsFixed(1)} km/h', amber, Icons.speed_outlined)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildTelemetryStat('Fuel Tank Level', '84.2 % (420 L)', green, Icons.local_gas_station_outlined)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTelemetryStat(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFF060B14), borderRadius: BorderRadius.circular(12), border: Border.all(color: cardBorder)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 6),
          Text(value, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white)),
          Text(label, style: const TextStyle(fontSize: 10, color: textMuted)),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // TAB 4: DIGITAL WAYBILLS & QR BATCH MANIFEST BUILDER
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildManifestBuilderTab(AgriLogisticsState state) {
    final batches = state.availableFarmBatches;
    final primaryWaybill = state.activeWaybills.isNotEmpty ? state.activeWaybills.first : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Multi-Farmer QR Batch Manifest Builder', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          const Text('Scan and aggregate multiple smallholder farmgate produce batches onto a single Master Waybill.', style: TextStyle(fontSize: 12, color: textMuted)),
          const SizedBox(height: 16),

          if (primaryWaybill != null)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(14), border: Border.all(color: amber.withOpacity(0.4))),
              child: Row(
                children: [
                  const Icon(Icons.description_outlined, color: amber, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Target Master Waybill: ${primaryWaybill.waybillNumber}', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13.5)),
                        Text('${primaryWaybill.origin} ➔ ${primaryWaybill.destination}', style: const TextStyle(fontSize: 11.5, color: textMuted)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),

          Text('Available Farm Produce Batches for Aggregation', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 10),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: batches.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, idx) {
              final b = batches[idx];
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(14), border: Border.all(color: cardBorder)),
                child: Row(
                  children: [
                    CircleAvatar(backgroundColor: amber.withOpacity(0.15), radius: 18, child: const Icon(Icons.qr_code_2, color: amber, size: 18)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${b.cropVariety} (${b.initialQuantityKg} kg)', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13.5, color: Colors.white)),
                          Text('Farmer: ${b.farmerName} • Origin: ${b.location}', style: const TextStyle(fontSize: 11, color: textMuted)),
                          Text('EUDR Cert: ${b.organicCertificationCode}', style: const TextStyle(fontSize: 10.5, color: cyan)),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        if (primaryWaybill != null) {
                          ref.read(agriLogisticsProvider.notifier).aggregateBatchToWaybill(primaryWaybill.id, b, b.initialQuantityKg);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Aggregated ${b.cropVariety} to Waybill ${primaryWaybill.waybillNumber}!'), backgroundColor: green),
                          );
                        }
                      },
                      icon: const Icon(Icons.add_link_rounded, size: 14),
                      label: const Text('Aggregate Lot', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(backgroundColor: green, foregroundColor: Colors.white),
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

  // ───────────────────────────────────────────────────────────────────────────
  // TAB 5: IN-CAB TELEMETRY & ELD RADAR
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildInCabTelemetryTab(AgriLogisticsState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(16), border: Border.all(color: cardBorder)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Live In-Cab ELD Telemetry Stream', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text('Sync: ${state.lastTelemetrySyncTime}', style: const TextStyle(fontSize: 11, color: cyan, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 12),

                // Simulated Map HUD Radar
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF060B14),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: cyan.withOpacity(0.3)),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.navigation_rounded, color: cyan, size: 36),
                            const SizedBox(height: 6),
                            Text('A5 SADC Transit Corridor • GPS Coordinate [-18.1856, 31.5519]', style: GoogleFonts.inter(fontSize: 11.5, color: textMuted)),
                            Text('Live Vehicle Speed: ${state.liveSpeedKmh.toStringAsFixed(1)} km/h • Reefer: +${state.liveReeferTemp.toStringAsFixed(1)} °C', style: const TextStyle(fontSize: 11, color: amber, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // TAB 6: DISCHARGE INSPECTION & E-POD ESCROW DESK
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildEpodEscrowDeskTab(AgriLogisticsState state) {
    final activeWaybill = state.activeWaybills.isNotEmpty ? state.activeWaybills.first : null;

    final weightCtrl = TextEditingController(text: '8495.0');
    final gradeCtrl = TextEditingController(text: 'Grade A Export');
    final moistureCtrl = TextEditingController(text: '12.4');
    final spoilageCtrl = TextEditingController(text: '5.0');
    final inspectorCtrl = TextEditingController(text: 'Blessing Musona (Chief Dock Inspector)');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: purple.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: purple.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.fact_check_outlined, color: purple, size: 28),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Discharge Quality Verification & e-POD Settlement', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                      Text('Log received weight, moisture drop & inspector signature to instantly trigger automatic escrow payout to carrier and farmer.', style: TextStyle(fontSize: 11.5, color: textMuted)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: purple.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                  child: const Text('ESCROW SETTLEMENT READY', style: TextStyle(color: purple, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          if (activeWaybill != null) ...[
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(16), border: Border.all(color: cardBorder)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Discharge Cargo Form for Waybill: ${activeWaybill.waybillNumber}', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(child: _field('Received Weight (kg)', weightCtrl)),
                      const SizedBox(width: 12),
                      Expanded(child: _field('Received Moisture (%)', moistureCtrl)),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(child: _field('Received Quality Grade', gradeCtrl)),
                      const SizedBox(width: 12),
                      Expanded(child: _field('Spoilage Loss (kg)', spoilageCtrl)),
                    ],
                  ),
                  const SizedBox(height: 12),

                  _field('Receiving Inspector Name', inspectorCtrl),
                  const SizedBox(height: 16),

                  // Electronic Signature Capture Simulation
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF060B14),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: cardBorder),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.draw_outlined, color: amber, size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text('Electronic Inspector Signature Verified (e-POD Hash #9982)', style: TextStyle(color: textMuted, fontSize: 11.5)),
                        ),
                        Icon(Icons.check_circle, color: green, size: 16),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await ref.read(agriLogisticsProvider.notifier).submitDischargeInspectionAndSettle(
                              waybill: activeWaybill,
                              receivedWeightKg: double.tryParse(weightCtrl.text) ?? 8495.0,
                              receivedGrade: gradeCtrl.text,
                              receivedMoisturePercentage: double.tryParse(moistureCtrl.text) ?? 12.4,
                              spoilageLossKg: double.tryParse(spoilageCtrl.text) ?? 5.0,
                              inspectorName: inspectorCtrl.text,
                              signatureData: 'SIG_${DateTime.now().millisecondsSinceEpoch}',
                            );

                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('e-POD Signed! Escrow of US\$ ${activeWaybill.totalFreightFee.toStringAsFixed(2)} released to Carrier wallet.'),
                              backgroundColor: green,
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.verified_rounded, size: 18),
                      label: Text('Sign e-POD & Trigger Instant Escrow Payout (US\$ ${activeWaybill.totalFreightFee.toStringAsFixed(2)})', style: const TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(backgroundColor: green, foregroundColor: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl) {
    return TextField(
      controller: ctrl,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: textMuted, fontSize: 12),
        filled: true,
        fillColor: const Color(0xFF060B14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(14), border: Border.all(color: cardBorder)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 6),
          Text(value, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white)),
          Text(title, style: const TextStyle(fontSize: 10, color: textMuted)),
        ],
      ),
    );
  }
}
