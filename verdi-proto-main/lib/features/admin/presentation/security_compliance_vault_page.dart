import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/services/rate_limiter_service.dart';
import '../../../core/services/security_vault_service.dart';
import '../../../core/widgets/security_pin_biometric_dialog.dart';

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

  final Map<String, bool> _complianceRulepack = {
    'EUDR Deforestation Polygon Scan (Mandatory for Coffee/Cocoa/Timber)': true,
    'GDPR Cryptographic Data Anonymization Engine': true,
    'National Reserve Bank Escrow Clearing Audit Policy': true,
    'Ministry of Lands Geographic Boundary Cross-Verification': true,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    SecurityVaultService.instance.initialize();
    SecurityVaultService.instance.addListener(_onVaultUpdated);
    RateLimiterService.instance.initialize();
    RateLimiterService.instance.addListener(_onVaultUpdated);
  }

  void _onVaultUpdated() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    SecurityVaultService.instance.removeListener(_onVaultUpdated);
    RateLimiterService.instance.removeListener(_onVaultUpdated);
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
                    'Security, API Vault & Rate Limiting Control Desk',
                    style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'API Key rotation, Rate Limiting & Token Quotas, IP Firewall, EUDR compliance, and threat monitoring.',
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
              Tab(text: '⚡ Rates & Token Control'),
              Tab(text: 'API Secret Vault & Rotation'),
              Tab(text: 'IP Firewall & Network Access'),
              Tab(text: 'EUDR & Compliance Rulepack'),
              Tab(text: 'Security Incident Desk'),
            ],
          ),
        ),

        const SizedBox(height: 20),

        SizedBox(
          height: 1100,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildRateAndTokenControlTab(),
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
    final keys = SecurityVaultService.instance.apiKeys;

    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Third-Party API Credentials & Secret Tokens', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ElevatedButton.icon(
              onPressed: () async {
                final authOk = await SecurityPinBiometricDialog.prompt(
                  context,
                  title: 'Authorize Key Generation',
                  description: 'Enter your Master Security PIN or Biometric Pass to generate a production API secret token.',
                );
                if (!authOk || !mounted) return;

                _showCreateKeyModal();
              },
              icon: const Icon(Icons.key_outlined, size: 16),
              label: const Text('Generate API Key'),
              style: ElevatedButton.styleFrom(backgroundColor: accentGreen, foregroundColor: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 16),

        for (final k in keys) ...[
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
                    Text(k.name, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: (k.status == 'ACTIVE' ? accentGreen : accentDanger).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(k.status, style: TextStyle(color: k.status == 'ACTIVE' ? accentGreen : accentDanger, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text('Token: ${k.key} • Scope: ${k.scope} • Rotated: ${k.lastRotated}', style: const TextStyle(color: textMuted, fontSize: 11)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () async {
                        final authOk = await SecurityPinBiometricDialog.prompt(
                          context,
                          title: 'Authorize Secret Rotation',
                          description: 'Enter Master PIN to rotate the secret token for ${k.name}.',
                        );
                        if (!authOk) return;

                        await SecurityVaultService.instance.rotateApiKey(k.id);
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Key successfully rotated for ${k.name}'), backgroundColor: accentBlue),
                        );
                      },
                      icon: const Icon(Icons.sync, size: 14, color: accentBlue),
                      label: const Text('Rotate Key', style: TextStyle(color: accentBlue, fontSize: 11)),
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: accentBlue)),
                    ),
                    const SizedBox(width: 8),
                    if (k.status == 'ACTIVE')
                      OutlinedButton.icon(
                        onPressed: () async {
                          final authOk = await SecurityPinBiometricDialog.prompt(
                            context,
                            title: 'Authorize Token Revocation',
                            description: 'Revoking this token will immediately terminate third-party access.',
                            actionButtonLabel: 'Confirm Revocation',
                          );
                          if (!authOk) return;

                          await SecurityVaultService.instance.revokeApiKey(k.id);
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Revoked key for ${k.name}'), backgroundColor: accentDanger),
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

  void _showCreateKeyModal() {
    final nameCtrl = TextEditingController();
    final scopeCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardDark,
        title: const Text('Create New API Secret Token', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Service Name (e.g. Export Gate)', labelStyle: TextStyle(color: textMuted)),
            ),
            TextField(
              controller: scopeCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Permission Scope (e.g. Read/Write Escrow)', labelStyle: TextStyle(color: textMuted)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: textMuted))),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.isNotEmpty) {
                await SecurityVaultService.instance.createApiKey(
                  nameCtrl.text.trim(),
                  scopeCtrl.text.trim().isEmpty ? 'Full Sovereign Access' : scopeCtrl.text.trim(),
                );
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: accentGreen, foregroundColor: Colors.white),
            child: const Text('Create Token'),
          ),
        ],
      ),
    );
  }

  // --- TAB 2: FIREWALL ---
  Widget _buildFirewallTab() {
    final rules = SecurityVaultService.instance.ipRules;

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

        for (final rule in rules) ...[
          Container(
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(12), border: Border.all(color: cardBorder)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(rule.action == 'ALLOW' ? Icons.check_circle_outline : Icons.do_not_disturb_on_outlined,
                        color: rule.action == 'ALLOW' ? accentGreen : accentDanger, size: 20),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(rule.ip, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                        Text('${rule.note} • ${rule.addedAt}', style: const TextStyle(color: textMuted, fontSize: 11)),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: (rule.action == 'ALLOW' ? accentGreen : accentDanger).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(rule.action, style: TextStyle(color: rule.action == 'ALLOW' ? accentGreen : accentDanger, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18, color: textMuted),
                      onPressed: () async {
                        await SecurityVaultService.instance.removeIpRule(rule.ip);
                      },
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
    final incidents = SecurityVaultService.instance.incidents;

    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Text('Real-Time Security Threat & Anomaly Desk', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 12),

        for (final inc in incidents) ...[
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: cardDark,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: inc.severity == 'HIGH' || inc.severity == 'CRITICAL' ? accentDanger : cardBorder),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: inc.severity == 'HIGH' || inc.severity == 'CRITICAL' ? accentDanger : accentGold, size: 24),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(inc.title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text('IP: ${inc.ip} • Time: ${inc.time} • Status: ${inc.status}', style: const TextStyle(color: textMuted, fontSize: 11)),
                    ],
                  ),
                ),
                OutlinedButton(
                  onPressed: () async {
                    await SecurityVaultService.instance.addIpRule(inc.ip, 'BLOCK', 'Flagged via incident ${inc.id}');
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('IP ${inc.ip} added to firewall block list.'), backgroundColor: accentDanger),
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
            onPressed: () async {
              if (ipCtrl.text.isNotEmpty) {
                await SecurityVaultService.instance.addIpRule(ipCtrl.text.trim(), action, noteCtrl.text.trim());
              }
              if (context.mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: accentGreen, foregroundColor: Colors.white),
            child: const Text('Add Rule'),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // TAB: RATES & TOKEN CONTROL (MONITOR & LIVE ADJUSTMENT)
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildRateAndTokenControlTab() {
    final limiter = RateLimiterService.instance;
    final usedTokens = limiter.tokensUsedToday;
    final totalCap = limiter.dailyTokenCap;
    final tokenUsageRatio = (usedTokens / totalCap).clamp(0.0, 1.0);
    final estimatedCost = (usedTokens / 1000.0) * 0.00015;
    final violations = limiter.violations;

    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      children: [
        // 1. Daily Token Budget Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('DAILY BACKBONE TOKEN BUDGET', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w900, color: accentBlue, letterSpacing: 1.0)),
                  Text('${(tokenUsageRatio * 100).toStringAsFixed(1)}% Consumed', style: TextStyle(color: tokenUsageRatio > 0.85 ? accentDanger : accentGreen, fontWeight: FontWeight.bold, fontSize: 11)),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: tokenUsageRatio,
                  minHeight: 10,
                  backgroundColor: const Color(0xFF1E293B),
                  valueColor: AlwaysStoppedAnimation<Color>(tokenUsageRatio > 0.85 ? accentDanger : accentGreen),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('$usedTokens / $totalCap Tokens Today', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                  Text('Est. Spend: \$${estimatedCost.toStringAsFixed(3)}', style: const TextStyle(color: textMuted, fontSize: 12)),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // 2. Category Sliding Window Control Desk
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Live Sliding-Window Rate Controls', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ElevatedButton.icon(
              onPressed: () {
                limiter.flushAllCooldowns();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All sliding-window rate cooldowns flushed.'), backgroundColor: accentGreen),
                );
              },
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Flush All Cooldowns'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E293B), foregroundColor: Colors.white),
            ),
          ],
        ),

        const SizedBox(height: 12),

        for (final category in RateLimitCategory.values) ...[
          _buildCategoryRateCard(category, limiter),
        ],

        const SizedBox(height: 24),

        // 3. Live Rate Limit Violation Incident Table
        Text('Recent Rate Limit & Quota Violations', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 12),

        if (violations.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(12), border: Border.all(color: cardBorder)),
            child: const Center(
              child: Text('No rate limit violations recorded.', style: TextStyle(color: textMuted, fontSize: 13)),
            ),
          )
        else
          for (final vio in violations.take(6)) ...[
            Container(
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(12), border: Border.all(color: cardBorder)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.speed_outlined, color: accentDanger, size: 20),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${vio.categoryName} (${vio.ipOrUser})', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                          Text('Target: ${vio.targetKey} • Rejected: ${vio.rejectedRequests} reqs', style: const TextStyle(color: textMuted, fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                  OutlinedButton(
                    onPressed: () async {
                      await SecurityVaultService.instance.addIpRule(vio.ipOrUser.replaceAll(RegExp(r'\s*\([^)]*\)'), '').trim(), 'BLOCK', 'Rate violation ${vio.id}');
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Blocked IP for violation ${vio.id}'), backgroundColor: accentDanger),
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

  Widget _buildCategoryRateCard(RateLimitCategory category, RateLimiterService limiter) {
    final activeCount = limiter.getActiveRequestCountInWindow(category);
    final currentLimit = limiter.getCategoryLimit(category);
    final ratio = limiter.getCategoryUsageRatio(category);

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ratio >= 1.0 ? accentDanger : cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(category.name, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: (ratio >= 1.0 ? accentDanger : accentBlue).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text('$activeCount / $currentLimit in window', style: TextStyle(color: ratio >= 1.0 ? accentDanger : accentBlue, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 6,
              backgroundColor: const Color(0xFF1E293B),
              valueColor: AlwaysStoppedAnimation<Color>(ratio >= 1.0 ? accentDanger : (ratio > 0.7 ? accentGold : accentGreen)),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Text('Limit:', style: TextStyle(color: textMuted, fontSize: 12)),
              Expanded(
                child: Slider(
                  value: currentLimit.toDouble().clamp(1.0, 200.0),
                  min: 1.0,
                  max: 200.0,
                  divisions: 199,
                  activeColor: accentGreen,
                  onChanged: (val) {
                    limiter.setCategoryLimit(category, val.toInt());
                  },
                ),
              ),
              Text('$currentLimit reqs/min', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
