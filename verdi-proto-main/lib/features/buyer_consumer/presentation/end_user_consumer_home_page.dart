import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../state/app_state.dart';
import '../../auth/presentation/widgets/buyer_sub_role_dialog.dart';
import 'indrive_transport_tracking_view.dart';
import 'consumer_settings_view.dart';

class ProduceItem {
  final String id;
  final String name;
  final String category;
  final String farm;
  final String freshness;
  final double priceUsd;
  final String unit;
  final IconData icon;
  final Color iconColor;
  final double rating;

  ProduceItem({
    required this.id,
    required this.name,
    required this.category,
    required this.farm,
    required this.freshness,
    required this.priceUsd,
    required this.unit,
    required this.icon,
    required this.iconColor,
    required this.rating,
  });
}

/// Dedicated Consumer / End-User Home Page & Web Store Experience
class EndUserConsumerHomePage extends ConsumerStatefulWidget {
  const EndUserConsumerHomePage({super.key});

  @override
  ConsumerState<EndUserConsumerHomePage> createState() => _EndUserConsumerHomePageState();
}

class _EndUserConsumerHomePageState extends ConsumerState<EndUserConsumerHomePage> {
  int _activeNavIndex = 0; // 0: Store/Marketplace, 1: Orders & Basket, 2: InDrive Tracking, 3: Direct Chats, 4: AI Grocery Insight, 5: Settings
  String _selectedCategory = 'All Fresh';
  String _searchQuery = '';

  final List<ProduceItem> _produceCatalog = [
    ProduceItem(id: 'PRD-101', name: 'Fresh Farmgate Tomatoes', category: 'Vegetables', farm: 'Mazowe Cooperative', freshness: 'Harvested 3h ago', priceUsd: 1.20, unit: 'per kg', icon: Icons.eco, iconColor: const Color(0xFFEF4444), rating: 4.9),
    ProduceItem(id: 'PRD-102', name: 'Sweet Sugar Maize (Corn)', category: 'Grains & Flour', farm: 'Marondera Outgrowers', freshness: 'Fresh morning harvest', priceUsd: 0.80, unit: 'per 3 cobs', icon: Icons.grass, iconColor: const Color(0xFFF59E0B), rating: 4.8),
    ProduceItem(id: 'PRD-103', name: 'Crisp English Spinach (Covo)', category: 'Vegetables', farm: 'Goromonzi Greenhouses', freshness: 'Hydroponic Grade A', priceUsd: 0.60, unit: 'per bunch', icon: Icons.spa, iconColor: const Color(0xFF10B981), rating: 4.9),
    ProduceItem(id: 'PRD-104', name: 'Organic Hass Avocados', category: 'Fruits', farm: 'Chipinge Highland Orchards', freshness: 'Tree-ripened', priceUsd: 2.50, unit: 'per 4-pack', icon: Icons.nature, iconColor: const Color(0xFF059669), rating: 5.0),
    ProduceItem(id: 'PRD-105', name: 'Farm-Fresh Free Range Eggs', category: 'Eggs & Dairy', farm: 'Harare South Poultry', freshness: 'Laid today', priceUsd: 3.80, unit: 'per crate (30)', icon: Icons.egg_outlined, iconColor: const Color(0xFFD97706), rating: 4.9),
    ProduceItem(id: 'PRD-106', name: 'Red Creole Onions', category: 'Vegetables', farm: 'Norton Commercial Plots', freshness: 'Cured & Dry', priceUsd: 1.40, unit: 'per 2kg bag', icon: Icons.circle, iconColor: const Color(0xFF9333EA), rating: 4.7),
    ProduceItem(id: 'PRD-107', name: 'Sweet Butternut Squash', category: 'Vegetables', farm: 'Chegutu Solar Irrigation Farm', freshness: 'Organically grown', priceUsd: 1.10, unit: 'per kg', icon: Icons.energy_savings_leaf, iconColor: const Color(0xFFEA580C), rating: 4.8),
    ProduceItem(id: 'PRD-108', name: 'Pure Raw Blossom Honey', category: 'Herbs & Spices', farm: 'Nyanga Apiaries', freshness: '100% Unprocessed', priceUsd: 4.50, unit: '500g glass jar', icon: Icons.bubble_chart, iconColor: const Color(0xFFCA8A04), rating: 5.0),
  ];

  final Map<String, int> _cart = {};

  void _addToCart(ProduceItem item) {
    setState(() {
      _cart[item.id] = (_cart[item.id] ?? 0) + 1;
    });

    // In-app push pop-up alert
    _showPushPopUp(
      title: 'Added to Fresh Basket',
      message: '${item.name} (${_cart[item.id]} in basket)',
      icon: Icons.shopping_basket,
      color: const Color(0xFF10B981),
    );
  }

  void _showPushPopUp({required String title, required String message, required IconData icon, required Color color}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.2), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
                  Text(message, style: const TextStyle(fontSize: 11.5, color: Colors.white70)),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF0F172A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appStateProvider);
    final totalCartItems = _cart.values.fold(0, (a, b) => a + b);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // ───────────────────────────────────────────────────────────────────
          // CONSUMER TOP HEADER NAVIGATION BAR (NO SIDEBAR!)
          // ───────────────────────────────────────────────────────────────────
          _buildConsumerTopNavBar(state, totalCartItems),

          // Main View Content
          Expanded(
            child: switch (_activeNavIndex) {
              0 => _buildMarketplaceStoreView(state),
              1 => _buildBasketAndOrdersView(state),
              2 => InDriveTransportTrackingView(onBack: () => setState(() => _activeNavIndex = 0)),
              3 => InDriveTransportTrackingView(onBack: () => setState(() => _activeNavIndex = 0)), // direct chats
              4 => _buildGroceryAiInsightsView(state),
              5 => const ConsumerSettingsView(),
              _ => _buildMarketplaceStoreView(state),
            },
          ),
        ],
      ),
    );
  }

  Widget _buildConsumerTopNavBar(AppState state, int totalCartItems) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)],
      ),
      child: Row(
        children: [
          // Brand Logo
          InkWell(
            onTap: () => setState(() => _activeNavIndex = 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.storefront, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('VERDI FRESH STORE', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w900, color: const Color(0xFF0F172A), letterSpacing: 0.5)),
                    const Text('Direct Farmgate Consumer Web Store', style: TextStyle(fontSize: 10, color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 24),

          // Search Bar (Desktop)
          if (isDesktop)
            Expanded(
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, size: 18, color: Color(0xFF94A3B8)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        onChanged: (v) => setState(() => _searchQuery = v),
                        decoration: const InputDecoration(
                          hintText: 'Search farm-fresh tomatoes, sweetcorn, spinach, eggs...',
                          hintStyle: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(width: 16),

          // Navigation Links
          Row(
            children: [
              _buildTopNavLink(0, 'Store', Icons.storefront_outlined),
              _buildTopNavLink(1, 'Basket ($totalCartItems)', Icons.shopping_basket_outlined, badge: totalCartItems > 0 ? '$totalCartItems' : null),
              _buildTopNavLink(2, 'Track Ride', Icons.local_shipping_outlined),
              _buildTopNavLink(4, 'Grocery AI', Icons.psychology_outlined),
              _buildTopNavLink(5, 'Settings', Icons.settings_outlined),
            ],
          ),

          const SizedBox(width: 12),

          // Buyer Profile Switcher Chip
          InkWell(
            onTap: () async {
              final chosen = await BuyerSubRoleDialog.show(context, current: state.buyerSubRole);
              if (chosen != null) {
                ref.read(appStateProvider.notifier).setBuyerSubRole(chosen);
              }
            },
            borderRadius: BorderRadius.circular(999),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.12),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: const Color(0xFF10B981).withOpacity(0.4)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.person_pin_circle_outlined, size: 14, color: Color(0xFF10B981)),
                  SizedBox(width: 5),
                  Text('End-User / Customer', style: TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.bold)),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_drop_down, size: 16, color: Color(0xFF10B981)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopNavLink(int index, String label, IconData icon, {String? badge}) {
    final isSelected = _activeNavIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: TextButton.icon(
        onPressed: () => setState(() => _activeNavIndex = index),
        icon: Badge(
          isLabelVisible: badge != null,
          label: Text(badge ?? ''),
          child: Icon(icon, size: 18, color: isSelected ? const Color(0xFF10B981) : const Color(0xFF64748B)),
        ),
        label: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? const Color(0xFF10B981) : const Color(0xFF475569),
          ),
        ),
        style: TextButton.styleFrom(
          backgroundColor: isSelected ? const Color(0xFF10B981).withOpacity(0.08) : Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // TAB 0: CONSUMER MARKETPLACE / HOME STORE VIEW
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildMarketplaceStoreView(AppState state) {
    final categories = ['All Fresh', 'Vegetables', 'Fruits', 'Eggs & Dairy', 'Grains & Flour', 'Herbs & Spices'];
    final filteredProduce = _produceCatalog.where((p) {
      final matchesCategory = _selectedCategory == 'All Fresh' || p.category == _selectedCategory;
      final matchesQuery = _searchQuery.isEmpty || p.name.toLowerCase().contains(_searchQuery.toLowerCase()) || p.farm.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesQuery;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Promotional Farm-to-Table Hero Banner
          _buildConsumerHeroBanner(),

          const SizedBox(height: 20),

          // 2. Grocery & Produce Freshness AI Insight Bar (Tailored for Consumer)
          _buildAiGroceryBanner(),

          const SizedBox(height: 20),

          // 3. Category Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: categories.map((cat) {
                final isSel = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(cat, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: isSel ? Colors.white : const Color(0xFF0F172A))),
                    selected: isSel,
                    selectedColor: const Color(0xFF10B981),
                    backgroundColor: Colors.white,
                    side: BorderSide(color: isSel ? const Color(0xFF10B981) : const Color(0xFFE2E8F0)),
                    onSelected: (_) => setState(() => _selectedCategory = cat),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 20),

          // 4. Fresh Produce Cards Grid
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Fresh Farmgate Harvest (${filteredProduce.length} available today)', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
              TextButton.icon(
                onPressed: () {
                  _showPushPopUp(
                    title: 'Flash Sale Promo Triggered',
                    message: 'Get 15% off all Mazowe tomatoes until 6 PM today!',
                    icon: Icons.local_offer_outlined,
                    color: const Color(0xFFF59E0B),
                  );
                },
                icon: const Icon(Icons.flash_on, color: Color(0xFFF59E0B), size: 16),
                label: const Text('View Flash Deals', style: TextStyle(color: Color(0xFFF59E0B), fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),

          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              int crossAxisCount = 4;
              if (width < 600) {
                crossAxisCount = 1;
              } else if (width < 900) {
                crossAxisCount = 2;
              } else if (width < 1200) {
                crossAxisCount = 3;
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredProduce.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemBuilder: (context, index) {
                  final item = filteredProduce[index];
                  return _buildProduceCard(item, state);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildConsumerHeroBanner() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.15), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: const Color(0xFF10B981).withOpacity(0.6)),
                  ),
                  child: const Text('ZERO MIDDLEMAN MARKUP • DIRECT FROM FARMERS', style: TextStyle(color: Color(0xFF10B981), fontSize: 10.5, fontWeight: FontWeight.w800)),
                ),
                const SizedBox(height: 12),
                Text(
                  'Fresh Farm-to-Doorstep Groceries',
                  style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white, height: 1.2),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Harvested this morning across Zimbabwean farms. Order now and track your fresh delivery in real-time with InDrive logistics.',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12.5, height: 1.4),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => setState(() => _selectedCategory = 'All Fresh'),
                  icon: const Icon(Icons.shopping_bag, size: 16),
                  label: const Text('Shop Farm Harvest', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.agriculture, color: Color(0xFF10B981), size: 64),
          ),
        ],
      ),
    );
  }

  Widget _buildAiGroceryBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.3)),
        boxShadow: [BoxShadow(color: const Color(0xFF3B82F6).withOpacity(0.04), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.psychology, color: Color(0xFF3B82F6), size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('AI Grocery Freshness & Price Arbitration', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13.5, color: const Color(0xFF0F172A))),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(4)),
                      child: const Text('SMART BUYER AI', style: TextStyle(color: Color(0xFF2563EB), fontSize: 9.5, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                const Text(
                  'Sugar Beans & Fresh Tomatoes are 18% cheaper today due to peak morning harvest in Mashonaland West. Best value window is active.',
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 11.5),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => setState(() => _activeNavIndex = 4),
            child: const Text('View AI Analysis', style: TextStyle(color: Color(0xFF3B82F6), fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildProduceCard(ProduceItem item, AppState state) {
    final quantityInCart = _cart[item.id] ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Produce Image / Icon Area
          Container(
            height: 110,
            decoration: BoxDecoration(
              color: item.iconColor.withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Stack(
              children: [
                Center(child: Icon(item.icon, color: item.iconColor, size: 48)),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(item.freshness, style: const TextStyle(color: Color(0xFF0F172A), fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: Color(0xFFF59E0B), size: 12),
                        const SizedBox(width: 3),
                        Text('${item.rating}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14, color: const Color(0xFF0F172A)), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text(item.farm, style: const TextStyle(color: Color(0xFF64748B), fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(state.currency.format(item.priceUsd), style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w900, color: const Color(0xFF10B981))),
                          Text(item.unit, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10.5)),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () => _addToCart(item),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: quantityInCart > 0 ? const Color(0xFF0F172A) : const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text(quantityInCart > 0 ? 'Add ($quantityInCart)' : '+ Add', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // TAB 1: FRESH BASKET & CHECKOUT WITH INDRIVE TRANSPORT
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildBasketAndOrdersView(AppState state) {
    final cartItems = _produceCatalog.where((p) => (_cart[p.id] ?? 0) > 0).toList();
    final double subtotalUsd = cartItems.fold(0.0, (sum, p) => sum + (p.priceUsd * (_cart[p.id] ?? 0)));
    final double transportFeeUsd = cartItems.isNotEmpty ? 2.50 : 0.0;
    final double totalUsd = subtotalUsd + transportFeeUsd;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your Fresh Produce Basket', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
          const SizedBox(height: 14),

          if (cartItems.isEmpty)
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
              child: Center(
                child: Column(
                  children: [
                    const Icon(Icons.shopping_basket_outlined, size: 48, color: Color(0xFF94A3B8)),
                    const SizedBox(height: 12),
                    const Text('Your produce basket is empty', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A))),
                    const SizedBox(height: 6),
                    const Text('Add fresh vegetables, fruits and farm harvests to start your order.', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => setState(() => _activeNavIndex = 0),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white),
                      child: const Text('Browse Farmgate Produce'),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: cartItems.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, idx) {
                final item = cartItems[idx];
                final count = _cart[item.id] ?? 0;
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
                  child: Row(
                    children: [
                      CircleAvatar(backgroundColor: item.iconColor.withOpacity(0.15), child: Icon(item.icon, color: item.iconColor)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.name, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14, color: const Color(0xFF0F172A))),
                            Text('${item.farm} • ${state.currency.format(item.priceUsd)} ${item.unit}', style: const TextStyle(color: Color(0xFF64748B), fontSize: 11.5)),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: Color(0xFF94A3B8), size: 20),
                            onPressed: () {
                              setState(() {
                                if (count > 1) {
                                  _cart[item.id] = count - 1;
                                } else {
                                  _cart.remove(item.id);
                                }
                              });
                            },
                          ),
                          Text('$count', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, color: Color(0xFF10B981), size: 20),
                            onPressed: () => _addToCart(item),
                          ),
                        ],
                      ),
                      const SizedBox(width: 10),
                      Text(state.currency.format(item.priceUsd * count), style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 14, color: const Color(0xFF0F172A))),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // Order Summary & InDrive Booking Box
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Delivery & Order Summary', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                  const SizedBox(height: 12),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Produce Subtotal', style: TextStyle(color: Color(0xFF64748B))), Text(state.currency.format(subtotalUsd), style: const TextStyle(fontWeight: FontWeight.bold))]),
                  const SizedBox(height: 6),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('InDrive Delivery (Harare Doorstep)', style: TextStyle(color: Color(0xFF64748B))), Text(state.currency.format(transportFeeUsd), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF10B981)))]),
                  const Divider(height: 24),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Total Order', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w900)), Text(state.currency.format(totalUsd), style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w900, color: const Color(0xFF10B981)))]),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _showPushPopUp(
                          title: 'Order Confirmed & InDrive Booked!',
                          message: 'Driver Blessing Chisora is en route to pick up your produce.',
                          icon: Icons.local_shipping,
                          color: const Color(0xFF10B981),
                        );
                        setState(() => _activeNavIndex = 2); // Jump to InDrive live tracking
                      },
                      icon: const Icon(Icons.lock, size: 16),
                      label: const Text('Checkout & Track InDrive Driver Live', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // TAB 4: GROCERY AI INSIGHTS VIEW
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildGroceryAiInsightsView(AppState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: const Color(0xFF3B82F6).withOpacity(0.12), shape: BoxShape.circle),
                child: const Icon(Icons.psychology, color: Color(0xFF3B82F6), size: 24),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Consumer Grocery & Produce Intelligence', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                  const Text('AI price alerts, harvest freshness predictions & nutrition tips', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          _buildAiCard('🍅 Tomato & Vegetable Price Drop (18% Savings)', 'Mashonaland West harvest surplus is lowering retail prices for Roma and Jam tomatoes. Ideal time for weekly household stocking.', const Color(0xFF10B981)),
          const SizedBox(height: 12),
          _buildAiCard('🥑 Avocado Ripeness & Peak Quality Indicator', 'Chipinge Hass avocados are at peak oil content this week. Shelf-life estimated at 6-8 days in cool ambient conditions.', const Color(0xFF059669)),
          const SizedBox(height: 12),
          _buildAiCard('🚚 Group Delivery Optimization', '3 other households in your Avondale area are ordering produce today. Your InDrive delivery fee was automatically shared, saving \$1.50.', const Color(0xFF3B82F6)),
        ],
      ),
    );
  }

  Widget _buildAiCard(String title, String desc, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [BoxShadow(color: color.withOpacity(0.04), blurRadius: 10)],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14, color: const Color(0xFF0F172A))),
                const SizedBox(height: 4),
                Text(desc, style: const TextStyle(color: Color(0xFF475569), fontSize: 12.5, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
