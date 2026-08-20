import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../state/app_state.dart';

/// Interactive Poll Dialog to select between:
/// ① Retailer / Wholesaler (Commercial B2B Buyer)
/// ② Customer / End-User (Direct B2C Consumer)
class BuyerSubRoleDialog extends StatelessWidget {
  final BuyerSubRole initialSubRole;
  final ValueChanged<BuyerSubRole> onSelected;

  const BuyerSubRoleDialog({
    super.key,
    this.initialSubRole = BuyerSubRole.retailerWholesaler,
    required this.onSelected,
  });

  static Future<BuyerSubRole?> show(BuildContext context, {BuyerSubRole current = BuyerSubRole.retailerWholesaler}) {
    return showDialog<BuyerSubRole>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => BuyerSubRoleDialog(
        initialSubRole: current,
        onSelected: (chosen) => Navigator.pop(ctx, chosen),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF0F172A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: Color(0xFF1E293B), width: 1.5),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.shopping_cart_outlined, color: Color(0xFF10B981), size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Choose Buyer Profile',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Select how you purchase agricultural produce on Verdi',
                        style: TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Option 1: Retailer / Wholesaler (Commercial B2B)
            _buildOptionCard(
              context: context,
              icon: Icons.storefront_outlined,
              badge: 'B2B COMMERCIAL',
              badgeColor: const Color(0xFF3B82F6),
              title: '① Retailer / Wholesaler',
              subtitle: 'Bulk lot procurement, outgrower contracts, wholesale trade desk, and cold-chain logistics.',
              tags: ['Bulk Haulage', 'Forward Contracts', 'Wholesale Orders', 'Escrow Vault'],
              isSelected: initialSubRole == BuyerSubRole.retailerWholesaler,
              onTap: () => onSelected(BuyerSubRole.retailerWholesaler),
            ),

            const SizedBox(height: 12),

            // Option 2: Customer / End-User (Direct B2C Consumer)
            _buildOptionCard(
              context: context,
              icon: Icons.person_pin_circle_outlined,
              badge: 'B2C CONSUMER',
              badgeColor: const Color(0xFF10B981),
              title: '② Customer / End User',
              subtitle: 'Farm-to-table fresh produce, consumer web store, InDrive-style live transport tracking & direct messenger.',
              tags: ['Direct Farmgate Store', 'Live Driver Tracking', 'In-App Chat', 'Grocery AI Insights'],
              isSelected: initialSubRole == BuyerSubRole.endUserCustomer,
              onTap: () => onSelected(BuyerSubRole.endUserCustomer),
            ),

            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Color(0xFF94A3B8))),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required BuildContext context,
    required IconData icon,
    required String badge,
    required Color badgeColor,
    required String title,
    required String subtitle,
    required List<String> tags,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? badgeColor.withOpacity(0.12) : const Color(0xFF161E2E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? badgeColor : const Color(0xFF2D3748),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: badgeColor.withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 4))]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: badgeColor.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: badgeColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: badgeColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: badgeColor.withOpacity(0.5)),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(color: badgeColor, fontSize: 9.5, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 12, height: 1.35),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: tags.map((t) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: Text(t, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10.5)),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
