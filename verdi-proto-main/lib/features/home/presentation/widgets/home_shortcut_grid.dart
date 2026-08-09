import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../state/app_state.dart';
import '../../../../core/enums/verdi_screen.dart';

class HomeShortcutGrid extends ConsumerWidget {
  const HomeShortcutGrid({super.key});

  static const green = Color(0xFF16A34A);
  static const dark = Color(0xFF0F172A);
  static const orange = Color(0xFFF97316);
  static const blue = Color(0xFF2563EB);
  static const purple = Color(0xFF7C3AED);
  static const teal = Color(0xFF0F766E);
  static const muted = Color(0xFF64748B);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = [
      _ShortcutItem('Marketplace', 'Buy & sell produce', Icons.storefront_outlined, green, VerdiScreen.marketplace),
      _ShortcutItem('Verdi AI Chat', 'Agronomy & pricing AI', Icons.chat_bubble_outline, blue, VerdiScreen.chats),
      _ShortcutItem('Control Tower', 'Super admin center', Icons.admin_panel_settings_outlined, orange, VerdiScreen.admin),
      _ShortcutItem('Analytics', 'Yield & revenue trends', Icons.insights_outlined, purple, VerdiScreen.analytics),
      _ShortcutItem('Satellites', 'Sentinel-2 NDVI feeds', Icons.satellite_alt_outlined, teal, VerdiScreen.satellites),
      _ShortcutItem('Export & Trade', 'ePhyto customs & routes', Icons.local_shipping_outlined, orange, VerdiScreen.export),
      _ShortcutItem('Smart Irrigation', 'IoT pump control', Icons.water_drop_outlined, blue, VerdiScreen.irrigation),
      _ShortcutItem('Ministry Portal', 'National grain & quota', Icons.account_balance_outlined, green, VerdiScreen.government),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final cols = w >= 800 ? 4 : (w >= 480 ? 2 : 2);
        final childAspectRatio = w >= 800 ? 3.0 : (w >= 480 ? 3.2 : 2.7);

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: childAspectRatio,
          ),
          itemBuilder: (context, i) {
            final item = items[i];
            return Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                onTap: () {
                  ref.read(appStateProvider.notifier).setNavIndex(item.screen.pageIndex);
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: item.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(item.icon, color: item.color, size: 18),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              item.title,
                              style: GoogleFonts.inter(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: dark,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.subtitle,
                              style: GoogleFonts.inter(fontSize: 10, color: muted),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _ShortcutItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VerdiScreen screen;

  _ShortcutItem(this.title, this.subtitle, this.icon, this.color, this.screen);
}
