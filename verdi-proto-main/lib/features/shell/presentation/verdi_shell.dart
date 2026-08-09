import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../home/presentation/home_page.dart';
import '../../weather/presentation/weather_page.dart';
import '../../alerts/presentation/alerts_page.dart';
import '../../logistics/presentation/logistics_dashboard_page.dart';
import '../../analytics/presentation/analytics_page.dart';
import '../../crop_health/presentation/crop_health_page.dart';
import '../../marketplace/presentation/marketplace_page.dart';

class VerdiShell extends StatefulWidget {
  const VerdiShell({super.key});

  @override
  State<VerdiShell> createState() => _VerdiShellState();
}

class _VerdiShellState extends State<VerdiShell> {
  int _index = 0;

  final _pages = const [
    HomePage(),
    WeatherPage(),
    AlertsPage(),
    LogisticsDashboardPage(),
    AnalyticsPage(),
    CropHealthPage(),
    MarketplacePage(),
  ];

  final _titles = const [
    'Home',
    'Weather',
    'Alerts',
    'Logistics',
    'Analytics',
    'Crop Health',
    'Marketplace',
  ];

  final _icons = const [
    Icons.home_outlined,
    Icons.cloud_outlined,
    Icons.notifications_outlined,
    Icons.local_shipping_outlined,
    Icons.show_chart_outlined,
    Icons.health_and_safety_outlined,
    Icons.storefront_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 900;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Verdi',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      drawer: isWide ? null : _buildDrawer(),
      body: isWide ? _wideLayout() : _pages[_index],
      bottomNavigationBar: isWide ? null : _buildBottomNav(),
    );
  }

  Widget _wideLayout() {
    return Row(
      children: [
        NavigationRail(
          selectedIndex: _index,
          onDestinationSelected: (value) => setState(() => _index = value),
          labelType: NavigationRailLabelType.all,
          backgroundColor: Colors.green.shade50,
          selectedIconTheme: IconThemeData(color: Colors.green.shade800),
          selectedLabelTextStyle: TextStyle(
            color: Colors.green.shade800,
            fontWeight: FontWeight.w600,
          ),
          destinations: List.generate(
            _titles.length,
            (i) => NavigationRailDestination(
              icon: Icon(_icons[i]),
              selectedIcon: Icon(_icons[i], color: Colors.green.shade800),
              label: Text(_titles[i]),
            ),
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(child: _pages[_index]),
      ],
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: SafeArea(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.green.shade700),
              child: const Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  'Verdi',
                  style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            for (int i = 0; i < _titles.length; i++)
              ListTile(
                leading: Icon(_icons[i]),
                title: Text(_titles[i]),
                selected: _index == i,
                onTap: () {
                  setState(() => _index = i);
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _index,
      onTap: (value) => setState(() => _index = value),
      selectedItemColor: Colors.green.shade800,
      unselectedItemColor: Colors.grey.shade600,
      type: BottomNavigationBarType.fixed,
      items: List.generate(
        _titles.length,
        (i) => BottomNavigationBarItem(
          icon: Icon(_icons[i]),
          label: _titles[i],
        ),
      ),
    );
  }
}