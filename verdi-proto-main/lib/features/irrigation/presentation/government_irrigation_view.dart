import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GovernmentIrrigationView extends StatelessWidget {
  const GovernmentIrrigationView({super.key});

  static const green = Color(0xFF16A34A);
  static const dark = Color(0xFF0F172A);
  static const muted = Color(0xFF64748B);
  static const orange = Color(0xFFF97316);
  static const red = Color(0xFFEF4444);
  static const blue = Color(0xFF3B82F6);
  static const background = Color(0xFFF8FAFC);

  @override
  Widget build(BuildContext context) {
    final schemes = const [
      _Scheme(
        name: 'Mvurwi Scheme',
        region: 'Mashonaland Central',
        crop: 'Maize',
        waterAllocated: 120.0,
        waterUsed: 103.2,
        uptime: 0.96,
        blockedValves: 1,
        alerts: 2,
        compliancePct: 92,
      ),
      _Scheme(
        name: 'Odzi Scheme',
        region: 'Manicaland',
        crop: 'Tomatoes',
        waterAllocated: 90.0,
        waterUsed: 61.8,
        uptime: 0.88,
        blockedValves: 2,
        alerts: 4,
        compliancePct: 73,
      ),
      _Scheme(
        name: 'Gutu Cluster',
        region: 'Masvingo',
        crop: 'Onions',
        waterAllocated: 75.0,
        waterUsed: 55.5,
        uptime: 0.92,
        blockedValves: 0,
        alerts: 1,
        compliancePct: 86,
      ),
      _Scheme(
        name: 'Chiredzi Block',
        region: 'Lowveld',
        crop: 'Sugarcane',
        waterAllocated: 150.0,
        waterUsed: 132.0,
        uptime: 0.99,
        blockedValves: 0,
        alerts: 0,
        compliancePct: 99,
      ),
    ];

    final totalAllocated = schemes.fold<double>(0, (s, e) => s + e.waterAllocated);
    final totalUsed = schemes.fold<double>(0, (s, e) => s + e.waterUsed);
    final avgUptime = schemes.fold<double>(0, (s, e) => s + e.uptime) / schemes.length;
    final totalAlerts = schemes.fold<int>(0, (s, e) => s + e.alerts);
    final avgCompliance = schemes.fold<int>(0, (s, e) => s + e.compliancePct) ~/ schemes.length;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: Text(
          'Irrigation — Government Oversight',
          style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: dark),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Chip(
              label: const Text('Government View', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              backgroundColor: blue,
              side: BorderSide.none,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: SingleChildScrollView(
              padding: MediaQuery.of(context).size.width < 600 ? const EdgeInsets.all(12) : const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Spatial banner
                  _SpatialBanner(),
                  const SizedBox(height: 16),

                  // AI National Water Advisory
                  _NationalAiCard(),
                  const SizedBox(height: 16),

                  // Top-level KPI Summary Cards
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final cols = constraints.maxWidth > 900
                          ? 5
                          : (constraints.maxWidth > 550 ? 3 : (constraints.maxWidth > 360 ? 2 : 1));
                      final spacing = 12.0;
                      final double width = (constraints.maxWidth - (spacing * (cols - 1))) / cols;
                      return Wrap(
                        spacing: spacing,
                        runSpacing: spacing,
                        children: [
                          _KpiCard(width: width, label: 'Total Allocated', value: '${totalAllocated.toStringAsFixed(0)} m³', icon: Icons.water_drop_outlined, color: blue),
                          _KpiCard(width: width, label: 'Total Used', value: '${totalUsed.toStringAsFixed(0)} m³', icon: Icons.opacity_outlined, color: green),
                          _KpiCard(width: width, label: 'Avg System Uptime', value: '${(avgUptime * 100).round()}%', icon: Icons.schedule_outlined, color: green),
                          _KpiCard(width: width, label: 'Open Alerts', value: '$totalAlerts', icon: Icons.warning_amber_outlined, color: totalAlerts > 3 ? red : orange),
                          _KpiCard(width: width, label: 'Avg Compliance', value: '$avgCompliance%', icon: Icons.verified_outlined, color: avgCompliance >= 80 ? green : orange),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Compliance Grid
                  _ComplianceGridCard(schemes: schemes),
                  const SizedBox(height: 16),

                  // Scheme Detail Cards
                  Text(
                    'Scheme Control Status',
                    style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: dark),
                  ),
                  const SizedBox(height: 10),
                  ...schemes.map((s) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _SchemeDetailCard(scheme: s),
                  )),
                  const SizedBox(height: 20),

                  // Reports & export
                  _ReportsExportCard(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SpatialBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF3B82F6).withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.map_outlined, color: Color(0xFF3B82F6), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Geospatial Layer Active — Spatial source of truth: scheme boundaries, field zones, and asset IDs synced.',
              style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600, color: GovernmentIrrigationView.dark),
            ),
          ),
          Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          const Text('Live', style: TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _NationalAiCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [GovernmentIrrigationView.blue.withOpacity(0.06), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: GovernmentIrrigationView.blue.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: GovernmentIrrigationView.blue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.smart_toy, color: Colors.white, size: 14),
                    SizedBox(width: 4),
                    Text('AI NATIONAL WATER ADVISORY', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text('Confidence: ', style: TextStyle(color: GovernmentIrrigationView.muted, fontSize: 12)),
                  Text('88%', style: TextStyle(color: GovernmentIrrigationView.blue, fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Water use in Odzi Scheme is 31.5% below allocation — possible infrastructure fault or unauthorised diversion.',
            style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: GovernmentIrrigationView.dark),
          ),
          const SizedBox(height: 6),
          Text(
            'Why this matters: Satellite moisture analysis indicates crops in Odzi Scheme are receiving below-optimal irrigation despite below-quota water draw. This pattern is consistent with blocked valve clusters or diversion at canal intake points. A field compliance audit is recommended.',
            style: GoogleFonts.inter(fontSize: 13, color: GovernmentIrrigationView.muted),
          ),
        ],
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final double? width;

  const _KpiCard({required this.label, required this.value, required this.icon, required this.color, this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? 165,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: GovernmentIrrigationView.muted, fontSize: 12)),
                const SizedBox(height: 4),
                Text(value, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: GovernmentIrrigationView.dark)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ComplianceGridCard extends StatelessWidget {
  final List<_Scheme> schemes;
  const _ComplianceGridCard({required this.schemes});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text('Compliance Grid', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: GovernmentIrrigationView.dark)),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download_outlined, size: 16),
                  label: const Text('Export', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: const [
                Expanded(flex: 3, child: Text('Scheme', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: GovernmentIrrigationView.muted))),
                Expanded(flex: 2, child: Text('Allocated', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: GovernmentIrrigationView.muted))),
                Expanded(flex: 2, child: Text('Used', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: GovernmentIrrigationView.muted))),
                Expanded(flex: 2, child: Text('Compliance', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: GovernmentIrrigationView.muted))),
                Expanded(flex: 1, child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: GovernmentIrrigationView.muted))),
              ],
            ),
          ),
          const Divider(height: 1),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 480),
              child: Column(
                children: [
                  ...schemes.map((s) {
                    final complianceColor = s.compliancePct >= 85
                        ? GovernmentIrrigationView.green
                        : s.compliancePct >= 70
                            ? GovernmentIrrigationView.orange
                            : GovernmentIrrigationView.red;
                    final statusLabel = s.compliancePct >= 85 ? 'OK' : s.compliancePct >= 70 ? 'Watch' : 'Alert';
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                Text(s.region, style: const TextStyle(fontSize: 11, color: GovernmentIrrigationView.muted)),
                              ],
                            ),
                          ),
                          Expanded(flex: 2, child: Text('${s.waterAllocated.toStringAsFixed(0)} m³', style: const TextStyle(fontSize: 13))),
                          Expanded(flex: 2, child: Text('${s.waterUsed.toStringAsFixed(0)} m³', style: const TextStyle(fontSize: 13))),
                          Expanded(
                            flex: 2,
                            child: Text(
                              '${s.compliancePct}%',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: complianceColor),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: complianceColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(statusLabel, style: TextStyle(color: complianceColor, fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SchemeDetailCard extends StatelessWidget {
  final _Scheme scheme;
  const _SchemeDetailCard({required this.scheme});

  @override
  Widget build(BuildContext context) {
    final utilizationPct = scheme.waterAllocated > 0
        ? ((scheme.waterUsed / scheme.waterAllocated) * 100).round()
        : 0;
    final complianceColor = scheme.compliancePct >= 85
        ? GovernmentIrrigationView.green
        : scheme.compliancePct >= 70
            ? GovernmentIrrigationView.orange
            : GovernmentIrrigationView.red;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black12),
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
                    Text(scheme.name, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: GovernmentIrrigationView.dark)),
                    Text('${scheme.region} · ${scheme.crop}', style: const TextStyle(color: GovernmentIrrigationView.muted, fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: complianceColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Compliance: ${scheme.compliancePct}%',
                  style: TextStyle(color: complianceColor, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('Water Utilisation', style: TextStyle(color: GovernmentIrrigationView.muted, fontSize: 12)),
              const Spacer(),
              Text('$utilizationPct%', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: utilizationPct > 90 ? GovernmentIrrigationView.orange : GovernmentIrrigationView.dark)),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: utilizationPct / 100,
            minHeight: 8,
            backgroundColor: Colors.grey.shade100,
            color: utilizationPct > 95 ? GovernmentIrrigationView.red : (utilizationPct > 80 ? GovernmentIrrigationView.orange : GovernmentIrrigationView.green),
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _MiniStat(label: 'Uptime', value: '${(scheme.uptime * 100).round()}%')),
              const SizedBox(width: 8),
              Expanded(child: _MiniStat(label: 'Blocked Valves', value: '${scheme.blockedValves}')),
              const SizedBox(width: 8),
              Expanded(child: _MiniStat(label: 'Open Alerts', value: '${scheme.alerts}', color: scheme.alerts > 0 ? GovernmentIrrigationView.orange : null)),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 400;
              final btnAudit = OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.search_outlined, size: 16),
                label: const Text('Audit Scheme', style: TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              );
              final btnSchedule = ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.schedule_outlined, size: 16),
                label: const Text('Water Schedule', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: GovernmentIrrigationView.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );

              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    btnAudit,
                    const SizedBox(height: 8),
                    btnSchedule,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: btnAudit),
                  const SizedBox(width: 8),
                  Expanded(child: btnSchedule),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  const _MiniStat({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: GovernmentIrrigationView.muted)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: color ?? GovernmentIrrigationView.dark,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportsExportCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Export & Audit Options', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: GovernmentIrrigationView.dark)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _ExportButton(label: 'PDF Report', icon: Icons.picture_as_pdf_outlined),
              _ExportButton(label: 'CSV Data', icon: Icons.table_chart_outlined),
              _ExportButton(label: 'Audit Bundle', icon: Icons.inventory_2_outlined),
              _ExportButton(label: 'Compliance Summary', icon: Icons.verified_outlined),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: const [
              Icon(Icons.access_time_outlined, size: 14, color: GovernmentIrrigationView.muted),
              SizedBox(width: 6),
              Text('Audit trail: 47 records. Last change 12m ago by Inspector Moyo.', style: TextStyle(fontSize: 12, color: GovernmentIrrigationView.muted)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExportButton extends StatelessWidget {
  final String label;
  final IconData icon;
  const _ExportButton({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      style: OutlinedButton.styleFrom(
        foregroundColor: GovernmentIrrigationView.dark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class _Scheme {
  final String name;
  final String region;
  final String crop;
  final double waterAllocated;
  final double waterUsed;
  final double uptime;
  final int blockedValves;
  final int alerts;
  final int compliancePct;

  const _Scheme({
    required this.name,
    required this.region,
    required this.crop,
    required this.waterAllocated,
    required this.waterUsed,
    required this.uptime,
    required this.blockedValves,
    required this.alerts,
    required this.compliancePct,
  });
}
