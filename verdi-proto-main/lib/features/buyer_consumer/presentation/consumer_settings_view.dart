import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../state/app_state.dart';
import '../../auth/presentation/widgets/buyer_sub_role_dialog.dart';

class ConsumerSettingsView extends ConsumerStatefulWidget {
  const ConsumerSettingsView({super.key});

  @override
  ConsumerState<ConsumerSettingsView> createState() => _ConsumerSettingsViewState();
}

class _ConsumerSettingsViewState extends ConsumerState<ConsumerSettingsView> {
  bool _notifyPromos = true;
  bool _notifyChats = true;
  bool _notifyDriverArrival = true;

  String _selectedPaymentMethod = 'EcoCash Wallet (077 412 9081)';
  String _selectedAddress = '14 Avondale West, Harare (Home Delivery)';

  final List<String> _addresses = [
    '14 Avondale West, Harare (Home Delivery)',
    'Shop 4, Borrowdale Village, Harare (Office)',
    'Farm Gate Hub 2, Mazowe Highway (Pickup Point)',
  ];

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appStateProvider);
    final notifier = ref.read(appStateProvider.notifier);

    return Container(
      color: const Color(0xFFF8FAFC),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile & Role Banner
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: Color(0xFF10B981),
                    child: Icon(Icons.person, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Customer / End-User Profile', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                        const SizedBox(height: 2),
                        const Text('Direct Farm-to-Table Grocery & Household Consumer', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final chosen = await BuyerSubRoleDialog.show(context, current: state.buyerSubRole);
                      if (chosen != null) {
                        notifier.setBuyerSubRole(chosen);
                      }
                    },
                    icon: const Icon(Icons.swap_horiz, size: 16),
                    label: const Text('Switch Role', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Delivery Addresses
            _buildSectionHeader(Icons.location_on_outlined, 'Delivery Addresses'),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  ..._addresses.map((addr) => RadioListTile<String>(
                    title: Text(addr, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                    value: addr,
                    groupValue: _selectedAddress,
                    activeColor: const Color(0xFF10B981),
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedAddress = val);
                    },
                  )),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Add new delivery address dialog opened.'), backgroundColor: Color(0xFF10B981)),
                      );
                    },
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add New Delivery Address', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF10B981), side: const BorderSide(color: Color(0xFF10B981))),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Payment Methods
            _buildSectionHeader(Icons.account_balance_wallet_outlined, 'Payment Methods'),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _buildPaymentTile('EcoCash Wallet (077 412 9081)', Icons.phone_android, const Color(0xFF16A34A)),
                  _buildPaymentTile('InnBucks QR Code', Icons.qr_code_2, const Color(0xFFF59E0B)),
                  _buildPaymentTile('Cash on Delivery', Icons.payments_outlined, const Color(0xFF3B82F6)),
                  _buildPaymentTile('Visa / Mastercard (•••• 8812)', Icons.credit_card, const Color(0xFF6366F1)),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Push Notifications & Alerts
            _buildSectionHeader(Icons.notifications_active_outlined, 'Push Notification Alerts'),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Flash Sales & Fresh Harvest Deals', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
                    subtitle: const Text('Instant pop-up alerts when nearby farmers offer discounts', style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
                    value: _notifyPromos,
                    activeColor: const Color(0xFF10B981),
                    onChanged: (v) => setState(() => _notifyPromos = v),
                  ),
                  const Divider(color: Color(0xFFF1F5F9), height: 1),
                  SwitchListTile(
                    title: const Text('Direct Messages from Transporters & Farmers', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
                    subtitle: const Text('Receive immediate in-app chat notifications and ETA updates', style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
                    value: _notifyChats,
                    activeColor: const Color(0xFF10B981),
                    onChanged: (v) => setState(() => _notifyChats = v),
                  ),
                  const Divider(color: Color(0xFFF1F5F9), height: 1),
                  SwitchListTile(
                    title: const Text('InDrive Delivery Arrival Pop-Ups', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
                    subtitle: const Text('Sound alert when transporter is within 5 minutes of your gate', style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
                    value: _notifyDriverArrival,
                    activeColor: const Color(0xFF10B981),
                    onChanged: (v) => setState(() => _notifyDriverArrival = v),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Preferred Currency
            _buildSectionHeader(Icons.currency_exchange, 'Currency Display'),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: AppCurrency.values.map((c) {
                  final isSel = state.currency == c;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: InkWell(
                        onTap: () => notifier.setCurrency(c),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSel ? const Color(0xFF10B981).withOpacity(0.12) : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isSel ? const Color(0xFF10B981) : const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            children: [
                              Text(c.flag, style: const TextStyle(fontSize: 20)),
                              const SizedBox(height: 4),
                              Text(c.code, style: TextStyle(fontWeight: FontWeight.bold, color: isSel ? const Color(0xFF10B981) : const Color(0xFF0F172A), fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF10B981)),
          const SizedBox(width: 8),
          Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14, color: const Color(0xFF0F172A))),
        ],
      ),
    );
  }

  Widget _buildPaymentTile(String name, IconData icon, Color color) {
    return RadioListTile<String>(
      title: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
        ],
      ),
      value: name,
      groupValue: _selectedPaymentMethod,
      activeColor: const Color(0xFF10B981),
      contentPadding: EdgeInsets.zero,
      onChanged: (val) {
        if (val != null) setState(() => _selectedPaymentMethod = val);
      },
    );
  }
}
