import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../state/app_state.dart';
import '../../../state/platform_data_state.dart';
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

  bool _hasSeenSplash = true;
  bool _hasCompletedOnboarding = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 8, vsync: this);
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

            // 8 Dedicated Module Tabs
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
                  Tab(icon: Icon(Icons.link_rounded, size: 16), text: 'Traceability & BoL'),
                  Tab(icon: Icon(Icons.settings_outlined, size: 16), text: 'Telematics & Settings'),
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
                  _buildTraceabilityTab(logisticsState),
                  _buildSettingsTab(logisticsState),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 720;

        final carrierInfo = Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: amber.withOpacity(0.18),
              child: const Icon(Icons.local_shipping_rounded, color: amber, size: 20),
            ),
            const SizedBox(width: 12),
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
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        );

        final escrowPill = Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: bgDark,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: green.withOpacity(0.4)),
          ),
          child: Column(
            crossAxisAlignment: isNarrow ? CrossAxisAlignment.start : CrossAxisAlignment.end,
            children: [
              const Text('CARRIER ESCROW WALLET', style: TextStyle(fontSize: 8.5, color: textMuted, fontWeight: FontWeight.bold)),
              Text(
                'US\$ ${profile.walletBalance.toStringAsFixed(2)}',
                style: GoogleFonts.inter(fontWeight: FontWeight.w900, color: green, fontSize: 13),
              ),
            ],
          ),
        );

        final dutyDropdown = _buildDutyStatusDropdown(profile);

        final registerBtn = ElevatedButton.icon(
          onPressed: () => _showRegisterTruckModal(context),
          icon: const Icon(Icons.add, size: 14),
          label: const Text('Register Truck', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: amber,
            foregroundColor: bgDark,
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            color: cardDark,
            border: Border(bottom: BorderSide(color: cardBorder)),
          ),
          child: isNarrow
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    carrierInfo,
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        escrowPill,
                        dutyDropdown,
                        registerBtn,
                      ],
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(child: carrierInfo),
                    const SizedBox(width: 12),
                    escrowPill,
                    const SizedBox(width: 10),
                    dutyDropdown,
                    const SizedBox(width: 8),
                    registerBtn,
                  ],
                ),
        );
      },
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
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 700) {
                return Row(
                  children: [
                    Expanded(child: _buildMetricCard('Active Freight Runs', '${activeWaybills.length}', Icons.local_shipping_outlined, amber)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildMetricCard('Live IoT Speed', '${state.liveSpeedKmh.toStringAsFixed(1)} km/h', Icons.speed_outlined, cyan)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildMetricCard('Reefer Chamber Temp', '+${state.liveReeferTemp.toStringAsFixed(1)} °C', Icons.ac_unit_outlined, green)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildMetricCard('Marketplace Jobs', '${openOrders.length}', Icons.storefront_outlined, purple)),
                  ],
                );
              }
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildMetricCard('Active Freight Runs', '${activeWaybills.length}', Icons.local_shipping_outlined, amber)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildMetricCard('Live IoT Speed', '${state.liveSpeedKmh.toStringAsFixed(1)} km/h', Icons.speed_outlined, cyan)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: _buildMetricCard('Reefer Chamber Temp', '+${state.liveReeferTemp.toStringAsFixed(1)} °C', Icons.ac_unit_outlined, green)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildMetricCard('Marketplace Jobs', '${openOrders.length}', Icons.storefront_outlined, purple)),
                    ],
                  ),
                ],
              );
            },
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

  Widget _buildModuleBanner({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 650;
        final mainContent = Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 11.5, color: textMuted)),
                ],
              ),
            ),
          ],
        );

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: isNarrow
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    mainContent,
                    const SizedBox(height: 10),
                    trailing,
                  ],
                )
              : Row(
                  children: [
                    Expanded(child: mainContent),
                    const SizedBox(width: 12),
                    trailing,
                  ],
                ),
        );
      },
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
          _buildModuleBanner(
            icon: Icons.electric_rickshaw_outlined,
            color: green,
            title: 'Hyper-Local Farmgate Aggregation Pools',
            subtitle: 'Optimized for smallholder farmgate-to-hub consolidation (< 50 km) using motorcycles, tricycles & light utilities.',
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: green.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
              child: const Text('FIXED & PER-KM FORMULAS', style: TextStyle(color: green, fontSize: 10, fontWeight: FontWeight.bold)),
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
          _buildModuleBanner(
            icon: Icons.ac_unit_outlined,
            color: cyan,
            title: 'Long-Distance Bulk Haulage & Reefer Telemetry',
            subtitle: 'Multi-tonne inter-provincial corridors with live ELD IoT cold-chain temperature stream, fuel index & border clearance.',
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: cyan.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
              child: const Text('PER-TONNE-KM FORMULA', style: TextStyle(color: cyan, fontSize: 10, fontWeight: FontWeight.bold)),
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
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 550;
                    final infoRow = Row(
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
                      ],
                    );

                    final btn = ElevatedButton.icon(
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
                    );

                    if (isNarrow) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          infoRow,
                          const SizedBox(height: 10),
                          btn,
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(child: infoRow),
                        const SizedBox(width: 12),
                        btn,
                      ],
                    );
                  },
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
    return _LiveCorridorGpsMapWidget(state: state);
  }

  // ───────────────────────────────────────────────────────────────────────────
  // TAB 6: DISCHARGE INSPECTION & E-POD ESCROW DESK
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildEpodEscrowDeskTab(AgriLogisticsState state) {
    final activeWaybill = state.activeWaybills.isNotEmpty ? state.activeWaybills.first : null;

    final weightCtrl = TextEditingController();
    final gradeCtrl = TextEditingController();
    final moistureCtrl = TextEditingController();
    final spoilageCtrl = TextEditingController();
    final inspectorCtrl = TextEditingController();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildModuleBanner(
            icon: Icons.fact_check_outlined,
            color: purple,
            title: 'Discharge Quality Verification & e-POD Settlement',
            subtitle: 'Log received weight, moisture drop & inspector signature to instantly trigger automatic escrow payout to carrier and farmer.',
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: purple.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
              child: const Text('ESCROW SETTLEMENT READY', style: TextStyle(color: purple, fontSize: 10, fontWeight: FontWeight.bold)),
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
                      Expanded(child: _field('Received Weight (kg)', weightCtrl, hint: 'e.g. 8495.0')),
                      const SizedBox(width: 12),
                      Expanded(child: _field('Received Moisture (%)', moistureCtrl, hint: 'e.g. 12.4')),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(child: _field('Received Quality Grade', gradeCtrl, hint: 'e.g. Grade A Export')),
                      const SizedBox(width: 12),
                      Expanded(child: _field('Spoilage Loss (kg)', spoilageCtrl, hint: 'e.g. 5.0')),
                    ],
                  ),
                  const SizedBox(height: 12),

                  _field('Receiving Inspector Name', inspectorCtrl, hint: 'e.g. Blessing Musona (Chief Dock Inspector)'),
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
                              receivedWeightKg: double.tryParse(weightCtrl.text.trim()) ?? activeWaybill.totalQuantityKg,
                              receivedGrade: gradeCtrl.text.trim().isEmpty ? 'Grade A Export' : gradeCtrl.text.trim(),
                              receivedMoisturePercentage: double.tryParse(moistureCtrl.text.trim()) ?? 12.4,
                              spoilageLossKg: double.tryParse(spoilageCtrl.text.trim()) ?? 0.0,
                              inspectorName: inspectorCtrl.text.trim().isEmpty ? 'Certified Dock Inspector' : inspectorCtrl.text.trim(),
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
                      icon: const Icon(Icons.verified, size: 18),
                      label: Text('Sign e-POD & Trigger Instant Escrow Payout (US\$ ${activeWaybill.totalFreightFee.toStringAsFixed(2)})', style: const TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(backgroundColor: green, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    ),
                  ),
                ],
              ),
            ),
          ] else
            Container(
              padding: const EdgeInsets.all(32),
              alignment: Alignment.center,
              child: const Text('No active master waybill awaiting destination discharge inspection.', style: TextStyle(color: textMuted)),
            ),
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, {String? hint}) {
    return TextField(
      controller: ctrl,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: textMuted, fontSize: 12),
        hintText: hint,
        hintStyle: TextStyle(color: textMuted.withOpacity(0.35), fontSize: 12),
        filled: true,
        fillColor: const Color(0xFF060B14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: cardBorder)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: cardBorder)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: amber)),
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

  // ───────────────────────────────────────────────────────────────────────────
  // TAB 7: TRACEABILITY & BILL OF LADING MANIFESTS
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildTraceabilityTab(AgriLogisticsState state) {
    final activeWaybill = state.activeWaybills.isNotEmpty ? state.activeWaybills.first : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildModuleBanner(
            icon: Icons.link_rounded,
            color: cyan,
            title: 'Agricultural Freight Traceability & Documents',
            subtitle: 'End-to-end QR provenance, digital Bills of Lading (BoL), phytosanitary certificates, and corridor weighbridge logs.',
            trailing: ElevatedButton.icon(
              onPressed: () => ref.read(appStateProvider.notifier).setNavIndex(15),
              icon: const Icon(Icons.open_in_new, size: 13),
              label: const Text('Open Full Traceability Hub', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(backgroundColor: cyan, foregroundColor: bgDark),
            ),
          ),
          const SizedBox(height: 16),

          Text('Active Freight Documents & Compliance Vault', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 10),

          _buildDocCard('Digital Bill of Lading (Master BoL)', '${activeWaybill?.waybillNumber ?? 'WB-AG-2026-9081'}-BoL-manifest.pdf', Icons.description_outlined, green),
          const SizedBox(height: 10),
          _buildDocCard('Phytosanitary & EUDR Transit Clearance', 'PHYTO-ZIM-2026-EUDR-889.pdf', Icons.verified_user_outlined, amber),
          const SizedBox(height: 10),
          _buildDocCard('In-Transit Cold-Chain Reefer IoT Telemetry Slip', 'REEFER-TEL-AEB2910-LOG.pdf', Icons.ac_unit_outlined, cyan),
          const SizedBox(height: 10),
          _buildDocCard('SADC Axle Weighbridge Scale Slip (Gross 11.8T)', 'WEIGHBRIDGE-HARARE-GWERU.pdf', Icons.scale_outlined, purple),
        ],
      ),
    );
  }

  Widget _buildDocCard(String title, String filename, IconData icon, Color color) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 600;
        final infoRow = Row(
          children: [
            CircleAvatar(backgroundColor: color.withOpacity(0.15), radius: 18, child: Icon(icon, color: color, size: 18)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
                  Text(filename, style: const TextStyle(fontSize: 11, color: textMuted)),
                ],
              ),
            ),
          ],
        );

        final btn = OutlinedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Downloading verified document: $filename'), backgroundColor: color),
            );
          },
          icon: const Icon(Icons.download_rounded, size: 14),
          label: const Text('Download PDF', style: TextStyle(fontSize: 11)),
          style: OutlinedButton.styleFrom(foregroundColor: color, side: BorderSide(color: color)),
        );

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(14), border: Border.all(color: cardBorder)),
          child: isNarrow
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    infoRow,
                    const SizedBox(height: 8),
                    btn,
                  ],
                )
              : Row(
                  children: [
                    Expanded(child: infoRow),
                    const SizedBox(width: 12),
                    btn,
                  ],
                ),
        );
      },
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // TAB 8: TELEMATICS & CARRIER HARDWARE SETTINGS
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildSettingsTab(AgriLogisticsState state) {
    final profile = state.carrierProfile;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildModuleBanner(
            icon: Icons.settings_outlined,
            color: amber,
            title: 'Carrier Telematics Hardware & Platform Settings',
            subtitle: 'Configure in-cab IoT sensors, calibrate cold-chain thresholds, managing operating corridors and escrow payout bank accounts.',
            trailing: ElevatedButton.icon(
              onPressed: () => ref.read(appStateProvider.notifier).setNavIndex(21),
              icon: const Icon(Icons.open_in_new, size: 13),
              label: const Text('Open System Settings', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(backgroundColor: amber, foregroundColor: bgDark),
            ),
          ),
          const SizedBox(height: 16),

          Text('In-Cab Hardware & Sensor Pairing', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(16), border: Border.all(color: cardBorder)),
            child: Column(
              children: [
                _buildSettingRow('OBD-II Telematics Gateway (AEB-2910)', 'PAIRED & ONLINE (4G LTE)', green, Icons.sensors),
                const Divider(color: cardBorder, height: 24),
                _buildSettingRow('Reefer Temperature Probe #1', 'CALIBRATED (+3.4°C)', cyan, Icons.thermostat),
                const Divider(color: cardBorder, height: 24),
                _buildSettingRow('SADC Corridor Transit Permit', profile.eudrPermitCode, amber, Icons.verified),
                const Divider(color: cardBorder, height: 24),
                _buildSettingRow('Carrier Escrow Payout Wallet', 'EcoCash USD • +263 77 902 1140', green, Icons.account_balance_wallet_outlined),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingRow(String title, String value, Color color, IconData icon) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 460;
        final badge = Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(6), border: Border.all(color: color.withOpacity(0.4))),
          child: Text(value, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
        );

        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              badge,
            ],
          );
        }

        return Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
            ),
            badge,
          ],
        );
      },
    );
  }

  void _showRegisterTruckModal(BuildContext context) {
    final plateCtrl = TextEditingController();
    final modelCtrl = TextEditingController();
    final capacityCtrl = TextEditingController();
    final driverCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final permitCtrl = TextEditingController();
    final trackerCtrl = TextEditingController();
    VehicleType selectedType = VehicleType.reeferContainer;
    bool hasColdChain = true;

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: cardDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: cardBorder),
              ),
              title: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: amber.withOpacity(0.15),
                    child: const Icon(Icons.local_shipping_rounded, color: amber, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Register New Fleet Asset',
                          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const Text(
                          'Enroll vehicle into live carrier dispatch & GPS radar grid',
                          style: TextStyle(fontSize: 11, color: textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 520,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Vehicle Classification
                      const Text('Vehicle Classification', style: TextStyle(color: textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<VehicleType>(
                        value: selectedType,
                        dropdownColor: cardDark,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        items: VehicleType.values.map((v) => DropdownMenuItem(value: v, child: Text(v.label))).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setModalState(() {
                              selectedType = val;
                              if (val == VehicleType.reeferContainer) hasColdChain = true;
                            });
                          }
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFF060B14),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: cardBorder)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: cardBorder)),
                        ),
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: _field('Registration Plate', plateCtrl, hint: 'e.g. AFG-8921'),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _field('Payload Capacity (kg)', capacityCtrl, hint: 'e.g. 30000'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      _field('Vehicle Make & Model', modelCtrl, hint: 'e.g. Volvo FH16 540 Globetrotter'),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: _field('Assigned Driver Name', driverCtrl, hint: 'e.g. Tendai Chikore'),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _field('Driver Phone', phoneCtrl, hint: 'e.g. +263 77 412 8890'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: _field('SADC Transit Permit #', permitCtrl, hint: 'e.g. SADC-ZIM-2026-992'),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _field('IoT GPS Tracker IMEI', trackerCtrl, hint: 'e.g. IOT-GPS-8842'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Cold-Chain Switch
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF060B14),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: hasColdChain ? cyan.withOpacity(0.4) : cardBorder),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.ac_unit, color: hasColdChain ? cyan : textMuted, size: 18),
                                const SizedBox(width: 8),
                                const Text('Cold-Chain Telemetry Enabled', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                              ],
                            ),
                            Switch(
                              value: hasColdChain,
                              activeColor: cyan,
                              onChanged: (v) => setModalState(() => hasColdChain = v),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: const Text('Cancel', style: TextStyle(color: textMuted)),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    final plate = plateCtrl.text.trim().isEmpty ? 'AFG-8921' : plateCtrl.text.trim();
                    final model = modelCtrl.text.trim().isEmpty ? 'Volvo FH16 540' : modelCtrl.text.trim();
                    final driver = driverCtrl.text.trim().isEmpty ? 'Assigned Fleet Driver' : driverCtrl.text.trim();
                    final cap = double.tryParse(capacityCtrl.text.trim()) ?? 30000.0;
                    final permit = permitCtrl.text.trim().isEmpty ? 'SADC-ZIM-2026-992' : permitCtrl.text.trim();

                    // Register to trucksListProvider
                    final newTruck = TruckItem(
                      id: 'truck-${DateTime.now().millisecondsSinceEpoch % 10000}',
                      driver: driver,
                      vehicle: '${selectedType.label} (${(cap / 1000).toStringAsFixed(1)}T)',
                      plateNumber: plate,
                      regNumber: permit,
                      color: 'Fleet White',
                      model: model,
                      from: 'Live Dispatch Corridor',
                      eta: 'Available Now',
                      costPerKm: 0.35,
                      rating: 5.0,
                      status: 'Ready for dispatch',
                    );
                    ref.read(trucksListProvider.notifier).addTruck(newTruck);

                    // Update carrier vehicle profile
                    final newVehicle = AgriVehicle(
                      id: 'VEH-${DateTime.now().millisecondsSinceEpoch % 1000}',
                      ownerId: 'CAR-01',
                      registrationNumber: plate,
                      type: selectedType,
                      tierCapability: LogisticsTier.longDistance,
                      maxWeightCapacityKg: cap,
                      hasColdChain: hasColdChain,
                      model: model,
                    );
                    final curProfile = ref.read(agriLogisticsProvider).carrierProfile;
                    ref.read(agriLogisticsProvider.notifier).updateCarrierProfile(
                          curProfile.copyWith(vehicle: newVehicle),
                        );

                    Navigator.pop(dialogCtx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.white, size: 20),
                            const SizedBox(width: 10),
                            Expanded(child: Text('Fleet Vehicle $plate ($model) registered into active grid! 🚚')),
                          ],
                        ),
                        backgroundColor: green,
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_task, size: 16),
                  label: const Text('Register Truck', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: amber,
                    foregroundColor: bgDark,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _LiveCorridorGpsMapWidget extends StatefulWidget {
  final AgriLogisticsState state;
  const _LiveCorridorGpsMapWidget({required this.state});

  @override
  State<_LiveCorridorGpsMapWidget> createState() => _LiveCorridorGpsMapWidgetState();
}

class _LiveCorridorGpsMapWidgetState extends State<_LiveCorridorGpsMapWidget> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  bool _isPlaying = true;
  double _zoomLevel = 1.0;
  bool _satelliteMode = false;

  final List<Map<String, dynamic>> _waypoints = [
    {'name': 'Harare Freight Depot', 'coord': 'Lat -17.8252, Lng 31.0335', 'eta': 'Departed 05:30 AM', 'passed': true, 'progress': 0.0},
    {'name': 'Beatrice Toll Plaza', 'coord': 'Lat -18.2520, Lng 30.8750', 'eta': 'Cleared Inspection', 'passed': true, 'progress': 0.22},
    {'name': 'Mvuma Weighbridge & Hub', 'coord': 'Lat -19.2811, Lng 30.5319', 'eta': 'In-Transit (Current GPS)', 'active': true, 'progress': 0.52},
    {'name': 'Masvingo Grain Depot', 'coord': 'Lat -20.0744, Lng 30.8328', 'eta': 'ETA: 14:15 (On Schedule)', 'progress': 0.74},
    {'name': 'Beitbridge SADC Gateway', 'coord': 'Lat -22.2167, Lng 30.0000', 'eta': 'ETA: 18:30 (Cross-Border)', 'progress': 1.0},
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const bgDark = Color(0xFF060B14);
    const cardDark = Color(0xFF0D1626);
    const cardBorder = Color(0xFF1E293B);
    const amber = Color(0xFFFF9F1C);
    const cyan = Color(0xFF00F0FF);
    const green = Color(0xFF10B981);
    const textMuted = Color(0xFF94A3B8);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Live Map Radar Canvas Container
          Container(
            height: 380,
            width: double.infinity,
            decoration: BoxDecoration(
              color: _satelliteMode ? const Color(0xFF071018) : bgDark,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: cyan.withOpacity(0.4), width: 1.5),
              boxShadow: [
                BoxShadow(color: cyan.withOpacity(0.08), blurRadius: 20, spreadRadius: 2),
              ],
            ),
            child: Stack(
              children: [
                // Animated Custom Map Painter
                AnimatedBuilder(
                  animation: _animController,
                  builder: (context, child) {
                    final t = _isPlaying ? _animController.value : 0.52;
                    return CustomPaint(
                      size: Size.infinite,
                      painter: _TransitCorridorPainter(
                        animationValue: t,
                        satelliteMode: _satelliteMode,
                        zoom: _zoomLevel,
                      ),
                    );
                  },
                ),

                // Top GPS HUD Bar
                Positioned(
                  top: 14,
                  left: 14,
                  right: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: cardDark.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: cardBorder),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.satellite_alt_rounded, color: cyan, size: 18),
                        const SizedBox(width: 8),
                        AnimatedBuilder(
                          animation: _animController,
                          builder: (context, _) {
                            final lat = -18.2520 - (_animController.value * 2.2);
                            final lng = 30.8750 - (_animController.value * 0.4);
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'A5 SADC Transit Corridor • Live GPS Stream',
                                  style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                                Text(
                                  'Coords: [${lat.toStringAsFixed(4)}° S, ${lng.toStringAsFixed(4)}° E] • 18 Sats (RTK Fixed 0.3m)',
                                  style: const TextStyle(color: cyan, fontSize: 10.5, fontFamily: 'monospace'),
                                ),
                              ],
                            );
                          },
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: green.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: green),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(backgroundColor: green, radius: 3),
                              SizedBox(width: 5),
                              Text('GPS ACTIVE', style: TextStyle(color: green, fontSize: 9.5, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom Floating Telemetry Overlay
                Positioned(
                  bottom: 14,
                  left: 14,
                  right: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: cardDark.withOpacity(0.92),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: cyan.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _hudStat(Icons.speed, 'SPEED', '${widget.state.liveSpeedKmh.toStringAsFixed(1)} km/h', amber),
                        _hudDivider(),
                        _hudStat(Icons.ac_unit, 'REEFER TEMP', '+${widget.state.liveReeferTemp.toStringAsFixed(1)} °C', cyan),
                        _hudDivider(),
                        _hudStat(Icons.navigation_outlined, 'BEARING', '142° SE', Colors.white),
                        _hudDivider(),
                        _hudStat(Icons.local_gas_station_outlined, 'FUEL', '84% (420L)', green),
                        _hudDivider(),
                        _hudStat(Icons.timer_outlined, 'REMAINING', '238 km (3h 18m)', Colors.white),
                      ],
                    ),
                  ),
                ),

                // Interactive Controls (Right Side)
                Positioned(
                  right: 14,
                  top: 72,
                  child: Column(
                    children: [
                      _mapBtn(
                        icon: _isPlaying ? Icons.pause_circle_outline : Icons.play_circle_outline,
                        tooltip: 'Play/Pause GPS Simulator',
                        color: amber,
                        onTap: () => setState(() => _isPlaying = !_isPlaying),
                      ),
                      const SizedBox(height: 8),
                      _mapBtn(
                        icon: _satelliteMode ? Icons.map_outlined : Icons.satellite_outlined,
                        tooltip: 'Toggle Satellite/Radar HUD Mode',
                        color: cyan,
                        onTap: () => setState(() => _satelliteMode = !_satelliteMode),
                      ),
                      const SizedBox(height: 8),
                      _mapBtn(
                        icon: Icons.zoom_in,
                        tooltip: 'Zoom In',
                        color: Colors.white,
                        onTap: () => setState(() => _zoomLevel = (_zoomLevel + 0.2).clamp(0.8, 1.8)),
                      ),
                      const SizedBox(height: 8),
                      _mapBtn(
                        icon: Icons.zoom_out,
                        tooltip: 'Zoom Out',
                        color: Colors.white,
                        onTap: () => setState(() => _zoomLevel = (_zoomLevel - 0.2).clamp(0.8, 1.8)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Corridor Waypoint Pipeline Tracker
          Text('Corridor Waypoints & Cargo Seal Status', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          const Text('Live electronic seal (e-Seal) and GPS telemetry checkpoints along the transport route.', style: TextStyle(fontSize: 11.5, color: textMuted)),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(16), border: Border.all(color: cardBorder)),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _waypoints.length,
              separatorBuilder: (_, __) => const Divider(color: cardBorder, height: 20),
              itemBuilder: (context, idx) {
                final wp = _waypoints[idx];
                final isPassed = wp['passed'] == true;
                final isActive = wp['active'] == true;

                return Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: isPassed ? green.withOpacity(0.18) : (isActive ? amber.withOpacity(0.2) : bgDark),
                      child: Icon(
                        isPassed ? Icons.check_circle : (isActive ? Icons.navigation_rounded : Icons.radio_button_unchecked),
                        size: 16,
                        color: isPassed ? green : (isActive ? amber : textMuted),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(wp['name'], style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                          Text(wp['coord'], style: const TextStyle(fontSize: 10.5, color: textMuted, fontFamily: 'monospace')),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isPassed ? green.withOpacity(0.12) : (isActive ? amber.withOpacity(0.15) : bgDark),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: isPassed ? green.withOpacity(0.4) : (isActive ? amber : cardBorder)),
                      ),
                      child: Text(
                        wp['eta'],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isPassed ? green : (isActive ? amber : textMuted),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _hudStat(IconData icon, String label, String value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 9, color: Color(0xFF94A3B8), fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 2),
        Text(value, style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.white)),
      ],
    );
  }

  Widget _hudDivider() => Container(height: 24, width: 1, color: const Color(0xFF1E293B));

  Widget _mapBtn({required IconData icon, required String tooltip, required Color color, required VoidCallback onTap}) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF0D1626).withOpacity(0.85),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF1E293B)),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
      ),
    );
  }
}

class _TransitCorridorPainter extends CustomPainter {
  final double animationValue;
  final bool satelliteMode;
  final double zoom;

  _TransitCorridorPainter({
    required this.animationValue,
    required this.satelliteMode,
    required this.zoom,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = satelliteMode ? const Color(0xFF102A45).withOpacity(0.3) : const Color(0xFF1E293B).withOpacity(0.35)
      ..strokeWidth = 1.0;

    // Draw Radar/GIS Grid
    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Corridor Points across canvas
    final points = [
      Offset(size.width * 0.12, size.height * 0.35),
      Offset(size.width * 0.28, size.height * 0.42),
      Offset(size.width * 0.46, size.height * 0.55),
      Offset(size.width * 0.68, size.height * 0.65),
      Offset(size.width * 0.88, size.height * 0.78),
    ];

    // Draw Glow Background Corridor Polyline
    final glowPaint = Paint()
      ..color = const Color(0xFF00F0FF).withOpacity(0.25)
      ..strokeWidth = 8.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final roadPaint = Paint()
      ..color = const Color(0xFF00F0FF)
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, roadPaint);

    // Draw Waypoint nodes
    final nodePaint = Paint()..color = const Color(0xFFFF9F1C);
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    final nodeLabels = ['Harare', 'Beatrice', 'Mvuma Hub', 'Masvingo', 'Beitbridge'];
    for (int i = 0; i < points.length; i++) {
      canvas.drawCircle(points[i], 5.0, nodePaint);
      canvas.drawCircle(points[i], 8.0, Paint()..color = const Color(0xFFFF9F1C).withOpacity(0.3)..style = PaintingStyle.stroke..strokeWidth = 2);

      textPainter.text = TextSpan(
        text: nodeLabels[i],
        style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.bold),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(points[i].dx - (textPainter.width / 2), points[i].dy - 18));
    }

    // Calculate current truck position along polyline based on animationValue
    final totalSegments = points.length - 1;
    final segFloat = animationValue * totalSegments;
    final segIdx = segFloat.floor().clamp(0, totalSegments - 1);
    final segFraction = (segFloat - segIdx).clamp(0.0, 1.0);

    final currentPos = Offset(
      points[segIdx].dx + (points[segIdx + 1].dx - points[segIdx].dx) * segFraction,
      points[segIdx].dy + (points[segIdx + 1].dy - points[segIdx].dy) * segFraction,
    );

    // Pulse Ring around vehicle
    canvas.drawCircle(
      currentPos,
      18.0 + (animationValue * 10),
      Paint()..color = const Color(0xFFFF9F1C).withOpacity((1.0 - animationValue).clamp(0.0, 0.6))..style = PaintingStyle.stroke..strokeWidth = 2,
    );

    // Vehicle Core Marker
    canvas.drawCircle(currentPos, 10.0, Paint()..color = const Color(0xFFFF9F1C));
    canvas.drawCircle(currentPos, 4.0, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _TransitCorridorPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue ||
      oldDelegate.satelliteMode != satelliteMode ||
      oldDelegate.zoom != zoom;
}
