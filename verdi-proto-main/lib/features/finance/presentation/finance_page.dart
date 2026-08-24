import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../analytics/data/analytics_export_service.dart';
import '../../../state/app_state.dart';

class FinancePage extends ConsumerStatefulWidget {
  const FinancePage({super.key});

  @override
  ConsumerState<FinancePage> createState() => _FinancePageState();
}

class _FinancePageState extends ConsumerState<FinancePage> {
  static const background = Color(0xFFF4F7FB);
  static const dark = Color(0xFF0F172A);
  static const green = Color(0xFF16A34A);
  static const muted = Color(0xFF64748B);
  static const gold = Color(0xFFD97706);

  int _activeTab = 0;
  bool _showInstitutionalView = false; // Toggle for Admin/Financier
  // Creator Security Key System (Default: LOCKED)
  bool _isCreatorKeyUnlocked = false;

  double get activeWalletBalance => ref.watch(isDemoModeProvider) ? _userWalletBalanceUsd : 0.0;
  List<Map<String, dynamic>> get activeTransactions => ref.watch(isDemoModeProvider) ? _userTransactionsList : [];
  List<Map<String, dynamic>> get activeRevenueLogs => ref.watch(isDemoModeProvider) ? _creatorRevenueLogs : [];

  // Live Personal Wallet State
  double _userWalletBalanceUsd = 2450.0;
  final List<Map<String, dynamic>> _userTransactionsList = [
    {
      'title': 'Cargo Freight Payout (Chiredzi ➔ Mbare)',
      'subtitle': 'Completed • EcoCash Transfer',
      'amountUsd': 140.0,
      'date': 'Today, 10:14 AM',
      'isIncome': true,
    },
    {
      'title': 'NPK 14-28-14 Fertilizer Purchase',
      'subtitle': 'Marketplace Order #ORD-9821',
      'amountUsd': -45.0,
      'date': 'Yesterday',
      'isIncome': false,
    },
    {
      'title': 'Wholesale Tomato Auction Proceeds',
      'subtitle': 'Escrow Released • Mbare Hub',
      'amountUsd': 250.0,
      'date': '05 Aug 2026',
      'isIncome': true,
    },
    {
      'title': 'Verdi Platform Escrow Fee (1.8%)',
      'subtitle': 'Automated Transaction Fee',
      'amountUsd': -12.50,
      'date': '04 Aug 2026',
      'isIncome': false,
    },
  ];

  // Creator Revenue Itemized Origin Logs
  final List<Map<String, dynamic>> _creatorRevenueLogs = [
    {
      'id': 'REV-9821',
      'source': 'Marketplace Sale (3% Take-Rate)',
      'origin': 'Order #ORD-9821 • Wholesale Tomatoes (Mbare Hub)',
      'amountUsd': 3.00,
      'date': 'Today, 11:20 AM',
      'rate': '3.0%',
    },
    {
      'id': 'REV-9820',
      'source': 'Freight Escrow (3% Take-Rate)',
      'origin': 'Shipment #TRK-441 • Chiredzi ➔ Mbare Freight',
      'amountUsd': 4.20,
      'date': 'Today, 10:14 AM',
      'rate': '3.0%',
    },
    {
      'id': 'REV-9819',
      'source': 'Loan Underwriting (1.5% Processing Fee)',
      'origin': 'Loan #LN-2026-0891 • Murewa Coop Drip Irrigation',
      'amountUsd': 675.00,
      'date': 'Yesterday, 16:45 PM',
      'rate': '1.5%',
    },
    {
      'id': 'REV-9818',
      'source': 'ePhyto Customs Certificate Fee',
      'origin': 'Export Batch #EXP-8812 • Citrus Inspection',
      'amountUsd': 15.00,
      'date': '05 Aug 2026',
      'rate': 'Flat',
    },
    {
      'id': 'REV-9817',
      'source': 'Smart Irrigation Solenoid Telemetry Fee',
      'origin': 'Zone 2 Solenoid Telemetry • Lowveld Sugar Grid',
      'amountUsd': 1.20,
      'date': '04 Aug 2026',
      'rate': 'Per Pulse',
    },
  ];

  // Super Admin Policy Simulator Controls
  double _platformFeeRate = 1.8; // %
  double _capitalReserveRatio = 25.0; // %
  double _loanDefaultProvision = 2.0; // %
  double _discountRate = 8.5; // %
  double _totalAumVolume = 14280000.0; // $14.28M USD

  // Bank Filter Lens
  String _selectedBankLens = 'All Institutions';

  final List<Map<String, String>> _pendingLoans = [
    {
      'id': 'LN-2026-0891',
      'farmer': 'Murewa Smallholder Cooperative',
      'amount': '\$45,000',
      'purpose': 'Drip Irrigation & Solar Pump Installation',
      'crop': 'Hass Avocados (120 Ha)',
      'score': '885 / 900 (AAA+)',
      'risk': 'Low',
      'status': 'Pending Approval',
      'bank': 'AFC Agribank',
    },
    {
      'id': 'LN-2026-0892',
      'farmer': 'Zvimba Commercial Grains Ltd',
      'amount': '\$120,000',
      'purpose': 'Compound D Fertilizer & Hybrid Maize Seed',
      'crop': 'White Maize (350 Ha)',
      'score': '840 / 900 (AAA)',
      'risk': 'Low',
      'status': 'Pending Approval',
      'bank': 'CBZ Bank',
    },
    {
      'id': 'LN-2026-0893',
      'farmer': 'Mutare Citrus Outgrowers',
      'amount': '\$28,500',
      'purpose': 'Cold Chain Refrigerated Transit Fleet',
      'crop': 'Valencia Oranges (80 Ha)',
      'score': '790 / 900 (AA)',
      'risk': 'Medium',
      'status': 'Underwriting Review',
      'bank': 'Stanbic Bank',
    },
    {
      'id': 'LN-2026-0894',
      'farmer': 'Mazowe Horticulture Trust',
      'amount': '\$65,000',
      'purpose': 'Greenhouse Poly-Tunnel Expansion',
      'crop': 'Cherry Tomatoes (45 Ha)',
      'score': '860 / 900 (AAA)',
      'risk': 'Low',
      'status': 'Pending Approval',
      'bank': 'Reserve Bank Ag-Desk',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1100;
    final role = ref.watch(appStateProvider).role;
    final isInstitutionalAllowed = role == UserRole.admin || role == UserRole.financier || role == UserRole.government;

    // Show Personal Agri-Wallet view for regular users (Driver, Farmer, Buyer, Expert, etc.)
    if (!isInstitutionalAllowed || !_showInstitutionalView) {
      return Scaffold(
        backgroundColor: background,
        body: SafeArea(
          child: Column(
            children: [
              _buildPersonalWalletHeader(role, isInstitutionalAllowed),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1100),
                    child: _buildPersonalWalletContent(role),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            // ─────────────────────────────────────────────────────────────────
            // Institutional Banking & Admin Live Ticker Pulse
            // ─────────────────────────────────────────────────────────────────
            Container(
              width: double.infinity,
              color: dark,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF22C55E),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'INSTITUTIONAL BANKING & TREASURY PULSE: ',
                      style: GoogleFonts.inter(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF22C55E),
                        letterSpacing: 1.0,
                      ),
                    ),
                    Text(
                      'Total Assets Under Management (AUM): \$14.28M USD • Liquidity Ratio: 42.8% • Reserve Bank Clearing: ONLINE • Loan Default Risk: 0.42% • EUDR Green Bond Rating: AAA',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ─────────────────────────────────────────────────────────────────
            // Header & Role Indicator Bar
            // ─────────────────────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Institutional Finance & Treasury Hub',
                              style: GoogleFonts.inter(
                                fontSize: isDesktop ? 22 : 18,
                                fontWeight: FontWeight.w800,
                                color: dark,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: gold.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'SUPER ADMIN & BANK PORTAL',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: gold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Capital liquidity reserves, bank clearing rails, credit underwriting desk, and cross-border trade finance.',
                          style: GoogleFonts.inter(fontSize: 12, color: muted),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: _isCreatorKeyUnlocked
                        ? () => setState(() => _isCreatorKeyUnlocked = false)
                        : () => _showCreatorKeyDialog(),
                    icon: Icon(_isCreatorKeyUnlocked ? Icons.lock_open : Icons.lock_outlined, size: 16, color: _isCreatorKeyUnlocked ? green : gold),
                    label: Text(
                      _isCreatorKeyUnlocked ? '🔑 CREATOR KEY UNLOCKED' : '🔒 Creator Key (8899)',
                      style: TextStyle(color: _isCreatorKeyUnlocked ? green : gold, fontWeight: FontWeight.bold, fontSize: 11.5),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: _isCreatorKeyUnlocked ? green : gold),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (isInstitutionalAllowed) ...[
                    OutlinedButton.icon(
                      onPressed: () => setState(() => _showInstitutionalView = false),
                      icon: const Icon(Icons.account_balance_wallet_outlined, size: 16),
                      label: const Text('My Personal Wallet'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  ElevatedButton.icon(
                    onPressed: _exportTreasuryAuditReport,
                    icon: const Icon(Icons.picture_as_pdf_outlined, size: 16),
                    label: const Text('Export Audit Statement'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: dark,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // ─────────────────────────────────────────────────────────────────
            // Institutional Navigation Tabs
            // ─────────────────────────────────────────────────────────────────
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildTabChip(0, '🏛️ Multi-Tier Banking & Virtual Accounts', Icons.account_balance_outlined),
                    const SizedBox(width: 8),
                    _buildTabChip(1, '🔒 Universal Escrow & Multi-Party Split', Icons.lock_clock_outlined),
                    const SizedBox(width: 8),
                    _buildTabChip(2, '🛡️ Dual-Speed Credit & eWRS Collateral (${_pendingLoans.length})', Icons.verified_user_outlined),
                    const SizedBox(width: 8),
                    _buildTabChip(3, '📊 Portfolio Health & Syndicate', Icons.donut_large_outlined),
                    const SizedBox(width: 8),
                    _buildTabChip(4, '📜 Tiered KYC/KYB & Compliance', Icons.gavel_outlined),
                    const SizedBox(width: 8),
                    _buildTabChip(5, '⚡ Policy Simulator & Creator Income', Icons.tune_outlined),
                  ],
                ),
              ),
            ),
            const Divider(height: 1),

            // ─────────────────────────────────────────────────────────────────
            // Tab Contents
            // ─────────────────────────────────────────────────────────────────
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: SingleChildScrollView(
                    padding: MediaQuery.of(context).size.width < 600 ? const EdgeInsets.all(12) : const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_activeTab == 0) _buildMultiTierBankingTab(isDesktop),
                        if (_activeTab == 1) _buildUniversalEscrowTab(isDesktop),
                        if (_activeTab == 2) _buildDualSpeedCreditTab(isDesktop),
                        if (_activeTab == 3) _buildPortfolioRiskTab(isDesktop),
                        if (_activeTab == 4) _buildKycComplianceTab(isDesktop),
                        if (_activeTab == 5) _buildPolicyAndCreatorTab(),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabChip(int index, String label, IconData icon) {
    final isSelected = _activeTab == index;
    return InkWell(
      onTap: () => setState(() => _activeTab = index),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? dark : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 15, color: isSelected ? Colors.white : dark),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? Colors.white : dark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // TAB 0: MULTI-TIER BANKING & VIRTUAL ACCOUNTS
  // ───────────────────────────────────────────────────────────────────────────

  Widget _buildMultiTierBankingTab(bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // AUM & Multi-Tier Hero Card
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'MULTI-TIER VALUE CHAIN TREASURY (AUM)',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF38BDF8),
                      letterSpacing: 1.2,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF22C55E),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'ISO 20022 OPEN BANKING CONNECTED',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '\$14,280,000.00 USD',
                style: GoogleFonts.inter(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  _treasuryHeroBadge('Smallholder Pool: \$2.42M', Icons.nature_people_outlined),
                  _treasuryHeroBadge('Aggregator Vault: \$4.85M', Icons.store_outlined),
                  _treasuryHeroBadge('Off-taker Escrow: \$12.50M', Icons.account_balance_outlined),
                  _treasuryHeroBadge('Input Suppliers: \$1.80M', Icons.shopping_bag_outlined),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Virtual IBAN / Account Directory & Bulk Actions
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dedicated Virtual Accounts (vIBAN Directory)',
                  style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w800, color: dark),
                ),
                Text(
                  'Automated incoming & outgoing payment routing for ecosystem stakeholders.',
                  style: GoogleFonts.inter(fontSize: 12, color: muted),
                ),
              ],
            ),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () => _showBulkPaymentModal(),
                  icon: const Icon(Icons.flash_on, size: 15, color: green),
                  label: const Text('Execute Bulk Payouts', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: green)),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: green)),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () => _showLiquiditySweepModal(),
                  icon: const Icon(Icons.sync_alt, size: 15),
                  label: const Text('EOD Liquidity Sweep', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5)),
                  style: ElevatedButton.styleFrom(backgroundColor: dark, foregroundColor: Colors.white),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Virtual Accounts List
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black12),
          ),
          child: Column(
            children: [
              _vAccountRow('ZW-CBZ-8894-001', 'Kudakwashe Moyo (Farmer)', 'Smallholder Wallet', 'CBZ Bank', '\$2,450.00 USD', 'Active Rail'),
              const Divider(height: 1),
              _vAccountRow('ZW-AGRI-1001-BYR', 'FreshMart Procurement (Off-taker)', 'Enterprise Buyer Vault', 'Stanbic Bank', '\$145,000.00 USD', 'Active Rail'),
              const Divider(height: 1),
              _vAccountRow('ZW-STB-4412-TRP', 'Tafadzwa Freight (Transporter)', 'Logistics Operator', 'AFC Agribank', '\$18,920.00 USD', 'Active Rail'),
              const Divider(height: 1),
              _vAccountRow('ZW-NMB-9920-AGD', 'Mazowe Agro-Dealers Ltd (Input Supplier)', 'Input Voucher Clearing', 'NMB Bank', '\$42,800.00 USD', 'Active Rail'),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Integrated Partner Financial Institutions
        Text(
          'Integrated Partner Financial Institutions',
          style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w800, color: dark),
        ),
        Text(
          'Real-time liquidity clearing rails and central bank discount window connectivity.',
          style: GoogleFonts.inter(fontSize: 12, color: muted),
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(child: _bankCard('AFC Agribank 🏦', '\$5.20M Reserve', 'Direct Ag-Credit Rail', green, Icons.check_circle_outline)),
            const SizedBox(width: 12),
            Expanded(child: _bankCard('CBZ Bank 🏦', '\$4.15M Reserve', 'Institutional Clearing', green, Icons.check_circle_outline)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _bankCard('Stanbic Bank 🏦', '\$2.80M Reserve', 'Trade Guarantee Desk', const Color(0xFF2563EB), Icons.verified_outlined)),
            const SizedBox(width: 12),
            Expanded(child: _bankCard('Reserve Bank Ag-RTGS 🏛️', '\$2.13M Reserve', 'Central Settlement Rail', gold, Icons.account_balance_outlined)),
          ],
        ),
      ],
    );
  }

  Widget _vAccountRow(String iban, String owner, String tier, String bank, String balance, String status) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.qr_code_2, color: Color(0xFF2563EB), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(iban, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: dark)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(4)),
                      child: Text(tier, style: const TextStyle(fontSize: 10, color: muted, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text('$owner • $bank', style: const TextStyle(fontSize: 11.5, color: muted)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(balance, style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 13.5, color: green)),
              Text(status, style: const TextStyle(fontSize: 10.5, color: Color(0xFF2563EB), fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // TAB 1: UNIVERSAL ESCROW & MULTI-PARTY SPLIT ENGINE
  // ───────────────────────────────────────────────────────────────────────────

  Widget _buildUniversalEscrowTab(bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Multi-Party Escrow Nodes & Smart Contracts',
                  style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: dark),
                ),
                Text(
                  'Conditional fund locking, multi-signature sign-offs, and dynamic quality grade price adjustments.',
                  style: GoogleFonts.inter(fontSize: 12, color: muted),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: green.withOpacity(0.12), borderRadius: BorderRadius.circular(999)),
              child: Text('\$12.50M Total Active Escrow', style: GoogleFonts.inter(color: green, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Active Escrow Contract Node Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.black12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Contract #ESC-1001 • Grade-A Sugar Beans', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: dark)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: gold.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                    child: Text('Multi-Sig Pending (2/3)', style: TextStyle(color: gold, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text('Buyer: FreshMart Procurement • Locked in Bank Trust Account: \$14,500.00 USD', style: const TextStyle(fontSize: 12, color: muted)),
              const SizedBox(height: 16),

              // Multi-Party Fee Split Visualizer
              Text('AUTOMATED MULTI-PARTY PAYOUT SPLIT (ON FULFILLMENT):', style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w900, color: muted, letterSpacing: 0.8)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _payoutSplitChip('🌾 85% Farmer (Kudakwashe Moyo)', '\$12,325.00 USD', green)),
                  const SizedBox(width: 8),
                  Expanded(child: _payoutSplitChip('🚚 10% Logistics (Tafadzwa Freight)', '\$1,450.00 USD', const Color(0xFF2563EB))),
                  const SizedBox(width: 8),
                  Expanded(child: _payoutSplitChip('🛡️ 5% Escrow & Insurance Fee', '\$725.00 USD', dark)),
                ],
              ),
              const SizedBox(height: 16),

              // Conditional Milestones Track
              Text('CONDITIONAL VERIFICATION MILESTONES:', style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w900, color: muted, letterSpacing: 0.8)),
              const SizedBox(height: 8),
              _milestoneRow('IoT Geofence Arrival', 'GPS confirmed truck inside Mbare Warehouse', true),
              _milestoneRow('Moisture & Grade Lab Assay', '12.2% Moisture Content (Passed Grade-A Threshold)', true),
              _milestoneRow('Warehouse Receipt Sign-Off', 'eWRS-9920 Vault Receipt Issued & Verified', true),
              const SizedBox(height: 14),

              // Multi-Sig Action Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.check_circle, color: green, size: 16),
                      SizedBox(width: 4),
                      Text('Buyer Signed', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      SizedBox(width: 10),
                      Icon(Icons.check_circle, color: green, size: 16),
                      SizedBox(width: 4),
                      Text('Seller Signed', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      SizedBox(width: 10),
                      Icon(Icons.hourglass_empty, color: gold, size: 16),
                      SizedBox(width: 4),
                      Text('Trustee Sign-Off Pending', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: gold)),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Trustee signature applied! \$14,500 disbursed to 3 payout nodes.'), backgroundColor: green),
                      );
                    },
                    icon: const Icon(Icons.draw, size: 16),
                    label: const Text('Sign as Platform Trustee & Release', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(backgroundColor: green, foregroundColor: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Dispute Resolution & Arbitration Desk
        Text(
          'Escrow Dispute Resolution & Arbitration Trail',
          style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w800, color: dark),
        ),
        const SizedBox(height: 10),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.red.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.red.shade700, size: 20),
                      const SizedBox(width: 8),
                      Text('Dispute #DSP-104 • Frozen in Escrow (\$14,500 USD)', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.red.shade900, fontSize: 13.5)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(6)),
                    child: Text('Paued by Buyer', style: TextStyle(color: Colors.red.shade900, fontSize: 10.5, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text('Claimant: FreshMart Buyer • Issue: Moisture Content Variance (13.1% vs 12.5% spec limit). Audit trail logged.', style: TextStyle(fontSize: 12, color: Colors.red.shade800)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => _showDisputeResolutionModal(),
                    child: const Text('Review Digital Lab Certificate & Arbitrate', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _payoutSplitChip(String label, String amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color), overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text(amount, style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w900, color: color)),
        ],
      ),
    );
  }

  Widget _milestoneRow(String title, String status, bool done) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(done ? Icons.check_circle : Icons.radio_button_unchecked, color: done ? green : muted, size: 16),
          const SizedBox(width: 8),
          Text('$title: ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: dark)),
          Text(status, style: const TextStyle(fontSize: 12, color: muted)),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // TAB 2: DUAL-SPEED CREDIT & eWRS COLLATERAL VAULT
  // ───────────────────────────────────────────────────────────────────────────

  Widget _buildDualSpeedCreditTab(bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dual-Speed Agricultural Credit & Loan Lifecycle Engine',
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: dark),
        ),
        Text(
          'Tailored underwriting profiles for smallholder outgrowers versus commercial enterprises.',
          style: GoogleFonts.inter(fontSize: 12, color: muted),
        ),
        const SizedBox(height: 16),

        // Dual Speed Architecture Comparison Grid
        Row(
          children: [
            Expanded(
              child: _creditSegmentCard(
                'Smallholder Farmer Segment',
                'Alternative AI Credit Scoring',
                'NDVI satellite vegetation index, mobile money history & harvest yield forecasts.',
                'Disbursement: Closed-Loop Digital Vouchers sent to certified Agro-dealers for seeds & fertilizer.',
                'Repayment: Single Bullet Repayment tied exactly to harvest date.',
                const Color(0xFF16A34A),
                Icons.nature_people_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _creditSegmentCard(
                'Commercial Enterprise Segment',
                'Traditional Corporate Underwriting',
                'Audited balance sheets, tax returns, equipment depreciation & forward off-take contracts.',
                'Disbursement: Direct Capital Lines & Fleet Asset Financing for tractors, trucks & machinery.',
                'Repayment: Structured Monthly / Quarterly Amortization Schedules.',
                const Color(0xFF2563EB),
                Icons.business_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Warehouse Receipt System (eWRS) & Collateral Vault
        Text(
          'Warehouse Receipt System (eWRS) & Collateral Vault',
          style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w800, color: dark),
        ),
        Text(
          'Encumbered digital warehouse receipts, RFID livestock tags, and chattel mortgages.',
          style: GoogleFonts.inter(fontSize: 12, color: muted),
        ),
        const SizedBox(height: 12),

        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black12),
          ),
          child: Column(
            children: [
              _collateralRow('eWRS-9920', 'Grade-A Sugar Beans (50 Tonnes)', 'Mbare Grain Silo Vault #4', '\$60,000 USD', '75% Max LTV', '\$45,000 Credit Limit', 'Encumbered (AFC Agribank)', green),
              const Divider(height: 1),
              _collateralRow('eWRS-9921', 'White Maize Grain (120 Tonnes)', 'Banket Commercial Depot', '\$40,200 USD', '80% Max LTV', '\$32,160 Credit Limit', 'Unencumbered (Available)', const Color(0xFF2563EB)),
              const Divider(height: 1),
              _collateralRow('TAG-LVS-441', '45 Head Cattle (RFID-9912 Tags)', 'Mazowe Citrus Plot Ranch', '\$38,000 USD', '60% Max LTV', '\$22,800 Credit Limit', 'Chattel Mortgage Active', gold),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Actionable Loans Desk
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Underwriting & Credit Approval Queue',
              style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w800, color: dark),
            ),
            DropdownButton<String>(
              value: _selectedBankLens,
              items: ['All Institutions', 'AFC Agribank', 'CBZ Bank', 'Stanbic Bank', 'Reserve Bank Ag-Desk']
                  .map((b) => DropdownMenuItem(value: b, child: Text(b, style: const TextStyle(fontSize: 12))))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _selectedBankLens = v);
              },
            ),
          ],
        ),
        const SizedBox(height: 12),

        for (int i = 0; i < _pendingLoans.length; i++) ...[
          _buildLoanCard(_pendingLoans[i], i),
          if (i != _pendingLoans.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _buildLoanCard(Map<String, String> loan, int index) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${loan['id']} • ${loan['farmer']}',
                  style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: dark),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: green.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  loan['score']!,
                  style: GoogleFonts.inter(color: green, fontSize: 11, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${loan['amount']} USD • ${loan['purpose']}',
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: dark),
          ),
          const SizedBox(height: 4),
          Text(
            'Crop: ${loan['crop']} • Bank Rail: ${loan['bank']}',
            style: const TextStyle(fontSize: 12, color: muted),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed: () => _rejectLoan(index),
                icon: const Icon(Icons.close_outlined, size: 16, color: Colors.redAccent),
                label: const Text('Reject Application', style: TextStyle(color: Colors.redAccent, fontSize: 12)),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: () => _approveLoan(index),
                icon: const Icon(Icons.check_circle_outline, size: 16),
                label: const Text('Approve & Disburse Capital', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _approveLoan(int index) {
    final loan = _pendingLoans[index];
    setState(() {
      _pendingLoans.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('APPROVED ${loan['id']}: ${loan['amount']} disbursed via ${loan['bank']}!'),
        backgroundColor: green,
      ),
    );
  }

  void _rejectLoan(int index) {
    final loan = _pendingLoans[index];
    setState(() {
      _pendingLoans.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('REJECTED ${loan['id']} - Returned to risk underwriting desk.'),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  Widget _creditSegmentCard(String title, String scoring, String detail, String disb, String repay, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
          const SizedBox(height: 8),
          Text('Score Engine: $scoring', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12, color: dark)),
          const SizedBox(height: 4),
          Text(detail, style: const TextStyle(fontSize: 11.5, color: muted)),
          const SizedBox(height: 8),
          Text(disb, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: dark)),
          const SizedBox(height: 2),
          Text(repay, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: dark)),
        ],
      ),
    );
  }

  Widget _collateralRow(String code, String name, String loc, String val, String ltv, String limit, String status, Color color) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(Icons.shield_outlined, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('$code • $name', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: dark)),
                    const SizedBox(width: 8),
                    Text(ltv, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: color)),
                  ],
                ),
                const SizedBox(height: 2),
                Text('$loc • Valuation: $val', style: const TextStyle(fontSize: 11.5, color: muted)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(limit, style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 13, color: dark)),
              Text(status, style: TextStyle(fontSize: 10.5, color: color, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // TAB 3: PORTFOLIO HEALTH & CO-LENDING SYNDICATE
  // ───────────────────────────────────────────────────────────────────────────

  Widget _buildPortfolioRiskTab(bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Portfolio Health, Risk Exposure & Co-Lending Syndicates',
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: dark),
        ),
        Text(
          'Real-time Portfolio at Risk (PAR) monitoring and multi-bank loan syndication exposure.',
          style: GoogleFonts.inter(fontSize: 12, color: muted),
        ),
        const SizedBox(height: 16),

        // PAR KPI Strip
        Row(
          children: [
            Expanded(child: _kpiCard('Portfolio Volume', '\$14.28M USD', '100% Total AUM', dark, Icons.account_balance)),
            const SizedBox(width: 10),
            Expanded(child: _kpiCard('PAR 30 Days', '0.42%', '14 Accounts Flagged', green, Icons.check_circle_outline)),
            const SizedBox(width: 10),
            Expanded(child: _kpiCard('PAR 60 Days', '0.18%', '5 Accounts Review', gold, Icons.warning_amber)),
            const SizedBox(width: 10),
            Expanded(child: _kpiCard('NPL Default Ratio', '0.05%', 'Low Exposure', const Color(0xFF2563EB), Icons.shield)),
          ],
        ),
        const SizedBox(height: 20),

        // Co-Lending Syndicate Exposure Grid
        Text(
          'Co-Lending Syndicate Risk Sharing Exposure',
          style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w800, color: dark),
        ),
        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.black12),
          ),
          child: Column(
            children: [
              _syndicateRow('AFC Agribank', 40.0, '\$5,712,000 USD', 'Maize & Wheat Grains', 'Lead Arranger', green),
              const Divider(height: 1),
              _syndicateRow('CBZ Bank', 35.0, '\$4,998,000 USD', 'Sugar Beans & Soybeans', 'Co-Underwriter', green),
              const Divider(height: 1),
              _syndicateRow('Stanbic Bank', 15.0, '\$2,142,000 USD', 'Citrus & Horticultural Exports', 'Participant', const Color(0xFF2563EB)),
              const Divider(height: 1),
              _syndicateRow('Verdi Capital Pool', 10.0, '\$1,428,000 USD', 'First-Loss Default Reserve', 'Platform Equity', gold),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Drought & Rainfall Stress Testing Simulator
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF1E293B)]),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('DROUGHT & RAINFALL STRESS TESTING SIMULATOR', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w900, color: const Color(0xFF38BDF8), letterSpacing: 1.0)),
              const SizedBox(height: 12),
              Text('Simulate Lowveld Regional Rainfall Deficit (-15% to -40%):', style: const TextStyle(color: Colors.white, fontSize: 13)),
              Slider(
                value: _loanDefaultProvision,
                min: 0.5,
                max: 10.0,
                activeColor: const Color(0xFF38BDF8),
                onChanged: (v) => setState(() => _loanDefaultProvision = v),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _simMetric('Simulated PAR Increase', '+${(_loanDefaultProvision * 0.15).toStringAsFixed(2)}%', const Color(0xFFFACC15)),
                  _simMetric('Required Loss Provision Buffer', '\$${(_totalAumVolume * (_loanDefaultProvision / 100)).toStringAsFixed(0)} USD', Colors.orangeAccent),
                  _simMetric('Syndicate Solvency Ratio', '99.4% Pass', const Color(0xFF22C55E)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _syndicateRow(String bank, double share, String exp, String crop, String role, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(Icons.account_balance, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$bank ($share%)', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13.5, color: dark)),
                Text('Crop Focus: $crop', style: const TextStyle(fontSize: 11.5, color: muted)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(exp, style: GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 13.5, color: color)),
              Text(role, style: const TextStyle(fontSize: 10.5, color: muted, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // TAB 4: TIERED KYC/KYB & REGULATORY COMPLIANCE
  // ───────────────────────────────────────────────────────────────────────────

  Widget _buildKycComplianceTab(bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tiered KYC / KYB Onboarding & AML Sanctions Screening',
                  style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: dark),
                ),
                Text(
                  'Central Bank (RBZ) & Ministry of Agriculture regulatory reporting engine.',
                  style: GoogleFonts.inter(fontSize: 12, color: muted),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () => _exportCentralBankComplianceReport(),
              icon: const Icon(Icons.assignment_turned_in_outlined, size: 16),
              label: const Text('Export Central Bank Report (ISO 20022)', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(backgroundColor: dark, foregroundColor: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Tiered KYC/KYB Cards
        Row(
          children: [
            Expanded(child: _kycTierCard('Tier 1: Smallholders', '14,250 Verified', 'National ID + Mobile Selfie', green, Icons.person_outline)),
            const SizedBox(width: 10),
            Expanded(child: _kycTierCard('Tier 2: SMEs & Logistics', '420 Verified', 'Tax Clearance + Corporate Registry', const Color(0xFF2563EB), Icons.local_shipping_outlined)),
            const SizedBox(width: 10),
            Expanded(child: _kycTierCard('Tier 3: Enterprises & Banks', '38 Verified', 'KYB + UBO Registry + Global AML', gold, Icons.account_balance_outlined)),
          ],
        ),
        const SizedBox(height: 20),

        // Automated AML Watchlist Screening Audit Trail
        Text(
          'Automated Sanction & AML Watchlist Audit Log (Real-Time)',
          style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w800, color: dark),
        ),
        const SizedBox(height: 12),

        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black12),
          ),
          child: Column(
            children: [
              _amlRow('2026-08-24 10:14', 'TX-9981', 'FreshMart Procurement', '\$145,000 USD', 'OFAC / SADC Watchlist', 'CLEARED (0 Match)', green),
              const Divider(height: 1),
              _amlRow('2026-08-24 09:30', 'TX-9980', 'Lowveld Outgrowers Trust', '\$85,000 USD', 'PEP / UBO Registry', 'CLEARED (Tier 3 Valid)', green),
              const Divider(height: 1),
              _amlRow('2026-08-23 16:45', 'TX-9979', 'Murewa Coop Drip Loan', '\$45,000 USD', 'Transaction Velocity Audit', 'CLEARED (Low Risk)', green),
            ],
          ),
        ),
      ],
    );
  }

  Widget _kycTierCard(String title, String count, String req, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13.5, color: dark)),
          const SizedBox(height: 2),
          Text(count, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w900, color: color)),
          const SizedBox(height: 4),
          Text(req, style: const TextStyle(fontSize: 11, color: muted)),
        ],
      ),
    );
  }

  Widget _amlRow(String time, String txId, String party, String amt, String check, String result, Color color) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Icon(Icons.shield_moon_outlined, color: color, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$txId • $party ($amt)', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: dark)),
                Text('Check: $check • Time: $time', style: const TextStyle(fontSize: 11.5, color: muted)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
            child: Text(result, style: TextStyle(color: color, fontSize: 10.5, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _treasuryHeroBadge(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF38BDF8)),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _bankCard(String name, String reserve, String status, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  name,
                  style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.bold, color: dark),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            reserve,
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w900, color: color),
          ),
          const SizedBox(height: 2),
          Text(status, style: const TextStyle(fontSize: 11, color: muted)),
        ],
      ),
    );
  }

  Widget _kpiCard(String label, String value, String sub, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 11.5, color: muted, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w900, color: color)),
          const SizedBox(height: 2),
          Text(sub, style: const TextStyle(fontSize: 10.5, color: muted)),
        ],
      ),
    );
  }

  Widget _simMetric(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.white60)),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildAdminPolicySimulatorTab() {
    final netPlatformFeeIncome = _totalAumVolume * (_platformFeeRate / 100);
    final capitalReserveBuffer = _totalAumVolume * (_capitalReserveRatio / 100);
    final defaultProvisionFund = _totalAumVolume * (_loanDefaultProvision / 100);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Super Admin Policy & Yield Control Simulator',
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: dark),
        ),
        Text(
          'Adjust platform escrow fee rates, capital reserve ratios, and discount windows in real time.',
          style: GoogleFonts.inter(fontSize: 12, color: muted),
        ),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.black12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('SUPER ADMIN TREASURY POLICY CONTROLS', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w900, color: green, letterSpacing: 1.0)),
              const SizedBox(height: 14),

              Text('Platform Escrow Fee Rate: ${_platformFeeRate.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: dark)),
              Slider(
                value: _platformFeeRate,
                min: 0.5,
                max: 5.0,
                activeColor: green,
                onChanged: (v) => setState(() => _platformFeeRate = v),
              ),

              Text('Capital Reserve Ratio: ${_capitalReserveRatio.toStringAsFixed(0)}%', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: dark)),
              Slider(
                value: _capitalReserveRatio,
                min: 10.0,
                max: 50.0,
                activeColor: const Color(0xFF2563EB),
                onChanged: (v) => setState(() => _capitalReserveRatio = v),
              ),

              Text('Loan Default Provision: ${_loanDefaultProvision.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: dark)),
              Slider(
                value: _loanDefaultProvision,
                min: 0.5,
                max: 10.0,
                activeColor: Colors.orange,
                onChanged: (v) => setState(() => _loanDefaultProvision = v),
              ),

              Text('Central Bank Discount Rate: ${_discountRate.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: dark)),
              Slider(
                value: _discountRate,
                min: 2.0,
                max: 20.0,
                activeColor: const Color(0xFF7C3AED),
                onChanged: (v) => setState(() => _discountRate = v),
              ),

              Text('Simulated AUM Portfolio Volume: \$${(_totalAumVolume / 1000000.0).toStringAsFixed(1)}M USD', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: dark)),
              Slider(
                value: _totalAumVolume,
                min: 1000000.0,
                max: 50000000.0,
                activeColor: const Color(0xFF0EA5E9),
                onChanged: (v) => setState(() => _totalAumVolume = v),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF1E293B)]), borderRadius: BorderRadius.circular(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('SIMULATED INSTITUTIONAL OUTCOMES', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w900, color: const Color(0xFF22C55E), letterSpacing: 1.0)),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _simMetric('Net Platform Revenue', '\$${netPlatformFeeIncome.toStringAsFixed(0)}', const Color(0xFF22C55E)),
                  _simMetric('Capital Reserve Fund', '\$${capitalReserveBuffer.toStringAsFixed(0)}', const Color(0xFF38BDF8)),
                  _simMetric('Loss Provision Buffer', '\$${defaultProvisionFund.toStringAsFixed(0)}', Colors.orangeAccent),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // TAB 5: POLICY SIMULATOR & CREATOR INCOME
  // ───────────────────────────────────────────────────────────────────────────

  Widget _buildPolicyAndCreatorTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAdminPolicySimulatorTab(),
        const SizedBox(height: 24),
        _buildCreatorIncomeTab(ref.watch(appStateProvider).currency),
      ],
    );
  }

  // Helper Modals
  void _showBulkPaymentModal() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.flash_on, color: green, size: 24),
            SizedBox(width: 8),
            Text('Bulk Outgrower Payout Engine'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Disburse bulk harvest proceeds or input loan allowances directly to smallholders:'),
            SizedBox(height: 12),
            Text('• Batch: 1,250 Outgrowers (Mazowe & Chiredzi Clusters)'),
            Text('• Total Disbursement: \$485,000.00 USD'),
            Text('• Channels: EcoCash Mobile Money (65%), CBZ Zipit (35%)'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bulk Payout of \$485,000 USD executed to 1,250 outgrowers!'), backgroundColor: green),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: green, foregroundColor: Colors.white),
            child: const Text('Execute Bulk Payout Now'),
          ),
        ],
      ),
    );
  }

  void _showLiquiditySweepModal() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.sync_alt, color: dark, size: 24),
            SizedBox(width: 8),
            Text('Automated End-Of-Day Liquidity Sweep'),
          ],
        ),
        content: const Text('Pool funds from 48 regional collection accounts into central CBZ Bank corporate treasury account (\$14.28M USD AUM).'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('EOD Liquidity Sweep completed successfully!'), backgroundColor: dark),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: dark, foregroundColor: Colors.white),
            child: const Text('Execute EOD Sweep'),
          ),
        ],
      ),
    );
  }

  void _showDisputeResolutionModal() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.gavel, color: Colors.redAccent, size: 24),
            SizedBox(width: 8),
            Text('Arbitrate Dispute #DSP-104'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Lab Assay Result: 13.1% Moisture Content (0.6% over 12.5% max spec threshold).'),
            SizedBox(height: 10),
            Text('Recommended Arbitration Action: Apply 2.5% moisture drying price deduction (\$362.50 USD) and release balance (\$14,137.50 USD) to Kudakwashe Moyo.'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Dispute Arbitrated: \$14,137.50 USD released to farmer with lab adjustment.'), backgroundColor: green),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: green, foregroundColor: Colors.white),
            child: const Text('Apply Arbitrated Settlement'),
          ),
        ],
      ),
    );
  }

  void _exportCentralBankComplianceReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exported RBZ & Agricultural Ministry Compliance Audit PDF (ISO 20022 format).'), backgroundColor: dark),
    );
  }

  Widget _buildPersonalWalletHeader(UserRole role, bool isInstitutionalAllowed) {
    final currency = ref.watch(appStateProvider).currency;
    final appNotifier = ref.read(appStateProvider.notifier);
    final isNarrow = MediaQuery.of(context).size.width < 650;

    String title = 'Personal Agri-Wallet & Digital Earnings';
    if (role == UserRole.transporter) {
      title = 'Transporter Freight Payout & Fleet Wallet';
    } else if (role == UserRole.farmer) {
      title = 'Farmer Agri-Wallet & Inputs Fund';
    } else if (role == UserRole.buyer) {
      title = 'Buyer Escrow & Procurement Wallet';
    } else if (role == UserRole.expert) {
      title = 'Agri-Expert Advisory Earnings Wallet';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.black12)),
      ),
      child: isNarrow
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: dark,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: green.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${role.label.toUpperCase()} DESK',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: green,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Manage payout settlements in ZiG, USD & ZAR, mobile money transfers, and credit lines.',
                  style: GoogleFonts.inter(fontSize: 12, color: muted),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<AppCurrency>(
                          value: currency,
                          isDense: true,
                          menuMaxHeight: 200,
                          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: dark),
                          onChanged: (c) {
                            if (c != null) appNotifier.setCurrency(c);
                          },
                          items: AppCurrency.values.map((c) {
                            return DropdownMenuItem<AppCurrency>(
                              value: c,
                              child: Text('${c.flag} ${c.code}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    if (isInstitutionalAllowed)
                      ElevatedButton.icon(
                        onPressed: () => setState(() => _showInstitutionalView = true),
                        icon: const Icon(Icons.account_balance_outlined, size: 16),
                        label: const Text('Institutional Treasury Hub'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: dark,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                  ],
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: dark,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: green.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${role.label.toUpperCase()} DESK',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: green,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Manage payout settlements in ZiG, USD & ZAR, mobile money transfers, and credit lines.',
                        style: GoogleFonts.inter(fontSize: 12, color: muted),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<AppCurrency>(
                      value: currency,
                      isDense: true,
                      menuMaxHeight: 200,
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: dark),
                      onChanged: (c) {
                        if (c != null) appNotifier.setCurrency(c);
                      },
                      items: AppCurrency.values.map((c) {
                        return DropdownMenuItem<AppCurrency>(
                          value: c,
                          child: Text('${c.flag} ${c.code}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                if (isInstitutionalAllowed)
                  ElevatedButton.icon(
                    onPressed: () => setState(() => _showInstitutionalView = true),
                    icon: const Icon(Icons.account_balance_outlined, size: 16),
                    label: const Text('Institutional Treasury Hub'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: dark,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildPersonalWalletContent(UserRole role) {
    final currency = ref.watch(appStateProvider).currency;
    final balanceText = currency.format(_userWalletBalanceUsd);
    final pendingText = currency.format(380.00);
    final creditText = currency.format(5000.00);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Balance Summary Card
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'TOTAL AVAILABLE BALANCE (${currency.code})',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF4ADE80),
                      letterSpacing: 1.0,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.verified_user_outlined, color: Colors.white70, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          'ZiG & Multi-Currency Pay',
                          style: GoogleFonts.inter(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                balanceText,
                style: GoogleFonts.inter(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '+$pendingText pending escrow release',
                style: GoogleFonts.inter(fontSize: 12, color: Colors.white70),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 10,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _showWithdrawDialog(context, currency),
                    icon: const Icon(Icons.arrow_upward_rounded, size: 16),
                    label: Text('Withdraw (${currency.code} / EcoCash / OneMoney)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _showTopUpDialog(context, currency),
                    icon: const Icon(Icons.arrow_downward_rounded, size: 16),
                    label: const Text('Top Up Wallet'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white38),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // 2. Personal Credit Rating & Trust Index
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: green.withOpacity(0.12),
                child: const Icon(Icons.shield_outlined, color: green, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Personal Agri-Credit Score: 780 / 900 (AA Rated)',
                      style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: dark),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Pre-Approved Credit Line: $creditText for instant input purchasing & fuel advance.',
                      style: GoogleFonts.inter(fontSize: 12, color: muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // 3. Transactions History
        Text(
          'Recent Earnings & Wallet Transactions',
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: dark),
        ),
        const SizedBox(height: 12),
        ..._userTransactionsList.map((tx) {
          final amtUsd = tx['amountUsd'] as double;
          final isInc = tx['isIncome'] as bool;
          final formattedAmt = '${isInc ? '+' : ''}${currency.format(amtUsd)}';
          return _buildTransactionRow(
            tx['title'] as String,
            tx['subtitle'] as String,
            formattedAmt,
            tx['date'] as String,
            isInc,
          );
        }),
      ],
    );
  }

  Widget _buildTransactionRow(String title, String subtitle, String amount, String date, bool isIncome) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: isIncome ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9),
                child: Icon(
                  isIncome ? Icons.south_west_rounded : Icons.north_east_rounded,
                  size: 18,
                  color: isIncome ? green : dark,
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.bold, color: dark)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: GoogleFonts.inter(fontSize: 11, color: muted)),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: GoogleFonts.inter(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: isIncome ? green : dark,
                ),
              ),
              const SizedBox(height: 2),
              Text(date, style: GoogleFonts.inter(fontSize: 10.5, color: muted)),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _exportTreasuryAuditReport() async {
    if (!_isCreatorKeyUnlocked) {
      _showCreatorKeyDialog(onSuccess: _exportTreasuryAuditReport);
      return;
    }
    try {
      final file = await AnalyticsExportService.exportOrderSummary(
        orders: [
          {
            'id': 'AUDIT-2026-Q3',
            'buyer': 'Verdi Institutional Treasury Desk',
            'product': 'AUM Escrow & Capital Reserves',
            'quantity': '\$14.28M USD',
            'destination': 'Reserve Bank & Partner Banks',
            'status': 'AUDITED & SECURED',
            'payment': 'SADC RTGS / Nostro Vault',
            'total': '\$14,280,000',
            'date': '2026-07-24',
            'eta': 'Compliant',
            'priority': 'High Priority',
          }
        ],
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Exported Treasury Audit to ${file.path}'), backgroundColor: green),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _showCreatorKeyDialog({VoidCallback? onSuccess}) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: const [
              Icon(Icons.vpn_key_outlined, color: gold, size: 24),
              SizedBox(width: 10),
              Text('Creator Master Security Key'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter 4-digit Creator Security Key (Passcode: 8899) to unlock creator profit logs and perform administrative disbursements.',
                style: TextStyle(fontSize: 12.5, color: muted),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: controller,
                obscureText: true,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Security Passcode (8899)',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final text = controller.text.trim();
                if (text == '8899' || text == 'VERDI-CREATOR-8899' || text == 'admin8899') {
                  setState(() {
                    _isCreatorKeyUnlocked = true;
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('🔑 Creator Security Key Verified! Operational controls & revenue logs unlocked.'),
                      backgroundColor: green,
                    ),
                  );
                  if (onSuccess != null) onSuccess();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('❌ Invalid Passcode. Access denied.'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: gold,
                foregroundColor: Colors.white,
              ),
              child: const Text('Unlock Key'),
            ),
          ],
        );
      },
    );
  }

  void _showTopUpDialog(BuildContext context, AppCurrency currency) {
    final amountController = TextEditingController(text: '100');
    final phoneController = TextEditingController(text: '+263 77 123 4567');
    String selectedMethod = 'EcoCash Mobile Money';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: const [
                  Icon(Icons.arrow_downward_rounded, color: green, size: 24),
                  SizedBox(width: 10),
                  Text('Wallet Top Up'),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Deposit funds into your Agri-Wallet (${currency.code})', style: const TextStyle(fontSize: 12, color: muted)),
                    const SizedBox(height: 14),
                    TextField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Top Up Amount (${currency.code})',
                        prefixText: currency.symbol,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text('Payment Channel:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: dark)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: selectedMethod,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: ['EcoCash Mobile Money', 'OneMoney Transfer', 'Zipit Bank Transfer', 'Mastercard / Visa']
                          .map((m) => DropdownMenuItem(value: m, child: Text(m, style: const TextStyle(fontSize: 12))))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setDialogState(() => selectedMethod = v);
                      },
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: phoneController,
                      decoration: InputDecoration(
                        labelText: 'Phone / Account Number',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () {
                    final entered = double.tryParse(amountController.text.trim()) ?? 100.0;
                    final enteredUsd = entered / currency.rateToUsd;
                    setState(() {
                      _userWalletBalanceUsd += enteredUsd;
                      _userTransactionsList.insert(0, {
                        'title': 'Wallet Top Up via $selectedMethod',
                        'subtitle': 'Completed • Deposit',
                        'amountUsd': enteredUsd,
                        'date': 'Just Now',
                        'isIncome': true,
                      });
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('🎉 Top Up Successful! ${currency.format(enteredUsd)} added to your wallet.'),
                        backgroundColor: green,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: green, foregroundColor: Colors.white),
                  child: const Text('Confirm & Deposit'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showWithdrawDialog(BuildContext context, AppCurrency currency) {
    final amountController = TextEditingController(text: '50');
    final phoneController = TextEditingController(text: '+263 78 323 7918');
    String selectedMethod = 'EcoCash USD/ZiG Wallet';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: const [
                  Icon(Icons.arrow_upward_rounded, color: green, size: 24),
                  SizedBox(width: 10),
                  Text('Wallet Withdrawal'),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Withdraw funds to mobile money or bank (${currency.code})', style: const TextStyle(fontSize: 12, color: muted)),
                    const SizedBox(height: 14),
                    TextField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Withdrawal Amount (${currency.code})',
                        prefixText: currency.symbol,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text('Destination Channel:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: dark)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: selectedMethod,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: ['EcoCash USD/ZiG Wallet', 'OneMoney Wallet', 'FCA Bank Account Transfer', 'Cash Pickup (Mukuru/Inno8)']
                          .map((m) => DropdownMenuItem(value: m, child: Text(m, style: const TextStyle(fontSize: 12))))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setDialogState(() => selectedMethod = v);
                      },
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: phoneController,
                      decoration: InputDecoration(
                        labelText: 'Recipient Phone / Account',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () {
                    final entered = double.tryParse(amountController.text.trim()) ?? 50.0;
                    final enteredUsd = entered / currency.rateToUsd;
                    if (enteredUsd > _userWalletBalanceUsd) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('❌ Insufficient balance. Available: ${currency.format(_userWalletBalanceUsd)}'),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                      return;
                    }
                    setState(() {
                      _userWalletBalanceUsd -= enteredUsd;
                      _userTransactionsList.insert(0, {
                        'title': 'Wallet Withdrawal to $selectedMethod',
                        'subtitle': 'Processing • Payout',
                        'amountUsd': -enteredUsd,
                        'date': 'Just Now',
                        'isIncome': false,
                      });
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('💸 Withdrawal Dispatched! ${currency.format(enteredUsd)} sent to $selectedMethod.'),
                        backgroundColor: green,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: green, foregroundColor: Colors.white),
                  child: const Text('Confirm Withdrawal'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildCreatorIncomeTab(AppCurrency currency) {
    if (!_isCreatorKeyUnlocked) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: gold.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: gold.withOpacity(0.12),
              child: const Icon(Icons.lock_outlined, color: gold, size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              '🔒 Creator Income & Revenue Origin Logs Locked',
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: dark),
            ),
            const SizedBox(height: 8),
            const Text(
              'Detailed platform earnings logs, automated 3% transaction take-rates, and creator profit streams require entering the 4-digit Creator Security Key.',
              textAlign: TextAlign.center,
              style: TextStyle(color: muted, fontSize: 13),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _showCreatorKeyDialog(),
              icon: const Icon(Icons.vpn_key_outlined, size: 18),
              label: const Text('Enter Creator Security Key (8899)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: gold,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      );
    }

    final totalProfitUsd = _creatorRevenueLogs.fold<double>(0, (s, e) => s + (e['amountUsd'] as double));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hero Profit Card
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'TOTAL VERDI CREATOR NET REVENUE',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFFF59E0B),
                      letterSpacing: 1.2,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: gold.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.vpn_key, color: gold, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          'KEY UNLOCKED',
                          style: TextStyle(color: gold, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                currency.format(totalProfitUsd),
                style: GoogleFonts.inter(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Automated 3.0% platform take-rate & service fee accumulation across all 25 modules',
                style: GoogleFonts.inter(fontSize: 12, color: Colors.white70),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Origin Logs Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Itemized Revenue Source Origin Logs',
              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: dark),
            ),
            Chip(
              label: Text('${_creatorRevenueLogs.length} Verified Entries', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
              backgroundColor: green,
              side: BorderSide.none,
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Itemized Logs Table
        ..._creatorRevenueLogs.map((log) {
          final amtUsd = log['amountUsd'] as double;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: gold.withOpacity(0.12),
                  child: Icon(Icons.monetization_on_outlined, color: gold, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(log['source'], style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.bold, color: dark)),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(log['rate'], style: TextStyle(color: green, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(log['origin'], style: GoogleFonts.inter(fontSize: 11.5, color: muted)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '+${currency.format(amtUsd)}',
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w900, color: green),
                    ),
                    const SizedBox(height: 2),
                    Text(log['date'], style: GoogleFonts.inter(fontSize: 10.5, color: muted)),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}