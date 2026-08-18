import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppNavigationDrawer extends StatelessWidget {
  final String currentRoute;
  final ValueChanged<String> onNavigate;

  const AppNavigationDrawer({
    super.key,
    required this.currentRoute,
    required this.onNavigate,
  });

  void _go(BuildContext context, String route) {
    Navigator.of(context).pop();
    onNavigate(route);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF16A34A), Color(0xFF0F172A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.agriculture_outlined,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Verdi',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Farm operations shell',
                    style: GoogleFonts.inter(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _DrawerSectionTitle(title: 'Operations'),
                  _DrawerItem(
                    icon: Icons.storefront_outlined,
                    title: 'Marketplace',
                    selected: currentRoute == '/marketplace',
                    onTap: () => _go(context, '/marketplace'),
                  ),
                  _DrawerItem(
                    icon: Icons.receipt_long_outlined,
                    title: 'Orders',
                    selected: currentRoute == '/orders',
                    onTap: () => _go(context, '/orders'),
                  ),
                  _DrawerItem(
                    icon: Icons.payments_outlined,
                    title: 'Payments',
                    selected: currentRoute == '/payments',
                    onTap: () => _go(context, '/payments'),
                  ),
                  const SizedBox(height: 8),
                  _DrawerSectionTitle(title: 'Farm Control'),
                  _DrawerItem(
                    icon: Icons.water_outlined,
                    title: 'Farm Operations',
                    selected: currentRoute == '/farm-operations',
                    onTap: () => _go(context, '/farm-operations'),
                  ),
                  _DrawerItem(
                    icon: Icons.map_outlined,
                    title: 'Geospatial',
                    selected: currentRoute == '/geospatial',
                    onTap: () => _go(context, '/geospatial'),
                  ),
                  _DrawerItem(
                    icon: Icons.satellite_alt_outlined,
                    title: 'Satellite',
                    selected: currentRoute == '/satellite',
                    onTap: () => _go(context, '/satellite'),
                  ),
                  const SizedBox(height: 8),
                  _DrawerSectionTitle(title: 'Trade'),
                  _DrawerItem(
                    icon: Icons.local_shipping_outlined,
                    title: 'Logistics',
                    selected: currentRoute == '/logistics',
                    onTap: () => _go(context, '/logistics'),
                  ),
                  _DrawerItem(
                    icon: Icons.fact_check_outlined,
                    title: 'Traceability',
                    selected: currentRoute == '/traceability',
                    onTap: () => _go(context, '/traceability'),
                  ),
                  _DrawerItem(
                    icon: Icons.verified_outlined,
                    title: 'Exports',
                    selected: currentRoute == '/exports',
                    onTap: () => _go(context, '/exports'),
                  ),
                  const SizedBox(height: 8),
                  _DrawerSectionTitle(title: 'Support'),
                  _DrawerItem(
                    icon: Icons.assistant_outlined,
                    title: 'AI Assistant',
                    selected: currentRoute == '/assistant',
                    onTap: () => _go(context, '/assistant'),
                  ),
                  _DrawerItem(
                    icon: Icons.notifications_none_outlined,
                    title: 'Notifications',
                    selected: currentRoute == '/notifications',
                    onTap: () => _go(context, '/notifications'),
                  ),
                  _DrawerItem(
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    selected: currentRoute == '/settings',
                    onTap: () => _go(context, '/settings'),
                  ),
                  const SizedBox(height: 8),
                  _DrawerSectionTitle(title: 'Administration'),
                  _DrawerItem(
                    icon: Icons.admin_panel_settings_outlined,
                    title: 'Admin Command Center',
                    selected: currentRoute == '/admin',
                    onTap: () => _go(context, '/admin'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerSectionTitle extends StatelessWidget {
  final String title;

  const _DrawerSectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFF64748B),
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xFF16A34A);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        selected: selected,
        selectedTileColor: activeColor.withValues(alpha: 0.10),
        leading: Icon(
          icon,
          color: selected ? activeColor : const Color(0xFF64748B),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? activeColor : const Color(0xFF0F172A),
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
