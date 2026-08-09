import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Dedicated Sovereign Control Console: Security, Compliance & API Vault
class SecurityComplianceVaultPage extends StatefulWidget {
  const SecurityComplianceVaultPage({super.key});

  @override
  State<SecurityComplianceVaultPage> createState() => _SecurityComplianceVaultPageState();
}

class _SecurityComplianceVaultPageState extends State<SecurityComplianceVaultPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const cardDark = Color(0xFF161E2E);
  static const cardBorder = Color(0xFF2D3748);
  static const accentGreen = Color(0xFF10B981);
  static const accentDanger = Color(0xFFEF4444);
  static const accentBlue = Color(0xFF3B82F6);
  static const accentGold = Color(0xFFF59E0B);
  static const textMuted = Color(0xFF94A3B8);

  double _ddosRateLimit = 100.0;

  final List<Map<String, String>> _apiKeys = [
    {'name': 'Verdi Backend AI Service Token', 'key': 'verdi-backend-ai-token-prod-v1-9981', 'status': 'ACTIVE', 'scope': 'Full Model Access'},
    {'name': 'Copernicus Sentinel API', 'key': 'copernicus-auth-token-v2-live-881', 'status': 'ACTIVE', 'scope': 'Sentinel-2 Satellite Feed'},
    {'name': 'EcoCash Merchant Gateway API', 'key': 'ecocash-merchant-key-prod-9941', 'status': 'ACTIVE', 'scope': 'Escrow Payments'},
    {'name': 'AWS S3 Satellite Storage Vault', 'key': 'aws-s3-raster-vault-key-zim-01', 'status': 'ACTIVE', 'scope': 'GeoTIFF Rasters'},
  ];

  final List<Map<String, String>> _ipRules = [
    {'ip': '196.220.12.0/24', 'action': 'ALLOW', 'note': 'Harare Data Center Node'},
    {'ip': '197.210.45.19', 'action': 'BLOCK', 'note': 'Brute-force SSH Attempt Flagged'},
    {'ip': '41.206.18.99', 'action': 'BLOCK', 'note': 'Suspicious Escrow Re-entry Attempt'},
  ];

  final List<Map<String, String>> _securityIncidents = [
    {'id': 'INC-9912', 'time': '10 mins ago', 'severity': 'MEDIUM', 'title': 'Failed KYC Document Hash Spoof Attempt', 'ip': '197.221.12.8', 'status': 'BLOCKED'},
    {'id': 'INC-8819', 'time': '1 hour ago', 'severity': 'LOW', 'title': 'Repeated Rate Limit Hit on Trade Endpoint', 'ip': '41.206.18.99', 'status': 'RATE_LIMITED'},
    {'id': 'INC-4412', 'time': 'Yesterday', 'severity': 'HIGH', 'title': 'Unverified EUDR Export Permit Attempt', 'ip': '196.220.14.2', 'status': 'REJECTED'},
  ];

  final Map<String, bool> _complianceRulepack = {
    'EUDR Deforestation Polygon Scan (Mandatory for Coffee/Cocoa/Timber)': true,
    'GDPR Cryptographic Data Anonymization Engine': true,
    'National Reserve Bank Escrow Clearing Audit Policy': true,
    'Ministry of Lands Geographic Boundary Cross-Verification': true,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    'Security, API Vault & EUDR Compliance Desk',
                    style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'API Key rotation, IP Firewall rules, EUDR compliance rulepacks, and threat incident monitoring.',
                    style: GoogleFonts.inter(fontSize: 12, color: textMuted),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: accentGreen.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: accentGreen),
              ),
              child: const Row(
                children: [
                  Icon(Icons.shield, color: accentGreen, size: 16),
                  SizedBox(width: 6),
                  Text('SECURITY VAULT ARMED', style: TextStyle(color: accentGreen, fontSize: 11, fontWeight: FontWeight.bold)),
                ],
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
              Tab(text: 'API Secret Vault & Rotation'),
              Tab(text: 'IP Firewall & Network Access'),
              Tab(text: 'EUDR & Compliance Rulepack'),
              Tab(text: 'Security Incident Desk'),
            ],
          ),
        ),

        const SizedBox(height: 20),

        SizedBox(
          height: 900,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildApiVaultTab(),
              _buildFirewallTab(),
              _buildComplianceTab(),
              _buildIncidentsTab(),
            ],
          ),
        ),
      ],
    );
  }

  // --- TAB 1: API VAULT ---
  Widget _buildApiVaultTab() {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Third-Party API Credentials & Secret Tokens', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('New Production API Key generated.'), backgroundColor: accentGreen),
                );
              },
              icon: const Icon(Icons.key_outlined, size: 16),
              label: const Text('Generate API Key'),
              style: ElevatedButton.styleFrom(backgroundColor: accentGreen, foregroundColor: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 16),

        for (int i = 0; i < _apiKeys.length; i++) ...[
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(14), border: Border.all(color: cardBorder)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_apiKeys[i]['name']!, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: accentGreen.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(999)),
                      child: Text(_apiKeys[i]['status']!, style: const TextStyle(color: accentGreen, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text('Token: ${_apiKeys[i]['key']} • Scope: ${_apiKeys[i]['scope']}', style: const TextStyle(color: textMuted, fontSize: 11)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Key rotated for ${_apiKeys[i]['name']}'), backgroundColor: accentBlue),
                        );
                      },
                      icon: const Icon(Icons.sync, size: 14, color: accentBlue),
                      label: const Text('Rotate Key', style: TextStyle(color: accentBlue, fontSize: 11)),
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: accentBlue)),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () {
                        setState(() => _apiKeys[i]['status'] = 'REVOKED');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Revoked key for ${_apiKeys[i]['name']}'), backgroundColor: accentDanger),
                        );
                      },
                      icon: const Icon(Icons.block, size: 14, color: accentDanger),
                      label: const Text('Revoke Token', style: TextStyle(color: accentDanger, fontSize: 11)),
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: accentDanger)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // --- TAB 2: FIREWALL ---
  Widget _buildFirewallTab() {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(16), border: Border.all(color: cardBorder)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('DDOS RATE LIMITING CONTROLS', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w900, color: accentBlue, letterSpacing: 1.0)),
              const SizedBox(height: 12),
              Text('Max Requests/Min per Client IP: ${_ddosRateLimit.toInt()} reqs', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              Slider(
                value: _ddosRateLimit,
                min: 30.0,
                max: 500.0,
                divisions: 47,
                activeColor: accentBlue,
                onChanged: (v) => setState(() => _ddosRateLimit = v),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('IP Address & CIDR Access Rules', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ElevatedButton.icon(
              onPressed: _showAddIpRuleModal,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add IP Rule'),
              style: ElevatedButton.styleFrom(backgroundColor: accentBlue, foregroundColor: Colors.white),
            ),
          ],
        ),

        const SizedBox(height: 12),

        for (final rule in _ipRules) ...[
          Container(
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(12), border: Border.all(color: cardBorder)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(rule['action'] == 'ALLOW' ? Icons.check_circle_outline : Icons.do_not_disturb_on_outlined,
                        color: rule['action'] == 'ALLOW' ? accentGreen : accentDanger, size: 20),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(rule['ip']!, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                        Text(rule['note']!, style: const TextStyle(color: textMuted, fontSize: 11)),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: (rule['action'] == 'ALLOW' ? accentGreen : accentDanger).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(999)),
                  child: Text(rule['action']!, style: TextStyle(color: rule['action'] == 'ALLOW' ? accentGreen : accentDanger, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // --- TAB 3: COMPLIANCE ---
  Widget _buildComplianceTab() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(16), border: Border.all(color: cardBorder)),
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        children: [
          Text('EUDR & Sovereign Compliance Rulepack Desk', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          const Text('Configure European Union Deforestation Regulation (EUDR) and national data law enforcement rules.', style: TextStyle(color: textMuted, fontSize: 12)),
          const SizedBox(height: 20),

          for (final entry in _complianceRulepack.entries) ...[
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(12), border: Border.all(color: cardBorder)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(entry.key, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                  Switch(
                    value: entry.value,
                    activeColor: accentGreen,
                    onChanged: (val) {
                      setState(() => _complianceRulepack[entry.key] = val);
                    },
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // --- TAB 4: INCIDENTS ---
  Widget _buildIncidentsTab() {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Text('Real-Time Security Threat & Anomaly Desk', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 12),

        for (final inc in _securityIncidents) ...[
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: cardDark,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: inc['severity'] == 'HIGH' ? accentDanger : cardBorder),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: inc['severity'] == 'HIGH' ? accentDanger : accentGold, size: 24),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(inc['title']!, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text('IP: ${inc['ip']} • Time: ${inc['time']}', style: const TextStyle(color: textMuted, fontSize: 11)),
                    ],
                  ),
                ),
                OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('IP ${inc['ip']} added to firewall block list.'), backgroundColor: accentDanger),
                    );
                  },
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: accentDanger)),
                  child: const Text('Block IP', style: TextStyle(color: accentDanger, fontSize: 11)),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  void _showAddIpRuleModal() {
    final ipCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    String action = 'BLOCK';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardDark,
        title: const Text('Add Firewall Access Rule', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: ipCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'IP Address / CIDR', labelStyle: TextStyle(color: textMuted))),
            TextField(controller: noteCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Rule Reason / Note', labelStyle: TextStyle(color: textMuted))),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: action,
              dropdownColor: cardDark,
              style: const TextStyle(color: Colors.white),
              items: ['ALLOW', 'BLOCK'].map((a) => DropdownMenuItem(value: a, child: Text(a))).toList(),
              onChanged: (v) { if (v != null) action = v; },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: textMuted))),
          ElevatedButton(
            onPressed: () {
              if (ipCtrl.text.isNotEmpty) {
                setState(() {
                  _ipRules.add({'ip': ipCtrl.text, 'action': action, 'note': noteCtrl.text});
                });
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: accentGreen, foregroundColor: Colors.white),
            child: const Text('Add Rule'),
          ),
        ],
      ),
    );
  }
}
