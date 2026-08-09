import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../state/cart_state.dart';
import '../state/app_state.dart';
import '../state/platform_data_state.dart';
import '../features/auth/state/auth_state.dart';
import '../features/logistics/data/logistics_data.dart';

class CartDrawer extends ConsumerWidget {
  const CartDrawer({super.key});

  static const green = Color(0xFF16A34A);
  static const dark = Color(0xFF0F172A);
  static const muted = Color(0xFF64748B);
  static const cream = Color(0xFFF7F9FC);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final notifier = ref.read(cartProvider.notifier);

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Shopping Cart',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: dark,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Divider(color: Colors.grey.shade300, height: 1),
            Expanded(
              child: cart.items.isEmpty
                  ? _EmptyCart(onBrowse: () => Navigator.pop(context))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: cart.items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = cart.items[index];

                        return Dismissible(
                          key: ValueKey(item.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 16),
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Icon(Icons.delete_outline, color: Colors.red.shade700),
                          ),
                          onDismissed: (_) {
                            notifier.removeItem(item.id);
                          },
                          child: _CartItemCard(item: item),
                        );
                      },
                    ),
            ),
            if (cart.items.isNotEmpty) ...[
              Divider(color: Colors.grey.shade300, height: 1),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _SummaryRow(label: 'Items', value: '${cart.itemCount}'),
                    const SizedBox(height: 8),
                    _SummaryRow(label: 'Subtotal', value: '\$${cart.total.toStringAsFixed(2)}'),
                    const SizedBox(height: 8),
                    _SummaryRow(label: 'Delivery', value: '\$0.00'),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context); // Close the drawer
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => const CheckoutDialog(),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Checkout'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: cart.items.isEmpty ? null : notifier.clear,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: green,
                          side: const BorderSide(color: green),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Clear Cart'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CartItemCard extends ConsumerWidget {
  final CartItem item;

  const _CartItemCard({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(cartProvider.notifier);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: item.imageUrl.startsWith('assets/')
                ? Image.asset(
                    item.imageUrl,
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                  )
                : CachedNetworkImage(
                    imageUrl: item.imageUrl,
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 72,
                      height: 72,
                      color: Colors.grey.shade200,
                      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 72,
                      height: 72,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.broken_image_outlined),
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: _DrawerColors.dark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.price,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: _DrawerColors.green,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _QtyButton(
                      icon: Icons.remove,
                      onTap: () => notifier.decrement(item.id),
                    ),
                    Container(
                      width: 40,
                      alignment: Alignment.center,
                      child: Text(
                        '${item.quantity}',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    _QtyButton(
                      icon: Icons.add,
                      onTap: () => notifier.increment(item.id),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => notifier.removeItem(item.id),
                      icon: const Icon(Icons.delete_outline),
                      color: Colors.red.shade700,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QtyButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 20,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: _DrawerColors.green.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: _DrawerColors.green),
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  final VoidCallback onBrowse;

  const _EmptyCart({required this.onBrowse});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 72, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            const Text(
              'Your cart is empty',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Add produce from the marketplace to start building an order.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onBrowse,
              style: ElevatedButton.styleFrom(
                backgroundColor: _DrawerColors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Browse Marketplace'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: _DrawerColors.muted)),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w800, color: _DrawerColors.dark),
        ),
      ],
    );
  }
}

class _DrawerColors {
  static const green = Color(0xFF16A34A);
  static const dark = Color(0xFF0F172A);
  static const muted = Color(0xFF64748B);
}

class CheckoutDialog extends ConsumerStatefulWidget {
  const CheckoutDialog({super.key});

  @override
  ConsumerState<CheckoutDialog> createState() => _CheckoutDialogState();
}

class _CheckoutDialogState extends ConsumerState<CheckoutDialog> {
  int _currentStep = 0;

  // Step 1: Logistics Selection
  bool _needTransport = false;
  int _selectedTransportIndex = 0;
  int _selectedDestinationIndex = 0;

  final List<Map<String, dynamic>> _destinations = const [
    {'name': 'Harare Market', 'distance': 80.0},
    {'name': 'Bulawayo Hub', 'distance': 430.0},
    {'name': 'Masvingo Depot', 'distance': 290.0},
    {'name': 'Mutare Center', 'distance': 260.0},
    {'name': 'Gweru Hub', 'distance': 280.0},
  ];

  // Step 2: Payment Selection
  String _selectedPaymentMethod = 'Ecocash';
  final List<String> _paymentMethods = const [
    'Ecocash',
    'OneMoney',
    'Telecash',
    'Card / Paynow',
    'Bank Transfer',
    'Pay Onsite - Cash'
  ];

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final trucks = ref.watch(trucksListProvider);
    final subtotal = cart.total;
    final distance = _destinations[_selectedDestinationIndex]['distance'] as double;
    final rate = (trucks.isNotEmpty && _selectedTransportIndex < trucks.length) ? trucks[_selectedTransportIndex].costPerKm : 0.20;
    final transportCost = _needTransport ? (distance * rate) : 0.0;
    final total = subtotal + transportCost;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Verdi Checkout',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ),
                if (_currentStep < 2)
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            // Step indicator
            Row(
              children: [
                _stepIndicator(0, 'Logistics'),
                _stepDivider(),
                _stepIndicator(1, 'Payment'),
                _stepDivider(),
                _stepIndicator(2, 'Success'),
              ],
            ),
            const SizedBox(height: 20),
            Flexible(
              child: SingleChildScrollView(
                child: _buildStepContent(cart, trucks, subtotal, transportCost, total),
              ),
            ),
            const SizedBox(height: 20),
            if (_currentStep < 2)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (_currentStep > 0)
                    TextButton(
                      onPressed: () => setState(() => _currentStep--),
                      child: const Text('Back', style: TextStyle(color: Color(0xFF64748B))),
                    ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _handleNext(cart, trucks, subtotal, transportCost, total),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(_currentStep == 1 ? 'Confirm & Pay' : 'Continue'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _stepIndicator(int step, String label) {
    final active = _currentStep == step;
    final completed = _currentStep > step;
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: active
                ? const Color(0xFF16A34A)
                : completed
                    ? const Color(0xFF16A34A).withValues(alpha: 0.2)
                    : Colors.grey.shade200,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: completed
              ? const Icon(Icons.check, size: 14, color: Color(0xFF16A34A))
              : Text(
                  '${step + 1}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: active ? Colors.white : Colors.grey.shade600,
                  ),
                ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
            color: active ? const Color(0xFF0F172A) : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _stepDivider() {
    return Expanded(
      child: Container(
        height: 1,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        color: Colors.grey.shade300,
      ),
    );
  }

  Widget _buildStepContent(CartState cart, List<TruckItem> trucks, double subtotal, double transportCost, double total) {
    if (_currentStep == 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review Items',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black12),
            ),
            child: Column(
              children: [
                ...cart.items.map((item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${item.name} x${item.quantity}', style: const TextStyle(fontWeight: FontWeight.w600)),
                          Text(item.price),
                        ],
                      ),
                    )),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Subtotal', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('\$${subtotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          CheckboxListTile(
            title: Text(
              'Find Available Transport',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            subtitle: const Text('Arrange driver dispatch and route scheduling'),
            value: _needTransport,
            onChanged: (v) {
              if (v != null) setState(() => _needTransport = v);
            },
            activeColor: const Color(0xFF16A34A),
            contentPadding: EdgeInsets.zero,
          ),
          if (_needTransport) ...[
            const SizedBox(height: 10),
            Text(
              'Select Destination',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: const Color(0xFF64748B)),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<int>(
              value: _selectedDestinationIndex,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: List.generate(_destinations.length, (i) {
                final dest = _destinations[i];
                return DropdownMenuItem<int>(
                  value: i,
                  child: Text('${dest['name']} (${dest['distance'].toStringAsFixed(0)} km)'),
                );
              }),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedDestinationIndex = val;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Select Driver & Vehicle',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: const Color(0xFF64748B)),
            ),
            const SizedBox(height: 8),
            ...List.generate(trucks.length, (index) {
              final opt = trucks[index];
              final selected = _selectedTransportIndex == index;
              final dist = _destinations[_selectedDestinationIndex]['distance'] as double;
              final cost = dist * opt.costPerKm;

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected ? const Color(0xFF16A34A) : Colors.black12,
                    width: selected ? 2 : 1,
                  ),
                ),
                child: ListTile(
                  onTap: () => setState(() => _selectedTransportIndex = index),
                  leading: CircleAvatar(
                    backgroundColor: selected ? const Color(0xFF16A34A).withValues(alpha: 0.1) : Colors.grey.shade100,
                    child: Icon(Icons.local_shipping_outlined, color: selected ? const Color(0xFF16A34A) : Colors.grey),
                  ),
                  title: Text('${opt.driver} • ${opt.vehicle}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('ETA: ${opt.eta} • \$${opt.costPerKm.toStringAsFixed(2)}/km'),
                  trailing: Text(
                    '\$${cost.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: selected ? const Color(0xFF16A34A) : Colors.black87,
                    ),
                  ),
                ),
              );
            }),
          ],
        ],
      );
    } else if (_currentStep == 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black12),
            ),
            child: Column(
              children: [
                _SummaryRow(label: 'Subtotal', value: '\$${subtotal.toStringAsFixed(2)}'),
                const SizedBox(height: 8),
                _SummaryRow(label: 'Transport Fee', value: '\$${transportCost.toStringAsFixed(2)}'),
                const Divider(),
                _SummaryRow(label: 'Total Amount', value: '\$${total.toStringAsFixed(2)}'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Select Payment Method',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 10),
          ..._paymentMethods.map((method) {
            final selected = _selectedPaymentMethod == method;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected ? const Color(0xFF16A34A) : Colors.black12,
                  width: selected ? 2 : 1,
                ),
              ),
              child: RadioListTile<String>(
                title: Text(method, style: const TextStyle(fontWeight: FontWeight.bold)),
                value: method,
                groupValue: _selectedPaymentMethod,
                onChanged: (v) {
                  if (v != null) setState(() => _selectedPaymentMethod = v);
                },
                activeColor: const Color(0xFF16A34A),
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            );
          }),
        ],
      );
    } else {
      // Step 3: Success Screen
      final driverName = (trucks.isNotEmpty && _selectedTransportIndex < trucks.length) ? trucks[_selectedTransportIndex].driver : 'Tafadzwa M.';
      return Column(
        children: [
          const SizedBox(height: 20),
          const Center(
            child: Icon(
              Icons.check_circle_outline,
              color: Color(0xFF16A34A),
              size: 80,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Order Placed Successfully!',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your payment has been processed and order dispatch has been registered.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF16A34A).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF16A34A).withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.shield_outlined, color: Color(0xFF16A34A), size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Automated Verdi Escrow Settlement',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF16A34A)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Seller Net Settlement (97.0%)', style: TextStyle(fontSize: 11.5)),
                    Text('US\$ ${(subtotal * 0.97).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Verdi Service Fee (3.0% per T&Cs)', style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
                    Text('US\$ ${(subtotal * 0.03).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: Color(0xFF64748B))),
                  ],
                ),
                if (_needTransport) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Transporter Payout ($driverName)', style: const TextStyle(fontSize: 11.5)),
                      Text('US\$ ${transportCost.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5)),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  ref.read(appStateProvider.notifier).setNavIndex(4); // Go to Orders
                },
                icon: const Icon(Icons.shopping_bag_outlined),
                label: const Text('View Orders'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  ref.read(appStateProvider.notifier).setNavIndex(6); // Go to Payments
                },
                icon: const Icon(Icons.receipt_long_outlined),
                label: const Text('View Transactions'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              if (_needTransport)
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ref.read(appStateProvider.notifier).setNavIndex(5); // Go to Logistics
                  },
                  icon: const Icon(Icons.local_shipping_outlined),
                  label: const Text('Track Logistics'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close Dialog', style: TextStyle(color: Color(0xFF64748B))),
          ),
        ],
      );
    }
  }

  Future<bool> _processPayment(BuildContext context, String method, double amount) async {
    switch (method) {
      case 'Ecocash':
        return await _showMobileMoneyDialog(context, "Ecocash", amount, "*150#", 9, 4) ?? false;
      case 'OneMoney':
        return await _showMobileMoneyDialog(context, "OneMoney", amount, "*303#", 9, 4) ?? false;
      case 'Telecash':
        return await _showMobileMoneyDialog(context, "Telecash", amount, "*483#", 9, 4) ?? false;
      case 'Card / Paynow':
        return await _showCardDialog(context, amount) ?? false;
      case 'Bank Transfer':
        return await _showBankDialog(context, amount) ?? false;
      case 'Pay Onsite - Cash':
        return true; // Instant success
      default:
        return true;
    }
  }

  Future<bool?> _showMobileMoneyDialog(BuildContext context, String name, double amount, String ussd, int phoneLen, int pinLen) async {
    String phone = "";
    String pin = "";
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final formKey = GlobalKey<FormState>();
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text("Pay with $name", style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Pay \$${amount.toStringAsFixed(2)} to Verdi", style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "$name Number",
                    prefixText: "+263 ",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (val) {
                    if (val == null || val.length != phoneLen) {
                      return 'Enter a valid $phoneLen digit number';
                    }
                    return null;
                  },
                  onChanged: (val) => phone = val,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "$name PIN",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  obscureText: true,
                  autofillHints: const [],
                  keyboardType: TextInputType.number,
                  validator: (val) {
                    if (val == null || val.length != pinLen) {
                      return 'Enter your $pinLen digit PIN';
                    }
                    return null;
                  },
                  onChanged: (val) => pin = val,
                ),
                const SizedBox(height: 10),
                Text("*Test Mode. Dial $ussd for real payments*", style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  debugPrint("Mobile money payment submitted for number $phone with pin length ${pin.length}");
                  Navigator.pop(context, true);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("Pay Now"),
            ),
          ],
        );
      },
    );
  }

  Future<bool?> _showCardDialog(BuildContext context, double amount) async {
    String card = "";
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final formKey = GlobalKey<FormState>();
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text("Pay with Card", style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Pay \$${amount.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "Card Number",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (val) {
                    if (val == null || val.length != 16) {
                      return 'Enter 16 digit card number';
                    }
                    return null;
                  },
                  onChanged: (val) => card = val,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: "MM/YY",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Required';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: "CVV",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        obscureText: true,
                        autofillHints: const [],
                        validator: (val) {
                          if (val == null || val.length != 3) {
                            return 'Invalid';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text("*Test Mode. Uses Paynow/Stripe in production*", style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  debugPrint("Card payment submitted for card length ${card.length}");
                  Navigator.pop(context, true);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text("Pay \$${amount.toStringAsFixed(2)}"),
            ),
          ],
        );
      },
    );
  }

  Future<bool?> _showBankDialog(BuildContext context, double amount) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Bank Transfer", style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Pay \$${amount.toStringAsFixed(2)} to:", style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            const Text("Bank: Stanbic Bank ZW", style: TextStyle(fontWeight: FontWeight.w500)),
            const Text("Account: Verdi Tech P/L"),
            const Text("Acc No: 914000123456"),
            const Text("Branch: 6102 Harare"),
            const SizedBox(height: 12),
            const Text("Upload proof of payment after transfer", style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 6),
            const Text("*Test Mode: Click Confirm to simulate*", style: TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF16A34A),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("I Have Paid"),
          ),
        ],
      ),
    );
  }

  void _handleNext(CartState cart, List<TruckItem> trucks, double subtotal, double transportCost, double total) async {
    if (_currentStep == 0) {
      setState(() => _currentStep = 1);
    } else if (_currentStep == 1) {
      // Step 2 -> Process payment first!
      final success = await _processPayment(context, _selectedPaymentMethod, total);
      if (!success) {
        // Payment failed or cancelled
        return;
      }

      // Complete Order!
      final orderId = '#ORD-${1000 + DateTime.now().millisecond}';
      final payId = '#PAY-${1000 + DateTime.now().millisecond}';
      final dlvId = '#DLV-${100 + DateTime.now().millisecond}';

      final productsString = cart.items.map((e) => e.name).join(', ');
      final quantitiesString = cart.items.map((e) => '${e.quantity} units').join(', ');
      
      final user = ref.read(authStateProvider).user;
      final buyerName = user?.fullName ?? 'sir Mufasa';
      final supplierString = cart.items.isNotEmpty ? cart.items.first.supplier : 'Mufasa Farm';

      // 1. Add Order
      ref.read(ordersListProvider.notifier).addOrder(
            OrderItem(
              id: orderId,
              buyer: buyerName,
              product: productsString,
              quantity: quantitiesString,
              destination: _needTransport ? _destinations[_selectedDestinationIndex]['name'] as String : 'Chiredzi',
              status: _needTransport ? 'Confirmed' : 'Delivered',
              payment: 'Paid',
              total: 'US\$ ${total.toStringAsFixed(0)}',
              date: 'Today, ${DateFormat('HH:mm').format(DateTime.now())}',
              eta: _needTransport ? ((trucks.isNotEmpty && _selectedTransportIndex < trucks.length) ? trucks[_selectedTransportIndex].eta : '30m') : 'Completed',
              priority: 'High',
              supplier: supplierString,
            ),
          );

      // 2. Add Payment Transaction
      ref.read(paymentsListProvider.notifier).addPayment(
            PaymentItem(
              id: payId,
              party: buyerName,
              type: 'Buyer Payment',
              amount: 'US\$ ${total.toStringAsFixed(0)}',
              status: 'Completed',
              method: _selectedPaymentMethod,
              date: 'Today, ${DateFormat('HH:mm').format(DateTime.now())}',
              ref: 'TXN-${1000 + DateTime.now().millisecond}',
              note: '$productsString Purchase',
              riskLevel: 'Low',
              settlementWindow: 'Completed',
              currency: 'USD',
              destination: 'Harare Wallet',
              timeline: const ['Initiated', 'Captured', 'Settled'],
            ),
          );

      // 3. Automated Payout Split Routing
      // 3a. Product share goes to Crop Seller (Supplier)
      ref.read(paymentsListProvider.notifier).addPayment(
            PaymentItem(
              id: '#PAY-${2000 + DateTime.now().millisecond}',
              party: supplierString,
              type: 'Payout',
              amount: 'US\$ ${subtotal.toStringAsFixed(0)}',
              status: 'Completed',
              method: 'Direct Deposit',
              date: 'Today, ${DateFormat('HH:mm').format(DateTime.now())}',
              ref: 'SPLIT-SEL-${1000 + DateTime.now().millisecond}',
              note: 'Seller split for order $orderId',
              riskLevel: 'Low',
              settlementWindow: 'Instant',
              currency: 'USD',
              destination: '$supplierString Merchant Wallet',
              timeline: const ['Split Routed', 'Completed'],
            ),
          );

      // 3b. Logistics share goes to Transporter (if transport selected)
      if (_needTransport && trucks.isNotEmpty && _selectedTransportIndex < trucks.length) {
        final opt = trucks[_selectedTransportIndex];
        ref.read(paymentsListProvider.notifier).addPayment(
              PaymentItem(
                id: '#PAY-${3000 + DateTime.now().millisecond}',
                party: '${opt.driver} (Driver)',
                type: 'Payout',
                amount: 'US\$ ${transportCost.toStringAsFixed(0)}',
                status: 'Completed',
                method: 'EcoCash Wallet',
                date: 'Today, ${DateFormat('HH:mm').format(DateTime.now())}',
                ref: 'SPLIT-TRN-${1000 + DateTime.now().millisecond}',
                note: 'Transporter split for order $orderId',
                riskLevel: 'Low',
                settlementWindow: 'Instant',
                currency: 'USD',
                destination: '${opt.driver} Mobile Wallet',
                timeline: const ['Split Routed', 'Completed'],
              ),
            );
      }

      // 3. Add Delivery Shipment (if transport requested)
      if (_needTransport && trucks.isNotEmpty && _selectedTransportIndex < trucks.length) {
        final opt = trucks[_selectedTransportIndex];
        ref.read(deliveriesListProvider.notifier).addDelivery(
              DeliveryItem(
                id: dlvId,
                customer: buyerName,
                product: productsString,
                quantity: quantitiesString,
                from: opt.from,
                to: _destinations[_selectedDestinationIndex]['name'] as String,
                status: 'Pending',
                driver: opt.driver,
                vehicle: opt.vehicle,
                eta: opt.eta,
                progress: 0.12,
                hub: 'Harare Hub',
                priority: 'High',
                riskLevel: 'Low',
                exceptionType: 'None',
                proofStatus: 'Pending review',
                temperature: '18°C',
                distanceRemaining: '38 km',
                timeline: const ['Order placed', 'Driver assigned', 'Awaiting pickup'],
              ),
            );
      }

      // 4. Clear the shopping cart
      ref.read(cartProvider.notifier).clear();

      setState(() => _currentStep = 2);
    }
  }
}