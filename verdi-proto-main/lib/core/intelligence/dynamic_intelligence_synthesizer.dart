import 'package:flutter/material.dart';
import '../../state/app_state.dart';
import '../../core/enums/verdi_screen.dart';
import '../../state/platform_data_state.dart';

class AiInsightItem {
  final String title;
  final String subtitle;
  final String action;
  final String imageUrl;
  final Color color;
  final double confidence;
  final VerdiScreen targetScreen;
  final String category; // 'Agronomic', 'Logistics', 'Financial', 'Market', 'Security', 'Health'
  final String severity; // 'Critical', 'High', 'Moderate', 'Informational'
  final Map<String, dynamic>? telemetryContext;

  const AiInsightItem({
    required this.title,
    required this.subtitle,
    required this.action,
    required this.imageUrl,
    required this.color,
    required this.confidence,
    required this.targetScreen,
    this.category = 'Informational',
    this.severity = 'Moderate',
    this.telemetryContext,
  });
}

class DynamicIntelligenceSynthesizer {
  static const green = Color(0xFF16A34A);
  static const orange = Color(0xFFF97316);
  static const blue = Color(0xFF2563EB);
  static const purple = Color(0xFF7C3AED);
  static const teal = Color(0xFF0F766E);
  static const red = Color(0xFFDC2626);

  /// Synthesizes role-tailored intelligence derived from active platform state.
  static List<AiInsightItem> synthesizeInsights({
    required UserRole role,
    BuyerSubRole buyerSubRole = BuyerSubRole.retailerWholesaler,
    required bool isDemo,
    required List<OrderItem> orders,
    required List<TruckItem> trucks,
    required List<PaymentItem> payments,
    int onlineUsersCount = 1,
    double platformHealthPercent = 100.0,
  }) {
    switch (role) {
      case UserRole.admin:
        return _synthesizeAdminInsights(orders, trucks, payments, onlineUsersCount, platformHealthPercent, isDemo);
      case UserRole.farmer:
        return _synthesizeFarmerInsights(orders, isDemo);
      case UserRole.transporter:
        return _synthesizeTransporterInsights(trucks, orders, isDemo);
      case UserRole.buyer:
        return buyerSubRole == BuyerSubRole.endUserCustomer
            ? _synthesizeConsumerInsights(orders, isDemo)
            : _synthesizeBuyerInsights(orders, isDemo);
      case UserRole.financier:
        return _synthesizeFinancierInsights(payments, isDemo);
      case UserRole.government:
        return _synthesizeGovernmentInsights(orders, isDemo);
      case UserRole.valueAdder:
        return _synthesizeValueAdderInsights(orders, isDemo);
      case UserRole.expert:
        return _synthesizeExpertInsights(isDemo);
      case UserRole.consumer:
        return _synthesizeConsumerInsights(orders, isDemo);
    }
  }

  // ───────────────────────────────────────────────────────────────────────────
  // SUPER ADMIN LIVE SURVEILLANCE & SYSTEM HEALTH INSIGHTS
  // ───────────────────────────────────────────────────────────────────────────
  static List<AiInsightItem> _synthesizeAdminInsights(
    List<OrderItem> orders,
    List<TruckItem> trucks,
    List<PaymentItem> payments,
    int onlineUsersCount,
    double platformHealthPercent,
    bool isDemo,
  ) {
    final activeOrdersCount = orders.where((o) => o.status != 'Delivered' && o.status != 'Cancelled').length;
    final activeTrucksCount = trucks.where((t) => t.status != 'Offline').length;
    final double totalTradeGmv = orders.fold(0.0, (sum, o) {
      final val = double.tryParse(o.total.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
      return sum + val;
    });

    if (!isDemo) {
      return [
        AiInsightItem(
          title: '$onlineUsersCount Live Active User Session${onlineUsersCount > 1 ? 's' : ''}',
          subtitle: 'Real-time multi-role surveillance active. Platform audit bus streaming live.',
          action: 'Audit Log',
          imageUrl: 'https://images.unsplash.com/photo-1558494949-ef010cbdcc31?auto=format&fit=crop&w=1200&q=80',
          color: purple,
          confidence: 0.99,
          targetScreen: VerdiScreen.adminActivity,
          category: 'Security',
          severity: 'Moderate',
        ),
        AiInsightItem(
          title: 'Infrastructure Health at ${platformHealthPercent.toStringAsFixed(1)}%',
          subtitle: 'All 8 distributed API microservices, Sentinel geospatial server, and gateway operational.',
          action: 'System Health',
          imageUrl: 'https://images.unsplash.com/photo-1518770660439-4636190af475?auto=format&fit=crop&w=1200&q=80',
          color: green,
          confidence: 1.0,
          targetScreen: VerdiScreen.adminHealth,
          category: 'Health',
          severity: 'Moderate',
        ),
        AiInsightItem(
          title: '$activeOrdersCount Live Trade Orders (GMV: \$${totalTradeGmv.toStringAsFixed(2)})',
          subtitle: activeOrdersCount > 0
              ? 'Real-time marketplace trade liquidity and escrow settlements.'
              : 'Marketplace pipeline ready. Trade orders will stream here when placed by buyers.',
          action: 'Inspect Trade',
          imageUrl: 'https://images.unsplash.com/photo-1526304640581-d334cdbbf45e?auto=format&fit=crop&w=1200&q=80',
          color: blue,
          confidence: 0.95,
          targetScreen: VerdiScreen.admin,
          category: 'Market',
          severity: 'Moderate',
        ),
        AiInsightItem(
          title: '$activeTrucksCount Registered Freight Trucks Active',
          subtitle: activeTrucksCount > 0
              ? 'Transporter GPS telemetry and cold-chain sensor streams active.'
              : 'Fleet telemetry ready. Transporters registering vehicles will appear in live tracking.',
          action: 'Fleet Telemetry',
          imageUrl: 'https://images.unsplash.com/photo-1601584115197-04ecc0da31d7?auto=format&fit=crop&w=1200&q=80',
          color: orange,
          confidence: 0.92,
          targetScreen: VerdiScreen.logistics,
          category: 'Logistics',
          severity: 'Moderate',
        ),
      ];
    }

    // Demo Mode Sandbox Insights
    return [
      AiInsightItem(
        title: '$onlineUsersCount Active Nodes & Real-Time Surveillance',
        subtitle: 'Multi-role users active across Harare, Mazowe, and Chiredzi. Mesh latency 24ms.',
        action: 'View User Logs',
        imageUrl: 'https://images.unsplash.com/photo-1558494949-ef010cbdcc31?auto=format&fit=crop&w=1200&q=80',
        color: purple,
        confidence: 0.98,
        targetScreen: VerdiScreen.adminActivity,
        category: 'Security',
        severity: 'Moderate',
      ),
      AiInsightItem(
        title: 'Platform Infrastructure Health at ${platformHealthPercent.toStringAsFixed(1)}%',
        subtitle: 'All 8 distributed API microservices, Sentinel geospatial server, and payment gateway operational.',
        action: 'System Health',
        imageUrl: 'https://images.unsplash.com/photo-1518770660439-4636190af475?auto=format&fit=crop&w=1200&q=80',
        color: green,
        confidence: 0.99,
        targetScreen: VerdiScreen.adminHealth,
        category: 'Health',
        severity: 'Moderate',
      ),
      AiInsightItem(
        title: '$activeOrdersCount Live Trade Orders (GMV: \$${totalTradeGmv > 0 ? totalTradeGmv.toStringAsFixed(0) : "1,420"})',
        subtitle: 'Active cross-stakeholder trade liquidity. Escrow release SLAs meeting 99.2% target.',
        action: 'Inspect Trade',
        imageUrl: 'https://images.unsplash.com/photo-1526304640581-d334cdbbf45e?auto=format&fit=crop&w=1200&q=80',
        color: blue,
        confidence: 0.94,
        targetScreen: VerdiScreen.admin,
        category: 'Market',
        severity: 'Moderate',
      ),
      AiInsightItem(
        title: '$activeTrucksCount Freight Fleet Dispatches Active',
        subtitle: 'SADC corridor cross-border clearance and domestic transit cold-chain at nominal +3.2°C.',
        action: 'Fleet Telemetry',
        imageUrl: 'https://images.unsplash.com/photo-1601584115197-04ecc0da31d7?auto=format&fit=crop&w=1200&q=80',
        color: orange,
        confidence: 0.92,
        targetScreen: VerdiScreen.logistics,
        category: 'Logistics',
        severity: 'Moderate',
      ),
    ];
  }

  // ───────────────────────────────────────────────────────────────────────────
  // FARMER INTELLIGENCE
  // ───────────────────────────────────────────────────────────────────────────
  static List<AiInsightItem> _synthesizeFarmerInsights(List<OrderItem> orders, bool isDemo) {
    if (!isDemo) {
      return [
        const AiInsightItem(
          title: 'Smart Irrigation Ready for Activation',
          subtitle: 'Connect field sensors or log manual soil moisture reading to start automated watering.',
          action: 'Open Irrigation',
          imageUrl: 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?auto=format&fit=crop&w=1200&q=80',
          color: orange,
          confidence: 0.95,
          targetScreen: VerdiScreen.irrigation,
          category: 'Agronomic',
          severity: 'Moderate',
        ),
        const AiInsightItem(
          title: 'Live Marketplace Ready: List Harvest Batch',
          subtitle: 'Create a listing for your fresh crops to connect directly with wholesale buyers.',
          action: 'List Produce',
          imageUrl: 'https://images.unsplash.com/photo-1546470427-227c2e6b1b4c?auto=format&fit=crop&w=1200&q=80',
          color: green,
          confidence: 0.92,
          targetScreen: VerdiScreen.marketplace,
          category: 'Market',
          severity: 'Moderate',
        ),
        const AiInsightItem(
          title: 'Geospatial Field Mapping Online',
          subtitle: 'Draw your farm boundary on the satellite map to initialize Sentinel-2 NDVI monitoring.',
          action: 'Map Field',
          imageUrl: 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?auto=format&fit=crop&w=1200&q=80',
          color: blue,
          confidence: 0.97,
          targetScreen: VerdiScreen.geospatial,
          category: 'Agronomic',
          severity: 'Moderate',
        ),
      ];
    }

    return [
      const AiInsightItem(
        title: 'High Moisture Deficit Detected in Zone 2',
        subtitle: 'Soil moisture at 24% (nominal >40%). Recommend 12mm smart drip irrigation by 14:00.',
        action: 'Activate Drip',
        imageUrl: 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?auto=format&fit=crop&w=1200&q=80',
        color: orange,
        confidence: 0.93,
        targetScreen: VerdiScreen.irrigation,
        category: 'Agronomic',
        severity: 'High',
      ),
      const AiInsightItem(
        title: 'Tomato Spot Price Surging +14% at Mbare',
        subtitle: 'Current market clearing rate: \$1.54/kg. List available harvest batches now to capture peak.',
        action: 'List Produce',
        imageUrl: 'https://images.unsplash.com/photo-1546470427-227c2e6b1b4c?auto=format&fit=crop&w=1200&q=80',
        color: green,
        confidence: 0.91,
        targetScreen: VerdiScreen.marketplace,
        category: 'Market',
        severity: 'Moderate',
      ),
      const AiInsightItem(
        title: 'Sentinel-2 Satellite Pass Synchronized (NDVI 0.78)',
        subtitle: 'Vegetative biomass healthy across 82% of farm sectors. 1 hotspot flagged in East Plot.',
        action: 'View Map',
        imageUrl: 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?auto=format&fit=crop&w=1200&q=80',
        color: blue,
        confidence: 0.96,
        targetScreen: VerdiScreen.geospatial,
        category: 'Agronomic',
        severity: 'Moderate',
      ),
      const AiInsightItem(
        title: 'Agro-Meteorology Radar: 85% Rain Probability',
        subtitle: 'Moderate showers forecast in 24 hours. Suggest delaying scheduled foliar spray application.',
        action: 'Check Weather',
        imageUrl: 'https://images.unsplash.com/photo-1503435824048-a799a3a84bf4?auto=format&fit=crop&w=1200&q=80',
        color: teal,
        confidence: 0.88,
        targetScreen: VerdiScreen.weather,
        category: 'Agronomic',
        severity: 'Moderate',
      ),
    ];
  }

  // ───────────────────────────────────────────────────────────────────────────
  // TRANSPORTER INTELLIGENCE
  // ───────────────────────────────────────────────────────────────────────────
  static List<AiInsightItem> _synthesizeTransporterInsights(
    List<TruckItem> trucks,
    List<OrderItem> orders,
    bool isDemo,
  ) {
    if (!isDemo) {
      return [
        const AiInsightItem(
          title: 'Register Vehicle to Receive Haulage Bids',
          subtitle: 'Add your cargo truck, flatbed, or refrigerated van to unlock regional freight dispatches.',
          action: 'Add Vehicle',
          imageUrl: 'https://images.unsplash.com/photo-1601584115197-04ecc0da31d7?auto=format&fit=crop&w=1200&q=80',
          color: green,
          confidence: 0.95,
          targetScreen: VerdiScreen.logistics,
          category: 'Logistics',
          severity: 'Moderate',
        ),
        const AiInsightItem(
          title: 'In-Cab GPS Telemetry Hub Ready',
          subtitle: 'Stream live location coordinates and reefer temperature for smart contract escrow release.',
          action: 'Open Telemetry',
          imageUrl: 'https://images.unsplash.com/photo-1586771107445-d3ca888129ff?auto=format&fit=crop&w=1200&q=80',
          color: blue,
          confidence: 0.98,
          targetScreen: VerdiScreen.logistics,
          category: 'Logistics',
          severity: 'Moderate',
        ),
      ];
    }

    return [
      const AiInsightItem(
        title: '3 Cargo Haulage Bids Active Near Chiredzi',
        subtitle: '12-tonne tomato & sugar cane dispatch requests. Estimated payout: \$420–\$850.',
        action: 'Accept Haulage',
        imageUrl: 'https://images.unsplash.com/photo-1601584115197-04ecc0da31d7?auto=format&fit=crop&w=1200&q=80',
        color: green,
        confidence: 0.92,
        targetScreen: VerdiScreen.logistics,
        category: 'Logistics',
        severity: 'Moderate',
      ),
      const AiInsightItem(
        title: 'Beitbridge Corridor Clearance: 18m Average',
        subtitle: 'Fast-track digital pre-clearance online. Southern SADC transit delays minimal today.',
        action: 'View Route',
        imageUrl: 'https://images.unsplash.com/photo-1508444845599-5c89863b1c44?auto=format&fit=crop&w=1200&q=80',
        color: blue,
        confidence: 0.89,
        targetScreen: VerdiScreen.logistics,
        category: 'Logistics',
        severity: 'Moderate',
      ),
      const AiInsightItem(
        title: 'Cold-Chain Reefer Sensor Audit: 100% SLA',
        subtitle: 'Active refrigerated cargo maintained at steady +3.2°C. Proof of Quality token minted.',
        action: 'Check Telemetry',
        imageUrl: 'https://images.unsplash.com/photo-1586771107445-d3ca888129ff?auto=format&fit=crop&w=1200&q=80',
        color: teal,
        confidence: 0.95,
        targetScreen: VerdiScreen.traceability,
        category: 'Logistics',
        severity: 'Moderate',
      ),
    ];
  }

  // ───────────────────────────────────────────────────────────────────────────
  // BUYER & CONSUMER INTELLIGENCE
  // ───────────────────────────────────────────────────────────────────────────
  static List<AiInsightItem> _synthesizeBuyerInsights(List<OrderItem> orders, bool isDemo) {
    if (!isDemo) {
      return [
        const AiInsightItem(
          title: 'Direct Farmgate Marketplace Active',
          subtitle: 'Search fresh harvest batches verified with digital phytosanitary inspection.',
          action: 'Browse Produce',
          imageUrl: 'https://images.unsplash.com/photo-1546470427-227c2e6b1b4c?auto=format&fit=crop&w=1200&q=80',
          color: green,
          confidence: 0.96,
          targetScreen: VerdiScreen.marketplace,
          category: 'Market',
          severity: 'Moderate',
        ),
        const AiInsightItem(
          title: 'EUDR Compliance Verification Engine',
          subtitle: 'Verify farm polygon deforestation-free compliance before locking escrow.',
          action: 'Audit Origin',
          imageUrl: 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?auto=format&fit=crop&w=1200&q=80',
          color: blue,
          confidence: 0.98,
          targetScreen: VerdiScreen.traceability,
          category: 'Market',
          severity: 'Moderate',
        ),
      ];
    }

    return [
      const AiInsightItem(
        title: '45 Tonnes Certified White Maize Listed in Mazowe',
        subtitle: 'Direct farmgate pricing at \$275/Ton with verified phytosanitary grading.',
        action: 'Review Batch',
        imageUrl: 'https://images.unsplash.com/photo-1546470427-227c2e6b1b4c?auto=format&fit=crop&w=1200&q=80',
        color: green,
        confidence: 0.94,
        targetScreen: VerdiScreen.marketplace,
        category: 'Market',
        severity: 'Moderate',
      ),
      const AiInsightItem(
        title: 'EUDR Traceability Verified: 100% Polygon Mapped',
        subtitle: 'Upcoming citrus batches comply with EU Deforestation-Free Regulation requirements.',
        action: 'Verify Origin',
        imageUrl: 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?auto=format&fit=crop&w=1200&q=80',
        color: blue,
        confidence: 0.97,
        targetScreen: VerdiScreen.traceability,
        category: 'Market',
        severity: 'Moderate',
      ),
    ];
  }

  // ───────────────────────────────────────────────────────────────────────────
  // FINANCIER & INSTITUTIONAL TREASURY INSIGHTS
  // ───────────────────────────────────────────────────────────────────────────
  static List<AiInsightItem> _synthesizeFinancierInsights(List<PaymentItem> payments, bool isDemo) {
    if (!isDemo) {
      return [
        const AiInsightItem(
          title: 'Agri-Credit Underwriting Portal Active',
          subtitle: 'Review smallholder credit requests verified with satellite NDVI vegetative health data.',
          action: 'Credit Desk',
          imageUrl: 'https://images.unsplash.com/photo-1526304640581-d334cdbbf45e?auto=format&fit=crop&w=1200&q=80',
          color: green,
          confidence: 0.97,
          targetScreen: VerdiScreen.finance,
          category: 'Financial',
          severity: 'Moderate',
        ),
      ];
    }

    return [
      const AiInsightItem(
        title: 'Agri-Credit Portfolio Health: 96.8% Repayment Rate',
        subtitle: 'Automated escrow deduction from marketplace harvest sales maintaining low default rate.',
        action: 'Treasury Hub',
        imageUrl: 'https://images.unsplash.com/photo-1526304640581-d334cdbbf45e?auto=format&fit=crop&w=1200&q=80',
        color: green,
        confidence: 0.96,
        targetScreen: VerdiScreen.finance,
        category: 'Financial',
        severity: 'Moderate',
      ),
    ];
  }

  // ───────────────────────────────────────────────────────────────────────────
  // GOVERNMENT & VALUE ADDER & EXPERT INSIGHTS
  // ───────────────────────────────────────────────────────────────────────────
  static List<AiInsightItem> _synthesizeGovernmentInsights(List<OrderItem> orders, bool isDemo) {
    return [
      const AiInsightItem(
        title: 'National Strategic Grain Reserve Tracking',
        subtitle: 'Monitoring regional crop yields and trade volume buffer for national food security.',
        action: 'National Security',
        imageUrl: 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?auto=format&fit=crop&w=1200&q=80',
        color: green,
        confidence: 0.96,
        targetScreen: VerdiScreen.analytics,
        category: 'Agronomic',
        severity: 'Moderate',
      ),
    ];
  }

  static List<AiInsightItem> _synthesizeValueAdderInsights(List<OrderItem> orders, bool isDemo) {
    return [
      const AiInsightItem(
        title: 'Raw Crop Processing Intake Weighbridge',
        subtitle: 'Log raw intake moisture grade and processing yield on active mill lines.',
        action: 'Log Intake',
        imageUrl: 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?auto=format&fit=crop&w=1200&q=80',
        color: green,
        confidence: 0.94,
        targetScreen: VerdiScreen.processing,
        category: 'Agronomic',
        severity: 'Moderate',
      ),
    ];
  }

  static List<AiInsightItem> _synthesizeConsumerInsights(List<OrderItem> orders, bool isDemo) {
    return [
      const AiInsightItem(
        title: 'Fresh Produce Price Drop: -18% on Fresh Tomatoes',
        subtitle: 'Peak harvest volume from Mashonaland West outgrowers is creating prime buying opportunities today.',
        action: 'Shop Produce',
        imageUrl: 'https://images.unsplash.com/photo-1546470427-227c2e6b1b4c?auto=format&fit=crop&w=1200&q=80',
        color: green,
        confidence: 0.97,
        targetScreen: VerdiScreen.marketplace,
        category: 'Market',
        severity: 'Moderate',
      ),
      const AiInsightItem(
        title: 'Avocado Freshness & Ripeness Optimal Window',
        subtitle: 'Chipinge Hass avocados currently in store are tree-ripened with 6-8 days optimum kitchen shelf-life.',
        action: 'View Produce',
        imageUrl: 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?auto=format&fit=crop&w=1200&q=80',
        color: teal,
        confidence: 0.94,
        targetScreen: VerdiScreen.marketplace,
        category: 'Market',
        severity: 'Moderate',
      ),
      const AiInsightItem(
        title: 'InDrive Farmgate Shared Route Delivery Active',
        subtitle: 'Combine your delivery with nearby orders in your suburb to unlock discounted zero-middleman transit.',
        action: 'Track InDrive',
        imageUrl: 'https://images.unsplash.com/photo-1601584115197-04ecc0da31d7?auto=format&fit=crop&w=1200&q=80',
        color: blue,
        confidence: 0.96,
        targetScreen: VerdiScreen.marketplace,
        category: 'Logistics',
        severity: 'Moderate',
      ),
    ];
  }

  static List<AiInsightItem> _synthesizeExpertInsights(bool isDemo) {
    return [
      const AiInsightItem(
        title: 'Agronomic Advisory & Case Desk',
        subtitle: 'Review farmer pest diagnostics and soil health consultation requests.',
        action: 'Review Cases',
        imageUrl: 'https://images.unsplash.com/photo-1464226184884-fa280b87c399?auto=format&fit=crop&w=1200&q=80',
        color: purple,
        confidence: 0.93,
        targetScreen: VerdiScreen.cropHealth,
        category: 'Agronomic',
        severity: 'Moderate',
      ),
    ];
  }
}
