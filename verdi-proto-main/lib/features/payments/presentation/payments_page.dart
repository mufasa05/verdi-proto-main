import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../state/platform_data_state.dart';
import '../../analytics/data/analytics_export_service.dart';

class PaymentsPage extends ConsumerStatefulWidget {
  const PaymentsPage({super.key});

  @override
  ConsumerState<PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends ConsumerState<PaymentsPage> {
  static const background = Color(0xFFF4F7FB);
  static const green = Color(0xFF16A34A);
  static const dark = Color(0xFF0F172A);
  static const muted = Color(0xFF64748B);

  int _activeTab = 0;

  final List<String> _filters = const [
    'All',
    'Pending',
    'Completed',
    'Failed',
    'Refunded',
  ];

  String _selectedFilter = 'All';
  String? _selectedPaymentId;

  // Currency Converter & Calculator State
  double _converterUsd = 100.0;
  String _targetCurrency = 'ZiG (Zimbabwe Gold)';

  // Escrow Yield Calculator State
  double _calcTradeVolume = 25000.0;
  double _calcFeeRate = 1.5; // %
  double _calcHoldDays = 14.0; // days

  List<PaymentItem> _filteredPayments(List<PaymentItem> allPayments) {
    if (_selectedFilter == 'All') return allPayments;
    return allPayments.where((p) => p.status == _selectedFilter).toList();
  }

  Future<void> _exportPayments(PaymentItem payment) async {
    try {
      final file = await AnalyticsExportService.exportOrderSummary(
        orders: [
          {
            'id': payment.id,
            'buyer': payment.party,
            'product': payment.type,
            'quantity': payment.amount,
            'destination': payment.destination,
            'status': payment.status,
            'payment': payment.method,
            'total': payment.amount,
            'date': payment.date,
            'eta': payment.settlementWindow,
            'priority': payment.riskLevel,
          }
        ],
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Exported ${payment.id} to ${file.path}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _applyPaymentAction(PaymentItem payment, String action) {
    late String nextStatus;
    late String nextNote;
    late String nextRisk;
    late String nextSettlement;
    late String nextDestination;
    late List<String> nextTimeline;

    switch (action) {
      case 'approve':
        nextStatus = 'Completed';
        nextNote = 'Escrow released via instant mobile gateway';
        nextRisk = 'Low';
        nextSettlement = 'Instant Completed';
        nextDestination = payment.destination;
        nextTimeline = [...payment.timeline, 'Escrow Released to Seller'];
        break;
      case 'hold':
        nextStatus = 'Pending';
        nextNote = 'Held for compliance review';
        nextRisk = 'High';
        nextSettlement = 'Review in 30 min';
        nextDestination = payment.destination;
        nextTimeline = [...payment.timeline, 'Held for compliance audit'];
        break;
      case 'escalate':
        nextStatus = 'Pending';
        nextNote = 'Escalated to finance ops desk';
        nextRisk = 'High';
        nextSettlement = 'Escalation window 15 min';
        nextDestination = 'Finance desk';
        nextTimeline = [...payment.timeline, 'Escalated to Compliance Desk'];
        break;
      default:
        nextStatus = payment.status;
        nextNote = payment.note;
        nextRisk = payment.riskLevel;
        nextSettlement = payment.settlementWindow;
        nextDestination = payment.destination;
        nextTimeline = payment.timeline;
    }

    ref.read(paymentsListProvider.notifier).updatePayment(
      payment.id,
      status: nextStatus,
      note: nextNote,
      riskLevel: nextRisk,
      settlementWindow: nextSettlement,
      destination: nextDestination,
      timeline: nextTimeline,
    );
  }

  @override
  Widget build(BuildContext context) {
    final allPayments = ref.watch(paymentsListProvider);
    final payments = _filteredPayments(allPayments);

    if (_selectedPaymentId == null && payments.isNotEmpty) {
      _selectedPaymentId = payments.first.id;
    }
    final selectedPayment = payments.firstWhere(
      (p) => p.id == _selectedPaymentId,
      orElse: () => payments.isNotEmpty
          ? payments.first
          : const PaymentItem(
              id: '',
              party: '',
              type: '',
              amount: '',
              status: '',
              method: '',
              date: '',
              ref: '',
              note: '',
              riskLevel: '',
              settlementWindow: '',
              currency: '',
              destination: '',
              timeline: [],
            ),
    );

    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1100;

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            // ─────────────────────────────────────────────────────────────────
            // Live Settlement Ticker Pulse Bar
            // ─────────────────────────────────────────────────────────────────
            Container(
              width: double.infinity,
              color: const Color(0xFF0F172A),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF22C55E))),
                    const SizedBox(width: 8),
                    Text(
                      'FINANCIAL ESCROW PULSE: ',
                      style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w900, color: const Color(0xFF22C55E), letterSpacing: 1.0),
                    ),
                    Text(
                      'Total Vault Escrow Lock: \$1,428,500.00 • EcoCash / OneMoney Gateway: 99.98% Success • SADC RTGS Settlement: Active • ZiG/USD Rate: 13.85 • Compliance Violations: 0',
                      style: GoogleFonts.inter(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),

            // ─────────────────────────────────────────────────────────────────
            // Financial Tab Navigation
            // ─────────────────────────────────────────────────────────────────
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildTabChip(0, '💳 Escrow & Trade Settlements', Icons.account_balance_wallet_outlined),
                    const SizedBox(width: 8),
                    _buildTabChip(1, '📱 Mobile Wallet & Gateways', Icons.phone_android_outlined),
                    const SizedBox(width: 8),
                    _buildTabChip(2, '🛡️ Credit Risk & Financing Radar', Icons.security_outlined),
                    const SizedBox(width: 8),
                    _buildTabChip(3, '⚡ Escrow Yield & Fee Calculator', Icons.calculate_outlined),
                  ],
                ),
              ),
            ),
            const Divider(height: 1),

            // ─────────────────────────────────────────────────────────────────
            // Tab Content
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
                        if (_activeTab == 0) _buildEscrowTab(payments, selectedPayment, isDesktop, allPayments),
                        if (_activeTab == 1) _buildMobileGatewayTab(),
                        if (_activeTab == 2) _buildCreditRadarTab(),
                        if (_activeTab == 3) _buildYieldCalculatorTab(),
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
        decoration: BoxDecoration(color: isSelected ? green : const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Icon(icon, size: 15, color: isSelected ? Colors.white : dark),
            const SizedBox(width: 6),
            Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.w600, color: isSelected ? Colors.white : dark)),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // TAB 0: ESCROW & TRADE SETTLEMENTS
  // ───────────────────────────────────────────────────────────────────────────

  Widget _buildEscrowTab(List<PaymentItem> payments, PaymentItem selectedPayment, bool isDesktop, List<PaymentItem> allPayments) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Header(
          isCompact: !isDesktop,
          selectedFilter: _selectedFilter,
          filters: _filters,
          onFilterChanged: (v) {
            setState(() {
              _selectedFilter = v;
              final filtered = _filteredPayments(allPayments);
              if (filtered.isNotEmpty) {
                _selectedPaymentId = filtered.first.id;
              }
            });
          },
          onExport: () {
            if (selectedPayment.id.isNotEmpty) _exportPayments(selectedPayment);
          },
        ),
        const SizedBox(height: 16),
        _PremiumHeroCard(payment: selectedPayment),
        const SizedBox(height: 16),
        _StatsGrid(isDesktop: isDesktop),
        const SizedBox(height: 16),
        if (payments.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text('No transactions found matching this filter.'),
            ),
          )
        else if (isDesktop)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: _SectionCard(
                  title: 'Transactions',
                  child: Column(
                    children: [
                      for (int i = 0; i < payments.length; i++) ...[
                        _PaymentCard(
                          payment: payments[i],
                          selected: payments[i].id == _selectedPaymentId,
                          onTap: () {
                            setState(() {
                              _selectedPaymentId = payments[i].id;
                            });
                          },
                        ),
                        if (i != payments.length - 1) const SizedBox(height: 12),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    _SectionCard(
                      title: 'Payment detail',
                      child: _PaymentDetailPanel(
                        payment: selectedPayment,
                        onExport: () => _exportPayments(selectedPayment),
                        onApprove: () => _applyPaymentAction(selectedPayment, 'approve'),
                        onHold: () => _applyPaymentAction(selectedPayment, 'hold'),
                        onEscalate: () => _applyPaymentAction(selectedPayment, 'escalate'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _SectionCard(
                      title: 'Wallet summary',
                      child: const _WalletSummary(),
                    ),
                  ],
                ),
              ),
            ],
          )
        else
          Column(
            children: [
              _SectionCard(
                title: 'Payment detail',
                child: _PaymentDetailPanel(
                  payment: selectedPayment,
                  onExport: () => _exportPayments(selectedPayment),
                  onApprove: () => _applyPaymentAction(selectedPayment, 'approve'),
                  onHold: () => _applyPaymentAction(selectedPayment, 'hold'),
                  onEscalate: () => _applyPaymentAction(selectedPayment, 'escalate'),
                ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Transactions',
                child: Column(
                  children: [
                    for (int i = 0; i < payments.length; i++) ...[
                      _PaymentCard(
                        payment: payments[i],
                        selected: payments[i].id == _selectedPaymentId,
                        onTap: () {
                          setState(() {
                            _selectedPaymentId = payments[i].id;
                          });
                        },
                      ),
                      if (i != payments.length - 1) const SizedBox(height: 12),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Wallet summary',
                child: const _WalletSummary(),
              ),
            ],
          ),
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // TAB 1: MOBILE WALLET & MULTI-CURRENCY GATEWAY
  // ───────────────────────────────────────────────────────────────────────────

  Widget _buildMobileGatewayTab() {
    final convertedAmount = switch (_targetCurrency) {
      'ZiG (Zimbabwe Gold)' => _converterUsd * 13.85,
      'ZAR (South African Rand)' => _converterUsd * 18.40,
      'MZN (Mozambican Metical)' => _converterUsd * 63.80,
      _ => _converterUsd * 1.0,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Mobile Wallet Settlement & Multi-Currency Gateway', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: dark)),
        Text('Instant EcoCash, OneMoney, ZIPIT, and cross-border currency conversion engine.', style: GoogleFonts.inter(fontSize: 12, color: muted)),
        const SizedBox(height: 16),

        // Live Gateway Health Grid
        Row(
          children: [
            Expanded(child: _gatewayHealthCard('EcoCash 📱', '99.98% Uptime', 'Instant USD/ZiG Payout', green, Icons.check_circle_outline)),
            const SizedBox(width: 12),
            Expanded(child: _gatewayHealthCard('OneMoney 📱', '99.90% Uptime', 'NetOne Wallet Active', green, Icons.check_circle_outline)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _gatewayHealthCard('Bank ZIPIT 🏦', 'Normal Speed', 'Instant Interbank Clearing', const Color(0xFF2563EB), Icons.account_balance_outlined)),
            const SizedBox(width: 12),
            Expanded(child: _gatewayHealthCard('Visa / Mastercard 💳', 'Operational', '3DS Secure Gateway', const Color(0xFF7C3AED), Icons.credit_card_outlined)),
          ],
        ),
        const SizedBox(height: 20),

        // Currency Exchange Engine Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.black12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('REAL-TIME MULTI-CURRENCY CONVERTER', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w900, color: green, letterSpacing: 1.0)),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Base Amount (USD)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.attach_money_outlined, color: green),
                      ),
                      onChanged: (v) {
                        final parsed = double.tryParse(v);
                        if (parsed != null) setState(() => _converterUsd = parsed);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _targetCurrency,
                      decoration: InputDecoration(
                        labelText: 'Target Settlement Currency',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: ['ZiG (Zimbabwe Gold)', 'ZAR (South African Rand)', 'MZN (Mozambican Metical)'].map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 12)))).toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _targetCurrency = v);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(14)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Calculated Settlement Value:', style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600, color: dark)),
                    Text('${convertedAmount.toStringAsFixed(2)} ${_targetCurrency.split(' ')[0]}', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w900, color: green)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _gatewayHealthCard(String title, String status, String note, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.black12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(icon, color: color, size: 20), const SizedBox(width: 8), Text(title, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: dark))]),
          const SizedBox(height: 8),
          Text(status, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 2),
          Text(note, style: const TextStyle(fontSize: 11, color: muted)),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // TAB 2: CREDIT RISK & FINANCING RADAR
  // ───────────────────────────────────────────────────────────────────────────

  Widget _buildCreditRadarTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Smallholder Credit Scoring & Working Capital Advance', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: dark)),
        Text('Automated AI credit scoring and 80% pre-harvest liquidity advance engine.', style: GoogleFonts.inter(fontSize: 12, color: muted)),
        const SizedBox(height: 16),

        // Credit Score Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF1E293B)]), borderRadius: BorderRadius.circular(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('FARMER CREDIT RATING SCORE', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w900, color: const Color(0xFF22C55E), letterSpacing: 1.0)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: const Color(0xFF22C55E).withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
                    child: const Text('AAA+ EXCELLENT', style: TextStyle(color: Color(0xFF22C55E), fontSize: 10.5, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Text('840 / 900', style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white)),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text('Based on 98.4% trade fulfillment, zero default history, and verified Landsat field polygons.', style: TextStyle(color: Colors.white70, fontSize: 11.5, height: 1.3)),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Working Capital Request Form
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.black12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('REQUEST WORKING CAPITAL ADVANCE (80% PRE-HARVEST)', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w900, color: green, letterSpacing: 1.0)),
              const SizedBox(height: 12),
              const Text('Approved Credit Line: \$15,000.00 USD @ 1.2% monthly interest.', style: TextStyle(fontSize: 12.5, color: muted)),
              const SizedBox(height: 14),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Working Capital Advance of \$5,000 disbursed to Escrow Wallet!'), backgroundColor: green),
                  );
                },
                icon: const Icon(Icons.flash_on_outlined, size: 18),
                label: const Text('Disburse \$5,000 Instant Advance', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(backgroundColor: green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // TAB 3: ESCROW YIELD & FEE CALCULATOR
  // ───────────────────────────────────────────────────────────────────────────

  Widget _buildYieldCalculatorTab() {
    final escrowProtectionFee = _calcTradeVolume * (_calcFeeRate / 100);
    final netSellerPayout = _calcTradeVolume - escrowProtectionFee;
    final interestEarned = (_calcTradeVolume * 0.08 * (_calcHoldDays / 365));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Interactive Escrow Yield & Fee Calculator', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: dark)),
        Text('Simulate trade settlement fees, escrow protection margins, and net seller payouts.', style: GoogleFonts.inter(fontSize: 12, color: muted)),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.black12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('TRADE SETTLEMENT PARAMETERS', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w900, color: green, letterSpacing: 1.0)),
              const SizedBox(height: 12),

              Text('Monthly Trade Settlement Volume: \$${_calcTradeVolume.toStringAsFixed(0)} USD', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: dark)),
              Slider(
                value: _calcTradeVolume,
                min: 1000.0,
                max: 100000.0,
                activeColor: green,
                label: '\$${_calcTradeVolume.toStringAsFixed(0)}',
                onChanged: (v) => setState(() => _calcTradeVolume = v),
              ),

              Text('Escrow Protection Fee Rate: ${_calcFeeRate.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: dark)),
              Slider(
                value: _calcFeeRate,
                min: 0.5,
                max: 5.0,
                activeColor: const Color(0xFF2563EB),
                label: '${_calcFeeRate.toStringAsFixed(1)}%',
                onChanged: (v) => setState(() => _calcFeeRate = v),
              ),

              Text('Escrow Hold Period: ${_calcHoldDays.toStringAsFixed(0)} Days', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: dark)),
              Slider(
                value: _calcHoldDays,
                min: 1.0,
                max: 90.0,
                activeColor: const Color(0xFF7C3AED),
                label: '${_calcHoldDays.toStringAsFixed(0)} Days',
                onChanged: (v) => setState(() => _calcHoldDays = v),
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
              Text('CALCULATED SETTLEMENT OUTCOMES', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w900, color: const Color(0xFF22C55E), letterSpacing: 1.0)),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _simOutputMetric('Net Seller Payout', '\$${netSellerPayout.toStringAsFixed(2)}', const Color(0xFF22C55E)),
                  _simOutputMetric('Escrow Fee (1.5%)', '\$${escrowProtectionFee.toStringAsFixed(2)}', Colors.white),
                  _simOutputMetric('Vault Interest Yield', '\$${interestEarned.toStringAsFixed(2)}', const Color(0xFF38BDF8)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _simOutputMetric(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.white60)),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w900, color: color)),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  final bool isCompact;
  final String selectedFilter;
  final List<String> filters;
  final ValueChanged<String> onFilterChanged;
  final VoidCallback onExport;

  const _Header({
    required this.isCompact,
    required this.selectedFilter,
    required this.filters,
    required this.onFilterChanged,
    required this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 18, offset: const Offset(0, 8)),
        ],
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
                    Text(
                      'Payments command center',
                      style: GoogleFonts.inter(
                        fontSize: isCompact ? 24 : 28,
                        fontWeight: FontWeight.w800,
                        color: _PaymentsPageState.dark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Review settlements, processor health, wallet movements, and exceptions from one premium workspace.',
                      style: GoogleFonts.inter(color: _PaymentsPageState.muted, height: 1.4),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onExport,
                icon: const Icon(Icons.ios_share_outlined),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFF8FAFC),
                  side: const BorderSide(color: Colors.black12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: filters
                .map(
                  (f) => ChoiceChip(
                    label: Text(f),
                    selected: selectedFilter == f,
                    selectedColor: _PaymentsPageState.green.withValues(alpha: 0.15),
                    labelStyle: TextStyle(
                      color: selectedFilter == f ? _PaymentsPageState.green : _PaymentsPageState.muted,
                      fontWeight: FontWeight.w600,
                    ),
                    onSelected: (_) => onFilterChanged(f),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _PremiumHeroCard extends StatelessWidget {
  final PaymentItem payment;

  const _PremiumHeroCard({required this.payment});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF052E16), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Live settlement pulse • ${payment.id}',
                  style: GoogleFonts.inter(color: Colors.white70, fontWeight: FontWeight.w600),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  payment.status,
                  style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            payment.party,
            style: GoogleFonts.inter(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            '${payment.type} • ${payment.method} • ${payment.destination}',
            style: GoogleFonts.inter(color: Colors.white70),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _HeroChip(label: payment.amount, icon: Icons.attach_money_outlined),
              _HeroChip(label: payment.settlementWindow, icon: Icons.access_time_outlined),
              _HeroChip(label: payment.currency, icon: Icons.currency_exchange_outlined),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final bool isDesktop;

  const _StatsGrid({required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    final cards = [
      _StatData('Received', 'US\$ 674', Icons.payments_outlined),
      _StatData('Pending', 'US\$ 258', Icons.hourglass_top_outlined),
      _StatData('Payouts', 'US\$ 176', Icons.send_outlined),
      _StatData('Escrow Lock', 'US\$ 4,436', Icons.lock_clock_outlined),
    ];

    Widget buildCard(_StatData stat, {bool compact = false}) {
      final iconSize = compact ? 32.0 : 42.0;
      final valueFontSize = compact ? 15.0 : 20.0;
      final labelFontSize = compact ? 11.0 : 13.0;
      final pad = compact ? 10.0 : 14.0;
      final gap = compact ? 8.0 : 12.0;

      return Container(
        padding: EdgeInsets.all(pad),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black12),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 12, offset: const Offset(0, 6)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: iconSize,
              height: iconSize,
              decoration: BoxDecoration(
                color: _PaymentsPageState.green.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(stat.icon, color: _PaymentsPageState.green, size: compact ? 18 : 22),
            ),
            SizedBox(width: gap),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(stat.label, style: TextStyle(fontSize: labelFontSize, color: _PaymentsPageState.muted), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 3),
                  Text(
                    stat.value,
                    style: GoogleFonts.inter(fontSize: valueFontSize, fontWeight: FontWeight.w800, color: _PaymentsPageState.dark),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 900) {
          return Row(
            children: cards.map((stat) => Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: buildCard(stat),
              ),
            )).toList(),
          );
        }
        final compact = constraints.maxWidth < 380;
        return Column(
          children: [
            Row(
              children: [
                Expanded(child: buildCard(cards[0], compact: compact)),
                const SizedBox(width: 10),
                Expanded(child: buildCard(cards[1], compact: compact)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: buildCard(cards[2], compact: compact)),
                const SizedBox(width: 10),
                Expanded(child: buildCard(cards[3], compact: compact)),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _PaymentCard extends StatelessWidget {
  final PaymentItem payment;
  final bool selected;
  final VoidCallback onTap;

  const _PaymentCard({required this.payment, required this.selected, required this.onTap});

  Color _statusColor() {
    switch (payment.status) {
      case 'Pending':
        return Colors.orange;
      case 'Completed':
        return _PaymentsPageState.green;
      case 'Failed':
        return Colors.red;
      case 'Refunded':
        return Colors.blueGrey;
      default:
        return _PaymentsPageState.muted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? _PaymentsPageState.green.withValues(alpha: 0.06) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: selected ? _PaymentsPageState.green : Colors.black12, width: selected ? 1.5 : 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${payment.id} • ${payment.party}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: _PaymentsPageState.dark),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(payment.status, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('${payment.type} • ${payment.note}', style: GoogleFonts.inter(color: _PaymentsPageState.muted)),
            const SizedBox(height: 6),
            Text('${payment.method} • ${payment.date}', style: const TextStyle(fontSize: 12, color: _PaymentsPageState.muted)),
            const SizedBox(height: 10),
            LinearProgressIndicator(value: _progressValue(payment.status), minHeight: 8, backgroundColor: Colors.grey.shade200, color: statusColor),
          ],
        ),
      ),
    );
  }

  double _progressValue(String status) {
    switch (status) {
      case 'Pending':
        return 0.35;
      case 'Completed':
        return 1.0;
      case 'Failed':
        return 0.05;
      case 'Refunded':
        return 0.75;
      default:
        return 0.35;
    }
  }
}

class _PaymentDetailPanel extends StatelessWidget {
  final PaymentItem payment;
  final VoidCallback onExport;
  final VoidCallback onApprove;
  final VoidCallback onHold;
  final VoidCallback onEscalate;

  const _PaymentDetailPanel({
    required this.payment,
    required this.onExport,
    required this.onApprove,
    required this.onHold,
    required this.onEscalate,
  });

  Color _statusColor() {
    switch (payment.status) {
      case 'Pending':
        return Colors.orange;
      case 'Completed':
        return _PaymentsPageState.green;
      case 'Failed':
        return Colors.red;
      case 'Refunded':
        return Colors.blueGrey;
      default:
        return _PaymentsPageState.muted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(payment.id, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: _PaymentsPageState.dark)),
        const SizedBox(height: 4),
        Text(payment.party, style: const TextStyle(color: _PaymentsPageState.muted)),
        const SizedBox(height: 14),
        _DetailRow(label: 'Type', value: payment.type),
        _DetailRow(label: 'Amount', value: payment.amount),
        _DetailRow(label: 'Method', value: payment.method),
        _DetailRow(label: 'Status', value: payment.status),
        _DetailRow(label: 'Reference', value: payment.ref),
        _DetailRow(label: 'Date', value: payment.date),
        _DetailRow(label: 'Risk', value: payment.riskLevel),
        _DetailRow(label: 'Settlement', value: payment.settlementWindow),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: _progressValue(payment.status), minHeight: 8, backgroundColor: Colors.grey.shade200, color: statusColor),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _MiniChip(label: payment.note, icon: Icons.receipt_long_outlined),
            _MiniChip(label: 'View invoice', icon: Icons.picture_as_pdf_outlined),
            _MiniChip(label: 'Send receipt', icon: Icons.send_outlined),
            _MiniChip(label: 'Flag issue', icon: Icons.report_outlined),
          ],
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: payment.timeline.map((entry) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(999)),
                child: Text(entry, style: const TextStyle(fontSize: 12)),
              )).toList(),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _ActionButton(label: 'Approve & Release', icon: Icons.check_circle_outline, onPressed: onApprove, color: _PaymentsPageState.green),
            _ActionButton(label: 'Hold', icon: Icons.pause_circle_outline, onPressed: onHold, color: Colors.orange),
            _ActionButton(label: 'Escalate', icon: Icons.shield_outlined, onPressed: onEscalate, color: Colors.redAccent),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onExport,
                style: OutlinedButton.styleFrom(foregroundColor: _PaymentsPageState.green, side: const BorderSide(color: _PaymentsPageState.green)),
                child: const Text('Export Statement'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  double _progressValue(String status) {
    switch (status) {
      case 'Pending':
        return 0.35;
      case 'Completed':
        return 1.0;
      case 'Failed':
        return 0.05;
      case 'Refunded':
        return 0.75;
      default:
        return 0.35;
    }
  }
}

class _WalletSummary extends StatelessWidget {
  const _WalletSummary();

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Available Vault Balance', 'US\$ 1,240,500'),
      ('Pending Settlements', 'US\$ 258,400'),
      ('Today\'s Inflow', 'US\$ 430,200'),
      ('Today\'s Outflow', 'US\$ 176,100'),
    ];

    return Column(
      children: [
        for (final item in items) ...[
          _WalletRow(label: item.$1, value: item.$2),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _WalletRow extends StatelessWidget {
  final String label;
  final String value;

  const _WalletRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label, style: const TextStyle(color: _PaymentsPageState.muted, fontWeight: FontWeight.w500))),
        Text(value, style: const TextStyle(color: _PaymentsPageState.dark, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _HeroChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _HeroChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: Colors.white),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(color: _PaymentsPageState.muted, fontWeight: FontWeight.w500))),
          Text(value, style: const TextStyle(color: _PaymentsPageState.dark, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _MiniChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Color color;

  const _ActionButton({required this.label, required this.icon, required this.onPressed, required this.color});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(foregroundColor: color, side: BorderSide(color: color.withValues(alpha: 0.6))),
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: _PaymentsPageState.dark)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _StatData {
  final String label;
  final String value;
  final IconData icon;

  _StatData(this.label, this.value, this.icon);
}