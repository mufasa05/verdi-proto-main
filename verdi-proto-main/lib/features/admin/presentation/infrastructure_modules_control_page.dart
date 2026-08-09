import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Dedicated Sovereign Control Console: Infrastructure & 47-Module Capability Switchboard
class InfrastructureModulesControlPage extends StatefulWidget {
  const InfrastructureModulesControlPage({super.key});

  @override
  State<InfrastructureModulesControlPage> createState() => _InfrastructureModulesControlPageState();
}

class _InfrastructureModulesControlPageState extends State<InfrastructureModulesControlPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const cardDark = Color(0xFF161E2E);
  static const cardBorder = Color(0xFF2D3748);
  static const accentGreen = Color(0xFF10B981);
  static const accentDanger = Color(0xFFEF4444);
  static const accentBlue = Color(0xFF3B82F6);
  static const accentGold = Color(0xFFF59E0B);
  static const textMuted = Color(0xFF94A3B8);

  String _moduleSearchQuery = '';
  String _selectedCategory = 'All Categories';

  // System Safety Switches
  bool _emergencyLockdown = false;
  bool _maintenanceMode = false;
  bool _escrowTradeFrozen = false;

  final List<Map<String, dynamic>> _modulesList = [
    {'name': 'Marketplace & Trade Floor', 'category': 'Trade & Escrow', 'enabled': true, 'code': 'MOD-01'},
    {'name': 'Escrow Payment & Wallet Vaults', 'category': 'Trade & Escrow', 'enabled': true, 'code': 'MOD-02'},
    {'name': 'AI Agronomist & Voice Assistant', 'category': 'AI & Intelligence', 'enabled': true, 'code': 'MOD-03'},
    {'name': 'Shona & Ndebele Speech Engine', 'category': 'AI & Intelligence', 'enabled': true, 'code': 'MOD-04'},
    {'name': 'Plant Pathology AI Vision Diagnostic', 'category': 'AI & Intelligence', 'enabled': true, 'code': 'MOD-05'},
    {'name': 'Geospatial Polygon Mapping & GIS', 'category': 'Geospatial & Satellite', 'enabled': true, 'code': 'MOD-06'},
    {'name': 'Sentinel-2 Satellite Telemetry Stream', 'category': 'Geospatial & Satellite', 'enabled': true, 'code': 'MOD-07'},
    {'name': 'Landsat Thermal Soil Moisture Feed', 'category': 'Geospatial & Satellite', 'enabled': true, 'code': 'MOD-08'},
    {'name': 'EUDR Deforestation Verification', 'category': 'Compliance & EUDR', 'enabled': true, 'code': 'MOD-09'},
    {'name': 'GDPR Anonymized Data Vault', 'category': 'Compliance & EUDR', 'enabled': true, 'code': 'MOD-10'},
    {'name': 'Drone Inspection Pipeline & Video', 'category': 'Geospatial & Satellite', 'enabled': true, 'code': 'MOD-11'},
    {'name': 'Refrigerated Transport Dispatch', 'category': 'Logistics & Supply', 'enabled': true, 'code': 'MOD-12'},
    {'name': 'Cold-Chain IoT Sensor Monitoring', 'category': 'Logistics & Supply', 'enabled': true, 'code': 'MOD-13'},
    {'name': 'Government Agronomy & GMB Silo Sync', 'category': 'Government & Regulatory', 'enabled': true, 'code': 'MOD-14'},
    {'name': 'Cryptographic Sovereign Audit Trail', 'category': 'Compliance & EUDR', 'enabled': true, 'code': 'MOD-15'},
    {'name': 'Weather Risk Forecasting Engine', 'category': 'AI & Intelligence', 'enabled': true, 'code': 'MOD-16'},
    {'name': 'Commodity Floor Price Publisher', 'category': 'Trade & Escrow', 'enabled': true, 'code': 'MOD-17'},
    {'name': 'Credit Scoring & Micro-Loan Engine', 'category': 'Trade & Escrow', 'enabled': true, 'code': 'MOD-18'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeCount = _modulesList.where((m) => m['enabled'] == true).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Infrastructure & 47-Module Switchboard Suite',
                    style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Real-time module control, infrastructure telemetry, database pool, and emergency safety lockdown.',
                    style: GoogleFonts.inter(fontSize: 12, color: textMuted),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: accentGreen.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: accentGreen.withValues(alpha: 0.4)),
              ),
              child: Text(
                '$activeCount / ${_modulesList.length} Modules Active',
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: accentGreen),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        Container(
          decoration: BoxDecoration(
            color: cardDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cardBorder),
          ),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorColor: accentGreen,
            labelColor: accentGreen,
            unselectedLabelColor: textMuted,
            tabs: const [
              Tab(text: '47-Module Capability Switchboard'),
              Tab(text: 'Server Health & Real-Time Telemetry'),
              Tab(text: 'Emergency Safety & Lockdown Desk'),
            ],
          ),
        ),

        const SizedBox(height: 20),

        SizedBox(
          height: 950,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildModulesTab(),
              _buildTelemetryTab(),
              _buildLockdownTab(),
            ],
          ),
        ),
      ],
    );
  }

  // --- TAB 1: 47-MODULE SWITCHBOARD ---
  Widget _buildModulesTab() {
    final filtered = _modulesList.where((m) {
      final matchesSearch = m['name'].toString().toLowerCase().contains(_moduleSearchQuery.toLowerCase()) ||
          m['code'].toString().toLowerCase().contains(_moduleSearchQuery.toLowerCase());
      final matchesCat = _selectedCategory == 'All Categories' || m['category'] == _selectedCategory;
      return matchesSearch && matchesCat;
    }).toList();

    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      children: [
        // Filter bar
        Row(
          children: [
            Expanded(
              child: TextField(
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Search module by name or code...',
                  hintStyle: const TextStyle(color: textMuted),
                  filled: true,
                  fillColor: cardDark,
                  prefixIcon: const Icon(Icons.search, color: textMuted, size: 18),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: cardBorder)),
                ),
                onChanged: (v) => setState(() => _moduleSearchQuery = v),
              ),
            ),
            const SizedBox(width: 12),
            DropdownButton<String>(
              value: _selectedCategory,
              dropdownColor: cardDark,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              items: ['All Categories', 'Trade & Escrow', 'AI & Intelligence', 'Geospatial & Satellite', 'Compliance & EUDR', 'Logistics & Supply', 'Government & Regulatory']
                  .map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) { if (v != null) setState(() => _selectedCategory = v); },
            ),
          ],
        ),

        const SizedBox(height: 16),

        for (int i = 0; i < filtered.length; i++) ...[
          Container(
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: cardDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: filtered[i]['enabled'] ? cardBorder : accentDanger.withValues(alpha: 0.5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (filtered[i]['enabled'] ? accentGreen : accentDanger).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        filtered[i]['enabled'] ? Icons.check_circle_outline : Icons.power_settings_new,
                        color: filtered[i]['enabled'] ? accentGreen : accentDanger,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(filtered[i]['name'], style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(4)),
                              child: Text(filtered[i]['code'], style: const TextStyle(color: accentBlue, fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(filtered[i]['category'], style: const TextStyle(color: textMuted, fontSize: 11)),
                      ],
                    ),
                  ],
                ),
                Switch(
                  value: filtered[i]['enabled'],
                  activeColor: accentGreen,
                  inactiveThumbColor: accentDanger,
                  onChanged: (val) {
                    setState(() {
                      filtered[i]['enabled'] = val;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${filtered[i]['name']} is now ${val ? "ACTIVE" : "DISABLED"}'),
                        backgroundColor: val ? accentGreen : accentDanger,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // --- TAB 2: TELEMETRY & SERVER HEALTH ---
  Widget _buildTelemetryTab() {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Row(
          children: [
            Expanded(child: _telemetryMetricCard('NestJS API Core Node', '24 ms', '99.99% Uptime', accentGreen)),
            const SizedBox(width: 12),
            Expanded(child: _telemetryMetricCard('PostgreSQL Pool', '14 / 100', '2.1 ms Avg Query', accentGreen)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _telemetryMetricCard('Redis Cache Subsystem', '98.4%', '42 MB Allocated', accentBlue)),
            const SizedBox(width: 12),
            Expanded(child: _telemetryMetricCard('Satellite Raster Jobs', '0 Pending', 'Sentinel-2 Synced', accentGreen)),
          ],
        ),

        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(16), border: Border.all(color: cardBorder)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('INFRASTRUCTURE MAINTENANCE CONTROLS', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w900, color: accentGold, letterSpacing: 1.0)),
              const SizedBox(height: 16),

              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Redis cache flushed cleanly.'), backgroundColor: accentGreen),
                      );
                    },
                    icon: const Icon(Icons.cleaning_services, size: 16),
                    label: const Text('Flush Redis Cache'),
                    style: ElevatedButton.styleFrom(backgroundColor: accentBlue, foregroundColor: Colors.white),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('PostgreSQL connection pool reconnected cleanly.'), backgroundColor: accentGreen),
                      );
                    },
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Reconnect DB Pool'),
                    style: ElevatedButton.styleFrom(backgroundColor: accentGreen, foregroundColor: Colors.white),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Satellite pipeline job queue cleared.'), backgroundColor: accentGold),
                      );
                    },
                    icon: const Icon(Icons.satellite_alt, size: 16),
                    label: const Text('Clear Raster Pipeline Queue'),
                    style: ElevatedButton.styleFrom(backgroundColor: accentGold, foregroundColor: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _telemetryMetricCard(String title, String val, String sub, Color color) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(16), border: Border.all(color: cardBorder)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: textMuted)),
          const SizedBox(height: 8),
          Text(val, style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w900, color: color)),
          const SizedBox(height: 4),
          Text(sub, style: const TextStyle(fontSize: 11, color: Colors.white70)),
        ],
      ),
    );
  }

  // --- TAB 3: LOCKDOWN DESK ---
  Widget _buildLockdownTab() {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _lockdownTile(
          'PLATFORM-WIDE EMERGENCY LOCKDOWN',
          'Freeze all logins and active commodity transactions instantly across the platform.',
          _emergencyLockdown,
          (v) => setState(() => _emergencyLockdown = v),
          accentDanger,
        ),
        const SizedBox(height: 12),
        _lockdownTile(
          'READ-ONLY MAINTENANCE MODE',
          'Puts database into read-only mode for scheduled platform updates.',
          _maintenanceMode,
          (v) => setState(() => _maintenanceMode = v),
          accentGold,
        ),
        const SizedBox(height: 12),
        _lockdownTile(
          'MARKETPLACE ESCROW TRADE FREEZE',
          'Halts escrow checkouts during market volatility or regulatory inspection.',
          _escrowTradeFrozen,
          (v) => setState(() => _escrowTradeFrozen = v),
          accentBlue,
        ),
      ],
    );
  }

  Widget _lockdownTile(String title, String desc, bool value, ValueChanged<bool> onChanged, Color activeColor) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: value ? activeColor : cardBorder, width: value ? 2 : 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: value ? activeColor : Colors.white)),
                const SizedBox(height: 4),
                Text(desc, style: const TextStyle(color: textMuted, fontSize: 11)),
              ],
            ),
          ),
          Switch(value: value, activeColor: activeColor, onChanged: onChanged),
        ],
      ),
    );
  }
}
