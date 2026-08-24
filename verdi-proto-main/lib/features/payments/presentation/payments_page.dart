import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../state/platform_data_state.dart';
import '../../../state/app_state.dart';
import '../../analytics/data/analytics_export_service.dart';

class _PaymentRoleTab {
  final int id;
  final String label;
  final IconData icon;
  const _PaymentRoleTab(this.id, this.label, this.icon);
}

List<_PaymentRoleTab> _getTabsForRole(UserRole role) {
  final isEndUser = role == UserRole.consumer;
  final isB2BWholesaler = role == UserRole.buyer;

  if (isEndUser) {
    return const [
      _PaymentRoleTab(0, '🛒 Grocery Orders & Receipts', Icons.receipt_long_outlined),
    ];
  }

  if (isB2BWholesaler) {
    return const [
      _PaymentRoleTab(0, '🏢 Multi-Stage Escrow Vault', Icons.account_balance_wallet_outlined),
      _PaymentRoleTab(1, '🏦 SADC RTGS & Bank Wire Gateway', Icons.account_balance_outlined),
      _PaymentRoleTab(2, '📑 Working Capital & Trade Credit', Icons.security_outlined),
      _PaymentRoleTab(3, '⚡ Volume Discount & Fee Engine', Icons.calculate_outlined),
    ];
  }

  switch (role) {
    case UserRole.farmer:
      return const [
        _PaymentRoleTab(0, '🌾 Harvest Payouts & Escrow', Icons.agriculture_outlined),
        _PaymentRoleTab(1, '📱 Instant Mobile Cashout', Icons.phone_android_outlined),
        _PaymentRoleTab(2, '🌱 Input Loan Repayments', Icons.spa_outlined),
      ];

    case UserRole.transporter:
      return const [
        _PaymentRoleTab(0, '🚛 Freight Waybill Settlements', Icons.local_shipping_outlined),
        _PaymentRoleTab(1, '⛽ Fuel & Tollgate Fleet Card', Icons.local_gas_station_outlined),
        _PaymentRoleTab(2, '⚡ Tariff & Demurrage Calculator', Icons.calculate_outlined),
      ];

    case UserRole.financier:
      return const [
        _PaymentRoleTab(0, '📊 Loan Tranche Disbursements', Icons.account_balance_wallet_outlined),
        _PaymentRoleTab(1, '🛡️ Portfolio Credit Risk Radar', Icons.security_outlined),
        _PaymentRoleTab(2, '⚡ Structured Loan Yield Engine', Icons.calculate_outlined),
      ];

    case UserRole.valueAdder:
      return const [
        _PaymentRoleTab(0, '🏭 Raw Intake Settlements', Icons.factory_outlined),
        _PaymentRoleTab(1, '🏦 Working Capital Credit Line', Icons.account_balance_outlined),
        _PaymentRoleTab(2, '🧾 Wholesale Sales Invoices', Icons.receipt_long_outlined),
      ];

    case UserRole.admin:
    case UserRole.government:
    default:
      return const [
        _PaymentRoleTab(0, '🌐 Sovereign Escrow & Settlements', Icons.account_balance_wallet_outlined),
        _PaymentRoleTab(1, '📱 Gateway Telemetry & Health', Icons.phone_android_outlined),
        _PaymentRoleTab(2, '🛡️ AML & Credit Risk Radar', Icons.security_outlined),
        _PaymentRoleTab(3, '⚡ Platform Fee & Treasury Vault', Icons.calculate_outlined),
      ];
  }
}

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

    final currentRole = ref.watch(appStateProvider).role;
    final isEndUser = currentRole == UserRole.consumer;
    final isB2BWholesaler = currentRole == UserRole.buyer;

    final roleTabs = _getTabsForRole(currentRole);
    if (_activeTab >= roleTabs.length) {
      _activeTab = 0;
    }

    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1100;

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            // ─────────────────────────────────────────────────────────────────
            // Live Settlement Ticker Pulse Bar (Tailored Per Role)
            // ─────────────────────────────────────────────────────────────────
            if (!isEndUser)
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
                        isB2BWholesaler ? 'COMMERCIAL ESCROW PULSE: ' : 'FINANCIAL ESCROW PULSE: ',
                        style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w900, color: const Color(0xFF22C55E), letterSpacing: 1.0),
                      ),
                      Text(
                        _getTickerText(currentRole, isEndUser, isB2BWholesaler, ref.watch(isDemoModeProvider)),
                        style: GoogleFonts.inter(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),

            // ─────────────────────────────────────────────────────────────────
            // Role-Tailored Financial Tab Navigation
            // ─────────────────────────────────────────────────────────────────
            if (!isEndUser)
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (int i = 0; i < roleTabs.length; i++) ...[
                        _buildTabChip(i, roleTabs[i].label, roleTabs[i].icon),
                        if (i != roleTabs.length - 1) const SizedBox(width: 8),
                      ],
                    ],
                  ),
                ),
              ),
            if (!isEndUser) const Divider(height: 1),

            // ─────────────────────────────────────────────────────────────────
            // Tab Content (Dynamic based on selected role tab)
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
                        _buildDynamicTabContent(
                          tabIndex: _activeTab,
                          role: currentRole,
                          isEndUser: isEndUser,
                          isB2BWholesaler: isB2BWholesaler,
                          payments: payments,
                          selectedPayment: selectedPayment,
                          isDesktop: isDesktop,
                          allPayments: allPayments,
                        ),
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

  String _getTickerText(UserRole role, bool isEndUser, bool isB2BWholesaler, bool isDemo) {
    if (isEndUser) {
      return '100% Secure Direct Checkout';
    }
    if (isB2BWholesaler) {
      return isDemo
          ? '3-Stage Commercial Escrow Vault: Active • SADC RTGS Bank Wire: Online • Inspection Clearance: 99.4% • Currency Index: 13.85'
          : '3-Stage Commercial Escrow Vault: Active • SADC RTGS Bank Wire: Online • Inspection Clearance: 100% • Currency Index: 13.85';
    }
    return isDemo
        ? 'Total Vault Escrow Lock: \$1,428,500.00 • Gateway Success: 99.98% • SADC RTGS: Active • ZiG/USD Rate: 13.85'
        : 'Total Vault Escrow Lock: \$0.00 • EcoCash / OneMoney: Operational • SADC RTGS: Active • ZiG/USD Rate: 13.85';
  }

  Widget _buildDynamicTabContent({
    required int tabIndex,
    required UserRole role,
    required bool isEndUser,
    required bool isB2BWholesaler,
    required List<PaymentItem> payments,
    required PaymentItem selectedPayment,
    required bool isDesktop,
    required List<PaymentItem> allPayments,
  }) {
    if (isEndUser) {
      return _buildEscrowTab(payments, selectedPayment, isDesktop, allPayments, isEndUser: true);
    }

    if (isB2BWholesaler) {
      if (tabIndex == 0) return _buildEscrowTab(payments, selectedPayment, isDesktop, allPayments);
      if (tabIndex == 1) return _buildBankWireGatewayTab();
      if (tabIndex == 2) return _buildCreditRadarTab();
      if (tabIndex == 3) return _buildYieldCalculatorTab();
      return _buildEscrowTab(payments, selectedPayment, isDesktop, allPayments);
    }

    switch (role) {
      case UserRole.farmer:
        if (tabIndex == 0) return _buildEscrowTab(payments, selectedPayment, isDesktop, allPayments);
        if (tabIndex == 1) return _buildMobileGatewayTab();
        if (tabIndex == 2) return _buildInputLoanTab();
        return _buildEscrowTab(payments, selectedPayment, isDesktop, allPayments);

      case UserRole.transporter:
        if (tabIndex == 0) return _buildEscrowTab(payments, selectedPayment, isDesktop, allPayments);
        if (tabIndex == 1) return _buildFuelCardTab();
        if (tabIndex == 2) return _buildYieldCalculatorTab();
        return _buildEscrowTab(payments, selectedPayment, isDesktop, allPayments);

      case UserRole.financier:
        if (tabIndex == 0) return _buildEscrowTab(payments, selectedPayment, isDesktop, allPayments);
        if (tabIndex == 1) return _buildCreditRadarTab();
        if (tabIndex == 2) return _buildYieldCalculatorTab();
        return _buildEscrowTab(payments, selectedPayment, isDesktop, allPayments);

      case UserRole.valueAdder:
        if (tabIndex == 0) return _buildEscrowTab(payments, selectedPayment, isDesktop, allPayments);
        if (tabIndex == 1) return _buildCreditRadarTab();
        if (tabIndex == 2) return _buildBankWireGatewayTab();
        return _buildEscrowTab(payments, selectedPayment, isDesktop, allPayments);

      case UserRole.admin:
      case UserRole.government:
      default:
        if (tabIndex == 0) return _buildEscrowTab(payments, selectedPayment, isDesktop, allPayments);
        if (tabIndex == 1) return _buildMobileGatewayTab();
        if (tabIndex == 2) return _buildCreditRadarTab();
        if (tabIndex == 3) return _buildYieldCalculatorTab();
        return _buildEscrowTab(payments, selectedPayment, isDesktop, allPayments);
    }
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

  Widget _buildCurrencyConverterCard() {
    double rate = 13.85; // ZiG
    String symbol = 'ZiG';
    if (_targetCurrency.contains('ZAR')) {
      rate = 18.20;
      symbol = 'ZAR';
    } else if (_targetCurrency.contains('EcoCash')) {
      rate = 14.10;
      symbol = 'ZWG';
    }
    final converted = _converterUsd * rate;

    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF1E293B)]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: const Color(0xFF22C55E).withOpacity(0.15), shape: BoxShape.circle),
                    child: const Icon(Icons.currency_exchange, color: Color(0xFF22C55E), size: 20),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Live Currency Converter & Checkout Rates', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                      const Text('Official interbank & local mobile money settlement rates', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFF22C55E).withOpacity(0.15), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF22C55E).withOpacity(0.4))),
                child: const Text('LIVE INTERBANK', style: TextStyle(color: Color(0xFF22C55E), fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 600;
              final inputField = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('AMOUNT (USD)', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFF0A0F1D), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF334155))),
                    child: Row(
                      children: [
                        const Text('\$', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            initialValue: _converterUsd.toStringAsFixed(0),
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                            onChanged: (v) {
                              final val = double.tryParse(v);
                              if (val != null) setState(() => _converterUsd = val);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );

              final dropdownField = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('TARGET CURRENCY', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                    decoration: BoxDecoration(color: const Color(0xFF0A0F1D), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF334155))),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _targetCurrency,
                        dropdownColor: const Color(0xFF1E293B),
                        isExpanded: true,
                        icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                        items: const [
                          DropdownMenuItem(value: 'ZiG (Zimbabwe Gold)', child: Text('ZiG (Zimbabwe Gold) @ 13.85', style: TextStyle(color: Colors.white, fontSize: 13))),
                          DropdownMenuItem(value: 'EcoCash ZWG', child: Text('EcoCash ZWG @ 14.10', style: TextStyle(color: Colors.white, fontSize: 13))),
                          DropdownMenuItem(value: 'ZAR (South African Rand)', child: Text('ZAR (SA Rand) @ 18.20', style: TextStyle(color: Colors.white, fontSize: 13))),
                        ],
                        onChanged: (v) {
                          if (v != null) setState(() => _targetCurrency = v);
                        },
                      ),
                    ),
                  ),
                ],
              );

              if (isNarrow) {
                return Column(
                  children: [
                    inputField,
                    const SizedBox(height: 12),
                    dropdownField,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: inputField),
                  const SizedBox(width: 14),
                  Expanded(child: dropdownField),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          // Converted Outcome Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF16A34A).withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF16A34A).withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('CONVERTED ESTIMATE', style: TextStyle(color: Color(0xFF86EFAC), fontSize: 10.5, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                    const SizedBox(height: 2),
                    Text('$symbol ${converted.toStringAsFixed(2)}', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w900, color: const Color(0xFF22C55E))),
                  ],
                ),
                Wrap(
                  spacing: 6,
                  children: [10.0, 25.0, 50.0, 100.0].map((quick) {
                    final isSel = _converterUsd == quick;
                    return InkWell(
                      onTap: () => setState(() => _converterUsd = quick),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSel ? const Color(0xFF16A34A) : const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: isSel ? const Color(0xFF16A34A) : const Color(0xFF334155)),
                        ),
                        child: Text('\$${quick.toInt()}', style: TextStyle(color: isSel ? Colors.white : const Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEscrowTab(List<PaymentItem> payments, PaymentItem selectedPayment, bool isDesktop, List<PaymentItem> allPayments, {bool isEndUser = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isEndUser) _buildCurrencyConverterCard(),
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
    final isDemo = ref.watch(isDemoModeProvider);

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
                    decoration: BoxDecoration(color: (isDemo ? const Color(0xFF22C55E) : const Color(0xFF64748B)).withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
                    child: Text(isDemo ? 'AAA+ EXCELLENT' : 'UNRATED (NEW LIVE ACCOUNT)', style: TextStyle(color: isDemo ? const Color(0xFF22C55E) : const Color(0xFF94A3B8), fontSize: 10.5, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Text(isDemo ? '840 / 900' : 'Unrated', style: GoogleFonts.inter(fontSize: isDemo ? 32 : 24, fontWeight: FontWeight.w900, color: Colors.white)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      isDemo
                          ? 'Based on 98.4% trade fulfillment, zero default history, and verified Landsat field polygons.'
                          : 'No historical contract defaults or verified trade fulfillment recorded yet on this live account.',
                      style: const TextStyle(color: Colors.white70, fontSize: 11.5, height: 1.3),
                    ),
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
              Text(
                isDemo
                    ? 'Approved Credit Line: \$15,000.00 USD @ 1.2% monthly interest.'
                    : 'Approved Credit Line: \$0.00 USD (Complete first live trade fulfillment to establish active credit line).',
                style: const TextStyle(fontSize: 12.5, color: muted),
              ),
              const SizedBox(height: 14),
              if (isDemo)
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Working Capital Advance of \$5,000 disbursed to Escrow Wallet!'), backgroundColor: green),
                    );
                  },
                  icon: const Icon(Icons.flash_on_outlined, size: 18),
                  label: const Text('Disburse \$5,000 Instant Advance', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(backgroundColor: green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                )
              else
                OutlinedButton(
                  onPressed: null,
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Text('Complete First Trade to Unlock Credit Facility', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
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
    final isDemo = ref.watch(isDemoModeProvider);
    final escrowProtectionFee = _calcTradeVolume * (_calcFeeRate / 100);
    final netSellerPayout = _calcTradeVolume - escrowProtectionFee;
    final interestEarned = (_calcTradeVolume * 0.08 * (_calcHoldDays / 365));

    if (!isDemo) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Volume Discount & Fee Engine', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: dark)),
          Text('Live protocol fee parameters and active trade settlement volume tiers.', style: GoogleFonts.inter(fontSize: 12, color: muted)),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF1E293B)]), borderRadius: BorderRadius.circular(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('LIVE PROTOCOL SETTLEMENT STATUS', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w900, color: const Color(0xFF38BDF8), letterSpacing: 1.0)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: const Color(0xFF38BDF8).withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
                      child: const Text('TIER 1 BASELINE', style: TextStyle(color: Color(0xFF38BDF8), fontSize: 10.5, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _simOutputMetric('Active Sourcing Volume', '0.0 MT', Colors.white),
                    _simOutputMetric('Escrow Protection Fee', '1.5% (Standard)', const Color(0xFF22C55E)),
                    _simOutputMetric('Accrued Yield', 'US\$ 0.00', const Color(0xFF38BDF8)),
                  ],
                ),
                const Divider(color: Color(0xFF334155), height: 28),
                const Text(
                  'No live trade contracts currently accruing escrow settlement fees. Volume discount rebates will apply automatically as monthly procurement exceeds 50 MT.',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Interactive Escrow Yield & Fee Calculator (Demo Simulation)', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: dark)),
        Text('Simulate trade settlement fees, escrow protection margins, and net seller payouts.', style: GoogleFonts.inter(fontSize: 12, color: muted)),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.black12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('TRADE SETTLEMENT PARAMETERS (DEMO SANDBOX)', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w900, color: green, letterSpacing: 1.0)),
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


  // ───────────────────────────────────────────────────────────────────────────
  // TAB: SADC RTGS & BANK WIRE GATEWAY (B2B WHOLESALER)
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildBankWireGatewayTab() {
    final isDemo = ref.watch(isDemoModeProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('SADC RTGS & Commercial Bank Wire Clearing', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: dark)),
        Text('High-value commercial wire settlements, Letters of Credit (LC), and central bank clearing accounts.', style: GoogleFonts.inter(fontSize: 12, color: muted)),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF1E3A8A), Color(0xFF1E293B)]),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('COMMERCIAL RTGS VAULT BALANCE', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.white70, letterSpacing: 1.0)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: const Color(0xFF38BDF8).withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
                    child: Text(isDemo ? 'SADC RTGS LIVE' : 'AWAITING DEPOSIT', style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 10.5, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Text(isDemo ? '\$145,000.00 USD' : '\$0.00 USD', style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      isDemo
                          ? 'Linked to Stanbic Zimbabwe & First National Bank SADC Gateway for bulk grain contract settlement.'
                          : 'No commercial RTGS vault funds deposited yet. Link your corporate bank account or initiate incoming wire transfer to fund live contract settlements.',
                      style: const TextStyle(color: Colors.white70, fontSize: 11.5, height: 1.3),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.black12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('INITIATE HIGH-VALUE COMMERCIAL WIRE / LETTER OF CREDIT', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w900, color: green, letterSpacing: 1.0)),
              const SizedBox(height: 14),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('RTGS Commercial Settlement Batch initiated with SADC Clearing House.'), backgroundColor: green),
                  );
                },
                icon: const Icon(Icons.account_balance, size: 18),
                label: const Text('Initiate Commercial RTGS Batch (\$50k+)', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A8A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // TAB: INPUT LOAN REPAYMENTS (FARMER)
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildInputLoanTab() {
    final isDemo = ref.watch(isDemoModeProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Seasonal Input Financing & Loan Offsets', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: dark)),
        Text('Review automatic loan deductions for certified seed, fertilizer, and agronomy services.', style: GoogleFonts.inter(fontSize: 12, color: muted)),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF047857), Color(0xFF0F172A)]),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('ACTIVE INPUT CREDIT FACILITY', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.white70, letterSpacing: 1.0)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: const Color(0xFF22C55E).withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
                    child: Text(isDemo ? '85% REPAID' : 'CLEARED', style: const TextStyle(color: Color(0xFF22C55E), fontSize: 10.5, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Text(isDemo ? '\$420.00 Remaining' : '\$0.00 Remaining', style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      isDemo
                          ? 'Initial \$2,800.00 seed & fertilizer loan automatically deducted from delivered maize contracts.'
                          : 'No active seasonal input loans on live account.',
                      style: const TextStyle(color: Colors.white70, fontSize: 11.5, height: 1.3),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // TAB: FUEL & TOLLGATE FLEET CARD (TRANSPORTER)
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildFuelCardTab() {
    final isDemo = ref.watch(isDemoModeProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Fleet Diesel & Zinara Tollgate Cards', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: dark)),
        Text('Manage driver fuel allowances, digital toll passes, and breakdown emergency funds.', style: GoogleFonts.inter(fontSize: 12, color: muted)),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFFC2410C), Color(0xFF7C2D12)]),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('FLEET DIESEL SMART CARD POOL', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.white70, letterSpacing: 1.0)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
                    child: Text(isDemo ? 'AUTO-REPLENISH ON' : 'INACTIVE', style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Text(isDemo ? '\$1,850.00 Available' : '\$0.00 Available', style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      isDemo
                          ? 'Linked to TotalEnergies & Puma Energy filling stations along the Harare-Beira and Harare-Bulawayo corridors.'
                          : 'No live fleet fuel card pool activated yet.',
                      style: const TextStyle(color: Colors.white70, fontSize: 11.5, height: 1.3),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Header extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(appStateProvider).role;
    final isEndUser = role == UserRole.consumer;
    final isB2BWholesaler = role == UserRole.buyer;

    final title = isEndUser
        ? 'Grocery Payments & Receipts'
        : (isB2BWholesaler
            ? 'Commercial Sourcing & Escrow Vault'
            : switch (role) {
                UserRole.farmer => 'Harvest Payouts & Farmgate Cashout',
                UserRole.transporter => 'Freight Settlements & Fleet Fuel',
                UserRole.financier => 'Agri-Credit Portfolio & Escrow Custody',
                UserRole.valueAdder => 'Factory Raw Intake Settlements',
                UserRole.admin || UserRole.government => 'National Escrow & Payment Gateway Hub',
                _ => 'Payments Command Center',
              });

    final subtitle = isEndUser
        ? 'Track your household grocery orders, mobile money receipts, and delivery savings.'
        : (isB2BWholesaler
            ? 'Manage multi-stage contract escrow, outgrower disbursements, and SADC RTGS settlements.'
            : switch (role) {
                UserRole.farmer => 'Track direct crop payments, escrow disbursements, and mobile money cashouts.',
                UserRole.transporter => 'Manage cargo waybill payouts, tollgate fuel cards, and driver travel disbursements.',
                UserRole.financier => 'Monitor loan tranches, collateral liens, and credit risk repayment radar.',
                UserRole.valueAdder => 'Manage outgrower raw commodity intake, quality grade adjustments, and wholesale billing.',
                UserRole.admin || UserRole.government => 'Central bank RTGS settlements, processor uptime, AML risk flags, and platform treasury.',
                _ => 'Review settlements, processor health, wallet movements, and exceptions from one workspace.',
              });

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
                      title,
                      style: GoogleFonts.inter(
                        fontSize: isCompact ? 22 : 26,
                        fontWeight: FontWeight.w800,
                        color: _PaymentsPageState.dark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(color: _PaymentsPageState.muted, height: 1.4, fontSize: 13),
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

class _StatsGrid extends ConsumerWidget {
  final bool isDesktop;

  const _StatsGrid({required this.isDesktop});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDemo = ref.watch(isDemoModeProvider);
    final role = ref.watch(appStateProvider).role;
    final isEndUser = role == UserRole.consumer;
    final isB2BWholesaler = role == UserRole.buyer;

    final List<_StatData> cards;

    if (isEndUser) {
      cards = [
        _StatData('Total Spent', isDemo ? 'US\$ 142.50' : 'US\$ 0.00', Icons.shopping_bag_outlined),
        _StatData('Farm Savings', isDemo ? 'US\$ 46.80' : 'US\$ 0.00', Icons.savings_outlined),
        _StatData('Orders', isDemo ? '3 Active' : '0 Active', Icons.receipt_long_outlined),
        _StatData('EcoCash Wallet', isDemo ? 'US\$ 25.00' : 'US\$ 0.00', Icons.phone_android_outlined),
      ];
    } else if (isB2BWholesaler) {
      cards = [
        _StatData('Escrow Locked', isDemo ? 'US\$ 48,250' : 'US\$ 0', Icons.lock_clock_outlined),
        _StatData('Pending Inspect', isDemo ? 'US\$ 14,000' : 'US\$ 0', Icons.hourglass_top_outlined),
        _StatData('Cleared Payouts', isDemo ? 'US\$ 182,000' : 'US\$ 0', Icons.payments_outlined),
        _StatData('Trade Credit Line', isDemo ? 'US\$ 100,000' : 'US\$ 0', Icons.security_outlined),
      ];
    } else {
      switch (role) {
        case UserRole.farmer:
          cards = [
            _StatData('Harvest Proceeds', isDemo ? 'US\$ 4,250' : 'US\$ 0', Icons.payments_outlined),
            _StatData('In Escrow Vault', isDemo ? 'US\$ 1,800' : 'US\$ 0', Icons.lock_clock_outlined),
            _StatData('Input Loans Deducted', isDemo ? 'US\$ 420' : 'US\$ 0', Icons.spa_outlined),
            _StatData('Instant Cashout', isDemo ? 'US\$ 2,030' : 'US\$ 0', Icons.send_outlined),
          ];
          break;
        case UserRole.transporter:
          cards = [
            _StatData('Freight Billed', isDemo ? 'US\$ 3,150' : 'US\$ 0', Icons.local_shipping_outlined),
            _StatData('Pending POD Signoff', isDemo ? 'US\$ 650' : 'US\$ 0', Icons.hourglass_top_outlined),
            _StatData('Diesel Fuel Wallet', isDemo ? 'US\$ 480' : 'US\$ 0', Icons.local_gas_station_outlined),
            _StatData('Net Cleared', isDemo ? 'US\$ 2,020' : 'US\$ 0', Icons.payments_outlined),
          ];
          break;
        case UserRole.financier:
          cards = [
            _StatData('Portfolio Active', isDemo ? 'US\$ 450,000' : 'US\$ 0', Icons.account_balance_outlined),
            _StatData('Tranches Disbursed', isDemo ? 'US\$ 320,000' : 'US\$ 0', Icons.send_outlined),
            _StatData('Collateral Locked', isDemo ? 'US\$ 130,000' : 'US\$ 0', Icons.lock_clock_outlined),
            _StatData('Repayment Rate', isDemo ? '99.2%' : '100%', Icons.check_circle_outlined),
          ];
          break;
        case UserRole.valueAdder:
          cards = [
            _StatData('Raw Intake Settled', isDemo ? 'US\$ 64,500' : 'US\$ 0', Icons.factory_outlined),
            _StatData('Pending QA Cleared', isDemo ? 'US\$ 12,200' : 'US\$ 0', Icons.hourglass_top_outlined),
            _StatData('Factory Credit Line', isDemo ? 'US\$ 85,000' : 'US\$ 0', Icons.account_balance_outlined),
            _StatData('Wholesale Invoices', isDemo ? 'US\$ 41,000' : 'US\$ 0', Icons.receipt_long_outlined),
          ];
          break;
        case UserRole.admin:
        case UserRole.government:
        default:
          cards = [
            _StatData('Total Escrow Vault', isDemo ? 'US\$ 1,428,500' : 'US\$ 0', Icons.lock_clock_outlined),
            _StatData('Gateway Success', isDemo ? '99.98%' : '100%', Icons.phone_android_outlined),
            _StatData('SADC RTGS Settled', isDemo ? 'US\$ 640,000' : 'US\$ 0', Icons.account_balance_outlined),
            _StatData('Treasury Reserve', isDemo ? 'US\$ 124,000' : 'US\$ 0', Icons.payments_outlined),
          ];
          break;
      }
    }

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