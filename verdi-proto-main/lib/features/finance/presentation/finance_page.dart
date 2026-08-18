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
                    _buildTabChip(0, '🏛️ Institutional Treasury & Vaults', Icons.account_balance_outlined),
                    const SizedBox(width: 8),
                    _buildTabChip(1, '🛡️ Credit Underwriting & Loans (${_pendingLoans.length})', Icons.verified_user_outlined),
                    const SizedBox(width: 8),
                    _buildTabChip(2, '🌐 Cross-Border Trade & SADC Desk', Icons.public_outlined),
                    const SizedBox(width: 8),
                    _buildTabChip(3, '🌿 Carbon ESG Green Financing', Icons.eco_outlined),
                    const SizedBox(width: 8),
                    _buildTabChip(4, '⚡ Super Admin Policy Simulator', Icons.tune_outlined),
                    const SizedBox(width: 8),
                    _buildTabChip(5, _isCreatorKeyUnlocked ? '💎 Creator Income Logs' : '🔒 Creator Income (Locked)', Icons.monetization_on_outlined),
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
                        if (_activeTab == 0) _buildTreasuryVaultTab(isDesktop),
                        if (_activeTab == 1) _buildCreditUnderwritingTab(isDesktop),
                        if (_activeTab == 2) _buildCrossBorderDeskTab(),
                        if (_activeTab == 3) _buildCarbonEsgTab(),
                        if (_activeTab == 4) _buildAdminPolicySimulatorTab(),
                        if (_activeTab == 5) _buildCreatorIncomeTab(ref.watch(appStateProvider).currency),
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
  // TAB 0: INSTITUTIONAL TREASURY & VAULTS
  // ───────────────────────────────────────────────────────────────────────────

  Widget _buildTreasuryVaultTab(bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // AUM & Liquidity Hero Card
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
                color: Colors.black.withValues(alpha: 0.1),
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
                    'TOTAL ASSETS UNDER MANAGEMENT (AUM)',
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
                      color: Colors.white.withValues(alpha: 0.12),
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
                          'AUDITED PLATFORM TREASURY',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 10.5,
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
                spacing: 12,
                runSpacing: 8,
                children: [
                  _treasuryHeroBadge('Escrow Vault Lock: \$4.85M', Icons.lock_outlined),
                  _treasuryHeroBadge('Bank Reserve Fund: \$6.50M', Icons.account_balance_outlined),
                  _treasuryHeroBadge('Emergency Liquidity: \$2.93M', Icons.savings_outlined),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Partner Banks Health Grid
        Text(
          'Integrated Partner Financial Institutions',
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: dark),
        ),
        Text(
          'Real-time liquidity clearing rails and central bank discount window connectivity.',
          style: GoogleFonts.inter(fontSize: 12, color: muted),
        ),
        const SizedBox(height: 14),

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

  Widget _treasuryHeroBadge(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
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

  // ───────────────────────────────────────────────────────────────────────────
  // TAB 1: CREDIT UNDERWRITING & LOANS DESK
  // ───────────────────────────────────────────────────────────────────────────

  Widget _buildCreditUnderwritingTab(bool isDesktop) {
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
                  'Institutional Loan Underwriting Desk',
                  style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: dark),
                ),
                Text(
                  'Review and approve high-yield smallholder & commercial farm loan applications.',
                  style: GoogleFonts.inter(fontSize: 12, color: muted),
                ),
              ],
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
        const SizedBox(height: 16),

        // Underwriting Loans List
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
            color: Colors.black.withValues(alpha: 0.03),
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
                  color: green.withValues(alpha: 0.12),
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

  // ───────────────────────────────────────────────────────────────────────────
  // TAB 2: CROSS-BORDER TRADE & SADC DESK
  // ───────────────────────────────────────────────────────────────────────────

  Widget _buildCrossBorderDeskTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SADC Cross-Border Trade Finance & Letters of Credit (LC)',
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: dark),
        ),
        Text(
          'Institutional export credit guarantees for bulk regional agricultural trade.',
          style: GoogleFonts.inter(fontSize: 12, color: muted),
        ),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SADC CORRIDOR CLEARANCE & LETTER OF CREDIT DESK',
                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w900, color: green, letterSpacing: 1.0),
              ),
              const SizedBox(height: 14),
              _sadcCorridorRow('Harare 🇿🇼 ➔ Beira Port 🇲🇿', 'Tobacco Export Cargo (450 Tons)', '\$1,250,000 LC Active', 'Cleared Customs'),
              const SizedBox(height: 10),
              _sadcCorridorRow('Bulawayo 🇿🇼 ➔ Johannesburg 🇿🇦', 'Organic Hass Avocados (120 Tons)', '\$480,000 LC Active', 'Transit Escrow'),
              const SizedBox(height: 10),
              _sadcCorridorRow('Lusaka 🇿🇲 ➔ Chirundu 🇿🇼', 'White Non-GMO Maize (800 Tons)', '\$2,100,000 LC Active', 'GMB Silo Receiving'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sadcCorridorRow(String corridor, String cargo, String lcVal, String status) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(corridor, style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.bold, color: dark)),
                const SizedBox(height: 2),
                Text(cargo, style: const TextStyle(fontSize: 12, color: muted)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(lcVal, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w900, color: green)),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(status, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: green)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // TAB 3: CARBON ESG GREEN FINANCING
  // ───────────────────────────────────────────────────────────────────────────

  Widget _buildCarbonEsgTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Carbon Credit Monetization & EUDR Green Bonds',
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: dark),
        ),
        Text(
          'Institutional ESG underwriting and satellite carbon offset verification.',
          style: GoogleFonts.inter(fontSize: 12, color: muted),
        ),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF042F2E), Color(0xFF0F172A)],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'VERIFIED CARBON OFFSET ASSETS',
                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w900, color: const Color(0xFF2DD4BF), letterSpacing: 1.0),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('48,500 Tons CO2e', style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white)),
                  Text('\$1,382,250 USD Value', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF2DD4BF))),
                ],
              ),
              const SizedBox(height: 8),
              const Text('Spot Carbon Offset Price: \$28.50 / Ton CO2e (Verra Standard Verified)', style: TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // TAB 4: SUPER ADMIN POLICY SIMULATOR
  // ───────────────────────────────────────────────────────────────────────────

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
                      children: const [
                        Icon(Icons.vpn_key, color: gold, size: 14),
                        SizedBox(width: 4),
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
                  child: const Icon(Icons.monetization_on_outlined, color: gold, size: 20),
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
                            child: Text(log['rate'], style: const TextStyle(color: green, fontSize: 10, fontWeight: FontWeight.bold)),
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